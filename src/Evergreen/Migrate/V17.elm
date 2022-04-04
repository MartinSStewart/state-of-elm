module Evergreen.Migrate.V17 exposing (..)

import AssocList as Dict
import AssocSet as Set
import Evergreen.V13.Questions
import Evergreen.V13.Types as Old
import Evergreen.V17.Questions
import Evergreen.V17.Types as New
import Lamdera.Migrations exposing (..)


migrateAge : Evergreen.V13.Questions.Age -> Evergreen.V17.Questions.Age
migrateAge old =
    case old of
        Evergreen.V13.Questions.Under10 ->
            Evergreen.V17.Questions.Under10

        Evergreen.V13.Questions.Age10To19 ->
            Evergreen.V17.Questions.Age10To19

        Evergreen.V13.Questions.Age20To29 ->
            Evergreen.V17.Questions.Age20To29

        Evergreen.V13.Questions.Age30To39 ->
            Evergreen.V17.Questions.Age30To39

        Evergreen.V13.Questions.Age40To49 ->
            Evergreen.V17.Questions.Age40To49

        Evergreen.V13.Questions.Age50To59 ->
            Evergreen.V17.Questions.Age50To59

        Evergreen.V13.Questions.Over60 ->
            Evergreen.V17.Questions.Over60


migrateBuildTools : Evergreen.V13.Questions.BuildTools -> Maybe Evergreen.V17.Questions.BuildTools
migrateBuildTools old =
    case old of
        Evergreen.V13.Questions.ShellScripts ->
            Just Evergreen.V17.Questions.ShellScripts

        Evergreen.V13.Questions.ElmLive ->
            Just Evergreen.V17.Questions.ElmLive

        Evergreen.V13.Questions.CreateElmApp ->
            Just Evergreen.V17.Questions.CreateElmApp

        Evergreen.V13.Questions.Webpack ->
            Just Evergreen.V17.Questions.Webpack

        Evergreen.V13.Questions.Brunch ->
            Just Evergreen.V17.Questions.Brunch

        Evergreen.V13.Questions.ElmMakeStandalone ->
            Just Evergreen.V17.Questions.ElmMakeStandalone

        Evergreen.V13.Questions.Gulp ->
            Just Evergreen.V17.Questions.Gulp

        Evergreen.V13.Questions.Make ->
            Just Evergreen.V17.Questions.Make

        Evergreen.V13.Questions.ElmReactor ->
            Just Evergreen.V17.Questions.ElmReactor

        Evergreen.V13.Questions.Parcel ->
            Just Evergreen.V17.Questions.Parcel

        Evergreen.V13.Questions.Vite ->
            Just Evergreen.V17.Questions.Vite


migrateDoYouUseElm : Evergreen.V13.Questions.DoYouUseElm -> Evergreen.V17.Questions.DoYouUseElm
migrateDoYouUseElm old =
    case old of
        Evergreen.V13.Questions.YesAtWork ->
            Evergreen.V17.Questions.YesAtWork

        Evergreen.V13.Questions.YesInSideProjects ->
            Evergreen.V17.Questions.YesInSideProjects

        Evergreen.V13.Questions.YesAsAStudent ->
            Evergreen.V17.Questions.YesAsAStudent

        Evergreen.V13.Questions.IUsedToButIDontAnymore ->
            Evergreen.V17.Questions.IUsedToButIDontAnymore

        Evergreen.V13.Questions.NoButImCuriousAboutIt ->
            Evergreen.V17.Questions.NoButImCuriousAboutIt

        Evergreen.V13.Questions.NoAndIDontPlanTo ->
            Evergreen.V17.Questions.NoAndIDontPlanTo


migrateDoYouUseElmAtWork : Evergreen.V13.Questions.DoYouUseElmAtWork -> Evergreen.V17.Questions.DoYouUseElmAtWork
migrateDoYouUseElmAtWork old =
    case old of
        Evergreen.V13.Questions.NotInterestedInElmAtWork ->
            Evergreen.V17.Questions.NotInterestedInElmAtWork

        Evergreen.V13.Questions.WouldLikeToUseElmAtWork ->
            Evergreen.V17.Questions.WouldLikeToUseElmAtWork

        Evergreen.V13.Questions.HaveTriedElmInAWorkProject ->
            Evergreen.V17.Questions.HaveTriedElmInAWorkProject

        Evergreen.V13.Questions.MyTeamMostlyWritesNewCodeInElm ->
            Evergreen.V17.Questions.MyTeamMostlyWritesNewCodeInElm

        Evergreen.V13.Questions.NotEmployed ->
            Evergreen.V17.Questions.NotEmployed


migrateDoYouUseElmFormat : Evergreen.V13.Questions.DoYouUseElmFormat -> Evergreen.V17.Questions.DoYouUseElmFormat
migrateDoYouUseElmFormat old =
    case old of
        Evergreen.V13.Questions.PreferElmFormat ->
            Evergreen.V17.Questions.PreferElmFormat

        Evergreen.V13.Questions.TriedButDontUseElmFormat ->
            Evergreen.V17.Questions.TriedButDontUseElmFormat

        Evergreen.V13.Questions.HeardButDontUseElmFormat ->
            Evergreen.V17.Questions.HeardButDontUseElmFormat

        Evergreen.V13.Questions.HaveNotHeardOfElmFormat ->
            Evergreen.V17.Questions.HaveNotHeardOfElmFormat


migrateDoYouUseElmReview : Evergreen.V13.Questions.DoYouUseElmReview -> Evergreen.V17.Questions.DoYouUseElmReview
migrateDoYouUseElmReview old =
    case old of
        Evergreen.V13.Questions.NeverHeardOfElmReview ->
            Evergreen.V17.Questions.NeverHeardOfElmReview

        Evergreen.V13.Questions.HeardOfItButNeverTriedElmReview ->
            Evergreen.V17.Questions.HeardOfItButNeverTriedElmReview

        Evergreen.V13.Questions.IveTriedElmReview ->
            Evergreen.V17.Questions.IveTriedElmReview

        Evergreen.V13.Questions.IUseElmReviewRegularly ->
            Evergreen.V17.Questions.IUseElmReviewRegularly


migrateEditor : Evergreen.V13.Questions.Editor -> Evergreen.V17.Questions.Editor
migrateEditor old =
    case old of
        Evergreen.V13.Questions.SublimeText ->
            Evergreen.V17.Questions.SublimeText

        Evergreen.V13.Questions.Vim ->
            Evergreen.V17.Questions.Vim

        Evergreen.V13.Questions.Atom ->
            Evergreen.V17.Questions.Atom

        Evergreen.V13.Questions.Emacs ->
            Evergreen.V17.Questions.Emacs

        Evergreen.V13.Questions.VSCode ->
            Evergreen.V17.Questions.VSCode

        Evergreen.V13.Questions.Intellij ->
            Evergreen.V17.Questions.Intellij


migrateElmResources : Evergreen.V13.Questions.ElmResources -> Evergreen.V17.Questions.ElmResources
migrateElmResources old =
    case old of
        Evergreen.V13.Questions.DailyDrip ->
            Evergreen.V17.Questions.DailyDrip

        Evergreen.V13.Questions.ElmInActionBook ->
            Evergreen.V17.Questions.ElmInActionBook

        Evergreen.V13.Questions.WeeklyBeginnersElmSubreddit ->
            Evergreen.V17.Questions.WeeklyBeginnersElmSubreddit

        Evergreen.V13.Questions.BeginningElmBook ->
            Evergreen.V17.Questions.BeginningElmBook

        Evergreen.V13.Questions.StackOverflow ->
            Evergreen.V17.Questions.StackOverflow

        Evergreen.V13.Questions.BuildingWebAppsWithElm ->
            Evergreen.V17.Questions.BuildingWebAppsWithElm

        Evergreen.V13.Questions.TheJsonSurvivalKit ->
            Evergreen.V17.Questions.TheJsonSurvivalKit

        Evergreen.V13.Questions.EggheadCourses ->
            Evergreen.V17.Questions.EggheadCourses

        Evergreen.V13.Questions.ProgrammingElmBook ->
            Evergreen.V17.Questions.ProgrammingElmBook

        Evergreen.V13.Questions.GuideElmLang ->
            Evergreen.V17.Questions.GuideElmLang

        Evergreen.V13.Questions.ElmForBeginners ->
            Evergreen.V17.Questions.ElmForBeginners

        Evergreen.V13.Questions.ElmSlack_ ->
            Evergreen.V17.Questions.ElmSlack_

        Evergreen.V13.Questions.FrontendMasters ->
            Evergreen.V17.Questions.FrontendMasters

        Evergreen.V13.Questions.ElmOnline ->
            Evergreen.V17.Questions.ElmOnline


migrateExperienceLevel : Evergreen.V13.Questions.ExperienceLevel -> Evergreen.V17.Questions.ExperienceLevel
migrateExperienceLevel old =
    case old of
        Evergreen.V13.Questions.Beginner ->
            Evergreen.V17.Questions.Beginner

        Evergreen.V13.Questions.Intermediate ->
            Evergreen.V17.Questions.Intermediate

        Evergreen.V13.Questions.Professional ->
            Evergreen.V17.Questions.Professional

        Evergreen.V13.Questions.Expert ->
            Evergreen.V17.Questions.Expert


migrateFrameworks : Evergreen.V13.Questions.Frameworks -> Evergreen.V17.Questions.Frameworks
migrateFrameworks old =
    case old of
        Evergreen.V13.Questions.Lamdera_ ->
            Evergreen.V17.Questions.Lamdera_

        Evergreen.V13.Questions.ElmSpa ->
            Evergreen.V17.Questions.ElmSpa

        Evergreen.V13.Questions.ElmPages ->
            Evergreen.V17.Questions.ElmPages

        Evergreen.V13.Questions.ElmPlayground ->
            Evergreen.V17.Questions.ElmPlayground


migrateHowLargeIsTheCompany : Evergreen.V13.Questions.HowLargeIsTheCompany -> Evergreen.V17.Questions.HowLargeIsTheCompany
migrateHowLargeIsTheCompany old =
    case old of
        Evergreen.V13.Questions.Size1To10Employees ->
            Evergreen.V17.Questions.Size1To10Employees

        Evergreen.V13.Questions.Size11To50Employees ->
            Evergreen.V17.Questions.Size11To50Employees

        Evergreen.V13.Questions.Size50To100Employees ->
            Evergreen.V17.Questions.Size50To100Employees

        Evergreen.V13.Questions.Size100OrMore ->
            Evergreen.V17.Questions.Size100OrMore


migrateHowLong : Evergreen.V13.Questions.HowLong -> Evergreen.V17.Questions.HowLong
migrateHowLong old =
    case old of
        Evergreen.V13.Questions.Under3Months ->
            Evergreen.V17.Questions.Under3Months

        Evergreen.V13.Questions.Between3MonthsAndAYear ->
            Evergreen.V17.Questions.Between3MonthsAndAYear

        Evergreen.V13.Questions.OneYear ->
            Evergreen.V17.Questions.OneYear

        Evergreen.V13.Questions.TwoYears ->
            Evergreen.V17.Questions.TwoYears

        Evergreen.V13.Questions.ThreeYears ->
            Evergreen.V17.Questions.ThreeYears

        Evergreen.V13.Questions.FourYears ->
            Evergreen.V17.Questions.FourYears

        Evergreen.V13.Questions.FiveYears ->
            Evergreen.V17.Questions.FiveYears

        Evergreen.V13.Questions.SixYears ->
            Evergreen.V17.Questions.SixYears

        Evergreen.V13.Questions.SevenYears ->
            Evergreen.V17.Questions.SevenYears

        Evergreen.V13.Questions.EightYears ->
            Evergreen.V17.Questions.EightYears

        Evergreen.V13.Questions.NineYears ->
            Evergreen.V17.Questions.NineYears


migrateNewsAndDiscussions : Evergreen.V13.Questions.NewsAndDiscussions -> Evergreen.V17.Questions.NewsAndDiscussions
migrateNewsAndDiscussions old =
    case old of
        Evergreen.V13.Questions.ElmDiscourse ->
            Evergreen.V17.Questions.ElmDiscourse

        Evergreen.V13.Questions.ElmSlack ->
            Evergreen.V17.Questions.ElmSlack

        Evergreen.V13.Questions.ElmSubreddit ->
            Evergreen.V17.Questions.ElmSubreddit

        Evergreen.V13.Questions.Twitter ->
            Evergreen.V17.Questions.Twitter

        Evergreen.V13.Questions.ElmRadio ->
            Evergreen.V17.Questions.ElmRadio

        Evergreen.V13.Questions.BlogPosts ->
            Evergreen.V17.Questions.BlogPosts

        Evergreen.V13.Questions.Facebook ->
            Evergreen.V17.Questions.Facebook

        Evergreen.V13.Questions.DevTo ->
            Evergreen.V17.Questions.DevTo

        Evergreen.V13.Questions.Meetups ->
            Evergreen.V17.Questions.Meetups

        Evergreen.V13.Questions.ElmWeekly ->
            Evergreen.V17.Questions.ElmWeekly

        Evergreen.V13.Questions.ElmNews ->
            Evergreen.V17.Questions.ElmNews

        Evergreen.V13.Questions.ElmCraft ->
            Evergreen.V17.Questions.ElmCraft


migrateOtherLanguages : Evergreen.V13.Questions.OtherLanguages -> Evergreen.V17.Questions.OtherLanguages
migrateOtherLanguages old =
    case old of
        Evergreen.V13.Questions.JavaScript ->
            Evergreen.V17.Questions.JavaScript

        Evergreen.V13.Questions.TypeScript ->
            Evergreen.V17.Questions.TypeScript

        Evergreen.V13.Questions.Go ->
            Evergreen.V17.Questions.Go

        Evergreen.V13.Questions.Haskell ->
            Evergreen.V17.Questions.Haskell

        Evergreen.V13.Questions.CSharp ->
            Evergreen.V17.Questions.CSharp

        Evergreen.V13.Questions.C ->
            Evergreen.V17.Questions.C

        Evergreen.V13.Questions.CPlusPlus ->
            Evergreen.V17.Questions.CPlusPlus

        Evergreen.V13.Questions.OCaml ->
            Evergreen.V17.Questions.OCaml

        Evergreen.V13.Questions.Python ->
            Evergreen.V17.Questions.Python

        Evergreen.V13.Questions.Swift ->
            Evergreen.V17.Questions.Swift

        Evergreen.V13.Questions.PHP ->
            Evergreen.V17.Questions.PHP

        Evergreen.V13.Questions.Java ->
            Evergreen.V17.Questions.Java

        Evergreen.V13.Questions.Ruby ->
            Evergreen.V17.Questions.Ruby

        Evergreen.V13.Questions.Elixir ->
            Evergreen.V17.Questions.Elixir

        Evergreen.V13.Questions.Clojure ->
            Evergreen.V17.Questions.Clojure

        Evergreen.V13.Questions.Rust ->
            Evergreen.V17.Questions.Rust

        Evergreen.V13.Questions.FSharp ->
            Evergreen.V17.Questions.FSharp


migrateStylingTools : Evergreen.V13.Questions.StylingTools -> Evergreen.V17.Questions.StylingTools
migrateStylingTools old =
    case old of
        Evergreen.V13.Questions.SassOrScss ->
            Evergreen.V17.Questions.SassOrScss

        Evergreen.V13.Questions.ElmCss ->
            Evergreen.V17.Questions.ElmCss

        Evergreen.V13.Questions.PlainCss ->
            Evergreen.V17.Questions.PlainCss

        Evergreen.V13.Questions.ElmUi ->
            Evergreen.V17.Questions.ElmUi

        Evergreen.V13.Questions.Tailwind ->
            Evergreen.V17.Questions.Tailwind

        Evergreen.V13.Questions.ElmTailwindModules ->
            Evergreen.V17.Questions.ElmTailwindModules

        Evergreen.V13.Questions.Bootstrap ->
            Evergreen.V17.Questions.Bootstrap


migrateTestTools : Evergreen.V13.Questions.TestTools -> Evergreen.V17.Questions.TestTools
migrateTestTools old =
    case old of
        Evergreen.V13.Questions.BrowserAcceptanceTests ->
            Evergreen.V17.Questions.BrowserAcceptanceTests

        Evergreen.V13.Questions.ElmBenchmark ->
            Evergreen.V17.Questions.ElmBenchmark

        Evergreen.V13.Questions.ElmTest ->
            Evergreen.V17.Questions.ElmTest

        Evergreen.V13.Questions.ElmProgramTest ->
            Evergreen.V17.Questions.ElmProgramTest

        Evergreen.V13.Questions.VisualRegressionTests ->
            Evergreen.V17.Questions.VisualRegressionTests


migrateTestsWrittenFor : Evergreen.V13.Questions.TestsWrittenFor -> Evergreen.V17.Questions.TestsWrittenFor
migrateTestsWrittenFor old =
    case old of
        Evergreen.V13.Questions.ComplicatedFunctions ->
            Evergreen.V17.Questions.ComplicatedFunctions

        Evergreen.V13.Questions.FunctionsThatReturnCmds ->
            Evergreen.V17.Questions.FunctionsThatReturnCmds

        Evergreen.V13.Questions.AllPublicFunctions ->
            Evergreen.V17.Questions.AllPublicFunctions

        Evergreen.V13.Questions.HtmlFunctions ->
            Evergreen.V17.Questions.HtmlFunctions

        Evergreen.V13.Questions.JsonDecodersAndEncoders ->
            Evergreen.V17.Questions.JsonDecodersAndEncoders

        Evergreen.V13.Questions.MostPublicFunctions ->
            Evergreen.V17.Questions.MostPublicFunctions


migrateWhatElmVersion : Evergreen.V13.Questions.WhatElmVersion -> Evergreen.V17.Questions.WhatElmVersion
migrateWhatElmVersion old =
    case old of
        Evergreen.V13.Questions.Version0_19 ->
            Evergreen.V17.Questions.Version0_19

        Evergreen.V13.Questions.Version0_18 ->
            Evergreen.V17.Questions.Version0_18

        Evergreen.V13.Questions.Version0_17 ->
            Evergreen.V17.Questions.Version0_17

        Evergreen.V13.Questions.Version0_16 ->
            Evergreen.V17.Questions.Version0_16


migrateWhatLanguageDoYouUseForTheBackend : Evergreen.V13.Questions.WhatLanguageDoYouUseForTheBackend -> Evergreen.V17.Questions.WhatLanguageDoYouUseForTheBackend
migrateWhatLanguageDoYouUseForTheBackend old =
    case old of
        Evergreen.V13.Questions.JavaScript_ ->
            Evergreen.V17.Questions.JavaScript_

        Evergreen.V13.Questions.TypeScript_ ->
            Evergreen.V17.Questions.TypeScript_

        Evergreen.V13.Questions.Go_ ->
            Evergreen.V17.Questions.Go_

        Evergreen.V13.Questions.Haskell_ ->
            Evergreen.V17.Questions.Haskell_

        Evergreen.V13.Questions.CSharp_ ->
            Evergreen.V17.Questions.CSharp_

        Evergreen.V13.Questions.OCaml_ ->
            Evergreen.V17.Questions.OCaml_

        Evergreen.V13.Questions.Python_ ->
            Evergreen.V17.Questions.Python_

        Evergreen.V13.Questions.PHP_ ->
            Evergreen.V17.Questions.PHP_

        Evergreen.V13.Questions.Java_ ->
            Evergreen.V17.Questions.Java_

        Evergreen.V13.Questions.Ruby_ ->
            Evergreen.V17.Questions.Ruby_

        Evergreen.V13.Questions.Elixir_ ->
            Evergreen.V17.Questions.Elixir_

        Evergreen.V13.Questions.Clojure_ ->
            Evergreen.V17.Questions.Clojure_

        Evergreen.V13.Questions.Rust_ ->
            Evergreen.V17.Questions.Rust_

        Evergreen.V13.Questions.FSharp_ ->
            Evergreen.V17.Questions.FSharp_

        Evergreen.V13.Questions.AlsoElm ->
            Evergreen.V17.Questions.AlsoElm

        Evergreen.V13.Questions.NotApplicable ->
            Evergreen.V17.Questions.NotApplicable


migrateWhereDoYouUseElm : Evergreen.V13.Questions.WhereDoYouUseElm -> Evergreen.V17.Questions.WhereDoYouUseElm
migrateWhereDoYouUseElm old =
    case old of
        Evergreen.V13.Questions.Education ->
            Evergreen.V17.Questions.Education

        Evergreen.V13.Questions.Gaming ->
            Evergreen.V17.Questions.Gaming

        Evergreen.V13.Questions.ECommerce ->
            Evergreen.V17.Questions.ECommerce

        Evergreen.V13.Questions.Audio ->
            Evergreen.V17.Questions.Audio

        Evergreen.V13.Questions.Finance ->
            Evergreen.V17.Questions.Finance

        Evergreen.V13.Questions.Health ->
            Evergreen.V17.Questions.Health

        Evergreen.V13.Questions.Productivity ->
            Evergreen.V17.Questions.Productivity

        Evergreen.V13.Questions.Communication ->
            Evergreen.V17.Questions.Communication

        Evergreen.V13.Questions.DataVisualization ->
            Evergreen.V17.Questions.DataVisualization

        Evergreen.V13.Questions.Transportation ->
            Evergreen.V17.Questions.Transportation


migrateWhichElmReviewRulesDoYouUse : Evergreen.V13.Questions.WhichElmReviewRulesDoYouUse -> Evergreen.V17.Questions.WhichElmReviewRulesDoYouUse
migrateWhichElmReviewRulesDoYouUse old =
    case old of
        Evergreen.V13.Questions.ElmReviewUnused ->
            Evergreen.V17.Questions.ElmReviewUnused

        Evergreen.V13.Questions.ElmReviewSimplify ->
            Evergreen.V17.Questions.ElmReviewSimplify

        Evergreen.V13.Questions.ElmReviewLicense ->
            Evergreen.V17.Questions.ElmReviewLicense

        Evergreen.V13.Questions.ElmReviewDebug ->
            Evergreen.V17.Questions.ElmReviewDebug

        Evergreen.V13.Questions.ElmReviewCommon ->
            Evergreen.V17.Questions.ElmReviewCommon

        Evergreen.V13.Questions.ElmReviewCognitiveComplexity ->
            Evergreen.V17.Questions.ElmReviewCognitiveComplexity


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
        Old.Loading loading ->
            New.Loading loading

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

        Old.GotWindowSize size ->
            New.GotWindowSize size


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
