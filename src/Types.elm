module Types exposing (..)

import AdminPage exposing (AdminLoginData)
import AssocList exposing (Dict)
import AssocSet exposing (Set)
import Browser exposing (UrlRequest)
import Form exposing (Form, FormMapping)
import Lamdera exposing (ClientId, SessionId)
import SurveyResults
import Time
import Ui exposing (MultiChoiceWithOther, Size)


type FrontendModel
    = Loading (Maybe Size) (Maybe Time.Posix)
    | FormLoaded FormLoaded_
    | FormCompleted Time.Posix
    | AdminLogin { password : String, loginFailed : Bool }
    | Admin AdminLoginData
    | SurveyResultsLoaded SurveyResults.Data


type SurveyStatus
    = SurveyOpen
    | SurveyFinished


type alias FormLoaded_ =
    { form : Form
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    , windowSize : Size
    , time : Time.Posix
    }


type alias BackendModel =
    { forms : Dict SessionId { form : Form, submitTime : Maybe Time.Posix }
    , formMapping : FormMapping
    , adminLogin : Maybe SessionId
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged
    | FormChanged Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin
    | GotWindowSize Size
    | TypedFormsData String
    | PressedLogOut
    | GotTime Time.Posix
    | AdminPageMsg AdminPage.Msg


type ToBackend
    = AutoSaveForm Form
    | SubmitForm Form
    | AdminLoginRequest String
    | ReplaceFormsRequest (List Form)
    | LogOutRequest


type BackendMsg
    = UserConnected SessionId ClientId
    | GotTimeWithLoadFormData SessionId ClientId Time.Posix
    | GotTimeWithUpdate SessionId ClientId ToBackend Time.Posix


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
