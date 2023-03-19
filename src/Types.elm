module Types exposing (..)

import AdminPage exposing (AdminLoginData)
import AssocList exposing (Dict)
import AssocSet exposing (Set)
import Browser
import Effect.Browser.Navigation
import Effect.Lamdera exposing (ClientId, SessionId)
import Effect.Time
import EmailAddress exposing (EmailAddress)
import Env
import Form exposing (Form, FormMapping)
import Route exposing (Route, SurveyYear)
import SendGrid
import SurveyResults2022
import SurveyResults2023
import Ui exposing (Size)
import Url exposing (Url)


type FrontendModel
    = Loading LoadingData
    | Loaded LoadedData


type alias LoadedData =
    { page : Page
    , windowSize : Size
    , time : Effect.Time.Posix
    , navKey : Effect.Browser.Navigation.Key
    , route : Route
    }


type Page
    = FormLoaded FormLoaded_
    | FormCompleted
    | AdminLogin { password : String, loginFailed : Bool }
    | Admin AdminPage.Model
    | SurveyResultsLoaded SurveyResults2022.Model


type alias LoadingData =
    { windowSize : Maybe Size
    , time : Maybe Effect.Time.Posix
    , navKey : Effect.Browser.Navigation.Key
    , route : Route
    , responseData : Maybe ResponseData
    }


type ResponseData
    = LoadForm LoadFormStatus
    | LoadAdmin AdminLoginData
    | PreviewResponse SurveyResults2022.Data


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
    }


type alias BackendModel =
    { adminLogin : Set SessionId
    , survey2022 : BackendSurvey2022
    , survey2023 : BackendSurvey2023
    }


type alias BackendSurvey2022 =
    { forms : Dict SessionId { form : Form, submitTime : Maybe Effect.Time.Posix }
    , formMapping : FormMapping
    , sendEmailsStatus : AdminPage.SendEmailsStatus
    , cachedSurveyResults : Maybe SurveyResults2022.Data
    }


type alias BackendSurvey2023 =
    { forms : Dict SessionId { form : Form, submitTime : Maybe Effect.Time.Posix }
    , formMapping : FormMapping
    , sendEmailsStatus : AdminPage.SendEmailsStatus
    , cachedSurveyResults : Maybe SurveyResults2022.Data
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url
    | FormChanged Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin
    | GotWindowSize Size
    | GotTime Effect.Time.Posix
    | AdminPageMsg AdminPage.Msg
    | SurveyResultsMsg SurveyResults2022.Msg


type ToBackend
    = AutoSaveForm Form
    | SubmitForm Form
    | AdminLoginRequest String
    | AdminToBackend AdminPage.ToBackend
    | PreviewRequest String
    | RequestFormData2023
    | RequestFormData2022
    | RequestAdminFormData


type BackendMsg
    = GotTimeWithUpdate SessionId ClientId ToBackend Effect.Time.Posix
    | EmailsSent ClientId (List { emailAddress : EmailAddress, result : Result SendGrid.Error () })


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Form
    | FormSubmitted
    | SurveyResults SurveyResults2023.Data
    | AwaitingResultsData


type ToFrontend
    = AdminLoginResponse (Result () AdminLoginData)
    | SubmitConfirmed
    | LogOutResponse LoadFormStatus
    | AdminToFrontend AdminPage.ToFrontend
    | ResponseData ResponseData
