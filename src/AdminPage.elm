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
    | AnswerMapChanged (FormOtherQuestions AnswerMap)
    | PressedQuestionWithOther QuestionWithOther
    | PressedToggleShowEncodedState
    | DebounceSaveAnswerMap Int


type ToBackend
    = ReplaceFormsRequest (List Form)
    | SaveAnswerMap (FormOtherQuestions AnswerMap)
    | LogOutRequest


type alias AdminLoginData =
    { forms : List { form : Form, submitTime : Maybe Effect.Time.Posix }
    , formMapping : FormOtherQuestions AnswerMap
    }


type alias Model =
    { forms : List { form : Form, submitTime : Maybe Effect.Time.Posix }
    , formMapping : FormOtherQuestions AnswerMap
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


questionWithOtherData :
    QuestionWithOther
    ->
        { getter : FormOtherQuestions a -> a
        , setter : FormOtherQuestions a -> a -> FormOtherQuestions a
        , existingChoices : List String
        , text : String
        }
questionWithOtherData a =
    case a of
        OtherLanguagesQuestion ->
            otherLanguages

        NewsAndDiscussionsQuestion ->
            newsAndDiscussions

        ElmResourcesQuestion ->
            elmResources

        ApplicationDomainsQuestion ->
            applicationDomains

        WhatLanguageDoYouUseForBackendQuestion ->
            whatLanguageDoYouUseForBackend

        ElmVersionQuestion ->
            elmVersion

        StylingToolsQuestion ->
            stylingTools

        BuildToolsQuestion ->
            buildTools

        FrameworksQuestion ->
            frameworks

        EditorsQuestion ->
            editors

        WhichElmReviewRulesDoYouUseQuestion ->
            whichElmReviewRulesDoYouUse

        TestToolsQuestion ->
            testTools

        TestsWrittenForQuestion ->
            testsWrittenFor

        ElmInitialInterestQuestion ->
            elmInitialInterest

        BiggestPainPointQuestion ->
            biggestPainPoint

        WhatDoYouLikeMostQuestion ->
            whatDoYouLikeMost


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

        AnswerMapChanged newFormMapping ->
            { model | formMapping = newFormMapping } |> debounce

        PressedQuestionWithOther questionWithOther ->
            ( { model | selectedMapping = questionWithOther }, Command.none )

        PressedToggleShowEncodedState ->
            ( { model | showEncodedState = not model.showEncodedState }, Command.none )

        TypedGroupName hotkey groupName ->
            let
                mappingData =
                    questionWithOtherData model.selectedMapping

                mapping : AnswerMap
                mapping =
                    mappingData.getter model.formMapping
            in
            { model
                | formMapping =
                    AnswerMap.renameGroup hotkey groupName mapping
                        |> mappingData.setter model.formMapping
            }
                |> debounce

        TypedNewGroupName groupName ->
            let
                mappingData =
                    questionWithOtherData model.selectedMapping

                mapping : AnswerMap
                mapping =
                    mappingData.getter model.formMapping
            in
            { model
                | formMapping =
                    AnswerMap.addGroup groupName mapping
                        |> mappingData.setter model.formMapping
            }
                |> debounce

        TypedOtherAnswerGroups otherAnswer text ->
            let
                mappingData =
                    questionWithOtherData model.selectedMapping

                mapping : AnswerMap
                mapping =
                    mappingData.getter model.formMapping
            in
            { model
                | formMapping =
                    AnswerMap.updateOtherAnswer
                        (String.toList text |> List.map AnswerMap.hotkey)
                        otherAnswer
                        mapping
                        |> mappingData.setter model.formMapping
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
                    (questionWithOtherData question).text
            )
            questionsWithOther
            |> Element.wrappedRow []
        , answerMappingView model

        --, Element.column
        --    [ Element.spacing 32 ]
        --    (List.map adminFormView model.forms)
        ]


answerMappingView : Model -> Element Msg
answerMappingView model =
    let
        mappingData =
            questionWithOtherData model.selectedMapping

        mapping : AnswerMap
        mapping =
            mappingData.getter model.formMapping
    in
    Element.row
        [ Element.spacing 24, Element.width Element.fill ]
        [ Element.column
            [ Element.alignTop, Element.spacing 16 ]
            [ Element.text mappingData.text
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
                                deleteButton
                                    (AnswerMap.removeGroup hotkey mapping
                                        |> mappingData.setter model.formMapping
                                        |> AnswerMapChanged
                                    )

                              else
                                Element.none
                            ]
                    )
                    (AnswerMap.allGroups mappingData.existingChoices mapping)
                    ++ [ Element.row []
                            [ Element.el [ Element.Font.italic ] (Element.text "( ) ")
                            , Element.Input.text
                                [ Element.width (Element.px 200), Element.paddingXY 4 6 ]
                                { text = ""
                                , onChange = TypedNewGroupName
                                , placeholder = Nothing
                                , label = Element.Input.labelHidden "mapTo"
                                }
                            ]
                       ]
                )
            ]
        , submittedForms model.forms
            |> List.map Form.formToOtherAnswers
            |> List.filterMap mappingData.getter
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
                                AnswerMap.otherAnswerMapsTo otherAnswer mapping
                                    |> List.map AnswerMap.hotkeyToString
                                    |> String.concat
                            , onChange = TypedOtherAnswerGroups otherAnswer
                            , placeholder = Nothing
                            , label = Element.Input.labelHidden "mapTo"
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
