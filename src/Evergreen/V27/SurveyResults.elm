module Evergreen.V27.SurveyResults exposing (..)

import Countries
import Evergreen.V27.DataEntry
import Evergreen.V27.Questions
import Evergreen.V27.Ui


type alias DataEntrySegments a =
    { users : Evergreen.V27.DataEntry.DataEntry a
    , potentialUsers : Evergreen.V27.DataEntry.DataEntry a
    }


type alias DataEntryWithOtherSegments a =
    { users : Evergreen.V27.DataEntry.DataEntryWithOther a
    , potentialUsers : Evergreen.V27.DataEntry.DataEntryWithOther a
    }


type alias Data =
    { totalParticipants : Int
    , doYouUseElm : Evergreen.V27.DataEntry.DataEntry Evergreen.V27.Questions.DoYouUseElm
    , age : DataEntrySegments Evergreen.V27.Questions.Age
    , functionalProgrammingExperience : DataEntrySegments Evergreen.V27.Questions.ExperienceLevel
    , otherLanguages : DataEntryWithOtherSegments Evergreen.V27.Questions.OtherLanguages
    , newsAndDiscussions : DataEntryWithOtherSegments Evergreen.V27.Questions.NewsAndDiscussions
    , elmInitialInterest : DataEntryWithOtherSegments ()
    , countryLivingIn : DataEntrySegments Countries.Country
    , elmResources : Evergreen.V27.DataEntry.DataEntryWithOther Evergreen.V27.Questions.ElmResources
    , doYouUseElmAtWork : Evergreen.V27.DataEntry.DataEntry Evergreen.V27.Questions.DoYouUseElmAtWork
    , applicationDomains : Evergreen.V27.DataEntry.DataEntryWithOther Evergreen.V27.Questions.ApplicationDomains
    , howLargeIsTheCompany : Evergreen.V27.DataEntry.DataEntry Evergreen.V27.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V27.DataEntry.DataEntryWithOther Evergreen.V27.Questions.WhatLanguageDoYouUseForBackend
    , howLong : Evergreen.V27.DataEntry.DataEntry Evergreen.V27.Questions.HowLong
    , elmVersion : Evergreen.V27.DataEntry.DataEntryWithOther Evergreen.V27.Questions.ElmVersion
    , doYouUseElmFormat : Evergreen.V27.DataEntry.DataEntry Evergreen.V27.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V27.DataEntry.DataEntryWithOther Evergreen.V27.Questions.StylingTools
    , buildTools : Evergreen.V27.DataEntry.DataEntryWithOther Evergreen.V27.Questions.BuildTools
    , frameworks : Evergreen.V27.DataEntry.DataEntryWithOther Evergreen.V27.Questions.Frameworks
    , editors : Evergreen.V27.DataEntry.DataEntryWithOther Evergreen.V27.Questions.Editors
    , doYouUseElmReview : Evergreen.V27.DataEntry.DataEntry Evergreen.V27.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V27.DataEntry.DataEntryWithOther Evergreen.V27.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V27.DataEntry.DataEntryWithOther Evergreen.V27.Questions.TestTools
    , testsWrittenFor : Evergreen.V27.DataEntry.DataEntryWithOther Evergreen.V27.Questions.TestsWrittenFor
    , biggestPainPoint : Evergreen.V27.DataEntry.DataEntryWithOther ()
    , whatDoYouLikeMost : Evergreen.V27.DataEntry.DataEntryWithOther ()
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
    { windowSize : Evergreen.V27.Ui.Size
    , data : Data
    , mode : Mode
    , segment : Segment
    , isPreview : Bool
    }


type Msg
    = PressedModeButton Mode
    | PressedSegmentButton Segment
