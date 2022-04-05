module Evergreen.V20.Form exposing (..)

import AssocList
import AssocSet
import Evergreen.V20.Questions
import Evergreen.V20.Ui


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V20.Questions.DoYouUseElm
    , age : Maybe Evergreen.V20.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V20.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V20.Ui.MultiChoiceWithOther Evergreen.V20.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V20.Ui.MultiChoiceWithOther Evergreen.V20.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V20.Ui.MultiChoiceWithOther Evergreen.V20.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V20.Ui.MultiChoiceWithOther Evergreen.V20.Questions.WhereDoYouUseElm
    , doYouUseElmAtWork : Maybe Evergreen.V20.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V20.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V20.Ui.MultiChoiceWithOther Evergreen.V20.Questions.WhatLanguageDoYouUseForTheBackend
    , howLong : Maybe Evergreen.V20.Questions.HowLong
    , elmVersion : Evergreen.V20.Ui.MultiChoiceWithOther Evergreen.V20.Questions.WhatElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V20.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V20.Ui.MultiChoiceWithOther Evergreen.V20.Questions.StylingTools
    , buildTools : Evergreen.V20.Ui.MultiChoiceWithOther Evergreen.V20.Questions.BuildTools
    , frameworks : Evergreen.V20.Ui.MultiChoiceWithOther Evergreen.V20.Questions.Frameworks
    , editors : Evergreen.V20.Ui.MultiChoiceWithOther Evergreen.V20.Questions.Editor
    , doYouUseElmReview : Maybe Evergreen.V20.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V20.Ui.MultiChoiceWithOther Evergreen.V20.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V20.Ui.MultiChoiceWithOther Evergreen.V20.Questions.TestTools
    , testsWrittenFor : Evergreen.V20.Ui.MultiChoiceWithOther Evergreen.V20.Questions.TestsWrittenFor
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
