module Evergreen.V43.SurveyResults2022 exposing (..)

import Countries
import Evergreen.V43.DataEntry
import Evergreen.V43.Questions2022


type alias DataEntrySegments a =
    { users : Evergreen.V43.DataEntry.DataEntry a
    , potentialUsers : Evergreen.V43.DataEntry.DataEntry a
    }


type alias DataEntryWithOtherSegments a =
    { users : Evergreen.V43.DataEntry.DataEntryWithOther a
    , potentialUsers : Evergreen.V43.DataEntry.DataEntryWithOther a
    }


type alias Data =
    { totalParticipants : Int
    , doYouUseElm : Evergreen.V43.DataEntry.DataEntry Evergreen.V43.Questions2022.DoYouUseElm
    , age : DataEntrySegments Evergreen.V43.Questions2022.Age
    , functionalProgrammingExperience : DataEntrySegments Evergreen.V43.Questions2022.ExperienceLevel
    , otherLanguages : DataEntryWithOtherSegments Evergreen.V43.Questions2022.OtherLanguages
    , newsAndDiscussions : DataEntryWithOtherSegments Evergreen.V43.Questions2022.NewsAndDiscussions
    , elmInitialInterest : DataEntryWithOtherSegments ()
    , countryLivingIn : DataEntrySegments Countries.Country
    , elmResources : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2022.ElmResources
    , doYouUseElmAtWork : Evergreen.V43.DataEntry.DataEntry Evergreen.V43.Questions2022.DoYouUseElmAtWork
    , applicationDomains : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2022.ApplicationDomains
    , howLargeIsTheCompany : Evergreen.V43.DataEntry.DataEntry Evergreen.V43.Questions2022.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2022.WhatLanguageDoYouUseForBackend
    , howLong : Evergreen.V43.DataEntry.DataEntry Evergreen.V43.Questions2022.HowLong
    , elmVersion : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2022.ElmVersion
    , doYouUseElmFormat : Evergreen.V43.DataEntry.DataEntry Evergreen.V43.Questions2022.DoYouUseElmFormat
    , stylingTools : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2022.StylingTools
    , buildTools : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2022.BuildTools
    , frameworks : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2022.Frameworks
    , editors : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2022.Editors
    , doYouUseElmReview : Evergreen.V43.DataEntry.DataEntry Evergreen.V43.Questions2022.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2022.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2022.TestTools
    , testsWrittenFor : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2022.TestsWrittenFor
    , biggestPainPoint : Evergreen.V43.DataEntry.DataEntryWithOther ()
    , whatDoYouLikeMost : Evergreen.V43.DataEntry.DataEntryWithOther ()
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
    { mode : Mode
    , segment : Segment
    }


type Msg
    = PressedModeButton Mode
    | PressedSegmentButton Segment
