module Evergreen.Migrate.V20 exposing (..)

import AssocList as Dict exposing (Dict)
import AssocSet as Set
import Effect.Lamdera
import Evergreen.V18.DataEntry
import Evergreen.V18.Questions
import Evergreen.V18.SurveyResults
import Evergreen.V18.Types as Old
import Evergreen.V20.AdminPage
import Evergreen.V20.DataEntry
import Evergreen.V20.Form
import Evergreen.V20.Questions
import Evergreen.V20.SurveyResults
import Evergreen.V20.Types as New
import Lamdera
import Lamdera.Migrations exposing (..)
import Time


migrateAge : Evergreen.V18.Questions.Age -> Evergreen.V20.Questions.Age
migrateAge old =
    case old of
        Evergreen.V18.Questions.Under10 ->
            Evergreen.V20.Questions.Under10

        Evergreen.V18.Questions.Age10To19 ->
            Evergreen.V20.Questions.Age10To19

        Evergreen.V18.Questions.Age20To29 ->
            Evergreen.V20.Questions.Age20To29

        Evergreen.V18.Questions.Age30To39 ->
            Evergreen.V20.Questions.Age30To39

        Evergreen.V18.Questions.Age40To49 ->
            Evergreen.V20.Questions.Age40To49

        Evergreen.V18.Questions.Age50To59 ->
            Evergreen.V20.Questions.Age50To59

        Evergreen.V18.Questions.Over60 ->
            Evergreen.V20.Questions.Over60


migrateBuildTools : Evergreen.V18.Questions.BuildTools -> Maybe Evergreen.V20.Questions.BuildTools
migrateBuildTools old =
    case old of
        Evergreen.V18.Questions.ShellScripts ->
            Just Evergreen.V20.Questions.ShellScripts

        Evergreen.V18.Questions.ElmLive ->
            Just Evergreen.V20.Questions.ElmLive

        Evergreen.V18.Questions.CreateElmApp ->
            Just Evergreen.V20.Questions.CreateElmApp

        Evergreen.V18.Questions.Webpack ->
            Just Evergreen.V20.Questions.Webpack

        Evergreen.V18.Questions.Brunch ->
            Just Evergreen.V20.Questions.Brunch

        Evergreen.V18.Questions.ElmMakeStandalone ->
            Just Evergreen.V20.Questions.ElmMakeStandalone

        Evergreen.V18.Questions.Gulp ->
            Just Evergreen.V20.Questions.Gulp

        Evergreen.V18.Questions.Make ->
            Just Evergreen.V20.Questions.Make

        Evergreen.V18.Questions.ElmReactor ->
            Just Evergreen.V20.Questions.ElmReactor

        Evergreen.V18.Questions.Parcel ->
            Just Evergreen.V20.Questions.Parcel

        Evergreen.V18.Questions.Vite ->
            Just Evergreen.V20.Questions.Vite


migrateDoYouUseElm : Evergreen.V18.Questions.DoYouUseElm -> Evergreen.V20.Questions.DoYouUseElm
migrateDoYouUseElm old =
    case old of
        Evergreen.V18.Questions.YesAtWork ->
            Evergreen.V20.Questions.YesAtWork

        Evergreen.V18.Questions.YesInSideProjects ->
            Evergreen.V20.Questions.YesInSideProjects

        Evergreen.V18.Questions.YesAsAStudent ->
            Evergreen.V20.Questions.YesAsAStudent

        Evergreen.V18.Questions.IUsedToButIDontAnymore ->
            Evergreen.V20.Questions.IUsedToButIDontAnymore

        Evergreen.V18.Questions.NoButImCuriousAboutIt ->
            Evergreen.V20.Questions.NoButImCuriousAboutIt

        Evergreen.V18.Questions.NoAndIDontPlanTo ->
            Evergreen.V20.Questions.NoAndIDontPlanTo


migrateDoYouUseElmAtWork : Evergreen.V18.Questions.DoYouUseElmAtWork -> Evergreen.V20.Questions.DoYouUseElmAtWork
migrateDoYouUseElmAtWork old =
    case old of
        Evergreen.V18.Questions.NotInterestedInElmAtWork ->
            Evergreen.V20.Questions.NotInterestedInElmAtWork

        Evergreen.V18.Questions.WouldLikeToUseElmAtWork ->
            Evergreen.V20.Questions.WouldLikeToUseElmAtWork

        Evergreen.V18.Questions.HaveTriedElmInAWorkProject ->
            Evergreen.V20.Questions.HaveTriedElmInAWorkProject

        Evergreen.V18.Questions.MyTeamMostlyWritesNewCodeInElm ->
            Evergreen.V20.Questions.MyTeamMostlyWritesNewCodeInElm

        Evergreen.V18.Questions.NotEmployed ->
            Evergreen.V20.Questions.NotEmployed


migrateDoYouUseElmFormat : Evergreen.V18.Questions.DoYouUseElmFormat -> Evergreen.V20.Questions.DoYouUseElmFormat
migrateDoYouUseElmFormat old =
    case old of
        Evergreen.V18.Questions.PreferElmFormat ->
            Evergreen.V20.Questions.PreferElmFormat

        Evergreen.V18.Questions.TriedButDontUseElmFormat ->
            Evergreen.V20.Questions.TriedButDontUseElmFormat

        Evergreen.V18.Questions.HeardButDontUseElmFormat ->
            Evergreen.V20.Questions.HeardButDontUseElmFormat

        Evergreen.V18.Questions.HaveNotHeardOfElmFormat ->
            Evergreen.V20.Questions.HaveNotHeardOfElmFormat


migrateDoYouUseElmReview : Evergreen.V18.Questions.DoYouUseElmReview -> Evergreen.V20.Questions.DoYouUseElmReview
migrateDoYouUseElmReview old =
    case old of
        Evergreen.V18.Questions.NeverHeardOfElmReview ->
            Evergreen.V20.Questions.NeverHeardOfElmReview

        Evergreen.V18.Questions.HeardOfItButNeverTriedElmReview ->
            Evergreen.V20.Questions.HeardOfItButNeverTriedElmReview

        Evergreen.V18.Questions.IveTriedElmReview ->
            Evergreen.V20.Questions.IveTriedElmReview

        Evergreen.V18.Questions.IUseElmReviewRegularly ->
            Evergreen.V20.Questions.IUseElmReviewRegularly


migrateEditor : Evergreen.V18.Questions.Editor -> Evergreen.V20.Questions.Editor
migrateEditor old =
    case old of
        Evergreen.V18.Questions.SublimeText ->
            Evergreen.V20.Questions.SublimeText

        Evergreen.V18.Questions.Vim ->
            Evergreen.V20.Questions.Vim

        Evergreen.V18.Questions.Atom ->
            Evergreen.V20.Questions.Atom

        Evergreen.V18.Questions.Emacs ->
            Evergreen.V20.Questions.Emacs

        Evergreen.V18.Questions.VSCode ->
            Evergreen.V20.Questions.VSCode

        Evergreen.V18.Questions.Intellij ->
            Evergreen.V20.Questions.Intellij


migrateElmResources : Evergreen.V18.Questions.ElmResources -> Evergreen.V20.Questions.ElmResources
migrateElmResources old =
    case old of
        Evergreen.V18.Questions.DailyDrip ->
            Evergreen.V20.Questions.DailyDrip

        Evergreen.V18.Questions.ElmInActionBook ->
            Evergreen.V20.Questions.ElmInActionBook

        Evergreen.V18.Questions.WeeklyBeginnersElmSubreddit ->
            Evergreen.V20.Questions.WeeklyBeginnersElmSubreddit

        Evergreen.V18.Questions.BeginningElmBook ->
            Evergreen.V20.Questions.BeginningElmBook

        Evergreen.V18.Questions.StackOverflow ->
            Evergreen.V20.Questions.StackOverflow

        Evergreen.V18.Questions.BuildingWebAppsWithElm ->
            Evergreen.V20.Questions.BuildingWebAppsWithElm

        Evergreen.V18.Questions.TheJsonSurvivalKit ->
            Evergreen.V20.Questions.TheJsonSurvivalKit

        Evergreen.V18.Questions.EggheadCourses ->
            Evergreen.V20.Questions.EggheadCourses

        Evergreen.V18.Questions.ProgrammingElmBook ->
            Evergreen.V20.Questions.ProgrammingElmBook

        Evergreen.V18.Questions.GuideElmLang ->
            Evergreen.V20.Questions.GuideElmLang

        Evergreen.V18.Questions.ElmForBeginners ->
            Evergreen.V20.Questions.ElmForBeginners

        Evergreen.V18.Questions.ElmSlack_ ->
            Evergreen.V20.Questions.ElmSlack_

        Evergreen.V18.Questions.FrontendMasters ->
            Evergreen.V20.Questions.FrontendMasters

        Evergreen.V18.Questions.ElmOnline ->
            Evergreen.V20.Questions.ElmOnline


migrateExperienceLevel : Evergreen.V18.Questions.ExperienceLevel -> Evergreen.V20.Questions.ExperienceLevel
migrateExperienceLevel old =
    case old of
        Evergreen.V18.Questions.Beginner ->
            Evergreen.V20.Questions.Beginner

        Evergreen.V18.Questions.Intermediate ->
            Evergreen.V20.Questions.Intermediate

        Evergreen.V18.Questions.Professional ->
            Evergreen.V20.Questions.Professional

        Evergreen.V18.Questions.Expert ->
            Evergreen.V20.Questions.Expert


migrateFrameworks : Evergreen.V18.Questions.Frameworks -> Evergreen.V20.Questions.Frameworks
migrateFrameworks old =
    case old of
        Evergreen.V18.Questions.Lamdera_ ->
            Evergreen.V20.Questions.Lamdera_

        Evergreen.V18.Questions.ElmSpa ->
            Evergreen.V20.Questions.ElmSpa

        Evergreen.V18.Questions.ElmPages ->
            Evergreen.V20.Questions.ElmPages

        Evergreen.V18.Questions.ElmPlayground ->
            Evergreen.V20.Questions.ElmPlayground


migrateHowLargeIsTheCompany : Evergreen.V18.Questions.HowLargeIsTheCompany -> Evergreen.V20.Questions.HowLargeIsTheCompany
migrateHowLargeIsTheCompany old =
    case old of
        Evergreen.V18.Questions.Size1To10Employees ->
            Evergreen.V20.Questions.Size1To10Employees

        Evergreen.V18.Questions.Size11To50Employees ->
            Evergreen.V20.Questions.Size11To50Employees

        Evergreen.V18.Questions.Size50To100Employees ->
            Evergreen.V20.Questions.Size50To100Employees

        Evergreen.V18.Questions.Size100OrMore ->
            Evergreen.V20.Questions.Size100OrMore


migrateHowLong : Evergreen.V18.Questions.HowLong -> Evergreen.V20.Questions.HowLong
migrateHowLong old =
    case old of
        Evergreen.V18.Questions.Under3Months ->
            Evergreen.V20.Questions.Under3Months

        Evergreen.V18.Questions.Between3MonthsAndAYear ->
            Evergreen.V20.Questions.Between3MonthsAndAYear

        Evergreen.V18.Questions.OneYear ->
            Evergreen.V20.Questions.OneYear

        Evergreen.V18.Questions.TwoYears ->
            Evergreen.V20.Questions.TwoYears

        Evergreen.V18.Questions.ThreeYears ->
            Evergreen.V20.Questions.ThreeYears

        Evergreen.V18.Questions.FourYears ->
            Evergreen.V20.Questions.FourYears

        Evergreen.V18.Questions.FiveYears ->
            Evergreen.V20.Questions.FiveYears

        Evergreen.V18.Questions.SixYears ->
            Evergreen.V20.Questions.SixYears

        Evergreen.V18.Questions.SevenYears ->
            Evergreen.V20.Questions.SevenYears

        Evergreen.V18.Questions.EightYears ->
            Evergreen.V20.Questions.EightYears

        Evergreen.V18.Questions.NineYears ->
            Evergreen.V20.Questions.NineYears


migrateNewsAndDiscussions : Evergreen.V18.Questions.NewsAndDiscussions -> Evergreen.V20.Questions.NewsAndDiscussions
migrateNewsAndDiscussions old =
    case old of
        Evergreen.V18.Questions.ElmDiscourse ->
            Evergreen.V20.Questions.ElmDiscourse

        Evergreen.V18.Questions.ElmSlack ->
            Evergreen.V20.Questions.ElmSlack

        Evergreen.V18.Questions.ElmSubreddit ->
            Evergreen.V20.Questions.ElmSubreddit

        Evergreen.V18.Questions.Twitter ->
            Evergreen.V20.Questions.Twitter

        Evergreen.V18.Questions.ElmRadio ->
            Evergreen.V20.Questions.ElmRadio

        Evergreen.V18.Questions.BlogPosts ->
            Evergreen.V20.Questions.BlogPosts

        Evergreen.V18.Questions.Facebook ->
            Evergreen.V20.Questions.Facebook

        Evergreen.V18.Questions.DevTo ->
            Evergreen.V20.Questions.DevTo

        Evergreen.V18.Questions.Meetups ->
            Evergreen.V20.Questions.Meetups

        Evergreen.V18.Questions.ElmWeekly ->
            Evergreen.V20.Questions.ElmWeekly

        Evergreen.V18.Questions.ElmNews ->
            Evergreen.V20.Questions.ElmNews

        Evergreen.V18.Questions.ElmCraft ->
            Evergreen.V20.Questions.ElmCraft


migrateOtherLanguages : Evergreen.V18.Questions.OtherLanguages -> Evergreen.V20.Questions.OtherLanguages
migrateOtherLanguages old =
    case old of
        Evergreen.V18.Questions.JavaScript ->
            Evergreen.V20.Questions.JavaScript

        Evergreen.V18.Questions.TypeScript ->
            Evergreen.V20.Questions.TypeScript

        Evergreen.V18.Questions.Go ->
            Evergreen.V20.Questions.Go

        Evergreen.V18.Questions.Haskell ->
            Evergreen.V20.Questions.Haskell

        Evergreen.V18.Questions.CSharp ->
            Evergreen.V20.Questions.CSharp

        Evergreen.V18.Questions.C ->
            Evergreen.V20.Questions.C

        Evergreen.V18.Questions.CPlusPlus ->
            Evergreen.V20.Questions.CPlusPlus

        Evergreen.V18.Questions.OCaml ->
            Evergreen.V20.Questions.OCaml

        Evergreen.V18.Questions.Python ->
            Evergreen.V20.Questions.Python

        Evergreen.V18.Questions.Swift ->
            Evergreen.V20.Questions.Swift

        Evergreen.V18.Questions.PHP ->
            Evergreen.V20.Questions.PHP

        Evergreen.V18.Questions.Java ->
            Evergreen.V20.Questions.Java

        Evergreen.V18.Questions.Ruby ->
            Evergreen.V20.Questions.Ruby

        Evergreen.V18.Questions.Elixir ->
            Evergreen.V20.Questions.Elixir

        Evergreen.V18.Questions.Clojure ->
            Evergreen.V20.Questions.Clojure

        Evergreen.V18.Questions.Rust ->
            Evergreen.V20.Questions.Rust

        Evergreen.V18.Questions.FSharp ->
            Evergreen.V20.Questions.FSharp


migrateStylingTools : Evergreen.V18.Questions.StylingTools -> Evergreen.V20.Questions.StylingTools
migrateStylingTools old =
    case old of
        Evergreen.V18.Questions.SassOrScss ->
            Evergreen.V20.Questions.SassOrScss

        Evergreen.V18.Questions.ElmCss ->
            Evergreen.V20.Questions.ElmCss

        Evergreen.V18.Questions.PlainCss ->
            Evergreen.V20.Questions.PlainCss

        Evergreen.V18.Questions.ElmUi ->
            Evergreen.V20.Questions.ElmUi

        Evergreen.V18.Questions.Tailwind ->
            Evergreen.V20.Questions.Tailwind

        Evergreen.V18.Questions.ElmTailwindModules ->
            Evergreen.V20.Questions.ElmTailwindModules

        Evergreen.V18.Questions.Bootstrap ->
            Evergreen.V20.Questions.Bootstrap


migrateTestTools : Evergreen.V18.Questions.TestTools -> Evergreen.V20.Questions.TestTools
migrateTestTools old =
    case old of
        Evergreen.V18.Questions.BrowserAcceptanceTests ->
            Evergreen.V20.Questions.BrowserAcceptanceTests

        Evergreen.V18.Questions.ElmBenchmark ->
            Evergreen.V20.Questions.ElmBenchmark

        Evergreen.V18.Questions.ElmTest ->
            Evergreen.V20.Questions.ElmTest

        Evergreen.V18.Questions.ElmProgramTest ->
            Evergreen.V20.Questions.ElmProgramTest

        Evergreen.V18.Questions.VisualRegressionTests ->
            Evergreen.V20.Questions.VisualRegressionTests


migrateTestsWrittenFor : Evergreen.V18.Questions.TestsWrittenFor -> Evergreen.V20.Questions.TestsWrittenFor
migrateTestsWrittenFor old =
    case old of
        Evergreen.V18.Questions.ComplicatedFunctions ->
            Evergreen.V20.Questions.ComplicatedFunctions

        Evergreen.V18.Questions.FunctionsThatReturnCmds ->
            Evergreen.V20.Questions.FunctionsThatReturnCmds

        Evergreen.V18.Questions.AllPublicFunctions ->
            Evergreen.V20.Questions.AllPublicFunctions

        Evergreen.V18.Questions.HtmlFunctions ->
            Evergreen.V20.Questions.HtmlFunctions

        Evergreen.V18.Questions.JsonDecodersAndEncoders ->
            Evergreen.V20.Questions.JsonDecodersAndEncoders

        Evergreen.V18.Questions.MostPublicFunctions ->
            Evergreen.V20.Questions.MostPublicFunctions


migrateWhatElmVersion : Evergreen.V18.Questions.WhatElmVersion -> Evergreen.V20.Questions.WhatElmVersion
migrateWhatElmVersion old =
    case old of
        Evergreen.V18.Questions.Version0_19 ->
            Evergreen.V20.Questions.Version0_19

        Evergreen.V18.Questions.Version0_18 ->
            Evergreen.V20.Questions.Version0_18

        Evergreen.V18.Questions.Version0_17 ->
            Evergreen.V20.Questions.Version0_17

        Evergreen.V18.Questions.Version0_16 ->
            Evergreen.V20.Questions.Version0_16


migrateWhatLanguageDoYouUseForTheBackend : Evergreen.V18.Questions.WhatLanguageDoYouUseForTheBackend -> Evergreen.V20.Questions.WhatLanguageDoYouUseForTheBackend
migrateWhatLanguageDoYouUseForTheBackend old =
    case old of
        Evergreen.V18.Questions.JavaScript_ ->
            Evergreen.V20.Questions.JavaScript_

        Evergreen.V18.Questions.TypeScript_ ->
            Evergreen.V20.Questions.TypeScript_

        Evergreen.V18.Questions.Go_ ->
            Evergreen.V20.Questions.Go_

        Evergreen.V18.Questions.Haskell_ ->
            Evergreen.V20.Questions.Haskell_

        Evergreen.V18.Questions.CSharp_ ->
            Evergreen.V20.Questions.CSharp_

        Evergreen.V18.Questions.OCaml_ ->
            Evergreen.V20.Questions.OCaml_

        Evergreen.V18.Questions.Python_ ->
            Evergreen.V20.Questions.Python_

        Evergreen.V18.Questions.PHP_ ->
            Evergreen.V20.Questions.PHP_

        Evergreen.V18.Questions.Java_ ->
            Evergreen.V20.Questions.Java_

        Evergreen.V18.Questions.Ruby_ ->
            Evergreen.V20.Questions.Ruby_

        Evergreen.V18.Questions.Elixir_ ->
            Evergreen.V20.Questions.Elixir_

        Evergreen.V18.Questions.Clojure_ ->
            Evergreen.V20.Questions.Clojure_

        Evergreen.V18.Questions.Rust_ ->
            Evergreen.V20.Questions.Rust_

        Evergreen.V18.Questions.FSharp_ ->
            Evergreen.V20.Questions.FSharp_

        Evergreen.V18.Questions.AlsoElm ->
            Evergreen.V20.Questions.AlsoElm

        Evergreen.V18.Questions.NotApplicable ->
            Evergreen.V20.Questions.NotApplicable


migrateWhereDoYouUseElm : Evergreen.V18.Questions.WhereDoYouUseElm -> Evergreen.V20.Questions.WhereDoYouUseElm
migrateWhereDoYouUseElm old =
    case old of
        Evergreen.V18.Questions.Education ->
            Evergreen.V20.Questions.Education

        Evergreen.V18.Questions.Gaming ->
            Evergreen.V20.Questions.Gaming

        Evergreen.V18.Questions.ECommerce ->
            Evergreen.V20.Questions.ECommerce

        Evergreen.V18.Questions.Music ->
            Evergreen.V20.Questions.Music

        Evergreen.V18.Questions.Finance ->
            Evergreen.V20.Questions.Finance

        Evergreen.V18.Questions.Health ->
            Evergreen.V20.Questions.Health

        Evergreen.V18.Questions.Productivity ->
            Evergreen.V20.Questions.Productivity

        Evergreen.V18.Questions.Communication ->
            Evergreen.V20.Questions.Communication

        Evergreen.V18.Questions.DataVisualization ->
            Evergreen.V20.Questions.DataVisualization

        Evergreen.V18.Questions.Transportation ->
            Evergreen.V20.Questions.Transportation


migrateWhichElmReviewRulesDoYouUse : Evergreen.V18.Questions.WhichElmReviewRulesDoYouUse -> Evergreen.V20.Questions.WhichElmReviewRulesDoYouUse
migrateWhichElmReviewRulesDoYouUse old =
    case old of
        Evergreen.V18.Questions.ElmReviewUnused ->
            Evergreen.V20.Questions.ElmReviewUnused

        Evergreen.V18.Questions.ElmReviewSimplify ->
            Evergreen.V20.Questions.ElmReviewSimplify

        Evergreen.V18.Questions.ElmReviewLicense ->
            Evergreen.V20.Questions.ElmReviewLicense

        Evergreen.V18.Questions.ElmReviewDebug ->
            Evergreen.V20.Questions.ElmReviewDebug

        Evergreen.V18.Questions.ElmReviewCommon ->
            Evergreen.V20.Questions.ElmReviewCommon

        Evergreen.V18.Questions.ElmReviewCognitiveComplexity ->
            Evergreen.V20.Questions.ElmReviewCognitiveComplexity


migrateAdminLoginData : Old.AdminLoginData -> Evergreen.V20.AdminPage.AdminLoginData
migrateAdminLoginData old =
    Debug.todo ""


migrateSessionId : Lamdera.SessionId -> Effect.Lamdera.SessionId
migrateSessionId =
    Effect.Lamdera.sessionIdFromString


migrateClientId : Lamdera.ClientId -> Effect.Lamdera.ClientId
migrateClientId =
    Effect.Lamdera.clientIdFromString


migrateDict : (keyA -> keyB) -> (valueA -> valueB) -> Dict keyA valueA -> Dict keyB valueB
migrateDict migrateKey migrateValue dict =
    Dict.toList dict |> List.map (Tuple.mapBoth migrateKey migrateValue) |> Dict.fromList


migrateBackendModel : Old.BackendModel -> New.BackendModel
migrateBackendModel old =
    { forms =
        migrateDict
            migrateSessionId
            (\value ->
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
    , adminLogin = Maybe.map migrateSessionId old.adminLogin
    }


migrateBackendMsg : Old.BackendMsg -> New.BackendMsg
migrateBackendMsg old =
    case old of
        Old.UserConnected a b ->
            New.UserConnected (migrateSessionId a) (migrateClientId b)

        Old.GotTimeWithUpdate a b c d ->
            New.GotTimeWithUpdate (migrateSessionId a) (migrateClientId b) (migrateToBackend c) d

        Old.GotTimeWithLoadFormData a b c ->
            New.GotTimeWithLoadFormData (migrateSessionId a) (migrateClientId b) c


migrateForm : Old.Form -> Evergreen.V20.Form.Form
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

        Old.TypedFormsData string ->
            New.AdminPageMsg (Evergreen.V20.AdminPage.TypedFormsData string)

        Old.PressedLogOut ->
            New.AdminPageMsg Evergreen.V20.AdminPage.PressedLogOut

        Old.GotTime a ->
            New.GotTime a


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


migrateSurveyResultsData : Evergreen.V18.SurveyResults.Data -> Evergreen.V20.SurveyResults.Data
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


migrateDataEntry : Evergreen.V18.DataEntry.DataEntry a -> Evergreen.V20.DataEntry.DataEntry b
migrateDataEntry (Evergreen.V18.DataEntry.DataEntry old) =
    Evergreen.V20.DataEntry.DataEntry old


migrateToBackend : Old.ToBackend -> New.ToBackend
migrateToBackend old =
    case old of
        Old.AutoSaveForm a ->
            New.AutoSaveForm (migrateForm a)

        Old.SubmitForm a ->
            New.SubmitForm (migrateForm a)

        Old.AdminLoginRequest a ->
            New.AdminLoginRequest a

        Old.ReplaceFormsRequest forms ->
            New.AdminToBackend (Evergreen.V20.AdminPage.ReplaceFormsRequest (List.map migrateForm forms))

        Old.LogOutRequest ->
            New.AdminToBackend Evergreen.V20.AdminPage.LogOutRequest


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
