module Evergreen.V37.Form exposing (..)

import AssocSet
import Countries
import Evergreen.V37.AnswerMap
import Evergreen.V37.FreeTextAnswerMap
import Evergreen.V37.Questions
import Evergreen.V37.Ui


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V37.Questions.DoYouUseElm
    , age : Maybe Evergreen.V37.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V37.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V37.Ui.MultiChoiceWithOther Evergreen.V37.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V37.Ui.MultiChoiceWithOther Evergreen.V37.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V37.Ui.MultiChoiceWithOther Evergreen.V37.Questions.ElmResources
    , countryLivingIn : Maybe Countries.Country
    , applicationDomains : Evergreen.V37.Ui.MultiChoiceWithOther Evergreen.V37.Questions.ApplicationDomains
    , doYouUseElmAtWork : Maybe Evergreen.V37.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V37.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V37.Ui.MultiChoiceWithOther Evergreen.V37.Questions.WhatLanguageDoYouUseForBackend
    , howLong : Maybe Evergreen.V37.Questions.HowLong
    , elmVersion : Evergreen.V37.Ui.MultiChoiceWithOther Evergreen.V37.Questions.ElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V37.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V37.Ui.MultiChoiceWithOther Evergreen.V37.Questions.StylingTools
    , buildTools : Evergreen.V37.Ui.MultiChoiceWithOther Evergreen.V37.Questions.BuildTools
    , frameworks : Evergreen.V37.Ui.MultiChoiceWithOther Evergreen.V37.Questions.Frameworks
    , editors : Evergreen.V37.Ui.MultiChoiceWithOther Evergreen.V37.Questions.Editors
    , doYouUseElmReview : Maybe Evergreen.V37.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V37.Ui.MultiChoiceWithOther Evergreen.V37.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V37.Ui.MultiChoiceWithOther Evergreen.V37.Questions.TestTools
    , testsWrittenFor : Evergreen.V37.Ui.MultiChoiceWithOther Evergreen.V37.Questions.TestsWrittenFor
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
    , otherLanguages : Evergreen.V37.AnswerMap.AnswerMap Evergreen.V37.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V37.AnswerMap.AnswerMap Evergreen.V37.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V37.AnswerMap.AnswerMap Evergreen.V37.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V37.AnswerMap.AnswerMap Evergreen.V37.Questions.ApplicationDomains
    , doYouUseElmAtWork : String
    , howLargeIsTheCompany : String
    , whatLanguageDoYouUseForBackend : Evergreen.V37.AnswerMap.AnswerMap Evergreen.V37.Questions.WhatLanguageDoYouUseForBackend
    , howLong : String
    , elmVersion : Evergreen.V37.AnswerMap.AnswerMap Evergreen.V37.Questions.ElmVersion
    , doYouUseElmFormat : String
    , stylingTools : Evergreen.V37.AnswerMap.AnswerMap Evergreen.V37.Questions.StylingTools
    , buildTools : Evergreen.V37.AnswerMap.AnswerMap Evergreen.V37.Questions.BuildTools
    , frameworks : Evergreen.V37.AnswerMap.AnswerMap Evergreen.V37.Questions.Frameworks
    , editors : Evergreen.V37.AnswerMap.AnswerMap Evergreen.V37.Questions.Editors
    , doYouUseElmReview : String
    , whichElmReviewRulesDoYouUse : Evergreen.V37.AnswerMap.AnswerMap Evergreen.V37.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V37.AnswerMap.AnswerMap Evergreen.V37.Questions.TestTools
    , testsWrittenFor : Evergreen.V37.AnswerMap.AnswerMap Evergreen.V37.Questions.TestsWrittenFor
    , elmInitialInterest : Evergreen.V37.FreeTextAnswerMap.FreeTextAnswerMap
    , biggestPainPoint : Evergreen.V37.FreeTextAnswerMap.FreeTextAnswerMap
    , whatDoYouLikeMost : Evergreen.V37.FreeTextAnswerMap.FreeTextAnswerMap
    }
