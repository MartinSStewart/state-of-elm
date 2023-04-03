module Types exposing (..)

import AdminPage exposing (AdminLoginData)
import AssocList exposing (Dict)
import AssocSet exposing (Set)
import Browser
import Effect.Browser.Navigation
import Effect.Http as Http
import Effect.Lamdera exposing (ClientId, SessionId)
import Effect.Time
import EmailAddress exposing (EmailAddress)
import Env
import Form2023 exposing (Form2023, FormMapping)
import Id exposing (Id)
import Postmark exposing (PostmarkSendResponse)
import Route exposing (Route, SurveyYear, UnsubscribeId)
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
    | AdminPage AdminPage.Model
    | SurveyResultsLoaded SurveyResults2022.Model
    | UnsubscribePage


type alias LoadingData =
    { windowSize : Maybe Size
    , time : Maybe Effect.Time.Posix
    , navKey : Effect.Browser.Navigation.Key
    , route : Route
    , responseData : Maybe ResponseData
    }


type ResponseData
    = LoadForm2022 SurveyResults2022.Data
    | LoadForm2023 LoadFormStatus2023
    | LoadAdmin (Maybe AdminLoginData)
    | UnsubscribeResponse


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
    { form : Form2023
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    }


type alias BackendModel =
    { adminLogin : Set SessionId
    , survey2022 : BackendSurvey2022
    , survey2023 : BackendSurvey2023
    , subscribedEmails :
        Dict
            (Id UnsubscribeId)
            { emailAddress : EmailAddress
            , announcementEmail : Dict SurveyYear (Result Http.Error PostmarkSendResponse)
            }
    , secretCounter : Int
    }


type alias BackendSurvey2022 =
    { forms : Dict SessionId { form : Form2023, submitTime : Maybe Effect.Time.Posix }
    , formMapping : FormMapping
    , sendEmailsStatus : AdminPage.SendEmailsStatus
    , cachedSurveyResults : Maybe SurveyResults2022.Data
    }


type alias BackendSurvey2023 =
    { forms : Dict SessionId { form : Form2023, submitTime : Maybe Effect.Time.Posix }
    , formMapping : FormMapping
    , sendEmailsStatus : AdminPage.SendEmailsStatus
    , cachedSurveyResults : Maybe SurveyResults2022.Data
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url
    | FormChanged Form2023
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
    = AutoSaveForm Form2023
    | SubmitForm Form2023
    | AdminLoginRequest String
    | AdminToBackend AdminPage.ToBackend
    | RequestFormData2023
    | RequestFormData2022
    | RequestAdminFormData
    | UnsubscribeRequest (Id UnsubscribeId)


type BackendMsg
    = GotTimeWithUpdate SessionId ClientId ToBackend Effect.Time.Posix
    | EmailsSent ClientId (List { emailAddress : EmailAddress, result : Result SendGrid.Error () })


type LoadFormStatus2023
    = NoFormFound
    | FormAutoSaved Form2023
    | FormSubmitted
    | SurveyResults SurveyResults2023.Data
    | AwaitingResultsData


type ToFrontend
    = AdminLoginResponse (Result () AdminLoginData)
    | SubmitConfirmed
    | LogOutResponse LoadFormStatus2023
    | AdminToFrontend AdminPage.ToFrontend
    | ResponseData ResponseData
