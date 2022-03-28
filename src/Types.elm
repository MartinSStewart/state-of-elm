module Types exposing (..)

import AssocList exposing (Dict)
import AssocSet exposing (Set)
import Browser exposing (UrlRequest)
import Lamdera exposing (ClientId, SessionId)
import Questions exposing (Age, BuildTools, DoYouUseElm, DoYouUseElmFormat, Editor, ElmResources, ExperienceLevel, HowFarAlong, HowIsProjectLicensed, HowLong, NewsAndDiscussions, OtherLanguages, StylingTools, TestTools, TestsWrittenFor, WhatElmVersion, WhereDoYouUseElm, YesNo)
import Time
import Ui exposing (MultiChoiceWithOther)
import Url exposing (Url)


type FrontendModel
    = FormLoading
    | FormLoaded
        { form : Form
        , acceptedTos : Bool
        , submitting : Bool
        , pressedSubmitCount : Int
        , debounceCounter : Int
        }
    | FormCompleted


type alias Form =
    { doYouUseElm : Set DoYouUseElm
    , age : Maybe Age
    , functionalProgrammingExperience : Maybe ExperienceLevel
    , otherLanguages : MultiChoiceWithOther OtherLanguages
    , newsAndDiscussions : MultiChoiceWithOther NewsAndDiscussions
    , elmResources : MultiChoiceWithOther ElmResources
    , nearestCity : String
    , userGroupNearYou : Maybe YesNo
    , applicationDomains : MultiChoiceWithOther WhereDoYouUseElm
    , howLong : Maybe HowLong
    , howFarAlongWork : Maybe HowFarAlong
    , howIsProjectLicensedWork : Maybe HowIsProjectLicensed
    , workAdoptionChallenge : String
    , howFarAlongHobby : Maybe HowFarAlong
    , howIsProjectLicensedHobby : Maybe HowIsProjectLicensed
    , hobbyAdoptionChallenge : String
    , elmVersion : MultiChoiceWithOther WhatElmVersion
    , doYouUseElmFormat : Maybe DoYouUseElmFormat
    , stylingTools : MultiChoiceWithOther StylingTools
    , buildTools : MultiChoiceWithOther BuildTools
    , editors : MultiChoiceWithOther Editor
    , jsInteropUseCases : String
    , testTools : MultiChoiceWithOther TestTools
    , testsWrittenFor : MultiChoiceWithOther TestsWrittenFor
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
    }


type alias BackendModel =
    { forms : Dict SessionId { form : Form, submitTime : Maybe Time.Posix }
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | FormChanged Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int


type ToBackend
    = AutoSaveForm Form
    | SubmitForm Form


type BackendMsg
    = UserConnected SessionId ClientId
    | GotTimeWithUpdate SessionId ClientId ToBackend Time.Posix


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Form
    | FormSubmitted


type ToFrontend
    = LoadForm LoadFormStatus
    | SubmitConfirmed
