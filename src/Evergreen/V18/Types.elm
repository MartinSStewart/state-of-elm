module Evergreen.V18.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Evergreen.V18.Questions
import Evergreen.V18.SurveyResults
import Evergreen.V18.Ui
import Lamdera
import Time


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V18.Questions.DoYouUseElm
    , age : Maybe Evergreen.V18.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V18.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V18.Ui.MultiChoiceWithOther Evergreen.V18.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V18.Ui.MultiChoiceWithOther Evergreen.V18.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V18.Ui.MultiChoiceWithOther Evergreen.V18.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V18.Ui.MultiChoiceWithOther Evergreen.V18.Questions.WhereDoYouUseElm
    , doYouUseElmAtWork : Maybe Evergreen.V18.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V18.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V18.Ui.MultiChoiceWithOther Evergreen.V18.Questions.WhatLanguageDoYouUseForTheBackend
    , howLong : Maybe Evergreen.V18.Questions.HowLong
    , elmVersion : Evergreen.V18.Ui.MultiChoiceWithOther Evergreen.V18.Questions.WhatElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V18.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V18.Ui.MultiChoiceWithOther Evergreen.V18.Questions.StylingTools
    , buildTools : Evergreen.V18.Ui.MultiChoiceWithOther Evergreen.V18.Questions.BuildTools
    , frameworks : Evergreen.V18.Ui.MultiChoiceWithOther Evergreen.V18.Questions.Frameworks
    , editors : Evergreen.V18.Ui.MultiChoiceWithOther Evergreen.V18.Questions.Editor
    , doYouUseElmReview : Maybe Evergreen.V18.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V18.Ui.MultiChoiceWithOther Evergreen.V18.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V18.Ui.MultiChoiceWithOther Evergreen.V18.Questions.TestTools
    , testsWrittenFor : Evergreen.V18.Ui.MultiChoiceWithOther Evergreen.V18.Questions.TestsWrittenFor
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
    , emailAddress : String
    }


type alias FormLoaded_ =
    { form : Form
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    , windowSize : Evergreen.V18.Ui.Size
    , time : Time.Posix
    }


type alias AdminLoginData =
    { forms :
        List
            { form : Form
            , submitTime : Maybe Time.Posix
            }
    }


type FrontendModel
    = Loading (Maybe Evergreen.V18.Ui.Size) (Maybe Time.Posix)
    | FormLoaded FormLoaded_
    | FormCompleted Time.Posix
    | AdminLogin
        { password : String
        , loginFailed : Bool
        }
    | Admin AdminLoginData
    | SurveyResultsLoaded Evergreen.V18.SurveyResults.Data


type alias BackendModel =
    { forms :
        AssocList.Dict
            Lamdera.SessionId
            { form : Form
            , submitTime : Maybe Time.Posix
            }
    , adminLogin : Maybe Lamdera.SessionId
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged
    | FormChanged Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin
    | GotWindowSize Evergreen.V18.Ui.Size
    | TypedFormsData String
    | PressedLogOut
    | GotTime Time.Posix


type ToBackend
    = AutoSaveForm Form
    | SubmitForm Form
    | AdminLoginRequest String
    | ReplaceFormsRequest (List Form)
    | LogOutRequest


type BackendMsg
    = UserConnected Lamdera.SessionId Lamdera.ClientId
    | GotTimeWithLoadFormData Lamdera.SessionId Lamdera.ClientId Time.Posix
    | GotTimeWithUpdate Lamdera.SessionId Lamdera.ClientId ToBackend Time.Posix


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Form
    | FormSubmitted
    | SurveyResults Evergreen.V18.SurveyResults.Data
    | AwaitingResultsData


type ToFrontend
    = LoadForm LoadFormStatus
    | LoadAdmin AdminLoginData
    | AdminLoginResponse (Result () AdminLoginData)
    | SubmitConfirmed
    | LogOutResponse LoadFormStatus
