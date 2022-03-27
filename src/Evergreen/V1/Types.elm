module Evergreen.V1.Types exposing (..)

import AssocSet
import Browser
import Browser.Navigation
import Evergreen.V1.Questions
import Evergreen.V1.Ui
import Url


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V1.Questions.DoYouUseElm
    , functionalProgrammingExperience : Maybe Evergreen.V1.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V1.Ui.MultiChoiceWithOther Evergreen.V1.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V1.Ui.MultiChoiceWithOther Evergreen.V1.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V1.Ui.MultiChoiceWithOther Evergreen.V1.Questions.ElmResources
    , userGroupNearYou : Maybe Evergreen.V1.Questions.YesNo
    , applicationDomains : Evergreen.V1.Ui.MultiChoiceWithOther Evergreen.V1.Questions.WhereDoYouUseElm
    , howLong : Maybe Evergreen.V1.Questions.HowLong
    , howFarAlongWork : Maybe Evergreen.V1.Questions.HowFarAlong
    , howIsProjectLicensedWork : Maybe Evergreen.V1.Questions.HowIsProjectLicensed
    , workAdoptionChallenge : String
    , howFarAlongHobby : Maybe Evergreen.V1.Questions.HowFarAlong
    , howIsProjectLicensedHobby : Maybe Evergreen.V1.Questions.HowIsProjectLicensed
    , hobbyAdoptionChallenge : String
    , elmVersion : Evergreen.V1.Ui.MultiChoiceWithOther Evergreen.V1.Questions.WhatElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V1.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V1.Ui.MultiChoiceWithOther Evergreen.V1.Questions.StylingTools
    , buildTools : Evergreen.V1.Ui.MultiChoiceWithOther Evergreen.V1.Questions.BuildTools
    , editors : Evergreen.V1.Ui.MultiChoiceWithOther Evergreen.V1.Questions.Editor
    , jsInteropUseCases : String
    , testTools : Evergreen.V1.Ui.MultiChoiceWithOther Evergreen.V1.Questions.TestTools
    , testsWrittenFor : Evergreen.V1.Ui.MultiChoiceWithOther Evergreen.V1.Questions.TestsWrittenFor
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
