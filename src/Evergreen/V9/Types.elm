module Evergreen.V9.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Evergreen.V9.Questions
import Evergreen.V9.Ui
import Lamdera
import Time
import Url


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V9.Questions.DoYouUseElm
    , age : Maybe Evergreen.V9.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V9.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V9.Ui.MultiChoiceWithOther Evergreen.V9.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V9.Ui.MultiChoiceWithOther Evergreen.V9.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V9.Ui.MultiChoiceWithOther Evergreen.V9.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V9.Ui.MultiChoiceWithOther Evergreen.V9.Questions.WhereDoYouUseElm
    , doYouUseElmAtWork : Maybe Evergreen.V9.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V9.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V9.Ui.MultiChoiceWithOther Evergreen.V9.Questions.WhatLanguageDoYouUseForTheBackend
    , howLong : Maybe Evergreen.V9.Questions.HowLong
    , elmVersion : Evergreen.V9.Ui.MultiChoiceWithOther Evergreen.V9.Questions.WhatElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V9.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V9.Ui.MultiChoiceWithOther Evergreen.V9.Questions.StylingTools
    , buildTools : Evergreen.V9.Ui.MultiChoiceWithOther Evergreen.V9.Questions.BuildTools
    , frameworks : Evergreen.V9.Ui.MultiChoiceWithOther Evergreen.V9.Questions.Frameworks
    , editors : Evergreen.V9.Ui.MultiChoiceWithOther Evergreen.V9.Questions.Editor
    , doYouUseElmReview : Maybe Evergreen.V9.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V9.Ui.MultiChoiceWithOther Evergreen.V9.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V9.Ui.MultiChoiceWithOther Evergreen.V9.Questions.TestTools
    , testsWrittenFor : Evergreen.V9.Ui.MultiChoiceWithOther Evergreen.V9.Questions.TestsWrittenFor
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
