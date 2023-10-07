module Frontend exposing (..)

import AdminPage
import AssocSet as Set
import Browser
import Dict
import Duration exposing (Duration)
import Effect.Browser.Dom as Dom
import Effect.Browser.Events
import Effect.Browser.Navigation
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.File
import Effect.File.Select
import Effect.Lamdera
import Effect.Process
import Effect.Subscription as Subscription
import Effect.Task as Task
import Effect.Time
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Element.Region
import Env
import Form2023 exposing (Form2023)
import Json.Decode
import Lamdera
import List.Extra as List
import PackageName exposing (PackageName)
import Quantity
import Questions2023
import Route exposing (Route(..), SurveyYear(..))
import SurveyResults2022
import SurveyResults2023
import Types exposing (..)
import Ui exposing (Size)
import Url


app :
    { init : Url.Url -> Lamdera.Key -> ( FrontendModel, Cmd FrontendMsg )
    , view : FrontendModel -> Browser.Document FrontendMsg
    , update : FrontendMsg -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
    , updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
    , subscriptions : FrontendModel -> Sub FrontendMsg
    , onUrlRequest : Browser.UrlRequest -> FrontendMsg
    , onUrlChange : Url.Url -> FrontendMsg
    }
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


subscriptions : a -> Subscription.Subscription FrontendOnly FrontendMsg
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

        url2 =
            Route.encode route
    in
    ( Loading { windowSize = Nothing, time = Nothing, route = route, navKey = key, responseData = Nothing }
    , Command.batch
        [ Effect.Browser.Navigation.replaceUrl key url2
        , Task.perform
            (\{ viewport } -> GotWindowSize { width = round viewport.width, height = round viewport.height })
            Dom.getViewport
        , Task.perform GotTime Effect.Time.now
        , Effect.Lamdera.sendToBackend
            (case route of
                SurveyRoute Year2023 ->
                    RequestFormData2023

                SurveyRoute Year2022 ->
                    RequestFormData2023

                AdminRoute ->
                    RequestAdminFormData

                UnsubscribeRoute id ->
                    UnsubscribeRequest id
            )
        ]
    )


tryLoading : LoadingData -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
tryLoading loading =
    Maybe.map3
        (\windowSize time ( responseData, surveyResults2022 ) ->
            ( Loaded
                { page =
                    case responseData of
                        LoadAdmin maybeAdminData ->
                            case maybeAdminData of
                                Just adminData ->
                                    AdminPage.init adminData |> AdminPage

                                Nothing ->
                                    AdminLogin { password = "", loginFailed = False }

                        LoadForm2023 loadFormStatus ->
                            loadForm loading.route loadFormStatus

                        UnsubscribeResponse ->
                            UnsubscribePage
                , time = time
                , navKey = loading.navKey
                , route = loading.route
                , windowSize = windowSize
                , surveyResults2022 = surveyResults2022
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

                _ ->
                    ( model, Command.none )

        updateAdminLogin func =
            case model.page of
                AdminLogin adminLogin ->
                    let
                        ( newAdminLogin, cmd ) =
                            func adminLogin
                    in
                    ( { model | page = AdminLogin newAdminLogin }, cmd )

                _ ->
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

        UrlChanged _ ->
            ( model, Command.none )

        FormChanged form ->
            updateFormLoaded
                (\formLoaded ->
                    ( { formLoaded | form = form, debounceCounter = formLoaded.debounceCounter + 1 }
                    , Effect.Process.sleep Duration.second
                        |> Task.perform (\() -> Debounce (formLoaded.debounceCounter + 1))
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
                AdminPage admin ->
                    let
                        ( newAdmin, cmd ) =
                            AdminPage.update adminMsg admin
                    in
                    ( { model | page = AdminPage newAdmin }, Command.map AdminToBackend AdminPageMsg cmd )

                _ ->
                    ( model, Command.none )

        SurveyResults2022Msg surveyResultsMsg ->
            case model.page of
                SurveyResults2022Page surveyResultsModel ->
                    ( { model
                        | page =
                            SurveyResults2022.update surveyResultsMsg surveyResultsModel |> SurveyResults2022Page
                      }
                    , Command.none
                    )

                _ ->
                    ( model, Command.none )

        SurveyResults2023Msg surveyResultsMsg ->
            case model.page of
                SurveyResults2023Page surveyResultsModel ->
                    ( { model
                        | page =
                            SurveyResults2023.update surveyResultsMsg surveyResultsModel |> SurveyResults2023Page
                      }
                    , Command.none
                    )

                _ ->
                    ( model, Command.none )

        PressedSelectElmJsonFiles ->
            ( model, Effect.File.Select.files [ "application/json" ] SelectedElmJsonFiles )

        TypedElmJsonFile elmJsonText ->
            if String.length elmJsonText < 4 then
                updateFormLoaded
                    (\form -> ( { form | elmJsonError = Just "Copy paste your whole elm.json into the text field" }, Command.none ))

            else
                updateFormLoaded (addElmJson [ elmJsonText ])

        SelectedElmJsonFiles file files ->
            ( model
            , List.map Effect.File.toString (file :: files) |> Task.sequence |> Task.perform GotElmJsonFilesContent
            )

        GotElmJsonFilesContent fileContents ->
            updateFormLoaded (addElmJson fileContents)

        PressedRemoveElmJson index ->
            updateFormLoaded
                (\formLoaded ->
                    let
                        form : Form2023
                        form =
                            formLoaded.form
                    in
                    ( { formLoaded | form = { form | elmJson = List.removeAt index form.elmJson } }
                    , Command.none
                    )
                )


getJsonError : Json.Decode.Error -> String
getJsonError error =
    case error of
        Json.Decode.Field _ error2 ->
            getJsonError error2

        Json.Decode.Index _ error2 ->
            getJsonError error2

        Json.Decode.OneOf errors ->
            case List.head errors of
                Just error2 ->
                    getJsonError error2

                Nothing ->
                    "Failed to decode"

        Json.Decode.Failure string _ ->
            if String.startsWith "This is not valid JSON!" string then
                "Invalid JSON"

            else if String.startsWith "Expecting" string then
                "Not a valid elm.json file"

            else
                string


addElmJson : List String -> Form2023Loaded_ -> ( Form2023Loaded_, Command FrontendOnly ToBackend FrontendMsg )
addElmJson elmJsons model =
    let
        results : List (Result Json.Decode.Error (List PackageName))
        results =
            List.map (Json.Decode.decodeString parseElmJson) elmJsons

        oks : List (List PackageName)
        oks =
            List.filterMap Result.toMaybe results

        errs : List String
        errs =
            List.filterMap
                (\result ->
                    case result of
                        Ok _ ->
                            Nothing

                        Err error ->
                            getJsonError error |> Just
                )
                results

        form =
            model.form
    in
    ( { model
        | form =
            { form
                | elmJson =
                    form.elmJson
                        ++ (if List.isEmpty errs then
                                oks

                            else
                                []
                           )
            }
        , elmJsonError = List.head errs
        , debounceCounter = model.debounceCounter + 1
      }
    , Effect.Process.sleep Duration.second
        |> Task.perform (\() -> Debounce (model.debounceCounter + 1))
    )


parseElmJson : Json.Decode.Decoder (List PackageName)
parseElmJson =
    Json.Decode.map2
        Tuple.pair
        (Json.Decode.field "type" Json.Decode.string)
        (Json.Decode.field "elm-version" Json.Decode.string)
        |> Json.Decode.andThen
            (\( type_, elmVersion ) ->
                if type_ == "application" then
                    if String.startsWith "0.19." elmVersion || elmVersion == "0.19" then
                        Json.Decode.at [ "dependencies", "direct" ] (Json.Decode.dict Json.Decode.string)
                            |> Json.Decode.andThen
                                (\dict ->
                                    let
                                        packageNames =
                                            Dict.toList dict |> List.map PackageName.fromTuple

                                        okPackageNames =
                                            List.filterMap identity packageNames
                                    in
                                    if List.length packageNames == List.length okPackageNames then
                                        Json.Decode.succeed okPackageNames

                                    else
                                        Json.Decode.fail "Failed to parse some direct dependencies"
                                )

                    else
                        Json.Decode.fail "Only upload elm.json files for 0.19 or 0.19.1 applications please!"

                else
                    Json.Decode.fail "Only upload elm.json files for applications, not packages"
            )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
updateFromBackend msg model =
    case model of
        Loading loading ->
            case msg of
                ResponseData responseData surveyResults2022 ->
                    tryLoading { loading | responseData = Just ( responseData, surveyResults2022 ) }

                _ ->
                    ( model, Command.none )

        Loaded loaded ->
            updateFromBackendLoaded msg loaded |> Tuple.mapFirst Loaded


updateFromBackendLoaded : ToFrontend -> LoadedData -> ( LoadedData, Command FrontendOnly ToBackend FrontendMsg )
updateFromBackendLoaded msg model =
    ( case msg of
        ResponseData _ _ ->
            -- We shouldn't get response data after we've loaded
            model

        SubmitConfirmed ->
            case model.page of
                FormLoaded _ ->
                    { model | page = FormCompleted }

                _ ->
                    model

        AdminLoginResponse result ->
            case model.page of
                AdminLogin adminLogin ->
                    { model
                        | page =
                            case result of
                                Ok adminLoginData ->
                                    AdminPage.init adminLoginData |> AdminPage

                                Err () ->
                                    AdminLogin { adminLogin | loginFailed = True }
                    }

                _ ->
                    model

        LogOutResponse formStatus ->
            case model.page of
                AdminPage _ ->
                    { model | page = loadForm model.route formStatus }

                _ ->
                    model

        AdminToFrontend toFrontend ->
            case model.page of
                AdminPage adminModel ->
                    { model | page = AdminPage.updateFromBackend toFrontend adminModel |> AdminPage }

                _ ->
                    model
    , Command.none
    )


loadForm : Route -> LoadFormStatus2023 -> Page
loadForm route formStatus =
    case route of
        SurveyRoute Year2022 ->
            SurveyResults2022Page
                { mode = SurveyResults2022.Percentage
                , segment = SurveyResults2022.AllUsers
                }

        _ ->
            case formStatus of
                NoFormFound ->
                    FormLoaded
                        { form = Form2023.emptyForm
                        , acceptedTos = False
                        , submitting = False
                        , pressedSubmitCount = 0
                        , debounceCounter = 0
                        , elmJsonTextInput = ""
                        , elmJsonError = Nothing
                        }

                FormAutoSaved form ->
                    FormLoaded
                        { form = form
                        , acceptedTos = False
                        , submitting = False
                        , pressedSubmitCount = 0
                        , debounceCounter = 0
                        , elmJsonTextInput = ""
                        , elmJsonError = Nothing
                        }

                FormSubmitted ->
                    FormCompleted

                SurveyResults2023 data ->
                    SurveyResults2023Page
                        { data = data
                        , mode = SurveyResults2023.Percentage
                        , segment = SurveyResults2023.AllUsers
                        }

                AwaitingResultsData ->
                    FormCompleted


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title =
        "State of Elm "
            ++ (if Env.isProduction then
                    ""

                else
                    "(dev) "
               )
            ++ Route.yearToString Route.currentSurvey
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
            case Types.surveyStatus model.time of
                SurveyOpen ->
                    if Env.surveyIsOpen model.time then
                        answerSurveyView model formLoaded

                    else
                        awaitingResultsView

                SurveyFinished ->
                    Element.none

        FormCompleted ->
            case Types.surveyStatus model.time of
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
                    [ Element.htmlAttribute (Dom.idToAttribute passwordInputId) ]
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
                , Ui.button loginButtonId PressedLogin "Login"
                ]

        AdminPage admin ->
            AdminPage.adminView admin |> Element.map AdminPageMsg

        SurveyResults2022Page surveyResultsLoaded ->
            SurveyResults2022.view model model.surveyResults2022 surveyResultsLoaded
                |> Element.map SurveyResults2022Msg

        UnsubscribePage ->
            Element.el
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.Background.color Ui.blue0
                , Element.padding 24
                ]
                (Element.paragraph
                    [ Element.centerY
                    , Element.Font.center
                    , Element.Font.size 36
                    , Element.Font.color Ui.white
                    ]
                    [ Element.text "Unsubscribe successful!" ]
                )

        SurveyResults2023Page surveyResultsLoaded ->
            SurveyResults2023.view model model.surveyResults2022 surveyResultsLoaded
                |> Element.map SurveyResults2023Msg

        ErrorPage ->
            Element.paragraph [] [ Element.text "Something went wrong. Try reloading the page I guess?" ]


passwordInputId : Dom.HtmlId
passwordInputId =
    Dom.id "passwordInput"


loginButtonId : Dom.HtmlId
loginButtonId =
    Dom.id "loginButtonId"


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


answerSurveyView : LoadedData -> Form2023Loaded_ -> Element FrontendMsg
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
        , formView model.windowSize formLoaded
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


formView : Size -> Form2023Loaded_ -> Element FrontendMsg
formView windowSize model =
    let
        form =
            model.form
    in
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
                Questions2023.doYouUseElm
                Nothing
                form.doYouUseElm
                (\a ->
                    FormChanged
                        { form
                            | doYouUseElm =
                                let
                                    isYes =
                                        case Set.diff a form.doYouUseElm |> Set.toList |> List.head of
                                            Just Questions2023.YesAtWork ->
                                                Just True

                                            Just Questions2023.YesInSideProjects ->
                                                Just True

                                            Just Questions2023.YesAsAStudent ->
                                                Just True

                                            Just Questions2023.IUsedToButIDontAnymore ->
                                                Just True

                                            Just Questions2023.NoButImCuriousAboutIt ->
                                                Just False

                                            Just Questions2023.NoAndIDontPlanTo ->
                                                Just False

                                            Nothing ->
                                                Nothing
                                in
                                case isYes of
                                    Just True ->
                                        Set.remove Questions2023.NoButImCuriousAboutIt a
                                            |> Set.remove Questions2023.NoAndIDontPlanTo

                                    Just False ->
                                        Set.remove Questions2023.YesAtWork a
                                            |> Set.remove Questions2023.YesInSideProjects
                                            |> Set.remove Questions2023.YesAsAStudent
                                            |> Set.remove Questions2023.IUsedToButIDontAnymore

                                    Nothing ->
                                        a
                        }
                )
            , Ui.singleChoiceQuestion
                windowSize
                Questions2023.age
                Nothing
                form.age
                (\a -> FormChanged { form | age = a })
            , Ui.singleChoiceQuestion
                windowSize
                Questions2023.pleaseSelectYourGender
                Nothing
                form.pleaseSelectYourGender
                (\a -> FormChanged { form | pleaseSelectYourGender = a })
            , Ui.singleChoiceQuestion
                windowSize
                Questions2023.experienceLevel
                Nothing
                form.functionalProgrammingExperience
                (\a -> FormChanged { form | functionalProgrammingExperience = a })
            , Ui.multiChoiceQuestionWithOther
                windowSize
                Questions2023.otherLanguages
                Nothing
                form.otherLanguages
                (\a -> FormChanged { form | otherLanguages = a })
            , Ui.multiChoiceQuestionWithOther
                windowSize
                Questions2023.newsAndDiscussions
                Nothing
                form.newsAndDiscussions
                (\a -> FormChanged { form | newsAndDiscussions = a })
            , if Form2023.doesNotUseElm form then
                Element.none

              else
                Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions2023.elmResources
                    Nothing
                    form.elmResources
                    (\a -> FormChanged { form | elmResources = a })
            , Ui.textInput
                windowSize
                Questions2023.initialInterestTitle
                Nothing
                form.elmInitialInterest
                (\a -> FormChanged { form | elmInitialInterest = a })
            , Ui.select
                windowSize
                (\a -> FormChanged { form | countryLivingIn = Just a })
                form.countryLivingIn
                Questions2023.countryLivingIn
            , Ui.emailAddressInput
                windowSize
                form.emailAddress
                (\a -> FormChanged { form | emailAddress = a })
            ]
        , if Form2023.doesNotUseElm form then
            Element.none

          else
            Ui.section windowSize
                "Where do you use Elm?"
                [ Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions2023.applicationDomains
                    (Just "We're not counting \"web development\" as a domain here. Instead think of what you would use web development for.")
                    form.applicationDomains
                    (\a -> FormChanged { form | applicationDomains = a })
                , Ui.singleChoiceQuestion
                    windowSize
                    Questions2023.doYouUseElmAtWork
                    (Just "Either for a consumer product or an internal tool")
                    form.doYouUseElmAtWork
                    (\a -> FormChanged { form | doYouUseElmAtWork = a })
                , if form.doYouUseElmAtWork == Just Questions2023.WouldLikeToUseElmAtWork then
                    Ui.textInput
                        windowSize
                        Questions2023.whatPreventsYouFromUsingElmAtWorkTitle
                        Nothing
                        form.whatPreventsYouFromUsingElmAtWork
                        (\a -> FormChanged { form | whatPreventsYouFromUsingElmAtWork = a })

                  else
                    Element.none
                , if
                    (form.doYouUseElmAtWork == Just Questions2023.HaveTriedElmInAWorkProject)
                        || (form.doYouUseElmAtWork == Just Questions2023.IUseElmAtWork)
                  then
                    Ui.textInput
                        windowSize
                        (if form.doYouUseElmAtWork == Just Questions2023.HaveTriedElmInAWorkProject then
                            Questions2023.howDidItGoUsingElmAtWorkTitle

                         else
                            Questions2023.howIsItGoingUsingElmAtWorkTitle
                        )
                        Nothing
                        form.howDidItGoUsingElmAtWork
                        (\a -> FormChanged { form | howDidItGoUsingElmAtWork = a })

                  else
                    Element.none
                , if form.doYouUseElmAtWork == Just Questions2023.NotEmployed then
                    Element.none

                  else
                    Ui.singleChoiceQuestion
                        windowSize
                        Questions2023.howLargeIsTheCompany
                        Nothing
                        form.howLargeIsTheCompany
                        (\a -> FormChanged { form | howLargeIsTheCompany = a })
                , if form.doYouUseElmAtWork == Just Questions2023.NotEmployed then
                    Element.none

                  else
                    Ui.multiChoiceQuestionWithOther
                        windowSize
                        Questions2023.whatLanguageDoYouUseForBackend
                        Nothing
                        form.whatLanguageDoYouUseForBackend
                        (\a -> FormChanged { form | whatLanguageDoYouUseForBackend = a })
                , Ui.singleChoiceQuestion
                    windowSize
                    Questions2023.howLong
                    Nothing
                    form.howLong
                    (\a -> FormChanged { form | howLong = a })
                , Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions2023.elmVersion
                    Nothing
                    form.elmVersion
                    (\a -> FormChanged { form | elmVersion = a })
                ]
        , if Form2023.doesNotUseElm form then
            Element.none

          else
            Ui.section windowSize
                "How do you use Elm?"
                [ Ui.singleChoiceQuestion
                    windowSize
                    Questions2023.doYouUseElmFormat
                    Nothing
                    form.doYouUseElmFormat
                    (\a -> FormChanged { form | doYouUseElmFormat = a })
                , Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions2023.stylingTools
                    Nothing
                    form.stylingTools
                    (\a -> FormChanged { form | stylingTools = a })
                , Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions2023.buildTools
                    Nothing
                    form.buildTools
                    (\a -> FormChanged { form | buildTools = a })
                , Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions2023.frameworks
                    Nothing
                    form.frameworks
                    (\a -> FormChanged { form | frameworks = a })
                , Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions2023.editors
                    Nothing
                    form.editors
                    (\a -> FormChanged { form | editors = a })
                , Ui.singleChoiceQuestion
                    windowSize
                    Questions2023.doYouUseElmReview
                    Nothing
                    form.doYouUseElmReview
                    (\a -> FormChanged { form | doYouUseElmReview = a })
                , packagesQuestion windowSize model
                , Ui.multiChoiceQuestionWithOther
                    windowSize
                    Questions2023.testTools
                    Nothing
                    form.testTools
                    (\a -> FormChanged { form | testTools = a })
                , Ui.textInput
                    windowSize
                    Questions2023.biggestPainPointTitle
                    Nothing
                    form.biggestPainPoint
                    (\a -> FormChanged { form | biggestPainPoint = a })
                , Ui.textInput
                    windowSize
                    Questions2023.whatDoYouLikeMostTitle
                    Nothing
                    form.whatDoYouLikeMost
                    (\a -> FormChanged { form | whatDoYouLikeMost = a })
                , Ui.textInput
                    windowSize
                    Questions2023.surveyImprovementsTitle
                    (Just "New questions you want to see, a question you think could have been worded better, UX improvements, etc.")
                    form.surveyImprovements
                    (\a -> FormChanged { form | surveyImprovements = a })
                ]
        ]


packagesQuestion : Size -> Form2023Loaded_ -> Element FrontendMsg
packagesQuestion windowSize model =
    let
        uniquePackages : List PackageName
        uniquePackages =
            List.concat model.form.elmJson |> List.unique
    in
    Ui.container
        windowSize
        [ Ui.title Questions2023.whatPackagesDoYouUseTitle
        , Ui.subtitle "Upload elm.json files from apps you're working on or worked on this year. You don't need to upload everything, each unique package is counted once."
        , Element.column
            [ Element.spacing 8, Element.width Element.fill ]
            [ Ui.customButton
                [ Element.Background.color Ui.blue1
                , Element.Font.color Ui.white
                , Element.Font.bold
                , Element.padding 16
                ]
                selectElmJsonFilesButtonId
                PressedSelectElmJsonFiles
                (Element.text "Upload elm.json")
            , Element.Input.multiline
                Ui.multilineAttributes
                { onChange = TypedElmJsonFile
                , text = ""
                , placeholder = Nothing
                , label = Element.Input.labelAbove [] (Element.text "Or paste the elm.json contents here")
                , spellcheck = False
                }
            , case model.elmJsonError of
                Just error ->
                    Element.el [ Element.Font.size 16, Element.Font.color (Element.rgb 0.8 0.1 0.2) ] (Element.text error)

                Nothing ->
                    Element.none
            ]
        , Element.wrappedRow
            [ Element.spacing 16 ]
            (List.indexedMap
                (\index elmJson ->
                    Element.el
                        [ Element.width (Element.px 130)
                        , Element.height (Element.px 130)
                        , Element.Border.color (Element.rgb 0.8 0.8 0.8)
                        , Element.Background.color (Element.rgb 0.94 0.94 0.94)
                        , Element.Border.rounded 4
                        , Element.Border.width 1
                        , Element.inFront
                            (Ui.customButton
                                [ Element.alignRight, Element.padding 4, Element.Font.size 20 ]
                                (removeElmJsonButtonId index)
                                (PressedRemoveElmJson index)
                                (Element.text "✖")
                            )
                        ]
                        (Element.column
                            [ Element.centerX
                            , Element.centerY
                            , Element.spacing 12
                            , Element.moveDown 4
                            ]
                            [ Element.el
                                [ Element.Font.bold, Element.centerX ]
                                (Element.text ("elm.json #" ++ String.fromInt index))
                            , Element.el
                                [ Element.Font.size 16, Element.centerX ]
                                (Element.text (String.fromInt (List.length elmJson) ++ " packages"))
                            ]
                        )
                )
                model.form.elmJson
            )
        , if List.isEmpty model.form.elmJson then
            Element.none

          else
            Element.el
                [ Element.Font.size 16 ]
                (Element.text ("Total unique packages: " ++ String.fromInt (List.length uniquePackages)))
        ]


selectElmJsonFilesButtonId : Dom.HtmlId
selectElmJsonFilesButtonId =
    Dom.id "selectElmJsonFilesButton"


removeElmJsonButtonId : Int -> Dom.HtmlId
removeElmJsonButtonId index =
    Dom.id ("removeElmJsonButton" ++ String.fromInt index)
