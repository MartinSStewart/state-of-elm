module Evergreen.Migrate.V22 exposing (..)

import AssocList as Dict exposing (Dict)
import AssocSet as Set
import Countries exposing (Country)
import Evergreen.V21.AdminPage
import Evergreen.V21.DataEntry
import Evergreen.V21.Form
import Evergreen.V21.Questions
import Evergreen.V21.SurveyResults
import Evergreen.V21.Types as Old
import Evergreen.V22.AdminPage
import Evergreen.V22.AnswerMap
import Evergreen.V22.DataEntry
import Evergreen.V22.Form
import Evergreen.V22.FreeTextAnswerMap
import Evergreen.V22.Questions exposing (Age(..), ApplicationDomains(..), BuildTools(..), DoYouUseElm(..), DoYouUseElmAtWork(..), DoYouUseElmFormat(..), DoYouUseElmReview(..), Editors(..), ElmResources(..), ElmVersion(..), ExperienceLevel(..), Frameworks(..), HowLargeIsTheCompany(..), HowLong(..), NewsAndDiscussions(..), OtherLanguages(..), StylingTools(..), TestTools(..), TestsWrittenFor(..), WhatLanguageDoYouUseForBackend(..), WhichElmReviewRulesDoYouUse(..))
import Evergreen.V22.SurveyResults
import Evergreen.V22.Types as New
import Lamdera.Migrations exposing (..)
import List.Nonempty exposing (Nonempty(..))
import Questions exposing (Question)
import Time


migrateAge : Evergreen.V21.Questions.Age -> Evergreen.V22.Questions.Age
migrateAge old =
    case old of
        Evergreen.V21.Questions.Under10 ->
            Evergreen.V22.Questions.Under10

        Evergreen.V21.Questions.Age10To19 ->
            Evergreen.V22.Questions.Age10To19

        Evergreen.V21.Questions.Age20To29 ->
            Evergreen.V22.Questions.Age20To29

        Evergreen.V21.Questions.Age30To39 ->
            Evergreen.V22.Questions.Age30To39

        Evergreen.V21.Questions.Age40To49 ->
            Evergreen.V22.Questions.Age40To49

        Evergreen.V21.Questions.Age50To59 ->
            Evergreen.V22.Questions.Age50To59

        Evergreen.V21.Questions.Over60 ->
            Evergreen.V22.Questions.Over60


migrateBuildTools : Evergreen.V21.Questions.BuildTools -> Maybe Evergreen.V22.Questions.BuildTools
migrateBuildTools old =
    case old of
        Evergreen.V21.Questions.ShellScripts ->
            Just Evergreen.V22.Questions.ShellScripts

        Evergreen.V21.Questions.ElmLive ->
            Just Evergreen.V22.Questions.ElmLive

        Evergreen.V21.Questions.CreateElmApp ->
            Just Evergreen.V22.Questions.CreateElmApp

        Evergreen.V21.Questions.Webpack ->
            Just Evergreen.V22.Questions.Webpack

        Evergreen.V21.Questions.Brunch ->
            Just Evergreen.V22.Questions.Brunch

        Evergreen.V21.Questions.ElmMakeStandalone ->
            Just Evergreen.V22.Questions.ElmMakeStandalone

        Evergreen.V21.Questions.Gulp ->
            Just Evergreen.V22.Questions.Gulp

        Evergreen.V21.Questions.Make ->
            Just Evergreen.V22.Questions.Make

        Evergreen.V21.Questions.ElmReactor ->
            Just Evergreen.V22.Questions.ElmReactor

        Evergreen.V21.Questions.Parcel ->
            Just Evergreen.V22.Questions.Parcel

        Evergreen.V21.Questions.Vite ->
            Just Evergreen.V22.Questions.Vite


migrateDoYouUseElm : Evergreen.V21.Questions.DoYouUseElm -> Evergreen.V22.Questions.DoYouUseElm
migrateDoYouUseElm old =
    case old of
        Evergreen.V21.Questions.YesAtWork ->
            Evergreen.V22.Questions.YesAtWork

        Evergreen.V21.Questions.YesInSideProjects ->
            Evergreen.V22.Questions.YesInSideProjects

        Evergreen.V21.Questions.YesAsAStudent ->
            Evergreen.V22.Questions.YesAsAStudent

        Evergreen.V21.Questions.IUsedToButIDontAnymore ->
            Evergreen.V22.Questions.IUsedToButIDontAnymore

        Evergreen.V21.Questions.NoButImCuriousAboutIt ->
            Evergreen.V22.Questions.NoButImCuriousAboutIt

        Evergreen.V21.Questions.NoAndIDontPlanTo ->
            Evergreen.V22.Questions.NoAndIDontPlanTo


migrateDoYouUseElmAtWork : Evergreen.V21.Questions.DoYouUseElmAtWork -> Evergreen.V22.Questions.DoYouUseElmAtWork
migrateDoYouUseElmAtWork old =
    case old of
        Evergreen.V21.Questions.NotInterestedInElmAtWork ->
            Evergreen.V22.Questions.NotInterestedInElmAtWork

        Evergreen.V21.Questions.WouldLikeToUseElmAtWork ->
            Evergreen.V22.Questions.WouldLikeToUseElmAtWork

        Evergreen.V21.Questions.HaveTriedElmInAWorkProject ->
            Evergreen.V22.Questions.HaveTriedElmInAWorkProject

        Evergreen.V21.Questions.MyTeamMostlyWritesNewCodeInElm ->
            Evergreen.V22.Questions.MyTeamMostlyWritesNewCodeInElm

        Evergreen.V21.Questions.NotEmployed ->
            Evergreen.V22.Questions.NotEmployed


migrateDoYouUseElmFormat : Evergreen.V21.Questions.DoYouUseElmFormat -> Evergreen.V22.Questions.DoYouUseElmFormat
migrateDoYouUseElmFormat old =
    case old of
        Evergreen.V21.Questions.PreferElmFormat ->
            Evergreen.V22.Questions.PreferElmFormat

        Evergreen.V21.Questions.TriedButDontUseElmFormat ->
            Evergreen.V22.Questions.TriedButDontUseElmFormat

        Evergreen.V21.Questions.HeardButDontUseElmFormat ->
            Evergreen.V22.Questions.HeardButDontUseElmFormat

        Evergreen.V21.Questions.HaveNotHeardOfElmFormat ->
            Evergreen.V22.Questions.HaveNotHeardOfElmFormat


migrateDoYouUseElmReview : Evergreen.V21.Questions.DoYouUseElmReview -> Evergreen.V22.Questions.DoYouUseElmReview
migrateDoYouUseElmReview old =
    case old of
        Evergreen.V21.Questions.NeverHeardOfElmReview ->
            Evergreen.V22.Questions.NeverHeardOfElmReview

        Evergreen.V21.Questions.HeardOfItButNeverTriedElmReview ->
            Evergreen.V22.Questions.HeardOfItButNeverTriedElmReview

        Evergreen.V21.Questions.IveTriedElmReview ->
            Evergreen.V22.Questions.IveTriedElmReview

        Evergreen.V21.Questions.IUseElmReviewRegularly ->
            Evergreen.V22.Questions.IUseElmReviewRegularly


migrateEditor : Evergreen.V21.Questions.Editor -> Evergreen.V22.Questions.Editors
migrateEditor old =
    case old of
        Evergreen.V21.Questions.SublimeText ->
            Evergreen.V22.Questions.SublimeText

        Evergreen.V21.Questions.Vim ->
            Evergreen.V22.Questions.Vim

        Evergreen.V21.Questions.Atom ->
            Evergreen.V22.Questions.Atom

        Evergreen.V21.Questions.Emacs ->
            Evergreen.V22.Questions.Emacs

        Evergreen.V21.Questions.VSCode ->
            Evergreen.V22.Questions.VSCode

        Evergreen.V21.Questions.Intellij ->
            Evergreen.V22.Questions.Intellij


migrateElmResources : Evergreen.V21.Questions.ElmResources -> Evergreen.V22.Questions.ElmResources
migrateElmResources old =
    case old of
        Evergreen.V21.Questions.DailyDrip ->
            Evergreen.V22.Questions.DailyDrip

        Evergreen.V21.Questions.ElmInActionBook ->
            Evergreen.V22.Questions.ElmInActionBook

        Evergreen.V21.Questions.WeeklyBeginnersElmSubreddit ->
            Evergreen.V22.Questions.WeeklyBeginnersElmSubreddit

        Evergreen.V21.Questions.BeginningElmBook ->
            Evergreen.V22.Questions.BeginningElmBook

        Evergreen.V21.Questions.StackOverflow ->
            Evergreen.V22.Questions.StackOverflow

        Evergreen.V21.Questions.BuildingWebAppsWithElm ->
            Evergreen.V22.Questions.BuildingWebAppsWithElm

        Evergreen.V21.Questions.TheJsonSurvivalKit ->
            Evergreen.V22.Questions.TheJsonSurvivalKit

        Evergreen.V21.Questions.EggheadCourses ->
            Evergreen.V22.Questions.EggheadCourses

        Evergreen.V21.Questions.ProgrammingElmBook ->
            Evergreen.V22.Questions.ProgrammingElmBook

        Evergreen.V21.Questions.GuideElmLang ->
            Evergreen.V22.Questions.GuideElmLang

        Evergreen.V21.Questions.ElmForBeginners ->
            Evergreen.V22.Questions.ElmForBeginners

        Evergreen.V21.Questions.ElmSlack_ ->
            Evergreen.V22.Questions.ElmSlack_

        Evergreen.V21.Questions.FrontendMasters ->
            Evergreen.V22.Questions.FrontendMasters

        Evergreen.V21.Questions.ElmOnline ->
            Evergreen.V22.Questions.ElmOnline


migrateExperienceLevel : Evergreen.V21.Questions.ExperienceLevel -> Evergreen.V22.Questions.ExperienceLevel
migrateExperienceLevel old =
    case old of
        Evergreen.V21.Questions.Beginner ->
            Evergreen.V22.Questions.Beginner

        Evergreen.V21.Questions.Intermediate ->
            Evergreen.V22.Questions.Intermediate

        Evergreen.V21.Questions.Professional ->
            Evergreen.V22.Questions.Professional

        Evergreen.V21.Questions.Expert ->
            Evergreen.V22.Questions.Expert


migrateFrameworks : Evergreen.V21.Questions.Frameworks -> Evergreen.V22.Questions.Frameworks
migrateFrameworks old =
    case old of
        Evergreen.V21.Questions.Lamdera_ ->
            Evergreen.V22.Questions.Lamdera_

        Evergreen.V21.Questions.ElmSpa ->
            Evergreen.V22.Questions.ElmSpa

        Evergreen.V21.Questions.ElmPages ->
            Evergreen.V22.Questions.ElmPages

        Evergreen.V21.Questions.ElmPlayground ->
            Evergreen.V22.Questions.ElmPlayground


migrateHowLargeIsTheCompany : Evergreen.V21.Questions.HowLargeIsTheCompany -> Evergreen.V22.Questions.HowLargeIsTheCompany
migrateHowLargeIsTheCompany old =
    case old of
        Evergreen.V21.Questions.Size1To10Employees ->
            Evergreen.V22.Questions.Size1To10Employees

        Evergreen.V21.Questions.Size11To50Employees ->
            Evergreen.V22.Questions.Size11To50Employees

        Evergreen.V21.Questions.Size50To100Employees ->
            Evergreen.V22.Questions.Size50To100Employees

        Evergreen.V21.Questions.Size100OrMore ->
            Evergreen.V22.Questions.Size100OrMore


migrateHowLong : Evergreen.V21.Questions.HowLong -> Evergreen.V22.Questions.HowLong
migrateHowLong old =
    case old of
        Evergreen.V21.Questions.Under3Months ->
            Evergreen.V22.Questions.Under3Months

        Evergreen.V21.Questions.Between3MonthsAndAYear ->
            Evergreen.V22.Questions.Between3MonthsAndAYear

        Evergreen.V21.Questions.OneYear ->
            Evergreen.V22.Questions.OneYear

        Evergreen.V21.Questions.TwoYears ->
            Evergreen.V22.Questions.TwoYears

        Evergreen.V21.Questions.ThreeYears ->
            Evergreen.V22.Questions.ThreeYears

        Evergreen.V21.Questions.FourYears ->
            Evergreen.V22.Questions.FourYears

        Evergreen.V21.Questions.FiveYears ->
            Evergreen.V22.Questions.FiveYears

        Evergreen.V21.Questions.SixYears ->
            Evergreen.V22.Questions.SixYears

        Evergreen.V21.Questions.SevenYears ->
            Evergreen.V22.Questions.SevenYears

        Evergreen.V21.Questions.EightYears ->
            Evergreen.V22.Questions.EightYears

        Evergreen.V21.Questions.NineYears ->
            Evergreen.V22.Questions.NineYears


migrateNewsAndDiscussions : Evergreen.V21.Questions.NewsAndDiscussions -> Evergreen.V22.Questions.NewsAndDiscussions
migrateNewsAndDiscussions old =
    case old of
        Evergreen.V21.Questions.ElmDiscourse ->
            Evergreen.V22.Questions.ElmDiscourse

        Evergreen.V21.Questions.ElmSlack ->
            Evergreen.V22.Questions.ElmSlack

        Evergreen.V21.Questions.ElmSubreddit ->
            Evergreen.V22.Questions.ElmSubreddit

        Evergreen.V21.Questions.Twitter ->
            Evergreen.V22.Questions.Twitter

        Evergreen.V21.Questions.ElmRadio ->
            Evergreen.V22.Questions.ElmRadio

        Evergreen.V21.Questions.BlogPosts ->
            Evergreen.V22.Questions.BlogPosts

        Evergreen.V21.Questions.Facebook ->
            Evergreen.V22.Questions.Facebook

        Evergreen.V21.Questions.DevTo ->
            Evergreen.V22.Questions.DevTo

        Evergreen.V21.Questions.Meetups ->
            Evergreen.V22.Questions.Meetups

        Evergreen.V21.Questions.ElmWeekly ->
            Evergreen.V22.Questions.ElmWeekly

        Evergreen.V21.Questions.ElmNews ->
            Evergreen.V22.Questions.ElmNews

        Evergreen.V21.Questions.ElmCraft ->
            Evergreen.V22.Questions.ElmCraft


migrateOtherLanguages : Evergreen.V21.Questions.OtherLanguages -> Evergreen.V22.Questions.OtherLanguages
migrateOtherLanguages old =
    case old of
        Evergreen.V21.Questions.JavaScript ->
            Evergreen.V22.Questions.JavaScript

        Evergreen.V21.Questions.TypeScript ->
            Evergreen.V22.Questions.TypeScript

        Evergreen.V21.Questions.Go ->
            Evergreen.V22.Questions.Go

        Evergreen.V21.Questions.Haskell ->
            Evergreen.V22.Questions.Haskell

        Evergreen.V21.Questions.CSharp ->
            Evergreen.V22.Questions.CSharp

        Evergreen.V21.Questions.C ->
            Evergreen.V22.Questions.C

        Evergreen.V21.Questions.CPlusPlus ->
            Evergreen.V22.Questions.CPlusPlus

        Evergreen.V21.Questions.OCaml ->
            Evergreen.V22.Questions.OCaml

        Evergreen.V21.Questions.Python ->
            Evergreen.V22.Questions.Python

        Evergreen.V21.Questions.Swift ->
            Evergreen.V22.Questions.Swift

        Evergreen.V21.Questions.PHP ->
            Evergreen.V22.Questions.PHP

        Evergreen.V21.Questions.Java ->
            Evergreen.V22.Questions.Java

        Evergreen.V21.Questions.Ruby ->
            Evergreen.V22.Questions.Ruby

        Evergreen.V21.Questions.Elixir ->
            Evergreen.V22.Questions.Elixir

        Evergreen.V21.Questions.Clojure ->
            Evergreen.V22.Questions.Clojure

        Evergreen.V21.Questions.Rust ->
            Evergreen.V22.Questions.Rust

        Evergreen.V21.Questions.FSharp ->
            Evergreen.V22.Questions.FSharp


migrateStylingTools : Evergreen.V21.Questions.StylingTools -> Evergreen.V22.Questions.StylingTools
migrateStylingTools old =
    case old of
        Evergreen.V21.Questions.SassOrScss ->
            Evergreen.V22.Questions.SassOrScss

        Evergreen.V21.Questions.ElmCss ->
            Evergreen.V22.Questions.ElmCss

        Evergreen.V21.Questions.PlainCss ->
            Evergreen.V22.Questions.PlainCss

        Evergreen.V21.Questions.ElmUi ->
            Evergreen.V22.Questions.ElmUi

        Evergreen.V21.Questions.Tailwind ->
            Evergreen.V22.Questions.Tailwind

        Evergreen.V21.Questions.ElmTailwindModules ->
            Evergreen.V22.Questions.ElmTailwindModules

        Evergreen.V21.Questions.Bootstrap ->
            Evergreen.V22.Questions.Bootstrap


migrateTestTools : Evergreen.V21.Questions.TestTools -> Evergreen.V22.Questions.TestTools
migrateTestTools old =
    case old of
        Evergreen.V21.Questions.BrowserAcceptanceTests ->
            Evergreen.V22.Questions.BrowserAcceptanceTests

        Evergreen.V21.Questions.ElmBenchmark ->
            Evergreen.V22.Questions.ElmBenchmark

        Evergreen.V21.Questions.ElmTest ->
            Evergreen.V22.Questions.ElmTest

        Evergreen.V21.Questions.ElmProgramTest ->
            Evergreen.V22.Questions.ElmProgramTest

        Evergreen.V21.Questions.VisualRegressionTests ->
            Evergreen.V22.Questions.VisualRegressionTests


migrateTestsWrittenFor : Evergreen.V21.Questions.TestsWrittenFor -> Evergreen.V22.Questions.TestsWrittenFor
migrateTestsWrittenFor old =
    case old of
        Evergreen.V21.Questions.ComplicatedFunctions ->
            Evergreen.V22.Questions.ComplicatedFunctions

        Evergreen.V21.Questions.FunctionsThatReturnCmds ->
            Evergreen.V22.Questions.FunctionsThatReturnCmds

        Evergreen.V21.Questions.AllPublicFunctions ->
            Evergreen.V22.Questions.AllPublicFunctions

        Evergreen.V21.Questions.HtmlFunctions ->
            Evergreen.V22.Questions.HtmlFunctions

        Evergreen.V21.Questions.JsonDecodersAndEncoders ->
            Evergreen.V22.Questions.JsonDecodersAndEncoders

        Evergreen.V21.Questions.MostPublicFunctions ->
            Evergreen.V22.Questions.MostPublicFunctions


migrateWhatElmVersion : Evergreen.V21.Questions.WhatElmVersion -> Evergreen.V22.Questions.ElmVersion
migrateWhatElmVersion old =
    case old of
        Evergreen.V21.Questions.Version0_19 ->
            Evergreen.V22.Questions.Version0_19

        Evergreen.V21.Questions.Version0_18 ->
            Evergreen.V22.Questions.Version0_18

        Evergreen.V21.Questions.Version0_17 ->
            Evergreen.V22.Questions.Version0_17

        Evergreen.V21.Questions.Version0_16 ->
            Evergreen.V22.Questions.Version0_16


migrateWhatLanguageDoYouUseForTheBackend : Evergreen.V21.Questions.WhatLanguageDoYouUseForTheBackend -> Evergreen.V22.Questions.WhatLanguageDoYouUseForBackend
migrateWhatLanguageDoYouUseForTheBackend old =
    case old of
        Evergreen.V21.Questions.JavaScript_ ->
            Evergreen.V22.Questions.JavaScript_

        Evergreen.V21.Questions.TypeScript_ ->
            Evergreen.V22.Questions.TypeScript_

        Evergreen.V21.Questions.Go_ ->
            Evergreen.V22.Questions.Go_

        Evergreen.V21.Questions.Haskell_ ->
            Evergreen.V22.Questions.Haskell_

        Evergreen.V21.Questions.CSharp_ ->
            Evergreen.V22.Questions.CSharp_

        Evergreen.V21.Questions.OCaml_ ->
            Evergreen.V22.Questions.OCaml_

        Evergreen.V21.Questions.Python_ ->
            Evergreen.V22.Questions.Python_

        Evergreen.V21.Questions.PHP_ ->
            Evergreen.V22.Questions.PHP_

        Evergreen.V21.Questions.Java_ ->
            Evergreen.V22.Questions.Java_

        Evergreen.V21.Questions.Ruby_ ->
            Evergreen.V22.Questions.Ruby_

        Evergreen.V21.Questions.Elixir_ ->
            Evergreen.V22.Questions.Elixir_

        Evergreen.V21.Questions.Clojure_ ->
            Evergreen.V22.Questions.Clojure_

        Evergreen.V21.Questions.Rust_ ->
            Evergreen.V22.Questions.Rust_

        Evergreen.V21.Questions.FSharp_ ->
            Evergreen.V22.Questions.FSharp_

        Evergreen.V21.Questions.AlsoElm ->
            Evergreen.V22.Questions.AlsoElm

        Evergreen.V21.Questions.NotApplicable ->
            Evergreen.V22.Questions.NotApplicable


migrateWhereDoYouUseElm : Evergreen.V21.Questions.WhereDoYouUseElm -> Evergreen.V22.Questions.ApplicationDomains
migrateWhereDoYouUseElm old =
    case old of
        Evergreen.V21.Questions.Education ->
            Evergreen.V22.Questions.Education

        Evergreen.V21.Questions.Gaming ->
            Evergreen.V22.Questions.Gaming

        Evergreen.V21.Questions.ECommerce ->
            Evergreen.V22.Questions.ECommerce

        Evergreen.V21.Questions.Music ->
            Evergreen.V22.Questions.Music

        Evergreen.V21.Questions.Finance ->
            Evergreen.V22.Questions.Finance

        Evergreen.V21.Questions.Health ->
            Evergreen.V22.Questions.Health

        Evergreen.V21.Questions.Productivity ->
            Evergreen.V22.Questions.Productivity

        Evergreen.V21.Questions.Communication ->
            Evergreen.V22.Questions.Communication

        Evergreen.V21.Questions.DataVisualization ->
            Evergreen.V22.Questions.DataVisualization

        Evergreen.V21.Questions.Transportation ->
            Evergreen.V22.Questions.Transportation


migrateWhichElmReviewRulesDoYouUse : Evergreen.V21.Questions.WhichElmReviewRulesDoYouUse -> Evergreen.V22.Questions.WhichElmReviewRulesDoYouUse
migrateWhichElmReviewRulesDoYouUse old =
    case old of
        Evergreen.V21.Questions.ElmReviewUnused ->
            Evergreen.V22.Questions.ElmReviewUnused

        Evergreen.V21.Questions.ElmReviewSimplify ->
            Evergreen.V22.Questions.ElmReviewSimplify

        Evergreen.V21.Questions.ElmReviewLicense ->
            Evergreen.V22.Questions.ElmReviewLicense

        Evergreen.V21.Questions.ElmReviewDebug ->
            Evergreen.V22.Questions.ElmReviewDebug

        Evergreen.V21.Questions.ElmReviewCommon ->
            Evergreen.V22.Questions.ElmReviewCommon

        Evergreen.V21.Questions.ElmReviewCognitiveComplexity ->
            Evergreen.V22.Questions.ElmReviewCognitiveComplexity


migrateAdminLoginData : Evergreen.V21.AdminPage.AdminLoginData -> Evergreen.V22.AdminPage.AdminLoginData
migrateAdminLoginData old =
    { forms = List.map (\a -> { form = migrateForm a.form, submitTime = a.submitTime }) old.forms
    , formMapping = initFormOtherQuestions
    }


initFormOtherQuestions : Evergreen.V22.Form.FormOtherQuestions
initFormOtherQuestions =
    { doYouUseElm = ""
    , age = ""
    , functionalProgrammingExperience = ""
    , otherLanguages = answerMapInit otherLanguages
    , newsAndDiscussions = answerMapInit newsAndDiscussions
    , elmResources = answerMapInit elmResources
    , countryLivingIn = ""
    , applicationDomains = answerMapInit applicationDomains
    , doYouUseElmAtWork = ""
    , howLargeIsTheCompany = ""
    , whatLanguageDoYouUseForBackend = answerMapInit whatLanguageDoYouUseForBackend
    , howLong = ""
    , elmVersion = answerMapInit elmVersion
    , doYouUseElmFormat = ""
    , stylingTools = answerMapInit stylingTools
    , buildTools = answerMapInit buildTools
    , frameworks = answerMapInit frameworks
    , editors = answerMapInit editors
    , doYouUseElmReview = ""
    , whichElmReviewRulesDoYouUse = answerMapInit whichElmReviewRulesDoYouUse
    , testTools = answerMapInit testTools
    , testsWrittenFor = answerMapInit testsWrittenFor
    , elmInitialInterest = freeTextAnswerMapInit
    , biggestPainPoint = freeTextAnswerMapInit
    , whatDoYouLikeMost = freeTextAnswerMapInit
    }


freeTextAnswerMapInit : Evergreen.V22.FreeTextAnswerMap.FreeTextAnswerMap
freeTextAnswerMapInit =
    Evergreen.V22.FreeTextAnswerMap.FreeTextAnswerMap { otherMapping = [], comment = "" }


doYouUseElm : Question Evergreen.V22.Questions.DoYouUseElm
doYouUseElm =
    { title = "Do you use Elm?"
    , choices =
        Nonempty
            YesAtWork
            [ YesInSideProjects
            , YesAsAStudent
            , IUsedToButIDontAnymore
            , NoButImCuriousAboutIt
            , NoAndIDontPlanTo
            ]
    , choiceToString =
        \a ->
            case a of
                YesAtWork ->
                    "Yes, at work"

                YesInSideProjects ->
                    "Yes, in side projects"

                YesAsAStudent ->
                    "Yes, as a student"

                IUsedToButIDontAnymore ->
                    "I used to, but I don't anymore"

                NoButImCuriousAboutIt ->
                    "No, but I'm curious about it"

                NoAndIDontPlanTo ->
                    "No, and I don't plan to"
    }


age : Question Age
age =
    { title = "How old are you?"
    , choices =
        Nonempty Under10
            [ Age10To19
            , Age20To29
            , Age30To39
            , Age40To49
            , Age50To59
            , Over60
            ]
    , choiceToString =
        \a ->
            case a of
                Under10 ->
                    "Younger than 10"

                Age10To19 ->
                    "Between 10 and 19"

                Age20To29 ->
                    "Between 20 and 29"

                Age30To39 ->
                    "Between 30 and 39"

                Age40To49 ->
                    "Between 40 and 49"

                Age50To59 ->
                    "Between 50 and 59"

                Over60 ->
                    "60 years or older"
    }


experienceLevel : Question ExperienceLevel
experienceLevel =
    { title = "What is your level of experience with functional programming?"
    , choices =
        Nonempty
            Beginner
            [ Intermediate
            , Professional
            , Expert
            ]
    , choiceToString =
        \a ->
            case a of
                Beginner ->
                    "I'm a beginner"

                Intermediate ->
                    "Intermediate"

                Professional ->
                    "I'm good enough to use it professionally"

                Expert ->
                    "I'm an expert and could probably give a talk on category theory"
    }


otherLanguages : Question OtherLanguages
otherLanguages =
    { title = "What programming languages, other than Elm, are you most familiar with?"
    , choices =
        Nonempty
            C
            [ CSharp
            , CPlusPlus
            , Clojure
            , Elixir
            , FSharp
            , Go
            , Haskell
            , Java
            , JavaScript
            , OCaml
            , PHP
            , Python
            , Ruby
            , Rust
            , Swift
            , TypeScript
            ]
    , choiceToString =
        \a ->
            case a of
                JavaScript ->
                    "JavaScript"

                TypeScript ->
                    "TypeScript"

                Go ->
                    "Go"

                Haskell ->
                    "Haskell"

                CSharp ->
                    "C#"

                C ->
                    "C"

                CPlusPlus ->
                    "C++"

                OCaml ->
                    "OCaml"

                Python ->
                    "Python"

                Swift ->
                    "Swift"

                PHP ->
                    "PHP"

                Java ->
                    "Java"

                Ruby ->
                    "Ruby"

                Elixir ->
                    "Elixir"

                Clojure ->
                    "Clojure"

                Rust ->
                    "Rust"

                FSharp ->
                    "F#"
    }


newsAndDiscussions : Question NewsAndDiscussions
newsAndDiscussions =
    { title = "Where do you go for Elm news and discussion?"
    , choices =
        Nonempty
            BlogPosts
            [ ElmDiscourse
            , ElmRadio
            , ElmSlack
            , ElmSubreddit
            , ElmWeekly
            , Facebook
            , Meetups
            , Twitter
            , DevTo
            , ElmNews
            , ElmCraft
            ]
    , choiceToString =
        \a ->
            case a of
                ElmDiscourse ->
                    "Elm Discourse"

                ElmSlack ->
                    "Elm Slack"

                ElmSubreddit ->
                    "Elm Subreddit"

                Twitter ->
                    "Twitter discussions"

                ElmRadio ->
                    "Elm Radio"

                BlogPosts ->
                    "Blog posts"

                Facebook ->
                    "Facebook groups"

                DevTo ->
                    "dev.to"

                Meetups ->
                    "Meetups"

                ElmWeekly ->
                    "Elm Weekly newsletter"

                ElmNews ->
                    "elm-news.com"

                ElmCraft ->
                    "elmcraft.org"
    }


elmResources : Question ElmResources
elmResources =
    { title = "What resources did you use to learn Elm?"
    , choices =
        Nonempty
            BeginningElmBook
            [ BuildingWebAppsWithElm
            , DailyDrip
            , EggheadCourses
            , ElmOnline
            , ElmSlack_
            , ElmForBeginners
            , ElmInActionBook
            , FrontendMasters
            , ProgrammingElmBook
            , StackOverflow
            , TheJsonSurvivalKit
            , WeeklyBeginnersElmSubreddit
            , GuideElmLang
            ]
    , choiceToString =
        \a ->
            case a of
                DailyDrip ->
                    "Daily Drip"

                ElmInActionBook ->
                    "Elm in Action (book)"

                WeeklyBeginnersElmSubreddit ->
                    "Weekly beginners threads on the Elm Subreddit"

                BeginningElmBook ->
                    "Beginning Elm (book)"

                StackOverflow ->
                    "StackOverflow"

                BuildingWebAppsWithElm ->
                    "Building Web Apps with Elm (Pragmatic Studio course)"

                TheJsonSurvivalKit ->
                    "The JSON Survival Kit (book)"

                EggheadCourses ->
                    "Egghead courses"

                ProgrammingElmBook ->
                    "Programming Elm (book)"

                GuideElmLang ->
                    "guide.elm-lang.org"

                ElmForBeginners ->
                    "Elm for Beginners (KnowThen course)"

                ElmSlack_ ->
                    "Elm Slack"

                FrontendMasters ->
                    "Frontend Masters"

                ElmOnline ->
                    "Elm Online"
    }


countryLivingIn : Question Country
countryLivingIn =
    { title = "Which country do you live in?"
    , choices =
        let
            overrides : Dict String Country
            overrides =
                Dict.fromList
                    [ ( "TW", { name = "Taiwan", code = "TW", flag = "🇹🇼" } ) ]
        in
        List.map
            (\country ->
                Dict.get country.code overrides
                    |> Maybe.withDefault country
            )
            Countries.all
            |> List.Nonempty.fromList
            |> Maybe.withDefault (Nonempty { name = "", code = "", flag = "" } [])
    , choiceToString =
        \{ name, flag } ->
            (case name of
                "United Kingdom of Great Britain and Northern Ireland" ->
                    "United Kingdom"

                "United States of America" ->
                    "United States"

                "Russian Federation" ->
                    "Russia"

                "Bosnia and Herzegovina" ->
                    "Bosnia"

                "Iran (Islamic Republic of)" ->
                    "Iran"

                "Venezuela (Bolivarian Republic of)" ->
                    "Venezuela"

                "Trinidad and Tobago" ->
                    "Trinidad"

                "Viet Nam" ->
                    "Vietnam"

                _ ->
                    name
            )
                ++ " "
                ++ flag
    }


applicationDomains : Question ApplicationDomains
applicationDomains =
    { title = "In which application domains, if any, have you used Elm?"
    , choices =
        Nonempty
            Communication
            [ DataVisualization
            , ECommerce
            , Education
            , Finance
            , Gaming
            , Health
            , Music
            , Productivity
            , Transportation
            ]
    , choiceToString =
        \a ->
            case a of
                Education ->
                    "Education"

                Gaming ->
                    "Gaming"

                ECommerce ->
                    "E-commerce"

                Music ->
                    "Music"

                Finance ->
                    "Finance"

                Health ->
                    "Health"

                Productivity ->
                    "Productivity"

                Communication ->
                    "Communication"

                DataVisualization ->
                    "Data visualization"

                Transportation ->
                    "Transportation"
    }


doYouUseElmAtWork : Question DoYouUseElmAtWork
doYouUseElmAtWork =
    { title = "Do you use Elm at work?"
    , choices =
        Nonempty NotInterestedInElmAtWork
            [ WouldLikeToUseElmAtWork
            , HaveTriedElmInAWorkProject
            , MyTeamMostlyWritesNewCodeInElm
            , NotEmployed
            ]
    , choiceToString =
        \a ->
            case a of
                NotInterestedInElmAtWork ->
                    "No, and I'm not interested"

                WouldLikeToUseElmAtWork ->
                    "No, but I am interested"

                HaveTriedElmInAWorkProject ->
                    "I have tried Elm at work"

                MyTeamMostlyWritesNewCodeInElm ->
                    "My team mostly writes new code in Elm"

                NotEmployed ->
                    "Not employed"
    }


howLargeIsTheCompany : Question HowLargeIsTheCompany
howLargeIsTheCompany =
    { title = "How large is the company you work at?"
    , choices =
        Nonempty Size1To10Employees
            [ Size11To50Employees
            , Size50To100Employees
            , Size100OrMore
            ]
    , choiceToString =
        \a ->
            case a of
                Size1To10Employees ->
                    "1 to 10 employees"

                Size11To50Employees ->
                    "11 to 50 employees"

                Size50To100Employees ->
                    "50 to 100 employees"

                Size100OrMore ->
                    "100+ employees"
    }


whatLanguageDoYouUseForBackend : Question WhatLanguageDoYouUseForBackend
whatLanguageDoYouUseForBackend =
    { title = "What languages does your company use on the backend?"
    , choices =
        Nonempty JavaScript_
            [ TypeScript_
            , Go_
            , Haskell_
            , CSharp_
            , OCaml_
            , Python_
            , PHP_
            , Java_
            , Ruby_
            , Elixir_
            , Clojure_
            , Rust_
            , FSharp_
            , AlsoElm
            , NotApplicable
            ]
    , choiceToString =
        \a ->
            case a of
                JavaScript_ ->
                    "JavaScript"

                TypeScript_ ->
                    "TypeScript"

                Go_ ->
                    "Go"

                Haskell_ ->
                    "Haskell"

                CSharp_ ->
                    "C#"

                OCaml_ ->
                    "OCaml"

                Python_ ->
                    "Python"

                PHP_ ->
                    "PHP"

                Java_ ->
                    "Java"

                Ruby_ ->
                    "Ruby"

                Elixir_ ->
                    "Elixir"

                Clojure_ ->
                    "Clojure"

                Rust_ ->
                    "Rust"

                FSharp_ ->
                    "F#"

                AlsoElm ->
                    "Elm"

                NotApplicable ->
                    "Not applicable"
    }


howLong : Question HowLong
howLong =
    { title = "How long have you been using Elm?"
    , choices =
        Nonempty
            Under3Months
            [ Between3MonthsAndAYear
            , OneYear
            , TwoYears
            , ThreeYears
            , FourYears
            , FiveYears
            , SixYears
            , SevenYears
            , EightYears
            , NineYears
            ]
    , choiceToString =
        \a ->
            case a of
                Under3Months ->
                    "Under three months"

                Between3MonthsAndAYear ->
                    "Between three months and a year"

                OneYear ->
                    "1 year"

                TwoYears ->
                    "2 years"

                ThreeYears ->
                    "3 years"

                FourYears ->
                    "4 years"

                FiveYears ->
                    "5 years"

                SixYears ->
                    "6 years"

                SevenYears ->
                    "7 years"

                EightYears ->
                    "8 years"

                NineYears ->
                    "9 years"
    }


elmVersion : Question ElmVersion
elmVersion =
    { title = "What versions of Elm are you using?"
    , choices = Nonempty Version0_19 [ Version0_18, Version0_17, Version0_16 ]
    , choiceToString =
        \a ->
            case a of
                Version0_19 ->
                    "0.19 or 0.19.1"

                Version0_18 ->
                    "0.18"

                Version0_17 ->
                    "0.17"

                Version0_16 ->
                    "0.16"
    }


doYouUseElmFormat : Question DoYouUseElmFormat
doYouUseElmFormat =
    { title = "Do you format your code with elm-format?"
    , choices =
        Nonempty PreferElmFormat
            [ TriedButDontUseElmFormat
            , HeardButDontUseElmFormat
            , HaveNotHeardOfElmFormat
            ]
    , choiceToString =
        \a ->
            case a of
                PreferElmFormat ->
                    "I prefer to use elm-format"

                TriedButDontUseElmFormat ->
                    "I have tried elm-format, but prefer to not use it"

                HeardButDontUseElmFormat ->
                    "I have heard of elm-format, but have not used it"

                HaveNotHeardOfElmFormat ->
                    "I have not previously heard of elm-format"
    }


stylingTools : Question StylingTools
stylingTools =
    { title = "What tools or libraries do you use to style your Elm applications?"
    , choices =
        Nonempty Bootstrap
            [ SassOrScss
            , Tailwind
            , ElmCss
            , ElmTailwindModules
            , ElmUi
            , PlainCss
            ]
    , choiceToString =
        \a ->
            case a of
                SassOrScss ->
                    "SASS/SCSS"

                ElmCss ->
                    "elm-css"

                PlainCss ->
                    "plain CSS"

                ElmUi ->
                    "elm-ui"

                Tailwind ->
                    "Tailwind"

                Bootstrap ->
                    "Bootstrap"

                ElmTailwindModules ->
                    "elm-tailwind-modules"
    }


buildTools : Question BuildTools
buildTools =
    { title = "What tools do you use to build your Elm applications?"
    , choices =
        Nonempty Brunch
            [ Gulp
            , Make
            , Parcel
            , ShellScripts
            , Vite
            , Webpack
            , CreateElmApp
            , ElmLive
            , ElmMakeStandalone
            , ElmReactor
            ]
    , choiceToString =
        \a ->
            case a of
                ShellScripts ->
                    "Shell scripts"

                ElmLive ->
                    "elm-live"

                CreateElmApp ->
                    "create-elm-app"

                Webpack ->
                    "Webpack"

                Brunch ->
                    "Brunch"

                ElmMakeStandalone ->
                    "elm-make standalone"

                Gulp ->
                    "Gulp"

                Make ->
                    "Make"

                ElmReactor ->
                    "elm-reactor"

                Parcel ->
                    "Parcel"

                Vite ->
                    "Vite"
    }


frameworks : Question Frameworks
frameworks =
    { title = "What frameworks do you use?"
    , choices = Nonempty Lamdera_ [ ElmPages, ElmPlayground, ElmSpa ]
    , choiceToString =
        \a ->
            case a of
                Lamdera_ ->
                    "Lamdera"

                ElmSpa ->
                    "elm-spa"

                ElmPages ->
                    "elm-pages"

                ElmPlayground ->
                    "elm-playground"
    }


editors : Question Editors
editors =
    { title = "What editor(s) do you use to write your Elm applications?"
    , choices =
        Nonempty Atom
            [ Emacs
            , Intellij
            , SublimeText
            , VSCode
            , Vim
            ]
    , choiceToString =
        \a ->
            case a of
                SublimeText ->
                    "Sublime Text"

                Vim ->
                    "Vim"

                Atom ->
                    "Atom"

                Emacs ->
                    "Emacs"

                VSCode ->
                    "VSCode"

                Intellij ->
                    "Intellij"
    }


doYouUseElmReview : Question DoYouUseElmReview
doYouUseElmReview =
    { title = "Do you use elm-review?"
    , choices =
        Nonempty NeverHeardOfElmReview
            [ HeardOfItButNeverTriedElmReview
            , IveTriedElmReview
            , IUseElmReviewRegularly
            ]
    , choiceToString =
        \a ->
            case a of
                NeverHeardOfElmReview ->
                    "I've never heard of it"

                HeardOfItButNeverTriedElmReview ->
                    "I've heard of it but never tried it"

                IveTriedElmReview ->
                    "I use elm-review infrequently"

                IUseElmReviewRegularly ->
                    "I use elm-review regularly"
    }


whichElmReviewRulesDoYouUse : Question WhichElmReviewRulesDoYouUse
whichElmReviewRulesDoYouUse =
    { title = "Which elm-review rules do you use?"
    , choices =
        Nonempty ElmReviewUnused
            [ ElmReviewSimplify
            , ElmReviewLicense
            , ElmReviewDebug
            , ElmReviewCommon
            , ElmReviewCognitiveComplexity
            ]
    , choiceToString =
        \a ->
            case a of
                ElmReviewUnused ->
                    "elm-review-unused"

                ElmReviewSimplify ->
                    "elm-review-simplify"

                ElmReviewLicense ->
                    "elm-review-license"

                ElmReviewDebug ->
                    "elm-review-debug"

                ElmReviewCommon ->
                    "elm-review-common"

                ElmReviewCognitiveComplexity ->
                    "elm-review-cognitive-complexity"
    }


testTools : Question TestTools
testTools =
    { title = "What tools do you use to test your Elm projects?"
    , choices =
        Nonempty BrowserAcceptanceTests
            [ ElmBenchmark
            , ElmTest
            , ElmProgramTest
            , VisualRegressionTests
            ]
    , choiceToString =
        \a ->
            case a of
                BrowserAcceptanceTests ->
                    "Browser acceptance testing (e.g. Capybara)"

                ElmBenchmark ->
                    "elm-benchmark"

                ElmTest ->
                    "elm-test"

                ElmProgramTest ->
                    "elm-program-test"

                VisualRegressionTests ->
                    "Visual regression testing (e.g. Percy.io)"
    }


testsWrittenFor : Question TestsWrittenFor
testsWrittenFor =
    { title = "What do you write tests for in your Elm projects?"
    , choices =
        Nonempty ComplicatedFunctions
            [ FunctionsThatReturnCmds
            , AllPublicFunctions
            , HtmlFunctions
            , JsonDecodersAndEncoders
            , MostPublicFunctions
            ]
    , choiceToString =
        \a ->
            case a of
                ComplicatedFunctions ->
                    "Your most complicated functions"

                FunctionsThatReturnCmds ->
                    "Functions that return Cmd"

                AllPublicFunctions ->
                    "All public functions in your modules"

                HtmlFunctions ->
                    "Functions that return Html"

                JsonDecodersAndEncoders ->
                    "JSON encoders/decoders"

                MostPublicFunctions ->
                    "Most public functions in your modules"
    }


answerMapInit : Question a -> Evergreen.V22.AnswerMap.AnswerMap a
answerMapInit question =
    { otherMapping = []
    , existingMapping =
        (List.Nonempty.length question.choices - 1)
            |> List.range 0
            |> List.map
                (\index ->
                    List.Nonempty.get index question.choices
                        |> question.choiceToString
                        |> otherAnswer
                        |> List.singleton
                        |> Set.fromList
                )
    , comment = ""
    }
        |> Evergreen.V22.AnswerMap.AnswerMap


otherAnswer : String -> Evergreen.V22.AnswerMap.OtherAnswer
otherAnswer =
    normalizeOtherAnswer >> Evergreen.V22.AnswerMap.OtherAnswer


normalizeOtherAnswer : String -> String
normalizeOtherAnswer =
    String.trim >> String.toLower


migrateDict : (keyA -> keyB) -> (valueA -> valueB) -> Dict keyA valueA -> Dict keyB valueB
migrateDict migrateKey migrateValue dict =
    Dict.toList dict |> List.map (Tuple.mapBoth migrateKey migrateValue) |> Dict.fromList


migrateBackendModel : Old.BackendModel -> New.BackendModel
migrateBackendModel old =
    { forms =
        Dict.map
            (\_ value ->
                { form = migrateForm value.form
                , submitTime = value.submitTime
                }
            )
            old.forms
    , answerMap = initFormOtherQuestions
    , adminLogin = old.adminLogin
    }


migrateBackendMsg : Old.BackendMsg -> New.BackendMsg
migrateBackendMsg old =
    case old of
        Old.UserConnected a b ->
            New.UserConnected a b

        Old.GotTimeWithUpdate a b c d ->
            New.GotTimeWithUpdate a b (migrateToBackend c) d

        Old.GotTimeWithLoadFormData a b c ->
            New.GotTimeWithLoadFormData a b c


migrateForm : Evergreen.V21.Form.Form -> Evergreen.V22.Form.Form
migrateForm old =
    { doYouUseElm = Set.map migrateDoYouUseElm old.doYouUseElm
    , age = Maybe.map migrateAge old.age
    , functionalProgrammingExperience = Maybe.map migrateExperienceLevel old.functionalProgrammingExperience
    , otherLanguages = migrateMultiChoiceWithOther migrateOtherLanguages old.otherLanguages
    , newsAndDiscussions = migrateMultiChoiceWithOther migrateNewsAndDiscussions old.newsAndDiscussions
    , elmResources = migrateMultiChoiceWithOther migrateElmResources old.elmResources
    , countryLivingIn = old.countryLivingIn
    , applicationDomains = migrateMultiChoiceWithOther migrateWhereDoYouUseElm old.applicationDomains
    , doYouUseElmAtWork = Maybe.map migrateDoYouUseElmAtWork old.doYouUseElmAtWork
    , howLargeIsTheCompany = Maybe.map migrateHowLargeIsTheCompany old.howLargeIsTheCompany
    , whatLanguageDoYouUseForBackend =
        migrateMultiChoiceWithOther migrateWhatLanguageDoYouUseForTheBackend old.whatLanguageDoYouUseForBackend
    , howLong = Maybe.map migrateHowLong old.howLong
    , elmVersion = migrateMultiChoiceWithOther migrateWhatElmVersion old.elmVersion
    , doYouUseElmFormat = Maybe.map migrateDoYouUseElmFormat old.doYouUseElmFormat
    , stylingTools = migrateMultiChoiceWithOther migrateStylingTools old.stylingTools
    , buildTools = migrateMultiChoiceWithOtherFilter migrateBuildTools old.buildTools
    , frameworks = migrateMultiChoiceWithOther migrateFrameworks old.frameworks
    , editors = migrateMultiChoiceWithOther migrateEditor old.editors
    , doYouUseElmReview = Maybe.map migrateDoYouUseElmReview old.doYouUseElmReview
    , whichElmReviewRulesDoYouUse =
        migrateMultiChoiceWithOther migrateWhichElmReviewRulesDoYouUse old.whichElmReviewRulesDoYouUse
    , testTools = migrateMultiChoiceWithOther migrateTestTools old.testTools
    , testsWrittenFor = migrateMultiChoiceWithOther migrateTestsWrittenFor old.testsWrittenFor
    , elmInitialInterest = old.elmInitialInterest
    , biggestPainPoint = old.biggestPainPoint
    , whatDoYouLikeMost = old.whatDoYouLikeMost
    , emailAddress = old.emailAddress
    }


migrateMultiChoiceWithOther migrateFunc old =
    { choices = Set.map migrateFunc old.choices
    , otherChecked = old.otherChecked
    , otherText = old.otherText
    }


migrateMultiChoiceWithOtherFilter migrateFilterFunc old =
    { choices = Set.toList old.choices |> List.filterMap migrateFilterFunc |> Set.fromList
    , otherChecked = old.otherChecked
    , otherText = old.otherText
    }


migrateFormLoaded_ : Old.FormLoaded_ -> New.FormLoaded_
migrateFormLoaded_ old =
    { form = migrateForm old.form
    , acceptedTos = old.acceptedTos
    , submitting = old.submitting
    , pressedSubmitCount = old.pressedSubmitCount
    , debounceCounter = old.debounceCounter
    , windowSize = { width = 1920, height = 1080 }
    , time = Time.millisToPosix 0
    }


migrateFrontendModel : Old.FrontendModel -> New.FrontendModel
migrateFrontendModel old =
    case old of
        Old.Loading a b ->
            New.Loading a b

        Old.FormLoaded a ->
            New.FormLoaded (migrateFormLoaded_ a)

        Old.FormCompleted a ->
            New.FormCompleted a

        Old.AdminLogin a ->
            New.AdminLogin { password = identity a.password, loginFailed = identity a.loginFailed }

        Old.Admin a ->
            New.Admin
                { forms = List.map (\{ form, submitTime } -> { form = migrateForm form, submitTime = submitTime }) a.forms
                , formMapping = initFormOtherQuestions
                , selectedMapping = Evergreen.V22.Form.AgeQuestion
                , showEncodedState = False
                , debounceCount = 0
                }

        Old.SurveyResultsLoaded data ->
            New.SurveyResultsLoaded
                { windowSize = { width = 1920, height = 1080 }
                , data = migrateSurveyResultsData data
                }


migrateFrontendMsg : Old.FrontendMsg -> New.FrontendMsg
migrateFrontendMsg old =
    case old of
        Old.UrlClicked a ->
            New.UrlClicked a

        Old.UrlChanged ->
            New.UrlChanged

        Old.FormChanged a ->
            New.FormChanged (migrateForm a)

        Old.PressedAcceptTosAnswer a ->
            New.PressedAcceptTosAnswer a

        Old.PressedSubmitSurvey ->
            New.PressedSubmitSurvey

        Old.Debounce a ->
            New.Debounce a

        Old.TypedPassword a ->
            New.TypedPassword a

        Old.PressedLogin ->
            New.PressedLogin

        Old.GotWindowSize size ->
            New.GotWindowSize size

        Old.GotTime a ->
            New.GotTime a

        Old.AdminPageMsg msg ->
            migrateAdminPageMsg msg |> New.AdminPageMsg


migrateAdminPageMsg : Evergreen.V21.AdminPage.Msg -> Evergreen.V22.AdminPage.Msg
migrateAdminPageMsg msg =
    case msg of
        Evergreen.V21.AdminPage.PressedLogOut ->
            Evergreen.V22.AdminPage.PressedLogOut

        Evergreen.V21.AdminPage.TypedFormsData string ->
            Evergreen.V22.AdminPage.TypedFormsData string


migrateLoadFormStatus : Old.LoadFormStatus -> New.LoadFormStatus
migrateLoadFormStatus old =
    case old of
        Old.NoFormFound ->
            New.NoFormFound

        Old.FormAutoSaved a ->
            New.FormAutoSaved (migrateForm a)

        Old.FormSubmitted ->
            New.FormSubmitted

        Old.SurveyResults data ->
            New.SurveyResults (migrateSurveyResultsData data)

        Old.AwaitingResultsData ->
            New.AwaitingResultsData


migrateSurveyResultsData : Evergreen.V21.SurveyResults.Data -> Evergreen.V22.SurveyResults.Data
migrateSurveyResultsData old =
    { doYouUseElm = migrateDataEntry old.doYouUseElm
    , age = migrateDataEntry old.age
    , functionalProgrammingExperience = migrateDataEntry old.functionalProgrammingExperience
    , otherLanguages = initDataEntryWithOther
    , newsAndDiscussions = initDataEntryWithOther
    , elmResources = initDataEntryWithOther
    , countryLivingIn =
        Evergreen.V22.DataEntry.DataEntry
            { data = List.range 0 (List.length Countries.all - 2) |> List.map (always 0) |> Nonempty 0
            , comment = ""
            }
    , doYouUseElmAtWork = migrateDataEntry old.doYouUseElmAtWork
    , applicationDomains = initDataEntryWithOther
    , howLargeIsTheCompany = migrateDataEntry old.howLargeIsTheCompany
    , whatLanguageDoYouUseForBackend = initDataEntryWithOther
    , howLong = migrateDataEntry old.howLong
    , elmVersion = initDataEntryWithOther
    , doYouUseElmFormat = migrateDataEntry old.doYouUseElmFormat
    , stylingTools = initDataEntryWithOther
    , buildTools = initDataEntryWithOther
    , frameworks = initDataEntryWithOther
    , editors = initDataEntryWithOther
    , doYouUseElmReview = migrateDataEntry old.doYouUseElmReview
    , whichElmReviewRulesDoYouUse = initDataEntryWithOther
    , testTools = initDataEntryWithOther
    , testsWrittenFor = initDataEntryWithOther
    , elmInitialInterest = initDataEntryWithOther
    , biggestPainPoint = initDataEntryWithOther
    , whatDoYouLikeMost = initDataEntryWithOther
    }


initDataEntryWithOther =
    Evergreen.V22.DataEntry.DataEntryWithOther
        { data = Dict.empty
        , comment = ""
        }


migrateDataEntry : Evergreen.V21.DataEntry.DataEntry a -> Evergreen.V22.DataEntry.DataEntry b
migrateDataEntry (Evergreen.V21.DataEntry.DataEntry old) =
    Evergreen.V22.DataEntry.DataEntry
        { data = old
        , comment = ""
        }


migrateToBackend : Old.ToBackend -> New.ToBackend
migrateToBackend old =
    case old of
        Old.AutoSaveForm a ->
            New.AutoSaveForm (migrateForm a)

        Old.SubmitForm a ->
            New.SubmitForm (migrateForm a)

        Old.AdminLoginRequest a ->
            New.AdminLoginRequest a

        Old.AdminToBackend a ->
            migrateAdminToBackend a |> New.AdminToBackend


migrateAdminToBackend : Evergreen.V21.AdminPage.ToBackend -> Evergreen.V22.AdminPage.ToBackend
migrateAdminToBackend old =
    case old of
        Evergreen.V21.AdminPage.ReplaceFormsRequest forms ->
            Evergreen.V22.AdminPage.ReplaceFormsRequest (List.map migrateForm forms)

        Evergreen.V21.AdminPage.LogOutRequest ->
            Evergreen.V22.AdminPage.LogOutRequest


migrateToFrontend : Old.ToFrontend -> New.ToFrontend
migrateToFrontend old =
    case old of
        Old.LoadForm a ->
            New.LoadForm (migrateLoadFormStatus a)

        Old.LoadAdmin a ->
            New.LoadAdmin (migrateAdminLoginData a)

        Old.AdminLoginResponse a ->
            New.AdminLoginResponse (Result.map migrateAdminLoginData a)

        Old.SubmitConfirmed ->
            New.SubmitConfirmed

        Old.LogOutResponse loadFormStatus ->
            New.LogOutResponse (migrateLoadFormStatus loadFormStatus)


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    ModelMigrated ( migrateFrontendModel old, Cmd.none )


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelMigrated ( migrateBackendModel old, Cmd.none )


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    MsgMigrated ( migrateFrontendMsg old, Cmd.none )


toBackend : Old.ToBackend -> MsgMigration New.ToBackend New.BackendMsg
toBackend old =
    MsgMigrated ( migrateToBackend old, Cmd.none )


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg old =
    MsgMigrated ( migrateBackendMsg old, Cmd.none )


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend old =
    MsgMigrated ( migrateToFrontend old, Cmd.none )
