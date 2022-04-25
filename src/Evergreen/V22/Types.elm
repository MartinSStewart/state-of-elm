module Evergreen.V22.Types exposing (..)

import AssocList
import Browser
import Effect.Lamdera
import Effect.Time
import Evergreen.V22.AdminPage
import Evergreen.V22.Form
import Evergreen.V22.SurveyResults
import Evergreen.V22.Ui


type alias FormLoaded_ =
    { form : Evergreen.V22.Form.Form
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    , windowSize : Evergreen.V22.Ui.Size
    , time : Effect.Time.Posix
    }


type FrontendModel
    = Loading (Maybe Evergreen.V22.Ui.Size) (Maybe Effect.Time.Posix)
    | FormLoaded FormLoaded_
    | FormCompleted Effect.Time.Posix
    | AdminLogin
        { password : String
        , loginFailed : Bool
        }
    | Admin Evergreen.V22.AdminPage.Model
    | SurveyResultsLoaded Evergreen.V22.SurveyResults.Model


type alias BackendModel =
    { forms :
        AssocList.Dict
            Effect.Lamdera.SessionId
            { form : Evergreen.V22.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , answerMap : Evergreen.V22.Form.FormOtherQuestions
    , adminLogin : Maybe Effect.Lamdera.SessionId
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged
    | FormChanged Evergreen.V22.Form.Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin
    | GotWindowSize Evergreen.V22.Ui.Size
    | GotTime Effect.Time.Posix
    | AdminPageMsg Evergreen.V22.AdminPage.Msg


type ToBackend
    = AutoSaveForm Evergreen.V22.Form.Form
    | SubmitForm Evergreen.V22.Form.Form
    | AdminLoginRequest String
    | AdminToBackend Evergreen.V22.AdminPage.ToBackend


type BackendMsg
    = UserConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | GotTimeWithLoadFormData Effect.Lamdera.SessionId Effect.Lamdera.ClientId Effect.Time.Posix
    | GotTimeWithUpdate Effect.Lamdera.SessionId Effect.Lamdera.ClientId ToBackend Effect.Time.Posix


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Evergreen.V22.Form.Form
    | FormSubmitted
    | SurveyResults Evergreen.V22.SurveyResults.Data
    | AwaitingResultsData


type ToFrontend
    = LoadForm LoadFormStatus
    | LoadAdmin Evergreen.V22.AdminPage.AdminLoginData
    | AdminLoginResponse (Result () Evergreen.V22.AdminPage.AdminLoginData)
    | SubmitConfirmed
    | LogOutResponse LoadFormStatus
