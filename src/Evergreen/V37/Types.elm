module Evergreen.V37.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Effect.Lamdera
import Effect.Time
import Evergreen.V37.AdminPage
import Evergreen.V37.EmailAddress
import Evergreen.V37.Form
import Evergreen.V37.SendGrid
import Evergreen.V37.SurveyResults
import Evergreen.V37.Ui


type alias LoadingData =
    { windowSize : Maybe Evergreen.V37.Ui.Size
    , time : Maybe Effect.Time.Posix
    }


type alias FormLoaded_ =
    { form : Evergreen.V37.Form.Form
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    , windowSize : Evergreen.V37.Ui.Size
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
    | Admin Evergreen.V37.AdminPage.Model
    | SurveyResultsLoaded Evergreen.V37.SurveyResults.Model


type alias BackendModel =
    { forms :
        AssocList.Dict
            Effect.Lamdera.SessionId
            { form : Evergreen.V37.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V37.Form.FormMapping
    , adminLogin : AssocSet.Set Effect.Lamdera.SessionId
    , sendEmailsStatus : Evergreen.V37.AdminPage.SendEmailsStatus
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged
    | FormChanged Evergreen.V37.Form.Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin
    | GotWindowSize Evergreen.V37.Ui.Size
    | GotTime Effect.Time.Posix
    | AdminPageMsg Evergreen.V37.AdminPage.Msg
    | SurveyResultsMsg Evergreen.V37.SurveyResults.Msg


type ToBackend
    = AutoSaveForm Evergreen.V37.Form.Form
    | SubmitForm Evergreen.V37.Form.Form
    | AdminLoginRequest String
    | AdminToBackend Evergreen.V37.AdminPage.ToBackend
    | PreviewRequest String


type BackendMsg
    = UserConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | GotTimeWithLoadFormData Effect.Lamdera.SessionId Effect.Lamdera.ClientId Effect.Time.Posix
    | GotTimeWithUpdate Effect.Lamdera.SessionId Effect.Lamdera.ClientId ToBackend Effect.Time.Posix
    | EmailsSent
        Effect.Lamdera.ClientId
        (List
            { emailAddress : Evergreen.V37.EmailAddress.EmailAddress
            , result : Result Evergreen.V37.SendGrid.Error ()
            }
        )


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Evergreen.V37.Form.Form
    | FormSubmitted
    | SurveyResults Evergreen.V37.SurveyResults.Data
    | AwaitingResultsData


type ToFrontend
    = LoadForm LoadFormStatus
    | LoadAdmin Evergreen.V37.AdminPage.AdminLoginData
    | AdminLoginResponse (Result () Evergreen.V37.AdminPage.AdminLoginData)
    | SubmitConfirmed
    | LogOutResponse LoadFormStatus
    | AdminToFrontend Evergreen.V37.AdminPage.ToFrontend
    | PreviewResponse Evergreen.V37.SurveyResults.Data
