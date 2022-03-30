module Evergreen.Migrate.V12 exposing (..)

import AssocList as Dict
import AssocSet as Set
import Evergreen.V10.Questions
import Evergreen.V10.Types as Old
import Evergreen.V12.Questions
import Evergreen.V12.Types as New
import Lamdera.Migrations exposing (..)


migrateAge : Evergreen.V10.Questions.Age -> Evergreen.V12.Questions.Age
migrateAge old =
    case old of
        Evergreen.V10.Questions.Under10 ->
            Evergreen.V12.Questions.Under10

        Evergreen.V10.Questions.Age10To19 ->
            Evergreen.V12.Questions.Age10To19

        Evergreen.V10.Questions.Age20To29 ->
            Evergreen.V12.Questions.Age20To29

        Evergreen.V10.Questions.Age30To39 ->
            Evergreen.V12.Questions.Age30To39

        Evergreen.V10.Questions.Age40To49 ->
            Evergreen.V12.Questions.Age40To49

        Evergreen.V10.Questions.Age50To59 ->
            Evergreen.V12.Questions.Age50To59

        Evergreen.V10.Questions.Over60 ->
            Evergreen.V12.Questions.Over60


migrateBuildTools : Evergreen.V10.Questions.BuildTools -> Maybe Evergreen.V12.Questions.BuildTools
migrateBuildTools old =
    case old of
        Evergreen.V10.Questions.ShellScripts ->
            Just Evergreen.V12.Questions.ShellScripts

        Evergreen.V10.Questions.ElmLive ->
            Just Evergreen.V12.Questions.ElmLive

        Evergreen.V10.Questions.CreateElmApp ->
            Just Evergreen.V12.Questions.CreateElmApp

        Evergreen.V10.Questions.Webpack ->
            Just Evergreen.V12.Questions.Webpack

        Evergreen.V10.Questions.Brunch ->
            Just Evergreen.V12.Questions.Brunch

        Evergreen.V10.Questions.ElmMakeStandalone ->
            Just Evergreen.V12.Questions.ElmMakeStandalone

        Evergreen.V10.Questions.Gulp ->
            Just Evergreen.V12.Questions.Gulp

        Evergreen.V10.Questions.Make ->
            Just Evergreen.V12.Questions.Make

        Evergreen.V10.Questions.ElmReactor ->
            Just Evergreen.V12.Questions.ElmReactor

        Evergreen.V10.Questions.Parcel ->
            Just Evergreen.V12.Questions.Parcel

        Evergreen.V10.Questions.Vite ->
            Just Evergreen.V12.Questions.Vite


migrateDoYouUseElm : Evergreen.V10.Questions.DoYouUseElm -> Evergreen.V12.Questions.DoYouUseElm
migrateDoYouUseElm old =
    case old of
        Evergreen.V10.Questions.YesAtWork ->
            Evergreen.V12.Questions.YesAtWork

        Evergreen.V10.Questions.YesInSideProjects ->
            Evergreen.V12.Questions.YesInSideProjects

        Evergreen.V10.Questions.YesAsAStudent ->
            Evergreen.V12.Questions.YesAsAStudent

        Evergreen.V10.Questions.IUsedToButIDontAnymore ->
            Evergreen.V12.Questions.IUsedToButIDontAnymore

        Evergreen.V10.Questions.NoButImCuriousAboutIt ->
            Evergreen.V12.Questions.NoButImCuriousAboutIt

        Evergreen.V10.Questions.NoAndIDontPlanTo ->
            Evergreen.V12.Questions.NoAndIDontPlanTo


migrateDoYouUseElmAtWork : Evergreen.V10.Questions.DoYouUseElmAtWork -> Evergreen.V12.Questions.DoYouUseElmAtWork
migrateDoYouUseElmAtWork old =
    case old of
        Evergreen.V10.Questions.NotInterestedInElmAtWork ->
            Evergreen.V12.Questions.NotInterestedInElmAtWork

        Evergreen.V10.Questions.WouldLikeToUseElmAtWork ->
            Evergreen.V12.Questions.WouldLikeToUseElmAtWork

        Evergreen.V10.Questions.HaveTriedElmInAWorkProject ->
            Evergreen.V12.Questions.HaveTriedElmInAWorkProject

        Evergreen.V10.Questions.MyTeamMostlyWritesNewCodeInElm ->
            Evergreen.V12.Questions.MyTeamMostlyWritesNewCodeInElm

        Evergreen.V10.Questions.NotEmployed ->
            Evergreen.V12.Questions.NotEmployed


migrateDoYouUseElmFormat : Evergreen.V10.Questions.DoYouUseElmFormat -> Evergreen.V12.Questions.DoYouUseElmFormat
migrateDoYouUseElmFormat old =
    case old of
        Evergreen.V10.Questions.PreferElmFormat ->
            Evergreen.V12.Questions.PreferElmFormat

        Evergreen.V10.Questions.TriedButDontUseElmFormat ->
            Evergreen.V12.Questions.TriedButDontUseElmFormat

        Evergreen.V10.Questions.HeardButDontUseElmFormat ->
            Evergreen.V12.Questions.HeardButDontUseElmFormat

        Evergreen.V10.Questions.HaveNotHeardOfElmFormat ->
            Evergreen.V12.Questions.HaveNotHeardOfElmFormat


migrateDoYouUseElmReview : Evergreen.V10.Questions.DoYouUseElmReview -> Evergreen.V12.Questions.DoYouUseElmReview
migrateDoYouUseElmReview old =
    case old of
        Evergreen.V10.Questions.NeverHeardOfElmReview ->
            Evergreen.V12.Questions.NeverHeardOfElmReview

        Evergreen.V10.Questions.HeardOfItButNeverTriedElmReview ->
            Evergreen.V12.Questions.HeardOfItButNeverTriedElmReview

        Evergreen.V10.Questions.IveTriedElmReview ->
            Evergreen.V12.Questions.IveTriedElmReview

        Evergreen.V10.Questions.IUseElmReviewRegularly ->
            Evergreen.V12.Questions.IUseElmReviewRegularly


migrateEditor : Evergreen.V10.Questions.Editor -> Evergreen.V12.Questions.Editor
migrateEditor old =
    case old of
        Evergreen.V10.Questions.SublimeText ->
            Evergreen.V12.Questions.SublimeText

        Evergreen.V10.Questions.Vim ->
            Evergreen.V12.Questions.Vim

        Evergreen.V10.Questions.Atom ->
            Evergreen.V12.Questions.Atom

        Evergreen.V10.Questions.Emacs ->
            Evergreen.V12.Questions.Emacs

        Evergreen.V10.Questions.VSCode ->
            Evergreen.V12.Questions.VSCode

        Evergreen.V10.Questions.Intellij ->
            Evergreen.V12.Questions.Intellij


migrateElmResources : Evergreen.V10.Questions.ElmResources -> Evergreen.V12.Questions.ElmResources
migrateElmResources old =
    case old of
        Evergreen.V10.Questions.DailyDrip ->
            Evergreen.V12.Questions.DailyDrip

        Evergreen.V10.Questions.ElmInActionBook ->
            Evergreen.V12.Questions.ElmInActionBook

        Evergreen.V10.Questions.WeeklyBeginnersElmSubreddit ->
            Evergreen.V12.Questions.WeeklyBeginnersElmSubreddit

        Evergreen.V10.Questions.BeginningElmBook ->
            Evergreen.V12.Questions.BeginningElmBook

        Evergreen.V10.Questions.StackOverflow ->
            Evergreen.V12.Questions.StackOverflow

        Evergreen.V10.Questions.BuildingWebAppsWithElm ->
            Evergreen.V12.Questions.BuildingWebAppsWithElm

        Evergreen.V10.Questions.TheJsonSurvivalKit ->
            Evergreen.V12.Questions.TheJsonSurvivalKit

        Evergreen.V10.Questions.EggheadCourses ->
            Evergreen.V12.Questions.EggheadCourses

        Evergreen.V10.Questions.ProgrammingElmBook ->
            Evergreen.V12.Questions.ProgrammingElmBook

        Evergreen.V10.Questions.GuideElmLang ->
            Evergreen.V12.Questions.GuideElmLang

        Evergreen.V10.Questions.ElmForBeginners ->
            Evergreen.V12.Questions.ElmForBeginners

        Evergreen.V10.Questions.ElmSlack_ ->
            Evergreen.V12.Questions.ElmSlack_

        Evergreen.V10.Questions.FrontendMasters ->
            Evergreen.V12.Questions.FrontendMasters

        Evergreen.V10.Questions.ElmOnline ->
            Evergreen.V12.Questions.ElmOnline


migrateExperienceLevel : Evergreen.V10.Questions.ExperienceLevel -> Evergreen.V12.Questions.ExperienceLevel
migrateExperienceLevel old =
    case old of
        Evergreen.V10.Questions.Beginner ->
            Evergreen.V12.Questions.Beginner

        Evergreen.V10.Questions.Intermediate ->
            Evergreen.V12.Questions.Intermediate

        Evergreen.V10.Questions.Professional ->
            Evergreen.V12.Questions.Professional

        Evergreen.V10.Questions.Expert ->
            Evergreen.V12.Questions.Expert


migrateFrameworks : Evergreen.V10.Questions.Frameworks -> Evergreen.V12.Questions.Frameworks
migrateFrameworks old =
    case old of
        Evergreen.V10.Questions.Lamdera_ ->
            Evergreen.V12.Questions.Lamdera_

        Evergreen.V10.Questions.ElmSpa ->
            Evergreen.V12.Questions.ElmSpa

        Evergreen.V10.Questions.ElmPages ->
            Evergreen.V12.Questions.ElmPages

        Evergreen.V10.Questions.ElmPlayground ->
            Evergreen.V12.Questions.ElmPlayground


migrateHowLargeIsTheCompany : Evergreen.V10.Questions.HowLargeIsTheCompany -> Evergreen.V12.Questions.HowLargeIsTheCompany
migrateHowLargeIsTheCompany old =
    case old of
        Evergreen.V10.Questions.Size1To10Employees ->
            Evergreen.V12.Questions.Size1To10Employees

        Evergreen.V10.Questions.Size11To50Employees ->
            Evergreen.V12.Questions.Size11To50Employees

        Evergreen.V10.Questions.Size50To100Employees ->
            Evergreen.V12.Questions.Size50To100Employees

        Evergreen.V10.Questions.Size100OrMore ->
            Evergreen.V12.Questions.Size100OrMore


migrateHowLong : Evergreen.V10.Questions.HowLong -> Evergreen.V12.Questions.HowLong
migrateHowLong old =
    case old of
        Evergreen.V10.Questions.Under3Months ->
            Evergreen.V12.Questions.Under3Months

        Evergreen.V10.Questions.Between3MonthsAndAYear ->
            Evergreen.V12.Questions.Between3MonthsAndAYear

        Evergreen.V10.Questions.OneYear ->
            Evergreen.V12.Questions.OneYear

        Evergreen.V10.Questions.TwoYears ->
            Evergreen.V12.Questions.TwoYears

        Evergreen.V10.Questions.ThreeYears ->
            Evergreen.V12.Questions.ThreeYears

        Evergreen.V10.Questions.FourYears ->
            Evergreen.V12.Questions.FourYears

        Evergreen.V10.Questions.FiveYears ->
            Evergreen.V12.Questions.FiveYears

        Evergreen.V10.Questions.SixYears ->
            Evergreen.V12.Questions.SixYears

        Evergreen.V10.Questions.SevenYears ->
            Evergreen.V12.Questions.SevenYears

        Evergreen.V10.Questions.EightYears ->
            Evergreen.V12.Questions.EightYears

        Evergreen.V10.Questions.NineYears ->
            Evergreen.V12.Questions.NineYears


migrateNewsAndDiscussions : Evergreen.V10.Questions.NewsAndDiscussions -> Evergreen.V12.Questions.NewsAndDiscussions
migrateNewsAndDiscussions old =
    case old of
        Evergreen.V10.Questions.ElmDiscourse ->
            Evergreen.V12.Questions.ElmDiscourse

        Evergreen.V10.Questions.ElmSlack ->
            Evergreen.V12.Questions.ElmSlack

        Evergreen.V10.Questions.ElmSubreddit ->
            Evergreen.V12.Questions.ElmSubreddit

        Evergreen.V10.Questions.Twitter ->
            Evergreen.V12.Questions.Twitter

        Evergreen.V10.Questions.ElmRadio ->
            Evergreen.V12.Questions.ElmRadio

        Evergreen.V10.Questions.BlogPosts ->
            Evergreen.V12.Questions.BlogPosts

        Evergreen.V10.Questions.Facebook ->
            Evergreen.V12.Questions.Facebook

        Evergreen.V10.Questions.DevTo ->
            Evergreen.V12.Questions.DevTo

        Evergreen.V10.Questions.Meetups ->
            Evergreen.V12.Questions.Meetups

        Evergreen.V10.Questions.ElmWeekly ->
            Evergreen.V12.Questions.ElmWeekly

        Evergreen.V10.Questions.ElmNews ->
            Evergreen.V12.Questions.ElmNews

        Evergreen.V10.Questions.ElmCraft ->
            Evergreen.V12.Questions.ElmCraft


migrateOtherLanguages : Evergreen.V10.Questions.OtherLanguages -> Evergreen.V12.Questions.OtherLanguages
migrateOtherLanguages old =
    case old of
        Evergreen.V10.Questions.JavaScript ->
            Evergreen.V12.Questions.JavaScript

        Evergreen.V10.Questions.TypeScript ->
            Evergreen.V12.Questions.TypeScript

        Evergreen.V10.Questions.Go ->
            Evergreen.V12.Questions.Go

        Evergreen.V10.Questions.Haskell ->
            Evergreen.V12.Questions.Haskell

        Evergreen.V10.Questions.CSharp ->
            Evergreen.V12.Questions.CSharp

        Evergreen.V10.Questions.C ->
            Evergreen.V12.Questions.C

        Evergreen.V10.Questions.CPlusPlus ->
            Evergreen.V12.Questions.CPlusPlus

        Evergreen.V10.Questions.OCaml ->
            Evergreen.V12.Questions.OCaml

        Evergreen.V10.Questions.Python ->
            Evergreen.V12.Questions.Python

        Evergreen.V10.Questions.Swift ->
            Evergreen.V12.Questions.Swift

        Evergreen.V10.Questions.PHP ->
            Evergreen.V12.Questions.PHP

        Evergreen.V10.Questions.Java ->
            Evergreen.V12.Questions.Java

        Evergreen.V10.Questions.Ruby ->
            Evergreen.V12.Questions.Ruby

        Evergreen.V10.Questions.Elixir ->
            Evergreen.V12.Questions.Elixir

        Evergreen.V10.Questions.Clojure ->
            Evergreen.V12.Questions.Clojure

        Evergreen.V10.Questions.Rust ->
            Evergreen.V12.Questions.Rust

        Evergreen.V10.Questions.FSharp ->
            Evergreen.V12.Questions.FSharp


migrateStylingTools : Evergreen.V10.Questions.StylingTools -> Evergreen.V12.Questions.StylingTools
migrateStylingTools old =
    case old of
        Evergreen.V10.Questions.SassOrScss ->
            Evergreen.V12.Questions.SassOrScss

        Evergreen.V10.Questions.ElmCss ->
            Evergreen.V12.Questions.ElmCss

        Evergreen.V10.Questions.PlainCss ->
            Evergreen.V12.Questions.PlainCss

        Evergreen.V10.Questions.ElmUi ->
            Evergreen.V12.Questions.ElmUi

        Evergreen.V10.Questions.Tailwind ->
            Evergreen.V12.Questions.Tailwind

        Evergreen.V10.Questions.ElmTailwindModules ->
            Evergreen.V12.Questions.ElmTailwindModules

        Evergreen.V10.Questions.Bootstrap ->
            Evergreen.V12.Questions.Bootstrap


migrateTestTools : Evergreen.V10.Questions.TestTools -> Evergreen.V12.Questions.TestTools
migrateTestTools old =
    case old of
        Evergreen.V10.Questions.BrowserAcceptanceTests ->
            Evergreen.V12.Questions.BrowserAcceptanceTests

        Evergreen.V10.Questions.ElmBenchmark ->
            Evergreen.V12.Questions.ElmBenchmark

        Evergreen.V10.Questions.ElmTest ->
            Evergreen.V12.Questions.ElmTest

        Evergreen.V10.Questions.ElmProgramTest ->
            Evergreen.V12.Questions.ElmProgramTest

        Evergreen.V10.Questions.VisualRegressionTests ->
            Evergreen.V12.Questions.VisualRegressionTests


migrateTestsWrittenFor : Evergreen.V10.Questions.TestsWrittenFor -> Evergreen.V12.Questions.TestsWrittenFor
migrateTestsWrittenFor old =
    case old of
        Evergreen.V10.Questions.ComplicatedFunctions ->
            Evergreen.V12.Questions.ComplicatedFunctions

        Evergreen.V10.Questions.FunctionsThatReturnCmds ->
            Evergreen.V12.Questions.FunctionsThatReturnCmds

        Evergreen.V10.Questions.AllPublicFunctions ->
            Evergreen.V12.Questions.AllPublicFunctions

        Evergreen.V10.Questions.HtmlFunctions ->
            Evergreen.V12.Questions.HtmlFunctions

        Evergreen.V10.Questions.JsonDecodersAndEncoders ->
            Evergreen.V12.Questions.JsonDecodersAndEncoders

        Evergreen.V10.Questions.MostPublicFunctions ->
            Evergreen.V12.Questions.MostPublicFunctions


migrateWhatElmVersion : Evergreen.V10.Questions.WhatElmVersion -> Evergreen.V12.Questions.WhatElmVersion
migrateWhatElmVersion old =
    case old of
        Evergreen.V10.Questions.Version0_19 ->
            Evergreen.V12.Questions.Version0_19

        Evergreen.V10.Questions.Version0_18 ->
            Evergreen.V12.Questions.Version0_18

        Evergreen.V10.Questions.Version0_17 ->
            Evergreen.V12.Questions.Version0_17

        Evergreen.V10.Questions.Version0_16 ->
            Evergreen.V12.Questions.Version0_16


migrateWhatLanguageDoYouUseForTheBackend : Evergreen.V10.Questions.WhatLanguageDoYouUseForTheBackend -> Evergreen.V12.Questions.WhatLanguageDoYouUseForTheBackend
migrateWhatLanguageDoYouUseForTheBackend old =
    case old of
        Evergreen.V10.Questions.JavaScript_ ->
            Evergreen.V12.Questions.JavaScript_

        Evergreen.V10.Questions.TypeScript_ ->
            Evergreen.V12.Questions.TypeScript_

        Evergreen.V10.Questions.Go_ ->
            Evergreen.V12.Questions.Go_

        Evergreen.V10.Questions.Haskell_ ->
            Evergreen.V12.Questions.Haskell_

        Evergreen.V10.Questions.CSharp_ ->
            Evergreen.V12.Questions.CSharp_

        Evergreen.V10.Questions.OCaml_ ->
            Evergreen.V12.Questions.OCaml_

        Evergreen.V10.Questions.Python_ ->
            Evergreen.V12.Questions.Python_

        Evergreen.V10.Questions.PHP_ ->
            Evergreen.V12.Questions.PHP_

        Evergreen.V10.Questions.Java_ ->
            Evergreen.V12.Questions.Java_

        Evergreen.V10.Questions.Ruby_ ->
            Evergreen.V12.Questions.Ruby_

        Evergreen.V10.Questions.Elixir_ ->
            Evergreen.V12.Questions.Elixir_

        Evergreen.V10.Questions.Clojure_ ->
            Evergreen.V12.Questions.Clojure_

        Evergreen.V10.Questions.Rust_ ->
            Evergreen.V12.Questions.Rust_

        Evergreen.V10.Questions.FSharp_ ->
            Evergreen.V12.Questions.FSharp_

        Evergreen.V10.Questions.AlsoElm ->
            Evergreen.V12.Questions.AlsoElm

        Evergreen.V10.Questions.NotApplicable ->
            Evergreen.V12.Questions.NotApplicable


migrateWhereDoYouUseElm : Evergreen.V10.Questions.WhereDoYouUseElm -> Evergreen.V12.Questions.WhereDoYouUseElm
migrateWhereDoYouUseElm old =
    case old of
        Evergreen.V10.Questions.Education ->
            Evergreen.V12.Questions.Education

        Evergreen.V10.Questions.Gaming ->
            Evergreen.V12.Questions.Gaming

        Evergreen.V10.Questions.ECommerce ->
            Evergreen.V12.Questions.ECommerce

        Evergreen.V10.Questions.Audio ->
            Evergreen.V12.Questions.Audio

        Evergreen.V10.Questions.Finance ->
            Evergreen.V12.Questions.Finance

        Evergreen.V10.Questions.Health ->
            Evergreen.V12.Questions.Health

        Evergreen.V10.Questions.Productivity ->
            Evergreen.V12.Questions.Productivity

        Evergreen.V10.Questions.Communication ->
            Evergreen.V12.Questions.Communication

        Evergreen.V10.Questions.DataVisualization ->
            Evergreen.V12.Questions.DataVisualization

        Evergreen.V10.Questions.Transportation ->
            Evergreen.V12.Questions.Transportation


migrateWhichElmReviewRulesDoYouUse : Evergreen.V10.Questions.WhichElmReviewRulesDoYouUse -> Evergreen.V12.Questions.WhichElmReviewRulesDoYouUse
migrateWhichElmReviewRulesDoYouUse old =
    case old of
        Evergreen.V10.Questions.ElmReviewUnused ->
            Evergreen.V12.Questions.ElmReviewUnused

        Evergreen.V10.Questions.ElmReviewSimplify ->
            Evergreen.V12.Questions.ElmReviewSimplify

        Evergreen.V10.Questions.ElmReviewLicense ->
            Evergreen.V12.Questions.ElmReviewLicense

        Evergreen.V10.Questions.ElmReviewDebug ->
            Evergreen.V12.Questions.ElmReviewDebug

        Evergreen.V10.Questions.ElmReviewCommon ->
            Evergreen.V12.Questions.ElmReviewCommon

        Evergreen.V10.Questions.ElmReviewCognitiveComplexity ->
            Evergreen.V12.Questions.ElmReviewCognitiveComplexity


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
