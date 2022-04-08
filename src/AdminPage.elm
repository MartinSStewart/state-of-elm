module AdminPage exposing
    ( AdminLoginData
    , FormMapData
    , Model
    , Msg(..)
    , ToBackend(..)
    , adminView
    , init
    , subscription
    , update
    )

import AssocSet as Set exposing (Set)
import Effect.Browser.Events
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera
import Effect.Subscription exposing (Subscription)
import Effect.Time
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Env
import Form exposing (Form, FormOtherQuestions, QuestionWithOther(..))
import Json.Decode
import List.Extra as List
import Questions exposing (Question)
import Serialize
import Ui


type Msg
    = PressedLogOut
    | TypedFormsData String
    | TypedMapTo (FormOtherQuestions FormMapData)
    | PressedQuestionWithOther QuestionWithOther
    | PressedKey String


type ToBackend
    = ReplaceFormsRequest (List Form)
    | LogOutRequest


type alias AdminLoginData =
    { forms : List { form : Form, submitTime : Maybe Effect.Time.Posix }
    , formMapping : FormOtherQuestions FormMapData
    }


type alias Model =
    { forms : List { form : Form, submitTime : Maybe Effect.Time.Posix }
    , formMapping : FormOtherQuestions FormMapData
    , selectedMapping : QuestionWithOther
    }


subscription : Subscription FrontendOnly Msg
subscription =
    Effect.Browser.Events.onKeyPress
        (Json.Decode.field "key" Json.Decode.string
            |> Json.Decode.andThen
                (\key ->
                    Debug.log "key" key |> PressedKey |> Json.Decode.succeed
                )
        )


init : AdminLoginData -> Model
init loginData =
    { forms = loginData.forms
    , formMapping = loginData.formMapping
    , selectedMapping = OtherLanguagesQuestion
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


questionWithOtherData :
    QuestionWithOther
    ->
        { getter : FormOtherQuestions a -> a
        , setter : a -> FormOtherQuestions a -> FormOtherQuestions a
        , text : String
        }
questionWithOtherData a =
    case a of
        OtherLanguagesQuestion ->
            { getter = .otherLanguages
            , setter = \value form -> { form | otherLanguages = value }
            , text = "OtherLanguages"
            }

        NewsAndDiscussionsQuestion ->
            { getter = .newsAndDiscussions
            , setter = \value form -> { form | newsAndDiscussions = value }
            , text = "NewsAndDiscussions"
            }

        ElmResourcesQuestion ->
            { getter = .elmResources
            , setter = \value form -> { form | elmResources = value }
            , text = "ElmResources"
            }

        ApplicationDomainsQuestion ->
            { getter = .applicationDomains
            , setter = \value form -> { form | applicationDomains = value }
            , text = "ApplicationDomains"
            }

        WhatLanguageDoYouUseForBackendQuestion ->
            { getter = .whatLanguageDoYouUseForBackend
            , setter = \value form -> { form | whatLanguageDoYouUseForBackend = value }
            , text = "WhatLanguageDoYouUseForBackend"
            }

        ElmVersionQuestion ->
            { getter = .elmVersion
            , setter = \value form -> { form | elmVersion = value }
            , text = "ElmVersion"
            }

        StylingToolsQuestion ->
            { getter = .stylingTools
            , setter = \value form -> { form | stylingTools = value }
            , text = "StylingTools"
            }

        BuildToolsQuestion ->
            { getter = .buildTools
            , setter = \value form -> { form | buildTools = value }
            , text = "BuildTools"
            }

        FrameworksQuestion ->
            { getter = .frameworks
            , setter = \value form -> { form | frameworks = value }
            , text = "Frameworks"
            }

        EditorsQuestion ->
            { getter = .editors
            , setter = \value form -> { form | editors = value }
            , text = "Editors"
            }

        WhichElmReviewRulesDoYouUseQuestion ->
            { getter = .whichElmReviewRulesDoYouUse
            , setter = \value form -> { form | whichElmReviewRulesDoYouUse = value }
            , text = "WhichElmReviewRulesDoYouUse"
            }

        TestToolsQuestion ->
            { getter = .testTools
            , setter = \value form -> { form | testTools = value }
            , text = "TestTools"
            }

        TestsWrittenForQuestion ->
            { getter = .testsWrittenFor
            , setter = \value form -> { form | testsWrittenFor = value }
            , text = "TestsWrittenFor"
            }

        ElmInitialInterestQuestion ->
            { getter = .elmInitialInterest
            , setter = \value form -> { form | elmInitialInterest = value }
            , text = "ElmInitialInterest"
            }

        BiggestPainPointQuestion ->
            { getter = .biggestPainPoint
            , setter = \value form -> { form | biggestPainPoint = value }
            , text = "BiggestPainPoint"
            }

        WhatDoYouLikeMostQuestion ->
            { getter = .whatDoYouLikeMost
            , setter = \value form -> { form | whatDoYouLikeMost = value }
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
                        , ReplaceFormsRequest forms |> Effect.Lamdera.sendToBackend
                        )

                    Err _ ->
                        ( model, Command.none )

        PressedLogOut ->
            ( model, Effect.Lamdera.sendToBackend LogOutRequest )

        TypedMapTo newFormMapping ->
            ( { model | formMapping = newFormMapping }, Command.none )

        PressedQuestionWithOther questionWithOther ->
            ( { model | selectedMapping = questionWithOther }, Command.none )

        PressedKey key ->
            let
                { getter, setter, text } =
                    questionWithOtherData model.selectedMapping

                mapping : FormMapData
                mapping =
                    getter model.formMapping
            in
            case ( hotkeyToIndex key, currentOtherAnswer model ) of
                ( Just index, Just otherAnswer ) ->
                    ( { model
                        | formMapping =
                            List.updateAt index
                                (\{ groupName, otherAnswers } ->
                                    { groupName = groupName, otherAnswers = toggleSet otherAnswer otherAnswers }
                                )
                                mapping
                                |> (\a -> setter a model.formMapping)
                      }
                    , Command.none
                    )

                _ ->
                    ( model, Command.none )


currentOtherAnswer : Model -> Maybe String
currentOtherAnswer model =
    let
        { getter, setter, text } =
            questionWithOtherData model.selectedMapping
    in
    submittedForms model
        |> List.map Form.formToOtherAnswers
        |> List.filterMap getter
        |> List.head


toggleSet : a -> Set a -> Set a
toggleSet a set =
    if Set.member a set then
        Set.remove a set

    else
        Set.insert a set


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


adminView : Model -> Element Msg
adminView model =
    Element.column
        [ Element.spacing 32, Element.padding 16 ]
        [ Element.el [ Element.Font.size 36 ] (Element.text "Admin view")
        , button False PressedLogOut "Log out"
        , Element.Input.text
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

        mapping : FormMapData
        mapping =
            mappingData.getter model.formMapping
    in
    Element.column
        [ Element.spacing 24 ]
        [ Element.text mappingData.text
        , Element.row
            [ Element.spacing 8 ]
            (List.indexedMap
                (\index { groupName } ->
                    Element.row []
                        [ Element.el [ Element.Font.italic ] (Element.text ("(" ++ indexToHotkey index ++ ") "))
                        , Element.Input.text
                            [ Element.width (Element.px 100) ]
                            { text = groupName
                            , onChange =
                                \a ->
                                    mappingData.setter
                                        (List.updateAt index (\data -> { data | groupName = a }) mapping)
                                        model.formMapping
                                        |> TypedMapTo
                            , placeholder = Nothing
                            , label = Element.Input.labelHidden "mapTo"
                            }
                        ]
                )
                mapping
                ++ [ Element.row []
                        [ Element.el [ Element.Font.italic ] (Element.text "(new) ")
                        , Element.Input.text
                            [ Element.width (Element.px 100) ]
                            { text = ""
                            , onChange =
                                \a ->
                                    mappingData.setter
                                        (mapping ++ [ { groupName = a, otherAnswers = Set.empty } ])
                                        model.formMapping
                                        |> TypedMapTo
                            , placeholder = Nothing
                            , label = Element.Input.labelHidden "mapTo"
                            }
                        ]
                   ]
            )
        , submittedForms model
            |> List.map Form.formToOtherAnswers
            |> List.filterMap mappingData.getter
            |> List.indexedMap
                (\index other ->
                    Element.paragraph
                        [ if index == 0 then
                            Element.Font.bold

                          else
                            Element.Font.regular
                        , Element.spacing 2
                        ]
                        [ Element.text other ]
                )
            |> Element.column [ Element.spacing 16 ]
        ]


submittedForms : Model -> List Form
submittedForms model =
    List.filterMap
        (\{ form, submitTime } ->
            case submitTime of
                Just _ ->
                    Just form

                Nothing ->
                    Nothing
        )
        model.forms


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
        , infoRow "applicationDomains" (multichoiceToString Questions.whereDoYouUseElm form.applicationDomains)
        , infoRow "doYouUseElmAtWork" (maybeToString Questions.doYouUseElmAtWork form.doYouUseElmAtWork)
        , infoRow "howLargeIsTheCompany" (maybeToString Questions.howLargeIsTheCompany form.howLargeIsTheCompany)
        , infoRow "whatLanguageDoYouUseForBackend" (multichoiceToString Questions.whatLanguageDoYouUseForTheBackend form.whatLanguageDoYouUseForBackend)
        , infoRow "howLong" (maybeToString Questions.howLong form.howLong)
        , infoRow "elmVersion" (multichoiceToString Questions.whatElmVersion form.elmVersion)
        , infoRow "doYouUseElmFormat" (maybeToString Questions.doYouUseElmFormat form.doYouUseElmFormat)
        , infoRow "stylingTools" (multichoiceToString Questions.stylingTools form.stylingTools)
        , infoRow "buildTools" (multichoiceToString Questions.buildTools form.buildTools)
        , infoRow "frameworks" (multichoiceToString Questions.frameworks form.frameworks)
        , infoRow "editors" (multichoiceToString Questions.editor form.editors)
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
