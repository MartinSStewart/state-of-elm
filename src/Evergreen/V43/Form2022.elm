module Evergreen.V43.Form2022 exposing (..)

import AssocSet
import Countries
import Evergreen.V43.AnswerMap
import Evergreen.V43.FreeTextAnswerMap
import Evergreen.V43.Questions2022
import Evergreen.V43.Ui


type alias Form2022 =
    { doYouUseElm : AssocSet.Set Evergreen.V43.Questions2022.DoYouUseElm
    , age : Maybe Evergreen.V43.Questions2022.Age
    , functionalProgrammingExperience : Maybe Evergreen.V43.Questions2022.ExperienceLevel
    , otherLanguages : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2022.OtherLanguages
    , newsAndDiscussions : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2022.NewsAndDiscussions
    , elmResources : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2022.ElmResources
    , countryLivingIn : Maybe Countries.Country
    , applicationDomains : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2022.ApplicationDomains
    , doYouUseElmAtWork : Maybe Evergreen.V43.Questions2022.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V43.Questions2022.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2022.WhatLanguageDoYouUseForBackend
    , howLong : Maybe Evergreen.V43.Questions2022.HowLong
    , elmVersion : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2022.ElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V43.Questions2022.DoYouUseElmFormat
    , stylingTools : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2022.StylingTools
    , buildTools : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2022.BuildTools
    , frameworks : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2022.Frameworks
    , editors : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2022.Editors
    , doYouUseElmReview : Maybe Evergreen.V43.Questions2022.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2022.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2022.TestTools
    , testsWrittenFor : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2022.TestsWrittenFor
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
    , emailAddress : String
    }


type alias FormMapping =
    { doYouUseElm : String
    , age : String
    , functionalProgrammingExperience : String
    , otherLanguages : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2022.OtherLanguages
    , newsAndDiscussions : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2022.NewsAndDiscussions
    , elmResources : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2022.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2022.ApplicationDomains
    , doYouUseElmAtWork : String
    , howLargeIsTheCompany : String
    , whatLanguageDoYouUseForBackend : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2022.WhatLanguageDoYouUseForBackend
    , howLong : String
    , elmVersion : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2022.ElmVersion
    , doYouUseElmFormat : String
    , stylingTools : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2022.StylingTools
    , buildTools : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2022.BuildTools
    , frameworks : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2022.Frameworks
    , editors : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2022.Editors
    , doYouUseElmReview : String
    , whichElmReviewRulesDoYouUse : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2022.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2022.TestTools
    , testsWrittenFor : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2022.TestsWrittenFor
    , elmInitialInterest : Evergreen.V43.FreeTextAnswerMap.FreeTextAnswerMap
    , biggestPainPoint : Evergreen.V43.FreeTextAnswerMap.FreeTextAnswerMap
    , whatDoYouLikeMost : Evergreen.V43.FreeTextAnswerMap.FreeTextAnswerMap
    }
