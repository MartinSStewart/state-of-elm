module Types exposing (..)

import AssocList exposing (Dict)
import AssocSet exposing (Set)
import Browser exposing (UrlRequest)
import Lamdera exposing (ClientId, SessionId)
import Questions exposing (Age, BuildTools, DoYouUseElm, DoYouUseElmAtWork, DoYouUseElmFormat, DoYouUseElmReview, Editor, ElmResources, ExperienceLevel, Frameworks, HowLargeIsTheCompany, HowLong, NewsAndDiscussions, OtherLanguages, StylingTools, TestTools, TestsWrittenFor, WhatElmVersion, WhatLanguageDoYouUseForTheBackend, WhereDoYouUseElm, WhichElmReviewRulesDoYouUse)
import Time
import Ui exposing (MultiChoiceWithOther)
import Url exposing (Url)


type FrontendModel
    = Loading
    | FormLoaded FormLoaded_
    | FormCompleted
    | AdminLogin { password : String, loginFailed : Bool }
    | Admin AdminLoginData


type alias FormLoaded_ =
    { form : Form
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
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
    | UrlChanged Url
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
    = UserConnected SessionId ClientId
    | GotTimeWithUpdate SessionId ClientId ToBackend Time.Posix


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Form
    | FormSubmitted


type ToFrontend
    = LoadForm LoadFormStatus
    | LoadAdmin AdminLoginData
    | AdminLoginResponse (Result () AdminLoginData)
    | SubmitConfirmed


type alias AdminLoginData =
    { autoSavedSurveyCount : Int, submittedSurveyCount : Int }
