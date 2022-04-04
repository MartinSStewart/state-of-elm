module Evergreen.Migrate.V18 exposing (..)

import AssocList as Dict
import AssocSet as Set
import Evergreen.V17.DataEntry
import Evergreen.V17.Questions
import Evergreen.V17.SurveyResults
import Evergreen.V17.Types as Old
import Evergreen.V18.DataEntry
import Evergreen.V18.Questions
import Evergreen.V18.SurveyResults
import Evergreen.V18.Types as New
import Lamdera.Migrations exposing (..)
import Time


migrateAge : Evergreen.V17.Questions.Age -> Evergreen.V18.Questions.Age
migrateAge old =
    case old of
        Evergreen.V17.Questions.Under10 ->
            Evergreen.V18.Questions.Under10

        Evergreen.V17.Questions.Age10To19 ->
            Evergreen.V18.Questions.Age10To19

        Evergreen.V17.Questions.Age20To29 ->
            Evergreen.V18.Questions.Age20To29

        Evergreen.V17.Questions.Age30To39 ->
            Evergreen.V18.Questions.Age30To39

        Evergreen.V17.Questions.Age40To49 ->
            Evergreen.V18.Questions.Age40To49

        Evergreen.V17.Questions.Age50To59 ->
            Evergreen.V18.Questions.Age50To59

        Evergreen.V17.Questions.Over60 ->
            Evergreen.V18.Questions.Over60


migrateBuildTools : Evergreen.V17.Questions.BuildTools -> Maybe Evergreen.V18.Questions.BuildTools
migrateBuildTools old =
    case old of
        Evergreen.V17.Questions.ShellScripts ->
            Just Evergreen.V18.Questions.ShellScripts

        Evergreen.V17.Questions.ElmLive ->
            Just Evergreen.V18.Questions.ElmLive

        Evergreen.V17.Questions.CreateElmApp ->
            Just Evergreen.V18.Questions.CreateElmApp

        Evergreen.V17.Questions.Webpack ->
            Just Evergreen.V18.Questions.Webpack

        Evergreen.V17.Questions.Brunch ->
            Just Evergreen.V18.Questions.Brunch

        Evergreen.V17.Questions.ElmMakeStandalone ->
            Just Evergreen.V18.Questions.ElmMakeStandalone

        Evergreen.V17.Questions.Gulp ->
            Just Evergreen.V18.Questions.Gulp

        Evergreen.V17.Questions.Make ->
            Just Evergreen.V18.Questions.Make

        Evergreen.V17.Questions.ElmReactor ->
            Just Evergreen.V18.Questions.ElmReactor

        Evergreen.V17.Questions.Parcel ->
            Just Evergreen.V18.Questions.Parcel

        Evergreen.V17.Questions.Vite ->
            Just Evergreen.V18.Questions.Vite


migrateDoYouUseElm : Evergreen.V17.Questions.DoYouUseElm -> Evergreen.V18.Questions.DoYouUseElm
migrateDoYouUseElm old =
    case old of
        Evergreen.V17.Questions.YesAtWork ->
            Evergreen.V18.Questions.YesAtWork

        Evergreen.V17.Questions.YesInSideProjects ->
            Evergreen.V18.Questions.YesInSideProjects

        Evergreen.V17.Questions.YesAsAStudent ->
            Evergreen.V18.Questions.YesAsAStudent

        Evergreen.V17.Questions.IUsedToButIDontAnymore ->
            Evergreen.V18.Questions.IUsedToButIDontAnymore

        Evergreen.V17.Questions.NoButImCuriousAboutIt ->
            Evergreen.V18.Questions.NoButImCuriousAboutIt

        Evergreen.V17.Questions.NoAndIDontPlanTo ->
            Evergreen.V18.Questions.NoAndIDontPlanTo


migrateDoYouUseElmAtWork : Evergreen.V17.Questions.DoYouUseElmAtWork -> Evergreen.V18.Questions.DoYouUseElmAtWork
migrateDoYouUseElmAtWork old =
    case old of
        Evergreen.V17.Questions.NotInterestedInElmAtWork ->
            Evergreen.V18.Questions.NotInterestedInElmAtWork

        Evergreen.V17.Questions.WouldLikeToUseElmAtWork ->
            Evergreen.V18.Questions.WouldLikeToUseElmAtWork

        Evergreen.V17.Questions.HaveTriedElmInAWorkProject ->
            Evergreen.V18.Questions.HaveTriedElmInAWorkProject

        Evergreen.V17.Questions.MyTeamMostlyWritesNewCodeInElm ->
            Evergreen.V18.Questions.MyTeamMostlyWritesNewCodeInElm

        Evergreen.V17.Questions.NotEmployed ->
            Evergreen.V18.Questions.NotEmployed


migrateDoYouUseElmFormat : Evergreen.V17.Questions.DoYouUseElmFormat -> Evergreen.V18.Questions.DoYouUseElmFormat
migrateDoYouUseElmFormat old =
    case old of
        Evergreen.V17.Questions.PreferElmFormat ->
            Evergreen.V18.Questions.PreferElmFormat

        Evergreen.V17.Questions.TriedButDontUseElmFormat ->
            Evergreen.V18.Questions.TriedButDontUseElmFormat

        Evergreen.V17.Questions.HeardButDontUseElmFormat ->
            Evergreen.V18.Questions.HeardButDontUseElmFormat

        Evergreen.V17.Questions.HaveNotHeardOfElmFormat ->
            Evergreen.V18.Questions.HaveNotHeardOfElmFormat


migrateDoYouUseElmReview : Evergreen.V17.Questions.DoYouUseElmReview -> Evergreen.V18.Questions.DoYouUseElmReview
migrateDoYouUseElmReview old =
    case old of
        Evergreen.V17.Questions.NeverHeardOfElmReview ->
            Evergreen.V18.Questions.NeverHeardOfElmReview

        Evergreen.V17.Questions.HeardOfItButNeverTriedElmReview ->
            Evergreen.V18.Questions.HeardOfItButNeverTriedElmReview

        Evergreen.V17.Questions.IveTriedElmReview ->
            Evergreen.V18.Questions.IveTriedElmReview

        Evergreen.V17.Questions.IUseElmReviewRegularly ->
            Evergreen.V18.Questions.IUseElmReviewRegularly


migrateEditor : Evergreen.V17.Questions.Editor -> Evergreen.V18.Questions.Editor
migrateEditor old =
    case old of
        Evergreen.V17.Questions.SublimeText ->
            Evergreen.V18.Questions.SublimeText

        Evergreen.V17.Questions.Vim ->
            Evergreen.V18.Questions.Vim

        Evergreen.V17.Questions.Atom ->
            Evergreen.V18.Questions.Atom

        Evergreen.V17.Questions.Emacs ->
            Evergreen.V18.Questions.Emacs

        Evergreen.V17.Questions.VSCode ->
            Evergreen.V18.Questions.VSCode

        Evergreen.V17.Questions.Intellij ->
            Evergreen.V18.Questions.Intellij


migrateElmResources : Evergreen.V17.Questions.ElmResources -> Evergreen.V18.Questions.ElmResources
migrateElmResources old =
    case old of
        Evergreen.V17.Questions.DailyDrip ->
            Evergreen.V18.Questions.DailyDrip

        Evergreen.V17.Questions.ElmInActionBook ->
            Evergreen.V18.Questions.ElmInActionBook

        Evergreen.V17.Questions.WeeklyBeginnersElmSubreddit ->
            Evergreen.V18.Questions.WeeklyBeginnersElmSubreddit

        Evergreen.V17.Questions.BeginningElmBook ->
            Evergreen.V18.Questions.BeginningElmBook

        Evergreen.V17.Questions.StackOverflow ->
            Evergreen.V18.Questions.StackOverflow

        Evergreen.V17.Questions.BuildingWebAppsWithElm ->
            Evergreen.V18.Questions.BuildingWebAppsWithElm

        Evergreen.V17.Questions.TheJsonSurvivalKit ->
            Evergreen.V18.Questions.TheJsonSurvivalKit

        Evergreen.V17.Questions.EggheadCourses ->
            Evergreen.V18.Questions.EggheadCourses

        Evergreen.V17.Questions.ProgrammingElmBook ->
            Evergreen.V18.Questions.ProgrammingElmBook

        Evergreen.V17.Questions.GuideElmLang ->
            Evergreen.V18.Questions.GuideElmLang

        Evergreen.V17.Questions.ElmForBeginners ->
            Evergreen.V18.Questions.ElmForBeginners

        Evergreen.V17.Questions.ElmSlack_ ->
            Evergreen.V18.Questions.ElmSlack_

        Evergreen.V17.Questions.FrontendMasters ->
            Evergreen.V18.Questions.FrontendMasters

        Evergreen.V17.Questions.ElmOnline ->
            Evergreen.V18.Questions.ElmOnline


migrateExperienceLevel : Evergreen.V17.Questions.ExperienceLevel -> Evergreen.V18.Questions.ExperienceLevel
migrateExperienceLevel old =
    case old of
        Evergreen.V17.Questions.Beginner ->
            Evergreen.V18.Questions.Beginner

        Evergreen.V17.Questions.Intermediate ->
            Evergreen.V18.Questions.Intermediate

        Evergreen.V17.Questions.Professional ->
            Evergreen.V18.Questions.Professional

        Evergreen.V17.Questions.Expert ->
            Evergreen.V18.Questions.Expert


migrateFrameworks : Evergreen.V17.Questions.Frameworks -> Evergreen.V18.Questions.Frameworks
migrateFrameworks old =
    case old of
        Evergreen.V17.Questions.Lamdera_ ->
            Evergreen.V18.Questions.Lamdera_

        Evergreen.V17.Questions.ElmSpa ->
            Evergreen.V18.Questions.ElmSpa

        Evergreen.V17.Questions.ElmPages ->
            Evergreen.V18.Questions.ElmPages

        Evergreen.V17.Questions.ElmPlayground ->
            Evergreen.V18.Questions.ElmPlayground


migrateHowLargeIsTheCompany : Evergreen.V17.Questions.HowLargeIsTheCompany -> Evergreen.V18.Questions.HowLargeIsTheCompany
migrateHowLargeIsTheCompany old =
    case old of
        Evergreen.V17.Questions.Size1To10Employees ->
            Evergreen.V18.Questions.Size1To10Employees

        Evergreen.V17.Questions.Size11To50Employees ->
            Evergreen.V18.Questions.Size11To50Employees

        Evergreen.V17.Questions.Size50To100Employees ->
            Evergreen.V18.Questions.Size50To100Employees

        Evergreen.V17.Questions.Size100OrMore ->
            Evergreen.V18.Questions.Size100OrMore


migrateHowLong : Evergreen.V17.Questions.HowLong -> Evergreen.V18.Questions.HowLong
migrateHowLong old =
    case old of
        Evergreen.V17.Questions.Under3Months ->
            Evergreen.V18.Questions.Under3Months

        Evergreen.V17.Questions.Between3MonthsAndAYear ->
            Evergreen.V18.Questions.Between3MonthsAndAYear

        Evergreen.V17.Questions.OneYear ->
            Evergreen.V18.Questions.OneYear

        Evergreen.V17.Questions.TwoYears ->
            Evergreen.V18.Questions.TwoYears

        Evergreen.V17.Questions.ThreeYears ->
            Evergreen.V18.Questions.ThreeYears

        Evergreen.V17.Questions.FourYears ->
            Evergreen.V18.Questions.FourYears

        Evergreen.V17.Questions.FiveYears ->
            Evergreen.V18.Questions.FiveYears

        Evergreen.V17.Questions.SixYears ->
            Evergreen.V18.Questions.SixYears

        Evergreen.V17.Questions.SevenYears ->
            Evergreen.V18.Questions.SevenYears

        Evergreen.V17.Questions.EightYears ->
            Evergreen.V18.Questions.EightYears

        Evergreen.V17.Questions.NineYears ->
            Evergreen.V18.Questions.NineYears


migrateNewsAndDiscussions : Evergreen.V17.Questions.NewsAndDiscussions -> Evergreen.V18.Questions.NewsAndDiscussions
migrateNewsAndDiscussions old =
    case old of
        Evergreen.V17.Questions.ElmDiscourse ->
            Evergreen.V18.Questions.ElmDiscourse

        Evergreen.V17.Questions.ElmSlack ->
            Evergreen.V18.Questions.ElmSlack

        Evergreen.V17.Questions.ElmSubreddit ->
            Evergreen.V18.Questions.ElmSubreddit

        Evergreen.V17.Questions.Twitter ->
            Evergreen.V18.Questions.Twitter

        Evergreen.V17.Questions.ElmRadio ->
            Evergreen.V18.Questions.ElmRadio

        Evergreen.V17.Questions.BlogPosts ->
            Evergreen.V18.Questions.BlogPosts

        Evergreen.V17.Questions.Facebook ->
            Evergreen.V18.Questions.Facebook

        Evergreen.V17.Questions.DevTo ->
            Evergreen.V18.Questions.DevTo

        Evergreen.V17.Questions.Meetups ->
            Evergreen.V18.Questions.Meetups

        Evergreen.V17.Questions.ElmWeekly ->
            Evergreen.V18.Questions.ElmWeekly

        Evergreen.V17.Questions.ElmNews ->
            Evergreen.V18.Questions.ElmNews

        Evergreen.V17.Questions.ElmCraft ->
            Evergreen.V18.Questions.ElmCraft


migrateOtherLanguages : Evergreen.V17.Questions.OtherLanguages -> Evergreen.V18.Questions.OtherLanguages
migrateOtherLanguages old =
    case old of
        Evergreen.V17.Questions.JavaScript ->
            Evergreen.V18.Questions.JavaScript

        Evergreen.V17.Questions.TypeScript ->
            Evergreen.V18.Questions.TypeScript

        Evergreen.V17.Questions.Go ->
            Evergreen.V18.Questions.Go

        Evergreen.V17.Questions.Haskell ->
            Evergreen.V18.Questions.Haskell

        Evergreen.V17.Questions.CSharp ->
            Evergreen.V18.Questions.CSharp

        Evergreen.V17.Questions.C ->
            Evergreen.V18.Questions.C

        Evergreen.V17.Questions.CPlusPlus ->
            Evergreen.V18.Questions.CPlusPlus

        Evergreen.V17.Questions.OCaml ->
            Evergreen.V18.Questions.OCaml

        Evergreen.V17.Questions.Python ->
            Evergreen.V18.Questions.Python

        Evergreen.V17.Questions.Swift ->
            Evergreen.V18.Questions.Swift

        Evergreen.V17.Questions.PHP ->
            Evergreen.V18.Questions.PHP

        Evergreen.V17.Questions.Java ->
            Evergreen.V18.Questions.Java

        Evergreen.V17.Questions.Ruby ->
            Evergreen.V18.Questions.Ruby

        Evergreen.V17.Questions.Elixir ->
            Evergreen.V18.Questions.Elixir

        Evergreen.V17.Questions.Clojure ->
            Evergreen.V18.Questions.Clojure

        Evergreen.V17.Questions.Rust ->
            Evergreen.V18.Questions.Rust

        Evergreen.V17.Questions.FSharp ->
            Evergreen.V18.Questions.FSharp


migrateStylingTools : Evergreen.V17.Questions.StylingTools -> Evergreen.V18.Questions.StylingTools
migrateStylingTools old =
    case old of
        Evergreen.V17.Questions.SassOrScss ->
            Evergreen.V18.Questions.SassOrScss

        Evergreen.V17.Questions.ElmCss ->
            Evergreen.V18.Questions.ElmCss

        Evergreen.V17.Questions.PlainCss ->
            Evergreen.V18.Questions.PlainCss

        Evergreen.V17.Questions.ElmUi ->
            Evergreen.V18.Questions.ElmUi

        Evergreen.V17.Questions.Tailwind ->
            Evergreen.V18.Questions.Tailwind

        Evergreen.V17.Questions.ElmTailwindModules ->
            Evergreen.V18.Questions.ElmTailwindModules

        Evergreen.V17.Questions.Bootstrap ->
            Evergreen.V18.Questions.Bootstrap


migrateTestTools : Evergreen.V17.Questions.TestTools -> Evergreen.V18.Questions.TestTools
migrateTestTools old =
    case old of
        Evergreen.V17.Questions.BrowserAcceptanceTests ->
            Evergreen.V18.Questions.BrowserAcceptanceTests

        Evergreen.V17.Questions.ElmBenchmark ->
            Evergreen.V18.Questions.ElmBenchmark

        Evergreen.V17.Questions.ElmTest ->
            Evergreen.V18.Questions.ElmTest

        Evergreen.V17.Questions.ElmProgramTest ->
            Evergreen.V18.Questions.ElmProgramTest

        Evergreen.V17.Questions.VisualRegressionTests ->
            Evergreen.V18.Questions.VisualRegressionTests


migrateTestsWrittenFor : Evergreen.V17.Questions.TestsWrittenFor -> Evergreen.V18.Questions.TestsWrittenFor
migrateTestsWrittenFor old =
    case old of
        Evergreen.V17.Questions.ComplicatedFunctions ->
            Evergreen.V18.Questions.ComplicatedFunctions

        Evergreen.V17.Questions.FunctionsThatReturnCmds ->
            Evergreen.V18.Questions.FunctionsThatReturnCmds

        Evergreen.V17.Questions.AllPublicFunctions ->
            Evergreen.V18.Questions.AllPublicFunctions

        Evergreen.V17.Questions.HtmlFunctions ->
            Evergreen.V18.Questions.HtmlFunctions

        Evergreen.V17.Questions.JsonDecodersAndEncoders ->
            Evergreen.V18.Questions.JsonDecodersAndEncoders

        Evergreen.V17.Questions.MostPublicFunctions ->
            Evergreen.V18.Questions.MostPublicFunctions


migrateWhatElmVersion : Evergreen.V17.Questions.WhatElmVersion -> Evergreen.V18.Questions.WhatElmVersion
migrateWhatElmVersion old =
    case old of
        Evergreen.V17.Questions.Version0_19 ->
            Evergreen.V18.Questions.Version0_19

        Evergreen.V17.Questions.Version0_18 ->
            Evergreen.V18.Questions.Version0_18

        Evergreen.V17.Questions.Version0_17 ->
            Evergreen.V18.Questions.Version0_17

        Evergreen.V17.Questions.Version0_16 ->
            Evergreen.V18.Questions.Version0_16


migrateWhatLanguageDoYouUseForTheBackend : Evergreen.V17.Questions.WhatLanguageDoYouUseForTheBackend -> Evergreen.V18.Questions.WhatLanguageDoYouUseForTheBackend
migrateWhatLanguageDoYouUseForTheBackend old =
    case old of
        Evergreen.V17.Questions.JavaScript_ ->
            Evergreen.V18.Questions.JavaScript_

        Evergreen.V17.Questions.TypeScript_ ->
            Evergreen.V18.Questions.TypeScript_

        Evergreen.V17.Questions.Go_ ->
            Evergreen.V18.Questions.Go_

        Evergreen.V17.Questions.Haskell_ ->
            Evergreen.V18.Questions.Haskell_

        Evergreen.V17.Questions.CSharp_ ->
            Evergreen.V18.Questions.CSharp_

        Evergreen.V17.Questions.OCaml_ ->
            Evergreen.V18.Questions.OCaml_

        Evergreen.V17.Questions.Python_ ->
            Evergreen.V18.Questions.Python_

        Evergreen.V17.Questions.PHP_ ->
            Evergreen.V18.Questions.PHP_

        Evergreen.V17.Questions.Java_ ->
            Evergreen.V18.Questions.Java_

        Evergreen.V17.Questions.Ruby_ ->
            Evergreen.V18.Questions.Ruby_

        Evergreen.V17.Questions.Elixir_ ->
            Evergreen.V18.Questions.Elixir_

        Evergreen.V17.Questions.Clojure_ ->
            Evergreen.V18.Questions.Clojure_

        Evergreen.V17.Questions.Rust_ ->
            Evergreen.V18.Questions.Rust_

        Evergreen.V17.Questions.FSharp_ ->
            Evergreen.V18.Questions.FSharp_

        Evergreen.V17.Questions.AlsoElm ->
            Evergreen.V18.Questions.AlsoElm

        Evergreen.V17.Questions.NotApplicable ->
            Evergreen.V18.Questions.NotApplicable


migrateWhereDoYouUseElm : Evergreen.V17.Questions.WhereDoYouUseElm -> Evergreen.V18.Questions.WhereDoYouUseElm
migrateWhereDoYouUseElm old =
    case old of
        Evergreen.V17.Questions.Education ->
            Evergreen.V18.Questions.Education

        Evergreen.V17.Questions.Gaming ->
            Evergreen.V18.Questions.Gaming

        Evergreen.V17.Questions.ECommerce ->
            Evergreen.V18.Questions.ECommerce

        Evergreen.V17.Questions.Audio ->
            Evergreen.V18.Questions.Music

        Evergreen.V17.Questions.Finance ->
            Evergreen.V18.Questions.Finance

        Evergreen.V17.Questions.Health ->
            Evergreen.V18.Questions.Health

        Evergreen.V17.Questions.Productivity ->
            Evergreen.V18.Questions.Productivity

        Evergreen.V17.Questions.Communication ->
            Evergreen.V18.Questions.Communication

        Evergreen.V17.Questions.DataVisualization ->
            Evergreen.V18.Questions.DataVisualization

        Evergreen.V17.Questions.Transportation ->
            Evergreen.V18.Questions.Transportation


migrateWhichElmReviewRulesDoYouUse : Evergreen.V17.Questions.WhichElmReviewRulesDoYouUse -> Evergreen.V18.Questions.WhichElmReviewRulesDoYouUse
migrateWhichElmReviewRulesDoYouUse old =
    case old of
        Evergreen.V17.Questions.ElmReviewUnused ->
            Evergreen.V18.Questions.ElmReviewUnused

        Evergreen.V17.Questions.ElmReviewSimplify ->
            Evergreen.V18.Questions.ElmReviewSimplify

        Evergreen.V17.Questions.ElmReviewLicense ->
            Evergreen.V18.Questions.ElmReviewLicense

        Evergreen.V17.Questions.ElmReviewDebug ->
            Evergreen.V18.Questions.ElmReviewDebug

        Evergreen.V17.Questions.ElmReviewCommon ->
            Evergreen.V18.Questions.ElmReviewCommon

        Evergreen.V17.Questions.ElmReviewCognitiveComplexity ->
            Evergreen.V18.Questions.ElmReviewCognitiveComplexity


migrateAdminLoginData : Old.AdminLoginData -> New.AdminLoginData
migrateAdminLoginData old =
    { forms = [] }


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
    , windowSize = { width = 1920, height = 1080 }
    , time = Time.millisToPosix 0
    }


migrateFrontendModel : Old.FrontendModel -> New.FrontendModel
migrateFrontendModel old =
    case old of
        Old.Loading loading ->
            New.Loading loading Nothing

        Old.FormLoaded a ->
            New.FormLoaded (migrateFormLoaded_ a)

        Old.FormCompleted ->
            New.FormCompleted (Time.millisToPosix 0)

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
            New.TypedFormsData string


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


migrateSurveyResultsData : Evergreen.V17.SurveyResults.Data -> Evergreen.V18.SurveyResults.Data
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


migrateDataEntry : Evergreen.V17.DataEntry.DataEntry a -> Evergreen.V18.DataEntry.DataEntry b
migrateDataEntry (Evergreen.V17.DataEntry.DataEntry old) =
    Evergreen.V18.DataEntry.DataEntry old


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
