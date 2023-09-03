module Evergreen.V43.SurveyResults2023 exposing (..)

import AssocList
import Countries
import Evergreen.V43.DataEntry
import Evergreen.V43.PackageName
import Evergreen.V43.Questions2023


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
    , doYouUseElm : Evergreen.V43.DataEntry.DataEntry Evergreen.V43.Questions2023.DoYouUseElm
    , age : DataEntrySegments Evergreen.V43.Questions2023.Age
    , functionalProgrammingExperience : DataEntrySegments Evergreen.V43.Questions2023.ExperienceLevel
    , otherLanguages : DataEntryWithOtherSegments Evergreen.V43.Questions2023.OtherLanguages
    , newsAndDiscussions : DataEntryWithOtherSegments Evergreen.V43.Questions2023.NewsAndDiscussions
    , elmInitialInterest : DataEntryWithOtherSegments ()
    , countryLivingIn : DataEntrySegments Countries.Country
    , elmResources : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2023.ElmResources
    , doYouUseElmAtWork : Evergreen.V43.DataEntry.DataEntry Evergreen.V43.Questions2023.DoYouUseElmAtWork
    , applicationDomains : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2023.ApplicationDomains
    , howLargeIsTheCompany : Evergreen.V43.DataEntry.DataEntry Evergreen.V43.Questions2023.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2023.WhatLanguageDoYouUseForBackend
    , howLong : Evergreen.V43.DataEntry.DataEntry Evergreen.V43.Questions2023.HowLong
    , elmVersion : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2023.ElmVersion
    , doYouUseElmFormat : Evergreen.V43.DataEntry.DataEntry Evergreen.V43.Questions2023.DoYouUseElmFormat
    , stylingTools : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2023.StylingTools
    , buildTools : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2023.BuildTools
    , frameworks : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2023.Frameworks
    , editors : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2023.Editors
    , doYouUseElmReview : Evergreen.V43.DataEntry.DataEntry Evergreen.V43.Questions2023.DoYouUseElmReview
    , testTools : Evergreen.V43.DataEntry.DataEntryWithOther Evergreen.V43.Questions2023.TestTools
    , biggestPainPoint : Evergreen.V43.DataEntry.DataEntryWithOther ()
    , whatDoYouLikeMost : Evergreen.V43.DataEntry.DataEntryWithOther ()
    , elmJson : AssocList.Dict Evergreen.V43.PackageName.PackageName Int
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
    { data : Data
    , mode : Mode
    , segment : Segment
    }


type Msg
    = PressedModeButton Mode
    | PressedSegmentButton Segment
