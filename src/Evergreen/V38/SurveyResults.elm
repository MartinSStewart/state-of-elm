module Evergreen.V38.SurveyResults exposing (..)

import Countries
import Evergreen.V38.DataEntry
import Evergreen.V38.Questions
import Evergreen.V38.Ui


type alias DataEntrySegments a =
    { users : Evergreen.V38.DataEntry.DataEntry a
    , potentialUsers : Evergreen.V38.DataEntry.DataEntry a
    }


type alias DataEntryWithOtherSegments a =
    { users : Evergreen.V38.DataEntry.DataEntryWithOther a
    , potentialUsers : Evergreen.V38.DataEntry.DataEntryWithOther a
    }


type alias Data =
    { totalParticipants : Int
    , doYouUseElm : Evergreen.V38.DataEntry.DataEntry Evergreen.V38.Questions.DoYouUseElm
    , age : DataEntrySegments Evergreen.V38.Questions.Age
    , functionalProgrammingExperience : DataEntrySegments Evergreen.V38.Questions.ExperienceLevel
    , otherLanguages : DataEntryWithOtherSegments Evergreen.V38.Questions.OtherLanguages
    , newsAndDiscussions : DataEntryWithOtherSegments Evergreen.V38.Questions.NewsAndDiscussions
    , elmInitialInterest : DataEntryWithOtherSegments ()
    , countryLivingIn : DataEntrySegments Countries.Country
    , elmResources : Evergreen.V38.DataEntry.DataEntryWithOther Evergreen.V38.Questions.ElmResources
    , doYouUseElmAtWork : Evergreen.V38.DataEntry.DataEntry Evergreen.V38.Questions.DoYouUseElmAtWork
    , applicationDomains : Evergreen.V38.DataEntry.DataEntryWithOther Evergreen.V38.Questions.ApplicationDomains
    , howLargeIsTheCompany : Evergreen.V38.DataEntry.DataEntry Evergreen.V38.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V38.DataEntry.DataEntryWithOther Evergreen.V38.Questions.WhatLanguageDoYouUseForBackend
    , howLong : Evergreen.V38.DataEntry.DataEntry Evergreen.V38.Questions.HowLong
    , elmVersion : Evergreen.V38.DataEntry.DataEntryWithOther Evergreen.V38.Questions.ElmVersion
    , doYouUseElmFormat : Evergreen.V38.DataEntry.DataEntry Evergreen.V38.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V38.DataEntry.DataEntryWithOther Evergreen.V38.Questions.StylingTools
    , buildTools : Evergreen.V38.DataEntry.DataEntryWithOther Evergreen.V38.Questions.BuildTools
    , frameworks : Evergreen.V38.DataEntry.DataEntryWithOther Evergreen.V38.Questions.Frameworks
    , editors : Evergreen.V38.DataEntry.DataEntryWithOther Evergreen.V38.Questions.Editors
    , doYouUseElmReview : Evergreen.V38.DataEntry.DataEntry Evergreen.V38.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V38.DataEntry.DataEntryWithOther Evergreen.V38.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V38.DataEntry.DataEntryWithOther Evergreen.V38.Questions.TestTools
    , testsWrittenFor : Evergreen.V38.DataEntry.DataEntryWithOther Evergreen.V38.Questions.TestsWrittenFor
    , biggestPainPoint : Evergreen.V38.DataEntry.DataEntryWithOther ()
    , whatDoYouLikeMost : Evergreen.V38.DataEntry.DataEntryWithOther ()
    }


type Mode
    = Percentage
    | PerCapita
    | Total


type Segment
    = AllUsers
    | Users
    | PotentialUsers


type alias Model =
    { windowSize : Evergreen.V38.Ui.Size
    , data : Data
    , mode : Mode
    , segment : Segment
    , isPreview : Bool
    }


type Msg
    = PressedModeButton Mode
    | PressedSegmentButton Segment
