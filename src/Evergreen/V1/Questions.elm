module Evergreen.V1.Questions exposing (..)


type DoYouUseElm
    = YesAtWork
    | YesInSideProjects
    | YesAsAStudent
    | IUsedToButIDontAnymore
    | NoButImCuriousAboutIt
    | NoAndIDontPlanTo


type ExperienceLevel
    = Level0
    | Level1
    | Level2
    | Level3
    | Level4
    | Level5
    | Level6
    | Level7
    | Level8
    | Level9
    | Level10


type OtherLanguages
    = JavaScript
    | TypeScript
    | Go
    | Haskell
    | CSharp
    | C
    | CPlusPlus
    | OCaml
    | Python
    | R
    | Swift
    | PHP
    | Java


type NewsAndDiscussions
    = ElmDiscourse
    | ElmSlack
    | ElmSubreddit
    | Twitter
    | ElmRadio
    | BlogPosts
    | Facebook
    | DevTo
    | Meetups
    | ElmWeekly
    | ElmNews


type ElmResources
    = DailyDrip
    | ElmInActionBook
    | WeeklyBeginnersElmSubreddit
    | BeginningElmBook
    | StackOverflow
    | BuildingWebAppsWithElm
    | TheJsonSurvivalKit
    | EggheadCourses
    | ProgrammingElmBook
    | GuideElmLang
    | ElmForBeginners
    | ElmSlack_


type YesNo
    = Yes
    | No


type WhereDoYouUseElm
    = Education
    | Gaming
    | ECommerce
    | Music
    | Finance


type HowLong
    = Under3Months
    | Between3MonthsAndAYear
    | OneYear
    | TwoYears
    | ThreeYears
    | FourYears
    | FiveYears
    | SixYears
    | SevenYears
    | EightYears
    | NineYears


type HowFarAlong
    = IHaveNotStarted
    | PlanningLearningExplorationPhase
    | InDevelopment
    | InStaging
    | Shipped


type HowIsProjectLicensed
    = NotApplicable
    | ClosedSource
    | OpenSourceShareAlike
    | OpenSourcePermissive


type WhatElmVersion
    = Version0_19
    | Version0_18
    | Version0_17
    | Version0_16
    | Version0_15
    | Version0_14
    | Version0_13
    | Version0_12


type DoYouUseElmFormat
    = PreferElmFormat
    | TriedButDontUseElmFormat
    | HeardButDontUseElmFormat
    | HaveNotHeardOfElmFormat


type StylingTools
    = SassOrScss
    | ElmCss
    | PlainCss
    | ElmUi
    | Tailwind


type BuildTools
    = Broccoli
    | ShellScripts
    | ElmLive
    | CreateElmApp
    | Webpack
    | Brunch
    | ElmMakeStandalone
    | Gulp
    | Make
    | Grunt
    | ElmReactor
    | Lamdera
    | Parcel


type Editor
    = SublimeText
    | Vim
    | Atom
    | Emacs
    | VSCode
    | Intellij


type TestTools
    = IDontWriteTests
    | BrowserAcceptanceTests
    | ElmBenchmark
    | ElmTest
    | ElmProgramTest
    | VisualRegressionTests


type TestsWrittenFor
    = ComplicatedFunctions
    | FunctionsThatReturnCmds
    | AllPublicFunctions
    | HtmlFunctions
    | JsonDecodersAndEncoders
    | MostPublicFunctions
