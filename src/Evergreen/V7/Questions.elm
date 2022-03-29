module Evergreen.V7.Questions exposing (..)


type DoYouUseElm
    = YesAtWork
    | YesInSideProjects
    | YesAsAStudent
    | IUsedToButIDontAnymore
    | NoButImCuriousAboutIt
    | NoAndIDontPlanTo


type Age
    = Under10
    | Age10To20
    | Age20To30
    | Age30To40
    | Age40To50
    | Age50To60
    | Over60


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
    | Swift
    | PHP
    | Java
    | Ruby
    | Elixir
    | Clojure
    | Rust
    | FSharp


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
    | FrontendMasters


type WhereDoYouUseElm
    = Education
    | Gaming
    | ECommerce
    | Audio
    | Finance
    | Health
    | Productivity
    | Communication
    | DataVisualization
    | Transportation


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
    = ClosedSource
    | OpenSourceShareAlike
    | OpenSourcePermissive


type WhatElmVersion
    = Version0_19
    | Version0_18
    | Version0_17
    | Version0_16


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
    | Bootstrap


type BuildTools
    = ShellScripts
    | ElmLive
    | CreateElmApp
    | Webpack
    | Brunch
    | ElmMakeStandalone
    | Gulp
    | Make
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
