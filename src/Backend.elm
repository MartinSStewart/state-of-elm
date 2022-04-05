module Backend exposing (..)

import AdminPage exposing (AdminLoginData)
import AssocList as Dict
import AssocSet as Set
import DataEntry
import Env
import Form exposing (Form)
import Lamdera exposing (ClientId, SessionId)
import Questions
import Sha256
import Task
import Time
import Types exposing (..)


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \_ -> Lamdera.onConnect UserConnected
        }


init : ( BackendModel, Cmd BackendMsg )
init =
    ( { forms = Dict.empty
      , formMapping = Form.noMapping
      , adminLogin = Nothing
      }
    , Cmd.none
    )


getAdminData : BackendModel -> AdminLoginData
getAdminData model =
    { forms = Dict.values model.forms, formMapping = model.formMapping }


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    case msg of
        UserConnected sessionId clientId ->
            ( model
            , if isAdmin sessionId model then
                LoadAdmin (getAdminData model) |> Lamdera.sendToFrontend clientId

              else
                Time.now |> Task.perform (GotTimeWithLoadFormData sessionId clientId)
            )

        GotTimeWithLoadFormData sessionId clientId time ->
            ( model, loadFormData sessionId time model |> LoadForm |> Lamdera.sendToFrontend clientId )

        GotTimeWithUpdate sessionId clientId toBackend time ->
            updateFromFrontendWithTime time sessionId clientId toBackend model


loadFormData : SessionId -> Time.Posix -> BackendModel -> LoadFormStatus
loadFormData sessionId time model =
    case Env.surveyStatus of
        SurveyOpen ->
            if Env.surveyIsOpen time then
                case Dict.get sessionId model.forms of
                    Just value ->
                        case value.submitTime of
                            Just _ ->
                                FormSubmitted

                            Nothing ->
                                FormAutoSaved value.form

                    Nothing ->
                        NoFormFound

            else
                AwaitingResultsData

        SurveyFinished ->
            let
                forms : List Form
                forms =
                    Dict.values model.forms
                        |> List.filterMap
                            (\{ form, submitTime } ->
                                case submitTime of
                                    Just _ ->
                                        Just form

                                    Nothing ->
                                        Nothing
                            )
            in
            { doYouUseElm =
                List.concatMap (.doYouUseElm >> Set.toList) forms
                    |> DataEntry.fromForms Questions.doYouUseElm.choices
            , age = List.filterMap .age forms |> DataEntry.fromForms Questions.age.choices
            , functionalProgrammingExperience =
                List.filterMap .functionalProgrammingExperience forms
                    |> DataEntry.fromForms Questions.experienceLevel.choices
            , doYouUseElmAtWork =
                List.filterMap .doYouUseElmAtWork forms
                    |> DataEntry.fromForms Questions.doYouUseElmAtWork.choices
            , howLargeIsTheCompany =
                List.filterMap .howLargeIsTheCompany forms
                    |> DataEntry.fromForms Questions.howLargeIsTheCompany.choices
            , howLong = List.filterMap .howLong forms |> DataEntry.fromForms Questions.howLong.choices
            , doYouUseElmFormat =
                List.filterMap .doYouUseElmFormat forms
                    |> DataEntry.fromForms Questions.doYouUseElmFormat.choices
            , doYouUseElmReview =
                List.filterMap .doYouUseElmReview forms
                    |> DataEntry.fromForms Questions.doYouUseElmReview.choices
            }
                |> SurveyResults


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    ( model, Time.now |> Task.perform (GotTimeWithUpdate sessionId clientId msg) )


updateFromFrontendWithTime : Time.Posix -> SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontendWithTime time sessionId clientId msg model =
    case msg of
        AutoSaveForm form ->
            case Env.surveyStatus of
                SurveyOpen ->
                    ( if Env.surveyIsOpen time then
                        { model
                            | forms =
                                Dict.update
                                    sessionId
                                    (\maybeValue ->
                                        case maybeValue of
                                            Just value ->
                                                case value.submitTime of
                                                    Just _ ->
                                                        maybeValue

                                                    Nothing ->
                                                        Just { value | form = form }

                                            Nothing ->
                                                Just { form = form, submitTime = Nothing }
                                    )
                                    model.forms
                        }

                      else
                        model
                    , Cmd.none
                    )

                SurveyFinished ->
                    ( model, Cmd.none )

        SubmitForm form ->
            case Env.surveyStatus of
                SurveyOpen ->
                    if Env.surveyIsOpen time then
                        ( { model
                            | forms =
                                Dict.update
                                    sessionId
                                    (\maybeValue ->
                                        case maybeValue of
                                            Just value ->
                                                case value.submitTime of
                                                    Just _ ->
                                                        maybeValue

                                                    Nothing ->
                                                        Just { value | form = form, submitTime = Just time }

                                            Nothing ->
                                                Just { form = form, submitTime = Just time }
                                    )
                                    model.forms
                          }
                        , Lamdera.sendToFrontend clientId SubmitConfirmed
                        )

                    else
                        ( model, Cmd.none )

                SurveyFinished ->
                    ( model, Cmd.none )

        AdminLoginRequest password ->
            if Env.adminPasswordHash == Sha256.sha256 password then
                ( { model | adminLogin = Just sessionId }
                , getAdminData model |> Ok |> AdminLoginResponse |> Lamdera.sendToFrontend clientId
                )

            else
                ( model, Err () |> AdminLoginResponse |> Lamdera.sendToFrontend clientId )

        ReplaceFormsRequest forms ->
            ( if not Env.isProduction && isAdmin sessionId model then
                { model
                    | forms =
                        List.indexedMap
                            (\index form ->
                                ( Char.fromCode index |> String.fromChar
                                , { form = form, submitTime = Just (Time.millisToPosix 0) }
                                )
                            )
                            forms
                            |> Dict.fromList
                }

              else
                model
            , Cmd.none
            )

        LogOutRequest ->
            if isAdmin sessionId model then
                ( { model | adminLogin = Nothing }
                , loadFormData sessionId time model |> LogOutResponse |> Lamdera.sendToFrontend clientId
                )

            else
                ( model, Cmd.none )


isAdmin : SessionId -> BackendModel -> Bool
isAdmin sessionId model =
    Just sessionId == model.adminLogin
