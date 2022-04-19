module Evergreen.V21.Form exposing (..)

import AssocList
import AssocSet
import Countries
import Evergreen.V21.Questions
import Evergreen.V21.Ui


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V21.Questions.DoYouUseElm
    , age : Maybe Evergreen.V21.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V21.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V21.Ui.MultiChoiceWithOther Evergreen.V21.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V21.Ui.MultiChoiceWithOther Evergreen.V21.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V21.Ui.MultiChoiceWithOther Evergreen.V21.Questions.ElmResources
    , countryLivingIn : Maybe Countries.Country
    , applicationDomains : Evergreen.V21.Ui.MultiChoiceWithOther Evergreen.V21.Questions.WhereDoYouUseElm
    , doYouUseElmAtWork : Maybe Evergreen.V21.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V21.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V21.Ui.MultiChoiceWithOther Evergreen.V21.Questions.WhatLanguageDoYouUseForTheBackend
    , howLong : Maybe Evergreen.V21.Questions.HowLong
    , elmVersion : Evergreen.V21.Ui.MultiChoiceWithOther Evergreen.V21.Questions.WhatElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V21.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V21.Ui.MultiChoiceWithOther Evergreen.V21.Questions.StylingTools
    , buildTools : Evergreen.V21.Ui.MultiChoiceWithOther Evergreen.V21.Questions.BuildTools
    , frameworks : Evergreen.V21.Ui.MultiChoiceWithOther Evergreen.V21.Questions.Frameworks
    , editors : Evergreen.V21.Ui.MultiChoiceWithOther Evergreen.V21.Questions.Editor
    , doYouUseElmReview : Maybe Evergreen.V21.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V21.Ui.MultiChoiceWithOther Evergreen.V21.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V21.Ui.MultiChoiceWithOther Evergreen.V21.Questions.TestTools
    , testsWrittenFor : Evergreen.V21.Ui.MultiChoiceWithOther Evergreen.V21.Questions.TestsWrittenFor
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
    , emailAddress : String
    }


type alias FormMapping =
    { otherLanguages : AssocList.Dict String String
    , newsAndDiscussions : AssocList.Dict String String
    , elmResources : AssocList.Dict String String
    , applicationDomains : AssocList.Dict String String
    , whatLanguageDoYouUseForBackend : AssocList.Dict String String
    , elmVersion : AssocList.Dict String String
    , stylingTools : AssocList.Dict String String
    , buildTools : AssocList.Dict String String
    , frameworks : AssocList.Dict String String
    , editors : AssocList.Dict String String
    , whichElmReviewRulesDoYouUse : AssocList.Dict String String
    , testTools : AssocList.Dict String String
    , testsWrittenFor : AssocList.Dict String String
    , elmInitialInterest : AssocList.Dict String String
    , biggestPainPoint : AssocList.Dict String String
    , whatDoYouLikeMost : AssocList.Dict String String
    }
