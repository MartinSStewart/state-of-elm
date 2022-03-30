module Frontend exposing (..)

import AssocSet as Set
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Countries
import Element exposing (Element)
import Element.Background
import Element.Font
import Element.Input
import Element.Region
import Lamdera
import Process
import Questions exposing (DoYouUseElm(..), DoYouUseElmAtWork(..), DoYouUseElmReview(..))
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
        , onUrlChange = \_ -> UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \_ -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( FrontendModel, Cmd FrontendMsg )
init url _ =
    if url.path == "/admin" then
        ( AdminLogin { password = "", loginFailed = False }, Cmd.none )

    else
        ( Loading, Cmd.none )


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
update msg model =
    let
        updateFormLoaded : (FormLoaded_ -> ( FormLoaded_, Cmd FrontendMsg )) -> ( FrontendModel, Cmd FrontendMsg )
        updateFormLoaded func =
            case model of
                FormLoaded formLoaded ->
                    let
                        ( newFormLoaded, cmd ) =
                            func formLoaded
                    in
                    ( FormLoaded newFormLoaded, cmd )

                Loading ->
                    ( model, Cmd.none )

                FormCompleted ->
                    ( model, Cmd.none )

                Admin _ ->
                    ( model, Cmd.none )

                AdminLogin _ ->
                    ( model, Cmd.none )

        updateAdminLogin func =
            case model of
                FormLoaded _ ->
                    ( model, Cmd.none )

                Loading ->
                    ( model, Cmd.none )

                FormCompleted ->
                    ( model, Cmd.none )

                Admin _ ->
                    ( model, Cmd.none )

                AdminLogin adminLogin ->
                    let
                        ( newAdminLogin, cmd ) =
                            func adminLogin
                    in
                    ( AdminLogin newAdminLogin, cmd )
    in
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

        UrlChanged ->
            ( model, Cmd.none )

        FormChanged form ->
            updateFormLoaded
                (\formLoaded ->
                    ( { formLoaded | form = form, debounceCounter = formLoaded.debounceCounter + 1 }
                    , Process.sleep 1000 |> Task.perform (\() -> Debounce (formLoaded.debounceCounter + 1))
                    )
                )

        PressedAcceptTosAnswer acceptedTos ->
            updateFormLoaded (\formLoaded -> ( { formLoaded | acceptedTos = acceptedTos }, Cmd.none ))

        PressedSubmitSurvey ->
            updateFormLoaded
                (\formLoaded ->
                    if formLoaded.submitting then
                        ( formLoaded, Cmd.none )

                    else if formLoaded.acceptedTos then
                        ( { formLoaded | submitting = True }
                        , Lamdera.sendToBackend (SubmitForm formLoaded.form)
                        )

                    else
                        ( { formLoaded | pressedSubmitCount = formLoaded.pressedSubmitCount + 1 }
                        , Cmd.none
                        )
                )

        Debounce counter ->
            updateFormLoaded
                (\formLoaded ->
                    ( formLoaded
                    , if counter == formLoaded.debounceCounter then
                        Lamdera.sendToBackend (AutoSaveForm formLoaded.form)

                      else
                        Cmd.none
                    )
                )

        TypedPassword password ->
            updateAdminLogin (\adminLogin -> ( { adminLogin | password = password }, Cmd.none ))

        PressedLogin ->
            updateAdminLogin
                (\adminLogin -> ( adminLogin, Lamdera.sendToBackend (AdminLoginRequest adminLogin.password) ))


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
updateFromBackend msg model =
    ( case msg of
        LoadForm formStatus ->
            case model of
                Loading ->
                    case formStatus of
                        NoFormFound ->
                            let
                                form : Form
                                form =
                                    { doYouUseElm = Set.empty
                                    , age = Nothing
                                    , functionalProgrammingExperience = Nothing
                                    , otherLanguages = Ui.multiChoiceWithOtherInit
                                    , newsAndDiscussions = Ui.multiChoiceWithOtherInit
                                    , elmResources = Ui.multiChoiceWithOtherInit
                                    , countryLivingIn = ""
                                    , applicationDomains = Ui.multiChoiceWithOtherInit
                                    , doYouUseElmAtWork = Nothing
                                    , howLargeIsTheCompany = Nothing
                                    , whatLanguageDoYouUseForBackend = Ui.multiChoiceWithOtherInit
                                    , howLong = Nothing
                                    , elmVersion = Ui.multiChoiceWithOtherInit
                                    , doYouUseElmFormat = Nothing
                                    , stylingTools = Ui.multiChoiceWithOtherInit
                                    , buildTools = Ui.multiChoiceWithOtherInit
                                    , frameworks = Ui.multiChoiceWithOtherInit
                                    , editors = Ui.multiChoiceWithOtherInit
                                    , doYouUseElmReview = Nothing
                                    , whichElmReviewRulesDoYouUse = Ui.multiChoiceWithOtherInit
                                    , testTools = Ui.multiChoiceWithOtherInit
                                    , testsWrittenFor = Ui.multiChoiceWithOtherInit
                                    , elmInitialInterest = ""
                                    , biggestPainPoint = ""
                                    , whatDoYouLikeMost = ""
                                    , emailAddress = ""
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

                _ ->
                    model

        SubmitConfirmed ->
            FormCompleted

        LoadAdmin adminData ->
            Admin adminData

        AdminLoginResponse result ->
            case model of
                AdminLogin adminLogin ->
                    case result of
                        Ok adminLoginData ->
                            Admin adminLoginData

                        Err () ->
                            AdminLogin { adminLogin | loginFailed = True }

                _ ->
                    model
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
                                    [ Ui.titleFontSize, Element.Font.bold ]
                                    [ Element.text "After a 4 year hiatus, State of Elm is back!" ]
                                , Element.paragraph
                                    []
                                    [ Element.text "This is a survey to better understand the Elm community." ]
                                , Element.paragraph
                                    []
                                    [ Element.text "Feel free to fill in as many or as few questions as you are comfortable with. Press submit at the bottom of the page when you are finished." ]
                                , Ui.disclaimer
                                ]
                            )
                        , formView formLoaded.form
                        , Ui.acceptTosQuestion
                            formLoaded.acceptedTos
                            PressedAcceptTosAnswer
                            PressedSubmitSurvey
                            formLoaded.pressedSubmitCount
                        ]

                Loading ->
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

                AdminLogin { password, loginFailed } ->
                    Element.column
                        [ Element.centerX, Element.centerY, Element.spacing 16 ]
                        [ Element.Input.currentPassword
                            []
                            { onChange = TypedPassword
                            , text = password
                            , placeholder = Nothing
                            , show = False
                            , label =
                                Element.Input.labelAbove []
                                    (if loginFailed then
                                        Element.el
                                            [ Element.Font.color <| Element.rgb 0.8 0 0 ]
                                            (Element.text "Incorrect password")

                                     else
                                        Element.text "Enter password"
                                    )
                            }
                        , Element.Input.button
                            []
                            { onPress = Just PressedLogin
                            , label = Element.text "Login"
                            }
                        ]

                Admin admin ->
                    Element.column
                        []
                        [ Element.text "Admin view"
                        , Element.text ("autoSavedSurveyCount: " ++ String.fromInt admin.autoSavedSurveyCount)
                        , Element.text ("submittedSurveyCount: " ++ String.fromInt admin.submittedSurveyCount)
                        ]
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


section : String -> List (Element msg) -> Element msg
section text content =
    Element.column
        [ Element.spacing 24 ]
        [ Element.paragraph
            [ Element.Region.heading 2
            , Element.Font.size 24
            , Element.Font.bold
            , Element.Font.color Ui.blue0
            ]
            [ Element.text text ]
        , Element.column [ Element.spacing 32 ] content
        ]


countries : List String
countries =
    List.map (\country -> country.name ++ " " ++ country.flag) Countries.all


formView : Form -> Element FrontendMsg
formView form =
    let
        doesNotUseElm : Bool
        doesNotUseElm =
            Set.member NoButImCuriousAboutIt form.doYouUseElm
                || Set.member NoAndIDontPlanTo form.doYouUseElm
    in
    Element.column
        [ Element.spacing 64
        , Element.padding 8
        , Element.width (Element.maximum 800 Element.fill)
        , Element.centerX
        ]
        [ section "About you"
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
            , Ui.singleChoiceQuestion
                "How old are you?"
                Nothing
                Questions.allAge
                Questions.ageToString
                form.age
                (\a -> FormChanged { form | age = a })
            , Ui.singleChoiceQuestion
                "What is your level of experience with functional programming?"
                Nothing
                Questions.allExperienceLevel
                Questions.experienceLevelToString
                form.functionalProgrammingExperience
                (\a -> FormChanged { form | functionalProgrammingExperience = a })
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
            , Ui.searchableTextInput
                "Which country do you live in?"
                Nothing
                countries
                form.countryLivingIn
                (\a -> FormChanged { form | countryLivingIn = a })
            , Ui.emailAddressInput
                form.emailAddress
                (\a -> FormChanged { form | emailAddress = a })
            ]
        , if doesNotUseElm then
            Element.none

          else
            section "Where do you use Elm?"
                [ Ui.multiChoiceQuestionWithOther
                    "In which application domains, if any, have you used Elm?"
                    (Just "We're not counting \"web development\" as a domain here. Instead think of what would you would use web development for.")
                    Questions.allApplicationDomains
                    Questions.applicationDomainsToString
                    form.applicationDomains
                    (\a -> FormChanged { form | applicationDomains = a })
                , Ui.singleChoiceQuestion
                    "Do you use Elm at work?"
                    (Just "Either for a consumer product or an internal tool")
                    Questions.allDoYouUseElmAtWork
                    Questions.doYouUseElmAtWorkToString
                    form.doYouUseElmAtWork
                    (\a -> FormChanged { form | doYouUseElmAtWork = a })
                , if form.doYouUseElmAtWork == Just NotEmployed then
                    Element.none

                  else
                    Ui.singleChoiceQuestion
                        "How large is the company you work at?"
                        Nothing
                        Questions.allHowLargeIsTheCompany
                        Questions.howLargeIsTheCompanyToString
                        form.howLargeIsTheCompany
                        (\a -> FormChanged { form | howLargeIsTheCompany = a })
                , if form.doYouUseElmAtWork == Just NotEmployed then
                    Element.none

                  else
                    Ui.multiChoiceQuestionWithOther
                        "What languages does your company use on the backend?"
                        Nothing
                        Questions.allWhatLanguageDoYouUseForTheBackend
                        Questions.whatLanguageDoYouUseForTheBackendToString
                        form.whatLanguageDoYouUseForBackend
                        (\a -> FormChanged { form | whatLanguageDoYouUseForBackend = a })
                , Ui.singleChoiceQuestion
                    "How long have you been using Elm?"
                    Nothing
                    Questions.allHowLong
                    Questions.howLongToString
                    form.howLong
                    (\a -> FormChanged { form | howLong = a })
                , Ui.multiChoiceQuestionWithOther
                    "What versions of Elm are you using?"
                    Nothing
                    Questions.allWhatElmVersion
                    Questions.whatElmVersionToString
                    form.elmVersion
                    (\a -> FormChanged { form | elmVersion = a })
                ]
        , if doesNotUseElm then
            Element.none

          else
            section "How do you use Elm?"
                [ Ui.singleChoiceQuestion
                    "Do you format your code with elm-format?"
                    Nothing
                    Questions.allDoYouUseElmFormat
                    Questions.doYouUseElmFormatToString
                    form.doYouUseElmFormat
                    (\a -> FormChanged { form | doYouUseElmFormat = a })
                , Ui.multiChoiceQuestionWithOther
                    "What tools or libraries do you use to style your Elm applications?"
                    Nothing
                    Questions.allStylingTools
                    Questions.stylingToolsToString
                    form.stylingTools
                    (\a -> FormChanged { form | stylingTools = a })
                , Ui.multiChoiceQuestionWithOther
                    "What tools do you use to build your Elm applications?"
                    Nothing
                    Questions.allBuildTools
                    Questions.buildToolsToString
                    form.buildTools
                    (\a -> FormChanged { form | buildTools = a })
                , Ui.multiChoiceQuestionWithOther
                    "What frameworks do you use?"
                    Nothing
                    Questions.allFrameworks
                    Questions.frameworkToString
                    form.frameworks
                    (\a -> FormChanged { form | frameworks = a })
                , Ui.multiChoiceQuestionWithOther
                    "What editor(s) do you use to write your Elm applications?"
                    Nothing
                    Questions.allEditor
                    Questions.editorToString
                    form.editors
                    (\a -> FormChanged { form | editors = a })
                , Ui.singleChoiceQuestion
                    "Do you use elm-review?"
                    Nothing
                    Questions.allDoYouUseElmReview
                    Questions.doYouUseElmReview
                    form.doYouUseElmReview
                    (\a -> FormChanged { form | doYouUseElmReview = a })
                , if
                    (form.doYouUseElmReview == Just NeverHeardOfElmReview)
                        || (form.doYouUseElmReview == Just HeardOfItButNeverTriedElmReview)
                  then
                    Element.none

                  else
                    Ui.multiChoiceQuestionWithOther
                        "Which elm-review rules do you use?"
                        (Just "If you have custom unpublished rules, select \"Other\" and describe what they do")
                        Questions.allWhichElmReviewRulesDoYouUse
                        Questions.whichElmReviewRulesDoYouUse
                        form.whichElmReviewRulesDoYouUse
                        (\a -> FormChanged { form | whichElmReviewRulesDoYouUse = a })
                , Ui.multiChoiceQuestionWithOther
                    "What tools do you use to test your Elm projects?"
                    Nothing
                    Questions.allTestTools
                    Questions.testToolsToString
                    form.testTools
                    (\a -> FormChanged { form | testTools = a })
                , Ui.multiChoiceQuestionWithOther
                    "What do you write tests for in your Elm projects?"
                    Nothing
                    Questions.allTestsWrittenFor
                    Questions.testsWrittenForToString
                    form.testsWrittenFor
                    (\a -> FormChanged { form | testsWrittenFor = a })
                , Ui.textInput
                    "What initially attracted you to Elm, or motivated you to try it?"
                    Nothing
                    form.elmInitialInterest
                    (\a -> FormChanged { form | elmInitialInterest = a })
                , Ui.textInput
                    "What has been your biggest pain point in your use of Elm?"
                    Nothing
                    form.biggestPainPoint
                    (\a -> FormChanged { form | biggestPainPoint = a })
                , Ui.textInput
                    "What do you like the most about your use of Elm?"
                    Nothing
                    form.whatDoYouLikeMost
                    (\a -> FormChanged { form | whatDoYouLikeMost = a })
                ]
        ]
