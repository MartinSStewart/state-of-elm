module Evergreen.V22.SurveyResults exposing (..)

import Countries
import Evergreen.V22.DataEntry
import Evergreen.V22.Questions
import Evergreen.V22.Ui


type alias Data =
    { doYouUseElm : Evergreen.V22.DataEntry.DataEntry Evergreen.V22.Questions.DoYouUseElm
    , age : Evergreen.V22.DataEntry.DataEntry Evergreen.V22.Questions.Age
    , functionalProgrammingExperience : Evergreen.V22.DataEntry.DataEntry Evergreen.V22.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V22.DataEntry.DataEntryWithOther Evergreen.V22.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V22.DataEntry.DataEntryWithOther Evergreen.V22.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V22.DataEntry.DataEntryWithOther Evergreen.V22.Questions.ElmResources
    , countryLivingIn : Evergreen.V22.DataEntry.DataEntry Countries.Country
    , doYouUseElmAtWork : Evergreen.V22.DataEntry.DataEntry Evergreen.V22.Questions.DoYouUseElmAtWork
    , applicationDomains : Evergreen.V22.DataEntry.DataEntryWithOther Evergreen.V22.Questions.ApplicationDomains
    , howLargeIsTheCompany : Evergreen.V22.DataEntry.DataEntry Evergreen.V22.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V22.DataEntry.DataEntryWithOther Evergreen.V22.Questions.WhatLanguageDoYouUseForBackend
    , howLong : Evergreen.V22.DataEntry.DataEntry Evergreen.V22.Questions.HowLong
    , elmVersion : Evergreen.V22.DataEntry.DataEntryWithOther Evergreen.V22.Questions.ElmVersion
    , doYouUseElmFormat : Evergreen.V22.DataEntry.DataEntry Evergreen.V22.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V22.DataEntry.DataEntryWithOther Evergreen.V22.Questions.StylingTools
    , buildTools : Evergreen.V22.DataEntry.DataEntryWithOther Evergreen.V22.Questions.BuildTools
    , frameworks : Evergreen.V22.DataEntry.DataEntryWithOther Evergreen.V22.Questions.Frameworks
    , editors : Evergreen.V22.DataEntry.DataEntryWithOther Evergreen.V22.Questions.Editors
    , doYouUseElmReview : Evergreen.V22.DataEntry.DataEntry Evergreen.V22.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V22.DataEntry.DataEntryWithOther Evergreen.V22.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V22.DataEntry.DataEntryWithOther Evergreen.V22.Questions.TestTools
    , testsWrittenFor : Evergreen.V22.DataEntry.DataEntryWithOther Evergreen.V22.Questions.TestsWrittenFor
    , elmInitialInterest : Evergreen.V22.DataEntry.DataEntryWithOther ()
    , biggestPainPoint : Evergreen.V22.DataEntry.DataEntryWithOther ()
    , whatDoYouLikeMost : Evergreen.V22.DataEntry.DataEntryWithOther ()
    }


type alias Model =
    { windowSize : Evergreen.V22.Ui.Size
    , data : Data
    }
