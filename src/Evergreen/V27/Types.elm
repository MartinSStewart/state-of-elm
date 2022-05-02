module Evergreen.V27.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Effect.Lamdera
import Effect.Time
import Evergreen.V27.AdminPage
import Evergreen.V27.Form
import Evergreen.V27.SurveyResults
import Evergreen.V27.Ui


type alias LoadingData =
    { windowSize : Maybe Evergreen.V27.Ui.Size
    , time : Maybe Effect.Time.Posix
    }


type alias FormLoaded_ =
    { form : Evergreen.V27.Form.Form
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    , windowSize : Evergreen.V27.Ui.Size
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
    | Admin Evergreen.V27.AdminPage.Model
    | SurveyResultsLoaded Evergreen.V27.SurveyResults.Model


type alias BackendModel =
    { forms :
        AssocList.Dict
            Effect.Lamdera.SessionId
            { form : Evergreen.V27.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V27.Form.FormMapping
    , adminLogin : AssocSet.Set Effect.Lamdera.SessionId
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged
    | FormChanged Evergreen.V27.Form.Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin
    | GotWindowSize Evergreen.V27.Ui.Size
    | GotTime Effect.Time.Posix
    | AdminPageMsg Evergreen.V27.AdminPage.Msg
    | SurveyResultsMsg Evergreen.V27.SurveyResults.Msg


type ToBackend
    = AutoSaveForm Evergreen.V27.Form.Form
    | SubmitForm Evergreen.V27.Form.Form
    | AdminLoginRequest String
    | AdminToBackend Evergreen.V27.AdminPage.ToBackend
    | PreviewRequest String


type BackendMsg
    = UserConnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | GotTimeWithLoadFormData Effect.Lamdera.SessionId Effect.Lamdera.ClientId Effect.Time.Posix
    | GotTimeWithUpdate Effect.Lamdera.SessionId Effect.Lamdera.ClientId ToBackend Effect.Time.Posix


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Evergreen.V27.Form.Form
    | FormSubmitted
    | SurveyResults Evergreen.V27.SurveyResults.Data
    | AwaitingResultsData


type ToFrontend
    = LoadForm LoadFormStatus
    | LoadAdmin Evergreen.V27.AdminPage.AdminLoginData
    | AdminLoginResponse (Result () Evergreen.V27.AdminPage.AdminLoginData)
    | SubmitConfirmed
    | LogOutResponse LoadFormStatus
    | AdminToFrontend Evergreen.V27.AdminPage.ToFrontend
    | PreviewResponse Evergreen.V27.SurveyResults.Data
