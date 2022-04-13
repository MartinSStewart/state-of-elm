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
import Form exposing (Form, FormOtherQuestions, QuestionWithOther(..))
import Html.Events
import List.Nonempty exposing (Nonempty)
import Questions exposing (Question)
import Serialize
import Ui


type Msg
    = PressedLogOut
    | TypedFormsData String
    | TypedGroupName Hotkey String
    | TypedNewGroupName String
    | TypedOtherAnswerGroups OtherAnswer String
    | RemoveGroup Hotkey
    | PressedQuestionWithOther QuestionWithOther
    | PressedToggleShowEncodedState
    | DebounceSaveAnswerMap Int


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
    , selectedMapping : QuestionWithOther
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


questionsWithOther : List QuestionWithOther
questionsWithOther =
    [ OtherLanguagesQuestion
    , NewsAndDiscussionsQuestion
    , ElmResourcesQuestion
    , ApplicationDomainsQuestion
    , WhatLanguageDoYouUseForBackendQuestion
    , ElmVersionQuestion
    , StylingToolsQuestion
    , BuildToolsQuestion
    , FrameworksQuestion
    , EditorsQuestion
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
                            { answerMap | elmInitialInterest = removeGroup answerMap.elmInitialInterest }

                        BiggestPainPointQuestion ->
                            { answerMap | biggestPainPoint = removeGroup answerMap.biggestPainPoint }

                        WhatDoYouLikeMostQuestion ->
                            { answerMap | whatDoYouLikeMost = removeGroup answerMap.whatDoYouLikeMost }
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
                            { answerMap | elmInitialInterest = renameGroup answerMap.elmInitialInterest }

                        BiggestPainPointQuestion ->
                            { answerMap | biggestPainPoint = renameGroup answerMap.biggestPainPoint }

                        WhatDoYouLikeMostQuestion ->
                            { answerMap | whatDoYouLikeMost = renameGroup answerMap.whatDoYouLikeMost }
            }
                |> debounce

        TypedNewGroupName groupName ->
            let
                addGroup : AnswerMap a -> AnswerMap a
                addGroup =
                    AnswerMap.addGroup groupName

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
                            { answerMap | elmInitialInterest = addGroup answerMap.elmInitialInterest }

                        BiggestPainPointQuestion ->
                            { answerMap | biggestPainPoint = addGroup answerMap.biggestPainPoint }

                        WhatDoYouLikeMostQuestion ->
                            { answerMap | whatDoYouLikeMost = addGroup answerMap.whatDoYouLikeMost }
            }
                |> debounce

        TypedOtherAnswerGroups otherAnswer text ->
            let
                updateOtherAnswer : AnswerMap a -> AnswerMap a
                updateOtherAnswer =
                    AnswerMap.updateOtherAnswer
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
                            { answerMap | elmInitialInterest = updateOtherAnswer answerMap.elmInitialInterest }

                        BiggestPainPointQuestion ->
                            { answerMap | biggestPainPoint = updateOtherAnswer answerMap.biggestPainPoint }

                        WhatDoYouLikeMostQuestion ->
                            { answerMap | whatDoYouLikeMost = updateOtherAnswer answerMap.whatDoYouLikeMost }
            }
                |> debounce

        DebounceSaveAnswerMap debounceCount ->
            ( model
            , if debounceCount == model.debounceCount then
                Lamdera.sendToBackend (SaveAnswerMap model.formMapping)

              else
                Command.none
            )


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
        , Element.padding 16
        , Element.Border.width 1
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
        , button False PressedLogOut "Log out"
        , button model.showEncodedState PressedToggleShowEncodedState "Show encoded state"
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
                    (questionName model.selectedMapping)
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
                Questions.otherLanguages
                (.otherLanguages >> Form.getOtherAnswer)
                formMapping.otherLanguages
                model

        NewsAndDiscussionsQuestion ->
            answerMappingView
                Questions.newsAndDiscussions
                (.newsAndDiscussions >> Form.getOtherAnswer)
                formMapping.newsAndDiscussions
                model

        ElmResourcesQuestion ->
            answerMappingView
                Questions.elmResources
                (.elmResources >> Form.getOtherAnswer)
                formMapping.elmResources
                model

        ApplicationDomainsQuestion ->
            answerMappingView
                Questions.applicationDomains
                (.applicationDomains >> Form.getOtherAnswer)
                formMapping.applicationDomains
                model

        WhatLanguageDoYouUseForBackendQuestion ->
            answerMappingView
                Questions.whatLanguageDoYouUseForBackend
                (.whatLanguageDoYouUseForBackend >> Form.getOtherAnswer)
                formMapping.whatLanguageDoYouUseForBackend
                model

        ElmVersionQuestion ->
            answerMappingView
                Questions.elmVersion
                (.elmVersion >> Form.getOtherAnswer)
                formMapping.elmVersion
                model

        StylingToolsQuestion ->
            answerMappingView
                Questions.stylingTools
                (.stylingTools >> Form.getOtherAnswer)
                formMapping.stylingTools
                model

        BuildToolsQuestion ->
            answerMappingView
                Questions.buildTools
                (.buildTools >> Form.getOtherAnswer)
                formMapping.buildTools
                model

        FrameworksQuestion ->
            answerMappingView
                Questions.frameworks
                (.frameworks >> Form.getOtherAnswer)
                formMapping.frameworks
                model

        EditorsQuestion ->
            answerMappingView
                Questions.editors
                (.editors >> Form.getOtherAnswer)
                formMapping.editors
                model

        WhichElmReviewRulesDoYouUseQuestion ->
            answerMappingView
                Questions.whichElmReviewRulesDoYouUse
                (.whichElmReviewRulesDoYouUse >> Form.getOtherAnswer)
                formMapping.whichElmReviewRulesDoYouUse
                model

        TestToolsQuestion ->
            answerMappingView
                Questions.testTools
                (.testTools >> Form.getOtherAnswer)
                formMapping.testTools
                model

        TestsWrittenForQuestion ->
            answerMappingView
                Questions.testsWrittenFor
                (.testsWrittenFor >> Form.getOtherAnswer)
                formMapping.testsWrittenFor
                model

        ElmInitialInterestQuestion ->
            Debug.todo ""

        --answerMappingView Questions.elmInitialInterest
        BiggestPainPointQuestion ->
            Debug.todo ""

        --answerMappingView Questions.biggestPainPoint
        WhatDoYouLikeMostQuestion ->
            Debug.todo ""


questionName : QuestionWithOther -> String
questionName selectedMapping =
    case selectedMapping of
        OtherLanguagesQuestion ->
            "OtherLanguagesQuestion"

        NewsAndDiscussionsQuestion ->
            "NewsAndDiscussionsQuestion"

        ElmResourcesQuestion ->
            "ElmResourcesQuestion"

        ApplicationDomainsQuestion ->
            "ApplicationDomainsQuestion"

        WhatLanguageDoYouUseForBackendQuestion ->
            "WhatLanguageDoYouUseForBackendQuestion"

        ElmVersionQuestion ->
            "ElmVersionQuestion"

        StylingToolsQuestion ->
            "StylingToolsQuestion"

        BuildToolsQuestion ->
            "BuildToolsQuestion"

        FrameworksQuestion ->
            "FrameworksQuestion"

        EditorsQuestion ->
            "EditorsQuestion"

        WhichElmReviewRulesDoYouUseQuestion ->
            "WhichElmReviewRulesDoYouUseQuestion"

        TestToolsQuestion ->
            "TestToolsQuestion"

        TestsWrittenForQuestion ->
            "TestsWrittenForQuestion"

        ElmInitialInterestQuestion ->
            "ElmInitialInterestQuestion"

        BiggestPainPointQuestion ->
            "BiggestPainPointQuestion"

        WhatDoYouLikeMostQuestion ->
            "WhatDoYouLikeMostQuestion"


answerMappingView : Question a -> (Form -> Maybe String) -> AnswerMap a -> Model -> Element Msg
answerMappingView question getAnswer answerMap model =
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
        , submittedForms model.forms
            |> List.filterMap getAnswer
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
        , infoRow "countryLivingIn" form.countryLivingIn
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
