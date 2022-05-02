module Evergreen.V27.Form exposing (..)

import AssocSet
import Countries
import Evergreen.V27.AnswerMap
import Evergreen.V27.FreeTextAnswerMap
import Evergreen.V27.Questions
import Evergreen.V27.Ui


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V27.Questions.DoYouUseElm
    , age : Maybe Evergreen.V27.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V27.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V27.Ui.MultiChoiceWithOther Evergreen.V27.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V27.Ui.MultiChoiceWithOther Evergreen.V27.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V27.Ui.MultiChoiceWithOther Evergreen.V27.Questions.ElmResources
    , countryLivingIn : Maybe Countries.Country
    , applicationDomains : Evergreen.V27.Ui.MultiChoiceWithOther Evergreen.V27.Questions.ApplicationDomains
    , doYouUseElmAtWork : Maybe Evergreen.V27.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V27.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V27.Ui.MultiChoiceWithOther Evergreen.V27.Questions.WhatLanguageDoYouUseForBackend
    , howLong : Maybe Evergreen.V27.Questions.HowLong
    , elmVersion : Evergreen.V27.Ui.MultiChoiceWithOther Evergreen.V27.Questions.ElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V27.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V27.Ui.MultiChoiceWithOther Evergreen.V27.Questions.StylingTools
    , buildTools : Evergreen.V27.Ui.MultiChoiceWithOther Evergreen.V27.Questions.BuildTools
    , frameworks : Evergreen.V27.Ui.MultiChoiceWithOther Evergreen.V27.Questions.Frameworks
    , editors : Evergreen.V27.Ui.MultiChoiceWithOther Evergreen.V27.Questions.Editors
    , doYouUseElmReview : Maybe Evergreen.V27.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V27.Ui.MultiChoiceWithOther Evergreen.V27.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V27.Ui.MultiChoiceWithOther Evergreen.V27.Questions.TestTools
    , testsWrittenFor : Evergreen.V27.Ui.MultiChoiceWithOther Evergreen.V27.Questions.TestsWrittenFor
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
    , emailAddress : String
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


type alias FormMapping =
    { doYouUseElm : String
    , age : String
    , functionalProgrammingExperience : String
    , otherLanguages : Evergreen.V27.AnswerMap.AnswerMap Evergreen.V27.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V27.AnswerMap.AnswerMap Evergreen.V27.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V27.AnswerMap.AnswerMap Evergreen.V27.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V27.AnswerMap.AnswerMap Evergreen.V27.Questions.ApplicationDomains
    , doYouUseElmAtWork : String
    , howLargeIsTheCompany : String
    , whatLanguageDoYouUseForBackend : Evergreen.V27.AnswerMap.AnswerMap Evergreen.V27.Questions.WhatLanguageDoYouUseForBackend
    , howLong : String
    , elmVersion : Evergreen.V27.AnswerMap.AnswerMap Evergreen.V27.Questions.ElmVersion
    , doYouUseElmFormat : String
    , stylingTools : Evergreen.V27.AnswerMap.AnswerMap Evergreen.V27.Questions.StylingTools
    , buildTools : Evergreen.V27.AnswerMap.AnswerMap Evergreen.V27.Questions.BuildTools
    , frameworks : Evergreen.V27.AnswerMap.AnswerMap Evergreen.V27.Questions.Frameworks
    , editors : Evergreen.V27.AnswerMap.AnswerMap Evergreen.V27.Questions.Editors
    , doYouUseElmReview : String
    , whichElmReviewRulesDoYouUse : Evergreen.V27.AnswerMap.AnswerMap Evergreen.V27.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V27.AnswerMap.AnswerMap Evergreen.V27.Questions.TestTools
    , testsWrittenFor : Evergreen.V27.AnswerMap.AnswerMap Evergreen.V27.Questions.TestsWrittenFor
    , elmInitialInterest : Evergreen.V27.FreeTextAnswerMap.FreeTextAnswerMap
    , biggestPainPoint : Evergreen.V27.FreeTextAnswerMap.FreeTextAnswerMap
    , whatDoYouLikeMost : Evergreen.V27.FreeTextAnswerMap.FreeTextAnswerMap
    }
