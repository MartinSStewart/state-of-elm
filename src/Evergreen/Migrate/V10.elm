module Evergreen.Migrate.V10 exposing (..)

import AssocList as Dict
import AssocSet as Set
import Evergreen.V10.Questions
import Evergreen.V10.Types as New
import Evergreen.V9.Questions
import Evergreen.V9.Types as Old
import Lamdera.Migrations exposing (..)


migrateAge : Evergreen.V9.Questions.Age -> Evergreen.V10.Questions.Age
migrateAge old =
    case old of
        Evergreen.V9.Questions.Under10 ->
            Evergreen.V10.Questions.Under10

        Evergreen.V9.Questions.Age10To19 ->
            Evergreen.V10.Questions.Age10To19

        Evergreen.V9.Questions.Age20To29 ->
            Evergreen.V10.Questions.Age20To29

        Evergreen.V9.Questions.Age30To39 ->
            Evergreen.V10.Questions.Age30To39

        Evergreen.V9.Questions.Age40To49 ->
            Evergreen.V10.Questions.Age40To49

        Evergreen.V9.Questions.Age50To59 ->
            Evergreen.V10.Questions.Age50To59

        Evergreen.V9.Questions.Over60 ->
            Evergreen.V10.Questions.Over60


migrateBuildTools : Evergreen.V9.Questions.BuildTools -> Maybe Evergreen.V10.Questions.BuildTools
migrateBuildTools old =
    case old of
        Evergreen.V9.Questions.ShellScripts ->
            Just Evergreen.V10.Questions.ShellScripts

        Evergreen.V9.Questions.ElmLive ->
            Just Evergreen.V10.Questions.ElmLive

        Evergreen.V9.Questions.CreateElmApp ->
            Just Evergreen.V10.Questions.CreateElmApp

        Evergreen.V9.Questions.Webpack ->
            Just Evergreen.V10.Questions.Webpack

        Evergreen.V9.Questions.Brunch ->
            Just Evergreen.V10.Questions.Brunch

        Evergreen.V9.Questions.ElmMakeStandalone ->
            Just Evergreen.V10.Questions.ElmMakeStandalone

        Evergreen.V9.Questions.Gulp ->
            Just Evergreen.V10.Questions.Gulp

        Evergreen.V9.Questions.Make ->
            Just Evergreen.V10.Questions.Make

        Evergreen.V9.Questions.ElmReactor ->
            Just Evergreen.V10.Questions.ElmReactor

        Evergreen.V9.Questions.Parcel ->
            Just Evergreen.V10.Questions.Parcel

        Evergreen.V9.Questions.Vite ->
            Just Evergreen.V10.Questions.Vite


migrateDoYouUseElm : Evergreen.V9.Questions.DoYouUseElm -> Evergreen.V10.Questions.DoYouUseElm
migrateDoYouUseElm old =
    case old of
        Evergreen.V9.Questions.YesAtWork ->
            Evergreen.V10.Questions.YesAtWork

        Evergreen.V9.Questions.YesInSideProjects ->
            Evergreen.V10.Questions.YesInSideProjects

        Evergreen.V9.Questions.YesAsAStudent ->
            Evergreen.V10.Questions.YesAsAStudent

        Evergreen.V9.Questions.IUsedToButIDontAnymore ->
            Evergreen.V10.Questions.IUsedToButIDontAnymore

        Evergreen.V9.Questions.NoButImCuriousAboutIt ->
            Evergreen.V10.Questions.NoButImCuriousAboutIt

        Evergreen.V9.Questions.NoAndIDontPlanTo ->
            Evergreen.V10.Questions.NoAndIDontPlanTo


migrateDoYouUseElmAtWork : Evergreen.V9.Questions.DoYouUseElmAtWork -> Evergreen.V10.Questions.DoYouUseElmAtWork
migrateDoYouUseElmAtWork old =
    case old of
        Evergreen.V9.Questions.NotInterestedInElmAtWork ->
            Evergreen.V10.Questions.NotInterestedInElmAtWork

        Evergreen.V9.Questions.WouldLikeToUseElmAtWork ->
            Evergreen.V10.Questions.WouldLikeToUseElmAtWork

        Evergreen.V9.Questions.HaveTriedElmInAWorkProject ->
            Evergreen.V10.Questions.HaveTriedElmInAWorkProject

        Evergreen.V9.Questions.MyTeamMostlyWritesNewCodeInElm ->
            Evergreen.V10.Questions.MyTeamMostlyWritesNewCodeInElm

        Evergreen.V9.Questions.NotEmployed ->
            Evergreen.V10.Questions.NotEmployed


migrateDoYouUseElmFormat : Evergreen.V9.Questions.DoYouUseElmFormat -> Evergreen.V10.Questions.DoYouUseElmFormat
migrateDoYouUseElmFormat old =
    case old of
        Evergreen.V9.Questions.PreferElmFormat ->
            Evergreen.V10.Questions.PreferElmFormat

        Evergreen.V9.Questions.TriedButDontUseElmFormat ->
            Evergreen.V10.Questions.TriedButDontUseElmFormat

        Evergreen.V9.Questions.HeardButDontUseElmFormat ->
            Evergreen.V10.Questions.HeardButDontUseElmFormat

        Evergreen.V9.Questions.HaveNotHeardOfElmFormat ->
            Evergreen.V10.Questions.HaveNotHeardOfElmFormat


migrateDoYouUseElmReview : Evergreen.V9.Questions.DoYouUseElmReview -> Evergreen.V10.Questions.DoYouUseElmReview
migrateDoYouUseElmReview old =
    case old of
        Evergreen.V9.Questions.NeverHeardOfElmReview ->
            Evergreen.V10.Questions.NeverHeardOfElmReview

        Evergreen.V9.Questions.HeardOfItButNeverTriedElmReview ->
            Evergreen.V10.Questions.HeardOfItButNeverTriedElmReview

        Evergreen.V9.Questions.IveTriedElmReview ->
            Evergreen.V10.Questions.IveTriedElmReview

        Evergreen.V9.Questions.IUseElmReviewRegularly ->
            Evergreen.V10.Questions.IUseElmReviewRegularly


migrateEditor : Evergreen.V9.Questions.Editor -> Evergreen.V10.Questions.Editor
migrateEditor old =
    case old of
        Evergreen.V9.Questions.SublimeText ->
            Evergreen.V10.Questions.SublimeText

        Evergreen.V9.Questions.Vim ->
            Evergreen.V10.Questions.Vim

        Evergreen.V9.Questions.Atom ->
            Evergreen.V10.Questions.Atom

        Evergreen.V9.Questions.Emacs ->
            Evergreen.V10.Questions.Emacs

        Evergreen.V9.Questions.VSCode ->
            Evergreen.V10.Questions.VSCode

        Evergreen.V9.Questions.Intellij ->
            Evergreen.V10.Questions.Intellij


migrateElmResources : Evergreen.V9.Questions.ElmResources -> Evergreen.V10.Questions.ElmResources
migrateElmResources old =
    case old of
        Evergreen.V9.Questions.DailyDrip ->
            Evergreen.V10.Questions.DailyDrip

        Evergreen.V9.Questions.ElmInActionBook ->
            Evergreen.V10.Questions.ElmInActionBook

        Evergreen.V9.Questions.WeeklyBeginnersElmSubreddit ->
            Evergreen.V10.Questions.WeeklyBeginnersElmSubreddit

        Evergreen.V9.Questions.BeginningElmBook ->
            Evergreen.V10.Questions.BeginningElmBook

        Evergreen.V9.Questions.StackOverflow ->
            Evergreen.V10.Questions.StackOverflow

        Evergreen.V9.Questions.BuildingWebAppsWithElm ->
            Evergreen.V10.Questions.BuildingWebAppsWithElm

        Evergreen.V9.Questions.TheJsonSurvivalKit ->
            Evergreen.V10.Questions.TheJsonSurvivalKit

        Evergreen.V9.Questions.EggheadCourses ->
            Evergreen.V10.Questions.EggheadCourses

        Evergreen.V9.Questions.ProgrammingElmBook ->
            Evergreen.V10.Questions.ProgrammingElmBook

        Evergreen.V9.Questions.GuideElmLang ->
            Evergreen.V10.Questions.GuideElmLang

        Evergreen.V9.Questions.ElmForBeginners ->
            Evergreen.V10.Questions.ElmForBeginners

        Evergreen.V9.Questions.ElmSlack_ ->
            Evergreen.V10.Questions.ElmSlack_

        Evergreen.V9.Questions.FrontendMasters ->
            Evergreen.V10.Questions.FrontendMasters

        Evergreen.V9.Questions.ElmOnline ->
            Evergreen.V10.Questions.ElmOnline


migrateExperienceLevel : Evergreen.V9.Questions.ExperienceLevel -> Evergreen.V10.Questions.ExperienceLevel
migrateExperienceLevel old =
    case old of
        Evergreen.V9.Questions.Level0 ->
            Evergreen.V10.Questions.Beginner

        Evergreen.V9.Questions.Level1 ->
            Evergreen.V10.Questions.Beginner

        Evergreen.V9.Questions.Level2 ->
            Evergreen.V10.Questions.Beginner

        Evergreen.V9.Questions.Level3 ->
            Evergreen.V10.Questions.Intermediate

        Evergreen.V9.Questions.Level4 ->
            Evergreen.V10.Questions.Intermediate

        Evergreen.V9.Questions.Level5 ->
            Evergreen.V10.Questions.Intermediate

        Evergreen.V9.Questions.Level6 ->
            Evergreen.V10.Questions.Professional

        Evergreen.V9.Questions.Level7 ->
            Evergreen.V10.Questions.Professional

        Evergreen.V9.Questions.Level8 ->
            Evergreen.V10.Questions.Professional

        Evergreen.V9.Questions.Level9 ->
            Evergreen.V10.Questions.Expert

        Evergreen.V9.Questions.Level10 ->
            Evergreen.V10.Questions.Expert


migrateFrameworks : Evergreen.V9.Questions.Frameworks -> Evergreen.V10.Questions.Frameworks
migrateFrameworks old =
    case old of
        Evergreen.V9.Questions.Lamdera_ ->
            Evergreen.V10.Questions.Lamdera_

        Evergreen.V9.Questions.ElmSpa ->
            Evergreen.V10.Questions.ElmSpa

        Evergreen.V9.Questions.ElmPages ->
            Evergreen.V10.Questions.ElmPages

        Evergreen.V9.Questions.ElmPlayground ->
            Evergreen.V10.Questions.ElmPlayground


migrateHowLargeIsTheCompany : Evergreen.V9.Questions.HowLargeIsTheCompany -> Evergreen.V10.Questions.HowLargeIsTheCompany
migrateHowLargeIsTheCompany old =
    case old of
        Evergreen.V9.Questions.Size1To10Employees ->
            Evergreen.V10.Questions.Size1To10Employees

        Evergreen.V9.Questions.Size11To50Employees ->
            Evergreen.V10.Questions.Size11To50Employees

        Evergreen.V9.Questions.Size50To100Employees ->
            Evergreen.V10.Questions.Size50To100Employees

        Evergreen.V9.Questions.Size100OrMore ->
            Evergreen.V10.Questions.Size100OrMore


migrateHowLong : Evergreen.V9.Questions.HowLong -> Evergreen.V10.Questions.HowLong
migrateHowLong old =
    case old of
        Evergreen.V9.Questions.Under3Months ->
            Evergreen.V10.Questions.Under3Months

        Evergreen.V9.Questions.Between3MonthsAndAYear ->
            Evergreen.V10.Questions.Between3MonthsAndAYear

        Evergreen.V9.Questions.OneYear ->
            Evergreen.V10.Questions.OneYear

        Evergreen.V9.Questions.TwoYears ->
            Evergreen.V10.Questions.TwoYears

        Evergreen.V9.Questions.ThreeYears ->
            Evergreen.V10.Questions.ThreeYears

        Evergreen.V9.Questions.FourYears ->
            Evergreen.V10.Questions.FourYears

        Evergreen.V9.Questions.FiveYears ->
            Evergreen.V10.Questions.FiveYears

        Evergreen.V9.Questions.SixYears ->
            Evergreen.V10.Questions.SixYears

        Evergreen.V9.Questions.SevenYears ->
            Evergreen.V10.Questions.SevenYears

        Evergreen.V9.Questions.EightYears ->
            Evergreen.V10.Questions.EightYears

        Evergreen.V9.Questions.NineYears ->
            Evergreen.V10.Questions.NineYears


migrateNewsAndDiscussions : Evergreen.V9.Questions.NewsAndDiscussions -> Evergreen.V10.Questions.NewsAndDiscussions
migrateNewsAndDiscussions old =
    case old of
        Evergreen.V9.Questions.ElmDiscourse ->
            Evergreen.V10.Questions.ElmDiscourse

        Evergreen.V9.Questions.ElmSlack ->
            Evergreen.V10.Questions.ElmSlack

        Evergreen.V9.Questions.ElmSubreddit ->
            Evergreen.V10.Questions.ElmSubreddit

        Evergreen.V9.Questions.Twitter ->
            Evergreen.V10.Questions.Twitter

        Evergreen.V9.Questions.ElmRadio ->
            Evergreen.V10.Questions.ElmRadio

        Evergreen.V9.Questions.BlogPosts ->
            Evergreen.V10.Questions.BlogPosts

        Evergreen.V9.Questions.Facebook ->
            Evergreen.V10.Questions.Facebook

        Evergreen.V9.Questions.DevTo ->
            Evergreen.V10.Questions.DevTo

        Evergreen.V9.Questions.Meetups ->
            Evergreen.V10.Questions.Meetups

        Evergreen.V9.Questions.ElmWeekly ->
            Evergreen.V10.Questions.ElmWeekly

        Evergreen.V9.Questions.ElmNews ->
            Evergreen.V10.Questions.ElmNews

        Evergreen.V9.Questions.ElmCraft ->
            Evergreen.V10.Questions.ElmCraft


migrateOtherLanguages : Evergreen.V9.Questions.OtherLanguages -> Evergreen.V10.Questions.OtherLanguages
migrateOtherLanguages old =
    case old of
        Evergreen.V9.Questions.JavaScript ->
            Evergreen.V10.Questions.JavaScript

        Evergreen.V9.Questions.TypeScript ->
            Evergreen.V10.Questions.TypeScript

        Evergreen.V9.Questions.Go ->
            Evergreen.V10.Questions.Go

        Evergreen.V9.Questions.Haskell ->
            Evergreen.V10.Questions.Haskell

        Evergreen.V9.Questions.CSharp ->
            Evergreen.V10.Questions.CSharp

        Evergreen.V9.Questions.C ->
            Evergreen.V10.Questions.C

        Evergreen.V9.Questions.CPlusPlus ->
            Evergreen.V10.Questions.CPlusPlus

        Evergreen.V9.Questions.OCaml ->
            Evergreen.V10.Questions.OCaml

        Evergreen.V9.Questions.Python ->
            Evergreen.V10.Questions.Python

        Evergreen.V9.Questions.Swift ->
            Evergreen.V10.Questions.Swift

        Evergreen.V9.Questions.PHP ->
            Evergreen.V10.Questions.PHP

        Evergreen.V9.Questions.Java ->
            Evergreen.V10.Questions.Java

        Evergreen.V9.Questions.Ruby ->
            Evergreen.V10.Questions.Ruby

        Evergreen.V9.Questions.Elixir ->
            Evergreen.V10.Questions.Elixir

        Evergreen.V9.Questions.Clojure ->
            Evergreen.V10.Questions.Clojure

        Evergreen.V9.Questions.Rust ->
            Evergreen.V10.Questions.Rust

        Evergreen.V9.Questions.FSharp ->
            Evergreen.V10.Questions.FSharp


migrateStylingTools : Evergreen.V9.Questions.StylingTools -> Evergreen.V10.Questions.StylingTools
migrateStylingTools old =
    case old of
        Evergreen.V9.Questions.SassOrScss ->
            Evergreen.V10.Questions.SassOrScss

        Evergreen.V9.Questions.ElmCss ->
            Evergreen.V10.Questions.ElmCss

        Evergreen.V9.Questions.PlainCss ->
            Evergreen.V10.Questions.PlainCss

        Evergreen.V9.Questions.ElmUi ->
            Evergreen.V10.Questions.ElmUi

        Evergreen.V9.Questions.Tailwind ->
            Evergreen.V10.Questions.Tailwind

        Evergreen.V9.Questions.ElmTailwindModules ->
            Evergreen.V10.Questions.ElmTailwindModules

        Evergreen.V9.Questions.Bootstrap ->
            Evergreen.V10.Questions.Bootstrap


migrateTestTools : Evergreen.V9.Questions.TestTools -> Evergreen.V10.Questions.TestTools
migrateTestTools old =
    case old of
        Evergreen.V9.Questions.BrowserAcceptanceTests ->
            Evergreen.V10.Questions.BrowserAcceptanceTests

        Evergreen.V9.Questions.ElmBenchmark ->
            Evergreen.V10.Questions.ElmBenchmark

        Evergreen.V9.Questions.ElmTest ->
            Evergreen.V10.Questions.ElmTest

        Evergreen.V9.Questions.ElmProgramTest ->
            Evergreen.V10.Questions.ElmProgramTest

        Evergreen.V9.Questions.VisualRegressionTests ->
            Evergreen.V10.Questions.VisualRegressionTests


migrateTestsWrittenFor : Evergreen.V9.Questions.TestsWrittenFor -> Evergreen.V10.Questions.TestsWrittenFor
migrateTestsWrittenFor old =
    case old of
        Evergreen.V9.Questions.ComplicatedFunctions ->
            Evergreen.V10.Questions.ComplicatedFunctions

        Evergreen.V9.Questions.FunctionsThatReturnCmds ->
            Evergreen.V10.Questions.FunctionsThatReturnCmds

        Evergreen.V9.Questions.AllPublicFunctions ->
            Evergreen.V10.Questions.AllPublicFunctions

        Evergreen.V9.Questions.HtmlFunctions ->
            Evergreen.V10.Questions.HtmlFunctions

        Evergreen.V9.Questions.JsonDecodersAndEncoders ->
            Evergreen.V10.Questions.JsonDecodersAndEncoders

        Evergreen.V9.Questions.MostPublicFunctions ->
            Evergreen.V10.Questions.MostPublicFunctions


migrateWhatElmVersion : Evergreen.V9.Questions.WhatElmVersion -> Evergreen.V10.Questions.WhatElmVersion
migrateWhatElmVersion old =
    case old of
        Evergreen.V9.Questions.Version0_19 ->
            Evergreen.V10.Questions.Version0_19

        Evergreen.V9.Questions.Version0_18 ->
            Evergreen.V10.Questions.Version0_18

        Evergreen.V9.Questions.Version0_17 ->
            Evergreen.V10.Questions.Version0_17

        Evergreen.V9.Questions.Version0_16 ->
            Evergreen.V10.Questions.Version0_16


migrateWhatLanguageDoYouUseForTheBackend : Evergreen.V9.Questions.WhatLanguageDoYouUseForTheBackend -> Evergreen.V10.Questions.WhatLanguageDoYouUseForTheBackend
migrateWhatLanguageDoYouUseForTheBackend old =
    case old of
        Evergreen.V9.Questions.JavaScript_ ->
            Evergreen.V10.Questions.JavaScript_

        Evergreen.V9.Questions.TypeScript_ ->
            Evergreen.V10.Questions.TypeScript_

        Evergreen.V9.Questions.Go_ ->
            Evergreen.V10.Questions.Go_

        Evergreen.V9.Questions.Haskell_ ->
            Evergreen.V10.Questions.Haskell_

        Evergreen.V9.Questions.CSharp_ ->
            Evergreen.V10.Questions.CSharp_

        Evergreen.V9.Questions.OCaml_ ->
            Evergreen.V10.Questions.OCaml_

        Evergreen.V9.Questions.Python_ ->
            Evergreen.V10.Questions.Python_

        Evergreen.V9.Questions.PHP_ ->
            Evergreen.V10.Questions.PHP_

        Evergreen.V9.Questions.Java_ ->
            Evergreen.V10.Questions.Java_

        Evergreen.V9.Questions.Ruby_ ->
            Evergreen.V10.Questions.Ruby_

        Evergreen.V9.Questions.Elixir_ ->
            Evergreen.V10.Questions.Elixir_

        Evergreen.V9.Questions.Clojure_ ->
            Evergreen.V10.Questions.Clojure_

        Evergreen.V9.Questions.Rust_ ->
            Evergreen.V10.Questions.Rust_

        Evergreen.V9.Questions.FSharp_ ->
            Evergreen.V10.Questions.FSharp_

        Evergreen.V9.Questions.AlsoElm ->
            Evergreen.V10.Questions.AlsoElm

        Evergreen.V9.Questions.NotApplicable ->
            Evergreen.V10.Questions.NotApplicable


migrateWhereDoYouUseElm : Evergreen.V9.Questions.WhereDoYouUseElm -> Evergreen.V10.Questions.WhereDoYouUseElm
migrateWhereDoYouUseElm old =
    case old of
        Evergreen.V9.Questions.Education ->
            Evergreen.V10.Questions.Education

        Evergreen.V9.Questions.Gaming ->
            Evergreen.V10.Questions.Gaming

        Evergreen.V9.Questions.ECommerce ->
            Evergreen.V10.Questions.ECommerce

        Evergreen.V9.Questions.Audio ->
            Evergreen.V10.Questions.Audio

        Evergreen.V9.Questions.Finance ->
            Evergreen.V10.Questions.Finance

        Evergreen.V9.Questions.Health ->
            Evergreen.V10.Questions.Health

        Evergreen.V9.Questions.Productivity ->
            Evergreen.V10.Questions.Productivity

        Evergreen.V9.Questions.Communication ->
            Evergreen.V10.Questions.Communication

        Evergreen.V9.Questions.DataVisualization ->
            Evergreen.V10.Questions.DataVisualization

        Evergreen.V9.Questions.Transportation ->
            Evergreen.V10.Questions.Transportation


migrateWhichElmReviewRulesDoYouUse : Evergreen.V9.Questions.WhichElmReviewRulesDoYouUse -> Evergreen.V10.Questions.WhichElmReviewRulesDoYouUse
migrateWhichElmReviewRulesDoYouUse old =
    case old of
        Evergreen.V9.Questions.ElmReviewUnused ->
            Evergreen.V10.Questions.ElmReviewUnused

        Evergreen.V9.Questions.ElmReviewSimplify ->
            Evergreen.V10.Questions.ElmReviewSimplify

        Evergreen.V9.Questions.ElmReviewLicense ->
            Evergreen.V10.Questions.ElmReviewLicense

        Evergreen.V9.Questions.ElmReviewDebug ->
            Evergreen.V10.Questions.ElmReviewDebug

        Evergreen.V9.Questions.ElmReviewCommon ->
            Evergreen.V10.Questions.ElmReviewCommon

        Evergreen.V9.Questions.ElmReviewCognitiveComplexity ->
            Evergreen.V10.Questions.ElmReviewCognitiveComplexity


migrateAdminLoginData : Old.AdminLoginData -> New.AdminLoginData
migrateAdminLoginData old =
    old


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
    , adminLogin = old.adminLogin
    }


migrateBackendMsg : Old.BackendMsg -> New.BackendMsg
migrateBackendMsg old =
    case old of
        Old.UserConnected a b ->
            New.UserConnected a b

        Old.GotTimeWithUpdate a b c d ->
            New.GotTimeWithUpdate a b (migrateToBackend c) d


migrateForm : Old.Form -> New.Form
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
    }


migrateFrontendModel : Old.FrontendModel -> New.FrontendModel
migrateFrontendModel old =
    case old of
        Old.Loading ->
            New.Loading

        Old.FormLoaded a ->
            New.FormLoaded (migrateFormLoaded_ a)

        Old.FormCompleted ->
            New.FormCompleted

        Old.AdminLogin a ->
            New.AdminLogin { password = identity a.password, loginFailed = identity a.loginFailed }

        Old.Admin a ->
            New.Admin (migrateAdminLoginData a)


migrateFrontendMsg : Old.FrontendMsg -> New.FrontendMsg
migrateFrontendMsg old =
    case old of
        Old.UrlClicked a ->
            New.UrlClicked a

        Old.UrlChanged _ ->
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


migrateLoadFormStatus : Old.LoadFormStatus -> New.LoadFormStatus
migrateLoadFormStatus old =
    case old of
        Old.NoFormFound ->
            New.NoFormFound

        Old.FormAutoSaved a ->
            New.FormAutoSaved (migrateForm a)

        Old.FormSubmitted ->
            New.FormSubmitted


migrateToBackend : Old.ToBackend -> New.ToBackend
migrateToBackend old =
    case old of
        Old.AutoSaveForm a ->
            New.AutoSaveForm (migrateForm a)

        Old.SubmitForm a ->
            New.SubmitForm (migrateForm a)

        Old.AdminLoginRequest a ->
            New.AdminLoginRequest a


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
