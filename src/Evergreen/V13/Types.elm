module Evergreen.V13.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Evergreen.V13.Questions
import Evergreen.V13.Ui
import Lamdera
import Time


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V13.Questions.DoYouUseElm
    , age : Maybe Evergreen.V13.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V13.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V13.Ui.MultiChoiceWithOther Evergreen.V13.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V13.Ui.MultiChoiceWithOther Evergreen.V13.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V13.Ui.MultiChoiceWithOther Evergreen.V13.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V13.Ui.MultiChoiceWithOther Evergreen.V13.Questions.WhereDoYouUseElm
    , doYouUseElmAtWork : Maybe Evergreen.V13.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V13.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V13.Ui.MultiChoiceWithOther Evergreen.V13.Questions.WhatLanguageDoYouUseForTheBackend
    , howLong : Maybe Evergreen.V13.Questions.HowLong
    , elmVersion : Evergreen.V13.Ui.MultiChoiceWithOther Evergreen.V13.Questions.WhatElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V13.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V13.Ui.MultiChoiceWithOther Evergreen.V13.Questions.StylingTools
    , buildTools : Evergreen.V13.Ui.MultiChoiceWithOther Evergreen.V13.Questions.BuildTools
    , frameworks : Evergreen.V13.Ui.MultiChoiceWithOther Evergreen.V13.Questions.Frameworks
    , editors : Evergreen.V13.Ui.MultiChoiceWithOther Evergreen.V13.Questions.Editor
    , doYouUseElmReview : Maybe Evergreen.V13.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V13.Ui.MultiChoiceWithOther Evergreen.V13.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V13.Ui.MultiChoiceWithOther Evergreen.V13.Questions.TestTools
    , testsWrittenFor : Evergreen.V13.Ui.MultiChoiceWithOther Evergreen.V13.Questions.TestsWrittenFor
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
    , emailAddress : String
    }


type alias FormLoaded_ =
    { form : Form
    , acceptedTos : Bool
    , submitting : Bool
    , pressedSubmitCount : Int
    , debounceCounter : Int
    , windowSize : Evergreen.V13.Ui.Size
    }


type alias AdminLoginData =
    { forms :
        List
            { form : Form
            , submitTime : Maybe Time.Posix
            }
    }


type FrontendModel
    = Loading (Maybe Evergreen.V13.Ui.Size)
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
    | UrlChanged
    | FormChanged Form
    | PressedAcceptTosAnswer Bool
    | PressedSubmitSurvey
    | Debounce Int
    | TypedPassword String
    | PressedLogin
    | GotWindowSize Evergreen.V13.Ui.Size


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
