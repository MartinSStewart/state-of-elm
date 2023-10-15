module Types exposing (..)

import AdminPage exposing (AdminLoginData, AiCategorizationStatus)
import AssocList exposing (Dict)
import AssocSet exposing (Set)
import Browser
import Duration
import Effect.Browser.Navigation
import Effect.File exposing (File)
import Effect.Http as Http
import Effect.Lamdera exposing (ClientId, SessionId)
import Effect.Time
import EmailAddress exposing (EmailAddress)
import Env
import Form2022 exposing (Form2022)
import Form2023 exposing (Form2023, FormMapping, SpecificQuestion)
import Id exposing (Id)
import List.Nonempty exposing (Nonempty)
import Postmark exposing (PostmarkSendResponse)
import Quantity
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
    , surveyResults2022 : SurveyResults2022.Data
    }


type Page
    = FormLoaded Form2023Loaded_
    | FormCompleted
    | AdminLogin { password : String, loginFailed : Bool }
    | AdminPage AdminPage.Model
    | SurveyResults2023Page SurveyResults2023.Model
    | SurveyResults2022Page SurveyResults2022.Model
    | UnsubscribePage
    | ErrorPage


type alias LoadingData =
    { windowSize : Maybe Size
    , time : Maybe Effect.Time.Posix
    , navKey : Effect.Browser.Navigation.Key
    , route : Route
    , responseData : Maybe ( ResponseData, SurveyResults2022.Data )
    }


type ResponseData
    = LoadForm2023 LoadFormStatus2023
    | LoadAdmin (Maybe AdminLoginData)
    | UnsubscribeResponse


type SurveyStatus
    = SurveyOpen
    | SurveyFinished


surveyStatus : Effect.Time.Posix -> SurveyStatus
surveyStatus currentTime =
    if Duration.from Env.presentResultsTime currentTime |> Quantity.lessThanZero then
        SurveyOpen

    else if Env.canShowLatestResults then
        SurveyFinished

    else
        SurveyOpen


type alias Form2023Loaded_ =
    { form : Form2023
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    , elmJsonTextInput : String
    , elmJsonError : Maybe String
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
    { forms : Dict SessionId { form : Form2022, submitTime : Maybe Effect.Time.Posix }
    , formMapping : Form2022.FormMapping
    , sendEmailsStatus : AdminPage.SendEmailsStatus
    , cachedSurveyResults : Maybe SurveyResults2022.Data
    }


type alias BackendSurvey2023 =
    { forms : Dict SessionId { form : Form2023, submitTime : Maybe Effect.Time.Posix }
    , formMapping : FormMapping
    , sendEmailsStatus : AdminPage.SendEmailsStatus
    , cachedSurveyResults : Maybe SurveyResults2023.Data
    , aiCategorization : AssocList.Dict SpecificQuestion AiCategorizationStatus
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
    | SurveyResults2022Msg SurveyResults2022.Msg
    | SurveyResults2023Msg SurveyResults2023.Msg
    | PressedSelectElmJsonFiles
    | SelectedElmJsonFiles File (List File)
    | GotElmJsonFilesContent (List String)
    | TypedElmJsonFile String
    | PressedRemoveElmJson Int


type ToBackend
    = AutoSaveForm Form2023
    | SubmitForm Form2023
    | AdminLoginRequest String
    | AdminToBackend AdminPage.ToBackend
    | RequestFormData2023
    | RequestAdminFormData
    | UnsubscribeRequest (Id UnsubscribeId)


type BackendMsg
    = GotTimeWithUpdate SessionId ClientId ToBackend Effect.Time.Posix
    | EmailsSent ClientId (List { emailAddress : EmailAddress, result : Result SendGrid.Error () })
    | GotAiCompletion SpecificQuestion (List { answer : String, categorizedAs : Result Http.Error (Nonempty String) })


type alias AiCategorizations =
    { otherMapping : List { groupName : String, otherAnswers : Set String } }


type LoadFormStatus2023
    = NoFormFound
    | FormAutoSaved Form2023
    | FormSubmitted
    | SurveyResults2023 SurveyResults2023.Data
    | AwaitingResultsData


type ToFrontend
    = AdminLoginResponse (Result () AdminLoginData)
    | SubmitConfirmed
    | LogOutResponse LoadFormStatus2023
    | AdminToFrontend AdminPage.ToFrontend
    | ResponseData ResponseData SurveyResults2022.Data
