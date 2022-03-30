module Evergreen.V12.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Evergreen.V12.Questions
import Evergreen.V12.Ui
import Lamdera
import Time


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V12.Questions.DoYouUseElm
    , age : Maybe Evergreen.V12.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V12.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V12.Ui.MultiChoiceWithOther Evergreen.V12.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V12.Ui.MultiChoiceWithOther Evergreen.V12.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V12.Ui.MultiChoiceWithOther Evergreen.V12.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V12.Ui.MultiChoiceWithOther Evergreen.V12.Questions.WhereDoYouUseElm
    , doYouUseElmAtWork : Maybe Evergreen.V12.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V12.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V12.Ui.MultiChoiceWithOther Evergreen.V12.Questions.WhatLanguageDoYouUseForTheBackend
    , howLong : Maybe Evergreen.V12.Questions.HowLong
    , elmVersion : Evergreen.V12.Ui.MultiChoiceWithOther Evergreen.V12.Questions.WhatElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V12.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V12.Ui.MultiChoiceWithOther Evergreen.V12.Questions.StylingTools
    , buildTools : Evergreen.V12.Ui.MultiChoiceWithOther Evergreen.V12.Questions.BuildTools
    , frameworks : Evergreen.V12.Ui.MultiChoiceWithOther Evergreen.V12.Questions.Frameworks
    , editors : Evergreen.V12.Ui.MultiChoiceWithOther Evergreen.V12.Questions.Editor
    , doYouUseElmReview : Maybe Evergreen.V12.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V12.Ui.MultiChoiceWithOther Evergreen.V12.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V12.Ui.MultiChoiceWithOther Evergreen.V12.Questions.TestTools
    , testsWrittenFor : Evergreen.V12.Ui.MultiChoiceWithOther Evergreen.V12.Questions.TestsWrittenFor
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
    { forms :
        List
            { form : Form
            , submitTime : Maybe Time.Posix
            }
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
