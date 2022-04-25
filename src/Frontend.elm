module Frontend exposing (..)

import AdminPage
import AssocSet as Set exposing (Set)
import Browser
import Duration exposing (Duration)
import Effect.Browser.Dom
import Effect.Browser.Events
import Effect.Browser.Navigation
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera
import Effect.Process
import Effect.Subscription as Subscription exposing (Subscription)
import Effect.Task
import Effect.Time
import Element exposing (Element)
import Element.Background
import Element.Font
import Element.Input
import Element.Region
import Env
import Form exposing (Form)
import Lamdera
import List.Extra as List
import Quantity
import Questions exposing (DoYouUseElm(..), DoYouUseElmAtWork(..), DoYouUseElmReview(..), Question)
import SurveyResults
import Svg
import Svg.Attributes
import Types exposing (..)
import Ui exposing (Size)
import Url


app =
    Effect.Lamdera.frontend
        Lamdera.sendToBackend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = \_ -> UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions =
            \_ ->
                Subscription.batch
                    [ Effect.Browser.Events.onResize (\w h -> GotWindowSize { width = w, height = h })
                    , Effect.Time.every Duration.second GotTime
                    ]
        , view = view
        }


init : Url.Url -> Effect.Browser.Navigation.Key -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
init url _ =
    ( if url.path == "/admin" then
        AdminLogin { password = "", loginFailed = False }

      else
        Loading Nothing Nothing
    , Command.batch
        [ Effect.Task.perform
            (\{ viewport } -> GotWindowSize { width = round viewport.width, height = round viewport.height })
            Effect.Browser.Dom.getViewport
        , Effect.Task.perform GotTime Effect.Time.now
        ]
    )


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
update msg model =
    let
        updateFormLoaded : (FormLoaded_ -> ( FormLoaded_, Command FrontendOnly ToBackend FrontendMsg )) -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
        updateFormLoaded func =
            case model of
                FormLoaded formLoaded ->
                    let
                        ( newFormLoaded, cmd ) =
                            func formLoaded
                    in
                    ( FormLoaded newFormLoaded, cmd )

                Loading _ _ ->
                    ( model, Command.none )

                FormCompleted _ ->
                    ( model, Command.none )

                Admin _ ->
                    ( model, Command.none )

                AdminLogin _ ->
                    ( model, Command.none )

                SurveyResultsLoaded _ ->
                    ( model, Command.none )

        updateAdminLogin func =
            case model of
                FormLoaded _ ->
                    ( model, Command.none )

                Loading _ _ ->
                    ( model, Command.none )

                FormCompleted _ ->
                    ( model, Command.none )

                Admin _ ->
                    ( model, Command.none )

                AdminLogin adminLogin ->
                    let
                        ( newAdminLogin, cmd ) =
                            func adminLogin
                    in
                    ( AdminLogin newAdminLogin, cmd )

                SurveyResultsLoaded _ ->
                    ( model, Command.none )
    in
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Effect.Browser.Navigation.load (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Effect.Browser.Navigation.load url
                    )

        UrlChanged ->
            ( model, Command.none )

        FormChanged form ->
            updateFormLoaded
                (\formLoaded ->
                    ( { formLoaded | form = form, debounceCounter = formLoaded.debounceCounter + 1 }
                    , Effect.Process.sleep Duration.second
                        |> Effect.Task.perform (\() -> Debounce (formLoaded.debounceCounter + 1))
                    )
                )

        PressedAcceptTosAnswer acceptedTos ->
            updateFormLoaded (\formLoaded -> ( { formLoaded | acceptedTos = acceptedTos }, Command.none ))

        PressedSubmitSurvey ->
            updateFormLoaded
                (\formLoaded ->
                    if formLoaded.submitting then
                        ( formLoaded, Command.none )

                    else if formLoaded.acceptedTos then
                        ( { formLoaded | submitting = True }
                        , Effect.Lamdera.sendToBackend (SubmitForm formLoaded.form)
                        )

                    else
                        ( { formLoaded | pressedSubmitCount = formLoaded.pressedSubmitCount + 1 }
                        , Command.none
                        )
                )

        Debounce counter ->
            updateFormLoaded
                (\formLoaded ->
                    ( formLoaded
                    , if counter == formLoaded.debounceCounter then
                        Effect.Lamdera.sendToBackend (AutoSaveForm formLoaded.form)

                      else
                        Command.none
                    )
                )

        TypedPassword password ->
            updateAdminLogin (\adminLogin -> ( { adminLogin | password = password }, Command.none ))

        PressedLogin ->
            updateAdminLogin
                (\adminLogin -> ( adminLogin, Effect.Lamdera.sendToBackend (AdminLoginRequest adminLogin.password) ))

        GotWindowSize windowSize ->
            ( case model of
                Loading _ maybeTime ->
                    Loading (Just windowSize) maybeTime

                FormLoaded formLoaded_ ->
                    FormLoaded { formLoaded_ | windowSize = windowSize }

                FormCompleted time ->
                    FormCompleted time

                AdminLogin record ->
                    AdminLogin record

                Admin adminLoginData ->
                    Admin adminLoginData

                SurveyResultsLoaded data ->
                    SurveyResultsLoaded { data | windowSize = windowSize }
            , Command.none
            )

        GotTime time ->
            ( case model of
                Loading maybeSize _ ->
                    Loading maybeSize (Just time)

                FormLoaded formLoaded_ ->
                    FormLoaded { formLoaded_ | time = time }

                FormCompleted _ ->
                    FormCompleted time

                AdminLogin _ ->
                    model

                Admin _ ->
                    model

                SurveyResultsLoaded _ ->
                    model
            , Command.none
            )

        AdminPageMsg adminMsg ->
            case model of
                Admin admin ->
                    let
                        ( newAdmin, cmd ) =
                            AdminPage.update adminMsg admin
                    in
                    ( Admin newAdmin, Command.map AdminToBackend AdminPageMsg cmd )

                _ ->
                    ( model, Command.none )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
updateFromBackend msg model =
    ( case msg of
        LoadForm formStatus ->
            case model of
                Loading maybeWindowSize maybeTime ->
                    loadForm formStatus maybeWindowSize maybeTime

                _ ->
                    model

        SubmitConfirmed ->
            case model of
                FormLoaded formLoaded ->
                    FormCompleted formLoaded.time

                _ ->
                    model

        LoadAdmin adminData ->
            AdminPage.init adminData |> Admin

        AdminLoginResponse result ->
            case model of
                AdminLogin adminLogin ->
                    case result of
                        Ok adminLoginData ->
                            AdminPage.init adminLoginData |> Admin

                        Err () ->
                            AdminLogin { adminLogin | loginFailed = True }

                _ ->
                    model

        LogOutResponse formStatus ->
            case model of
                Admin _ ->
                    loadForm formStatus Nothing Nothing

                _ ->
                    model
    , Command.none
    )


loadForm : LoadFormStatus -> Maybe Size -> Maybe Effect.Time.Posix -> FrontendModel
loadForm formStatus maybeWindowSize maybeTime =
    let
        windowSize =
            Maybe.withDefault { width = 1920, height = 1080 } maybeWindowSize
    in
    case formStatus of
        NoFormFound ->
            FormLoaded
                { form = Form.emptyForm
                , acceptedTos = False
                , submitting = False
                , pressedSubmitCount = 0
                , debounceCounter = 0
                , windowSize = windowSize
                , time = Maybe.withDefault (Effect.Time.millisToPosix 0) maybeTime
                }

        FormAutoSaved form ->
            FormLoaded
                { form = form
                , acceptedTos = False
                , submitting = False
                , pressedSubmitCount = 0
                , debounceCounter = 0
                , windowSize = windowSize
                , time = Maybe.withDefault (Effect.Time.millisToPosix 0) maybeTime
                }

        FormSubmitted ->
            FormCompleted (Maybe.withDefault (Effect.Time.millisToPosix 0) maybeTime)

        SurveyResults data ->
            SurveyResultsLoaded { windowSize = windowSize, data = data }

        AwaitingResultsData ->
            Loading maybeWindowSize maybeTime


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title = "State of Elm 2022"
    , body =
        [ Element.layout
            [ Element.Region.mainContent ]
            (case model of
                FormLoaded formLoaded ->
                    case Types.surveyStatus of
                        SurveyOpen ->
                            if Env.surveyIsOpen formLoaded.time then
                                answerSurveyView formLoaded

                            else
                                awaitingResultsView

                        SurveyFinished ->
                            Element.none

                Loading _ maybeTime ->
                    case Types.surveyStatus of
                        SurveyOpen ->
                            case maybeTime of
                                Just time ->
                                    if Env.surveyIsOpen time then
                                        Element.none

                                    else
                                        awaitingResultsView

                                Nothing ->
                                    Element.none

                        SurveyFinished ->
                            Element.none

                FormCompleted time ->
                    case Types.surveyStatus of
                        SurveyOpen ->
                            if Env.surveyIsOpen time then
                                formCompletedView

                            else
                                awaitingResultsView

                        SurveyFinished ->
                            Element.none

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
                        , Ui.button PressedLogin "Login"
                        ]

                Admin admin ->
                    AdminPage.adminView admin |> Element.map AdminPageMsg

                SurveyResultsLoaded surveyResultsLoaded ->
                    SurveyResults.view surveyResultsLoaded
            )
        ]
    }


formCompletedView : Element msg
formCompletedView =
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


answerSurveyView : FormLoaded_ -> Element FrontendMsg
answerSurveyView formLoaded =
    Element.column
        [ Element.spacing 24
        , Element.width Element.fill
        ]
        [ Ui.headerContainer
            formLoaded.windowSize
            [ Element.paragraph
                [ Ui.titleFontSize, Element.Font.bold ]
                [ Element.text "After a 4 year hiatus, State of Elm is back!" ]
            , Element.paragraph
                []
                [ Element.text "This is a survey to better understand the Elm community." ]
            , Element.paragraph
                []
                [ Element.text "Feel free to fill in as many or as few questions as you are comfortable with. Press submit at the bottom of the page when you are finished." ]
            , Element.paragraph
                [ Ui.titleFontSize, Element.Font.bold ]
                [ "Survey closes in " ++ timeLeft Env.surveyCloseTime formLoaded.time |> Element.text ]
            ]
        , formView formLoaded.windowSize formLoaded.form
        , Ui.acceptTosQuestion
            formLoaded.windowSize
            formLoaded.acceptedTos
            PressedAcceptTosAnswer
            PressedSubmitSurvey
            formLoaded.pressedSubmitCount
        ]


timeLeft : Effect.Time.Posix -> Effect.Time.Posix -> String
timeLeft closingTime time =
    let
        difference : Duration
        difference =
            Duration.from closingTime time |> Quantity.abs

        years =
            Duration.inDays difference / 365.242 |> floor

        yearsRemainder =
            difference |> Quantity.minus (Duration.days (toFloat years * 365.242))

        months =
            Duration.inDays yearsRemainder / 30 |> floor

        monthRemainder =
            yearsRemainder |> Quantity.minus (Duration.days (toFloat months * 30))

        days =
            Duration.inDays monthRemainder |> floor

        dayRemainder =
            monthRemainder |> Quantity.minus (Duration.days (toFloat days))

        hours =
            Duration.inHours dayRemainder |> floor

        hourRemainder =
            dayRemainder |> Quantity.minus (Duration.hours (toFloat hours))

        minutes =
            Duration.inMinutes hourRemainder |> floor

        minutesRemainder =
            hourRemainder |> Quantity.minus (Duration.minutes (toFloat minutes))

        seconds =
            Duration.inSeconds minutesRemainder |> round

        pluralize : Int -> String -> { isZero : Bool, text : String }
        pluralize value text =
            if value == 1 then
                { isZero = False, text = "1 " ++ text }

            else
                { isZero = value == 0, text = String.fromInt value ++ " " ++ text ++ "s" }

        a =
            [ pluralize years "year"
            , pluralize months "month"
            , pluralize days "day"
            , pluralize hours "hour"
            , pluralize minutes "minute"
            , pluralize seconds "second"
            ]
                |> List.dropWhile .isZero
                |> List.map .text
                |> String.join ", "
    in
    a


awaitingResultsView : Element msg
awaitingResultsView =
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
                [ Element.text "Survey closed" ]
            , Element.paragraph
                [ Element.Font.center ]
                [ Element.text "The survey is now closed and the results are being tallied. They should be released on this website in a few days." ]
            ]
        )


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


section : Size -> String -> List (Element msg) -> Element msg
section windowSize text content =
    Element.column
        [ Element.spacing 24 ]
        [ Element.paragraph
            [ Element.Region.heading 2
            , Element.Font.size 24
            , Element.Font.bold
            , Element.Font.color Ui.blue0
            ]
            [ Element.text text ]
        , Element.column
            [ Element.spacing (Ui.ifMobile windowSize 36 48) ]
            content
        ]


formView : Size -> Form -> Element FrontendMsg
formView windowSize form =
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
        [ section windowSize
            "About you"
            [ Ui.multiChoiceQuestion
                windowSize
                Questions.doYouUseElm
                Nothing
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
                windowSize
                Questions.age
                Nothing
                form.age
                (\a -> FormChanged { form | age = a })
            , Ui.singleChoiceQuestion
                windowSize
                Questions.experienceLevel
                Nothing
                form.functionalProgrammingExperience
                (\a -> FormChanged { form | functionalProgrammingExperience = a })
            , Ui.multiChoiceQuestionWithOther
                windowSize
                Questions.otherLanguages
                Nothing
                form.otherLanguages
                (\a -> FormChanged { form | otherLanguages = a })
            , Ui.multiChoiceQuestionWithOther
                windowSize
                Questions.newsAndDiscussions
                Nothing
                form.newsAndDiscussions
                (\a -> FormChanged { form | newsAndDiscussions = a })
            , if doesNotUseElm then
                Element.none

              else
                Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions.elmResources
                    Nothing
                    form.elmResources
                    (\a -> FormChanged { form | elmResources = a })
            , Ui.textInput
                windowSize
                Questions.initialInterestTitle
                Nothing
                form.elmInitialInterest
                (\a -> FormChanged { form | elmInitialInterest = a })

            -- TODO: Restore this
            --, Ui.searchableTextInput
            --    windowSize
            --    Questions.countryLivingInTitle
            --    Nothing
            --    countries
            --    form.countryLivingIn
            --    (\a -> FormChanged { form | countryLivingIn = a })
            , Ui.emailAddressInput
                windowSize
                form.emailAddress
                (\a -> FormChanged { form | emailAddress = a })
            ]
        , if doesNotUseElm then
            Element.none

          else
            section windowSize
                "Where do you use Elm?"
                [ Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions.applicationDomains
                    (Just "We're not counting \"web development\" as a domain here. Instead think of what would you would use web development for.")
                    form.applicationDomains
                    (\a -> FormChanged { form | applicationDomains = a })
                , Ui.singleChoiceQuestion
                    windowSize
                    Questions.doYouUseElmAtWork
                    (Just "Either for a consumer product or an internal tool")
                    form.doYouUseElmAtWork
                    (\a -> FormChanged { form | doYouUseElmAtWork = a })
                , if form.doYouUseElmAtWork == Just NotEmployed then
                    Element.none

                  else
                    Ui.singleChoiceQuestion
                        windowSize
                        Questions.howLargeIsTheCompany
                        Nothing
                        form.howLargeIsTheCompany
                        (\a -> FormChanged { form | howLargeIsTheCompany = a })
                , if form.doYouUseElmAtWork == Just NotEmployed then
                    Element.none

                  else
                    Ui.multiChoiceQuestionWithOther
                        windowSize
                        Questions.whatLanguageDoYouUseForBackend
                        Nothing
                        form.whatLanguageDoYouUseForBackend
                        (\a -> FormChanged { form | whatLanguageDoYouUseForBackend = a })
                , Ui.singleChoiceQuestion
                    windowSize
                    Questions.howLong
                    Nothing
                    form.howLong
                    (\a -> FormChanged { form | howLong = a })
                , Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions.elmVersion
                    Nothing
                    form.elmVersion
                    (\a -> FormChanged { form | elmVersion = a })
                ]
        , if doesNotUseElm then
            Element.none

          else
            section windowSize
                "How do you use Elm?"
                [ Ui.singleChoiceQuestion
                    windowSize
                    Questions.doYouUseElmFormat
                    Nothing
                    form.doYouUseElmFormat
                    (\a -> FormChanged { form | doYouUseElmFormat = a })
                , Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions.stylingTools
                    Nothing
                    form.stylingTools
                    (\a -> FormChanged { form | stylingTools = a })
                , Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions.buildTools
                    Nothing
                    form.buildTools
                    (\a -> FormChanged { form | buildTools = a })
                , Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions.frameworks
                    Nothing
                    form.frameworks
                    (\a -> FormChanged { form | frameworks = a })
                , Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions.editors
                    Nothing
                    form.editors
                    (\a -> FormChanged { form | editors = a })
                , Ui.singleChoiceQuestion
                    windowSize
                    Questions.doYouUseElmReview
                    Nothing
                    form.doYouUseElmReview
                    (\a -> FormChanged { form | doYouUseElmReview = a })
                , if
                    (form.doYouUseElmReview == Just NeverHeardOfElmReview)
                        || (form.doYouUseElmReview == Just HeardOfItButNeverTriedElmReview)
                  then
                    Element.none

                  else
                    Ui.multiChoiceQuestionWithOther
                        windowSize
                        Questions.whichElmReviewRulesDoYouUse
                        (Just "If you have custom unpublished rules, select \"Other\" and describe what they do")
                        form.whichElmReviewRulesDoYouUse
                        (\a -> FormChanged { form | whichElmReviewRulesDoYouUse = a })
                , Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions.testTools
                    Nothing
                    form.testTools
                    (\a -> FormChanged { form | testTools = a })
                , Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions.testsWrittenFor
                    Nothing
                    form.testsWrittenFor
                    (\a -> FormChanged { form | testsWrittenFor = a })
                , Ui.textInput
                    windowSize
                    Questions.biggestPainPointTitle
                    Nothing
                    form.biggestPainPoint
                    (\a -> FormChanged { form | biggestPainPoint = a })
                , Ui.textInput
                    windowSize
                    Questions.whatDoYouLikeMostTitle
                    Nothing
                    form.whatDoYouLikeMost
                    (\a -> FormChanged { form | whatDoYouLikeMost = a })
                ]
        ]
