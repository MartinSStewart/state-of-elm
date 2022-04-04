module Backend exposing (..)

import AssocList as Dict
import AssocSet as Set
import DataEntry
import Env
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
    ( { forms = Dict.empty, adminLogin = Nothing }
    , Cmd.none
    )


getAdminData : BackendModel -> AdminLoginData
getAdminData model =
    { forms = Dict.values model.forms }


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    case msg of
        UserConnected sessionId clientId ->
            ( model
            , if model.adminLogin == Just sessionId then
                LoadAdmin (getAdminData model) |> Lamdera.sendToFrontend clientId

              else
                loadFormData sessionId model |> LoadForm |> Lamdera.sendToFrontend clientId
            )

        GotTimeWithUpdate sessionId clientId toBackend time ->
            updateFromFrontendWithTime time sessionId clientId toBackend model


loadFormData sessionId model =
    case Env.surveyStatus of
        SurveyOpen ->
            case Dict.get sessionId model.forms of
                Just value ->
                    case value.submitTime of
                        Just _ ->
                            FormSubmitted

                        Nothing ->
                            FormAutoSaved value.form

                Nothing ->
                    NoFormFound

        AwaitingResults ->
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

                AwaitingResults ->
                    ( model, Cmd.none )

                SurveyFinished ->
                    ( model, Cmd.none )

        SubmitForm form ->
            case Env.surveyStatus of
                SurveyOpen ->
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

                AwaitingResults ->
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
            ( if Env.isProduction then
                model

              else
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
            , Cmd.none
            )

        LogOutRequest ->
            if Just sessionId == model.adminLogin then
                ( { model | adminLogin = Nothing }
                , loadFormData sessionId model |> LogOutResponse |> Lamdera.sendToFrontend clientId
                )

            else
                ( model, Cmd.none )
