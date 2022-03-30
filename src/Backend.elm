module Backend exposing (..)

import AssocList as Dict
import Env
import Lamdera exposing (ClientId, SessionId)
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
    ( { forms = Dict.empty, adminLogin = Nothing }
    , Cmd.none
    )


getAdminData : BackendModel -> AdminLoginData
getAdminData model =
    { autoSavedSurveyCount =
        Dict.values model.forms
            |> List.map (.submitTime >> (==) Nothing)
            |> List.length
    , submittedSurveyCount =
        Dict.values model.forms
            |> List.map (.submitTime >> (/=) Nothing)
            |> List.length
    }


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    case msg of
        UserConnected sessionId clientId ->
            ( model
            , (case ( model.adminLogin == Just sessionId, Dict.get sessionId model.forms ) of
                ( True, _ ) ->
                    LoadAdmin (getAdminData model)

                ( False, Just value ) ->
                    case value.submitTime of
                        Just _ ->
                            LoadForm FormSubmitted

                        Nothing ->
                            FormAutoSaved value.form |> LoadForm

                ( False, Nothing ) ->
                    LoadForm NoFormFound
              )
                |> Lamdera.sendToFrontend clientId
            )

        GotTimeWithUpdate sessionId clientId toBackend time ->
            updateFromFrontendWithTime time sessionId clientId toBackend model


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    ( model, Time.now |> Task.perform (GotTimeWithUpdate sessionId clientId msg) )


updateFromFrontendWithTime : Time.Posix -> SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontendWithTime time sessionId clientId msg model =
    case msg of
        AutoSaveForm form ->
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
                                            Just { value | form = form }

                                Nothing ->
                                    Just { form = form, submitTime = Nothing }
                        )
                        model.forms
              }
            , Cmd.none
            )

        SubmitForm form ->
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

        AdminLoginRequest password ->
            if Env.adminPasswordHash == Sha256.sha256 password then
                ( { model | adminLogin = Just sessionId }
                , getAdminData model |> Ok |> AdminLoginResponse |> Lamdera.sendToFrontend clientId
                )

            else
                ( model, Err () |> AdminLoginResponse |> Lamdera.sendToFrontend clientId )
