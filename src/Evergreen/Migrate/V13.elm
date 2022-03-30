module Evergreen.Migrate.V13 exposing (..)

import AssocList as Dict
import AssocSet as Set
import Evergreen.V12.Questions
import Evergreen.V12.Types as Old
import Evergreen.V13.Questions
import Evergreen.V13.Types as New
import Lamdera.Migrations exposing (..)


migrateAge : Evergreen.V12.Questions.Age -> Evergreen.V13.Questions.Age
migrateAge old =
    case old of
        Evergreen.V12.Questions.Under10 ->
            Evergreen.V13.Questions.Under10

        Evergreen.V12.Questions.Age10To19 ->
            Evergreen.V13.Questions.Age10To19

        Evergreen.V12.Questions.Age20To29 ->
            Evergreen.V13.Questions.Age20To29

        Evergreen.V12.Questions.Age30To39 ->
            Evergreen.V13.Questions.Age30To39

        Evergreen.V12.Questions.Age40To49 ->
            Evergreen.V13.Questions.Age40To49

        Evergreen.V12.Questions.Age50To59 ->
            Evergreen.V13.Questions.Age50To59

        Evergreen.V12.Questions.Over60 ->
            Evergreen.V13.Questions.Over60


migrateBuildTools : Evergreen.V12.Questions.BuildTools -> Maybe Evergreen.V13.Questions.BuildTools
migrateBuildTools old =
    case old of
        Evergreen.V12.Questions.ShellScripts ->
            Just Evergreen.V13.Questions.ShellScripts

        Evergreen.V12.Questions.ElmLive ->
            Just Evergreen.V13.Questions.ElmLive

        Evergreen.V12.Questions.CreateElmApp ->
            Just Evergreen.V13.Questions.CreateElmApp

        Evergreen.V12.Questions.Webpack ->
            Just Evergreen.V13.Questions.Webpack

        Evergreen.V12.Questions.Brunch ->
            Just Evergreen.V13.Questions.Brunch

        Evergreen.V12.Questions.ElmMakeStandalone ->
            Just Evergreen.V13.Questions.ElmMakeStandalone

        Evergreen.V12.Questions.Gulp ->
            Just Evergreen.V13.Questions.Gulp

        Evergreen.V12.Questions.Make ->
            Just Evergreen.V13.Questions.Make

        Evergreen.V12.Questions.ElmReactor ->
            Just Evergreen.V13.Questions.ElmReactor

        Evergreen.V12.Questions.Parcel ->
            Just Evergreen.V13.Questions.Parcel

        Evergreen.V12.Questions.Vite ->
            Just Evergreen.V13.Questions.Vite


migrateDoYouUseElm : Evergreen.V12.Questions.DoYouUseElm -> Evergreen.V13.Questions.DoYouUseElm
migrateDoYouUseElm old =
    case old of
        Evergreen.V12.Questions.YesAtWork ->
            Evergreen.V13.Questions.YesAtWork

        Evergreen.V12.Questions.YesInSideProjects ->
            Evergreen.V13.Questions.YesInSideProjects

        Evergreen.V12.Questions.YesAsAStudent ->
            Evergreen.V13.Questions.YesAsAStudent

        Evergreen.V12.Questions.IUsedToButIDontAnymore ->
            Evergreen.V13.Questions.IUsedToButIDontAnymore

        Evergreen.V12.Questions.NoButImCuriousAboutIt ->
            Evergreen.V13.Questions.NoButImCuriousAboutIt

        Evergreen.V12.Questions.NoAndIDontPlanTo ->
            Evergreen.V13.Questions.NoAndIDontPlanTo


migrateDoYouUseElmAtWork : Evergreen.V12.Questions.DoYouUseElmAtWork -> Evergreen.V13.Questions.DoYouUseElmAtWork
migrateDoYouUseElmAtWork old =
    case old of
        Evergreen.V12.Questions.NotInterestedInElmAtWork ->
            Evergreen.V13.Questions.NotInterestedInElmAtWork

        Evergreen.V12.Questions.WouldLikeToUseElmAtWork ->
            Evergreen.V13.Questions.WouldLikeToUseElmAtWork

        Evergreen.V12.Questions.HaveTriedElmInAWorkProject ->
            Evergreen.V13.Questions.HaveTriedElmInAWorkProject

        Evergreen.V12.Questions.MyTeamMostlyWritesNewCodeInElm ->
            Evergreen.V13.Questions.MyTeamMostlyWritesNewCodeInElm

        Evergreen.V12.Questions.NotEmployed ->
            Evergreen.V13.Questions.NotEmployed


migrateDoYouUseElmFormat : Evergreen.V12.Questions.DoYouUseElmFormat -> Evergreen.V13.Questions.DoYouUseElmFormat
migrateDoYouUseElmFormat old =
    case old of
        Evergreen.V12.Questions.PreferElmFormat ->
            Evergreen.V13.Questions.PreferElmFormat

        Evergreen.V12.Questions.TriedButDontUseElmFormat ->
            Evergreen.V13.Questions.TriedButDontUseElmFormat

        Evergreen.V12.Questions.HeardButDontUseElmFormat ->
            Evergreen.V13.Questions.HeardButDontUseElmFormat

        Evergreen.V12.Questions.HaveNotHeardOfElmFormat ->
            Evergreen.V13.Questions.HaveNotHeardOfElmFormat


migrateDoYouUseElmReview : Evergreen.V12.Questions.DoYouUseElmReview -> Evergreen.V13.Questions.DoYouUseElmReview
migrateDoYouUseElmReview old =
    case old of
        Evergreen.V12.Questions.NeverHeardOfElmReview ->
            Evergreen.V13.Questions.NeverHeardOfElmReview

        Evergreen.V12.Questions.HeardOfItButNeverTriedElmReview ->
            Evergreen.V13.Questions.HeardOfItButNeverTriedElmReview

        Evergreen.V12.Questions.IveTriedElmReview ->
            Evergreen.V13.Questions.IveTriedElmReview

        Evergreen.V12.Questions.IUseElmReviewRegularly ->
            Evergreen.V13.Questions.IUseElmReviewRegularly


migrateEditor : Evergreen.V12.Questions.Editor -> Evergreen.V13.Questions.Editor
migrateEditor old =
    case old of
        Evergreen.V12.Questions.SublimeText ->
            Evergreen.V13.Questions.SublimeText

        Evergreen.V12.Questions.Vim ->
            Evergreen.V13.Questions.Vim

        Evergreen.V12.Questions.Atom ->
            Evergreen.V13.Questions.Atom

        Evergreen.V12.Questions.Emacs ->
            Evergreen.V13.Questions.Emacs

        Evergreen.V12.Questions.VSCode ->
            Evergreen.V13.Questions.VSCode

        Evergreen.V12.Questions.Intellij ->
            Evergreen.V13.Questions.Intellij


migrateElmResources : Evergreen.V12.Questions.ElmResources -> Evergreen.V13.Questions.ElmResources
migrateElmResources old =
    case old of
        Evergreen.V12.Questions.DailyDrip ->
            Evergreen.V13.Questions.DailyDrip

        Evergreen.V12.Questions.ElmInActionBook ->
            Evergreen.V13.Questions.ElmInActionBook

        Evergreen.V12.Questions.WeeklyBeginnersElmSubreddit ->
            Evergreen.V13.Questions.WeeklyBeginnersElmSubreddit

        Evergreen.V12.Questions.BeginningElmBook ->
            Evergreen.V13.Questions.BeginningElmBook

        Evergreen.V12.Questions.StackOverflow ->
            Evergreen.V13.Questions.StackOverflow

        Evergreen.V12.Questions.BuildingWebAppsWithElm ->
            Evergreen.V13.Questions.BuildingWebAppsWithElm

        Evergreen.V12.Questions.TheJsonSurvivalKit ->
            Evergreen.V13.Questions.TheJsonSurvivalKit

        Evergreen.V12.Questions.EggheadCourses ->
            Evergreen.V13.Questions.EggheadCourses

        Evergreen.V12.Questions.ProgrammingElmBook ->
            Evergreen.V13.Questions.ProgrammingElmBook

        Evergreen.V12.Questions.GuideElmLang ->
            Evergreen.V13.Questions.GuideElmLang

        Evergreen.V12.Questions.ElmForBeginners ->
            Evergreen.V13.Questions.ElmForBeginners

        Evergreen.V12.Questions.ElmSlack_ ->
            Evergreen.V13.Questions.ElmSlack_

        Evergreen.V12.Questions.FrontendMasters ->
            Evergreen.V13.Questions.FrontendMasters

        Evergreen.V12.Questions.ElmOnline ->
            Evergreen.V13.Questions.ElmOnline


migrateExperienceLevel : Evergreen.V12.Questions.ExperienceLevel -> Evergreen.V13.Questions.ExperienceLevel
migrateExperienceLevel old =
    case old of
        Evergreen.V12.Questions.Beginner ->
            Evergreen.V13.Questions.Beginner

        Evergreen.V12.Questions.Intermediate ->
            Evergreen.V13.Questions.Intermediate

        Evergreen.V12.Questions.Professional ->
            Evergreen.V13.Questions.Professional

        Evergreen.V12.Questions.Expert ->
            Evergreen.V13.Questions.Expert


migrateFrameworks : Evergreen.V12.Questions.Frameworks -> Evergreen.V13.Questions.Frameworks
migrateFrameworks old =
    case old of
        Evergreen.V12.Questions.Lamdera_ ->
            Evergreen.V13.Questions.Lamdera_

        Evergreen.V12.Questions.ElmSpa ->
            Evergreen.V13.Questions.ElmSpa

        Evergreen.V12.Questions.ElmPages ->
            Evergreen.V13.Questions.ElmPages

        Evergreen.V12.Questions.ElmPlayground ->
            Evergreen.V13.Questions.ElmPlayground


migrateHowLargeIsTheCompany : Evergreen.V12.Questions.HowLargeIsTheCompany -> Evergreen.V13.Questions.HowLargeIsTheCompany
migrateHowLargeIsTheCompany old =
    case old of
        Evergreen.V12.Questions.Size1To10Employees ->
            Evergreen.V13.Questions.Size1To10Employees

        Evergreen.V12.Questions.Size11To50Employees ->
            Evergreen.V13.Questions.Size11To50Employees

        Evergreen.V12.Questions.Size50To100Employees ->
            Evergreen.V13.Questions.Size50To100Employees

        Evergreen.V12.Questions.Size100OrMore ->
            Evergreen.V13.Questions.Size100OrMore


migrateHowLong : Evergreen.V12.Questions.HowLong -> Evergreen.V13.Questions.HowLong
migrateHowLong old =
    case old of
        Evergreen.V12.Questions.Under3Months ->
            Evergreen.V13.Questions.Under3Months

        Evergreen.V12.Questions.Between3MonthsAndAYear ->
            Evergreen.V13.Questions.Between3MonthsAndAYear

        Evergreen.V12.Questions.OneYear ->
            Evergreen.V13.Questions.OneYear

        Evergreen.V12.Questions.TwoYears ->
            Evergreen.V13.Questions.TwoYears

        Evergreen.V12.Questions.ThreeYears ->
            Evergreen.V13.Questions.ThreeYears

        Evergreen.V12.Questions.FourYears ->
            Evergreen.V13.Questions.FourYears

        Evergreen.V12.Questions.FiveYears ->
            Evergreen.V13.Questions.FiveYears

        Evergreen.V12.Questions.SixYears ->
            Evergreen.V13.Questions.SixYears

        Evergreen.V12.Questions.SevenYears ->
            Evergreen.V13.Questions.SevenYears

        Evergreen.V12.Questions.EightYears ->
            Evergreen.V13.Questions.EightYears

        Evergreen.V12.Questions.NineYears ->
            Evergreen.V13.Questions.NineYears


migrateNewsAndDiscussions : Evergreen.V12.Questions.NewsAndDiscussions -> Evergreen.V13.Questions.NewsAndDiscussions
migrateNewsAndDiscussions old =
    case old of
        Evergreen.V12.Questions.ElmDiscourse ->
            Evergreen.V13.Questions.ElmDiscourse

        Evergreen.V12.Questions.ElmSlack ->
            Evergreen.V13.Questions.ElmSlack

        Evergreen.V12.Questions.ElmSubreddit ->
            Evergreen.V13.Questions.ElmSubreddit

        Evergreen.V12.Questions.Twitter ->
            Evergreen.V13.Questions.Twitter

        Evergreen.V12.Questions.ElmRadio ->
            Evergreen.V13.Questions.ElmRadio

        Evergreen.V12.Questions.BlogPosts ->
            Evergreen.V13.Questions.BlogPosts

        Evergreen.V12.Questions.Facebook ->
            Evergreen.V13.Questions.Facebook

        Evergreen.V12.Questions.DevTo ->
            Evergreen.V13.Questions.DevTo

        Evergreen.V12.Questions.Meetups ->
            Evergreen.V13.Questions.Meetups

        Evergreen.V12.Questions.ElmWeekly ->
            Evergreen.V13.Questions.ElmWeekly

        Evergreen.V12.Questions.ElmNews ->
            Evergreen.V13.Questions.ElmNews

        Evergreen.V12.Questions.ElmCraft ->
            Evergreen.V13.Questions.ElmCraft


migrateOtherLanguages : Evergreen.V12.Questions.OtherLanguages -> Evergreen.V13.Questions.OtherLanguages
migrateOtherLanguages old =
    case old of
        Evergreen.V12.Questions.JavaScript ->
            Evergreen.V13.Questions.JavaScript

        Evergreen.V12.Questions.TypeScript ->
            Evergreen.V13.Questions.TypeScript

        Evergreen.V12.Questions.Go ->
            Evergreen.V13.Questions.Go

        Evergreen.V12.Questions.Haskell ->
            Evergreen.V13.Questions.Haskell

        Evergreen.V12.Questions.CSharp ->
            Evergreen.V13.Questions.CSharp

        Evergreen.V12.Questions.C ->
            Evergreen.V13.Questions.C

        Evergreen.V12.Questions.CPlusPlus ->
            Evergreen.V13.Questions.CPlusPlus

        Evergreen.V12.Questions.OCaml ->
            Evergreen.V13.Questions.OCaml

        Evergreen.V12.Questions.Python ->
            Evergreen.V13.Questions.Python

        Evergreen.V12.Questions.Swift ->
            Evergreen.V13.Questions.Swift

        Evergreen.V12.Questions.PHP ->
            Evergreen.V13.Questions.PHP

        Evergreen.V12.Questions.Java ->
            Evergreen.V13.Questions.Java

        Evergreen.V12.Questions.Ruby ->
            Evergreen.V13.Questions.Ruby

        Evergreen.V12.Questions.Elixir ->
            Evergreen.V13.Questions.Elixir

        Evergreen.V12.Questions.Clojure ->
            Evergreen.V13.Questions.Clojure

        Evergreen.V12.Questions.Rust ->
            Evergreen.V13.Questions.Rust

        Evergreen.V12.Questions.FSharp ->
            Evergreen.V13.Questions.FSharp


migrateStylingTools : Evergreen.V12.Questions.StylingTools -> Evergreen.V13.Questions.StylingTools
migrateStylingTools old =
    case old of
        Evergreen.V12.Questions.SassOrScss ->
            Evergreen.V13.Questions.SassOrScss

        Evergreen.V12.Questions.ElmCss ->
            Evergreen.V13.Questions.ElmCss

        Evergreen.V12.Questions.PlainCss ->
            Evergreen.V13.Questions.PlainCss

        Evergreen.V12.Questions.ElmUi ->
            Evergreen.V13.Questions.ElmUi

        Evergreen.V12.Questions.Tailwind ->
            Evergreen.V13.Questions.Tailwind

        Evergreen.V12.Questions.ElmTailwindModules ->
            Evergreen.V13.Questions.ElmTailwindModules

        Evergreen.V12.Questions.Bootstrap ->
            Evergreen.V13.Questions.Bootstrap


migrateTestTools : Evergreen.V12.Questions.TestTools -> Evergreen.V13.Questions.TestTools
migrateTestTools old =
    case old of
        Evergreen.V12.Questions.BrowserAcceptanceTests ->
            Evergreen.V13.Questions.BrowserAcceptanceTests

        Evergreen.V12.Questions.ElmBenchmark ->
            Evergreen.V13.Questions.ElmBenchmark

        Evergreen.V12.Questions.ElmTest ->
            Evergreen.V13.Questions.ElmTest

        Evergreen.V12.Questions.ElmProgramTest ->
            Evergreen.V13.Questions.ElmProgramTest

        Evergreen.V12.Questions.VisualRegressionTests ->
            Evergreen.V13.Questions.VisualRegressionTests


migrateTestsWrittenFor : Evergreen.V12.Questions.TestsWrittenFor -> Evergreen.V13.Questions.TestsWrittenFor
migrateTestsWrittenFor old =
    case old of
        Evergreen.V12.Questions.ComplicatedFunctions ->
            Evergreen.V13.Questions.ComplicatedFunctions

        Evergreen.V12.Questions.FunctionsThatReturnCmds ->
            Evergreen.V13.Questions.FunctionsThatReturnCmds

        Evergreen.V12.Questions.AllPublicFunctions ->
            Evergreen.V13.Questions.AllPublicFunctions

        Evergreen.V12.Questions.HtmlFunctions ->
            Evergreen.V13.Questions.HtmlFunctions

        Evergreen.V12.Questions.JsonDecodersAndEncoders ->
            Evergreen.V13.Questions.JsonDecodersAndEncoders

        Evergreen.V12.Questions.MostPublicFunctions ->
            Evergreen.V13.Questions.MostPublicFunctions


migrateWhatElmVersion : Evergreen.V12.Questions.WhatElmVersion -> Evergreen.V13.Questions.WhatElmVersion
migrateWhatElmVersion old =
    case old of
        Evergreen.V12.Questions.Version0_19 ->
            Evergreen.V13.Questions.Version0_19

        Evergreen.V12.Questions.Version0_18 ->
            Evergreen.V13.Questions.Version0_18

        Evergreen.V12.Questions.Version0_17 ->
            Evergreen.V13.Questions.Version0_17

        Evergreen.V12.Questions.Version0_16 ->
            Evergreen.V13.Questions.Version0_16


migrateWhatLanguageDoYouUseForTheBackend : Evergreen.V12.Questions.WhatLanguageDoYouUseForTheBackend -> Evergreen.V13.Questions.WhatLanguageDoYouUseForTheBackend
migrateWhatLanguageDoYouUseForTheBackend old =
    case old of
        Evergreen.V12.Questions.JavaScript_ ->
            Evergreen.V13.Questions.JavaScript_

        Evergreen.V12.Questions.TypeScript_ ->
            Evergreen.V13.Questions.TypeScript_

        Evergreen.V12.Questions.Go_ ->
            Evergreen.V13.Questions.Go_

        Evergreen.V12.Questions.Haskell_ ->
            Evergreen.V13.Questions.Haskell_

        Evergreen.V12.Questions.CSharp_ ->
            Evergreen.V13.Questions.CSharp_

        Evergreen.V12.Questions.OCaml_ ->
            Evergreen.V13.Questions.OCaml_

        Evergreen.V12.Questions.Python_ ->
            Evergreen.V13.Questions.Python_

        Evergreen.V12.Questions.PHP_ ->
            Evergreen.V13.Questions.PHP_

        Evergreen.V12.Questions.Java_ ->
            Evergreen.V13.Questions.Java_

        Evergreen.V12.Questions.Ruby_ ->
            Evergreen.V13.Questions.Ruby_

        Evergreen.V12.Questions.Elixir_ ->
            Evergreen.V13.Questions.Elixir_

        Evergreen.V12.Questions.Clojure_ ->
            Evergreen.V13.Questions.Clojure_

        Evergreen.V12.Questions.Rust_ ->
            Evergreen.V13.Questions.Rust_

        Evergreen.V12.Questions.FSharp_ ->
            Evergreen.V13.Questions.FSharp_

        Evergreen.V12.Questions.AlsoElm ->
            Evergreen.V13.Questions.AlsoElm

        Evergreen.V12.Questions.NotApplicable ->
            Evergreen.V13.Questions.NotApplicable


migrateWhereDoYouUseElm : Evergreen.V12.Questions.WhereDoYouUseElm -> Evergreen.V13.Questions.WhereDoYouUseElm
migrateWhereDoYouUseElm old =
    case old of
        Evergreen.V12.Questions.Education ->
            Evergreen.V13.Questions.Education

        Evergreen.V12.Questions.Gaming ->
            Evergreen.V13.Questions.Gaming

        Evergreen.V12.Questions.ECommerce ->
            Evergreen.V13.Questions.ECommerce

        Evergreen.V12.Questions.Audio ->
            Evergreen.V13.Questions.Audio

        Evergreen.V12.Questions.Finance ->
            Evergreen.V13.Questions.Finance

        Evergreen.V12.Questions.Health ->
            Evergreen.V13.Questions.Health

        Evergreen.V12.Questions.Productivity ->
            Evergreen.V13.Questions.Productivity

        Evergreen.V12.Questions.Communication ->
            Evergreen.V13.Questions.Communication

        Evergreen.V12.Questions.DataVisualization ->
            Evergreen.V13.Questions.DataVisualization

        Evergreen.V12.Questions.Transportation ->
            Evergreen.V13.Questions.Transportation


migrateWhichElmReviewRulesDoYouUse : Evergreen.V12.Questions.WhichElmReviewRulesDoYouUse -> Evergreen.V13.Questions.WhichElmReviewRulesDoYouUse
migrateWhichElmReviewRulesDoYouUse old =
    case old of
        Evergreen.V12.Questions.ElmReviewUnused ->
            Evergreen.V13.Questions.ElmReviewUnused

        Evergreen.V12.Questions.ElmReviewSimplify ->
            Evergreen.V13.Questions.ElmReviewSimplify

        Evergreen.V12.Questions.ElmReviewLicense ->
            Evergreen.V13.Questions.ElmReviewLicense

        Evergreen.V12.Questions.ElmReviewDebug ->
            Evergreen.V13.Questions.ElmReviewDebug

        Evergreen.V12.Questions.ElmReviewCommon ->
            Evergreen.V13.Questions.ElmReviewCommon

        Evergreen.V12.Questions.ElmReviewCognitiveComplexity ->
            Evergreen.V13.Questions.ElmReviewCognitiveComplexity


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
    }


migrateFrontendModel : Old.FrontendModel -> New.FrontendModel
migrateFrontendModel old =
    case old of
        Old.Loading ->
            New.Loading Nothing

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
