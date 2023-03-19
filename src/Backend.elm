module Backend exposing (..)

import AdminPage exposing (AdminLoginData)
import AnswerMap exposing (AnswerMap)
import AssocList as Dict
import AssocSet as Set
import DataEntry
import Effect.Command as Command exposing (BackendOnly, Command)
import Effect.Lamdera exposing (ClientId, SessionId)
import Effect.Subscription as Subscription
import Effect.Task as Task
import Effect.Time
import Email.Html as Html
import Email.Html.Attributes as Attributes
import EmailAddress
import Env
import Form exposing (Form, FormMapping)
import FreeTextAnswerMap exposing (FreeTextAnswerMap)
import Lamdera
import List.Nonempty exposing (Nonempty(..))
import Questions exposing (Question)
import SendGrid
import Sha256
import String.Nonempty exposing (NonemptyString(..))
import SurveyResults2022
import SurveyResults2023
import Types exposing (..)
import Ui exposing (MultiChoiceWithOther)


app =
    Effect.Lamdera.backend
        Lamdera.broadcast
        Lamdera.sendToFrontend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


subscriptions _ =
    Subscription.none


init : ( BackendModel, Command restriction toMsg BackendMsg )
init =
    ( { adminLogin = Set.empty
      , survey2022 = initSurvey2022
      , survey2023 = initSurvey2023
      }
    , Command.none
    )


initSurvey2022 : BackendSurvey2022
initSurvey2022 =
    let
        answerMap : FormMapping
        answerMap =
            { doYouUseElm = ""
            , age = ""
            , functionalProgrammingExperience = ""
            , otherLanguages = AnswerMap.init Questions.otherLanguages
            , newsAndDiscussions = AnswerMap.init Questions.newsAndDiscussions
            , elmResources = AnswerMap.init Questions.elmResources
            , elmInitialInterest = FreeTextAnswerMap.init
            , countryLivingIn = ""
            , applicationDomains = AnswerMap.init Questions.applicationDomains
            , doYouUseElmAtWork = ""
            , howLargeIsTheCompany = ""
            , whatLanguageDoYouUseForBackend = AnswerMap.init Questions.whatLanguageDoYouUseForBackend
            , howLong = ""
            , elmVersion = AnswerMap.init Questions.elmVersion
            , doYouUseElmFormat = ""
            , stylingTools = AnswerMap.init Questions.stylingTools
            , buildTools = AnswerMap.init Questions.buildTools
            , frameworks = AnswerMap.init Questions.frameworks2022
            , editors = AnswerMap.init Questions.editors
            , doYouUseElmReview = ""
            , whichElmReviewRulesDoYouUse = AnswerMap.init Questions.whichElmReviewRulesDoYouUse
            , testTools = AnswerMap.init Questions.testTools
            , testsWrittenFor = AnswerMap.init Questions.testsWrittenFor
            , biggestPainPoint = FreeTextAnswerMap.init
            , whatDoYouLikeMost = FreeTextAnswerMap.init
            }
    in
    { forms = Dict.empty
    , formMapping = answerMap
    , sendEmailsStatus = AdminPage.EmailsNotSent
    , cachedSurveyResults = Nothing
    }


initSurvey2023 : BackendSurvey2023
initSurvey2023 =
    let
        answerMap : FormMapping
        answerMap =
            { doYouUseElm = ""
            , age = ""
            , functionalProgrammingExperience = ""
            , otherLanguages = AnswerMap.init Questions.otherLanguages
            , newsAndDiscussions = AnswerMap.init Questions.newsAndDiscussions
            , elmResources = AnswerMap.init Questions.elmResources
            , elmInitialInterest = FreeTextAnswerMap.init
            , countryLivingIn = ""
            , applicationDomains = AnswerMap.init Questions.applicationDomains
            , doYouUseElmAtWork = ""
            , howLargeIsTheCompany = ""
            , whatLanguageDoYouUseForBackend = AnswerMap.init Questions.whatLanguageDoYouUseForBackend
            , howLong = ""
            , elmVersion = AnswerMap.init Questions.elmVersion
            , doYouUseElmFormat = ""
            , stylingTools = AnswerMap.init Questions.stylingTools
            , buildTools = AnswerMap.init Questions.buildTools
            , frameworks = AnswerMap.init Questions.frameworks2023
            , editors = AnswerMap.init Questions.editors
            , doYouUseElmReview = ""
            , whichElmReviewRulesDoYouUse = AnswerMap.init Questions.whichElmReviewRulesDoYouUse
            , testTools = AnswerMap.init Questions.testTools
            , testsWrittenFor = AnswerMap.init Questions.testsWrittenFor
            , biggestPainPoint = FreeTextAnswerMap.init
            , whatDoYouLikeMost = FreeTextAnswerMap.init
            }
    in
    { forms = Dict.empty
    , formMapping = answerMap
    , sendEmailsStatus = AdminPage.EmailsNotSent
    , cachedSurveyResults = Nothing
    }


getCurrentSurvey : { a | survey2023 : BackendSurvey2023 } -> BackendSurvey2023
getCurrentSurvey =
    .survey2023


setCurrentSurvey :
    (BackendSurvey2023 -> BackendSurvey2023)
    -> { a | survey2023 : BackendSurvey2023 }
    -> { a | survey2023 : BackendSurvey2023 }
setCurrentSurvey updateFunc model =
    { model | survey2023 = updateFunc model.survey2023 }


getAdminData : BackendSurvey2023 -> AdminLoginData
getAdminData survey =
    { forms = Dict.values survey.forms, formMapping = survey.formMapping, sendEmailsStatus = survey.sendEmailsStatus }


update : BackendMsg -> BackendModel -> ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
update msg model =
    case msg of
        --UserConnected sessionId clientId ->
        --    ( model
        --    , if isAdmin sessionId model then
        --        LoadAdmin (getAdminData (getCurrentSurvey model)) |> Effect.Lamdera.sendToFrontend clientId
        --
        --      else
        --        Effect.Time.now |> Task.perform (GotTimeWithLoadFormData sessionId clientId)
        --    )
        --GotTimeWithLoadFormData sessionId clientId time ->
        --    loadFormData sessionId time model |> Tuple.mapSecond (LoadForm >> Effect.Lamdera.sendToFrontend clientId)
        GotTimeWithUpdate sessionId clientId toBackend time ->
            updateFromFrontendWithTime time sessionId clientId toBackend model

        EmailsSent clientId list ->
            ( setCurrentSurvey (\survey -> { survey | sendEmailsStatus = AdminPage.SendResult list }) model
            , AdminPage.SendEmailsResponse list |> AdminToFrontend |> Effect.Lamdera.sendToFrontend clientId
            )


loadFormData : SessionId -> Effect.Time.Posix -> BackendModel -> ( BackendSurvey2022, LoadFormStatus )
loadFormData sessionId time model =
    case Types.surveyStatus of
        SurveyOpen ->
            ( getCurrentSurvey model
            , if Env.surveyIsOpen time then
                case Dict.get sessionId (getCurrentSurvey model).forms of
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
            )

        SurveyFinished ->
            formData2022 (getCurrentSurvey model) |> Tuple.mapSecond SurveyResults


formData2022 : BackendSurvey2022 -> ( BackendSurvey2022, SurveyResults2022.Data )
formData2022 model =
    case model.cachedSurveyResults of
        Just cache ->
            ( model, cache )

        Nothing ->
            let
                submittedForms : List Form
                submittedForms =
                    Dict.values model.forms
                        |> List.filterMap
                            (\{ form, submitTime } ->
                                case submitTime of
                                    Just _ ->
                                        Just form

                                    Nothing ->
                                        Nothing
                            )

                formsWithoutNoInterestedInElm : List Form
                formsWithoutNoInterestedInElm =
                    List.filter (Form.notInterestedInElm >> not) submittedForms

                segmentWithOther :
                    (Form -> MultiChoiceWithOther a)
                    -> (FormMapping -> AnswerMap a)
                    -> Question a
                    -> SurveyResults2022.DataEntryWithOtherSegments a
                segmentWithOther formField answerMapField question =
                    { users =
                        List.filterMap
                            (\form ->
                                if Form.doesNotUseElm form then
                                    Nothing

                                else
                                    Just (formField form)
                            )
                            formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther question (answerMapField model.formMapping)
                    , potentialUsers =
                        List.filterMap
                            (\form ->
                                if Form.doesNotUseElm form then
                                    Just (formField form)

                                else
                                    Nothing
                            )
                            formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther question (answerMapField model.formMapping)
                    }

                segment : (Form -> Maybe a) -> (FormMapping -> String) -> Question a -> SurveyResults2022.DataEntrySegments a
                segment formField answerMapField question =
                    { users =
                        List.filterMap
                            (\form ->
                                if Form.doesNotUseElm form then
                                    Nothing

                                else
                                    formField form
                            )
                            formsWithoutNoInterestedInElm
                            |> DataEntry.fromForms (answerMapField model.formMapping) question.choices
                    , potentialUsers =
                        List.filterMap
                            (\form ->
                                if Form.doesNotUseElm form then
                                    formField form

                                else
                                    Nothing
                            )
                            formsWithoutNoInterestedInElm
                            |> DataEntry.fromForms (answerMapField model.formMapping) question.choices
                    }

                segmentFreeText : (Form -> String) -> (FormMapping -> FreeTextAnswerMap) -> SurveyResults2022.DataEntryWithOtherSegments a
                segmentFreeText formField answerMapField =
                    { users =
                        List.filterMap
                            (\form ->
                                if Form.doesNotUseElm form then
                                    Nothing

                                else
                                    Just (formField form)
                            )
                            formsWithoutNoInterestedInElm
                            |> DataEntry.fromFreeText (answerMapField model.formMapping)
                    , potentialUsers =
                        List.filterMap
                            (\form ->
                                if Form.doesNotUseElm form && not (Form.notInterestedInElm form) then
                                    Just (formField form)

                                else
                                    Nothing
                            )
                            formsWithoutNoInterestedInElm
                            |> DataEntry.fromFreeText (answerMapField model.formMapping)
                    }

                formData_ =
                    { totalParticipants = List.length submittedForms
                    , doYouUseElm =
                        List.concatMap (.doYouUseElm >> Set.toList) submittedForms
                            |> DataEntry.fromForms model.formMapping.doYouUseElm Questions.doYouUseElm.choices
                    , age = segment .age .age Questions.age
                    , functionalProgrammingExperience =
                        segment .functionalProgrammingExperience .functionalProgrammingExperience Questions.experienceLevel
                    , otherLanguages = segmentWithOther .otherLanguages .otherLanguages Questions.otherLanguages
                    , newsAndDiscussions = segmentWithOther .newsAndDiscussions .newsAndDiscussions Questions.newsAndDiscussions
                    , elmInitialInterest = segmentFreeText .elmInitialInterest .elmInitialInterest
                    , countryLivingIn = segment .countryLivingIn .countryLivingIn Questions.countryLivingIn
                    , elmResources =
                        List.map .elmResources formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.elmResources model.formMapping.elmResources
                    , doYouUseElmAtWork =
                        List.filterMap .doYouUseElmAtWork formsWithoutNoInterestedInElm
                            |> DataEntry.fromForms model.formMapping.doYouUseElmAtWork Questions.doYouUseElmAtWork.choices
                    , applicationDomains =
                        List.map .applicationDomains formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.applicationDomains model.formMapping.applicationDomains
                    , howLargeIsTheCompany =
                        List.filterMap .howLargeIsTheCompany formsWithoutNoInterestedInElm
                            |> DataEntry.fromForms model.formMapping.howLargeIsTheCompany Questions.howLargeIsTheCompany.choices
                    , whatLanguageDoYouUseForBackend =
                        List.map .whatLanguageDoYouUseForBackend formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.whatLanguageDoYouUseForBackend model.formMapping.whatLanguageDoYouUseForBackend
                    , howLong = List.filterMap .howLong formsWithoutNoInterestedInElm |> DataEntry.fromForms model.formMapping.howLong Questions.howLong.choices
                    , elmVersion =
                        List.map .elmVersion formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.elmVersion model.formMapping.elmVersion
                    , doYouUseElmFormat =
                        List.filterMap .doYouUseElmFormat formsWithoutNoInterestedInElm
                            |> DataEntry.fromForms model.formMapping.doYouUseElmFormat Questions.doYouUseElmFormat.choices
                    , stylingTools =
                        List.map .stylingTools formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.stylingTools model.formMapping.stylingTools
                    , buildTools =
                        List.map .buildTools formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.buildTools model.formMapping.buildTools
                    , frameworks =
                        List.map .frameworks formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.frameworks2022 model.formMapping.frameworks
                    , editors =
                        List.map .editors formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.editors model.formMapping.editors
                    , doYouUseElmReview =
                        List.filterMap .doYouUseElmReview formsWithoutNoInterestedInElm
                            |> DataEntry.fromForms model.formMapping.doYouUseElmReview Questions.doYouUseElmReview.choices
                    , whichElmReviewRulesDoYouUse =
                        List.map .whichElmReviewRulesDoYouUse formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.whichElmReviewRulesDoYouUse model.formMapping.whichElmReviewRulesDoYouUse
                    , testTools =
                        List.map .testTools formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.testTools model.formMapping.testTools
                    , testsWrittenFor =
                        List.map .testsWrittenFor formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.testsWrittenFor model.formMapping.testsWrittenFor
                    , biggestPainPoint =
                        List.map .biggestPainPoint formsWithoutNoInterestedInElm
                            |> DataEntry.fromFreeText model.formMapping.biggestPainPoint
                    , whatDoYouLikeMost =
                        List.map .whatDoYouLikeMost formsWithoutNoInterestedInElm
                            |> DataEntry.fromFreeText model.formMapping.whatDoYouLikeMost
                    }
            in
            ( { model | cachedSurveyResults = Just formData_ }, formData_ )


formData2023 : BackendSurvey2023 -> ( BackendSurvey2023, SurveyResults2023.Data )
formData2023 model =
    case model.cachedSurveyResults of
        Just cache ->
            ( model, cache )

        Nothing ->
            let
                submittedForms : List Form
                submittedForms =
                    Dict.values model.forms
                        |> List.filterMap
                            (\{ form, submitTime } ->
                                case submitTime of
                                    Just _ ->
                                        Just form

                                    Nothing ->
                                        Nothing
                            )

                formsWithoutNoInterestedInElm : List Form
                formsWithoutNoInterestedInElm =
                    List.filter (Form.notInterestedInElm >> not) submittedForms

                segmentWithOther :
                    (Form -> MultiChoiceWithOther a)
                    -> (FormMapping -> AnswerMap a)
                    -> Question a
                    -> SurveyResults2022.DataEntryWithOtherSegments a
                segmentWithOther formField answerMapField question =
                    { users =
                        List.filterMap
                            (\form ->
                                if Form.doesNotUseElm form then
                                    Nothing

                                else
                                    Just (formField form)
                            )
                            formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther question (answerMapField model.formMapping)
                    , potentialUsers =
                        List.filterMap
                            (\form ->
                                if Form.doesNotUseElm form then
                                    Just (formField form)

                                else
                                    Nothing
                            )
                            formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther question (answerMapField model.formMapping)
                    }

                segment : (Form -> Maybe a) -> (FormMapping -> String) -> Question a -> SurveyResults2022.DataEntrySegments a
                segment formField answerMapField question =
                    { users =
                        List.filterMap
                            (\form ->
                                if Form.doesNotUseElm form then
                                    Nothing

                                else
                                    formField form
                            )
                            formsWithoutNoInterestedInElm
                            |> DataEntry.fromForms (answerMapField model.formMapping) question.choices
                    , potentialUsers =
                        List.filterMap
                            (\form ->
                                if Form.doesNotUseElm form then
                                    formField form

                                else
                                    Nothing
                            )
                            formsWithoutNoInterestedInElm
                            |> DataEntry.fromForms (answerMapField model.formMapping) question.choices
                    }

                segmentFreeText : (Form -> String) -> (FormMapping -> FreeTextAnswerMap) -> SurveyResults2022.DataEntryWithOtherSegments a
                segmentFreeText formField answerMapField =
                    { users =
                        List.filterMap
                            (\form ->
                                if Form.doesNotUseElm form then
                                    Nothing

                                else
                                    Just (formField form)
                            )
                            formsWithoutNoInterestedInElm
                            |> DataEntry.fromFreeText (answerMapField model.formMapping)
                    , potentialUsers =
                        List.filterMap
                            (\form ->
                                if Form.doesNotUseElm form && not (Form.notInterestedInElm form) then
                                    Just (formField form)

                                else
                                    Nothing
                            )
                            formsWithoutNoInterestedInElm
                            |> DataEntry.fromFreeText (answerMapField model.formMapping)
                    }

                formData_ =
                    { totalParticipants = List.length submittedForms
                    , doYouUseElm =
                        List.concatMap (.doYouUseElm >> Set.toList) submittedForms
                            |> DataEntry.fromForms model.formMapping.doYouUseElm Questions.doYouUseElm.choices
                    , age = segment .age .age Questions.age
                    , functionalProgrammingExperience =
                        segment .functionalProgrammingExperience .functionalProgrammingExperience Questions.experienceLevel
                    , otherLanguages = segmentWithOther .otherLanguages .otherLanguages Questions.otherLanguages
                    , newsAndDiscussions = segmentWithOther .newsAndDiscussions .newsAndDiscussions Questions.newsAndDiscussions
                    , elmInitialInterest = segmentFreeText .elmInitialInterest .elmInitialInterest
                    , countryLivingIn = segment .countryLivingIn .countryLivingIn Questions.countryLivingIn
                    , elmResources =
                        List.map .elmResources formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.elmResources model.formMapping.elmResources
                    , doYouUseElmAtWork =
                        List.filterMap .doYouUseElmAtWork formsWithoutNoInterestedInElm
                            |> DataEntry.fromForms model.formMapping.doYouUseElmAtWork Questions.doYouUseElmAtWork.choices
                    , applicationDomains =
                        List.map .applicationDomains formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.applicationDomains model.formMapping.applicationDomains
                    , howLargeIsTheCompany =
                        List.filterMap .howLargeIsTheCompany formsWithoutNoInterestedInElm
                            |> DataEntry.fromForms model.formMapping.howLargeIsTheCompany Questions.howLargeIsTheCompany.choices
                    , whatLanguageDoYouUseForBackend =
                        List.map .whatLanguageDoYouUseForBackend formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.whatLanguageDoYouUseForBackend model.formMapping.whatLanguageDoYouUseForBackend
                    , howLong = List.filterMap .howLong formsWithoutNoInterestedInElm |> DataEntry.fromForms model.formMapping.howLong Questions.howLong.choices
                    , elmVersion =
                        List.map .elmVersion formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.elmVersion model.formMapping.elmVersion
                    , doYouUseElmFormat =
                        List.filterMap .doYouUseElmFormat formsWithoutNoInterestedInElm
                            |> DataEntry.fromForms model.formMapping.doYouUseElmFormat Questions.doYouUseElmFormat.choices
                    , stylingTools =
                        List.map .stylingTools formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.stylingTools model.formMapping.stylingTools
                    , buildTools =
                        List.map .buildTools formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.buildTools model.formMapping.buildTools
                    , frameworks =
                        List.map .frameworks formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.frameworks2023 model.formMapping.frameworks
                    , editors =
                        List.map .editors formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.editors model.formMapping.editors
                    , doYouUseElmReview =
                        List.filterMap .doYouUseElmReview formsWithoutNoInterestedInElm
                            |> DataEntry.fromForms model.formMapping.doYouUseElmReview Questions.doYouUseElmReview.choices
                    , whichElmReviewRulesDoYouUse =
                        List.map .whichElmReviewRulesDoYouUse formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.whichElmReviewRulesDoYouUse model.formMapping.whichElmReviewRulesDoYouUse
                    , testTools =
                        List.map .testTools formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.testTools model.formMapping.testTools
                    , testsWrittenFor =
                        List.map .testsWrittenFor formsWithoutNoInterestedInElm
                            |> DataEntry.fromMultiChoiceWithOther Questions.testsWrittenFor model.formMapping.testsWrittenFor
                    , biggestPainPoint =
                        List.map .biggestPainPoint formsWithoutNoInterestedInElm
                            |> DataEntry.fromFreeText model.formMapping.biggestPainPoint
                    , whatDoYouLikeMost =
                        List.map .whatDoYouLikeMost formsWithoutNoInterestedInElm
                            |> DataEntry.fromFreeText model.formMapping.whatDoYouLikeMost
                    }
            in
            ( { model | cachedSurveyResults = Just formData_ }, formData_ )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Command restriction toMsg BackendMsg )
updateFromFrontend sessionId clientId msg model =
    ( model, Effect.Time.now |> Task.perform (GotTimeWithUpdate sessionId clientId msg) )


updateFromFrontendWithTime : Effect.Time.Posix -> SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Command BackendOnly ToFrontend BackendMsg )
updateFromFrontendWithTime time sessionId clientId msg model =
    case msg of
        AutoSaveForm form ->
            case Types.surveyStatus of
                SurveyOpen ->
                    ( if Env.surveyIsOpen time then
                        setCurrentSurvey
                            (\survey ->
                                { survey
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
                                            survey.forms
                                }
                            )
                            model

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
                        ( setCurrentSurvey
                            (\survey ->
                                { survey
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
                                            survey.forms
                                }
                            )
                            model
                        , Effect.Lamdera.sendToFrontend clientId SubmitConfirmed
                        )

                    else
                        ( model, Command.none )

                SurveyFinished ->
                    ( model, Command.none )

        AdminLoginRequest password ->
            if Env.adminPasswordHash == Sha256.sha256 password then
                ( { model | adminLogin = Set.insert sessionId model.adminLogin }
                , getAdminData (getCurrentSurvey model)
                    |> Ok
                    |> AdminLoginResponse
                    |> Effect.Lamdera.sendToFrontend clientId
                )

            else
                ( model, Err () |> AdminLoginResponse |> Effect.Lamdera.sendToFrontend clientId )

        AdminToBackend (AdminPage.ReplaceFormsRequest ( forms, formMapping )) ->
            ( if not Env.isProduction && isAdmin sessionId model then
                setCurrentSurvey
                    (\survey ->
                        { survey
                            | forms =
                                List.indexedMap
                                    (\index form ->
                                        ( Char.fromCode index |> String.fromChar |> Effect.Lamdera.sessionIdFromString
                                        , { form = form, submitTime = Just (Effect.Time.millisToPosix 0) }
                                        )
                                    )
                                    forms
                                    |> Dict.fromList
                            , formMapping = formMapping
                        }
                    )
                    model

              else
                model
            , Command.none
            )

        AdminToBackend AdminPage.LogOutRequest ->
            if isAdmin sessionId model then
                let
                    ( survey, surveyStatus ) =
                        loadFormData sessionId time model
                in
                ( setCurrentSurvey (\_ -> survey) { model | adminLogin = Set.remove sessionId model.adminLogin }
                , Effect.Lamdera.sendToFrontend clientId (LogOutResponse surveyStatus)
                )

            else
                ( model, Command.none )

        AdminToBackend (AdminPage.EditFormMappingRequest edit) ->
            if isAdmin sessionId model then
                ( setCurrentSurvey
                    (\survey ->
                        { survey
                            | formMapping = AdminPage.networkUpdate edit survey.formMapping
                            , cachedSurveyResults = Nothing
                        }
                    )
                    model
                , Set.toList model.adminLogin
                    |> List.map
                        (\sessionId_ ->
                            AdminToFrontend (AdminPage.EditFormMappingResponse edit)
                                |> Effect.Lamdera.sendToFrontends sessionId_
                        )
                    |> Command.batch
                )

            else
                ( model, Command.none )

        AdminToBackend AdminPage.SendEmailsRequest ->
            let
                survey =
                    getCurrentSurvey model
            in
            case ( survey.sendEmailsStatus, EmailAddress.fromString "no-reply@state-of-elm.app" ) of
                ( AdminPage.EmailsNotSent, Just senderEmailAddress ) ->
                    let
                        emailAddresses =
                            List.filterMap
                                (\{ form, submitTime } ->
                                    case submitTime of
                                        Just _ ->
                                            EmailAddress.fromString form.emailAddress

                                        Nothing ->
                                            Nothing
                                )
                                (Dict.values survey.forms)
                    in
                    ( setCurrentSurvey (\_ -> { survey | sendEmailsStatus = AdminPage.Sending }) model
                    , List.map
                        (\emailAddress ->
                            SendGrid.sendEmailTask
                                Env.sendGridKey
                                (SendGrid.htmlEmail
                                    { subject = NonemptyString 'T' "he State of Elm results are out!"
                                    , content =
                                        Html.div
                                            []
                                            [ Html.text "The State of Elm survey results are ready. You can view them here "
                                            , Html.a
                                                [ Attributes.href "https://state-of-elm.lamdera.app/" ]
                                                [ Html.text "https://state-of-elm.lamdera.app/" ]
                                            ]
                                    , to = Nonempty emailAddress []
                                    , nameOfSender = "State of Elm"
                                    , emailAddressOfSender = senderEmailAddress
                                    }
                                )
                                |> Task.map (\ok -> { emailAddress = emailAddress, result = Ok ok })
                                |> Task.onError
                                    (\error ->
                                        { emailAddress = emailAddress, result = Err error }
                                            |> Task.succeed
                                    )
                        )
                        emailAddresses
                        |> Task.sequence
                        |> Task.perform (EmailsSent clientId)
                    )

                _ ->
                    ( model, Command.none )

        PreviewRequest password ->
            if password == Env.previewPassword then
                Debug.todo ""
                --formData (getCurrentSurvey model)
                --    |> Tuple.mapSecond (PreviewResponse >> Effect.Lamdera.sendToFrontend clientId)

            else
                ( model, Command.none )

        RequestFormData2023 ->
            let
                ( survey, surveyStatus ) =
                    loadFormData sessionId time model
            in
            ( setCurrentSurvey (\_ -> survey) model
            , Effect.Lamdera.sendToFrontend clientId (LoadForm surveyStatus)
            )

        RequestFormData2022 ->
            Debug.todo ""

        RequestAdminFormData ->
            Debug.todo ""


isAdmin : SessionId -> BackendModel -> Bool
isAdmin sessionId model =
    Set.member sessionId model.adminLogin
