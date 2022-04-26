module Evergreen.V23.Form exposing (..)

import AssocSet
import Countries
import Evergreen.V23.AnswerMap
import Evergreen.V23.FreeTextAnswerMap
import Evergreen.V23.Questions
import Evergreen.V23.Ui


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V23.Questions.DoYouUseElm
    , age : Maybe Evergreen.V23.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V23.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V23.Ui.MultiChoiceWithOther Evergreen.V23.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V23.Ui.MultiChoiceWithOther Evergreen.V23.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V23.Ui.MultiChoiceWithOther Evergreen.V23.Questions.ElmResources
    , countryLivingIn : Maybe Countries.Country
    , applicationDomains : Evergreen.V23.Ui.MultiChoiceWithOther Evergreen.V23.Questions.ApplicationDomains
    , doYouUseElmAtWork : Maybe Evergreen.V23.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V23.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V23.Ui.MultiChoiceWithOther Evergreen.V23.Questions.WhatLanguageDoYouUseForBackend
    , howLong : Maybe Evergreen.V23.Questions.HowLong
    , elmVersion : Evergreen.V23.Ui.MultiChoiceWithOther Evergreen.V23.Questions.ElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V23.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V23.Ui.MultiChoiceWithOther Evergreen.V23.Questions.StylingTools
    , buildTools : Evergreen.V23.Ui.MultiChoiceWithOther Evergreen.V23.Questions.BuildTools
    , frameworks : Evergreen.V23.Ui.MultiChoiceWithOther Evergreen.V23.Questions.Frameworks
    , editors : Evergreen.V23.Ui.MultiChoiceWithOther Evergreen.V23.Questions.Editors
    , doYouUseElmReview : Maybe Evergreen.V23.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V23.Ui.MultiChoiceWithOther Evergreen.V23.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V23.Ui.MultiChoiceWithOther Evergreen.V23.Questions.TestTools
    , testsWrittenFor : Evergreen.V23.Ui.MultiChoiceWithOther Evergreen.V23.Questions.TestsWrittenFor
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
    , otherLanguages : Evergreen.V23.AnswerMap.AnswerMap Evergreen.V23.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V23.AnswerMap.AnswerMap Evergreen.V23.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V23.AnswerMap.AnswerMap Evergreen.V23.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V23.AnswerMap.AnswerMap Evergreen.V23.Questions.ApplicationDomains
    , doYouUseElmAtWork : String
    , howLargeIsTheCompany : String
    , whatLanguageDoYouUseForBackend : Evergreen.V23.AnswerMap.AnswerMap Evergreen.V23.Questions.WhatLanguageDoYouUseForBackend
    , howLong : String
    , elmVersion : Evergreen.V23.AnswerMap.AnswerMap Evergreen.V23.Questions.ElmVersion
    , doYouUseElmFormat : String
    , stylingTools : Evergreen.V23.AnswerMap.AnswerMap Evergreen.V23.Questions.StylingTools
    , buildTools : Evergreen.V23.AnswerMap.AnswerMap Evergreen.V23.Questions.BuildTools
    , frameworks : Evergreen.V23.AnswerMap.AnswerMap Evergreen.V23.Questions.Frameworks
    , editors : Evergreen.V23.AnswerMap.AnswerMap Evergreen.V23.Questions.Editors
    , doYouUseElmReview : String
    , whichElmReviewRulesDoYouUse : Evergreen.V23.AnswerMap.AnswerMap Evergreen.V23.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V23.AnswerMap.AnswerMap Evergreen.V23.Questions.TestTools
    , testsWrittenFor : Evergreen.V23.AnswerMap.AnswerMap Evergreen.V23.Questions.TestsWrittenFor
    , elmInitialInterest : Evergreen.V23.FreeTextAnswerMap.FreeTextAnswerMap
    , biggestPainPoint : Evergreen.V23.FreeTextAnswerMap.FreeTextAnswerMap
    , whatDoYouLikeMost : Evergreen.V23.FreeTextAnswerMap.FreeTextAnswerMap
    }
