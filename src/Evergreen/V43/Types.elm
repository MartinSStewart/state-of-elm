module Evergreen.V43.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Effect.Browser.Navigation
import Effect.File
import Effect.Http
import Effect.Lamdera
import Effect.Time
import Evergreen.V43.AdminPage
import Evergreen.V43.EmailAddress
import Evergreen.V43.Form2022
import Evergreen.V43.Form2023
import Evergreen.V43.Id
import Evergreen.V43.Postmark
import Evergreen.V43.Route
import Evergreen.V43.SendGrid
import Evergreen.V43.SurveyResults2022
import Evergreen.V43.SurveyResults2023
import Evergreen.V43.Ui
import Url


type LoadFormStatus2023
    = NoFormFound
    | FormAutoSaved Evergreen.V43.Form2023.Form2023
    | FormSubmitted
    | SurveyResults2023 Evergreen.V43.SurveyResults2023.Data
    | AwaitingResultsData


type ResponseData
    = LoadForm2023 LoadFormStatus2023
    | LoadAdmin (Maybe Evergreen.V43.AdminPage.AdminLoginData)
    | UnsubscribeResponse


type alias LoadingData =
    { windowSize : Maybe Evergreen.V43.Ui.Size
    , time : Maybe Effect.Time.Posix
    , navKey : Effect.Browser.Navigation.Key
    , route : Evergreen.V43.Route.Route
    , responseData : Maybe ( ResponseData, Evergreen.V43.SurveyResults2022.Data )
    }


type alias Form2023Loaded_ =
    { form : Evergreen.V43.Form2023.Form2023
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    , elmJsonTextInput : String
    , elmJsonError : Maybe String
    }


type Page
    = FormLoaded Form2023Loaded_
    | FormCompleted
    | AdminLogin
        { password : String
        , loginFailed : Bool
        }
    | AdminPage Evergreen.V43.AdminPage.Model
    | SurveyResults2023Page Evergreen.V43.SurveyResults2023.Model
    | SurveyResults2022Page Evergreen.V43.SurveyResults2022.Model
    | UnsubscribePage
    | ErrorPage


type alias LoadedData =
    { page : Page
    , windowSize : Evergreen.V43.Ui.Size
    , time : Effect.Time.Posix
    , navKey : Effect.Browser.Navigation.Key
    , route : Evergreen.V43.Route.Route
    , surveyResults2022 : Evergreen.V43.SurveyResults2022.Data
    }


type FrontendModel
    = Loading LoadingData
    | Loaded LoadedData


type alias BackendSurvey2022 =
    { forms :
        AssocList.Dict
            Effect.Lamdera.SessionId
            { form : Evergreen.V43.Form2022.Form2022
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V43.Form2022.FormMapping
    , sendEmailsStatus : Evergreen.V43.AdminPage.SendEmailsStatus
    , cachedSurveyResults : Maybe Evergreen.V43.SurveyResults2022.Data
    }


type alias BackendSurvey2023 =
    { forms :
        AssocList.Dict
            Effect.Lamdera.SessionId
            { form : Evergreen.V43.Form2023.Form2023
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V43.Form2023.FormMapping
    , sendEmailsStatus : Evergreen.V43.AdminPage.SendEmailsStatus
    , cachedSurveyResults : Maybe Evergreen.V43.SurveyResults2023.Data
    }


type alias BackendModel =
    { adminLogin : AssocSet.Set Effect.Lamdera.SessionId
    , survey2022 : BackendSurvey2022
    , survey2023 : BackendSurvey2023
    , subscribedEmails :
        AssocList.Dict
            (Evergreen.V43.Id.Id Evergreen.V43.Route.UnsubscribeId)
            { emailAddress : Evergreen.V43.EmailAddress.EmailAddress
            , announcementEmail : AssocList.Dict Evergreen.V43.Route.SurveyYear (Result Effect.Http.Error Evergreen.V43.Postmark.PostmarkSendResponse)
            }
    , secretCounter : Int
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | FormChanged Evergreen.V43.Form2023.Form2023
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin
    | GotWindowSize Evergreen.V43.Ui.Size
    | GotTime Effect.Time.Posix
    | AdminPageMsg Evergreen.V43.AdminPage.Msg
    | SurveyResults2022Msg Evergreen.V43.SurveyResults2022.Msg
    | SurveyResults2023Msg Evergreen.V43.SurveyResults2023.Msg
    | PressedSelectElmJsonFiles
    | SelectedElmJsonFiles Effect.File.File (List Effect.File.File)
    | GotElmJsonFilesContent (List String)
    | TypedElmJsonFile String
    | PressedRemoveElmJson Int


type ToBackend
    = AutoSaveForm Evergreen.V43.Form2023.Form2023
    | SubmitForm Evergreen.V43.Form2023.Form2023
    | AdminLoginRequest String
    | AdminToBackend Evergreen.V43.AdminPage.ToBackend
    | RequestFormData2023
    | RequestAdminFormData
    | UnsubscribeRequest (Evergreen.V43.Id.Id Evergreen.V43.Route.UnsubscribeId)


type BackendMsg
    = GotTimeWithUpdate Effect.Lamdera.SessionId Effect.Lamdera.ClientId ToBackend Effect.Time.Posix
    | EmailsSent
        Effect.Lamdera.ClientId
        (List
            { emailAddress : Evergreen.V43.EmailAddress.EmailAddress
            , result : Result Evergreen.V43.SendGrid.Error ()
            }
        )


type ToFrontend
    = AdminLoginResponse (Result () Evergreen.V43.AdminPage.AdminLoginData)
    | SubmitConfirmed
    | LogOutResponse LoadFormStatus2023
    | AdminToFrontend Evergreen.V43.AdminPage.ToFrontend
    | ResponseData ResponseData Evergreen.V43.SurveyResults2022.Data
