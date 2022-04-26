module Evergreen.V23.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Effect.Lamdera
import Effect.Time
import Evergreen.V23.AdminPage
import Evergreen.V23.Form
import Evergreen.V23.SurveyResults
import Evergreen.V23.Ui


type alias FormLoaded_ =
    { form : Evergreen.V23.Form.Form
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    , windowSize : Evergreen.V23.Ui.Size
    , time : Effect.Time.Posix
    }


type FrontendModel
    = Loading (Maybe Evergreen.V23.Ui.Size) (Maybe Effect.Time.Posix)
    | FormLoaded FormLoaded_
    | FormCompleted Effect.Time.Posix
    | AdminLogin
        { password : String
        , loginFailed : Bool
        }
    | Admin Evergreen.V23.AdminPage.Model
    | SurveyResultsLoaded Evergreen.V23.SurveyResults.Model


type alias BackendModel =
    { forms :
        AssocList.Dict
            Effect.Lamdera.SessionId
            { form : Evergreen.V23.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , answerMap : Evergreen.V23.Form.FormMapping
    , adminLogin : AssocSet.Set Effect.Lamdera.SessionId
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged
    | FormChanged Evergreen.V23.Form.Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin
    | GotWindowSize Evergreen.V23.Ui.Size
    | GotTime Effect.Time.Posix
    | AdminPageMsg Evergreen.V23.AdminPage.Msg


type ToBackend
    = AutoSaveForm Evergreen.V23.Form.Form
    | SubmitForm Evergreen.V23.Form.Form
    | AdminLoginRequest String
    | AdminToBackend Evergreen.V23.AdminPage.ToBackend


type BackendMsg
    = UserConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | GotTimeWithLoadFormData Effect.Lamdera.SessionId Effect.Lamdera.ClientId Effect.Time.Posix
    | GotTimeWithUpdate Effect.Lamdera.SessionId Effect.Lamdera.ClientId ToBackend Effect.Time.Posix


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Evergreen.V23.Form.Form
    | FormSubmitted
    | SurveyResults Evergreen.V23.SurveyResults.Data
    | AwaitingResultsData


type ToFrontend
    = LoadForm LoadFormStatus
    | LoadAdmin Evergreen.V23.AdminPage.AdminLoginData
    | AdminLoginResponse (Result () Evergreen.V23.AdminPage.AdminLoginData)
    | SubmitConfirmed
    | LogOutResponse LoadFormStatus
    | AdminToFrontend Evergreen.V23.AdminPage.ToFrontend
