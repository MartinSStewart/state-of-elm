module Evergreen.V43.Form2023 exposing (..)

import AssocSet
import Countries
import Evergreen.V43.AnswerMap
import Evergreen.V43.FreeTextAnswerMap
import Evergreen.V43.PackageName
import Evergreen.V43.Questions2023
import Evergreen.V43.Ui


type alias Form2023 =
    { doYouUseElm : AssocSet.Set Evergreen.V43.Questions2023.DoYouUseElm
    , age : Maybe Evergreen.V43.Questions2023.Age
    , pleaseSelectYourGender : Maybe Evergreen.V43.Questions2023.PleaseSelectYourGender
    , functionalProgrammingExperience : Maybe Evergreen.V43.Questions2023.ExperienceLevel
    , otherLanguages : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2023.OtherLanguages
    , newsAndDiscussions : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2023.NewsAndDiscussions
    , elmResources : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2023.ElmResources
    , countryLivingIn : Maybe Countries.Country
    , applicationDomains : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2023.ApplicationDomains
    , doYouUseElmAtWork : Maybe Evergreen.V43.Questions2023.DoYouUseElmAtWork
    , whatPreventsYouFromUsingElmAtWork : String
    , howDidItGoUsingElmAtWork : String
    , howLargeIsTheCompany : Maybe Evergreen.V43.Questions2023.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2023.WhatLanguageDoYouUseForBackend
    , howLong : Maybe Evergreen.V43.Questions2023.HowLong
    , elmVersion : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2023.ElmVersion
    , doYouUseElmFormat : Maybe Evergreen.V43.Questions2023.DoYouUseElmFormat
    , stylingTools : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2023.StylingTools
    , buildTools : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2023.BuildTools
    , frameworks : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2023.Frameworks
    , editors : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2023.Editors
    , doYouUseElmReview : Maybe Evergreen.V43.Questions2023.DoYouUseElmReview
    , testTools : Evergreen.V43.Ui.MultiChoiceWithOther Evergreen.V43.Questions2023.TestTools
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
    , emailAddress : String
    , elmJson : List (List Evergreen.V43.PackageName.PackageName)
    , surveyImprovements : String
    }


type alias FormMapping =
    { doYouUseElm : String
    , age : String
    , pleaseSelectYourGender : String
    , functionalProgrammingExperience : String
    , otherLanguages : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2023.OtherLanguages
    , newsAndDiscussions : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2023.NewsAndDiscussions
    , elmResources : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2023.ElmResources
    , countryLivingIn : String
    , applicationDomains : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2023.ApplicationDomains
    , doYouUseElmAtWork : String
    , whatPreventsYouFromUsingElmAtWork : Evergreen.V43.FreeTextAnswerMap.FreeTextAnswerMap
    , howDidItGoUsingElmAtWork : Evergreen.V43.FreeTextAnswerMap.FreeTextAnswerMap
    , howLargeIsTheCompany : String
    , whatLanguageDoYouUseForBackend : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2023.WhatLanguageDoYouUseForBackend
    , howLong : String
    , elmVersion : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2023.ElmVersion
    , doYouUseElmFormat : String
    , stylingTools : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2023.StylingTools
    , buildTools : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2023.BuildTools
    , frameworks : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2023.Frameworks
    , editors : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2023.Editors
    , doYouUseElmReview : String
    , testTools : Evergreen.V43.AnswerMap.AnswerMap Evergreen.V43.Questions2023.TestTools
    , elmInitialInterest : Evergreen.V43.FreeTextAnswerMap.FreeTextAnswerMap
    , biggestPainPoint : Evergreen.V43.FreeTextAnswerMap.FreeTextAnswerMap
    , whatDoYouLikeMost : Evergreen.V43.FreeTextAnswerMap.FreeTextAnswerMap
    , whatPackagesDoYouUse : String
    }


type SpecificQuestion
    = DoYouUseElmQuestion
    | AgeQuestion
    | PleaseSelectYourGenderQuestion
    | FunctionalProgrammingExperienceQuestion
    | OtherLanguagesQuestion
    | NewsAndDiscussionsQuestion
    | ElmResourcesQuestion
    | CountryLivingInQuestion
    | ApplicationDomainsQuestion
    | DoYouUseElmAtWorkQuestion
    | WhatPreventsYouFromUsingElmAtWork
    | HowDidItGoUsingElmAtWork
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
    | TestToolsQuestion
    | ElmInitialInterestQuestion
    | BiggestPainPointQuestion
    | WhatDoYouLikeMostQuestion
    | SurveyImprovementsQuestion
    | WhatPackagesDoYouUseQuestion
