module AdminPage exposing
    ( AdminLoginData
    , Model
    , Msg(..)
    , ToBackend(..)
    , adminView
    , init
    , update
    )

import AnswerMap exposing (AnswerMap, Hotkey, OtherAnswer)
import AssocSet as Set exposing (Set)
import DataEntry exposing (DataEntryWithOther)
import Duration
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera as Lamdera
import Effect.Process as Process
import Effect.Task as Task
import Effect.Time
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Env
import Form exposing (Form, FormOtherQuestions, SpecificQuestion(..))
import FreeTextAnswerMap exposing (FreeTextAnswerMap)
import Html.Events
import List.Nonempty exposing (Nonempty)
import Questions exposing (Question)
import Serialize
import SurveyResults
import Ui exposing (MultiChoiceWithOther)


type Msg
    = PressedLogOut
    | TypedFormsData String
    | TypedGroupName Hotkey String
    | TypedNewGroupName String
    | TypedOtherAnswerGroups OtherAnswer String
    | RemoveGroup Hotkey
    | PressedQuestionWithOther SpecificQuestion
    | PressedToggleShowEncodedState
    | DebounceSaveAnswerMap Int
    | TypedComment String


type ToBackend
    = ReplaceFormsRequest (List Form)
    | SaveAnswerMap FormOtherQuestions
    | LogOutRequest


type alias AdminLoginData =
    { forms : List { form : Form, submitTime : Maybe Effect.Time.Posix }
    , formMapping : FormOtherQuestions
    }


type alias Model =
    { forms : List { form : Form, submitTime : Maybe Effect.Time.Posix }
    , formMapping : FormOtherQuestions
    , selectedMapping : SpecificQuestion
    , showEncodedState : Bool
    , debounceCount : Int
    }


init : AdminLoginData -> Model
init loginData =
    { forms = loginData.forms
    , formMapping = loginData.formMapping
    , selectedMapping = OtherLanguagesQuestion
    , showEncodedState = False
    , debounceCount = 0
    }


questionsWithOther : List SpecificQuestion
questionsWithOther =
    [ DoYouUseElmQuestion
    , AgeQuestion
    , FunctionalProgrammingExperienceQuestion
    , OtherLanguagesQuestion
    , NewsAndDiscussionsQuestion
    , ElmResourcesQuestion
    , CountryLivingInQuestion
    , ApplicationDomainsQuestion
    , DoYouUseElmAtWorkQuestion
    , HowLargeIsTheCompanyQuestion
    , WhatLanguageDoYouUseForBackendQuestion
    , HowLongQuestion
    , ElmVersionQuestion
    , DoYouUseElmFormatQuestion
    , StylingToolsQuestion
    , BuildToolsQuestion
    , FrameworksQuestion
    , EditorsQuestion
    , DoYouUseElmReviewQuestion
    , WhichElmReviewRulesDoYouUseQuestion
    , TestToolsQuestion
    , TestsWrittenForQuestion
    , ElmInitialInterestQuestion
    , BiggestPainPointQuestion
    , WhatDoYouLikeMostQuestion
    ]


otherLanguages =
    { getter = .otherLanguages
    , setter = \form value -> { form | otherLanguages = value }
    , existingChoices =
        List.Nonempty.toList Questions.otherLanguages.choices
            |> List.map Questions.otherLanguages.choiceToString
    , text = "OtherLanguages"
    }


newsAndDiscussions =
    { getter = .newsAndDiscussions
    , setter = \form value -> { form | newsAndDiscussions = value }
    , existingChoices =
        List.Nonempty.toList Questions.newsAndDiscussions.choices
            |> List.map Questions.newsAndDiscussions.choiceToString
    , text = "NewsAndDiscussions"
    }


elmResources =
    { getter = .elmResources
    , setter = \form value -> { form | elmResources = value }
    , existingChoices =
        List.Nonempty.toList Questions.elmResources.choices
            |> List.map Questions.elmResources.choiceToString
    , text = "ElmResources"
    }


applicationDomains =
    { getter = .applicationDomains
    , setter = \form value -> { form | applicationDomains = value }
    , existingChoices =
        List.Nonempty.toList Questions.applicationDomains.choices
            |> List.map Questions.applicationDomains.choiceToString
    , text = "ApplicationDomains"
    }


whatLanguageDoYouUseForBackend =
    { getter = .whatLanguageDoYouUseForBackend
    , setter = \form value -> { form | whatLanguageDoYouUseForBackend = value }
    , existingChoices =
        List.Nonempty.toList Questions.whatLanguageDoYouUseForBackend.choices
            |> List.map Questions.whatLanguageDoYouUseForBackend.choiceToString
    , text = "WhatLanguageDoYouUseForBackend"
    }


elmVersion =
    { getter = .elmVersion
    , setter = \form value -> { form | elmVersion = value }
    , existingChoices =
        List.Nonempty.toList Questions.elmVersion.choices
            |> List.map Questions.elmVersion.choiceToString
    , text = "ElmVersion"
    }


stylingTools =
    { getter = .stylingTools
    , setter = \form value -> { form | stylingTools = value }
    , existingChoices =
        List.Nonempty.toList Questions.stylingTools.choices
            |> List.map Questions.stylingTools.choiceToString
    , text = "StylingTools"
    }


buildTools =
    { getter = .buildTools
    , setter = \form value -> { form | buildTools = value }
    , existingChoices =
        List.Nonempty.toList Questions.buildTools.choices
            |> List.map Questions.buildTools.choiceToString
    , text = "BuildTools"
    }


frameworks =
    { getter = .frameworks
    , setter = \form value -> { form | frameworks = value }
    , existingChoices =
        List.Nonempty.toList Questions.frameworks.choices
            |> List.map Questions.frameworks.choiceToString
    , text = "Frameworks"
    }


editors =
    { getter = .editors
    , setter = \form value -> { form | editors = value }
    , existingChoices =
        List.Nonempty.toList Questions.editors.choices
            |> List.map Questions.editors.choiceToString
    , text = "Editors"
    }


whichElmReviewRulesDoYouUse =
    { getter = .whichElmReviewRulesDoYouUse
    , setter = \form value -> { form | whichElmReviewRulesDoYouUse = value }
    , existingChoices =
        List.Nonempty.toList Questions.whichElmReviewRulesDoYouUse.choices
            |> List.map Questions.whichElmReviewRulesDoYouUse.choiceToString
    , text = "WhichElmReviewRulesDoYouUse"
    }


testTools =
    { getter = .testTools
    , setter = \form value -> { form | testTools = value }
    , existingChoices =
        List.Nonempty.toList Questions.testTools.choices
            |> List.map Questions.testTools.choiceToString
    , text = "TestTools"
    }


testsWrittenFor =
    { getter = .testsWrittenFor
    , setter = \form value -> { form | testsWrittenFor = value }
    , existingChoices =
        List.Nonempty.toList Questions.testsWrittenFor.choices
            |> List.map Questions.testsWrittenFor.choiceToString
    , text = "TestsWrittenFor"
    }


elmInitialInterest =
    { getter = .elmInitialInterest
    , setter = \form value -> { form | elmInitialInterest = value }
    , existingChoices = []
    , text = "ElmInitialInterest"
    }


biggestPainPoint =
    { getter = .biggestPainPoint
    , setter = \form value -> { form | biggestPainPoint = value }
    , existingChoices = []
    , text = "BiggestPainPoint"
    }


whatDoYouLikeMost =
    { getter = .whatDoYouLikeMost
    , setter = \form value -> { form | whatDoYouLikeMost = value }
    , existingChoices = []
    , text = "WhatDoYouLikeMost"
    }


update : Msg -> Model -> ( Model, Command FrontendOnly ToBackend Msg )
update msg model =
    case msg of
        TypedFormsData text ->
            if Env.isProduction then
                ( model, Command.none )

            else
                case Serialize.decodeFromString (Serialize.list Form.formCodec) text of
                    Ok forms ->
                        ( { model
                            | forms =
                                List.map
                                    (\form -> { form = form, submitTime = Just (Effect.Time.millisToPosix 0) })
                                    forms
                          }
                        , ReplaceFormsRequest forms |> Lamdera.sendToBackend
                        )

                    Err _ ->
                        ( model, Command.none )

        PressedLogOut ->
            ( model, Lamdera.sendToBackend LogOutRequest )

        RemoveGroup hotkey ->
            let
                removeGroup : AnswerMap a -> AnswerMap a
                removeGroup =
                    AnswerMap.removeGroup hotkey

                removeGroup_ : FreeTextAnswerMap -> FreeTextAnswerMap
                removeGroup_ =
                    FreeTextAnswerMap.removeGroup hotkey

                answerMap =
                    model.formMapping
            in
            { model
                | formMapping =
                    case model.selectedMapping of
                        OtherLanguagesQuestion ->
                            { answerMap | otherLanguages = removeGroup answerMap.otherLanguages }

                        NewsAndDiscussionsQuestion ->
                            { answerMap | newsAndDiscussions = removeGroup answerMap.newsAndDiscussions }

                        ElmResourcesQuestion ->
                            { answerMap | elmResources = removeGroup answerMap.elmResources }

                        ApplicationDomainsQuestion ->
                            { answerMap | applicationDomains = removeGroup answerMap.applicationDomains }

                        WhatLanguageDoYouUseForBackendQuestion ->
                            { answerMap | whatLanguageDoYouUseForBackend = removeGroup answerMap.whatLanguageDoYouUseForBackend }

                        ElmVersionQuestion ->
                            { answerMap | elmVersion = removeGroup answerMap.elmVersion }

                        StylingToolsQuestion ->
                            { answerMap | stylingTools = removeGroup answerMap.stylingTools }

                        BuildToolsQuestion ->
                            { answerMap | buildTools = removeGroup answerMap.buildTools }

                        FrameworksQuestion ->
                            { answerMap | frameworks = removeGroup answerMap.frameworks }

                        EditorsQuestion ->
                            { answerMap | editors = removeGroup answerMap.editors }

                        WhichElmReviewRulesDoYouUseQuestion ->
                            { answerMap | whichElmReviewRulesDoYouUse = removeGroup answerMap.whichElmReviewRulesDoYouUse }

                        TestToolsQuestion ->
                            { answerMap | testTools = removeGroup answerMap.testTools }

                        TestsWrittenForQuestion ->
                            { answerMap | testsWrittenFor = removeGroup answerMap.testsWrittenFor }

                        ElmInitialInterestQuestion ->
                            { answerMap | elmInitialInterest = removeGroup_ answerMap.elmInitialInterest }

                        BiggestPainPointQuestion ->
                            { answerMap | biggestPainPoint = removeGroup_ answerMap.biggestPainPoint }

                        WhatDoYouLikeMostQuestion ->
                            { answerMap | whatDoYouLikeMost = removeGroup_ answerMap.whatDoYouLikeMost }

                        DoYouUseElmQuestion ->
                            answerMap

                        AgeQuestion ->
                            answerMap

                        FunctionalProgrammingExperienceQuestion ->
                            answerMap

                        CountryLivingInQuestion ->
                            answerMap

                        DoYouUseElmAtWorkQuestion ->
                            answerMap

                        HowLargeIsTheCompanyQuestion ->
                            answerMap

                        HowLongQuestion ->
                            answerMap

                        DoYouUseElmFormatQuestion ->
                            answerMap

                        DoYouUseElmReviewQuestion ->
                            answerMap
            }
                |> debounce

        PressedQuestionWithOther questionWithOther ->
            ( { model | selectedMapping = questionWithOther }, Command.none )

        PressedToggleShowEncodedState ->
            ( { model | showEncodedState = not model.showEncodedState }, Command.none )

        TypedGroupName hotkey groupName ->
            let
                renameGroup : AnswerMap a -> AnswerMap a
                renameGroup =
                    AnswerMap.renameGroup hotkey groupName

                renameGroup_ : FreeTextAnswerMap -> FreeTextAnswerMap
                renameGroup_ =
                    FreeTextAnswerMap.renameGroup hotkey groupName

                answerMap =
                    model.formMapping
            in
            { model
                | formMapping =
                    case model.selectedMapping of
                        OtherLanguagesQuestion ->
                            { answerMap | otherLanguages = renameGroup answerMap.otherLanguages }

                        NewsAndDiscussionsQuestion ->
                            { answerMap | newsAndDiscussions = renameGroup answerMap.newsAndDiscussions }

                        ElmResourcesQuestion ->
                            { answerMap | elmResources = renameGroup answerMap.elmResources }

                        ApplicationDomainsQuestion ->
                            { answerMap | applicationDomains = renameGroup answerMap.applicationDomains }

                        WhatLanguageDoYouUseForBackendQuestion ->
                            { answerMap | whatLanguageDoYouUseForBackend = renameGroup answerMap.whatLanguageDoYouUseForBackend }

                        ElmVersionQuestion ->
                            { answerMap | elmVersion = renameGroup answerMap.elmVersion }

                        StylingToolsQuestion ->
                            { answerMap | stylingTools = renameGroup answerMap.stylingTools }

                        BuildToolsQuestion ->
                            { answerMap | buildTools = renameGroup answerMap.buildTools }

                        FrameworksQuestion ->
                            { answerMap | frameworks = renameGroup answerMap.frameworks }

                        EditorsQuestion ->
                            { answerMap | editors = renameGroup answerMap.editors }

                        WhichElmReviewRulesDoYouUseQuestion ->
                            { answerMap | whichElmReviewRulesDoYouUse = renameGroup answerMap.whichElmReviewRulesDoYouUse }

                        TestToolsQuestion ->
                            { answerMap | testTools = renameGroup answerMap.testTools }

                        TestsWrittenForQuestion ->
                            { answerMap | testsWrittenFor = renameGroup answerMap.testsWrittenFor }

                        ElmInitialInterestQuestion ->
                            { answerMap | elmInitialInterest = renameGroup_ answerMap.elmInitialInterest }

                        BiggestPainPointQuestion ->
                            { answerMap | biggestPainPoint = renameGroup_ answerMap.biggestPainPoint }

                        WhatDoYouLikeMostQuestion ->
                            { answerMap | whatDoYouLikeMost = renameGroup_ answerMap.whatDoYouLikeMost }

                        DoYouUseElmQuestion ->
                            answerMap

                        AgeQuestion ->
                            answerMap

                        FunctionalProgrammingExperienceQuestion ->
                            answerMap

                        CountryLivingInQuestion ->
                            answerMap

                        DoYouUseElmAtWorkQuestion ->
                            answerMap

                        HowLargeIsTheCompanyQuestion ->
                            answerMap

                        HowLongQuestion ->
                            answerMap

                        DoYouUseElmFormatQuestion ->
                            answerMap

                        DoYouUseElmReviewQuestion ->
                            answerMap
            }
                |> debounce

        TypedNewGroupName groupName ->
            let
                addGroup : AnswerMap a -> AnswerMap a
                addGroup =
                    AnswerMap.addGroup groupName

                addGroup_ : FreeTextAnswerMap -> FreeTextAnswerMap
                addGroup_ =
                    FreeTextAnswerMap.addGroup groupName

                answerMap =
                    model.formMapping
            in
            { model
                | formMapping =
                    case model.selectedMapping of
                        OtherLanguagesQuestion ->
                            { answerMap | otherLanguages = addGroup answerMap.otherLanguages }

                        NewsAndDiscussionsQuestion ->
                            { answerMap | newsAndDiscussions = addGroup answerMap.newsAndDiscussions }

                        ElmResourcesQuestion ->
                            { answerMap | elmResources = addGroup answerMap.elmResources }

                        ApplicationDomainsQuestion ->
                            { answerMap | applicationDomains = addGroup answerMap.applicationDomains }

                        WhatLanguageDoYouUseForBackendQuestion ->
                            { answerMap | whatLanguageDoYouUseForBackend = addGroup answerMap.whatLanguageDoYouUseForBackend }

                        ElmVersionQuestion ->
                            { answerMap | elmVersion = addGroup answerMap.elmVersion }

                        StylingToolsQuestion ->
                            { answerMap | stylingTools = addGroup answerMap.stylingTools }

                        BuildToolsQuestion ->
                            { answerMap | buildTools = addGroup answerMap.buildTools }

                        FrameworksQuestion ->
                            { answerMap | frameworks = addGroup answerMap.frameworks }

                        EditorsQuestion ->
                            { answerMap | editors = addGroup answerMap.editors }

                        WhichElmReviewRulesDoYouUseQuestion ->
                            { answerMap | whichElmReviewRulesDoYouUse = addGroup answerMap.whichElmReviewRulesDoYouUse }

                        TestToolsQuestion ->
                            { answerMap | testTools = addGroup answerMap.testTools }

                        TestsWrittenForQuestion ->
                            { answerMap | testsWrittenFor = addGroup answerMap.testsWrittenFor }

                        ElmInitialInterestQuestion ->
                            { answerMap | elmInitialInterest = addGroup_ answerMap.elmInitialInterest }

                        BiggestPainPointQuestion ->
                            { answerMap | biggestPainPoint = addGroup_ answerMap.biggestPainPoint }

                        WhatDoYouLikeMostQuestion ->
                            { answerMap | whatDoYouLikeMost = addGroup_ answerMap.whatDoYouLikeMost }

                        DoYouUseElmQuestion ->
                            answerMap

                        AgeQuestion ->
                            answerMap

                        FunctionalProgrammingExperienceQuestion ->
                            answerMap

                        CountryLivingInQuestion ->
                            answerMap

                        DoYouUseElmAtWorkQuestion ->
                            answerMap

                        HowLargeIsTheCompanyQuestion ->
                            answerMap

                        HowLongQuestion ->
                            answerMap

                        DoYouUseElmFormatQuestion ->
                            answerMap

                        DoYouUseElmReviewQuestion ->
                            answerMap
            }
                |> debounce

        TypedOtherAnswerGroups otherAnswer text ->
            let
                updateOtherAnswer : AnswerMap a -> AnswerMap a
                updateOtherAnswer =
                    AnswerMap.updateOtherAnswer
                        (String.toList text |> List.map AnswerMap.hotkey)
                        otherAnswer

                updateOtherAnswer_ : FreeTextAnswerMap -> FreeTextAnswerMap
                updateOtherAnswer_ =
                    FreeTextAnswerMap.updateOtherAnswer
                        (String.toList text |> List.map AnswerMap.hotkey)
                        otherAnswer

                answerMap =
                    model.formMapping
            in
            { model
                | formMapping =
                    case model.selectedMapping of
                        OtherLanguagesQuestion ->
                            { answerMap | otherLanguages = updateOtherAnswer answerMap.otherLanguages }

                        NewsAndDiscussionsQuestion ->
                            { answerMap | newsAndDiscussions = updateOtherAnswer answerMap.newsAndDiscussions }

                        ElmResourcesQuestion ->
                            { answerMap | elmResources = updateOtherAnswer answerMap.elmResources }

                        ApplicationDomainsQuestion ->
                            { answerMap | applicationDomains = updateOtherAnswer answerMap.applicationDomains }

                        WhatLanguageDoYouUseForBackendQuestion ->
                            { answerMap | whatLanguageDoYouUseForBackend = updateOtherAnswer answerMap.whatLanguageDoYouUseForBackend }

                        ElmVersionQuestion ->
                            { answerMap | elmVersion = updateOtherAnswer answerMap.elmVersion }

                        StylingToolsQuestion ->
                            { answerMap | stylingTools = updateOtherAnswer answerMap.stylingTools }

                        BuildToolsQuestion ->
                            { answerMap | buildTools = updateOtherAnswer answerMap.buildTools }

                        FrameworksQuestion ->
                            { answerMap | frameworks = updateOtherAnswer answerMap.frameworks }

                        EditorsQuestion ->
                            { answerMap | editors = updateOtherAnswer answerMap.editors }

                        WhichElmReviewRulesDoYouUseQuestion ->
                            { answerMap | whichElmReviewRulesDoYouUse = updateOtherAnswer answerMap.whichElmReviewRulesDoYouUse }

                        TestToolsQuestion ->
                            { answerMap | testTools = updateOtherAnswer answerMap.testTools }

                        TestsWrittenForQuestion ->
                            { answerMap | testsWrittenFor = updateOtherAnswer answerMap.testsWrittenFor }

                        ElmInitialInterestQuestion ->
                            { answerMap | elmInitialInterest = updateOtherAnswer_ answerMap.elmInitialInterest }

                        BiggestPainPointQuestion ->
                            { answerMap | biggestPainPoint = updateOtherAnswer_ answerMap.biggestPainPoint }

                        WhatDoYouLikeMostQuestion ->
                            { answerMap | whatDoYouLikeMost = updateOtherAnswer_ answerMap.whatDoYouLikeMost }

                        DoYouUseElmQuestion ->
                            answerMap

                        AgeQuestion ->
                            answerMap

                        FunctionalProgrammingExperienceQuestion ->
                            answerMap

                        CountryLivingInQuestion ->
                            answerMap

                        DoYouUseElmAtWorkQuestion ->
                            answerMap

                        HowLargeIsTheCompanyQuestion ->
                            answerMap

                        HowLongQuestion ->
                            answerMap

                        DoYouUseElmFormatQuestion ->
                            answerMap

                        DoYouUseElmReviewQuestion ->
                            answerMap
            }
                |> debounce

        DebounceSaveAnswerMap debounceCount ->
            ( model
            , if debounceCount == model.debounceCount then
                Lamdera.sendToBackend (SaveAnswerMap model.formMapping)

              else
                Command.none
            )

        TypedComment text ->
            let
                withComment : AnswerMap a -> AnswerMap a
                withComment =
                    AnswerMap.withComment text

                withComment_ : FreeTextAnswerMap -> FreeTextAnswerMap
                withComment_ =
                    FreeTextAnswerMap.withComment text

                answerMap =
                    model.formMapping
            in
            { model
                | formMapping =
                    case model.selectedMapping of
                        OtherLanguagesQuestion ->
                            { answerMap | otherLanguages = withComment answerMap.otherLanguages }

                        NewsAndDiscussionsQuestion ->
                            { answerMap | newsAndDiscussions = withComment answerMap.newsAndDiscussions }

                        ElmResourcesQuestion ->
                            { answerMap | elmResources = withComment answerMap.elmResources }

                        ApplicationDomainsQuestion ->
                            { answerMap | applicationDomains = withComment answerMap.applicationDomains }

                        WhatLanguageDoYouUseForBackendQuestion ->
                            { answerMap | whatLanguageDoYouUseForBackend = withComment answerMap.whatLanguageDoYouUseForBackend }

                        ElmVersionQuestion ->
                            { answerMap | elmVersion = withComment answerMap.elmVersion }

                        StylingToolsQuestion ->
                            { answerMap | stylingTools = withComment answerMap.stylingTools }

                        BuildToolsQuestion ->
                            { answerMap | buildTools = withComment answerMap.buildTools }

                        FrameworksQuestion ->
                            { answerMap | frameworks = withComment answerMap.frameworks }

                        EditorsQuestion ->
                            { answerMap | editors = withComment answerMap.editors }

                        WhichElmReviewRulesDoYouUseQuestion ->
                            { answerMap | whichElmReviewRulesDoYouUse = withComment answerMap.whichElmReviewRulesDoYouUse }

                        TestToolsQuestion ->
                            { answerMap | testTools = withComment answerMap.testTools }

                        TestsWrittenForQuestion ->
                            { answerMap | testsWrittenFor = withComment answerMap.testsWrittenFor }

                        ElmInitialInterestQuestion ->
                            { answerMap | elmInitialInterest = withComment_ answerMap.elmInitialInterest }

                        BiggestPainPointQuestion ->
                            { answerMap | biggestPainPoint = withComment_ answerMap.biggestPainPoint }

                        WhatDoYouLikeMostQuestion ->
                            { answerMap | whatDoYouLikeMost = withComment_ answerMap.whatDoYouLikeMost }

                        DoYouUseElmQuestion ->
                            { answerMap | doYouUseElm = text }

                        AgeQuestion ->
                            { answerMap | age = text }

                        FunctionalProgrammingExperienceQuestion ->
                            { answerMap | functionalProgrammingExperience = text }

                        CountryLivingInQuestion ->
                            { answerMap | countryLivingIn = text }

                        DoYouUseElmAtWorkQuestion ->
                            { answerMap | doYouUseElmAtWork = text }

                        HowLargeIsTheCompanyQuestion ->
                            { answerMap | howLargeIsTheCompany = text }

                        HowLongQuestion ->
                            { answerMap | howLong = text }

                        DoYouUseElmFormatQuestion ->
                            { answerMap | doYouUseElmFormat = text }

                        DoYouUseElmReviewQuestion ->
                            { answerMap | doYouUseElmReview = text }
            }
                |> debounce


debounce : Model -> ( Model, Command FrontendOnly ToBackend Msg )
debounce model =
    ( { model | debounceCount = model.debounceCount + 1 }
    , Process.sleep Duration.second |> Task.perform (\() -> DebounceSaveAnswerMap (model.debounceCount + 1))
    )


button : Bool -> msg -> String -> Element msg
button isSelected onPress text =
    Element.Input.button
        [ Element.Background.color
            (if isSelected then
                Ui.blue1

             else
                Ui.white
            )
        , Element.Font.color Ui.black
        , Element.Font.bold
        , Element.padding 8
        , Element.Border.width 1
        , Element.Font.size 16
        ]
        { onPress = Just onPress
        , label = Element.text text
        }


deleteButton : msg -> Element msg
deleteButton onPress =
    Element.Input.button
        [ Element.Font.color Ui.black
        , Element.Font.bold
        , Element.paddingXY 6 4
        , Element.Border.width 1
        ]
        { onPress = Just onPress
        , label = Element.text "X"
        }


adminView : Model -> Element Msg
adminView model =
    Element.column
        [ Element.spacing 32, Element.padding 16 ]
        [ Element.el [ Element.Font.size 36 ] (Element.text "Admin view")
        , Element.row [ Element.spacing 16 ]
            [ button False PressedLogOut "Log out"
            , button model.showEncodedState PressedToggleShowEncodedState "Show encoded state"
            ]
        , if model.showEncodedState then
            Element.Input.text
                []
                { onChange = TypedFormsData
                , text =
                    List.filterMap
                        (\{ form, submitTime } ->
                            case submitTime of
                                Just _ ->
                                    Just form

                                Nothing ->
                                    Nothing
                        )
                        model.forms
                        |> Serialize.encodeToString (Serialize.list Form.formCodec)
                , placeholder = Nothing
                , label = Element.Input.labelHidden ""
                }

          else
            Element.none
        , List.map
            (\question ->
                button
                    (model.selectedMapping == question)
                    (PressedQuestionWithOther question)
                    (questionName question)
            )
            questionsWithOther
            |> Element.wrappedRow []
        , answerMapView model

        --, Element.column
        --    [ Element.spacing 32 ]
        --    (List.map adminFormView model.forms)
        ]


answerMapView : Model -> Element Msg
answerMapView model =
    let
        formMapping =
            model.formMapping
    in
    case model.selectedMapping of
        OtherLanguagesQuestion ->
            answerMappingView
                True
                Questions.otherLanguages
                .otherLanguages
                formMapping.otherLanguages
                model

        NewsAndDiscussionsQuestion ->
            answerMappingView
                False
                Questions.newsAndDiscussions
                .newsAndDiscussions
                formMapping.newsAndDiscussions
                model

        ElmResourcesQuestion ->
            answerMappingView
                False
                Questions.elmResources
                .elmResources
                formMapping.elmResources
                model

        ApplicationDomainsQuestion ->
            answerMappingView
                False
                Questions.applicationDomains
                .applicationDomains
                formMapping.applicationDomains
                model

        WhatLanguageDoYouUseForBackendQuestion ->
            answerMappingView
                True
                Questions.whatLanguageDoYouUseForBackend
                .whatLanguageDoYouUseForBackend
                formMapping.whatLanguageDoYouUseForBackend
                model

        ElmVersionQuestion ->
            answerMappingView
                False
                Questions.elmVersion
                .elmVersion
                formMapping.elmVersion
                model

        StylingToolsQuestion ->
            answerMappingView
                False
                Questions.stylingTools
                .stylingTools
                formMapping.stylingTools
                model

        BuildToolsQuestion ->
            answerMappingView
                False
                Questions.buildTools
                .buildTools
                formMapping.buildTools
                model

        FrameworksQuestion ->
            answerMappingView
                False
                Questions.frameworks
                .frameworks
                formMapping.frameworks
                model

        EditorsQuestion ->
            answerMappingView
                False
                Questions.editors
                .editors
                formMapping.editors
                model

        WhichElmReviewRulesDoYouUseQuestion ->
            answerMappingView
                False
                Questions.whichElmReviewRulesDoYouUse
                .whichElmReviewRulesDoYouUse
                formMapping.whichElmReviewRulesDoYouUse
                model

        TestToolsQuestion ->
            answerMappingView
                False
                Questions.testTools
                .testTools
                formMapping.testTools
                model

        TestsWrittenForQuestion ->
            answerMappingView
                False
                Questions.testsWrittenFor
                .testsWrittenFor
                formMapping.testsWrittenFor
                model

        ElmInitialInterestQuestion ->
            freeTextMappingView
                Questions.initialInterestTitle
                .elmInitialInterest
                formMapping.elmInitialInterest
                model

        BiggestPainPointQuestion ->
            freeTextMappingView
                Questions.biggestPainPointTitle
                .biggestPainPoint
                formMapping.biggestPainPoint
                model

        WhatDoYouLikeMostQuestion ->
            freeTextMappingView
                Questions.whatDoYouLikeMostTitle
                .whatDoYouLikeMost
                formMapping.whatDoYouLikeMost
                model

        DoYouUseElmQuestion ->
            Debug.todo ""

        --answerMappingView
        --    Nothing
        --    Questions.doYouUseElm
        --    (\a -> { choices = a.doYouUseElm, otherChecked = False, otherText = "" })
        --    formMapping.doYouUseElm
        --    model
        AgeQuestion ->
            commentEditor False Questions.age .age formMapping.age model

        FunctionalProgrammingExperienceQuestion ->
            commentEditor False Questions.experienceLevel .functionalProgrammingExperience formMapping.functionalProgrammingExperience model

        CountryLivingInQuestion ->
            commentEditor
                True
                Questions.countryLivingIn
                .countryLivingIn
                formMapping.countryLivingIn
                model

        DoYouUseElmAtWorkQuestion ->
            commentEditor False Questions.doYouUseElmAtWork .doYouUseElmAtWork formMapping.doYouUseElmAtWork model

        HowLargeIsTheCompanyQuestion ->
            commentEditor False Questions.howLargeIsTheCompany .howLargeIsTheCompany formMapping.howLargeIsTheCompany model

        HowLongQuestion ->
            commentEditor False Questions.howLong .howLong formMapping.howLong model

        DoYouUseElmFormatQuestion ->
            commentEditor False Questions.doYouUseElmFormat .doYouUseElmFormat formMapping.doYouUseElmFormat model

        DoYouUseElmReviewQuestion ->
            commentEditor False Questions.doYouUseElmReview .doYouUseElmReview formMapping.doYouUseElmReview model


questionName : SpecificQuestion -> String
questionName selectedMapping =
    case selectedMapping of
        OtherLanguagesQuestion ->
            "OtherLanguages"

        NewsAndDiscussionsQuestion ->
            "NewsAndDiscussions"

        ElmResourcesQuestion ->
            "ElmResources"

        ApplicationDomainsQuestion ->
            "ApplicationDomains"

        WhatLanguageDoYouUseForBackendQuestion ->
            "WhatLanguageDoYouUseForBackend"

        ElmVersionQuestion ->
            "ElmVersion"

        StylingToolsQuestion ->
            "StylingTools"

        BuildToolsQuestion ->
            "BuildTools"

        FrameworksQuestion ->
            "Frameworks"

        EditorsQuestion ->
            "Editors"

        WhichElmReviewRulesDoYouUseQuestion ->
            "WhichElmReviewRulesDoYouUse"

        TestToolsQuestion ->
            "TestTools"

        TestsWrittenForQuestion ->
            "TestsWrittenFor"

        ElmInitialInterestQuestion ->
            "ElmInitialInterest"

        BiggestPainPointQuestion ->
            "BiggestPainPoint"

        WhatDoYouLikeMostQuestion ->
            "WhatDoYouLikeMost"

        DoYouUseElmQuestion ->
            "DoYouUseElm"

        AgeQuestion ->
            "Age"

        FunctionalProgrammingExperienceQuestion ->
            "FunctionalProgrammingExperience"

        CountryLivingInQuestion ->
            "CountryLivingIn"

        DoYouUseElmAtWorkQuestion ->
            "DoYouUseElmAtWork"

        HowLargeIsTheCompanyQuestion ->
            "HowLargeIsTheCompany"

        HowLongQuestion ->
            "HowLong"

        DoYouUseElmFormatQuestion ->
            "DoYouUseElmFormat"

        DoYouUseElmReviewQuestion ->
            "DoYouUseElmReview"


commentEditor : Bool -> Question a -> (Form -> Maybe a) -> String -> Model -> Element Msg
commentEditor singleLine question getAnswer comment model =
    let
        answers : List a
        answers =
            submittedForms model.forms |> List.map getAnswer |> List.filterMap identity
    in
    Element.row [ Element.spacing 8 ]
        [ Element.Input.multiline
            [ Element.width Element.fill, Element.alignTop ]
            { onChange = TypedComment
            , text = comment
            , placeholder = Nothing
            , label = Element.Input.labelAbove [] (Element.text "Comment")
            , spellcheck = True
            }
        , SurveyResults.singleChoiceGraph
            { width = 1920, height = 1080 }
            singleLine
            True
            (DataEntry.fromForms comment question.choices answers)
            question
        ]


freeTextMappingView :
    String
    -> (Form -> String)
    -> FreeTextAnswerMap
    -> Model
    -> Element Msg
freeTextMappingView title getAnswer answerMap model =
    let
        answers : List String
        answers =
            submittedForms model.forms |> List.map getAnswer
    in
    Element.row
        [ Element.spacing 24, Element.width Element.fill ]
        [ Element.column
            [ Element.alignTop, Element.spacing 16 ]
            [ Element.text (questionName model.selectedMapping)
            , Element.column
                [ Element.spacing 8 ]
                (List.map
                    (\{ groupName, hotkey, editable } ->
                        Element.row [ Element.spacing 8 ]
                            [ Element.el
                                [ Element.Font.italic ]
                                (Element.text ("(" ++ AnswerMap.hotkeyToString hotkey ++ ")"))
                            , if editable then
                                Element.Input.text
                                    [ Element.width (Element.px 200), Element.paddingXY 4 6 ]
                                    { text = groupName
                                    , onChange = TypedGroupName hotkey
                                    , placeholder = Nothing
                                    , label = Element.Input.labelHidden "mapTo"
                                    }

                              else
                                Element.text groupName
                            , if editable then
                                deleteButton (RemoveGroup hotkey)

                              else
                                Element.none
                            ]
                    )
                    (FreeTextAnswerMap.allGroups answerMap)
                    ++ [ Element.row []
                            [ Element.el [ Element.Font.italic ] (Element.text "( ) ")
                            , Element.Input.text
                                [ Element.width (Element.px 200), Element.paddingXY 4 6 ]
                                { text = ""
                                , onChange = TypedNewGroupName
                                , placeholder = Nothing
                                , label = Element.Input.labelHidden "Group"
                                }
                            ]
                       ]
                )
            ]
        , Element.column
            [ Element.width Element.fill, Element.spacing 16 ]
            [ List.filterMap Form.getOtherAnswer_ answers
                |> List.sortBy (String.trim >> String.toLower)
                |> List.map
                    (\other ->
                        let
                            otherAnswer : OtherAnswer
                            otherAnswer =
                                AnswerMap.otherAnswer other
                        in
                        Element.row
                            [ Element.spacing 4 ]
                            [ Element.Input.text
                                [ Element.width (Element.px 80), Element.paddingXY 4 6 ]
                                { text =
                                    FreeTextAnswerMap.otherAnswerMapsTo otherAnswer answerMap
                                        |> List.map (.hotkey >> AnswerMap.hotkeyToString)
                                        |> String.concat
                                , onChange = TypedOtherAnswerGroups otherAnswer
                                , placeholder = Nothing
                                , label = Element.Input.labelHidden "New group"
                                }
                            , Element.paragraph [ Element.spacing 2 ] [ Element.text other ]
                            ]
                    )
                |> Element.column
                    [ Element.spacing 8
                    , Element.width Element.fill
                    , Element.scrollbars
                    , Element.height (Element.px 600)
                    , Element.alignTop
                    , Element.Border.width 1
                    , Element.padding 16
                    ]
            , Element.Input.multiline
                [ Element.width Element.fill ]
                { onChange = TypedComment
                , text = FreeTextAnswerMap.comment answerMap
                , placeholder = Nothing
                , label = Element.Input.labelAbove [] (Element.text "Comment")
                , spellcheck = True
                }
            ]
        , SurveyResults.freeText (DataEntry.fromFreeText answerMap answers) title
        ]


answerMappingView :
    Bool
    -> Question a
    -> (Form -> MultiChoiceWithOther a)
    -> AnswerMap a
    -> Model
    -> Element Msg
answerMappingView singleLine question getAnswer answerMap model =
    let
        answers : List (MultiChoiceWithOther a)
        answers =
            submittedForms model.forms |> List.map getAnswer
    in
    Element.row
        [ Element.spacing 24, Element.width Element.fill ]
        [ Element.column
            [ Element.alignTop, Element.spacing 16 ]
            [ Element.text (questionName model.selectedMapping)
            , Element.column
                [ Element.spacing 8 ]
                (List.map
                    (\{ groupName, hotkey, editable } ->
                        Element.row [ Element.spacing 8 ]
                            [ Element.el
                                [ Element.Font.italic ]
                                (Element.text ("(" ++ AnswerMap.hotkeyToString hotkey ++ ")"))
                            , if editable then
                                Element.Input.text
                                    [ Element.width (Element.px 200), Element.paddingXY 4 6 ]
                                    { text = groupName
                                    , onChange = TypedGroupName hotkey
                                    , placeholder = Nothing
                                    , label = Element.Input.labelHidden "mapTo"
                                    }

                              else
                                Element.text groupName
                            , if editable then
                                deleteButton (RemoveGroup hotkey)

                              else
                                Element.none
                            ]
                    )
                    (AnswerMap.allGroups question answerMap)
                    ++ [ Element.row []
                            [ Element.el [ Element.Font.italic ] (Element.text "( ) ")
                            , Element.Input.text
                                [ Element.width (Element.px 200), Element.paddingXY 4 6 ]
                                { text = ""
                                , onChange = TypedNewGroupName
                                , placeholder = Nothing
                                , label = Element.Input.labelHidden "Group"
                                }
                            ]
                       ]
                )
            ]
        , Element.column
            [ Element.width Element.fill, Element.spacing 16, Element.alignTop ]
            [ List.filterMap Form.getOtherAnswer answers
                |> List.sortBy (String.trim >> String.toLower)
                |> List.map
                    (\other ->
                        let
                            otherAnswer : OtherAnswer
                            otherAnswer =
                                AnswerMap.otherAnswer other
                        in
                        Element.row
                            [ Element.spacing 4 ]
                            [ Element.Input.text
                                [ Element.width (Element.px 80), Element.paddingXY 4 6 ]
                                { text =
                                    AnswerMap.otherAnswerMapsTo question otherAnswer answerMap
                                        |> List.map (.hotkey >> AnswerMap.hotkeyToString)
                                        |> String.concat
                                , onChange = TypedOtherAnswerGroups otherAnswer
                                , placeholder = Nothing
                                , label = Element.Input.labelHidden "New group"
                                }
                            , Element.paragraph [ Element.spacing 2 ] [ Element.text other ]
                            ]
                    )
                |> Element.column
                    [ Element.spacing 8
                    , Element.width Element.fill
                    , Element.scrollbars
                    , Element.height (Element.px 600)
                    , Element.alignTop
                    , Element.Border.width 1
                    , Element.padding 16
                    ]
            , Element.Input.multiline
                [ Element.width Element.fill ]
                { onChange = TypedComment
                , text = AnswerMap.comment answerMap
                , placeholder = Nothing
                , label = Element.Input.labelAbove [] (Element.text "Comment")
                , spellcheck = True
                }
            ]
        , SurveyResults.multiChoiceWithOther
            { width = 1920, height = 1080 }
            singleLine
            (DataEntry.fromMultiChoiceWithOther question answerMap answers)
            question
        ]


textInput :
    List (Element.Attribute msg)
    ->
        { text : String
        , onChange : String -> msg
        , onFocus : msg
        , onBlur : msg
        , placeholder : Maybe (Element.Input.Placeholder msg)
        , label : Element.Input.Label msg
        }
    -> Element msg
textInput attributes { text, onChange, onFocus, onBlur, placeholder, label } =
    Element.Input.text
        (Element.htmlAttribute (Html.Events.onFocus onFocus)
            :: Element.htmlAttribute (Html.Events.onBlur onBlur)
            :: attributes
        )
        { text = text
        , onChange = onChange
        , placeholder = placeholder
        , label = label
        }


submittedForms : List { form : Form, submitTime : Maybe Effect.Time.Posix } -> List Form
submittedForms forms =
    List.filterMap
        (\{ form, submitTime } ->
            case submitTime of
                Just _ ->
                    Just form

                Nothing ->
                    Nothing
        )
        forms


adminFormView : { form : Form, submitTime : Maybe Effect.Time.Posix } -> Element msg
adminFormView { form, submitTime } =
    Element.column
        [ Element.spacing 8 ]
        [ case submitTime of
            Just time ->
                Element.text ("Submitted at " ++ String.fromInt (Effect.Time.posixToMillis time))

            Nothing ->
                Element.text "Not submitted"
        , infoRow "doYouUseElm" (setToString Questions.doYouUseElm form.doYouUseElm)
        , infoRow "age" (maybeToString Questions.age form.age)
        , infoRow "functionalProgrammingExperience" (maybeToString Questions.experienceLevel form.functionalProgrammingExperience)
        , infoRow "otherLanguages" (multichoiceToString Questions.otherLanguages form.otherLanguages)
        , infoRow "newsAndDiscussions" (multichoiceToString Questions.newsAndDiscussions form.newsAndDiscussions)
        , infoRow "elmResources" (multichoiceToString Questions.elmResources form.elmResources)
        , infoRow "countryLivingIn" (maybeToString Questions.countryLivingIn form.countryLivingIn)
        , infoRow "applicationDomains" (multichoiceToString Questions.applicationDomains form.applicationDomains)
        , infoRow "doYouUseElmAtWork" (maybeToString Questions.doYouUseElmAtWork form.doYouUseElmAtWork)
        , infoRow "howLargeIsTheCompany" (maybeToString Questions.howLargeIsTheCompany form.howLargeIsTheCompany)
        , infoRow "whatLanguageDoYouUseForBackend" (multichoiceToString Questions.whatLanguageDoYouUseForBackend form.whatLanguageDoYouUseForBackend)
        , infoRow "howLong" (maybeToString Questions.howLong form.howLong)
        , infoRow "elmVersion" (multichoiceToString Questions.elmVersion form.elmVersion)
        , infoRow "doYouUseElmFormat" (maybeToString Questions.doYouUseElmFormat form.doYouUseElmFormat)
        , infoRow "stylingTools" (multichoiceToString Questions.stylingTools form.stylingTools)
        , infoRow "buildTools" (multichoiceToString Questions.buildTools form.buildTools)
        , infoRow "frameworks" (multichoiceToString Questions.frameworks form.frameworks)
        , infoRow "editors" (multichoiceToString Questions.editors form.editors)
        , infoRow "doYouUseElmReview" (maybeToString Questions.doYouUseElmReview form.doYouUseElmReview)
        , infoRow "whichElmReviewRulesDoYouUse" (multichoiceToString Questions.whichElmReviewRulesDoYouUse form.whichElmReviewRulesDoYouUse)
        , infoRow "testTools" (multichoiceToString Questions.testTools form.testTools)
        , infoRow "testsWrittenFor" (multichoiceToString Questions.testsWrittenFor form.testsWrittenFor)
        , infoRow "elmInitialInterest" form.elmInitialInterest
        , infoRow "biggestPainPoint" form.biggestPainPoint
        , infoRow "whatDoYouLikeMost" form.whatDoYouLikeMost
        , infoRow "emailAddress" form.emailAddress
        ]


multichoiceToString : Question a -> Ui.MultiChoiceWithOther a -> String
multichoiceToString { choiceToString } multiChoiceWithOther =
    Set.toList multiChoiceWithOther.choices
        |> List.map choiceToString
        |> (\choices ->
                if multiChoiceWithOther.otherChecked then
                    choices ++ [ multiChoiceWithOther.otherText ]

                else
                    choices
           )
        |> String.join ", "


setToString : Question a -> Set a -> String
setToString { choiceToString } set =
    Set.toList set
        |> List.map choiceToString
        |> String.join ", "


maybeToString : Question a -> Maybe a -> String
maybeToString { choiceToString } maybe =
    case maybe of
        Just a ->
            choiceToString a

        Nothing ->
            ""


infoRow name value =
    Element.row
        [ Element.spacing 24 ]
        [ Element.el [ Element.Font.color (Element.rgb 0.4 0.5 0.5) ] (Element.text name)
        , Element.paragraph [] [ Element.text value ]
        ]
