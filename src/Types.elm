module Types exposing (..)

import AssocSet exposing (Set)
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Questions exposing (Accept, BuildTools, DoYouUseElm, DoYouUseElmFormat, Editor, ElmResources, ExperienceLevel, HowFarAlong, HowIsProjectLicensed, HowLong, NewsAndDiscussions, OtherLanguages, StylingTools, TestTools, TestsWrittenFor, WhatElmVersion, WhereDoYouUseElm, YesNo)
import Ui exposing (MultiChoiceWithOther)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , form : Form
    }


type alias Form =
    { doYouUseElm : Set DoYouUseElm
    , functionalProgrammingExperience : Maybe ExperienceLevel
    , otherLanguages : MultiChoiceWithOther OtherLanguages
    , newsAndDiscussions : MultiChoiceWithOther NewsAndDiscussions
    , elmResources : MultiChoiceWithOther ElmResources
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
    , accept : Maybe Accept
    }


type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | FormChanged Form


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
