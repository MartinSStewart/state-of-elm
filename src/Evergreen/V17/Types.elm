module Evergreen.V17.Types exposing (..)

import AssocList
import AssocSet
import Browser
import Evergreen.V17.Questions
import Evergreen.V17.SurveyResults
import Evergreen.V17.Ui
import Lamdera
import Time


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V17.Questions.DoYouUseElm
    , age : Maybe Evergreen.V17.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V17.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V17.Ui.MultiChoiceWithOther Evergreen.V17.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V17.Ui.MultiChoiceWithOther Evergreen.V17.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V17.Ui.MultiChoiceWithOther Evergreen.V17.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V17.Ui.MultiChoiceWithOther Evergreen.V17.Questions.WhereDoYouUseElm
    , doYouUseElmAtWork : Maybe Evergreen.V17.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V17.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V17.Ui.MultiChoiceWithOther Evergreen.V17.Questions.WhatLanguageDoYouUseForTheBackend
    , howLong : Maybe Evergreen.V17.Questions.HowLong
    , elmVersion : Evergreen.V17.Ui.MultiChoiceWithOther Evergreen.V17.Questions.WhatElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V17.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V17.Ui.MultiChoiceWithOther Evergreen.V17.Questions.StylingTools
    , buildTools : Evergreen.V17.Ui.MultiChoiceWithOther Evergreen.V17.Questions.BuildTools
    , frameworks : Evergreen.V17.Ui.MultiChoiceWithOther Evergreen.V17.Questions.Frameworks
    , editors : Evergreen.V17.Ui.MultiChoiceWithOther Evergreen.V17.Questions.Editor
    , doYouUseElmReview : Maybe Evergreen.V17.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V17.Ui.MultiChoiceWithOther Evergreen.V17.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V17.Ui.MultiChoiceWithOther Evergreen.V17.Questions.TestTools
    , testsWrittenFor : Evergreen.V17.Ui.MultiChoiceWithOther Evergreen.V17.Questions.TestsWrittenFor
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
    , windowSize : Evergreen.V17.Ui.Size
    }


type alias AdminLoginData =
    { forms :
        List
            { form : Form
            , submitTime : Maybe Time.Posix
            }
    }


type FrontendModel
    = Loading (Maybe Evergreen.V17.Ui.Size)
    | FormLoaded FormLoaded_
    | FormCompleted
    | AdminLogin
        { password : String
        , loginFailed : Bool
        }
    | Admin AdminLoginData
    | SurveyResultsLoaded Evergreen.V17.SurveyResults.Data


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
    | GotWindowSize Evergreen.V17.Ui.Size
    | TypedFormsData String


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
    | SurveyResults Evergreen.V17.SurveyResults.Data


type ToFrontend
    = LoadForm LoadFormStatus
    | LoadAdmin AdminLoginData
    | AdminLoginResponse (Result () AdminLoginData)
    | SubmitConfirmed
