module Types exposing (..)

import AssocSet exposing (Set)
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Questions exposing (BuildTools, DoYouUseElm, DoYouUseElmFormat, Editor, ElmResources, ExperienceLevel, HowFarAlong, HowIsProjectLicensed, HowLong, NewsAndDiscussions, OtherLanguages, StylingTools, TestTools, TestsWrittenFor, WhatElmVersion, WhereDoYouUseElm, YesNo)
import Ui exposing (MultiChoiceWithOther)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , form : Form
    , acceptTosAnswer : Bool
    }


type alias Form =
    { doYouUseElm : Set DoYouUseElm
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
    { message : String
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | FormChanged Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
