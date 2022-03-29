module Evergreen.V7.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Evergreen.V7.Questions
import Evergreen.V7.Ui
import Lamdera
import Time
import Url


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V7.Questions.DoYouUseElm
    , age : Maybe Evergreen.V7.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V7.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V7.Ui.MultiChoiceWithOther Evergreen.V7.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V7.Ui.MultiChoiceWithOther Evergreen.V7.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V7.Ui.MultiChoiceWithOther Evergreen.V7.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V7.Ui.MultiChoiceWithOther Evergreen.V7.Questions.WhereDoYouUseElm
    , howLong : Maybe Evergreen.V7.Questions.HowLong
    , howFarAlongWork : Maybe Evergreen.V7.Questions.HowFarAlong
    , howIsProjectLicensedWork : Maybe Evergreen.V7.Questions.HowIsProjectLicensed
    , workAdoptionChallenge : String
    , howFarAlongHobby : Maybe Evergreen.V7.Questions.HowFarAlong
    , howIsProjectLicensedHobby : Maybe Evergreen.V7.Questions.HowIsProjectLicensed
    , hobbyAdoptionChallenge : String
    , elmVersion : Evergreen.V7.Ui.MultiChoiceWithOther Evergreen.V7.Questions.WhatElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V7.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V7.Ui.MultiChoiceWithOther Evergreen.V7.Questions.StylingTools
    , buildTools : Evergreen.V7.Ui.MultiChoiceWithOther Evergreen.V7.Questions.BuildTools
    , editors : Evergreen.V7.Ui.MultiChoiceWithOther Evergreen.V7.Questions.Editor
    , jsInteropUseCases : String
    , testTools : Evergreen.V7.Ui.MultiChoiceWithOther Evergreen.V7.Questions.TestTools
    , testsWrittenFor : Evergreen.V7.Ui.MultiChoiceWithOther Evergreen.V7.Questions.TestsWrittenFor
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
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
    | UrlChanged Url.Url
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
