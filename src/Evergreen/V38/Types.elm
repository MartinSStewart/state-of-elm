module Evergreen.V38.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Effect.Lamdera
import Effect.Time
import Evergreen.V38.AdminPage
import Evergreen.V38.EmailAddress
import Evergreen.V38.Form
import Evergreen.V38.SendGrid
import Evergreen.V38.SurveyResults
import Evergreen.V38.Ui


type alias LoadingData =
    { windowSize : Maybe Evergreen.V38.Ui.Size
    , time : Maybe Effect.Time.Posix
    }


type alias FormLoaded_ =
    { form : Evergreen.V38.Form.Form
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    , windowSize : Evergreen.V38.Ui.Size
    , time : Effect.Time.Posix
    }


type FrontendModel
    = Loading LoadingData
    | FormLoaded FormLoaded_
    | FormCompleted Effect.Time.Posix
    | AdminLogin
        { password : String
        , loginFailed : Bool
        }
    | Admin Evergreen.V38.AdminPage.Model
    | SurveyResultsLoaded Evergreen.V38.SurveyResults.Model


type alias BackendModel =
    { forms :
        AssocList.Dict
            Effect.Lamdera.SessionId
            { form : Evergreen.V38.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V38.Form.FormMapping
    , adminLogin : AssocSet.Set Effect.Lamdera.SessionId
    , sendEmailsStatus : Evergreen.V38.AdminPage.SendEmailsStatus
    , cachedSurveyResults : Maybe Evergreen.V38.SurveyResults.Data
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged
    | FormChanged Evergreen.V38.Form.Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin
    | GotWindowSize Evergreen.V38.Ui.Size
    | GotTime Effect.Time.Posix
    | AdminPageMsg Evergreen.V38.AdminPage.Msg
    | SurveyResultsMsg Evergreen.V38.SurveyResults.Msg


type ToBackend
    = AutoSaveForm Evergreen.V38.Form.Form
    | SubmitForm Evergreen.V38.Form.Form
    | AdminLoginRequest String
    | AdminToBackend Evergreen.V38.AdminPage.ToBackend
    | PreviewRequest String


type BackendMsg
    = UserConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | GotTimeWithLoadFormData Effect.Lamdera.SessionId Effect.Lamdera.ClientId Effect.Time.Posix
    | GotTimeWithUpdate Effect.Lamdera.SessionId Effect.Lamdera.ClientId ToBackend Effect.Time.Posix
    | EmailsSent
        Effect.Lamdera.ClientId
        (List
            { emailAddress : Evergreen.V38.EmailAddress.EmailAddress
            , result : Result Evergreen.V38.SendGrid.Error ()
            }
        )


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Evergreen.V38.Form.Form
    | FormSubmitted
    | SurveyResults Evergreen.V38.SurveyResults.Data
    | AwaitingResultsData


type ToFrontend
    = LoadForm LoadFormStatus
    | LoadAdmin Evergreen.V38.AdminPage.AdminLoginData
    | AdminLoginResponse (Result () Evergreen.V38.AdminPage.AdminLoginData)
    | SubmitConfirmed
    | LogOutResponse LoadFormStatus
    | AdminToFrontend Evergreen.V38.AdminPage.ToFrontend
    | PreviewResponse Evergreen.V38.SurveyResults.Data
