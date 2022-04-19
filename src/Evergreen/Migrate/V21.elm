module Evergreen.Migrate.V21 exposing (..)

import AssocList as Dict exposing (Dict)
import AssocSet as Set
import Countries exposing (Country)
import Effect.Lamdera
import Evergreen.V20.AdminPage
import Evergreen.V20.DataEntry
import Evergreen.V20.Form
import Evergreen.V20.Questions
import Evergreen.V20.SurveyResults
import Evergreen.V20.Types as Old
import Evergreen.V21.AdminPage
import Evergreen.V21.DataEntry
import Evergreen.V21.Form
import Evergreen.V21.Questions
import Evergreen.V21.SurveyResults
import Evergreen.V21.Types as New
import Lamdera
import Lamdera.Migrations exposing (..)
import List.Extra as List
import Time


migrateAge : Evergreen.V20.Questions.Age -> Evergreen.V21.Questions.Age
migrateAge old =
    case old of
        Evergreen.V20.Questions.Under10 ->
            Evergreen.V21.Questions.Under10

        Evergreen.V20.Questions.Age10To19 ->
            Evergreen.V21.Questions.Age10To19

        Evergreen.V20.Questions.Age20To29 ->
            Evergreen.V21.Questions.Age20To29

        Evergreen.V20.Questions.Age30To39 ->
            Evergreen.V21.Questions.Age30To39

        Evergreen.V20.Questions.Age40To49 ->
            Evergreen.V21.Questions.Age40To49

        Evergreen.V20.Questions.Age50To59 ->
            Evergreen.V21.Questions.Age50To59

        Evergreen.V20.Questions.Over60 ->
            Evergreen.V21.Questions.Over60


migrateBuildTools : Evergreen.V20.Questions.BuildTools -> Maybe Evergreen.V21.Questions.BuildTools
migrateBuildTools old =
    case old of
        Evergreen.V20.Questions.ShellScripts ->
            Just Evergreen.V21.Questions.ShellScripts

        Evergreen.V20.Questions.ElmLive ->
            Just Evergreen.V21.Questions.ElmLive

        Evergreen.V20.Questions.CreateElmApp ->
            Just Evergreen.V21.Questions.CreateElmApp

        Evergreen.V20.Questions.Webpack ->
            Just Evergreen.V21.Questions.Webpack

        Evergreen.V20.Questions.Brunch ->
            Just Evergreen.V21.Questions.Brunch

        Evergreen.V20.Questions.ElmMakeStandalone ->
            Just Evergreen.V21.Questions.ElmMakeStandalone

        Evergreen.V20.Questions.Gulp ->
            Just Evergreen.V21.Questions.Gulp

        Evergreen.V20.Questions.Make ->
            Just Evergreen.V21.Questions.Make

        Evergreen.V20.Questions.ElmReactor ->
            Just Evergreen.V21.Questions.ElmReactor

        Evergreen.V20.Questions.Parcel ->
            Just Evergreen.V21.Questions.Parcel

        Evergreen.V20.Questions.Vite ->
            Just Evergreen.V21.Questions.Vite


migrateDoYouUseElm : Evergreen.V20.Questions.DoYouUseElm -> Evergreen.V21.Questions.DoYouUseElm
migrateDoYouUseElm old =
    case old of
        Evergreen.V20.Questions.YesAtWork ->
            Evergreen.V21.Questions.YesAtWork

        Evergreen.V20.Questions.YesInSideProjects ->
            Evergreen.V21.Questions.YesInSideProjects

        Evergreen.V20.Questions.YesAsAStudent ->
            Evergreen.V21.Questions.YesAsAStudent

        Evergreen.V20.Questions.IUsedToButIDontAnymore ->
            Evergreen.V21.Questions.IUsedToButIDontAnymore

        Evergreen.V20.Questions.NoButImCuriousAboutIt ->
            Evergreen.V21.Questions.NoButImCuriousAboutIt

        Evergreen.V20.Questions.NoAndIDontPlanTo ->
            Evergreen.V21.Questions.NoAndIDontPlanTo


migrateDoYouUseElmAtWork : Evergreen.V20.Questions.DoYouUseElmAtWork -> Evergreen.V21.Questions.DoYouUseElmAtWork
migrateDoYouUseElmAtWork old =
    case old of
        Evergreen.V20.Questions.NotInterestedInElmAtWork ->
            Evergreen.V21.Questions.NotInterestedInElmAtWork

        Evergreen.V20.Questions.WouldLikeToUseElmAtWork ->
            Evergreen.V21.Questions.WouldLikeToUseElmAtWork

        Evergreen.V20.Questions.HaveTriedElmInAWorkProject ->
            Evergreen.V21.Questions.HaveTriedElmInAWorkProject

        Evergreen.V20.Questions.MyTeamMostlyWritesNewCodeInElm ->
            Evergreen.V21.Questions.MyTeamMostlyWritesNewCodeInElm

        Evergreen.V20.Questions.NotEmployed ->
            Evergreen.V21.Questions.NotEmployed


migrateDoYouUseElmFormat : Evergreen.V20.Questions.DoYouUseElmFormat -> Evergreen.V21.Questions.DoYouUseElmFormat
migrateDoYouUseElmFormat old =
    case old of
        Evergreen.V20.Questions.PreferElmFormat ->
            Evergreen.V21.Questions.PreferElmFormat

        Evergreen.V20.Questions.TriedButDontUseElmFormat ->
            Evergreen.V21.Questions.TriedButDontUseElmFormat

        Evergreen.V20.Questions.HeardButDontUseElmFormat ->
            Evergreen.V21.Questions.HeardButDontUseElmFormat

        Evergreen.V20.Questions.HaveNotHeardOfElmFormat ->
            Evergreen.V21.Questions.HaveNotHeardOfElmFormat


migrateDoYouUseElmReview : Evergreen.V20.Questions.DoYouUseElmReview -> Evergreen.V21.Questions.DoYouUseElmReview
migrateDoYouUseElmReview old =
    case old of
        Evergreen.V20.Questions.NeverHeardOfElmReview ->
            Evergreen.V21.Questions.NeverHeardOfElmReview

        Evergreen.V20.Questions.HeardOfItButNeverTriedElmReview ->
            Evergreen.V21.Questions.HeardOfItButNeverTriedElmReview

        Evergreen.V20.Questions.IveTriedElmReview ->
            Evergreen.V21.Questions.IveTriedElmReview

        Evergreen.V20.Questions.IUseElmReviewRegularly ->
            Evergreen.V21.Questions.IUseElmReviewRegularly


migrateEditor : Evergreen.V20.Questions.Editor -> Evergreen.V21.Questions.Editor
migrateEditor old =
    case old of
        Evergreen.V20.Questions.SublimeText ->
            Evergreen.V21.Questions.SublimeText

        Evergreen.V20.Questions.Vim ->
            Evergreen.V21.Questions.Vim

        Evergreen.V20.Questions.Atom ->
            Evergreen.V21.Questions.Atom

        Evergreen.V20.Questions.Emacs ->
            Evergreen.V21.Questions.Emacs

        Evergreen.V20.Questions.VSCode ->
            Evergreen.V21.Questions.VSCode

        Evergreen.V20.Questions.Intellij ->
            Evergreen.V21.Questions.Intellij


migrateElmResources : Evergreen.V20.Questions.ElmResources -> Evergreen.V21.Questions.ElmResources
migrateElmResources old =
    case old of
        Evergreen.V20.Questions.DailyDrip ->
            Evergreen.V21.Questions.DailyDrip

        Evergreen.V20.Questions.ElmInActionBook ->
            Evergreen.V21.Questions.ElmInActionBook

        Evergreen.V20.Questions.WeeklyBeginnersElmSubreddit ->
            Evergreen.V21.Questions.WeeklyBeginnersElmSubreddit

        Evergreen.V20.Questions.BeginningElmBook ->
            Evergreen.V21.Questions.BeginningElmBook

        Evergreen.V20.Questions.StackOverflow ->
            Evergreen.V21.Questions.StackOverflow

        Evergreen.V20.Questions.BuildingWebAppsWithElm ->
            Evergreen.V21.Questions.BuildingWebAppsWithElm

        Evergreen.V20.Questions.TheJsonSurvivalKit ->
            Evergreen.V21.Questions.TheJsonSurvivalKit

        Evergreen.V20.Questions.EggheadCourses ->
            Evergreen.V21.Questions.EggheadCourses

        Evergreen.V20.Questions.ProgrammingElmBook ->
            Evergreen.V21.Questions.ProgrammingElmBook

        Evergreen.V20.Questions.GuideElmLang ->
            Evergreen.V21.Questions.GuideElmLang

        Evergreen.V20.Questions.ElmForBeginners ->
            Evergreen.V21.Questions.ElmForBeginners

        Evergreen.V20.Questions.ElmSlack_ ->
            Evergreen.V21.Questions.ElmSlack_

        Evergreen.V20.Questions.FrontendMasters ->
            Evergreen.V21.Questions.FrontendMasters

        Evergreen.V20.Questions.ElmOnline ->
            Evergreen.V21.Questions.ElmOnline


migrateExperienceLevel : Evergreen.V20.Questions.ExperienceLevel -> Evergreen.V21.Questions.ExperienceLevel
migrateExperienceLevel old =
    case old of
        Evergreen.V20.Questions.Beginner ->
            Evergreen.V21.Questions.Beginner

        Evergreen.V20.Questions.Intermediate ->
            Evergreen.V21.Questions.Intermediate

        Evergreen.V20.Questions.Professional ->
            Evergreen.V21.Questions.Professional

        Evergreen.V20.Questions.Expert ->
            Evergreen.V21.Questions.Expert


migrateFrameworks : Evergreen.V20.Questions.Frameworks -> Evergreen.V21.Questions.Frameworks
migrateFrameworks old =
    case old of
        Evergreen.V20.Questions.Lamdera_ ->
            Evergreen.V21.Questions.Lamdera_

        Evergreen.V20.Questions.ElmSpa ->
            Evergreen.V21.Questions.ElmSpa

        Evergreen.V20.Questions.ElmPages ->
            Evergreen.V21.Questions.ElmPages

        Evergreen.V20.Questions.ElmPlayground ->
            Evergreen.V21.Questions.ElmPlayground


migrateHowLargeIsTheCompany : Evergreen.V20.Questions.HowLargeIsTheCompany -> Evergreen.V21.Questions.HowLargeIsTheCompany
migrateHowLargeIsTheCompany old =
    case old of
        Evergreen.V20.Questions.Size1To10Employees ->
            Evergreen.V21.Questions.Size1To10Employees

        Evergreen.V20.Questions.Size11To50Employees ->
            Evergreen.V21.Questions.Size11To50Employees

        Evergreen.V20.Questions.Size50To100Employees ->
            Evergreen.V21.Questions.Size50To100Employees

        Evergreen.V20.Questions.Size100OrMore ->
            Evergreen.V21.Questions.Size100OrMore


migrateHowLong : Evergreen.V20.Questions.HowLong -> Evergreen.V21.Questions.HowLong
migrateHowLong old =
    case old of
        Evergreen.V20.Questions.Under3Months ->
            Evergreen.V21.Questions.Under3Months

        Evergreen.V20.Questions.Between3MonthsAndAYear ->
            Evergreen.V21.Questions.Between3MonthsAndAYear

        Evergreen.V20.Questions.OneYear ->
            Evergreen.V21.Questions.OneYear

        Evergreen.V20.Questions.TwoYears ->
            Evergreen.V21.Questions.TwoYears

        Evergreen.V20.Questions.ThreeYears ->
            Evergreen.V21.Questions.ThreeYears

        Evergreen.V20.Questions.FourYears ->
            Evergreen.V21.Questions.FourYears

        Evergreen.V20.Questions.FiveYears ->
            Evergreen.V21.Questions.FiveYears

        Evergreen.V20.Questions.SixYears ->
            Evergreen.V21.Questions.SixYears

        Evergreen.V20.Questions.SevenYears ->
            Evergreen.V21.Questions.SevenYears

        Evergreen.V20.Questions.EightYears ->
            Evergreen.V21.Questions.EightYears

        Evergreen.V20.Questions.NineYears ->
            Evergreen.V21.Questions.NineYears


migrateNewsAndDiscussions : Evergreen.V20.Questions.NewsAndDiscussions -> Evergreen.V21.Questions.NewsAndDiscussions
migrateNewsAndDiscussions old =
    case old of
        Evergreen.V20.Questions.ElmDiscourse ->
            Evergreen.V21.Questions.ElmDiscourse

        Evergreen.V20.Questions.ElmSlack ->
            Evergreen.V21.Questions.ElmSlack

        Evergreen.V20.Questions.ElmSubreddit ->
            Evergreen.V21.Questions.ElmSubreddit

        Evergreen.V20.Questions.Twitter ->
            Evergreen.V21.Questions.Twitter

        Evergreen.V20.Questions.ElmRadio ->
            Evergreen.V21.Questions.ElmRadio

        Evergreen.V20.Questions.BlogPosts ->
            Evergreen.V21.Questions.BlogPosts

        Evergreen.V20.Questions.Facebook ->
            Evergreen.V21.Questions.Facebook

        Evergreen.V20.Questions.DevTo ->
            Evergreen.V21.Questions.DevTo

        Evergreen.V20.Questions.Meetups ->
            Evergreen.V21.Questions.Meetups

        Evergreen.V20.Questions.ElmWeekly ->
            Evergreen.V21.Questions.ElmWeekly

        Evergreen.V20.Questions.ElmNews ->
            Evergreen.V21.Questions.ElmNews

        Evergreen.V20.Questions.ElmCraft ->
            Evergreen.V21.Questions.ElmCraft


migrateOtherLanguages : Evergreen.V20.Questions.OtherLanguages -> Evergreen.V21.Questions.OtherLanguages
migrateOtherLanguages old =
    case old of
        Evergreen.V20.Questions.JavaScript ->
            Evergreen.V21.Questions.JavaScript

        Evergreen.V20.Questions.TypeScript ->
            Evergreen.V21.Questions.TypeScript

        Evergreen.V20.Questions.Go ->
            Evergreen.V21.Questions.Go

        Evergreen.V20.Questions.Haskell ->
            Evergreen.V21.Questions.Haskell

        Evergreen.V20.Questions.CSharp ->
            Evergreen.V21.Questions.CSharp

        Evergreen.V20.Questions.C ->
            Evergreen.V21.Questions.C

        Evergreen.V20.Questions.CPlusPlus ->
            Evergreen.V21.Questions.CPlusPlus

        Evergreen.V20.Questions.OCaml ->
            Evergreen.V21.Questions.OCaml

        Evergreen.V20.Questions.Python ->
            Evergreen.V21.Questions.Python

        Evergreen.V20.Questions.Swift ->
            Evergreen.V21.Questions.Swift

        Evergreen.V20.Questions.PHP ->
            Evergreen.V21.Questions.PHP

        Evergreen.V20.Questions.Java ->
            Evergreen.V21.Questions.Java

        Evergreen.V20.Questions.Ruby ->
            Evergreen.V21.Questions.Ruby

        Evergreen.V20.Questions.Elixir ->
            Evergreen.V21.Questions.Elixir

        Evergreen.V20.Questions.Clojure ->
            Evergreen.V21.Questions.Clojure

        Evergreen.V20.Questions.Rust ->
            Evergreen.V21.Questions.Rust

        Evergreen.V20.Questions.FSharp ->
            Evergreen.V21.Questions.FSharp


migrateStylingTools : Evergreen.V20.Questions.StylingTools -> Evergreen.V21.Questions.StylingTools
migrateStylingTools old =
    case old of
        Evergreen.V20.Questions.SassOrScss ->
            Evergreen.V21.Questions.SassOrScss

        Evergreen.V20.Questions.ElmCss ->
            Evergreen.V21.Questions.ElmCss

        Evergreen.V20.Questions.PlainCss ->
            Evergreen.V21.Questions.PlainCss

        Evergreen.V20.Questions.ElmUi ->
            Evergreen.V21.Questions.ElmUi

        Evergreen.V20.Questions.Tailwind ->
            Evergreen.V21.Questions.Tailwind

        Evergreen.V20.Questions.ElmTailwindModules ->
            Evergreen.V21.Questions.ElmTailwindModules

        Evergreen.V20.Questions.Bootstrap ->
            Evergreen.V21.Questions.Bootstrap


migrateTestTools : Evergreen.V20.Questions.TestTools -> Evergreen.V21.Questions.TestTools
migrateTestTools old =
    case old of
        Evergreen.V20.Questions.BrowserAcceptanceTests ->
            Evergreen.V21.Questions.BrowserAcceptanceTests

        Evergreen.V20.Questions.ElmBenchmark ->
            Evergreen.V21.Questions.ElmBenchmark

        Evergreen.V20.Questions.ElmTest ->
            Evergreen.V21.Questions.ElmTest

        Evergreen.V20.Questions.ElmProgramTest ->
            Evergreen.V21.Questions.ElmProgramTest

        Evergreen.V20.Questions.VisualRegressionTests ->
            Evergreen.V21.Questions.VisualRegressionTests


migrateTestsWrittenFor : Evergreen.V20.Questions.TestsWrittenFor -> Evergreen.V21.Questions.TestsWrittenFor
migrateTestsWrittenFor old =
    case old of
        Evergreen.V20.Questions.ComplicatedFunctions ->
            Evergreen.V21.Questions.ComplicatedFunctions

        Evergreen.V20.Questions.FunctionsThatReturnCmds ->
            Evergreen.V21.Questions.FunctionsThatReturnCmds

        Evergreen.V20.Questions.AllPublicFunctions ->
            Evergreen.V21.Questions.AllPublicFunctions

        Evergreen.V20.Questions.HtmlFunctions ->
            Evergreen.V21.Questions.HtmlFunctions

        Evergreen.V20.Questions.JsonDecodersAndEncoders ->
            Evergreen.V21.Questions.JsonDecodersAndEncoders

        Evergreen.V20.Questions.MostPublicFunctions ->
            Evergreen.V21.Questions.MostPublicFunctions


migrateWhatElmVersion : Evergreen.V20.Questions.WhatElmVersion -> Evergreen.V21.Questions.WhatElmVersion
migrateWhatElmVersion old =
    case old of
        Evergreen.V20.Questions.Version0_19 ->
            Evergreen.V21.Questions.Version0_19

        Evergreen.V20.Questions.Version0_18 ->
            Evergreen.V21.Questions.Version0_18

        Evergreen.V20.Questions.Version0_17 ->
            Evergreen.V21.Questions.Version0_17

        Evergreen.V20.Questions.Version0_16 ->
            Evergreen.V21.Questions.Version0_16


migrateWhatLanguageDoYouUseForTheBackend : Evergreen.V20.Questions.WhatLanguageDoYouUseForTheBackend -> Evergreen.V21.Questions.WhatLanguageDoYouUseForTheBackend
migrateWhatLanguageDoYouUseForTheBackend old =
    case old of
        Evergreen.V20.Questions.JavaScript_ ->
            Evergreen.V21.Questions.JavaScript_

        Evergreen.V20.Questions.TypeScript_ ->
            Evergreen.V21.Questions.TypeScript_

        Evergreen.V20.Questions.Go_ ->
            Evergreen.V21.Questions.Go_

        Evergreen.V20.Questions.Haskell_ ->
            Evergreen.V21.Questions.Haskell_

        Evergreen.V20.Questions.CSharp_ ->
            Evergreen.V21.Questions.CSharp_

        Evergreen.V20.Questions.OCaml_ ->
            Evergreen.V21.Questions.OCaml_

        Evergreen.V20.Questions.Python_ ->
            Evergreen.V21.Questions.Python_

        Evergreen.V20.Questions.PHP_ ->
            Evergreen.V21.Questions.PHP_

        Evergreen.V20.Questions.Java_ ->
            Evergreen.V21.Questions.Java_

        Evergreen.V20.Questions.Ruby_ ->
            Evergreen.V21.Questions.Ruby_

        Evergreen.V20.Questions.Elixir_ ->
            Evergreen.V21.Questions.Elixir_

        Evergreen.V20.Questions.Clojure_ ->
            Evergreen.V21.Questions.Clojure_

        Evergreen.V20.Questions.Rust_ ->
            Evergreen.V21.Questions.Rust_

        Evergreen.V20.Questions.FSharp_ ->
            Evergreen.V21.Questions.FSharp_

        Evergreen.V20.Questions.AlsoElm ->
            Evergreen.V21.Questions.AlsoElm

        Evergreen.V20.Questions.NotApplicable ->
            Evergreen.V21.Questions.NotApplicable


migrateWhereDoYouUseElm : Evergreen.V20.Questions.WhereDoYouUseElm -> Evergreen.V21.Questions.WhereDoYouUseElm
migrateWhereDoYouUseElm old =
    case old of
        Evergreen.V20.Questions.Education ->
            Evergreen.V21.Questions.Education

        Evergreen.V20.Questions.Gaming ->
            Evergreen.V21.Questions.Gaming

        Evergreen.V20.Questions.ECommerce ->
            Evergreen.V21.Questions.ECommerce

        Evergreen.V20.Questions.Music ->
            Evergreen.V21.Questions.Music

        Evergreen.V20.Questions.Finance ->
            Evergreen.V21.Questions.Finance

        Evergreen.V20.Questions.Health ->
            Evergreen.V21.Questions.Health

        Evergreen.V20.Questions.Productivity ->
            Evergreen.V21.Questions.Productivity

        Evergreen.V20.Questions.Communication ->
            Evergreen.V21.Questions.Communication

        Evergreen.V20.Questions.DataVisualization ->
            Evergreen.V21.Questions.DataVisualization

        Evergreen.V20.Questions.Transportation ->
            Evergreen.V21.Questions.Transportation


migrateWhichElmReviewRulesDoYouUse : Evergreen.V20.Questions.WhichElmReviewRulesDoYouUse -> Evergreen.V21.Questions.WhichElmReviewRulesDoYouUse
migrateWhichElmReviewRulesDoYouUse old =
    case old of
        Evergreen.V20.Questions.ElmReviewUnused ->
            Evergreen.V21.Questions.ElmReviewUnused

        Evergreen.V20.Questions.ElmReviewSimplify ->
            Evergreen.V21.Questions.ElmReviewSimplify

        Evergreen.V20.Questions.ElmReviewLicense ->
            Evergreen.V21.Questions.ElmReviewLicense

        Evergreen.V20.Questions.ElmReviewDebug ->
            Evergreen.V21.Questions.ElmReviewDebug

        Evergreen.V20.Questions.ElmReviewCommon ->
            Evergreen.V21.Questions.ElmReviewCommon

        Evergreen.V20.Questions.ElmReviewCognitiveComplexity ->
            Evergreen.V21.Questions.ElmReviewCognitiveComplexity


migrateAdminLoginData : Evergreen.V20.AdminPage.AdminLoginData -> Evergreen.V21.AdminPage.AdminLoginData
migrateAdminLoginData old =
    { forms = List.map (\a -> { form = migrateForm a.form, submitTime = a.submitTime }) old.forms
    , formMapping =
        { otherLanguages = Dict.empty
        , newsAndDiscussions = Dict.empty
        , elmResources = Dict.empty
        , applicationDomains = Dict.empty
        , whatLanguageDoYouUseForBackend = Dict.empty
        , elmVersion = Dict.empty
        , stylingTools = Dict.empty
        , buildTools = Dict.empty
        , frameworks = Dict.empty
        , editors = Dict.empty
        , whichElmReviewRulesDoYouUse = Dict.empty
        , testTools = Dict.empty
        , testsWrittenFor = Dict.empty
        , elmInitialInterest = Dict.empty
        , biggestPainPoint = Dict.empty
        , whatDoYouLikeMost = Dict.empty
        }
    }


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
    , formMapping =
        { otherLanguages = Dict.empty
        , newsAndDiscussions = Dict.empty
        , elmResources = Dict.empty
        , applicationDomains = Dict.empty
        , whatLanguageDoYouUseForBackend = Dict.empty
        , elmVersion = Dict.empty
        , stylingTools = Dict.empty
        , buildTools = Dict.empty
        , frameworks = Dict.empty
        , editors = Dict.empty
        , whichElmReviewRulesDoYouUse = Dict.empty
        , testTools = Dict.empty
        , testsWrittenFor = Dict.empty
        , elmInitialInterest = Dict.empty
        , biggestPainPoint = Dict.empty
        , whatDoYouLikeMost = Dict.empty
        }
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


migrateForm : Evergreen.V20.Form.Form -> Evergreen.V21.Form.Form
migrateForm old =
    { doYouUseElm = Set.map migrateDoYouUseElm old.doYouUseElm
    , age = Maybe.map migrateAge old.age
    , functionalProgrammingExperience = Maybe.map migrateExperienceLevel old.functionalProgrammingExperience
    , otherLanguages = migrateMultiChoiceWithOther migrateOtherLanguages old.otherLanguages
    , newsAndDiscussions = migrateMultiChoiceWithOther migrateNewsAndDiscussions old.newsAndDiscussions
    , elmResources = migrateMultiChoiceWithOther migrateElmResources old.elmResources
    , countryLivingIn = migrateCountry old.countryLivingIn
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


migrateCountry : String -> Maybe Country
migrateCountry old =
    (case old of
        "America" ->
            ( "United States of America", "US", "🇺🇸" )

        "Argentina" ->
            ( "Argentina", "AR", "🇦🇷" )

        "Argentina 🇦🇷" ->
            ( "Argentina", "AR", "🇦🇷" )

        "Armenia 🇦🇲" ->
            ( "Armenia", "AM", "🇦🇲" )

        "Australia" ->
            ( "Australia", "AU", "🇦🇺" )

        "Australia 🇦🇺" ->
            ( "Australia", "AU", "🇦🇺" )

        "Austria" ->
            ( "Austria", "AT", "🇦🇹" )

        "Austria 🇦🇹" ->
            ( "Austria", "AT", "🇦🇹" )

        "Bangladesh 🇧🇩" ->
            ( "Bangladesh", "BD", "🇧🇩" )

        "Belarus 🇧🇾" ->
            ( "Belarus", "BY", "🇧🇾" )

        "Belgium" ->
            ( "Belgium", "BE", "🇧🇪" )

        "Belgium 🇧🇪" ->
            ( "Belgium", "BE", "🇧🇪" )

        "Bosnia and Herzegovina 🇧🇦" ->
            ( "Bosnia and Herzegovina", "BA", "🇧🇦" )

        "Brazil" ->
            ( "Brazil", "BR", "🇧🇷" )

        "Brazil 🇧🇷" ->
            ( "Brazil", "BR", "🇧🇷" )

        "Canada" ->
            ( "Canada", "CA", "🇨🇦" )

        "Canada 🇨🇦" ->
            ( "Canada", "CA", "🇨🇦" )

        "Chile 🇨🇱" ->
            ( "Chile", "CL", "🇨🇱" )

        "China 🇨🇳" ->
            ( "China", "CN", "🇨🇳" )

        "Colombia 🇨🇴" ->
            ( "Colombia", "CO", "🇨🇴" )

        "Cyprus 🇨🇾" ->
            ( "Cyprus", "CY", "🇨🇾" )

        "Czech Republic" ->
            ( "Czechia", "CZ", "🇨🇿" )

        "Czechia 🇨🇿" ->
            ( "Czechia", "CZ", "🇨🇿" )

        "Denmark" ->
            ( "Denmark", "DK", "🇩🇰" )

        "Denmark 🇩🇰" ->
            ( "Denmark", "DK", "🇩🇰" )

        "Dominica" ->
            ( "Dominica", "DM", "🇩🇲" )

        "Ecuador 🇪🇨" ->
            ( "Ecuador", "EC", "🇪🇨" )

        "England" ->
            ( "United Kingdom of Great Britain and Northern Ireland", "GB", "🇬🇧" )

        "Estonia 🇪🇪" ->
            ( "Estonia", "EE", "🇪🇪" )

        "Finland" ->
            ( "Finland", "FI", "🇫🇮" )

        "Finland 🇫🇮" ->
            ( "Finland", "FI", "🇫🇮" )

        "france" ->
            ( "France", "FR", "🇫🇷" )

        "France 🇫🇷" ->
            ( "France", "FR", "🇫🇷" )

        "Germany" ->
            ( "Germany", "DE", "🇩🇪" )

        "Germany 🇩🇪" ->
            ( "Germany", "DE", "🇩🇪" )

        "ghana" ->
            ( "Ghana", "GH", "🇬🇭" )

        "Greece" ->
            ( "Greece", "GR", "🇬🇷" )

        "Hungary" ->
            ( "Hungary", "HU", "🇭🇺" )

        "Hungary 🇭🇺" ->
            ( "Hungary", "HU", "🇭🇺" )

        "India" ->
            ( "India", "IN", "🇮🇳" )

        "India 🇮🇳" ->
            ( "India", "IN", "🇮🇳" )

        "Indonesia" ->
            ( "Indonesia", "ID", "🇮🇩" )

        "Indonesia 🇮🇩" ->
            ( "Indonesia", "ID", "🇮🇩" )

        "Iran (Islamic Republic of) 🇮🇷" ->
            ( "Iran (Islamic Republic of)", "IR", "🇮🇷" )

        "Ireland 🇮🇪" ->
            ( "Ireland", "IE", "🇮🇪" )

        "Israel" ->
            ( "Israel", "IL", "🇮🇱" )

        "Israel 🇮🇱" ->
            ( "Israel", "IL", "🇮🇱" )

        "Italy" ->
            ( "Italy", "IT", "🇮🇹" )

        "Italy 🇮🇹" ->
            ( "Italy", "IT", "🇮🇹" )

        "Japan" ->
            ( "Japan", "JP", "🇯🇵" )

        "Japan 🇯🇵" ->
            ( "Japan", "JP", "🇯🇵" )

        "Kenya 🇰🇪" ->
            ( "Kenya", "KE", "🇰🇪" )

        "Lithuania" ->
            ( "Lithuania", "LT", "🇱🇹" )

        "Malaysia 🇲🇾" ->
            ( "Malaysia", "MY", "🇲🇾" )

        "Mexico 🇲🇽" ->
            ( "Mexico", "MX", "🇲🇽" )

        "Netherlands" ->
            ( "Netherlands", "NL", "🇳🇱" )

        "Netherlands 🇳🇱" ->
            ( "Netherlands", "NL", "🇳🇱" )

        "New Zealand 🇳🇿" ->
            ( "New Zealand", "NZ", "🇳🇿" )

        "Norway" ->
            ( "Norway", "NO", "🇳🇴" )

        "Norway 🇳🇴" ->
            ( "Norway", "NO", "🇳🇴" )

        "Philippines 🇵🇭" ->
            ( "Philippines", "PH", "🇵🇭" )

        "Poland" ->
            ( "Poland", "PL", "🇵🇱" )

        "Poland 🇵🇱" ->
            ( "Poland", "PL", "🇵🇱" )

        "Portugal" ->
            ( "Portugal", "PT", "🇵🇹" )

        "Portugal 🇵🇹" ->
            ( "Portugal", "PT", "🇵🇹" )

        "Puerto Rico 🇵🇷" ->
            ( "Puerto Rico", "PR", "🇵🇷" )

        "Romania" ->
            ( "Romania", "RO", "🇷🇴" )

        "Romania 🇷🇴" ->
            ( "Romania", "RO", "🇷🇴" )

        "Russian Federation 🇷🇺" ->
            ( "Russian Federation", "RU", "🇷🇺" )

        "Scotland" ->
            ( "United Kingdom of Great Britain and Northern Ireland", "GB", "🇬🇧" )

        "Serbia" ->
            ( "Serbia", "RS", "🇷🇸" )

        "Singapore" ->
            ( "Singapore", "SG", "🇸🇬" )

        "Slovakia" ->
            ( "Slovakia", "SK", "🇸🇰" )

        "Slovenia 🇸🇮" ->
            ( "Slovenia", "SI", "🇸🇮" )

        "South Africa 🇿🇦" ->
            ( "South Africa", "ZA", "🇿🇦" )

        "Spain" ->
            ( "Spain", "ES", "🇪🇸" )

        "Spain 🇪🇸" ->
            ( "Spain", "ES", "🇪🇸" )

        "Sweden" ->
            ( "Sweden", "SE", "🇸🇪" )

        "Sweden 🇸🇪" ->
            ( "Sweden", "SE", "🇸🇪" )

        "Switzerland" ->
            ( "Switzerland", "CH", "🇨🇭" )

        "Switzerland 🇨🇭" ->
            ( "Switzerland", "CH", "🇨🇭" )

        "Thailand 🇹🇭" ->
            ( "Thailand", "TH", "🇹🇭" )

        "The Netherlands" ->
            ( "Netherlands", "NL", "🇳🇱" )

        "Tokyo" ->
            ( "Japan", "JP", "🇯🇵" )

        "Trinidad and Tobago 🇹🇹" ->
            ( "Trinidad and Tobago", "TT", "🇹🇹" )

        "Turkey 🇹🇷" ->
            ( "Turkey", "TR", "🇹🇷" )

        "UK" ->
            ( "United Kingdom of Great Britain and Northern Ireland", "GB", "🇬🇧" )

        "Ukraine" ->
            ( "Ukraine", "UA", "🇺🇦" )

        "Ukraine 🇺🇦" ->
            ( "Ukraine", "UA", "🇺🇦" )

        "United Kingdom" ->
            ( "United Kingdom of Great Britain and Northern Ireland", "GB", "🇬🇧" )

        "United Kingdom of Great Britain and Northern Ireland 🇬🇧" ->
            ( "United Kingdom of Great Britain and Northern Ireland", "GB", "🇬🇧" )

        "United States" ->
            ( "United States of America", "US", "🇺🇸" )

        "United States 🇺🇲" ->
            ( "United States of America", "US", "🇺🇸" )

        "United States of America" ->
            ( "United States of America", "US", "🇺🇸" )

        "United States of America 🇺🇸" ->
            ( "United States of America", "US", "🇺🇸" )

        "United statrd of america" ->
            ( "United States of America", "US", "🇺🇸" )

        "Uruguay 🇺🇾" ->
            ( "Uruguay", "UY", "🇺🇾" )

        "US" ->
            ( "United States of America", "US", "🇺🇸" )

        "USA" ->
            ( "United States of America", "US", "🇺🇸" )

        "Venezuela (Bolivarian Republic of) 🇻🇪" ->
            ( "Venezuela (Bolivarian Republic of)", "VE", "🇻🇪" )

        "Viet Nam 🇻🇳" ->
            ( "Viet Nam", "VN", "🇻🇳" )

        _ ->
            ( "", "", "" )
    )
        |> (\( name, code, flag ) ->
                if name == "" then
                    Nothing

                else
                    Just { name = name, code = code, flag = flag }
           )


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
            New.Admin (migrateAdminLoginData a)

        Old.SurveyResultsLoaded data ->
            New.SurveyResultsLoaded (migrateSurveyResultsData data)


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


migrateAdminPageMsg : Evergreen.V20.AdminPage.Msg -> Evergreen.V21.AdminPage.Msg
migrateAdminPageMsg msg =
    case msg of
        Evergreen.V20.AdminPage.PressedLogOut ->
            Evergreen.V21.AdminPage.PressedLogOut

        Evergreen.V20.AdminPage.TypedFormsData string ->
            Evergreen.V21.AdminPage.TypedFormsData string


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


migrateSurveyResultsData : Evergreen.V20.SurveyResults.Data -> Evergreen.V21.SurveyResults.Data
migrateSurveyResultsData old =
    { doYouUseElm = migrateDataEntry old.doYouUseElm
    , age = migrateDataEntry old.age
    , functionalProgrammingExperience = migrateDataEntry old.functionalProgrammingExperience
    , doYouUseElmAtWork = migrateDataEntry old.doYouUseElmAtWork
    , howLargeIsTheCompany = migrateDataEntry old.howLargeIsTheCompany
    , howLong = migrateDataEntry old.howLong
    , doYouUseElmFormat = migrateDataEntry old.doYouUseElmFormat
    , doYouUseElmReview = migrateDataEntry old.doYouUseElmReview
    }


migrateDataEntry : Evergreen.V20.DataEntry.DataEntry a -> Evergreen.V21.DataEntry.DataEntry b
migrateDataEntry (Evergreen.V20.DataEntry.DataEntry old) =
    Evergreen.V21.DataEntry.DataEntry old


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


migrateAdminToBackend : Evergreen.V20.AdminPage.ToBackend -> Evergreen.V21.AdminPage.ToBackend
migrateAdminToBackend old =
    case old of
        Evergreen.V20.AdminPage.ReplaceFormsRequest forms ->
            Evergreen.V21.AdminPage.ReplaceFormsRequest (List.map migrateForm forms)

        Evergreen.V20.AdminPage.LogOutRequest ->
            Evergreen.V21.AdminPage.LogOutRequest


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
