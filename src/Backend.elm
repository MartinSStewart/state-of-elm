module Backend exposing (..)

import AdminPage exposing (AdminLoginData)
import AnswerMap exposing (AnswerMap)
import AssocList as Dict
import AssocSet as Set
import DataEntry
import Effect.Command as Command exposing (BackendOnly, Command)
import Effect.Lamdera exposing (ClientId, SessionId)
import Effect.Task
import Effect.Time
import Env
import Form exposing (Form, FormOtherQuestions)
import Lamdera
import Questions
import Sha256
import Types exposing (..)


app =
    Effect.Lamdera.backend
        Lamdera.broadcast
        Lamdera.sendToFrontend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \_ -> Effect.Lamdera.onConnect UserConnected
        }


init : ( BackendModel, Command restriction toMsg BackendMsg )
init =
    let
        answerMap : FormOtherQuestions
        answerMap =
            { doYouUseElm = ""
            , age = ""
            , functionalProgrammingExperience = ""
            , otherLanguages = AnswerMap.fromMultiChoiceWithOther Questions.otherLanguages
            , newsAndDiscussions = AnswerMap.fromMultiChoiceWithOther Questions.newsAndDiscussions
            , elmResources = AnswerMap.fromMultiChoiceWithOther Questions.elmResources
            , countryLivingIn = ""
            , applicationDomains = AnswerMap.fromMultiChoiceWithOther Questions.applicationDomains
            , doYouUseElmAtWork = ""
            , howLargeIsTheCompany = ""
            , whatLanguageDoYouUseForBackend = AnswerMap.fromMultiChoiceWithOther Questions.whatLanguageDoYouUseForBackend
            , howLong = ""
            , elmVersion = AnswerMap.fromMultiChoiceWithOther Questions.elmVersion
            , doYouUseElmFormat = ""
            , stylingTools = AnswerMap.fromMultiChoiceWithOther Questions.stylingTools
            , buildTools = AnswerMap.fromMultiChoiceWithOther Questions.buildTools
            , frameworks = AnswerMap.fromMultiChoiceWithOther Questions.frameworks
            , editors = AnswerMap.fromMultiChoiceWithOther Questions.editors
            , doYouUseElmReview = ""
            , whichElmReviewRulesDoYouUse = AnswerMap.fromMultiChoiceWithOther Questions.whichElmReviewRulesDoYouUse
            , testTools = AnswerMap.fromMultiChoiceWithOther Questions.testTools
            , testsWrittenFor = AnswerMap.fromMultiChoiceWithOther Questions.testsWrittenFor
            , elmInitialInterest = AnswerMap.fromFreeText
            , biggestPainPoint = AnswerMap.fromFreeText
            , whatDoYouLikeMost = AnswerMap.fromFreeText
            }
    in
    ( { forms = Dict.empty
      , answerMap = answerMap
      , adminLogin = Nothing
      }
    , Command.none
    )


getAdminData : BackendModel -> AdminLoginData
getAdminData model =
    { forms = Dict.values model.forms, formMapping = model.answerMap }


update : BackendMsg -> BackendModel -> ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
update msg model =
    case msg of
        UserConnected sessionId clientId ->
            ( model
            , if isAdmin sessionId model then
                LoadAdmin (getAdminData model) |> Effect.Lamdera.sendToFrontend clientId

              else
                Effect.Time.now |> Effect.Task.perform (GotTimeWithLoadFormData sessionId clientId)
            )

        GotTimeWithLoadFormData sessionId clientId time ->
            ( model, loadFormData sessionId time model |> LoadForm |> Effect.Lamdera.sendToFrontend clientId )

        GotTimeWithUpdate sessionId clientId toBackend time ->
            updateFromFrontendWithTime time sessionId clientId toBackend model


loadFormData : SessionId -> Effect.Time.Posix -> BackendModel -> LoadFormStatus
loadFormData sessionId time model =
    case Types.surveyStatus of
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
                    |> DataEntry.fromForms "" Questions.doYouUseElm.choices
            , age = List.filterMap .age forms |> DataEntry.fromForms "" Questions.age.choices
            , functionalProgrammingExperience =
                List.filterMap .functionalProgrammingExperience forms
                    |> DataEntry.fromForms "" Questions.experienceLevel.choices
            , otherLanguages =
                List.map .otherLanguages forms
                    |> DataEntry.fromMultiChoiceWithOther Questions.otherLanguages model.answerMap.otherLanguages
            , newsAndDiscussions =
                List.map .newsAndDiscussions forms
                    |> DataEntry.fromMultiChoiceWithOther Questions.newsAndDiscussions model.answerMap.newsAndDiscussions
            , elmResources =
                List.map .elmResources forms
                    |> DataEntry.fromMultiChoiceWithOther Questions.elmResources model.answerMap.elmResources
            , countryLivingIn = ""
            , doYouUseElmAtWork =
                List.filterMap .doYouUseElmAtWork forms
                    |> DataEntry.fromForms "" Questions.doYouUseElmAtWork.choices
            , applicationDomains =
                List.map .applicationDomains forms
                    |> DataEntry.fromMultiChoiceWithOther Questions.applicationDomains model.answerMap.applicationDomains
            , howLargeIsTheCompany =
                List.filterMap .howLargeIsTheCompany forms
                    |> DataEntry.fromForms "" Questions.howLargeIsTheCompany.choices
            , whatLanguageDoYouUseForBackend =
                List.map .whatLanguageDoYouUseForBackend forms
                    |> DataEntry.fromMultiChoiceWithOther Questions.whatLanguageDoYouUseForBackend model.answerMap.whatLanguageDoYouUseForBackend
            , howLong = List.filterMap .howLong forms |> DataEntry.fromForms "" Questions.howLong.choices
            , elmVersion =
                List.map .elmVersion forms
                    |> DataEntry.fromMultiChoiceWithOther Questions.elmVersion model.answerMap.elmVersion
            , doYouUseElmFormat =
                List.filterMap .doYouUseElmFormat forms
                    |> DataEntry.fromForms "" Questions.doYouUseElmFormat.choices
            , stylingTools =
                List.map .stylingTools forms
                    |> DataEntry.fromMultiChoiceWithOther Questions.stylingTools model.answerMap.stylingTools
            , buildTools =
                List.map .buildTools forms
                    |> DataEntry.fromMultiChoiceWithOther Questions.buildTools model.answerMap.buildTools
            , frameworks =
                List.map .frameworks forms
                    |> DataEntry.fromMultiChoiceWithOther Questions.frameworks model.answerMap.frameworks
            , editors =
                List.map .editors forms
                    |> DataEntry.fromMultiChoiceWithOther Questions.editors model.answerMap.editors
            , doYouUseElmReview =
                List.filterMap .doYouUseElmReview forms
                    |> DataEntry.fromForms "" Questions.doYouUseElmReview.choices
            , whichElmReviewRulesDoYouUse =
                List.map .whichElmReviewRulesDoYouUse forms
                    |> DataEntry.fromMultiChoiceWithOther Questions.whichElmReviewRulesDoYouUse model.answerMap.whichElmReviewRulesDoYouUse
            , testTools =
                List.map .testTools forms
                    |> DataEntry.fromMultiChoiceWithOther Questions.testTools model.answerMap.testTools
            , testsWrittenFor =
                List.map .testsWrittenFor forms
                    |> DataEntry.fromMultiChoiceWithOther Questions.testsWrittenFor model.answerMap.testsWrittenFor
            , elmInitialInterest = ""
            , biggestPainPoint = ""
            , whatDoYouLikeMost = ""
            }
                |> SurveyResults


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Command restriction toMsg BackendMsg )
updateFromFrontend sessionId clientId msg model =
    ( model, Effect.Time.now |> Effect.Task.perform (GotTimeWithUpdate sessionId clientId msg) )


updateFromFrontendWithTime : Effect.Time.Posix -> SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
updateFromFrontendWithTime time sessionId clientId msg model =
    case msg of
        AutoSaveForm form ->
            case Types.surveyStatus of
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
                    , Command.none
                    )

                SurveyFinished ->
                    ( model, Command.none )

        SubmitForm form ->
            case Types.surveyStatus of
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
                        , Effect.Lamdera.sendToFrontend clientId SubmitConfirmed
                        )

                    else
                        ( model, Command.none )

                SurveyFinished ->
                    ( model, Command.none )

        AdminLoginRequest password ->
            if Env.adminPasswordHash == Sha256.sha256 password then
                ( { model | adminLogin = Just sessionId }
                , getAdminData model |> Ok |> AdminLoginResponse |> Effect.Lamdera.sendToFrontend clientId
                )

            else
                ( model, Err () |> AdminLoginResponse |> Effect.Lamdera.sendToFrontend clientId )

        AdminToBackend (AdminPage.ReplaceFormsRequest forms) ->
            ( if not Env.isProduction && isAdmin sessionId model then
                { model
                    | forms =
                        List.indexedMap
                            (\index form ->
                                ( Char.fromCode index |> String.fromChar |> Effect.Lamdera.sessionIdFromString
                                , { form = form, submitTime = Just (Effect.Time.millisToPosix 0) }
                                )
                            )
                            forms
                            |> Dict.fromList
                }

              else
                model
            , Command.none
            )

        AdminToBackend AdminPage.LogOutRequest ->
            if isAdmin sessionId model then
                ( { model | adminLogin = Nothing }
                , loadFormData sessionId time model |> LogOutResponse |> Effect.Lamdera.sendToFrontend clientId
                )

            else
                ( model, Command.none )

        AdminToBackend (AdminPage.SaveAnswerMap answerMap) ->
            if isAdmin sessionId model then
                ( { model | answerMap = answerMap }
                , Command.none
                )

            else
                ( model, Command.none )


isAdmin : SessionId -> BackendModel -> Bool
isAdmin sessionId model =
    Just sessionId == model.adminLogin
