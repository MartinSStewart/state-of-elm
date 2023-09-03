module Evergreen.V43.Questions2023 exposing (..)


type DoYouUseElm
    = YesAtWork
    | YesInSideProjects
    | YesAsAStudent
    | IUsedToButIDontAnymore
    | NoButImCuriousAboutIt
    | NoAndIDontPlanTo


type Age
    = Under10
    | Age10To19
    | Age20To29
    | Age30To39
    | Age40To49
    | Age50To59
    | Over60
    | PreferNotToAnswer2


type PleaseSelectYourGender
    = Man
    | Woman
    | TransMan
    | TransWoman
    | NonBinary
    | PreferNotToAnswer
    | OtherGender


type ExperienceLevel
    = Beginner
    | Intermediate
    | Professional
    | Expert


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
    | NoOtherLanguage


type NewsAndDiscussions
    = ElmDiscourse
    | ElmSlack
    | ElmSubreddit
    | Twitter
    | ElmRadio
    | BlogPosts
    | DevTo
    | Meetups
    | ElmWeekly
    | ElmNews
    | ElmCraft
    | IncrementalElm
    | NoNewsOrDiscussions


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
    | ElmOnline
    | ElmTown
    | NoElmResources


type ApplicationDomains
    = Education
    | Gaming
    | ECommerce
    | Music
    | Finance
    | Health
    | Productivity
    | Communication
    | DataVisualization
    | Transportation
    | SocialMedia
    | Engineering
    | Sports
    | ArtAndCulture
    | Legal
    | EnvironmentOrClimate
    | NoApplicationDomains


type DoYouUseElmAtWork
    = NotInterestedInElmAtWork
    | WouldLikeToUseElmAtWork
    | HaveTriedElmInAWorkProject
    | IUseElmAtWork
    | NotEmployed


type HowLargeIsTheCompany
    = Size1To10Employees
    | Size11To50Employees
    | Size50To100Employees
    | Size100OrMore


type WhatLanguageDoYouUseForBackend
    = JavaScript_
    | TypeScript_
    | Go_
    | Haskell_
    | CSharp_
    | OCaml_
    | Python_
    | PHP_
    | Java_
    | Ruby_
    | Elixir_
    | Clojure_
    | Rust_
    | FSharp_
    | AlsoElm
    | C_
    | CPlusPlus_
    | Kotlin_
    | NotApplicable


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
    | TenYears


type ElmVersion
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
    | ElmTailwindModules
    | Bootstrap
    | NoStylingTools


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
    | Parcel
    | Vite
    | ElmWatch
    | ElmPages_
    | Lamdera__
    | ElmLand_
    | EsBuild
    | NoBuildTools


type Frameworks
    = Lamdera_
    | ElmSpa
    | ElmPages
    | ElmPlayground
    | NoFramework
    | ElmLand


type Editors
    = SublimeText
    | Vim
    | Atom
    | Emacs
    | VSCode
    | Intellij
    | NoEditor


type DoYouUseElmReview
    = NeverHeardOfElmReview
    | HeardOfItButNeverTriedElmReview
    | IveTriedElmReview
    | IUseElmReviewRegularly


type TestTools
    = BrowserAcceptanceTests
    | ElmBenchmark
    | ElmTest
    | ElmProgramTest
    | VisualRegressionTests
    | NoTestTools
