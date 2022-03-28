module Frontend exposing (..)

import AssocSet as Set
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element exposing (Element)
import Element.Background
import Element.Font
import Element.Region
import Lamdera
import Questions exposing (DoYouUseElm(..), ExperienceLevel(..), HowFarAlong(..))
import Types exposing (..)
import Ui
import Url


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( FrontendModel, Cmd FrontendMsg )
init _ _ =
    ( FormLoading, Cmd.none )


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.load (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged _ ->
            ( model, Cmd.none )

        FormChanged form ->
            case model of
                FormLoaded formLoaded ->
                    ( FormLoaded { formLoaded | form = form }, Cmd.none )

                FormLoading ->
                    ( model, Cmd.none )

                FormCompleted ->
                    ( model, Cmd.none )

        PressedAcceptTosAnswer acceptedTos ->
            case model of
                FormLoaded formLoaded ->
                    ( FormLoaded { formLoaded | acceptedTos = acceptedTos }, Cmd.none )

                FormLoading ->
                    ( model, Cmd.none )

                FormCompleted ->
                    ( model, Cmd.none )

        PressedSubmitSurvey ->
            case model of
                FormLoaded formLoaded ->
                    if formLoaded.submitting then
                        ( model, Cmd.none )

                    else if formLoaded.acceptedTos then
                        ( FormLoaded { formLoaded | submitting = True }
                        , Lamdera.sendToBackend (SubmitForm formLoaded.form)
                        )

                    else
                        ( FormLoaded { formLoaded | pressedSubmitCount = formLoaded.pressedSubmitCount + 1 }
                        , Cmd.none
                        )

                FormLoading ->
                    ( model, Cmd.none )

                FormCompleted ->
                    ( model, Cmd.none )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
updateFromBackend msg _ =
    ( case msg of
        LoadForm formStatus ->
            case formStatus of
                NoFormFound ->
                    let
                        form : Form
                        form =
                            { doYouUseElm = Set.empty
                            , functionalProgrammingExperience = Nothing
                            , otherLanguages = Ui.multiChoiceWithOtherInit
                            , newsAndDiscussions = Ui.multiChoiceWithOtherInit
                            , elmResources = Ui.multiChoiceWithOtherInit
                            , userGroupNearYou = Nothing
                            , nearestCity = ""
                            , applicationDomains = Ui.multiChoiceWithOtherInit
                            , howLong = Nothing
                            , howFarAlongWork = Nothing
                            , howIsProjectLicensedWork = Nothing
                            , workAdoptionChallenge = ""
                            , howFarAlongHobby = Nothing
                            , howIsProjectLicensedHobby = Nothing
                            , hobbyAdoptionChallenge = ""
                            , elmVersion = Ui.multiChoiceWithOtherInit
                            , doYouUseElmFormat = Nothing
                            , stylingTools = Ui.multiChoiceWithOtherInit
                            , buildTools = Ui.multiChoiceWithOtherInit
                            , editors = Ui.multiChoiceWithOtherInit
                            , jsInteropUseCases = ""
                            , testTools = Ui.multiChoiceWithOtherInit
                            , testsWrittenFor = Ui.multiChoiceWithOtherInit
                            , elmInitialInterest = ""
                            , biggestPainPoint = ""
                            , whatDoYouLikeMost = ""
                            }
                    in
                    FormLoaded { form = form, acceptedTos = False, submitting = False, pressedSubmitCount = 0 }

                FormAutoSaved form ->
                    FormLoaded { form = form, acceptedTos = False, submitting = False, pressedSubmitCount = 0 }

                FormSubmitted ->
                    FormCompleted

        SubmitConfirmed ->
            FormCompleted
    , Cmd.none
    )


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title = "State of Elm 2022"
    , body =
        [ Element.layout
            [ Element.Region.mainContent ]
            (case model of
                FormLoaded formLoaded ->
                    Element.column
                        [ Element.spacing 24
                        , Element.width Element.fill
                        ]
                        [ Element.el
                            [ Element.Background.color Ui.blue0
                            , Element.width Element.fill
                            ]
                            (Element.column
                                [ Element.Font.color Ui.white
                                , Element.paddingXY 22 24
                                , Element.centerX
                                , Element.width (Element.maximum 800 Element.fill)
                                , Element.spacing 24
                                ]
                                [ Element.paragraph
                                    [ Element.Font.size 48
                                    , Element.Font.bold
                                    , Element.Font.center
                                    ]
                                    [ Element.text "State of Elm 2022" ]
                                , Element.paragraph
                                    [ Element.Font.size 22, Element.Font.bold ]
                                    [ Element.text "After a 4 year hiatus, State of Elm is back!" ]
                                , Element.paragraph
                                    []
                                    [ Element.text "This is a survey to better understand the Elm community." ]
                                , Element.paragraph
                                    []
                                    [ Element.text "Feel free to fill in as many or as few questions as you are comfortable with. Press submit at the bottom of the page when you are finished." ]
                                ]
                            )
                        , formView formLoaded.form
                        , Ui.acceptTosQuestion
                            formLoaded.acceptedTos
                            PressedAcceptTosAnswer
                            PressedSubmitSurvey
                            formLoaded.pressedSubmitCount
                        ]

                FormLoading ->
                    Element.none

                FormCompleted ->
                    Element.el
                        [ Element.Background.color Ui.blue0
                        , Element.width Element.fill
                        , Element.height Element.fill
                        ]
                        (Element.column
                            [ Element.centerX, Element.centerY ]
                            [ Element.paragraph [] [ Element.text "Your survey has been submitted!" ]
                            , Element.paragraph [] [ Element.text "Thanks for participating in the State of Elm 2022 survey. The results will be presented in a few weeks." ]
                            ]
                        )
            )
        ]
    }


formView : Form -> Element FrontendMsg
formView form =
    let
        doesNotUseElm : Bool
        doesNotUseElm =
            Set.member NoButImCuriousAboutIt form.doYouUseElm
                || Set.member NoAndIDontPlanTo form.doYouUseElm
    in
    Element.column
        [ Element.spacing 32
        , Element.padding 8
        , Element.width (Element.maximum 800 Element.fill)
        , Element.centerX
        ]
        [ Ui.multiChoiceQuestion
            "Do you use Elm?"
            Nothing
            Questions.allDoYouUseElm
            Questions.doYouUseElmToString
            form.doYouUseElm
            (\a ->
                FormChanged
                    { form
                        | doYouUseElm =
                            let
                                isYes =
                                    case Set.diff a form.doYouUseElm |> Set.toList |> List.head of
                                        Just YesAtWork ->
                                            Just True

                                        Just YesInSideProjects ->
                                            Just True

                                        Just YesAsAStudent ->
                                            Just True

                                        Just IUsedToButIDontAnymore ->
                                            Just True

                                        Just NoButImCuriousAboutIt ->
                                            Just False

                                        Just NoAndIDontPlanTo ->
                                            Just False

                                        Nothing ->
                                            Nothing
                            in
                            case isYes of
                                Just True ->
                                    Set.remove NoButImCuriousAboutIt a
                                        |> Set.remove NoAndIDontPlanTo

                                Just False ->
                                    Set.remove YesAtWork a
                                        |> Set.remove YesInSideProjects
                                        |> Set.remove YesAsAStudent
                                        |> Set.remove IUsedToButIDontAnymore

                                Nothing ->
                                    a
                    }
            )
        , Ui.slider
            "What is your level of experience with functional programming?"
            (Just "Where 0 is beginner and 10 is expert.")
            0
            10
            (Maybe.map Questions.experienceToInt form.functionalProgrammingExperience)
            (\a -> FormChanged { form | functionalProgrammingExperience = Questions.intToExperience a |> Just })
        , Ui.multiChoiceQuestionWithOther
            "What programming languages, other than Elm, are you most familiar with?"
            Nothing
            Questions.allOtherLanguages
            Questions.otherLanguagesToString
            form.otherLanguages
            (\a -> FormChanged { form | otherLanguages = a })
        , Ui.multiChoiceQuestionWithOther
            "Where do you go for Elm news and discussion?"
            Nothing
            Questions.allNewsAndDiscussions
            Questions.newsAndDiscussionsToString
            form.newsAndDiscussions
            (\a -> FormChanged { form | newsAndDiscussions = a })
        , if doesNotUseElm then
            Element.none

          else
            Ui.multiChoiceQuestionWithOther
                "What resources did you use to learn Elm?"
                Nothing
                Questions.allElmResources
                Questions.elmResourcesToString
                form.elmResources
                (\a -> FormChanged { form | elmResources = a })
        , Ui.singleChoiceQuestion
            "Is there an Elm user group near you?"
            Nothing
            Questions.allYesNo
            Questions.yesNoToString
            form.userGroupNearYou
            (\a -> FormChanged { form | userGroupNearYou = a })
        , Ui.textInput
            "What's the nearest city to you?"
            (Just "If you are already using Elm at work, please skip this question.")
            form.nearestCity
            (\a -> FormChanged { form | nearestCity = a })
        , Ui.multiChoiceQuestionWithOther
            "In which application domains, if any, have you used Elm?"
            (Just "We're asking both to get an idea of where Elm users are located and where might be good to encourage new user groups.")
            Questions.allApplicationDomains
            Questions.applicationDomainsToString
            form.applicationDomains
            (\a -> FormChanged { form | applicationDomains = a })
        , if doesNotUseElm then
            Element.none

          else
            Ui.singleChoiceQuestion
                "How long have you been using Elm?"
                Nothing
                Questions.allHowLong
                Questions.howLongToString
                form.howLong
                (\a -> FormChanged { form | howLong = a })
        , Ui.singleChoiceQuestion
            "How far along is your most mature Elm project at work?"
            Nothing
            Questions.allHowFarAlong
            Questions.howFarAlongToStringWork
            form.howFarAlongWork
            (\a -> FormChanged { form | howFarAlongWork = a })
        , if form.howFarAlongWork == Just IHaveNotStarted then
            Ui.textInput
                "What's the main challenge preventing your organization from adopting Elm?"
                Nothing
                form.workAdoptionChallenge
                (\a -> FormChanged { form | workAdoptionChallenge = a })

          else
            Ui.singleChoiceQuestion
                "How is that work project licensed?"
                (Just "Or, if it is not yet released, how will it be licensed?")
                Questions.allHowIsProjectLicensed
                Questions.howIsProjectLicensedToString
                form.howIsProjectLicensedWork
                (\a -> FormChanged { form | howIsProjectLicensedWork = a })
        , if doesNotUseElm then
            Element.none

          else
            Ui.singleChoiceQuestion
                "How far along is your most mature Elm side project?"
                (Just "Meaning anything done in your spare time. For example, an application or package.")
                Questions.allHowFarAlong
                Questions.howFarAlongToStringHobby
                form.howFarAlongHobby
                (\a -> FormChanged { form | howFarAlongHobby = a })
        , if doesNotUseElm then
            Element.none

          else if form.howFarAlongHobby == Just IHaveNotStarted then
            Ui.textInput
                "What is the biggest thing that prevents you from using Elm in your side projects?"
                Nothing
                form.hobbyAdoptionChallenge
                (\a -> FormChanged { form | hobbyAdoptionChallenge = a })

          else
            Ui.singleChoiceQuestion
                "How is that side project licensed?"
                (Just "Or, if it is not yet released, how will it be licensed?")
                Questions.allHowIsProjectLicensed
                Questions.howIsProjectLicensedToString
                form.howIsProjectLicensedHobby
                (\a -> FormChanged { form | howIsProjectLicensedHobby = a })
        , if doesNotUseElm then
            Element.none

          else
            Ui.multiChoiceQuestionWithOther
                "What versions of Elm are you using?"
                Nothing
                Questions.allWhatElmVersion
                Questions.whatElmVersionToString
                form.elmVersion
                (\a -> FormChanged { form | elmVersion = a })
        , if doesNotUseElm then
            Element.none

          else
            Ui.singleChoiceQuestion
                "Do you format your code with elm-format?"
                Nothing
                Questions.allDoYouUseElmFormat
                Questions.doYouUseElmFormatToString
                form.doYouUseElmFormat
                (\a -> FormChanged { form | doYouUseElmFormat = a })
        , if doesNotUseElm then
            Element.none

          else
            Ui.multiChoiceQuestionWithOther
                "What tools or libraries do you use to style your Elm applications?"
                Nothing
                Questions.allStylingTools
                Questions.stylingToolsToString
                form.stylingTools
                (\a -> FormChanged { form | stylingTools = a })
        , if doesNotUseElm then
            Element.none

          else
            Ui.multiChoiceQuestionWithOther
                "What tools do you use to build your Elm applications?"
                Nothing
                Questions.allBuildTools
                Questions.buildToolsToString
                form.buildTools
                (\a -> FormChanged { form | buildTools = a })
        , if doesNotUseElm then
            Element.none

          else
            Ui.multiChoiceQuestionWithOther
                "What editor(s) do you use to build your Elm applications?"
                Nothing
                Questions.allEditor
                Questions.editorToString
                form.editors
                (\a -> FormChanged { form | editors = a })
        , if doesNotUseElm then
            Element.none

          else
            Ui.textInput
                "If you've used JavaScript interop, what have you used it for?"
                Nothing
                form.jsInteropUseCases
                (\a -> FormChanged { form | jsInteropUseCases = a })
        , if doesNotUseElm then
            Element.none

          else
            Ui.multiChoiceQuestionWithOther
                "What tools do you use to test your Elm projects?"
                Nothing
                Questions.allTestTools
                Questions.testToolsToString
                form.testTools
                (\a -> FormChanged { form | testTools = a })
        , if doesNotUseElm then
            Element.none

          else
            Ui.multiChoiceQuestionWithOther
                "What do you write tests for in your Elm projects?"
                Nothing
                Questions.allTestsWrittenFor
                Questions.testsWrittenForToString
                form.testsWrittenFor
                (\a -> FormChanged { form | testsWrittenFor = a })
        , if doesNotUseElm then
            Element.none

          else
            Ui.textInput
                "What initially attracted you to Elm, or motivated you to try it?"
                Nothing
                form.elmInitialInterest
                (\a -> FormChanged { form | elmInitialInterest = a })
        , if doesNotUseElm then
            Element.none

          else
            Ui.textInput
                "What has been your biggest pain point in your use of Elm?"
                Nothing
                form.biggestPainPoint
                (\a -> FormChanged { form | biggestPainPoint = a })
        , if doesNotUseElm then
            Element.none

          else
            Ui.textInput
                "What do you like the most about your use of Elm?"
                Nothing
                form.whatDoYouLikeMost
                (\a -> FormChanged { form | whatDoYouLikeMost = a })
        ]
