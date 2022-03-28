module Evergreen.V6.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Evergreen.V6.Questions
import Evergreen.V6.Ui
import Lamdera
import Time
import Url


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V6.Questions.DoYouUseElm
    , age : Maybe Evergreen.V6.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V6.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V6.Ui.MultiChoiceWithOther Evergreen.V6.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V6.Ui.MultiChoiceWithOther Evergreen.V6.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V6.Ui.MultiChoiceWithOther Evergreen.V6.Questions.ElmResources
    , nearestCity : String
    , userGroupNearYou : Maybe Evergreen.V6.Questions.YesNo
    , applicationDomains : Evergreen.V6.Ui.MultiChoiceWithOther Evergreen.V6.Questions.WhereDoYouUseElm
    , howLong : Maybe Evergreen.V6.Questions.HowLong
    , howFarAlongWork : Maybe Evergreen.V6.Questions.HowFarAlong
    , howIsProjectLicensedWork : Maybe Evergreen.V6.Questions.HowIsProjectLicensed
    , workAdoptionChallenge : String
    , howFarAlongHobby : Maybe Evergreen.V6.Questions.HowFarAlong
    , howIsProjectLicensedHobby : Maybe Evergreen.V6.Questions.HowIsProjectLicensed
    , hobbyAdoptionChallenge : String
    , elmVersion : Evergreen.V6.Ui.MultiChoiceWithOther Evergreen.V6.Questions.WhatElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V6.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V6.Ui.MultiChoiceWithOther Evergreen.V6.Questions.StylingTools
    , buildTools : Evergreen.V6.Ui.MultiChoiceWithOther Evergreen.V6.Questions.BuildTools
    , editors : Evergreen.V6.Ui.MultiChoiceWithOther Evergreen.V6.Questions.Editor
    , jsInteropUseCases : String
    , testTools : Evergreen.V6.Ui.MultiChoiceWithOther Evergreen.V6.Questions.TestTools
    , testsWrittenFor : Evergreen.V6.Ui.MultiChoiceWithOther Evergreen.V6.Questions.TestsWrittenFor
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
