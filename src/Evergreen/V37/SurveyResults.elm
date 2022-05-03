module Evergreen.V37.SurveyResults exposing (..)

import Countries
import Evergreen.V37.DataEntry
import Evergreen.V37.Questions
import Evergreen.V37.Ui


type alias DataEntrySegments a =
    { users : Evergreen.V37.DataEntry.DataEntry a
    , potentialUsers : Evergreen.V37.DataEntry.DataEntry a
    }


type alias DataEntryWithOtherSegments a =
    { users : Evergreen.V37.DataEntry.DataEntryWithOther a
    , potentialUsers : Evergreen.V37.DataEntry.DataEntryWithOther a
    }


type alias Data =
    { totalParticipants : Int
    , doYouUseElm : Evergreen.V37.DataEntry.DataEntry Evergreen.V37.Questions.DoYouUseElm
    , age : DataEntrySegments Evergreen.V37.Questions.Age
    , functionalProgrammingExperience : DataEntrySegments Evergreen.V37.Questions.ExperienceLevel
    , otherLanguages : DataEntryWithOtherSegments Evergreen.V37.Questions.OtherLanguages
    , newsAndDiscussions : DataEntryWithOtherSegments Evergreen.V37.Questions.NewsAndDiscussions
    , elmInitialInterest : DataEntryWithOtherSegments ()
    , countryLivingIn : DataEntrySegments Countries.Country
    , elmResources : Evergreen.V37.DataEntry.DataEntryWithOther Evergreen.V37.Questions.ElmResources
    , doYouUseElmAtWork : Evergreen.V37.DataEntry.DataEntry Evergreen.V37.Questions.DoYouUseElmAtWork
    , applicationDomains : Evergreen.V37.DataEntry.DataEntryWithOther Evergreen.V37.Questions.ApplicationDomains
    , howLargeIsTheCompany : Evergreen.V37.DataEntry.DataEntry Evergreen.V37.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V37.DataEntry.DataEntryWithOther Evergreen.V37.Questions.WhatLanguageDoYouUseForBackend
    , howLong : Evergreen.V37.DataEntry.DataEntry Evergreen.V37.Questions.HowLong
    , elmVersion : Evergreen.V37.DataEntry.DataEntryWithOther Evergreen.V37.Questions.ElmVersion
    , doYouUseElmFormat : Evergreen.V37.DataEntry.DataEntry Evergreen.V37.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V37.DataEntry.DataEntryWithOther Evergreen.V37.Questions.StylingTools
    , buildTools : Evergreen.V37.DataEntry.DataEntryWithOther Evergreen.V37.Questions.BuildTools
    , frameworks : Evergreen.V37.DataEntry.DataEntryWithOther Evergreen.V37.Questions.Frameworks
    , editors : Evergreen.V37.DataEntry.DataEntryWithOther Evergreen.V37.Questions.Editors
    , doYouUseElmReview : Evergreen.V37.DataEntry.DataEntry Evergreen.V37.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V37.DataEntry.DataEntryWithOther Evergreen.V37.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V37.DataEntry.DataEntryWithOther Evergreen.V37.Questions.TestTools
    , testsWrittenFor : Evergreen.V37.DataEntry.DataEntryWithOther Evergreen.V37.Questions.TestsWrittenFor
    , biggestPainPoint : Evergreen.V37.DataEntry.DataEntryWithOther ()
    , whatDoYouLikeMost : Evergreen.V37.DataEntry.DataEntryWithOther ()
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
    { windowSize : Evergreen.V37.Ui.Size
    , data : Data
    , mode : Mode
    , segment : Segment
    , isPreview : Bool
    }


type Msg
    = PressedModeButton Mode
    | PressedSegmentButton Segment
