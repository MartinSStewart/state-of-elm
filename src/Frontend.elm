module Frontend exposing (..)

import AssocSet as Set
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element exposing (Element)
import Element.Background
import Element.Font
import Element.Region
import Lamdera
import Process
import Questions exposing (DoYouUseElm(..), ExperienceLevel(..), HowFarAlong(..))
import Svg
import Svg.Attributes
import Task
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
                    ( FormLoaded { formLoaded | form = form, debounceCounter = formLoaded.debounceCounter + 1 }
                    , Process.sleep 1000 |> Task.perform (\() -> Debounce (formLoaded.debounceCounter + 1))
                    )

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

        Debounce counter ->
            case model of
                FormLoaded formLoaded ->
                    ( model
                    , if counter == formLoaded.debounceCounter then
                        Lamdera.sendToBackend (AutoSaveForm formLoaded.form)

                      else
                        Cmd.none
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
                    FormLoaded
                        { form = form
                        , acceptedTos = False
                        , submitting = False
                        , pressedSubmitCount = 0
                        , debounceCounter = 0
                        }

                FormAutoSaved form ->
                    FormLoaded
                        { form = form
                        , acceptedTos = False
                        , submitting = False
                        , pressedSubmitCount = 0
                        , debounceCounter = 0
                        }

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
                        , Element.inFront
                            (Element.column
                                [ Element.alignBottom, Element.spacing 16, Element.paddingXY 22 24 ]
                                [ Element.link
                                    [ Element.Font.color Ui.white
                                    ]
                                    { url = "https://github.com/MartinSStewart/state-of-elm"
                                    , label =
                                        Element.row
                                            [ Element.Font.size 32
                                            , Element.spacing 8
                                            ]
                                            [ githubLogo
                                            , Element.el [ Element.moveDown 2 ] (Element.text "Source")
                                            ]
                                    }
                                , Element.el [] Ui.disclaimer
                                ]
                            )
                        ]
                        (Element.column
                            [ Element.centerX
                            , Element.centerY
                            , Element.Font.color Ui.white
                            , Element.spacing 24
                            , Element.paddingXY 22 24
                            , Element.width (Element.maximum 800 Element.fill)
                            ]
                            [ Element.paragraph
                                [ Element.Font.center
                                , Element.Font.size 36
                                , Element.Font.bold
                                ]
                                [ Element.text "Survey submitted!" ]
                            , Element.paragraph
                                [ Element.Font.center ]
                                [ Element.text "Thanks for participating in the State of Elm 2022 survey. The results will be presented in a few weeks on this website." ]
                            ]
                        )
            )
        ]
    }


githubLogo : Element msg
githubLogo =
    Svg.svg
        [ Svg.Attributes.width "32px"
        , Svg.Attributes.height "32px"
        , Svg.Attributes.viewBox "0 0 1024 1024"
        , Svg.Attributes.version "1.1"
        ]
        [ Svg.path
            [ Svg.Attributes.d "M511.957333 12.650667C229.248 12.650667 0 241.877333 0 524.672c0 226.197333 146.688 418.090667 350.165333 485.802667 25.6 4.693333 34.944-11.093333 34.944-24.682667 0-12.16-0.426667-44.352-0.682666-87.082667-142.421333 30.933333-172.48-68.629333-172.48-68.629333C188.672 770.944 155.093333 755.2 155.093333 755.2c-46.485333-31.786667 3.52-31.146667 3.52-31.146667 51.392 3.626667 78.421333 52.778667 78.421334 52.778667 45.674667 78.229333 119.829333 55.637333 149.013333 42.538667 4.650667-33.066667 17.877333-55.658667 32.512-68.437334-113.706667-12.928-233.216-56.853333-233.216-253.056 0-55.893333 19.946667-101.589333 52.693333-137.386666-5.269333-12.949333-22.826667-65.002667 5.013334-135.509334 0 0 42.986667-13.76 140.8 52.48 40.832-11.349333 84.629333-17.024 128.170666-17.216 43.477333 0.213333 87.296 5.866667 128.192 17.237334 97.749333-66.261333 140.650667-52.48 140.650667-52.48 27.946667 70.485333 10.368 122.538667 5.098667 135.466666 32.810667 35.818667 52.629333 81.514667 52.629333 137.408 0 196.693333-119.701333 239.978667-233.770667 252.650667 18.389333 15.786667 34.773333 47.061333 34.773334 94.805333 0 68.458667-0.64 123.669333-0.64 140.458667 0 13.696 9.216 29.632 35.2 24.618667C877.44 942.570667 1024 750.784 1024 524.672 1024 241.877333 794.730667 12.650667 511.957333 12.650667z"
            , Svg.Attributes.fill "currentColor"
            ]
            []
        ]
        |> Element.html
        |> Element.el []


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
        , Element.column
            []
            [ Ui.singleChoiceQuestion
                "How far along is your most mature Elm project at work?"
                Nothing
                Questions.allHowFarAlong
                Questions.howFarAlongToStringWork
                form.howFarAlongWork
                (\a -> FormChanged { form | howFarAlongWork = a })
            , case form.howFarAlongWork of
                Just IHaveNotStarted ->
                    Ui.textInput
                        "What's the main challenge preventing your organization from adopting Elm?"
                        Nothing
                        form.workAdoptionChallenge
                        (\a -> FormChanged { form | workAdoptionChallenge = a })

                Just PlanningLearningExplorationPhase ->
                    workProjectLicenseQuestion form

                Just InDevelopment ->
                    workProjectLicenseQuestion form

                Just InStaging ->
                    workProjectLicenseQuestion form

                Just Shipped ->
                    workProjectLicenseQuestion form

                Nothing ->
                    Element.none
            ]
        , if doesNotUseElm then
            Element.none

          else
            Element.column
                []
                [ Ui.singleChoiceQuestion
                    "How far along is your most mature Elm side project?"
                    (Just "Meaning anything done in your spare time. For example, an application or package.")
                    Questions.allHowFarAlong
                    Questions.howFarAlongToStringHobby
                    form.howFarAlongHobby
                    (\a -> FormChanged { form | howFarAlongHobby = a })
                , case form.howFarAlongHobby of
                    Just IHaveNotStarted ->
                        Ui.textInput
                            "What is the biggest thing that prevents you from using Elm in your side projects?"
                            Nothing
                            form.hobbyAdoptionChallenge
                            (\a -> FormChanged { form | hobbyAdoptionChallenge = a })

                    Just PlanningLearningExplorationPhase ->
                        hobbyProjectLicenseQuestion form

                    Just InDevelopment ->
                        hobbyProjectLicenseQuestion form

                    Just InStaging ->
                        hobbyProjectLicenseQuestion form

                    Just Shipped ->
                        hobbyProjectLicenseQuestion form

                    Nothing ->
                        Element.none
                ]
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


workProjectLicenseQuestion form =
    Ui.singleChoiceQuestion
        "How is that work project licensed?"
        (Just "Or, if it is not yet released, how will it be licensed?")
        Questions.allHowIsProjectLicensed
        Questions.howIsProjectLicensedToString
        form.howIsProjectLicensedWork
        (\a -> FormChanged { form | howIsProjectLicensedWork = a })


hobbyProjectLicenseQuestion form =
    Ui.singleChoiceQuestion
        "How is that side project licensed?"
        (Just "Or, if it is not yet released, how will it be licensed?")
        Questions.allHowIsProjectLicensed
        Questions.howIsProjectLicensedToString
        form.howIsProjectLicensedHobby
        (\a -> FormChanged { form | howIsProjectLicensedHobby = a })
