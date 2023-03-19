module Frontend exposing (..)

import AdminPage
import AssocSet as Set
import Browser
import Duration exposing (Duration)
import Effect.Browser.Dom
import Effect.Browser.Events
import Effect.Browser.Navigation
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera
import Effect.Process
import Effect.Subscription as Subscription
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
import Questions exposing (DoYouUseElm(..), DoYouUseElmAtWork(..), DoYouUseElmReview(..))
import Route exposing (Route(..), SurveyYear(..))
import SurveyResults2022 exposing (Mode(..), Segment(..))
import Types exposing (..)
import Ui exposing (Size)
import Url


app =
    Effect.Lamdera.frontend
        Lamdera.sendToBackend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = view
        }


subscriptions _ =
    Subscription.batch
        [ Effect.Browser.Events.onResize (\w h -> GotWindowSize { width = w, height = h })
        , Effect.Time.every Duration.second GotTime
        ]


init : Url.Url -> Effect.Browser.Navigation.Key -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
init url key =
    let
        route =
            Route.decode url
    in
    ( Loading { windowSize = Nothing, time = Nothing, route = route, navKey = key, responseData = Nothing }
    , Command.batch
        [ Effect.Task.perform
            (\{ viewport } -> GotWindowSize { width = round viewport.width, height = round viewport.height })
            Effect.Browser.Dom.getViewport
        , Effect.Task.perform GotTime Effect.Time.now
        , Effect.Lamdera.sendToBackend
            (case route of
                SurveyRoute Year2023 ->
                    RequestFormData2023

                SurveyRoute Year2022 ->
                    RequestFormData2022

                AdminRoute ->
                    RequestAdminFormData
            )
        ]
    )


tryLoading : LoadingData -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
tryLoading loading =
    Maybe.map3
        (\windowSize time responseData ->
            ( Loaded
                { page =
                    case responseData of
                        LoadAdmin adminData ->
                            AdminLogin { password = "", loginFailed = False }

                        LoadForm loadFormStatus ->
                            loadForm loadFormStatus

                        PreviewResponse data ->
                            Debug.todo ""
                , time = time
                , navKey = loading.navKey
                , route = loading.route
                , windowSize = windowSize
                }
            , Command.none
            )
        )
        loading.windowSize
        loading.time
        loading.responseData
        |> Maybe.withDefault ( Loading loading, Command.none )


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
update msg model =
    case model of
        Loading loading ->
            case msg of
                GotWindowSize windowSize ->
                    tryLoading { loading | windowSize = Just windowSize }

                GotTime time ->
                    tryLoading { loading | time = Just time }

                _ ->
                    ( model, Command.none )

        Loaded loaded ->
            updateLoaded msg loaded |> Tuple.mapFirst Loaded


updateLoaded : FrontendMsg -> LoadedData -> ( LoadedData, Command FrontendOnly ToBackend FrontendMsg )
updateLoaded msg model =
    let
        updateFormLoaded func =
            case model.page of
                FormLoaded formLoaded ->
                    let
                        ( newFormLoaded, cmd ) =
                            func formLoaded
                    in
                    ( { model | page = FormLoaded newFormLoaded }, cmd )

                FormCompleted ->
                    ( model, Command.none )

                Admin _ ->
                    ( model, Command.none )

                AdminLogin _ ->
                    ( model, Command.none )

                SurveyResultsLoaded _ ->
                    ( model, Command.none )

        updateAdminLogin func =
            case model.page of
                FormLoaded _ ->
                    ( model, Command.none )

                FormCompleted ->
                    ( model, Command.none )

                Admin _ ->
                    ( model, Command.none )

                AdminLogin adminLogin ->
                    let
                        ( newAdminLogin, cmd ) =
                            func adminLogin
                    in
                    ( { model | page = AdminLogin newAdminLogin }, cmd )

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

        UrlChanged url ->
            let
                route =
                    Route.decode url
            in
            ( model, Effect.Browser.Navigation.replaceUrl model.navKey (Route.encode route) )

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
            ( { model | windowSize = windowSize }, Command.none )

        GotTime time ->
            ( { model | time = time }, Command.none )

        AdminPageMsg adminMsg ->
            case model.page of
                Admin admin ->
                    let
                        ( newAdmin, cmd ) =
                            AdminPage.update adminMsg admin
                    in
                    ( { model | page = Admin newAdmin }, Command.map AdminToBackend AdminPageMsg cmd )

                _ ->
                    ( model, Command.none )

        SurveyResultsMsg surveyResultsMsg ->
            case model.page of
                SurveyResultsLoaded surveyResultsModel ->
                    ( { model
                        | page =
                            SurveyResults2022.update surveyResultsMsg surveyResultsModel |> SurveyResultsLoaded
                      }
                    , Command.none
                    )

                _ ->
                    ( model, Command.none )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
updateFromBackend msg model =
    case model of
        Loading loading ->
            case msg of
                ResponseData responseData ->
                    tryLoading { loading | responseData = Just responseData }

                _ ->
                    ( model, Command.none )

        Loaded loaded ->
            updateFromBackendLoaded msg loaded |> Tuple.mapFirst Loaded


updateFromBackendLoaded : ToFrontend -> LoadedData -> ( LoadedData, Command FrontendOnly ToBackend FrontendMsg )
updateFromBackendLoaded msg model =
    ( case msg of
        ResponseData responseData ->
            case responseData of
                LoadForm loadFormStatus ->
                    --case model.page of
                    --    Loading loadingData ->
                    --        loadForm False formStatus loadingData
                    --
                    --    _ ->
                    --        model
                    Debug.todo ""

                LoadAdmin adminLoginData ->
                    --{ model | page = AdminPage.init adminData |> Admin }
                    Debug.todo ""

                PreviewResponse data ->
                    --case model.page of
                    --    FormLoaded formLoaded ->
                    --        loadForm
                    --            True
                    --            (SurveyResults data)
                    --            { windowSize = Just formLoaded.windowSize
                    --            , time = Just formLoaded.time
                    --            , surveyYear = Route.currentSurvey
                    --            }
                    --
                    --    Loading loadingData ->
                    --        loadForm True (SurveyResults data) loadingData
                    --
                    --    _ ->
                    --        model
                    Debug.todo ""

        SubmitConfirmed ->
            --case model.page of
            --    FormLoaded formLoaded ->
            --        FormCompleted formLoaded.time
            --
            --    _ ->
            --        model
            Debug.todo ""

        AdminLoginResponse result ->
            --case model.page of
            --    AdminLogin adminLogin ->
            --        case result of
            --            Ok adminLoginData ->
            --                AdminPage.init adminLoginData |> Admin
            --
            --            Err () ->
            --                AdminLogin { adminLogin | loginFailed = True }
            --
            --    _ ->
            --        model
            Debug.todo ""

        LogOutResponse formStatus ->
            --case model.page of
            --    Admin _ ->
            --        loadForm
            --            False
            --            formStatus
            --            { windowSize = Nothing, time = Nothing, surveyYear = Route.currentSurvey }
            --
            --    _ ->
            --        model
            Debug.todo ""

        AdminToFrontend toFrontend ->
            case model.page of
                Admin adminModel ->
                    { model | page = AdminPage.updateFromBackend toFrontend adminModel |> Admin }

                _ ->
                    model
    , Command.none
    )


loadForm : LoadFormStatus -> Page
loadForm formStatus =
    case formStatus of
        NoFormFound ->
            FormLoaded
                { form = Form.emptyForm
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

        SurveyResults data ->
            SurveyResultsLoaded
                { data = data, mode = Percentage, segment = AllUsers }

        AwaitingResultsData ->
            Debug.todo ""


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title = "State of Elm " ++ Route.yearToString Route.currentSurvey
    , body =
        [ Element.layout
            [ Element.Region.mainContent ]
            (case model of
                Loading _ ->
                    Element.text "Loading..."

                Loaded loaded ->
                    loadedView loaded
            )
        ]
    }


loadedView : LoadedData -> Element FrontendMsg
loadedView model =
    case model.page of
        FormLoaded formLoaded ->
            case Types.surveyStatus of
                SurveyOpen ->
                    if Env.surveyIsOpen model.time then
                        answerSurveyView model formLoaded

                    else
                        awaitingResultsView

                SurveyFinished ->
                    Element.none

        FormCompleted ->
            case Types.surveyStatus of
                SurveyOpen ->
                    if Env.surveyIsOpen model.time then
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
            SurveyResults2022.view model surveyResultsLoaded |> Element.map SurveyResultsMsg


formCompletedView : Element msg
formCompletedView =
    Element.el
        [ Element.Background.color Ui.blue0
        , Element.width Element.fill
        , Element.height Element.fill
        , Element.inFront
            (Element.column
                [ Element.alignBottom, Element.spacing 16, Element.paddingXY 22 24 ]
                [ Ui.sourceCodeLink
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
                [ "Thanks for participating in the State of Elm "
                    ++ Route.yearToString Route.currentSurvey
                    ++ " survey. The results will be presented in a few weeks on this website."
                    |> Element.text
                ]
            ]
        )


answerSurveyView : LoadedData -> FormLoaded_ -> Element FrontendMsg
answerSurveyView model formLoaded =
    Element.column
        [ Element.spacing 24
        , Element.width Element.fill
        ]
        [ Ui.headerContainer
            model.windowSize
            Route.currentSurvey
            [ Element.paragraph
                []
                [ Element.text "This is a survey to better understand the Elm community." ]
            , Element.paragraph
                []
                [ Element.text "Feel free to fill in as many or as few questions as you are comfortable with. Press submit at the bottom of the page when you are finished." ]
            , Element.paragraph
                [ Ui.titleFontSize, Element.Font.bold ]
                [ "Survey closes in " ++ timeLeft Env.surveyCloseTime model.time |> Element.text ]
            ]
        , formView model.windowSize formLoaded.form
        , Ui.acceptTosQuestion
            model.windowSize
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
                            [ Element.Font.size 24
                            , Element.spacing 8
                            ]
                            [ Ui.githubLogo
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


formView : Size -> Form -> Element FrontendMsg
formView windowSize form =
    Element.column
        [ Element.spacing 64
        , Element.padding 8
        , Element.width (Element.maximum 800 Element.fill)
        , Element.centerX
        ]
        [ Ui.section windowSize
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
            , if Form.doesNotUseElm form then
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
        , if Form.doesNotUseElm form then
            Element.none

          else
            Ui.section windowSize
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
        , if Form.doesNotUseElm form then
            Element.none

          else
            Ui.section windowSize
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
                    Questions.frameworks2023
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
                , Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions.testTools
                    Nothing
                    form.testTools
                    (\a -> FormChanged { form | testTools = a })
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
