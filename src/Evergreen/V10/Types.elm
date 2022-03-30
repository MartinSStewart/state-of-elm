module Evergreen.V10.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Evergreen.V10.Questions
import Evergreen.V10.Ui
import Lamdera
import Time


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V10.Questions.DoYouUseElm
    , age : Maybe Evergreen.V10.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V10.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V10.Ui.MultiChoiceWithOther Evergreen.V10.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V10.Ui.MultiChoiceWithOther Evergreen.V10.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V10.Ui.MultiChoiceWithOther Evergreen.V10.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V10.Ui.MultiChoiceWithOther Evergreen.V10.Questions.WhereDoYouUseElm
    , doYouUseElmAtWork : Maybe Evergreen.V10.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V10.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V10.Ui.MultiChoiceWithOther Evergreen.V10.Questions.WhatLanguageDoYouUseForTheBackend
    , howLong : Maybe Evergreen.V10.Questions.HowLong
    , elmVersion : Evergreen.V10.Ui.MultiChoiceWithOther Evergreen.V10.Questions.WhatElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V10.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V10.Ui.MultiChoiceWithOther Evergreen.V10.Questions.StylingTools
    , buildTools : Evergreen.V10.Ui.MultiChoiceWithOther Evergreen.V10.Questions.BuildTools
    , frameworks : Evergreen.V10.Ui.MultiChoiceWithOther Evergreen.V10.Questions.Frameworks
    , editors : Evergreen.V10.Ui.MultiChoiceWithOther Evergreen.V10.Questions.Editor
    , doYouUseElmReview : Maybe Evergreen.V10.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V10.Ui.MultiChoiceWithOther Evergreen.V10.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V10.Ui.MultiChoiceWithOther Evergreen.V10.Questions.TestTools
    , testsWrittenFor : Evergreen.V10.Ui.MultiChoiceWithOther Evergreen.V10.Questions.TestsWrittenFor
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
    | UrlChanged
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
