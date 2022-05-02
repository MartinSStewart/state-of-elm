module Evergreen.Migrate.V27 exposing (..)

import AssocList as Dict exposing (Dict)
import AssocSet as Set
import Countries exposing (Country)
import Evergreen.V24.AdminPage
import Evergreen.V24.AnswerMap
import Evergreen.V24.DataEntry
import Evergreen.V24.Form
import Evergreen.V24.FreeTextAnswerMap
import Evergreen.V24.NetworkModel
import Evergreen.V24.Questions
import Evergreen.V24.SurveyResults
import Evergreen.V24.Types as Old
import Evergreen.V27.AdminPage
import Evergreen.V27.AnswerMap
import Evergreen.V27.DataEntry
import Evergreen.V27.Form
import Evergreen.V27.FreeTextAnswerMap
import Evergreen.V27.NetworkModel
import Evergreen.V27.Questions exposing (Age(..), ApplicationDomains(..), BuildTools(..), DoYouUseElm(..), DoYouUseElmAtWork(..), DoYouUseElmFormat(..), DoYouUseElmReview(..), Editors(..), ElmResources(..), ElmVersion(..), ExperienceLevel(..), Frameworks(..), HowLargeIsTheCompany(..), HowLong(..), NewsAndDiscussions(..), OtherLanguages(..), StylingTools(..), TestTools(..), TestsWrittenFor(..), WhatLanguageDoYouUseForBackend(..), WhichElmReviewRulesDoYouUse(..))
import Evergreen.V27.SurveyResults
import Evergreen.V27.Types as New
import Lamdera.Migrations exposing (..)
import List.Nonempty exposing (Nonempty(..))
import Questions exposing (Question)
import Time


migrateAge : Evergreen.V24.Questions.Age -> Evergreen.V27.Questions.Age
migrateAge old =
    case old of
        Evergreen.V24.Questions.Under10 ->
            Evergreen.V27.Questions.Under10

        Evergreen.V24.Questions.Age10To19 ->
            Evergreen.V27.Questions.Age10To19

        Evergreen.V24.Questions.Age20To29 ->
            Evergreen.V27.Questions.Age20To29

        Evergreen.V24.Questions.Age30To39 ->
            Evergreen.V27.Questions.Age30To39

        Evergreen.V24.Questions.Age40To49 ->
            Evergreen.V27.Questions.Age40To49

        Evergreen.V24.Questions.Age50To59 ->
            Evergreen.V27.Questions.Age50To59

        Evergreen.V24.Questions.Over60 ->
            Evergreen.V27.Questions.Over60


migrateBuildTools : Evergreen.V24.Questions.BuildTools -> Maybe Evergreen.V27.Questions.BuildTools
migrateBuildTools old =
    case old of
        Evergreen.V24.Questions.ShellScripts ->
            Just Evergreen.V27.Questions.ShellScripts

        Evergreen.V24.Questions.ElmLive ->
            Just Evergreen.V27.Questions.ElmLive

        Evergreen.V24.Questions.CreateElmApp ->
            Just Evergreen.V27.Questions.CreateElmApp

        Evergreen.V24.Questions.Webpack ->
            Just Evergreen.V27.Questions.Webpack

        Evergreen.V24.Questions.Brunch ->
            Just Evergreen.V27.Questions.Brunch

        Evergreen.V24.Questions.ElmMakeStandalone ->
            Just Evergreen.V27.Questions.ElmMakeStandalone

        Evergreen.V24.Questions.Gulp ->
            Just Evergreen.V27.Questions.Gulp

        Evergreen.V24.Questions.Make ->
            Just Evergreen.V27.Questions.Make

        Evergreen.V24.Questions.ElmReactor ->
            Just Evergreen.V27.Questions.ElmReactor

        Evergreen.V24.Questions.Parcel ->
            Just Evergreen.V27.Questions.Parcel

        Evergreen.V24.Questions.Vite ->
            Just Evergreen.V27.Questions.Vite


migrateDoYouUseElm : Evergreen.V24.Questions.DoYouUseElm -> Evergreen.V27.Questions.DoYouUseElm
migrateDoYouUseElm old =
    case old of
        Evergreen.V24.Questions.YesAtWork ->
            Evergreen.V27.Questions.YesAtWork

        Evergreen.V24.Questions.YesInSideProjects ->
            Evergreen.V27.Questions.YesInSideProjects

        Evergreen.V24.Questions.YesAsAStudent ->
            Evergreen.V27.Questions.YesAsAStudent

        Evergreen.V24.Questions.IUsedToButIDontAnymore ->
            Evergreen.V27.Questions.IUsedToButIDontAnymore

        Evergreen.V24.Questions.NoButImCuriousAboutIt ->
            Evergreen.V27.Questions.NoButImCuriousAboutIt

        Evergreen.V24.Questions.NoAndIDontPlanTo ->
            Evergreen.V27.Questions.NoAndIDontPlanTo


migrateDoYouUseElmAtWork : Evergreen.V24.Questions.DoYouUseElmAtWork -> Evergreen.V27.Questions.DoYouUseElmAtWork
migrateDoYouUseElmAtWork old =
    case old of
        Evergreen.V24.Questions.NotInterestedInElmAtWork ->
            Evergreen.V27.Questions.NotInterestedInElmAtWork

        Evergreen.V24.Questions.WouldLikeToUseElmAtWork ->
            Evergreen.V27.Questions.WouldLikeToUseElmAtWork

        Evergreen.V24.Questions.HaveTriedElmInAWorkProject ->
            Evergreen.V27.Questions.HaveTriedElmInAWorkProject

        Evergreen.V24.Questions.MyTeamMostlyWritesNewCodeInElm ->
            Evergreen.V27.Questions.MyTeamMostlyWritesNewCodeInElm

        Evergreen.V24.Questions.NotEmployed ->
            Evergreen.V27.Questions.NotEmployed


migrateDoYouUseElmFormat : Evergreen.V24.Questions.DoYouUseElmFormat -> Evergreen.V27.Questions.DoYouUseElmFormat
migrateDoYouUseElmFormat old =
    case old of
        Evergreen.V24.Questions.PreferElmFormat ->
            Evergreen.V27.Questions.PreferElmFormat

        Evergreen.V24.Questions.TriedButDontUseElmFormat ->
            Evergreen.V27.Questions.TriedButDontUseElmFormat

        Evergreen.V24.Questions.HeardButDontUseElmFormat ->
            Evergreen.V27.Questions.HeardButDontUseElmFormat

        Evergreen.V24.Questions.HaveNotHeardOfElmFormat ->
            Evergreen.V27.Questions.HaveNotHeardOfElmFormat


migrateDoYouUseElmReview : Evergreen.V24.Questions.DoYouUseElmReview -> Evergreen.V27.Questions.DoYouUseElmReview
migrateDoYouUseElmReview old =
    case old of
        Evergreen.V24.Questions.NeverHeardOfElmReview ->
            Evergreen.V27.Questions.NeverHeardOfElmReview

        Evergreen.V24.Questions.HeardOfItButNeverTriedElmReview ->
            Evergreen.V27.Questions.HeardOfItButNeverTriedElmReview

        Evergreen.V24.Questions.IveTriedElmReview ->
            Evergreen.V27.Questions.IveTriedElmReview

        Evergreen.V24.Questions.IUseElmReviewRegularly ->
            Evergreen.V27.Questions.IUseElmReviewRegularly


migrateEditor : Evergreen.V24.Questions.Editors -> Evergreen.V27.Questions.Editors
migrateEditor old =
    case old of
        Evergreen.V24.Questions.SublimeText ->
            Evergreen.V27.Questions.SublimeText

        Evergreen.V24.Questions.Vim ->
            Evergreen.V27.Questions.Vim

        Evergreen.V24.Questions.Atom ->
            Evergreen.V27.Questions.Atom

        Evergreen.V24.Questions.Emacs ->
            Evergreen.V27.Questions.Emacs

        Evergreen.V24.Questions.VSCode ->
            Evergreen.V27.Questions.VSCode

        Evergreen.V24.Questions.Intellij ->
            Evergreen.V27.Questions.Intellij


migrateElmResources : Evergreen.V24.Questions.ElmResources -> Evergreen.V27.Questions.ElmResources
migrateElmResources old =
    case old of
        Evergreen.V24.Questions.DailyDrip ->
            Evergreen.V27.Questions.DailyDrip

        Evergreen.V24.Questions.ElmInActionBook ->
            Evergreen.V27.Questions.ElmInActionBook

        Evergreen.V24.Questions.WeeklyBeginnersElmSubreddit ->
            Evergreen.V27.Questions.WeeklyBeginnersElmSubreddit

        Evergreen.V24.Questions.BeginningElmBook ->
            Evergreen.V27.Questions.BeginningElmBook

        Evergreen.V24.Questions.StackOverflow ->
            Evergreen.V27.Questions.StackOverflow

        Evergreen.V24.Questions.BuildingWebAppsWithElm ->
            Evergreen.V27.Questions.BuildingWebAppsWithElm

        Evergreen.V24.Questions.TheJsonSurvivalKit ->
            Evergreen.V27.Questions.TheJsonSurvivalKit

        Evergreen.V24.Questions.EggheadCourses ->
            Evergreen.V27.Questions.EggheadCourses

        Evergreen.V24.Questions.ProgrammingElmBook ->
            Evergreen.V27.Questions.ProgrammingElmBook

        Evergreen.V24.Questions.GuideElmLang ->
            Evergreen.V27.Questions.GuideElmLang

        Evergreen.V24.Questions.ElmForBeginners ->
            Evergreen.V27.Questions.ElmForBeginners

        Evergreen.V24.Questions.ElmSlack_ ->
            Evergreen.V27.Questions.ElmSlack_

        Evergreen.V24.Questions.FrontendMasters ->
            Evergreen.V27.Questions.FrontendMasters

        Evergreen.V24.Questions.ElmOnline ->
            Evergreen.V27.Questions.ElmOnline


migrateExperienceLevel : Evergreen.V24.Questions.ExperienceLevel -> Evergreen.V27.Questions.ExperienceLevel
migrateExperienceLevel old =
    case old of
        Evergreen.V24.Questions.Beginner ->
            Evergreen.V27.Questions.Beginner

        Evergreen.V24.Questions.Intermediate ->
            Evergreen.V27.Questions.Intermediate

        Evergreen.V24.Questions.Professional ->
            Evergreen.V27.Questions.Professional

        Evergreen.V24.Questions.Expert ->
            Evergreen.V27.Questions.Expert


migrateFrameworks : Evergreen.V24.Questions.Frameworks -> Evergreen.V27.Questions.Frameworks
migrateFrameworks old =
    case old of
        Evergreen.V24.Questions.Lamdera_ ->
            Evergreen.V27.Questions.Lamdera_

        Evergreen.V24.Questions.ElmSpa ->
            Evergreen.V27.Questions.ElmSpa

        Evergreen.V24.Questions.ElmPages ->
            Evergreen.V27.Questions.ElmPages

        Evergreen.V24.Questions.ElmPlayground ->
            Evergreen.V27.Questions.ElmPlayground


migrateHowLargeIsTheCompany : Evergreen.V24.Questions.HowLargeIsTheCompany -> Evergreen.V27.Questions.HowLargeIsTheCompany
migrateHowLargeIsTheCompany old =
    case old of
        Evergreen.V24.Questions.Size1To10Employees ->
            Evergreen.V27.Questions.Size1To10Employees

        Evergreen.V24.Questions.Size11To50Employees ->
            Evergreen.V27.Questions.Size11To50Employees

        Evergreen.V24.Questions.Size50To100Employees ->
            Evergreen.V27.Questions.Size50To100Employees

        Evergreen.V24.Questions.Size100OrMore ->
            Evergreen.V27.Questions.Size100OrMore


migrateHowLong : Evergreen.V24.Questions.HowLong -> Evergreen.V27.Questions.HowLong
migrateHowLong old =
    case old of
        Evergreen.V24.Questions.Under3Months ->
            Evergreen.V27.Questions.Under3Months

        Evergreen.V24.Questions.Between3MonthsAndAYear ->
            Evergreen.V27.Questions.Between3MonthsAndAYear

        Evergreen.V24.Questions.OneYear ->
            Evergreen.V27.Questions.OneYear

        Evergreen.V24.Questions.TwoYears ->
            Evergreen.V27.Questions.TwoYears

        Evergreen.V24.Questions.ThreeYears ->
            Evergreen.V27.Questions.ThreeYears

        Evergreen.V24.Questions.FourYears ->
            Evergreen.V27.Questions.FourYears

        Evergreen.V24.Questions.FiveYears ->
            Evergreen.V27.Questions.FiveYears

        Evergreen.V24.Questions.SixYears ->
            Evergreen.V27.Questions.SixYears

        Evergreen.V24.Questions.SevenYears ->
            Evergreen.V27.Questions.SevenYears

        Evergreen.V24.Questions.EightYears ->
            Evergreen.V27.Questions.EightYears

        Evergreen.V24.Questions.NineYears ->
            Evergreen.V27.Questions.NineYears


migrateNewsAndDiscussions : Evergreen.V24.Questions.NewsAndDiscussions -> Evergreen.V27.Questions.NewsAndDiscussions
migrateNewsAndDiscussions old =
    case old of
        Evergreen.V24.Questions.ElmDiscourse ->
            Evergreen.V27.Questions.ElmDiscourse

        Evergreen.V24.Questions.ElmSlack ->
            Evergreen.V27.Questions.ElmSlack

        Evergreen.V24.Questions.ElmSubreddit ->
            Evergreen.V27.Questions.ElmSubreddit

        Evergreen.V24.Questions.Twitter ->
            Evergreen.V27.Questions.Twitter

        Evergreen.V24.Questions.ElmRadio ->
            Evergreen.V27.Questions.ElmRadio

        Evergreen.V24.Questions.BlogPosts ->
            Evergreen.V27.Questions.BlogPosts

        Evergreen.V24.Questions.Facebook ->
            Evergreen.V27.Questions.Facebook

        Evergreen.V24.Questions.DevTo ->
            Evergreen.V27.Questions.DevTo

        Evergreen.V24.Questions.Meetups ->
            Evergreen.V27.Questions.Meetups

        Evergreen.V24.Questions.ElmWeekly ->
            Evergreen.V27.Questions.ElmWeekly

        Evergreen.V24.Questions.ElmNews ->
            Evergreen.V27.Questions.ElmNews

        Evergreen.V24.Questions.ElmCraft ->
            Evergreen.V27.Questions.ElmCraft


migrateOtherLanguages : Evergreen.V24.Questions.OtherLanguages -> Evergreen.V27.Questions.OtherLanguages
migrateOtherLanguages old =
    case old of
        Evergreen.V24.Questions.JavaScript ->
            Evergreen.V27.Questions.JavaScript

        Evergreen.V24.Questions.TypeScript ->
            Evergreen.V27.Questions.TypeScript

        Evergreen.V24.Questions.Go ->
            Evergreen.V27.Questions.Go

        Evergreen.V24.Questions.Haskell ->
            Evergreen.V27.Questions.Haskell

        Evergreen.V24.Questions.CSharp ->
            Evergreen.V27.Questions.CSharp

        Evergreen.V24.Questions.C ->
            Evergreen.V27.Questions.C

        Evergreen.V24.Questions.CPlusPlus ->
            Evergreen.V27.Questions.CPlusPlus

        Evergreen.V24.Questions.OCaml ->
            Evergreen.V27.Questions.OCaml

        Evergreen.V24.Questions.Python ->
            Evergreen.V27.Questions.Python

        Evergreen.V24.Questions.Swift ->
            Evergreen.V27.Questions.Swift

        Evergreen.V24.Questions.PHP ->
            Evergreen.V27.Questions.PHP

        Evergreen.V24.Questions.Java ->
            Evergreen.V27.Questions.Java

        Evergreen.V24.Questions.Ruby ->
            Evergreen.V27.Questions.Ruby

        Evergreen.V24.Questions.Elixir ->
            Evergreen.V27.Questions.Elixir

        Evergreen.V24.Questions.Clojure ->
            Evergreen.V27.Questions.Clojure

        Evergreen.V24.Questions.Rust ->
            Evergreen.V27.Questions.Rust

        Evergreen.V24.Questions.FSharp ->
            Evergreen.V27.Questions.FSharp


migrateStylingTools : Evergreen.V24.Questions.StylingTools -> Evergreen.V27.Questions.StylingTools
migrateStylingTools old =
    case old of
        Evergreen.V24.Questions.SassOrScss ->
            Evergreen.V27.Questions.SassOrScss

        Evergreen.V24.Questions.ElmCss ->
            Evergreen.V27.Questions.ElmCss

        Evergreen.V24.Questions.PlainCss ->
            Evergreen.V27.Questions.PlainCss

        Evergreen.V24.Questions.ElmUi ->
            Evergreen.V27.Questions.ElmUi

        Evergreen.V24.Questions.Tailwind ->
            Evergreen.V27.Questions.Tailwind

        Evergreen.V24.Questions.ElmTailwindModules ->
            Evergreen.V27.Questions.ElmTailwindModules

        Evergreen.V24.Questions.Bootstrap ->
            Evergreen.V27.Questions.Bootstrap


migrateTestTools : Evergreen.V24.Questions.TestTools -> Evergreen.V27.Questions.TestTools
migrateTestTools old =
    case old of
        Evergreen.V24.Questions.BrowserAcceptanceTests ->
            Evergreen.V27.Questions.BrowserAcceptanceTests

        Evergreen.V24.Questions.ElmBenchmark ->
            Evergreen.V27.Questions.ElmBenchmark

        Evergreen.V24.Questions.ElmTest ->
            Evergreen.V27.Questions.ElmTest

        Evergreen.V24.Questions.ElmProgramTest ->
            Evergreen.V27.Questions.ElmProgramTest

        Evergreen.V24.Questions.VisualRegressionTests ->
            Evergreen.V27.Questions.VisualRegressionTests


migrateTestsWrittenFor : Evergreen.V24.Questions.TestsWrittenFor -> Evergreen.V27.Questions.TestsWrittenFor
migrateTestsWrittenFor old =
    case old of
        Evergreen.V24.Questions.ComplicatedFunctions ->
            Evergreen.V27.Questions.ComplicatedFunctions

        Evergreen.V24.Questions.FunctionsThatReturnCmds ->
            Evergreen.V27.Questions.FunctionsThatReturnCmds

        Evergreen.V24.Questions.AllPublicFunctions ->
            Evergreen.V27.Questions.AllPublicFunctions

        Evergreen.V24.Questions.HtmlFunctions ->
            Evergreen.V27.Questions.HtmlFunctions

        Evergreen.V24.Questions.JsonDecodersAndEncoders ->
            Evergreen.V27.Questions.JsonDecodersAndEncoders

        Evergreen.V24.Questions.MostPublicFunctions ->
            Evergreen.V27.Questions.MostPublicFunctions


migrateWhatElmVersion : Evergreen.V24.Questions.ElmVersion -> Evergreen.V27.Questions.ElmVersion
migrateWhatElmVersion old =
    case old of
        Evergreen.V24.Questions.Version0_19 ->
            Evergreen.V27.Questions.Version0_19

        Evergreen.V24.Questions.Version0_18 ->
            Evergreen.V27.Questions.Version0_18

        Evergreen.V24.Questions.Version0_17 ->
            Evergreen.V27.Questions.Version0_17

        Evergreen.V24.Questions.Version0_16 ->
            Evergreen.V27.Questions.Version0_16


migrateWhatLanguageDoYouUseForTheBackend : Evergreen.V24.Questions.WhatLanguageDoYouUseForBackend -> Evergreen.V27.Questions.WhatLanguageDoYouUseForBackend
migrateWhatLanguageDoYouUseForTheBackend old =
    case old of
        Evergreen.V24.Questions.JavaScript_ ->
            Evergreen.V27.Questions.JavaScript_

        Evergreen.V24.Questions.TypeScript_ ->
            Evergreen.V27.Questions.TypeScript_

        Evergreen.V24.Questions.Go_ ->
            Evergreen.V27.Questions.Go_

        Evergreen.V24.Questions.Haskell_ ->
            Evergreen.V27.Questions.Haskell_

        Evergreen.V24.Questions.CSharp_ ->
            Evergreen.V27.Questions.CSharp_

        Evergreen.V24.Questions.OCaml_ ->
            Evergreen.V27.Questions.OCaml_

        Evergreen.V24.Questions.Python_ ->
            Evergreen.V27.Questions.Python_

        Evergreen.V24.Questions.PHP_ ->
            Evergreen.V27.Questions.PHP_

        Evergreen.V24.Questions.Java_ ->
            Evergreen.V27.Questions.Java_

        Evergreen.V24.Questions.Ruby_ ->
            Evergreen.V27.Questions.Ruby_

        Evergreen.V24.Questions.Elixir_ ->
            Evergreen.V27.Questions.Elixir_

        Evergreen.V24.Questions.Clojure_ ->
            Evergreen.V27.Questions.Clojure_

        Evergreen.V24.Questions.Rust_ ->
            Evergreen.V27.Questions.Rust_

        Evergreen.V24.Questions.FSharp_ ->
            Evergreen.V27.Questions.FSharp_

        Evergreen.V24.Questions.AlsoElm ->
            Evergreen.V27.Questions.AlsoElm

        Evergreen.V24.Questions.NotApplicable ->
            Evergreen.V27.Questions.NotApplicable


migrateWhereDoYouUseElm : Evergreen.V24.Questions.ApplicationDomains -> Evergreen.V27.Questions.ApplicationDomains
migrateWhereDoYouUseElm old =
    case old of
        Evergreen.V24.Questions.Education ->
            Evergreen.V27.Questions.Education

        Evergreen.V24.Questions.Gaming ->
            Evergreen.V27.Questions.Gaming

        Evergreen.V24.Questions.ECommerce ->
            Evergreen.V27.Questions.ECommerce

        Evergreen.V24.Questions.Music ->
            Evergreen.V27.Questions.Music

        Evergreen.V24.Questions.Finance ->
            Evergreen.V27.Questions.Finance

        Evergreen.V24.Questions.Health ->
            Evergreen.V27.Questions.Health

        Evergreen.V24.Questions.Productivity ->
            Evergreen.V27.Questions.Productivity

        Evergreen.V24.Questions.Communication ->
            Evergreen.V27.Questions.Communication

        Evergreen.V24.Questions.DataVisualization ->
            Evergreen.V27.Questions.DataVisualization

        Evergreen.V24.Questions.Transportation ->
            Evergreen.V27.Questions.Transportation


migrateWhichElmReviewRulesDoYouUse : Evergreen.V24.Questions.WhichElmReviewRulesDoYouUse -> Evergreen.V27.Questions.WhichElmReviewRulesDoYouUse
migrateWhichElmReviewRulesDoYouUse old =
    case old of
        Evergreen.V24.Questions.ElmReviewUnused ->
            Evergreen.V27.Questions.ElmReviewUnused

        Evergreen.V24.Questions.ElmReviewSimplify ->
            Evergreen.V27.Questions.ElmReviewSimplify

        Evergreen.V24.Questions.ElmReviewLicense ->
            Evergreen.V27.Questions.ElmReviewLicense

        Evergreen.V24.Questions.ElmReviewDebug ->
            Evergreen.V27.Questions.ElmReviewDebug

        Evergreen.V24.Questions.ElmReviewCommon ->
            Evergreen.V27.Questions.ElmReviewCommon

        Evergreen.V24.Questions.ElmReviewCognitiveComplexity ->
            Evergreen.V27.Questions.ElmReviewCognitiveComplexity


migrateAdminLoginData : Evergreen.V24.AdminPage.AdminLoginData -> Evergreen.V27.AdminPage.AdminLoginData
migrateAdminLoginData old =
    { forms = List.map (\a -> { form = migrateForm a.form, submitTime = a.submitTime }) old.forms
    , formMapping = migrateFormMapping old.formMapping
    }


freeTextAnswerMapInit : Evergreen.V27.FreeTextAnswerMap.FreeTextAnswerMap
freeTextAnswerMapInit =
    Evergreen.V27.FreeTextAnswerMap.FreeTextAnswerMap { otherMapping = [], comment = "" }


doYouUseElm : Question Evergreen.V27.Questions.DoYouUseElm
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


answerMapInit : Question a -> Evergreen.V27.AnswerMap.AnswerMap a
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
        |> Evergreen.V27.AnswerMap.AnswerMap


otherAnswer : String -> Evergreen.V27.AnswerMap.OtherAnswer
otherAnswer =
    normalizeOtherAnswer >> Evergreen.V27.AnswerMap.OtherAnswer


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
    , formMapping = migrateFormMapping old.formMapping
    , adminLogin = old.adminLogin
    }


migrateBackendMsg : Old.BackendMsg -> Maybe New.BackendMsg
migrateBackendMsg old =
    case old of
        Old.UserConnected a b ->
            New.UserConnected a b |> Just

        Old.GotTimeWithUpdate a b c d ->
            case migrateToBackend c of
                Just e ->
                    New.GotTimeWithUpdate a b e d |> Just

                Nothing ->
                    Nothing

        Old.GotTimeWithLoadFormData a b c ->
            New.GotTimeWithLoadFormData a b c |> Just


migrateForm : Evergreen.V24.Form.Form -> Evergreen.V27.Form.Form
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



--migrateFrontendModel : Old.FrontendModel -> New.FrontendModel
--migrateFrontendModel old =
--    case old of
--        Old.Loading a b ->
--            New.Loading a b
--
--        Old.FormLoaded a ->
--            New.FormLoaded (migrateFormLoaded_ a)
--
--        Old.FormCompleted a ->
--            New.FormCompleted a
--
--        Old.AdminLogin a ->
--            New.AdminLogin { password = identity a.password, loginFailed = identity a.loginFailed }
--
--        Old.Admin a ->
--            New.Admin
--                { forms = List.map (\{ form, submitTime } -> { form = migrateForm form, submitTime = submitTime }) a.forms
--                , formMapping = migrateNetworkModel migrateFormMappingEdit migrateFormMapping a.formMapping
--                , selectedMapping = migrateSelectedMapping a.selectedMapping
--                , showEncodedState = a.showEncodedState
--                }
--
--        Old.SurveyResultsLoaded data ->
--            New.SurveyResultsLoaded
--                { windowSize = data.windowSize
--                , data = migrateSurveyResultsData data.data
--                , -- TODO
--                  mode = Evergreen.V27.SurveyResults.Percentage
--                , segment = Evergreen.V27.SurveyResults.AllUsers
--                }


migrateNetworkModel : (msg1 -> msg2) -> (model1 -> model2) -> Evergreen.V24.NetworkModel.NetworkModel msg1 model1 -> Evergreen.V27.NetworkModel.NetworkModel msg2 model2
migrateNetworkModel migrateMsg migrateModel old =
    { localMsgs = List.map migrateMsg old.localMsgs
    , serverState = migrateModel old.serverState
    }


migrateFormMappingEdit : Evergreen.V24.AdminPage.FormMappingEdit -> Evergreen.V27.AdminPage.FormMappingEdit
migrateFormMappingEdit old =
    case old of
        Evergreen.V24.AdminPage.TypedGroupName a b c ->
            Evergreen.V27.AdminPage.TypedGroupName (migrateSpecificQuestion a) (migrateHotkey b) c

        Evergreen.V24.AdminPage.TypedNewGroupName a b ->
            Evergreen.V27.AdminPage.TypedNewGroupName (migrateSpecificQuestion a) b

        Evergreen.V24.AdminPage.TypedOtherAnswerGroups a b c ->
            Evergreen.V27.AdminPage.TypedOtherAnswerGroups (migrateSpecificQuestion a) (migrateOtherAnswer b) c

        Evergreen.V24.AdminPage.RemoveGroup a b ->
            Evergreen.V27.AdminPage.RemoveGroup (migrateSpecificQuestion a) (migrateHotkey b)

        Evergreen.V24.AdminPage.TypedComment a b ->
            Evergreen.V27.AdminPage.TypedComment (migrateSpecificQuestion a) b


migrateHotkey : Evergreen.V24.AnswerMap.Hotkey -> Evergreen.V27.AnswerMap.Hotkey
migrateHotkey old =
    case old of
        Evergreen.V24.AnswerMap.Hotkey a ->
            Evergreen.V27.AnswerMap.Hotkey a


migrateFormMapping : Evergreen.V24.Form.FormMapping -> Evergreen.V27.Form.FormMapping
migrateFormMapping old =
    { doYouUseElm = old.doYouUseElm
    , age = old.age
    , functionalProgrammingExperience = old.functionalProgrammingExperience
    , otherLanguages = migrateAnswerMap old.otherLanguages
    , newsAndDiscussions = migrateAnswerMap old.newsAndDiscussions
    , elmResources = migrateAnswerMap old.elmResources
    , countryLivingIn = old.countryLivingIn
    , applicationDomains = migrateAnswerMap old.applicationDomains
    , doYouUseElmAtWork = old.doYouUseElmAtWork
    , howLargeIsTheCompany = old.howLargeIsTheCompany
    , whatLanguageDoYouUseForBackend =
        migrateAnswerMap old.whatLanguageDoYouUseForBackend
    , howLong = old.howLong
    , elmVersion = migrateAnswerMap old.elmVersion
    , doYouUseElmFormat = old.doYouUseElmFormat
    , stylingTools = migrateAnswerMap old.stylingTools
    , buildTools = migrateAnswerMap old.buildTools
    , frameworks = migrateAnswerMap old.frameworks
    , editors = migrateAnswerMap old.editors
    , doYouUseElmReview = old.doYouUseElmReview
    , whichElmReviewRulesDoYouUse = migrateAnswerMap old.whichElmReviewRulesDoYouUse
    , testTools = migrateAnswerMap old.testTools
    , testsWrittenFor = migrateAnswerMap old.testsWrittenFor
    , elmInitialInterest = migrateFreeTextAnswerMap old.elmInitialInterest
    , biggestPainPoint = migrateFreeTextAnswerMap old.biggestPainPoint
    , whatDoYouLikeMost = migrateFreeTextAnswerMap old.whatDoYouLikeMost
    }


migrateAnswerMap : Evergreen.V24.AnswerMap.AnswerMap a -> Evergreen.V27.AnswerMap.AnswerMap b
migrateAnswerMap (Evergreen.V24.AnswerMap.AnswerMap old) =
    Evergreen.V27.AnswerMap.AnswerMap
        { otherMapping =
            List.map (\{ groupName, otherAnswers } -> { groupName = groupName, otherAnswers = Set.map migrateOtherAnswer otherAnswers }) old.otherMapping
        , existingMapping = List.map (Set.map migrateOtherAnswer) old.existingMapping
        , comment = old.comment
        }


migrateOtherAnswer : Evergreen.V24.AnswerMap.OtherAnswer -> Evergreen.V27.AnswerMap.OtherAnswer
migrateOtherAnswer (Evergreen.V24.AnswerMap.OtherAnswer old) =
    Evergreen.V27.AnswerMap.OtherAnswer old


migrateFreeTextAnswerMap : Evergreen.V24.FreeTextAnswerMap.FreeTextAnswerMap -> Evergreen.V27.FreeTextAnswerMap.FreeTextAnswerMap
migrateFreeTextAnswerMap old =
    case old of
        Evergreen.V24.FreeTextAnswerMap.FreeTextAnswerMap a ->
            Evergreen.V27.FreeTextAnswerMap.FreeTextAnswerMap a


migrateSelectedMapping : Evergreen.V24.Form.SpecificQuestion -> Evergreen.V27.Form.SpecificQuestion
migrateSelectedMapping old =
    case old of
        Evergreen.V24.Form.DoYouUseElmQuestion ->
            Evergreen.V27.Form.DoYouUseElmQuestion

        Evergreen.V24.Form.AgeQuestion ->
            Evergreen.V27.Form.AgeQuestion

        Evergreen.V24.Form.FunctionalProgrammingExperienceQuestion ->
            Evergreen.V27.Form.FunctionalProgrammingExperienceQuestion

        Evergreen.V24.Form.OtherLanguagesQuestion ->
            Evergreen.V27.Form.OtherLanguagesQuestion

        Evergreen.V24.Form.NewsAndDiscussionsQuestion ->
            Evergreen.V27.Form.NewsAndDiscussionsQuestion

        Evergreen.V24.Form.ElmResourcesQuestion ->
            Evergreen.V27.Form.ElmResourcesQuestion

        Evergreen.V24.Form.CountryLivingInQuestion ->
            Evergreen.V27.Form.CountryLivingInQuestion

        Evergreen.V24.Form.ApplicationDomainsQuestion ->
            Evergreen.V27.Form.ApplicationDomainsQuestion

        Evergreen.V24.Form.DoYouUseElmAtWorkQuestion ->
            Evergreen.V27.Form.DoYouUseElmAtWorkQuestion

        Evergreen.V24.Form.HowLargeIsTheCompanyQuestion ->
            Evergreen.V27.Form.HowLargeIsTheCompanyQuestion

        Evergreen.V24.Form.WhatLanguageDoYouUseForBackendQuestion ->
            Evergreen.V27.Form.WhatLanguageDoYouUseForBackendQuestion

        Evergreen.V24.Form.HowLongQuestion ->
            Evergreen.V27.Form.HowLongQuestion

        Evergreen.V24.Form.ElmVersionQuestion ->
            Evergreen.V27.Form.ElmVersionQuestion

        Evergreen.V24.Form.DoYouUseElmFormatQuestion ->
            Evergreen.V27.Form.DoYouUseElmFormatQuestion

        Evergreen.V24.Form.StylingToolsQuestion ->
            Evergreen.V27.Form.StylingToolsQuestion

        Evergreen.V24.Form.BuildToolsQuestion ->
            Evergreen.V27.Form.BuildToolsQuestion

        Evergreen.V24.Form.FrameworksQuestion ->
            Evergreen.V27.Form.FrameworksQuestion

        Evergreen.V24.Form.EditorsQuestion ->
            Evergreen.V27.Form.EditorsQuestion

        Evergreen.V24.Form.DoYouUseElmReviewQuestion ->
            Evergreen.V27.Form.DoYouUseElmReviewQuestion

        Evergreen.V24.Form.WhichElmReviewRulesDoYouUseQuestion ->
            Evergreen.V27.Form.WhichElmReviewRulesDoYouUseQuestion

        Evergreen.V24.Form.TestToolsQuestion ->
            Evergreen.V27.Form.TestToolsQuestion

        Evergreen.V24.Form.TestsWrittenForQuestion ->
            Evergreen.V27.Form.TestsWrittenForQuestion

        Evergreen.V24.Form.ElmInitialInterestQuestion ->
            Evergreen.V27.Form.ElmInitialInterestQuestion

        Evergreen.V24.Form.BiggestPainPointQuestion ->
            Evergreen.V27.Form.BiggestPainPointQuestion

        Evergreen.V24.Form.WhatDoYouLikeMostQuestion ->
            Evergreen.V27.Form.WhatDoYouLikeMostQuestion


migrateFrontendMsg : Old.FrontendMsg -> Maybe New.FrontendMsg
migrateFrontendMsg old =
    case old of
        Old.UrlClicked a ->
            New.UrlClicked a |> Just

        Old.UrlChanged ->
            New.UrlChanged |> Just

        Old.FormChanged a ->
            New.FormChanged (migrateForm a) |> Just

        Old.PressedAcceptTosAnswer a ->
            New.PressedAcceptTosAnswer a |> Just

        Old.PressedSubmitSurvey ->
            New.PressedSubmitSurvey |> Just

        Old.Debounce a ->
            New.Debounce a |> Just

        Old.TypedPassword a ->
            New.TypedPassword a |> Just

        Old.PressedLogin ->
            New.PressedLogin |> Just

        Old.GotWindowSize size ->
            New.GotWindowSize size |> Just

        Old.GotTime a ->
            New.GotTime a |> Just

        Old.AdminPageMsg msg ->
            migrateAdminPageMsg msg |> New.AdminPageMsg |> Just

        Old.SurveyResultsMsg msg ->
            migrateSurveyResultMsg msg |> New.SurveyResultsMsg |> Just


migrateSurveyResultMsg : Evergreen.V24.SurveyResults.Msg -> Evergreen.V27.SurveyResults.Msg
migrateSurveyResultMsg old =
    Debug.todo ""


migrateAdminPageMsg : Evergreen.V24.AdminPage.Msg -> Evergreen.V27.AdminPage.Msg
migrateAdminPageMsg msg =
    case msg of
        Evergreen.V24.AdminPage.PressedLogOut ->
            Evergreen.V27.AdminPage.PressedLogOut

        Evergreen.V24.AdminPage.TypedFormsData string ->
            Evergreen.V27.AdminPage.TypedFormsData string

        Evergreen.V24.AdminPage.PressedQuestionWithOther specificQuestion ->
            migrateSpecificQuestion specificQuestion |> Evergreen.V27.AdminPage.PressedQuestionWithOther

        Evergreen.V24.AdminPage.PressedToggleShowEncodedState ->
            Evergreen.V27.AdminPage.PressedToggleShowEncodedState

        Evergreen.V24.AdminPage.FormMappingEditMsg formMappingEdit ->
            migrateFormMappingEdit formMappingEdit |> Evergreen.V27.AdminPage.FormMappingEditMsg

        Evergreen.V24.AdminPage.NoOp ->
            Evergreen.V27.AdminPage.NoOp


migrateSpecificQuestion : Evergreen.V24.Form.SpecificQuestion -> Evergreen.V27.Form.SpecificQuestion
migrateSpecificQuestion old =
    case old of
        Evergreen.V24.Form.DoYouUseElmQuestion ->
            Evergreen.V27.Form.DoYouUseElmQuestion

        Evergreen.V24.Form.AgeQuestion ->
            Evergreen.V27.Form.AgeQuestion

        Evergreen.V24.Form.FunctionalProgrammingExperienceQuestion ->
            Evergreen.V27.Form.FunctionalProgrammingExperienceQuestion

        Evergreen.V24.Form.OtherLanguagesQuestion ->
            Evergreen.V27.Form.OtherLanguagesQuestion

        Evergreen.V24.Form.NewsAndDiscussionsQuestion ->
            Evergreen.V27.Form.NewsAndDiscussionsQuestion

        Evergreen.V24.Form.ElmResourcesQuestion ->
            Evergreen.V27.Form.ElmResourcesQuestion

        Evergreen.V24.Form.CountryLivingInQuestion ->
            Evergreen.V27.Form.CountryLivingInQuestion

        Evergreen.V24.Form.ApplicationDomainsQuestion ->
            Evergreen.V27.Form.ApplicationDomainsQuestion

        Evergreen.V24.Form.DoYouUseElmAtWorkQuestion ->
            Evergreen.V27.Form.DoYouUseElmAtWorkQuestion

        Evergreen.V24.Form.HowLargeIsTheCompanyQuestion ->
            Evergreen.V27.Form.HowLargeIsTheCompanyQuestion

        Evergreen.V24.Form.WhatLanguageDoYouUseForBackendQuestion ->
            Evergreen.V27.Form.WhatLanguageDoYouUseForBackendQuestion

        Evergreen.V24.Form.HowLongQuestion ->
            Evergreen.V27.Form.HowLongQuestion

        Evergreen.V24.Form.ElmVersionQuestion ->
            Evergreen.V27.Form.ElmVersionQuestion

        Evergreen.V24.Form.DoYouUseElmFormatQuestion ->
            Evergreen.V27.Form.DoYouUseElmFormatQuestion

        Evergreen.V24.Form.StylingToolsQuestion ->
            Evergreen.V27.Form.StylingToolsQuestion

        Evergreen.V24.Form.BuildToolsQuestion ->
            Evergreen.V27.Form.BuildToolsQuestion

        Evergreen.V24.Form.FrameworksQuestion ->
            Evergreen.V27.Form.FrameworksQuestion

        Evergreen.V24.Form.EditorsQuestion ->
            Evergreen.V27.Form.EditorsQuestion

        Evergreen.V24.Form.DoYouUseElmReviewQuestion ->
            Evergreen.V27.Form.DoYouUseElmReviewQuestion

        Evergreen.V24.Form.WhichElmReviewRulesDoYouUseQuestion ->
            Evergreen.V27.Form.WhichElmReviewRulesDoYouUseQuestion

        Evergreen.V24.Form.TestToolsQuestion ->
            Evergreen.V27.Form.TestToolsQuestion

        Evergreen.V24.Form.TestsWrittenForQuestion ->
            Evergreen.V27.Form.TestsWrittenForQuestion

        Evergreen.V24.Form.ElmInitialInterestQuestion ->
            Evergreen.V27.Form.ElmInitialInterestQuestion

        Evergreen.V24.Form.BiggestPainPointQuestion ->
            Evergreen.V27.Form.BiggestPainPointQuestion

        Evergreen.V24.Form.WhatDoYouLikeMostQuestion ->
            Evergreen.V27.Form.WhatDoYouLikeMostQuestion



--migrateLoadFormStatus : Old.LoadFormStatus -> New.LoadFormStatus
--migrateLoadFormStatus old =
--    case old of
--        Old.NoFormFound ->
--            New.NoFormFound
--
--        Old.FormAutoSaved a ->
--            New.FormAutoSaved (migrateForm a)
--
--        Old.FormSubmitted ->
--            New.FormSubmitted
--
--        Old.SurveyResults data ->
--            New.SurveyResults (migrateSurveyResultsData data)
--
--        Old.AwaitingResultsData ->
--            New.AwaitingResultsData
--migrateSurveyResultsData : Evergreen.V24.SurveyResults.Data -> Evergreen.V27.SurveyResults.Data
--migrateSurveyResultsData old =
--    { totalParticipants = old.totalParticipants
--    , doYouUseElm = migrateDataEntry old.doYouUseElm
--    , age = migrateDataEntry old.age
--    , functionalProgrammingExperience = migrateDataEntry old.functionalProgrammingExperience
--    , otherLanguages = migrateDataEntryWithOther old.otherLanguages
--    , newsAndDiscussions = migrateDataEntryWithOther old.newsAndDiscussions
--    , elmResources = migrateDataEntryWithOther old.elmResources
--    , countryLivingIn = migrateDataEntry old.countryLivingIn
--    , doYouUseElmAtWork = migrateDataEntry old.doYouUseElmAtWork
--    , applicationDomains = migrateDataEntryWithOther old.applicationDomains
--    , howLargeIsTheCompany = migrateDataEntry old.howLargeIsTheCompany
--    , whatLanguageDoYouUseForBackend = migrateDataEntryWithOther old.whatLanguageDoYouUseForBackend
--    , howLong = migrateDataEntry old.howLong
--    , elmVersion = migrateDataEntryWithOther old.elmVersion
--    , doYouUseElmFormat = migrateDataEntry old.doYouUseElmFormat
--    , stylingTools = migrateDataEntryWithOther old.stylingTools
--    , buildTools = migrateDataEntryWithOther old.buildTools
--    , frameworks = migrateDataEntryWithOther old.frameworks
--    , editors = migrateDataEntryWithOther old.editors
--    , doYouUseElmReview = migrateDataEntry old.doYouUseElmReview
--    , whichElmReviewRulesDoYouUse = migrateDataEntryWithOther old.whichElmReviewRulesDoYouUse
--    , testTools = migrateDataEntryWithOther old.testTools
--    , testsWrittenFor = migrateDataEntryWithOther old.testsWrittenFor
--    , elmInitialInterest = migrateDataEntryWithOther old.elmInitialInterest
--    , biggestPainPoint = migrateDataEntryWithOther old.biggestPainPoint
--    , whatDoYouLikeMost = migrateDataEntryWithOther old.whatDoYouLikeMost
--    }


migrateDataEntryWithOther : Evergreen.V24.DataEntry.DataEntryWithOther a -> Evergreen.V27.DataEntry.DataEntryWithOther b
migrateDataEntryWithOther (Evergreen.V24.DataEntry.DataEntryWithOther old) =
    Evergreen.V27.DataEntry.DataEntryWithOther old


migrateDataEntry : Evergreen.V24.DataEntry.DataEntry a -> Evergreen.V27.DataEntry.DataEntry b
migrateDataEntry (Evergreen.V24.DataEntry.DataEntry old) =
    Evergreen.V27.DataEntry.DataEntry
        { data = old.data
        , comment = old.comment
        }


migrateToBackend : Old.ToBackend -> Maybe New.ToBackend
migrateToBackend old =
    case old of
        Old.AutoSaveForm a ->
            New.AutoSaveForm (migrateForm a) |> Just

        Old.SubmitForm a ->
            New.SubmitForm (migrateForm a) |> Just

        Old.AdminLoginRequest a ->
            New.AdminLoginRequest a |> Just

        Old.AdminToBackend a ->
            migrateAdminToBackend a |> Maybe.map New.AdminToBackend


migrateAdminToBackend : Evergreen.V24.AdminPage.ToBackend -> Maybe Evergreen.V27.AdminPage.ToBackend
migrateAdminToBackend old =
    case old of
        Evergreen.V24.AdminPage.ReplaceFormsRequest forms ->
            -- Don't bother with this since it's only for local development
            Nothing

        Evergreen.V24.AdminPage.LogOutRequest ->
            Evergreen.V27.AdminPage.LogOutRequest |> Just

        Evergreen.V24.AdminPage.EditFormMappingRequest formMappingEdit ->
            migrateFormMappingEdit formMappingEdit |> Evergreen.V27.AdminPage.EditFormMappingRequest |> Just



--migrateToFrontend : Old.ToFrontend -> New.ToFrontend
--migrateToFrontend old =
--    case old of
--        Old.LoadForm a ->
--            New.LoadForm (migrateLoadFormStatus a)
--
--        Old.LoadAdmin a ->
--            New.LoadAdmin (migrateAdminLoginData a)
--
--        Old.AdminLoginResponse a ->
--            New.AdminLoginResponse (Result.map migrateAdminLoginData a)
--
--        Old.SubmitConfirmed ->
--            New.SubmitConfirmed
--
--        Old.LogOutResponse loadFormStatus ->
--            New.LogOutResponse (migrateLoadFormStatus loadFormStatus)
--
--        Old.AdminToFrontend a ->
--            migrateAdminToFrontend a |> New.AdminToFrontend


migrateAdminToFrontend : Evergreen.V24.AdminPage.ToFrontend -> Evergreen.V27.AdminPage.ToFrontend
migrateAdminToFrontend old =
    case old of
        Evergreen.V24.AdminPage.EditFormMappingResponse a ->
            Evergreen.V27.AdminPage.EditFormMappingResponse (migrateFormMappingEdit a)


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    --ModelMigrated ( migrateFrontendModel old, Cmd.none )
    ModelUnchanged


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelMigrated ( migrateBackendModel old, Cmd.none )


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    case migrateFrontendMsg old of
        Just msg ->
            MsgMigrated ( msg, Cmd.none )

        Nothing ->
            MsgOldValueIgnored


toBackend : Old.ToBackend -> MsgMigration New.ToBackend New.BackendMsg
toBackend old =
    case migrateToBackend old of
        Just msg ->
            MsgMigrated ( msg, Cmd.none )

        Nothing ->
            MsgOldValueIgnored


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg old =
    case migrateBackendMsg old of
        Just msg ->
            MsgMigrated ( msg, Cmd.none )

        Nothing ->
            MsgOldValueIgnored


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend old =
    --MsgMigrated ( migrateToFrontend old, Cmd.none )
    --TODO
    MsgOldValueIgnored
