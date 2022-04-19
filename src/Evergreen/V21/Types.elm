module Evergreen.V21.Types exposing (..)

import AssocList
import Browser
import Effect.Lamdera
import Effect.Time
import Evergreen.V21.AdminPage
import Evergreen.V21.Form
import Evergreen.V21.SurveyResults
import Evergreen.V21.Ui


type alias FormLoaded_ =
    { form : Evergreen.V21.Form.Form
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    , windowSize : Evergreen.V21.Ui.Size
    , time : Effect.Time.Posix
    }


type FrontendModel
    = Loading (Maybe Evergreen.V21.Ui.Size) (Maybe Effect.Time.Posix)
    | FormLoaded FormLoaded_
    | FormCompleted Effect.Time.Posix
    | AdminLogin
        { password : String
        , loginFailed : Bool
        }
    | Admin Evergreen.V21.AdminPage.AdminLoginData
    | SurveyResultsLoaded Evergreen.V21.SurveyResults.Data


type alias BackendModel =
    { forms :
        AssocList.Dict
            Effect.Lamdera.SessionId
            { form : Evergreen.V21.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V21.Form.FormMapping
    , adminLogin : Maybe Effect.Lamdera.SessionId
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged
    | FormChanged Evergreen.V21.Form.Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin
    | GotWindowSize Evergreen.V21.Ui.Size
    | GotTime Effect.Time.Posix
    | AdminPageMsg Evergreen.V21.AdminPage.Msg


type ToBackend
    = AutoSaveForm Evergreen.V21.Form.Form
    | SubmitForm Evergreen.V21.Form.Form
    | AdminLoginRequest String
    | AdminToBackend Evergreen.V21.AdminPage.ToBackend


type BackendMsg
    = UserConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | GotTimeWithLoadFormData Effect.Lamdera.SessionId Effect.Lamdera.ClientId Effect.Time.Posix
    | GotTimeWithUpdate Effect.Lamdera.SessionId Effect.Lamdera.ClientId ToBackend Effect.Time.Posix


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Evergreen.V21.Form.Form
    | FormSubmitted
    | SurveyResults Evergreen.V21.SurveyResults.Data
    | AwaitingResultsData


type ToFrontend
    = LoadForm LoadFormStatus
    | LoadAdmin Evergreen.V21.AdminPage.AdminLoginData
    | AdminLoginResponse (Result () Evergreen.V21.AdminPage.AdminLoginData)
    | SubmitConfirmed
    | LogOutResponse LoadFormStatus
