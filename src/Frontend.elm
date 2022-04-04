module Frontend exposing (..)

import AssocSet as Set exposing (Set)
import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events
import Browser.Navigation as Nav
import Codecs
import Countries exposing (Country)
import Dict exposing (Dict)
import Duration exposing (Duration)
import Element exposing (Element)
import Element.Background
import Element.Font
import Element.Input
import Element.Region
import Env
import Lamdera
import List.Extra as List
import Process
import Quantity
import Questions exposing (DoYouUseElm(..), DoYouUseElmAtWork(..), DoYouUseElmReview(..), Question)
import Serialize
import SurveyResults
import Svg
import Svg.Attributes
import Task
import Time
import Types exposing (..)
import Ui exposing (Size)
import Url


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = \_ -> UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions =
            \_ ->
                Sub.batch
                    [ Browser.Events.onResize (\w h -> GotWindowSize { width = w, height = h })
                    , Time.every 1000 GotTime
                    ]
        , view = view
        }


init : Url.Url -> Nav.Key -> ( FrontendModel, Cmd FrontendMsg )
init url _ =
    ( if url.path == "/admin" then
        AdminLogin { password = "", loginFailed = False }

      else
        Loading Nothing Nothing
    , Cmd.batch
        [ Task.perform
            (\{ viewport } -> GotWindowSize { width = round viewport.width, height = round viewport.height })
            Browser.Dom.getViewport
        , Task.perform GotTime Time.now
        ]
    )


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

                Loading _ _ ->
                    ( model, Cmd.none )

                FormCompleted _ ->
                    ( model, Cmd.none )

                Admin _ ->
                    ( model, Cmd.none )

                AdminLogin _ ->
                    ( model, Cmd.none )

                SurveyResultsLoaded _ ->
                    ( model, Cmd.none )

        updateAdminLogin func =
            case model of
                FormLoaded _ ->
                    ( model, Cmd.none )

                Loading _ _ ->
                    ( model, Cmd.none )

                FormCompleted _ ->
                    ( model, Cmd.none )

                Admin _ ->
                    ( model, Cmd.none )

                AdminLogin adminLogin ->
                    let
                        ( newAdminLogin, cmd ) =
                            func adminLogin
                    in
                    ( AdminLogin newAdminLogin, cmd )

                SurveyResultsLoaded _ ->
                    ( model, Cmd.none )
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
                    SurveyResultsLoaded data
            , Cmd.none
            )

        TypedFormsData text ->
            if Env.isProduction then
                ( model, Cmd.none )

            else
                case model of
                    Admin admin ->
                        case Serialize.decodeFromString (Serialize.list Codecs.formCodec) text of
                            Ok forms ->
                                ( Admin
                                    { admin
                                        | forms =
                                            List.map
                                                (\form -> { form = form, submitTime = Just (Time.millisToPosix 0) })
                                                forms
                                    }
                                , ReplaceFormsRequest forms |> Lamdera.sendToBackend
                                )

                            Err _ ->
                                ( Admin admin, Cmd.none )

                    _ ->
                        ( model, Cmd.none )

        PressedLogOut ->
            ( model, Lamdera.sendToBackend LogOutRequest )

        GotTime time ->
            ( case model of
                Loading maybeSize _ ->
                    Loading maybeSize (Just time)

                FormLoaded formLoaded_ ->
                    FormLoaded { formLoaded_ | time = time }

                FormCompleted _ ->
                    FormCompleted time

                AdminLogin record ->
                    model

                Admin adminLoginData ->
                    model

                SurveyResultsLoaded data ->
                    model
            , Cmd.none
            )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
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

        LogOutResponse formStatus ->
            case model of
                Admin _ ->
                    loadForm formStatus Nothing Nothing

                _ ->
                    model
    , Cmd.none
    )


loadForm : LoadFormStatus -> Maybe Size -> Maybe Time.Posix -> FrontendModel
loadForm formStatus maybeWindowSize maybeTime =
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
                , windowSize = Maybe.withDefault { width = 1920, height = 1080 } maybeWindowSize
                , time = Maybe.withDefault (Time.millisToPosix 0) maybeTime
                }

        FormAutoSaved form ->
            FormLoaded
                { form = form
                , acceptedTos = False
                , submitting = False
                , pressedSubmitCount = 0
                , debounceCounter = 0
                , windowSize = Maybe.withDefault { width = 1920, height = 1080 } maybeWindowSize
                , time = Maybe.withDefault (Time.millisToPosix 0) maybeTime
                }

        FormSubmitted ->
            FormCompleted (Maybe.withDefault (Time.millisToPosix 0) maybeTime)

        SurveyResults data ->
            SurveyResultsLoaded data

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
                    case Env.surveyStatus of
                        SurveyOpen ->
                            if Env.surveyIsOpen formLoaded.time then
                                answerSurveyView formLoaded

                            else
                                awaitingResultsView

                        SurveyFinished ->
                            Element.none

                Loading _ maybeTime ->
                    case Env.surveyStatus of
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
                    case Env.surveyStatus of
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
                    Element.column
                        [ Element.spacing 32, Element.padding 16 ]
                        [ Element.el [ Element.Font.size 36 ] (Element.text "Admin view")
                        , Ui.button PressedLogOut "Log out"
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
                                    admin.forms
                                    |> Serialize.encodeToString (Serialize.list Codecs.formCodec)

                            --|> Json.Encode.encode 0
                            , placeholder = Nothing
                            , label = Element.Input.labelHidden ""
                            }
                        , Element.column
                            [ Element.spacing 32 ]
                            (List.map adminFormView admin.forms)
                        ]

                SurveyResultsLoaded data ->
                    SurveyResults.view data
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
        [ Element.el
            [ Element.Background.color Ui.blue0
            , Element.width Element.fill
            ]
            (Element.column
                [ Element.Font.color Ui.white
                , Ui.ifMobile formLoaded.windowSize (Element.paddingXY 22 24) (Element.paddingXY 34 36)
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
                , Element.paragraph
                    []
                    [ "Survey closes in " ++ timeLeft Env.surveyCloseTime formLoaded.time |> Element.text ]
                , Ui.disclaimer
                ]
            )
        , formView formLoaded.windowSize formLoaded.form
        , Ui.acceptTosQuestion
            formLoaded.windowSize
            formLoaded.acceptedTos
            PressedAcceptTosAnswer
            PressedSubmitSurvey
            formLoaded.pressedSubmitCount
        ]


timeLeft : Time.Posix -> Time.Posix -> String
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


adminFormView : { form : Form, submitTime : Maybe Time.Posix } -> Element msg
adminFormView { form, submitTime } =
    Element.column
        [ Element.spacing 8 ]
        [ case submitTime of
            Just time ->
                Element.text ("Submitted at " ++ String.fromInt (Time.posixToMillis time))

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


countries : List String
countries =
    let
        overrides : Dict String Country
        overrides =
            Dict.fromList
                [ ( "TW", { name = "Taiwan", code = "TW", flag = "🇹🇼" } ) ]
    in
    List.map
        (\country ->
            Dict.get country.code overrides
                |> Maybe.withDefault country
                |> (\{ name, flag } -> name ++ " " ++ flag)
        )
        Countries.all


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
            , Ui.searchableTextInput
                windowSize
                Questions.countryLivingInTitle
                Nothing
                countries
                form.countryLivingIn
                (\a -> FormChanged { form | countryLivingIn = a })
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
                    Questions.whereDoYouUseElm
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
                        Questions.whatLanguageDoYouUseForTheBackend
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
                    Questions.whatElmVersion
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
                    Questions.editor
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
