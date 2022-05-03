module Evergreen.V38.Form exposing (..)

import AssocSet
import Countries
import Evergreen.V38.AnswerMap
import Evergreen.V38.FreeTextAnswerMap
import Evergreen.V38.Questions
import Evergreen.V38.Ui


type alias Form =
    { doYouUseElm : AssocSet.Set Evergreen.V38.Questions.DoYouUseElm
    , age : Maybe Evergreen.V38.Questions.Age
    , functionalProgrammingExperience : Maybe Evergreen.V38.Questions.ExperienceLevel
    , otherLanguages : Evergreen.V38.Ui.MultiChoiceWithOther Evergreen.V38.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V38.Ui.MultiChoiceWithOther Evergreen.V38.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V38.Ui.MultiChoiceWithOther Evergreen.V38.Questions.ElmResources
    , countryLivingIn : Maybe Countries.Country
    , applicationDomains : Evergreen.V38.Ui.MultiChoiceWithOther Evergreen.V38.Questions.ApplicationDomains
    , doYouUseElmAtWork : Maybe Evergreen.V38.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe Evergreen.V38.Questions.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V38.Ui.MultiChoiceWithOther Evergreen.V38.Questions.WhatLanguageDoYouUseForBackend
    , howLong : Maybe Evergreen.V38.Questions.HowLong
    , elmVersion : Evergreen.V38.Ui.MultiChoiceWithOther Evergreen.V38.Questions.ElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V38.Questions.DoYouUseElmFormat
    , stylingTools : Evergreen.V38.Ui.MultiChoiceWithOther Evergreen.V38.Questions.StylingTools
    , buildTools : Evergreen.V38.Ui.MultiChoiceWithOther Evergreen.V38.Questions.BuildTools
    , frameworks : Evergreen.V38.Ui.MultiChoiceWithOther Evergreen.V38.Questions.Frameworks
    , editors : Evergreen.V38.Ui.MultiChoiceWithOther Evergreen.V38.Questions.Editors
    , doYouUseElmReview : Maybe Evergreen.V38.Questions.DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : Evergreen.V38.Ui.MultiChoiceWithOther Evergreen.V38.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V38.Ui.MultiChoiceWithOther Evergreen.V38.Questions.TestTools
    , testsWrittenFor : Evergreen.V38.Ui.MultiChoiceWithOther Evergreen.V38.Questions.TestsWrittenFor
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
    , otherLanguages : Evergreen.V38.AnswerMap.AnswerMap Evergreen.V38.Questions.OtherLanguages
    , newsAndDiscussions : Evergreen.V38.AnswerMap.AnswerMap Evergreen.V38.Questions.NewsAndDiscussions
    , elmResources : Evergreen.V38.AnswerMap.AnswerMap Evergreen.V38.Questions.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V38.AnswerMap.AnswerMap Evergreen.V38.Questions.ApplicationDomains
    , doYouUseElmAtWork : String
    , howLargeIsTheCompany : String
    , whatLanguageDoYouUseForBackend : Evergreen.V38.AnswerMap.AnswerMap Evergreen.V38.Questions.WhatLanguageDoYouUseForBackend
    , howLong : String
    , elmVersion : Evergreen.V38.AnswerMap.AnswerMap Evergreen.V38.Questions.ElmVersion
    , doYouUseElmFormat : String
    , stylingTools : Evergreen.V38.AnswerMap.AnswerMap Evergreen.V38.Questions.StylingTools
    , buildTools : Evergreen.V38.AnswerMap.AnswerMap Evergreen.V38.Questions.BuildTools
    , frameworks : Evergreen.V38.AnswerMap.AnswerMap Evergreen.V38.Questions.Frameworks
    , editors : Evergreen.V38.AnswerMap.AnswerMap Evergreen.V38.Questions.Editors
    , doYouUseElmReview : String
    , whichElmReviewRulesDoYouUse : Evergreen.V38.AnswerMap.AnswerMap Evergreen.V38.Questions.WhichElmReviewRulesDoYouUse
    , testTools : Evergreen.V38.AnswerMap.AnswerMap Evergreen.V38.Questions.TestTools
    , testsWrittenFor : Evergreen.V38.AnswerMap.AnswerMap Evergreen.V38.Questions.TestsWrittenFor
    , elmInitialInterest : Evergreen.V38.FreeTextAnswerMap.FreeTextAnswerMap
    , biggestPainPoint : Evergreen.V38.FreeTextAnswerMap.FreeTextAnswerMap
    , whatDoYouLikeMost : Evergreen.V38.FreeTextAnswerMap.FreeTextAnswerMap
    }
