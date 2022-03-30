module Evergreen.Migrate.V9 exposing (..)

import AssocList as Dict
import AssocSet as Set
import Evergreen.V8.Questions
import Evergreen.V8.Types as Old
import Evergreen.V9.Questions
import Evergreen.V9.Types as New
import Lamdera.Migrations exposing (..)


migrateAge : Evergreen.V8.Questions.Age -> Evergreen.V9.Questions.Age
migrateAge old =
    case old of
        Evergreen.V8.Questions.Under10 ->
            Evergreen.V9.Questions.Under10

        Evergreen.V8.Questions.Age10To19 ->
            Evergreen.V9.Questions.Age10To19

        Evergreen.V8.Questions.Age20To29 ->
            Evergreen.V9.Questions.Age20To29

        Evergreen.V8.Questions.Age30To39 ->
            Evergreen.V9.Questions.Age30To39

        Evergreen.V8.Questions.Age40To49 ->
            Evergreen.V9.Questions.Age40To49

        Evergreen.V8.Questions.Age50To59 ->
            Evergreen.V9.Questions.Age50To59

        Evergreen.V8.Questions.Over60 ->
            Evergreen.V9.Questions.Over60


migrateBuildTools : Evergreen.V8.Questions.BuildTools -> Maybe Evergreen.V9.Questions.BuildTools
migrateBuildTools old =
    case old of
        Evergreen.V8.Questions.ShellScripts ->
            Just Evergreen.V9.Questions.ShellScripts

        Evergreen.V8.Questions.ElmLive ->
            Just Evergreen.V9.Questions.ElmLive

        Evergreen.V8.Questions.CreateElmApp ->
            Just Evergreen.V9.Questions.CreateElmApp

        Evergreen.V8.Questions.Webpack ->
            Just Evergreen.V9.Questions.Webpack

        Evergreen.V8.Questions.Brunch ->
            Just Evergreen.V9.Questions.Brunch

        Evergreen.V8.Questions.ElmMakeStandalone ->
            Just Evergreen.V9.Questions.ElmMakeStandalone

        Evergreen.V8.Questions.Gulp ->
            Just Evergreen.V9.Questions.Gulp

        Evergreen.V8.Questions.Make ->
            Just Evergreen.V9.Questions.Make

        Evergreen.V8.Questions.ElmReactor ->
            Just Evergreen.V9.Questions.ElmReactor

        Evergreen.V8.Questions.Lamdera ->
            Nothing

        Evergreen.V8.Questions.Parcel ->
            Just Evergreen.V9.Questions.Parcel


migrateDoYouUseElm : Evergreen.V8.Questions.DoYouUseElm -> Evergreen.V9.Questions.DoYouUseElm
migrateDoYouUseElm old =
    case old of
        Evergreen.V8.Questions.YesAtWork ->
            Evergreen.V9.Questions.YesAtWork

        Evergreen.V8.Questions.YesInSideProjects ->
            Evergreen.V9.Questions.YesInSideProjects

        Evergreen.V8.Questions.YesAsAStudent ->
            Evergreen.V9.Questions.YesAsAStudent

        Evergreen.V8.Questions.IUsedToButIDontAnymore ->
            Evergreen.V9.Questions.IUsedToButIDontAnymore

        Evergreen.V8.Questions.NoButImCuriousAboutIt ->
            Evergreen.V9.Questions.NoButImCuriousAboutIt

        Evergreen.V8.Questions.NoAndIDontPlanTo ->
            Evergreen.V9.Questions.NoAndIDontPlanTo


migrateDoYouUseElmAtWork : Evergreen.V8.Questions.DoYouUseElmAtWork -> Evergreen.V9.Questions.DoYouUseElmAtWork
migrateDoYouUseElmAtWork old =
    case old of
        Evergreen.V8.Questions.NotInterestedInElmAtWork ->
            Evergreen.V9.Questions.NotInterestedInElmAtWork

        Evergreen.V8.Questions.WouldLikeToUseElmAtWork ->
            Evergreen.V9.Questions.WouldLikeToUseElmAtWork

        Evergreen.V8.Questions.HaveTriedElmInAWorkProject ->
            Evergreen.V9.Questions.HaveTriedElmInAWorkProject

        Evergreen.V8.Questions.MyTeamMostlyWritesNewCodeInElm ->
            Evergreen.V9.Questions.MyTeamMostlyWritesNewCodeInElm

        Evergreen.V8.Questions.NotEmployed ->
            Evergreen.V9.Questions.NotEmployed


migrateDoYouUseElmFormat : Evergreen.V8.Questions.DoYouUseElmFormat -> Evergreen.V9.Questions.DoYouUseElmFormat
migrateDoYouUseElmFormat old =
    case old of
        Evergreen.V8.Questions.PreferElmFormat ->
            Evergreen.V9.Questions.PreferElmFormat

        Evergreen.V8.Questions.TriedButDontUseElmFormat ->
            Evergreen.V9.Questions.TriedButDontUseElmFormat

        Evergreen.V8.Questions.HeardButDontUseElmFormat ->
            Evergreen.V9.Questions.HeardButDontUseElmFormat

        Evergreen.V8.Questions.HaveNotHeardOfElmFormat ->
            Evergreen.V9.Questions.HaveNotHeardOfElmFormat


migrateDoYouUseElmReview : Evergreen.V8.Questions.DoYouUseElmReview -> Evergreen.V9.Questions.DoYouUseElmReview
migrateDoYouUseElmReview old =
    case old of
        Evergreen.V8.Questions.NeverHeardOfElmReview ->
            Evergreen.V9.Questions.NeverHeardOfElmReview

        Evergreen.V8.Questions.HeardOfItButNeverTriedElmReview ->
            Evergreen.V9.Questions.HeardOfItButNeverTriedElmReview

        Evergreen.V8.Questions.IveTriedElmReview ->
            Evergreen.V9.Questions.IveTriedElmReview

        Evergreen.V8.Questions.IUseElmReviewRegularly ->
            Evergreen.V9.Questions.IUseElmReviewRegularly


migrateEditor : Evergreen.V8.Questions.Editor -> Evergreen.V9.Questions.Editor
migrateEditor old =
    case old of
        Evergreen.V8.Questions.SublimeText ->
            Evergreen.V9.Questions.SublimeText

        Evergreen.V8.Questions.Vim ->
            Evergreen.V9.Questions.Vim

        Evergreen.V8.Questions.Atom ->
            Evergreen.V9.Questions.Atom

        Evergreen.V8.Questions.Emacs ->
            Evergreen.V9.Questions.Emacs

        Evergreen.V8.Questions.VSCode ->
            Evergreen.V9.Questions.VSCode

        Evergreen.V8.Questions.Intellij ->
            Evergreen.V9.Questions.Intellij


migrateElmResources : Evergreen.V8.Questions.ElmResources -> Evergreen.V9.Questions.ElmResources
migrateElmResources old =
    case old of
        Evergreen.V8.Questions.DailyDrip ->
            Evergreen.V9.Questions.DailyDrip

        Evergreen.V8.Questions.ElmInActionBook ->
            Evergreen.V9.Questions.ElmInActionBook

        Evergreen.V8.Questions.WeeklyBeginnersElmSubreddit ->
            Evergreen.V9.Questions.WeeklyBeginnersElmSubreddit

        Evergreen.V8.Questions.BeginningElmBook ->
            Evergreen.V9.Questions.BeginningElmBook

        Evergreen.V8.Questions.StackOverflow ->
            Evergreen.V9.Questions.StackOverflow

        Evergreen.V8.Questions.BuildingWebAppsWithElm ->
            Evergreen.V9.Questions.BuildingWebAppsWithElm

        Evergreen.V8.Questions.TheJsonSurvivalKit ->
            Evergreen.V9.Questions.TheJsonSurvivalKit

        Evergreen.V8.Questions.EggheadCourses ->
            Evergreen.V9.Questions.EggheadCourses

        Evergreen.V8.Questions.ProgrammingElmBook ->
            Evergreen.V9.Questions.ProgrammingElmBook

        Evergreen.V8.Questions.GuideElmLang ->
            Evergreen.V9.Questions.GuideElmLang

        Evergreen.V8.Questions.ElmForBeginners ->
            Evergreen.V9.Questions.ElmForBeginners

        Evergreen.V8.Questions.ElmSlack_ ->
            Evergreen.V9.Questions.ElmSlack_

        Evergreen.V8.Questions.FrontendMasters ->
            Evergreen.V9.Questions.FrontendMasters

        Evergreen.V8.Questions.ElmOnline ->
            Evergreen.V9.Questions.ElmOnline


migrateExperienceLevel : Evergreen.V8.Questions.ExperienceLevel -> Evergreen.V9.Questions.ExperienceLevel
migrateExperienceLevel old =
    case old of
        Evergreen.V8.Questions.Level0 ->
            Evergreen.V9.Questions.Level0

        Evergreen.V8.Questions.Level1 ->
            Evergreen.V9.Questions.Level1

        Evergreen.V8.Questions.Level2 ->
            Evergreen.V9.Questions.Level2

        Evergreen.V8.Questions.Level3 ->
            Evergreen.V9.Questions.Level3

        Evergreen.V8.Questions.Level4 ->
            Evergreen.V9.Questions.Level4

        Evergreen.V8.Questions.Level5 ->
            Evergreen.V9.Questions.Level5

        Evergreen.V8.Questions.Level6 ->
            Evergreen.V9.Questions.Level6

        Evergreen.V8.Questions.Level7 ->
            Evergreen.V9.Questions.Level7

        Evergreen.V8.Questions.Level8 ->
            Evergreen.V9.Questions.Level8

        Evergreen.V8.Questions.Level9 ->
            Evergreen.V9.Questions.Level9

        Evergreen.V8.Questions.Level10 ->
            Evergreen.V9.Questions.Level10


migrateFrameworks : Evergreen.V8.Questions.Frameworks -> Evergreen.V9.Questions.Frameworks
migrateFrameworks old =
    case old of
        Evergreen.V8.Questions.Lamdera_ ->
            Evergreen.V9.Questions.Lamdera_

        Evergreen.V8.Questions.ElmSpa ->
            Evergreen.V9.Questions.ElmSpa

        Evergreen.V8.Questions.ElmPages ->
            Evergreen.V9.Questions.ElmPages

        Evergreen.V8.Questions.ElmPlayground ->
            Evergreen.V9.Questions.ElmPlayground


migrateHowLargeIsTheCompany : Evergreen.V8.Questions.HowLargeIsTheCompany -> Evergreen.V9.Questions.HowLargeIsTheCompany
migrateHowLargeIsTheCompany old =
    case old of
        Evergreen.V8.Questions.Size1To10Employees ->
            Evergreen.V9.Questions.Size1To10Employees

        Evergreen.V8.Questions.Size11To50Employees ->
            Evergreen.V9.Questions.Size11To50Employees

        Evergreen.V8.Questions.Size50To100Employees ->
            Evergreen.V9.Questions.Size50To100Employees

        Evergreen.V8.Questions.Size100OrMore ->
            Evergreen.V9.Questions.Size100OrMore


migrateHowLong : Evergreen.V8.Questions.HowLong -> Evergreen.V9.Questions.HowLong
migrateHowLong old =
    case old of
        Evergreen.V8.Questions.Under3Months ->
            Evergreen.V9.Questions.Under3Months

        Evergreen.V8.Questions.Between3MonthsAndAYear ->
            Evergreen.V9.Questions.Between3MonthsAndAYear

        Evergreen.V8.Questions.OneYear ->
            Evergreen.V9.Questions.OneYear

        Evergreen.V8.Questions.TwoYears ->
            Evergreen.V9.Questions.TwoYears

        Evergreen.V8.Questions.ThreeYears ->
            Evergreen.V9.Questions.ThreeYears

        Evergreen.V8.Questions.FourYears ->
            Evergreen.V9.Questions.FourYears

        Evergreen.V8.Questions.FiveYears ->
            Evergreen.V9.Questions.FiveYears

        Evergreen.V8.Questions.SixYears ->
            Evergreen.V9.Questions.SixYears

        Evergreen.V8.Questions.SevenYears ->
            Evergreen.V9.Questions.SevenYears

        Evergreen.V8.Questions.EightYears ->
            Evergreen.V9.Questions.EightYears

        Evergreen.V8.Questions.NineYears ->
            Evergreen.V9.Questions.NineYears


migrateNewsAndDiscussions : Evergreen.V8.Questions.NewsAndDiscussions -> Evergreen.V9.Questions.NewsAndDiscussions
migrateNewsAndDiscussions old =
    case old of
        Evergreen.V8.Questions.ElmDiscourse ->
            Evergreen.V9.Questions.ElmDiscourse

        Evergreen.V8.Questions.ElmSlack ->
            Evergreen.V9.Questions.ElmSlack

        Evergreen.V8.Questions.ElmSubreddit ->
            Evergreen.V9.Questions.ElmSubreddit

        Evergreen.V8.Questions.Twitter ->
            Evergreen.V9.Questions.Twitter

        Evergreen.V8.Questions.ElmRadio ->
            Evergreen.V9.Questions.ElmRadio

        Evergreen.V8.Questions.BlogPosts ->
            Evergreen.V9.Questions.BlogPosts

        Evergreen.V8.Questions.Facebook ->
            Evergreen.V9.Questions.Facebook

        Evergreen.V8.Questions.DevTo ->
            Evergreen.V9.Questions.DevTo

        Evergreen.V8.Questions.Meetups ->
            Evergreen.V9.Questions.Meetups

        Evergreen.V8.Questions.ElmWeekly ->
            Evergreen.V9.Questions.ElmWeekly

        Evergreen.V8.Questions.ElmNews ->
            Evergreen.V9.Questions.ElmNews


migrateOtherLanguages : Evergreen.V8.Questions.OtherLanguages -> Evergreen.V9.Questions.OtherLanguages
migrateOtherLanguages old =
    case old of
        Evergreen.V8.Questions.JavaScript ->
            Evergreen.V9.Questions.JavaScript

        Evergreen.V8.Questions.TypeScript ->
            Evergreen.V9.Questions.TypeScript

        Evergreen.V8.Questions.Go ->
            Evergreen.V9.Questions.Go

        Evergreen.V8.Questions.Haskell ->
            Evergreen.V9.Questions.Haskell

        Evergreen.V8.Questions.CSharp ->
            Evergreen.V9.Questions.CSharp

        Evergreen.V8.Questions.C ->
            Evergreen.V9.Questions.C

        Evergreen.V8.Questions.CPlusPlus ->
            Evergreen.V9.Questions.CPlusPlus

        Evergreen.V8.Questions.OCaml ->
            Evergreen.V9.Questions.OCaml

        Evergreen.V8.Questions.Python ->
            Evergreen.V9.Questions.Python

        Evergreen.V8.Questions.Swift ->
            Evergreen.V9.Questions.Swift

        Evergreen.V8.Questions.PHP ->
            Evergreen.V9.Questions.PHP

        Evergreen.V8.Questions.Java ->
            Evergreen.V9.Questions.Java

        Evergreen.V8.Questions.Ruby ->
            Evergreen.V9.Questions.Ruby

        Evergreen.V8.Questions.Elixir ->
            Evergreen.V9.Questions.Elixir

        Evergreen.V8.Questions.Clojure ->
            Evergreen.V9.Questions.Clojure

        Evergreen.V8.Questions.Rust ->
            Evergreen.V9.Questions.Rust

        Evergreen.V8.Questions.FSharp ->
            Evergreen.V9.Questions.FSharp


migrateStylingTools : Evergreen.V8.Questions.StylingTools -> Evergreen.V9.Questions.StylingTools
migrateStylingTools old =
    case old of
        Evergreen.V8.Questions.SassOrScss ->
            Evergreen.V9.Questions.SassOrScss

        Evergreen.V8.Questions.ElmCss ->
            Evergreen.V9.Questions.ElmCss

        Evergreen.V8.Questions.PlainCss ->
            Evergreen.V9.Questions.PlainCss

        Evergreen.V8.Questions.ElmUi ->
            Evergreen.V9.Questions.ElmUi

        Evergreen.V8.Questions.Tailwind ->
            Evergreen.V9.Questions.Tailwind

        Evergreen.V8.Questions.ElmTailwindModules ->
            Evergreen.V9.Questions.ElmTailwindModules

        Evergreen.V8.Questions.Bootstrap ->
            Evergreen.V9.Questions.Bootstrap


migrateTestTools : Evergreen.V8.Questions.TestTools -> Evergreen.V9.Questions.TestTools
migrateTestTools old =
    case old of
        Evergreen.V8.Questions.BrowserAcceptanceTests ->
            Evergreen.V9.Questions.BrowserAcceptanceTests

        Evergreen.V8.Questions.ElmBenchmark ->
            Evergreen.V9.Questions.ElmBenchmark

        Evergreen.V8.Questions.ElmTest ->
            Evergreen.V9.Questions.ElmTest

        Evergreen.V8.Questions.ElmProgramTest ->
            Evergreen.V9.Questions.ElmProgramTest

        Evergreen.V8.Questions.VisualRegressionTests ->
            Evergreen.V9.Questions.VisualRegressionTests


migrateTestsWrittenFor : Evergreen.V8.Questions.TestsWrittenFor -> Evergreen.V9.Questions.TestsWrittenFor
migrateTestsWrittenFor old =
    case old of
        Evergreen.V8.Questions.ComplicatedFunctions ->
            Evergreen.V9.Questions.ComplicatedFunctions

        Evergreen.V8.Questions.FunctionsThatReturnCmds ->
            Evergreen.V9.Questions.FunctionsThatReturnCmds

        Evergreen.V8.Questions.AllPublicFunctions ->
            Evergreen.V9.Questions.AllPublicFunctions

        Evergreen.V8.Questions.HtmlFunctions ->
            Evergreen.V9.Questions.HtmlFunctions

        Evergreen.V8.Questions.JsonDecodersAndEncoders ->
            Evergreen.V9.Questions.JsonDecodersAndEncoders

        Evergreen.V8.Questions.MostPublicFunctions ->
            Evergreen.V9.Questions.MostPublicFunctions


migrateWhatElmVersion : Evergreen.V8.Questions.WhatElmVersion -> Evergreen.V9.Questions.WhatElmVersion
migrateWhatElmVersion old =
    case old of
        Evergreen.V8.Questions.Version0_19 ->
            Evergreen.V9.Questions.Version0_19

        Evergreen.V8.Questions.Version0_18 ->
            Evergreen.V9.Questions.Version0_18

        Evergreen.V8.Questions.Version0_17 ->
            Evergreen.V9.Questions.Version0_17

        Evergreen.V8.Questions.Version0_16 ->
            Evergreen.V9.Questions.Version0_16


migrateWhatLanguageDoYouUseForTheBackend : Evergreen.V8.Questions.WhatLanguageDoYouUseForTheBackend -> Evergreen.V9.Questions.WhatLanguageDoYouUseForTheBackend
migrateWhatLanguageDoYouUseForTheBackend old =
    case old of
        Evergreen.V8.Questions.JavaScript_ ->
            Evergreen.V9.Questions.JavaScript_

        Evergreen.V8.Questions.TypeScript_ ->
            Evergreen.V9.Questions.TypeScript_

        Evergreen.V8.Questions.Go_ ->
            Evergreen.V9.Questions.Go_

        Evergreen.V8.Questions.Haskell_ ->
            Evergreen.V9.Questions.Haskell_

        Evergreen.V8.Questions.CSharp_ ->
            Evergreen.V9.Questions.CSharp_

        Evergreen.V8.Questions.OCaml_ ->
            Evergreen.V9.Questions.OCaml_

        Evergreen.V8.Questions.Python_ ->
            Evergreen.V9.Questions.Python_

        Evergreen.V8.Questions.PHP_ ->
            Evergreen.V9.Questions.PHP_

        Evergreen.V8.Questions.Java_ ->
            Evergreen.V9.Questions.Java_

        Evergreen.V8.Questions.Ruby_ ->
            Evergreen.V9.Questions.Ruby_

        Evergreen.V8.Questions.Elixir_ ->
            Evergreen.V9.Questions.Elixir_

        Evergreen.V8.Questions.Clojure_ ->
            Evergreen.V9.Questions.Clojure_

        Evergreen.V8.Questions.Rust_ ->
            Evergreen.V9.Questions.Rust_

        Evergreen.V8.Questions.FSharp_ ->
            Evergreen.V9.Questions.FSharp_

        Evergreen.V8.Questions.AlsoElm ->
            Evergreen.V9.Questions.AlsoElm

        Evergreen.V8.Questions.NotApplicable ->
            Evergreen.V9.Questions.NotApplicable


migrateWhereDoYouUseElm : Evergreen.V8.Questions.WhereDoYouUseElm -> Evergreen.V9.Questions.WhereDoYouUseElm
migrateWhereDoYouUseElm old =
    case old of
        Evergreen.V8.Questions.Education ->
            Evergreen.V9.Questions.Education

        Evergreen.V8.Questions.Gaming ->
            Evergreen.V9.Questions.Gaming

        Evergreen.V8.Questions.ECommerce ->
            Evergreen.V9.Questions.ECommerce

        Evergreen.V8.Questions.Audio ->
            Evergreen.V9.Questions.Audio

        Evergreen.V8.Questions.Finance ->
            Evergreen.V9.Questions.Finance

        Evergreen.V8.Questions.Health ->
            Evergreen.V9.Questions.Health

        Evergreen.V8.Questions.Productivity ->
            Evergreen.V9.Questions.Productivity

        Evergreen.V8.Questions.Communication ->
            Evergreen.V9.Questions.Communication

        Evergreen.V8.Questions.DataVisualization ->
            Evergreen.V9.Questions.DataVisualization

        Evergreen.V8.Questions.Transportation ->
            Evergreen.V9.Questions.Transportation


migrateWhichElmReviewRulesDoYouUse : Evergreen.V8.Questions.WhichElmReviewRulesDoYouUse -> Evergreen.V9.Questions.WhichElmReviewRulesDoYouUse
migrateWhichElmReviewRulesDoYouUse old =
    case old of
        Evergreen.V8.Questions.ElmReviewUnused ->
            Evergreen.V9.Questions.ElmReviewUnused

        Evergreen.V8.Questions.ElmReviewSimplify ->
            Evergreen.V9.Questions.ElmReviewSimplify

        Evergreen.V8.Questions.ElmReviewLicense ->
            Evergreen.V9.Questions.ElmReviewLicense

        Evergreen.V8.Questions.ElmReviewDebug ->
            Evergreen.V9.Questions.ElmReviewDebug

        Evergreen.V8.Questions.ElmReviewCommon ->
            Evergreen.V9.Questions.ElmReviewCommon

        Evergreen.V8.Questions.ElmReviewCognitiveComplexity ->
            Evergreen.V9.Questions.ElmReviewCognitiveComplexity


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

        Old.UrlChanged a ->
            New.UrlChanged a

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
