module Types exposing (..)

import AdminPage exposing (AdminLoginData)
import AnswerMap exposing (AnswerMap)
import AssocList exposing (Dict)
import Browser exposing (UrlRequest)
import Effect.Lamdera exposing (ClientId, SessionId)
import Effect.Time
import Env
import Form exposing (Form, FormOtherQuestions)
import SurveyResults
import Ui exposing (MultiChoiceWithOther, Size)


type FrontendModel
    = Loading (Maybe Size) (Maybe Effect.Time.Posix)
    | FormLoaded FormLoaded_
    | FormCompleted Effect.Time.Posix
    | AdminLogin { password : String, loginFailed : Bool }
    | Admin AdminPage.Model
    | SurveyResultsLoaded SurveyResults.Model


type SurveyStatus
    = SurveyOpen
    | SurveyFinished


surveyStatus : SurveyStatus
surveyStatus =
    if Env.presentSurveyResults then
        SurveyFinished

    else
        SurveyOpen


type alias FormLoaded_ =
    { form : Form
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    , windowSize : Size
    , time : Effect.Time.Posix
    }


type alias BackendModel =
    { forms : Dict SessionId { form : Form, submitTime : Maybe Effect.Time.Posix }
    , answerMap : FormOtherQuestions
    , adminLogin : Maybe SessionId
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged
    | FormChanged Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin
    | GotWindowSize Size
    | GotTime Effect.Time.Posix
    | AdminPageMsg AdminPage.Msg


type ToBackend
    = AutoSaveForm Form
    | SubmitForm Form
    | AdminLoginRequest String
    | AdminToBackend AdminPage.ToBackend


type BackendMsg
    = UserConnected SessionId ClientId
    | GotTimeWithLoadFormData SessionId ClientId Effect.Time.Posix
    | GotTimeWithUpdate SessionId ClientId ToBackend Effect.Time.Posix


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Form
    | FormSubmitted
    | SurveyResults SurveyResults.Data
    | AwaitingResultsData


type ToFrontend
    = LoadForm LoadFormStatus
    | LoadAdmin AdminLoginData
    | AdminLoginResponse (Result () AdminLoginData)
    | SubmitConfirmed
    | LogOutResponse LoadFormStatus
