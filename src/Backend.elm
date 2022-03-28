module Backend exposing (..)

import AssocList as Dict
import Lamdera exposing (ClientId, SessionId)
import Task
import Time
import Types exposing (..)


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Lamdera.onConnect UserConnected
        }


init : ( BackendModel, Cmd BackendMsg )
init =
    ( { forms = Dict.empty }
    , Cmd.none
    )


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    case msg of
        UserConnected sessionId clientId ->
            ( model
            , (case Dict.get sessionId model.forms of
                Just value ->
                    case value.submitTime of
                        Just _ ->
                            FormSubmitted

                        Nothing ->
                            FormAutoSaved value.form

                Nothing ->
                    NoFormFound
              )
                |> LoadForm
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
