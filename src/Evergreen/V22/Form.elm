module Evergreen.V22.Form exposing (..)

import AssocSet
import Countries
import Evergreen.V22.AnswerMap
import Evergreen.V22.FreeTextAnswerMap
import Evergreen.V22.Questions
import Evergreen.V22.Ui


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V22.Questions.DoYouUseElm
    , age : Maybe Evergreen.V22.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V22.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V22.Ui.MultiChoiceWithOther Evergreen.V22.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V22.Ui.MultiChoiceWithOther Evergreen.V22.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V22.Ui.MultiChoiceWithOther Evergreen.V22.Questions.ElmResources
    , countryLivingIn : Maybe Countries.Country
    , applicationDomains : Evergreen.V22.Ui.MultiChoiceWithOther Evergreen.V22.Questions.ApplicationDomains
    , doYouUseElmAtWork : Maybe Evergreen.V22.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V22.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V22.Ui.MultiChoiceWithOther Evergreen.V22.Questions.WhatLanguageDoYouUseForBackend
    , howLong : Maybe Evergreen.V22.Questions.HowLong
    , elmVersion : Evergreen.V22.Ui.MultiChoiceWithOther Evergreen.V22.Questions.ElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V22.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V22.Ui.MultiChoiceWithOther Evergreen.V22.Questions.StylingTools
    , buildTools : Evergreen.V22.Ui.MultiChoiceWithOther Evergreen.V22.Questions.BuildTools
    , frameworks : Evergreen.V22.Ui.MultiChoiceWithOther Evergreen.V22.Questions.Frameworks
    , editors : Evergreen.V22.Ui.MultiChoiceWithOther Evergreen.V22.Questions.Editors
    , doYouUseElmReview : Maybe Evergreen.V22.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V22.Ui.MultiChoiceWithOther Evergreen.V22.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V22.Ui.MultiChoiceWithOther Evergreen.V22.Questions.TestTools
    , testsWrittenFor : Evergreen.V22.Ui.MultiChoiceWithOther Evergreen.V22.Questions.TestsWrittenFor
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
    , emailAddress : String
    }


type alias FormOtherQuestions =
    { doYouUseElm : String
    , age : String
    , functionalProgrammingExperience : String
    , otherLanguages : Evergreen.V22.AnswerMap.AnswerMap Evergreen.V22.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V22.AnswerMap.AnswerMap Evergreen.V22.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V22.AnswerMap.AnswerMap Evergreen.V22.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V22.AnswerMap.AnswerMap Evergreen.V22.Questions.ApplicationDomains
    , doYouUseElmAtWork : String
    , howLargeIsTheCompany : String
    , whatLanguageDoYouUseForBackend : Evergreen.V22.AnswerMap.AnswerMap Evergreen.V22.Questions.WhatLanguageDoYouUseForBackend
    , howLong : String
    , elmVersion : Evergreen.V22.AnswerMap.AnswerMap Evergreen.V22.Questions.ElmVersion
    , doYouUseElmFormat : String
    , stylingTools : Evergreen.V22.AnswerMap.AnswerMap Evergreen.V22.Questions.StylingTools
    , buildTools : Evergreen.V22.AnswerMap.AnswerMap Evergreen.V22.Questions.BuildTools
    , frameworks : Evergreen.V22.AnswerMap.AnswerMap Evergreen.V22.Questions.Frameworks
    , editors : Evergreen.V22.AnswerMap.AnswerMap Evergreen.V22.Questions.Editors
    , doYouUseElmReview : String
    , whichElmReviewRulesDoYouUse : Evergreen.V22.AnswerMap.AnswerMap Evergreen.V22.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V22.AnswerMap.AnswerMap Evergreen.V22.Questions.TestTools
    , testsWrittenFor : Evergreen.V22.AnswerMap.AnswerMap Evergreen.V22.Questions.TestsWrittenFor
    , elmInitialInterest : Evergreen.V22.FreeTextAnswerMap.FreeTextAnswerMap
    , biggestPainPoint : Evergreen.V22.FreeTextAnswerMap.FreeTextAnswerMap
    , whatDoYouLikeMost : Evergreen.V22.FreeTextAnswerMap.FreeTextAnswerMap
    }


type SpecificQuestion
    = DoYouUseElmQuestion
    | AgeQuestion
    | FunctionalProgrammingExperienceQuestion
    | OtherLanguagesQuestion
    | NewsAndDiscussionsQuestion
    | ElmResourcesQuestion
    | CountryLivingInQuestion
    | ApplicationDomainsQuestion
    | DoYouUseElmAtWorkQuestion
    | HowLargeIsTheCompanyQuestion
    | WhatLanguageDoYouUseForBackendQuestion
    | HowLongQuestion
    | ElmVersionQuestion
    | DoYouUseElmFormatQuestion
    | StylingToolsQuestion
    | BuildToolsQuestion
    | FrameworksQuestion
    | EditorsQuestion
    | DoYouUseElmReviewQuestion
    | WhichElmReviewRulesDoYouUseQuestion
    | TestToolsQuestion
    | TestsWrittenForQuestion
    | ElmInitialInterestQuestion
    | BiggestPainPointQuestion
    | WhatDoYouLikeMostQuestion
