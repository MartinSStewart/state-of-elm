module Evergreen.V4.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Evergreen.V4.Questions
import Evergreen.V4.Ui
import Lamdera
import Url


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V4.Questions.DoYouUseElm
    , functionalProgrammingExperience : Maybe Evergreen.V4.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V4.Ui.MultiChoiceWithOther Evergreen.V4.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V4.Ui.MultiChoiceWithOther Evergreen.V4.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V4.Ui.MultiChoiceWithOther Evergreen.V4.Questions.ElmResources
    , nearestCity : String
    , userGroupNearYou : Maybe Evergreen.V4.Questions.YesNo
    , applicationDomains : Evergreen.V4.Ui.MultiChoiceWithOther Evergreen.V4.Questions.WhereDoYouUseElm
    , howLong : Maybe Evergreen.V4.Questions.HowLong
    , howFarAlongWork : Maybe Evergreen.V4.Questions.HowFarAlong
    , howIsProjectLicensedWork : Maybe Evergreen.V4.Questions.HowIsProjectLicensed
    , workAdoptionChallenge : String
    , howFarAlongHobby : Maybe Evergreen.V4.Questions.HowFarAlong
    , howIsProjectLicensedHobby : Maybe Evergreen.V4.Questions.HowIsProjectLicensed
    , hobbyAdoptionChallenge : String
    , elmVersion : Evergreen.V4.Ui.MultiChoiceWithOther Evergreen.V4.Questions.WhatElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V4.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V4.Ui.MultiChoiceWithOther Evergreen.V4.Questions.StylingTools
    , buildTools : Evergreen.V4.Ui.MultiChoiceWithOther Evergreen.V4.Questions.BuildTools
    , editors : Evergreen.V4.Ui.MultiChoiceWithOther Evergreen.V4.Questions.Editor
    , jsInteropUseCases : String
    , testTools : Evergreen.V4.Ui.MultiChoiceWithOther Evergreen.V4.Questions.TestTools
    , testsWrittenFor : Evergreen.V4.Ui.MultiChoiceWithOther Evergreen.V4.Questions.TestsWrittenFor
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
    }


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


type alias BackendModel =
    { forms :
        AssocList.Dict
            Lamdera.SessionId
            { form : Form
            , isSubmitted : Bool
            }
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | FormChanged Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int


type ToBackend
    = AutoSaveForm Form
    | SubmitForm Form


type BackendMsg
    = UserConnected Lamdera.SessionId Lamdera.ClientId


type LoadFormStatus
    = NoFormFound
    | FormAutoSaved Form
    | FormSubmitted


type ToFrontend
    = LoadForm LoadFormStatus
    | SubmitConfirmed
