module Types exposing (..)

import AssocList exposing (Dict)
import AssocSet exposing (Set)
import Browser exposing (UrlRequest)
import Lamdera exposing (ClientId, SessionId)
import Questions exposing (Age, BuildTools, DoYouUseElm, DoYouUseElmAtWork, DoYouUseElmFormat, DoYouUseElmReview, Editor, ElmResources, ExperienceLevel, Frameworks, HowLargeIsTheCompany, HowLong, NewsAndDiscussions, OtherLanguages, StylingTools, TestTools, TestsWrittenFor, WhatElmVersion, WhatLanguageDoYouUseForTheBackend, WhereDoYouUseElm, WhichElmReviewRulesDoYouUse)
import SurveyResults
import Time
import Ui exposing (MultiChoiceWithOther, Size)


type FrontendModel
    = Loading (Maybe Size) (Maybe Time.Posix)
    | FormLoaded FormLoaded_
    | FormCompleted Time.Posix
    | AdminLogin { password : String, loginFailed : Bool }
    | Admin AdminLoginData
    | SurveyResultsLoaded SurveyResults.Data


type SurveyStatus
    = SurveyOpen
    | SurveyFinished


type alias FormLoaded_ =
    { form : Form
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    , windowSize : Size
    , time : Time.Posix
    }


type alias Form =
    { doYouUseElm : Set DoYouUseElm
    , age : Maybe Age
    , functionalProgrammingExperience : Maybe ExperienceLevel
    , otherLanguages : MultiChoiceWithOther OtherLanguages
    , newsAndDiscussions : MultiChoiceWithOther NewsAndDiscussions
    , elmResources : MultiChoiceWithOther ElmResources
    , countryLivingIn : String
    , applicationDomains : MultiChoiceWithOther WhereDoYouUseElm
    , doYouUseElmAtWork : Maybe DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : MultiChoiceWithOther WhatLanguageDoYouUseForTheBackend
    , howLong : Maybe HowLong
    , elmVersion : MultiChoiceWithOther WhatElmVersion
    , doYouUseElmFormat : Maybe DoYouUseElmFormat
    , stylingTools : MultiChoiceWithOther StylingTools
    , buildTools : MultiChoiceWithOther BuildTools
    , frameworks : MultiChoiceWithOther Frameworks
    , editors : MultiChoiceWithOther Editor
    , doYouUseElmReview : Maybe DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : MultiChoiceWithOther WhichElmReviewRulesDoYouUse
    , testTools : MultiChoiceWithOther TestTools
    , testsWrittenFor : MultiChoiceWithOther TestsWrittenFor
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
    , emailAddress : String
    }


type alias BackendModel =
    { forms : Dict SessionId { form : Form, submitTime : Maybe Time.Posix }
    , adminLogin : Maybe SessionId
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged
    | FormChanged Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin
    | GotWindowSize Size
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
    = UserConnected SessionId ClientId
    | GotTimeWithLoadFormData SessionId ClientId Time.Posix
    | GotTimeWithUpdate SessionId ClientId ToBackend Time.Posix


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Form
    | FormSubmitted
    | SurveyResults SurveyResults.Data
    | AwaitingResultsData


type ToFrontend
    = LoadForm LoadFormStatus
    | LoadAdmin AdminLoginData
    | AdminLoginResponse (Result () AdminLoginData)
    | SubmitConfirmed
    | LogOutResponse LoadFormStatus


type alias AdminLoginData =
    { forms : List { form : Form, submitTime : Maybe Time.Posix }
    }
