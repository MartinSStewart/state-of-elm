module Backend exposing (..)

import AssocList as Dict
import Lamdera exposing (ClientId, SessionId)
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
                    if value.isSubmitted then
                        FormSubmitted

                    else
                        FormAutoSaved value.form

                Nothing ->
                    NoFormFound
              )
                |> LoadForm
                |> Lamdera.sendToFrontend clientId
            )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        AutoSaveForm form ->
            ( { model
                | forms =
                    Dict.update
                        sessionId
                        (\maybeValue ->
                            case maybeValue of
                                Just value ->
                                    if value.isSubmitted then
                                        maybeValue

                                    else
                                        Just { value | form = form }

                                Nothing ->
                                    Just { form = form, isSubmitted = False }
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
                                    if value.isSubmitted then
                                        maybeValue

                                    else
                                        Just { value | form = form, isSubmitted = True }

                                Nothing ->
                                    Just { form = form, isSubmitted = True }
                        )
                        model.forms
              }
            , Lamdera.sendToFrontend clientId SubmitConfirmed
            )
