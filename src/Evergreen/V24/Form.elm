module Evergreen.V24.Form exposing (..)

import AssocSet
import Countries
import Evergreen.V24.AnswerMap
import Evergreen.V24.FreeTextAnswerMap
import Evergreen.V24.Questions
import Evergreen.V24.Ui


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V24.Questions.DoYouUseElm
    , age : Maybe Evergreen.V24.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V24.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V24.Ui.MultiChoiceWithOther Evergreen.V24.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V24.Ui.MultiChoiceWithOther Evergreen.V24.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V24.Ui.MultiChoiceWithOther Evergreen.V24.Questions.ElmResources
    , countryLivingIn : Maybe Countries.Country
    , applicationDomains : Evergreen.V24.Ui.MultiChoiceWithOther Evergreen.V24.Questions.ApplicationDomains
    , doYouUseElmAtWork : Maybe Evergreen.V24.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V24.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V24.Ui.MultiChoiceWithOther Evergreen.V24.Questions.WhatLanguageDoYouUseForBackend
    , howLong : Maybe Evergreen.V24.Questions.HowLong
    , elmVersion : Evergreen.V24.Ui.MultiChoiceWithOther Evergreen.V24.Questions.ElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V24.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V24.Ui.MultiChoiceWithOther Evergreen.V24.Questions.StylingTools
    , buildTools : Evergreen.V24.Ui.MultiChoiceWithOther Evergreen.V24.Questions.BuildTools
    , frameworks : Evergreen.V24.Ui.MultiChoiceWithOther Evergreen.V24.Questions.Frameworks
    , editors : Evergreen.V24.Ui.MultiChoiceWithOther Evergreen.V24.Questions.Editors
    , doYouUseElmReview : Maybe Evergreen.V24.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V24.Ui.MultiChoiceWithOther Evergreen.V24.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V24.Ui.MultiChoiceWithOther Evergreen.V24.Questions.TestTools
    , testsWrittenFor : Evergreen.V24.Ui.MultiChoiceWithOther Evergreen.V24.Questions.TestsWrittenFor
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
    , otherLanguages : Evergreen.V24.AnswerMap.AnswerMap Evergreen.V24.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V24.AnswerMap.AnswerMap Evergreen.V24.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V24.AnswerMap.AnswerMap Evergreen.V24.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V24.AnswerMap.AnswerMap Evergreen.V24.Questions.ApplicationDomains
    , doYouUseElmAtWork : String
    , howLargeIsTheCompany : String
    , whatLanguageDoYouUseForBackend : Evergreen.V24.AnswerMap.AnswerMap Evergreen.V24.Questions.WhatLanguageDoYouUseForBackend
    , howLong : String
    , elmVersion : Evergreen.V24.AnswerMap.AnswerMap Evergreen.V24.Questions.ElmVersion
    , doYouUseElmFormat : String
    , stylingTools : Evergreen.V24.AnswerMap.AnswerMap Evergreen.V24.Questions.StylingTools
    , buildTools : Evergreen.V24.AnswerMap.AnswerMap Evergreen.V24.Questions.BuildTools
    , frameworks : Evergreen.V24.AnswerMap.AnswerMap Evergreen.V24.Questions.Frameworks
    , editors : Evergreen.V24.AnswerMap.AnswerMap Evergreen.V24.Questions.Editors
    , doYouUseElmReview : String
    , whichElmReviewRulesDoYouUse : Evergreen.V24.AnswerMap.AnswerMap Evergreen.V24.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V24.AnswerMap.AnswerMap Evergreen.V24.Questions.TestTools
    , testsWrittenFor : Evergreen.V24.AnswerMap.AnswerMap Evergreen.V24.Questions.TestsWrittenFor
    , elmInitialInterest : Evergreen.V24.FreeTextAnswerMap.FreeTextAnswerMap
    , biggestPainPoint : Evergreen.V24.FreeTextAnswerMap.FreeTextAnswerMap
    , whatDoYouLikeMost : Evergreen.V24.FreeTextAnswerMap.FreeTextAnswerMap
    }
