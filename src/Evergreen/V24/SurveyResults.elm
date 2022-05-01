module Evergreen.V24.SurveyResults exposing (..)

import Countries
import Evergreen.V24.DataEntry
import Evergreen.V24.Questions
import Evergreen.V24.Ui


type alias DataEntrySegments a =
    { users : Evergreen.V24.DataEntry.DataEntry a
    , potentialUsers : Evergreen.V24.DataEntry.DataEntry a
    }


type alias DataEntryWithOtherSegments a =
    { users : Evergreen.V24.DataEntry.DataEntryWithOther a
    , potentialUsers : Evergreen.V24.DataEntry.DataEntryWithOther a
    }


type alias Data =
    { totalParticipants : Int
    , doYouUseElm : Evergreen.V24.DataEntry.DataEntry Evergreen.V24.Questions.DoYouUseElm
    , age : DataEntrySegments Evergreen.V24.Questions.Age
    , functionalProgrammingExperience : DataEntrySegments Evergreen.V24.Questions.ExperienceLevel
    , otherLanguages : DataEntryWithOtherSegments Evergreen.V24.Questions.OtherLanguages
    , newsAndDiscussions : DataEntryWithOtherSegments Evergreen.V24.Questions.NewsAndDiscussions
    , elmResources : DataEntryWithOtherSegments Evergreen.V24.Questions.ElmResources
    , elmInitialInterest : DataEntryWithOtherSegments ()
    , countryLivingIn : DataEntrySegments Countries.Country
    , doYouUseElmAtWork : Evergreen.V24.DataEntry.DataEntry Evergreen.V24.Questions.DoYouUseElmAtWork
    , applicationDomains : Evergreen.V24.DataEntry.DataEntryWithOther Evergreen.V24.Questions.ApplicationDomains
    , howLargeIsTheCompany : Evergreen.V24.DataEntry.DataEntry Evergreen.V24.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V24.DataEntry.DataEntryWithOther Evergreen.V24.Questions.WhatLanguageDoYouUseForBackend
    , howLong : Evergreen.V24.DataEntry.DataEntry Evergreen.V24.Questions.HowLong
    , elmVersion : Evergreen.V24.DataEntry.DataEntryWithOther Evergreen.V24.Questions.ElmVersion
    , doYouUseElmFormat : Evergreen.V24.DataEntry.DataEntry Evergreen.V24.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V24.DataEntry.DataEntryWithOther Evergreen.V24.Questions.StylingTools
    , buildTools : Evergreen.V24.DataEntry.DataEntryWithOther Evergreen.V24.Questions.BuildTools
    , frameworks : Evergreen.V24.DataEntry.DataEntryWithOther Evergreen.V24.Questions.Frameworks
    , editors : Evergreen.V24.DataEntry.DataEntryWithOther Evergreen.V24.Questions.Editors
    , doYouUseElmReview : Evergreen.V24.DataEntry.DataEntry Evergreen.V24.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V24.DataEntry.DataEntryWithOther Evergreen.V24.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V24.DataEntry.DataEntryWithOther Evergreen.V24.Questions.TestTools
    , testsWrittenFor : Evergreen.V24.DataEntry.DataEntryWithOther Evergreen.V24.Questions.TestsWrittenFor
    , biggestPainPoint : Evergreen.V24.DataEntry.DataEntryWithOther ()
    , whatDoYouLikeMost : Evergreen.V24.DataEntry.DataEntryWithOther ()
    }


type Mode
    = Percentage
    | Total


type Segment
    = AllUsers
    | Users
    | PotentialUsers


type alias Model =
    { windowSize : Evergreen.V24.Ui.Size
    , data : Data
    , mode : Mode
    , segment : Segment
    }


type Msg
    = PressedModeButton Mode
    | PressedSegmentButton Segment
