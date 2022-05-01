module Evergreen.V24.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Effect.Lamdera
import Effect.Time
import Evergreen.V24.AdminPage
import Evergreen.V24.Form
import Evergreen.V24.SurveyResults
import Evergreen.V24.Ui


type alias FormLoaded_ =
    { form : Evergreen.V24.Form.Form
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    , windowSize : Evergreen.V24.Ui.Size
    , time : Effect.Time.Posix
    }


type FrontendModel
    = Loading (Maybe Evergreen.V24.Ui.Size) (Maybe Effect.Time.Posix)
    | FormLoaded FormLoaded_
    | FormCompleted Effect.Time.Posix
    | AdminLogin
        { password : String
        , loginFailed : Bool
        }
    | Admin Evergreen.V24.AdminPage.Model
    | SurveyResultsLoaded Evergreen.V24.SurveyResults.Model


type alias BackendModel =
    { forms :
        AssocList.Dict
            Effect.Lamdera.SessionId
            { form : Evergreen.V24.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V24.Form.FormMapping
    , adminLogin : AssocSet.Set Effect.Lamdera.SessionId
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged
    | FormChanged Evergreen.V24.Form.Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin
    | GotWindowSize Evergreen.V24.Ui.Size
    | GotTime Effect.Time.Posix
    | AdminPageMsg Evergreen.V24.AdminPage.Msg
    | SurveyResultsMsg Evergreen.V24.SurveyResults.Msg


type ToBackend
    = AutoSaveForm Evergreen.V24.Form.Form
    | SubmitForm Evergreen.V24.Form.Form
    | AdminLoginRequest String
    | AdminToBackend Evergreen.V24.AdminPage.ToBackend


type BackendMsg
    = UserConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | GotTimeWithLoadFormData Effect.Lamdera.SessionId Effect.Lamdera.ClientId Effect.Time.Posix
    | GotTimeWithUpdate Effect.Lamdera.SessionId Effect.Lamdera.ClientId ToBackend Effect.Time.Posix


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Evergreen.V24.Form.Form
    | FormSubmitted
    | SurveyResults Evergreen.V24.SurveyResults.Data
    | AwaitingResultsData


type ToFrontend
    = LoadForm LoadFormStatus
    | LoadAdmin Evergreen.V24.AdminPage.AdminLoginData
    | AdminLoginResponse (Result () Evergreen.V24.AdminPage.AdminLoginData)
    | SubmitConfirmed
    | LogOutResponse LoadFormStatus
    | AdminToFrontend Evergreen.V24.AdminPage.ToFrontend
