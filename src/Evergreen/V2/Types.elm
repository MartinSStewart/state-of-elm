module Evergreen.V2.Types exposing (..)

import AssocSet
import Browser
import Browser.Navigation
import Evergreen.V2.Questions
import Evergreen.V2.Ui
import Url


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V2.Questions.DoYouUseElm
    , functionalProgrammingExperience : Maybe Evergreen.V2.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V2.Ui.MultiChoiceWithOther Evergreen.V2.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V2.Ui.MultiChoiceWithOther Evergreen.V2.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V2.Ui.MultiChoiceWithOther Evergreen.V2.Questions.ElmResources
    , nearestCity : String
    , userGroupNearYou : Maybe Evergreen.V2.Questions.YesNo
    , applicationDomains : Evergreen.V2.Ui.MultiChoiceWithOther Evergreen.V2.Questions.WhereDoYouUseElm
    , howLong : Maybe Evergreen.V2.Questions.HowLong
    , howFarAlongWork : Maybe Evergreen.V2.Questions.HowFarAlong
    , howIsProjectLicensedWork : Maybe Evergreen.V2.Questions.HowIsProjectLicensed
    , workAdoptionChallenge : String
    , howFarAlongHobby : Maybe Evergreen.V2.Questions.HowFarAlong
    , howIsProjectLicensedHobby : Maybe Evergreen.V2.Questions.HowIsProjectLicensed
    , hobbyAdoptionChallenge : String
    , elmVersion : Evergreen.V2.Ui.MultiChoiceWithOther Evergreen.V2.Questions.WhatElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V2.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V2.Ui.MultiChoiceWithOther Evergreen.V2.Questions.StylingTools
    , buildTools : Evergreen.V2.Ui.MultiChoiceWithOther Evergreen.V2.Questions.BuildTools
    , editors : Evergreen.V2.Ui.MultiChoiceWithOther Evergreen.V2.Questions.Editor
    , jsInteropUseCases : String
    , testTools : Evergreen.V2.Ui.MultiChoiceWithOther Evergreen.V2.Questions.TestTools
    , testsWrittenFor : Evergreen.V2.Ui.MultiChoiceWithOther Evergreen.V2.Questions.TestsWrittenFor
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
    }


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , form : Form
    , acceptTosAnswer : Bool
    }


type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | FormChanged Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
