module Evergreen.V23.SurveyResults exposing (..)

import Countries
import Evergreen.V23.DataEntry
import Evergreen.V23.Questions
import Evergreen.V23.Ui


type alias Data =
    { doYouUseElm : Evergreen.V23.DataEntry.DataEntry Evergreen.V23.Questions.DoYouUseElm
    , age : Evergreen.V23.DataEntry.DataEntry Evergreen.V23.Questions.Age
    , functionalProgrammingExperience : Evergreen.V23.DataEntry.DataEntry Evergreen.V23.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V23.DataEntry.DataEntryWithOther Evergreen.V23.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V23.DataEntry.DataEntryWithOther Evergreen.V23.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V23.DataEntry.DataEntryWithOther Evergreen.V23.Questions.ElmResources
    , countryLivingIn : Evergreen.V23.DataEntry.DataEntry Countries.Country
    , doYouUseElmAtWork : Evergreen.V23.DataEntry.DataEntry Evergreen.V23.Questions.DoYouUseElmAtWork
    , applicationDomains : Evergreen.V23.DataEntry.DataEntryWithOther Evergreen.V23.Questions.ApplicationDomains
    , howLargeIsTheCompany : Evergreen.V23.DataEntry.DataEntry Evergreen.V23.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V23.DataEntry.DataEntryWithOther Evergreen.V23.Questions.WhatLanguageDoYouUseForBackend
    , howLong : Evergreen.V23.DataEntry.DataEntry Evergreen.V23.Questions.HowLong
    , elmVersion : Evergreen.V23.DataEntry.DataEntryWithOther Evergreen.V23.Questions.ElmVersion
    , doYouUseElmFormat : Evergreen.V23.DataEntry.DataEntry Evergreen.V23.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V23.DataEntry.DataEntryWithOther Evergreen.V23.Questions.StylingTools
    , buildTools : Evergreen.V23.DataEntry.DataEntryWithOther Evergreen.V23.Questions.BuildTools
    , frameworks : Evergreen.V23.DataEntry.DataEntryWithOther Evergreen.V23.Questions.Frameworks
    , editors : Evergreen.V23.DataEntry.DataEntryWithOther Evergreen.V23.Questions.Editors
    , doYouUseElmReview : Evergreen.V23.DataEntry.DataEntry Evergreen.V23.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V23.DataEntry.DataEntryWithOther Evergreen.V23.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V23.DataEntry.DataEntryWithOther Evergreen.V23.Questions.TestTools
    , testsWrittenFor : Evergreen.V23.DataEntry.DataEntryWithOther Evergreen.V23.Questions.TestsWrittenFor
    , elmInitialInterest : Evergreen.V23.DataEntry.DataEntryWithOther ()
    , biggestPainPoint : Evergreen.V23.DataEntry.DataEntryWithOther ()
    , whatDoYouLikeMost : Evergreen.V23.DataEntry.DataEntryWithOther ()
    }


type alias Model =
    { windowSize : Evergreen.V23.Ui.Size
    , data : Data
    }
