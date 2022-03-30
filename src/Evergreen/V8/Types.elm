module Evergreen.V8.Types exposing
    ( AdminLoginData
    , BackendModel
    , BackendMsg(..)
    , Form
    , FormLoaded_
    , FrontendModel(..)
    , FrontendMsg(..)
    , LoadFormStatus(..)
    , ToBackend(..)
    , ToFrontend(..)
    )

import AssocList
import AssocSet
import Browser
import Evergreen.V8.Questions
import Evergreen.V8.Ui
import Lamdera
import Time
import Url


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V8.Questions.DoYouUseElm
    , age : Maybe Evergreen.V8.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V8.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V8.Ui.MultiChoiceWithOther Evergreen.V8.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V8.Ui.MultiChoiceWithOther Evergreen.V8.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V8.Ui.MultiChoiceWithOther Evergreen.V8.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V8.Ui.MultiChoiceWithOther Evergreen.V8.Questions.WhereDoYouUseElm
    , doYouUseElmAtWork : Maybe Evergreen.V8.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V8.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V8.Ui.MultiChoiceWithOther Evergreen.V8.Questions.WhatLanguageDoYouUseForTheBackend
    , howLong : Maybe Evergreen.V8.Questions.HowLong
    , elmVersion : Evergreen.V8.Ui.MultiChoiceWithOther Evergreen.V8.Questions.WhatElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V8.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V8.Ui.MultiChoiceWithOther Evergreen.V8.Questions.StylingTools
    , buildTools : Evergreen.V8.Ui.MultiChoiceWithOther Evergreen.V8.Questions.BuildTools
    , frameworks : Evergreen.V8.Ui.MultiChoiceWithOther Evergreen.V8.Questions.Frameworks
    , editors : Evergreen.V8.Ui.MultiChoiceWithOther Evergreen.V8.Questions.Editor
    , doYouUseElmReview : Maybe Evergreen.V8.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V8.Ui.MultiChoiceWithOther Evergreen.V8.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V8.Ui.MultiChoiceWithOther Evergreen.V8.Questions.TestTools
    , testsWrittenFor : Evergreen.V8.Ui.MultiChoiceWithOther Evergreen.V8.Questions.TestsWrittenFor
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
    }


type alias AdminLoginData =
    { autoSavedSurveyCount : Int
    , submittedSurveyCount : Int
    }


type FrontendModel
    = Loading
    | FormLoaded FormLoaded_
    | FormCompleted
    | AdminLogin
        { password : String
        , loginFailed : Bool
        }
    | Admin AdminLoginData


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
    | UrlChanged Url.Url
    | FormChanged Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin


type ToBackend
    = AutoSaveForm Form
    | SubmitForm Form
    | AdminLoginRequest String


type BackendMsg
    = UserConnected Lamdera.SessionId Lamdera.ClientId
    | GotTimeWithUpdate Lamdera.SessionId Lamdera.ClientId ToBackend Time.Posix


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Form
    | FormSubmitted


type ToFrontend
    = LoadForm LoadFormStatus
    | LoadAdmin AdminLoginData
    | AdminLoginResponse (Result () AdminLoginData)
    | SubmitConfirmed
