module Questions exposing
    ( Age(..)
    , BuildTools(..)
    , DoYouUseElm(..)
    , DoYouUseElmFormat(..)
    , Editor(..)
    , ElmResources(..)
    , ExperienceLevel(..)
    , HowFarAlong(..)
    , HowIsProjectLicensed(..)
    , HowLong(..)
    , NewsAndDiscussions(..)
    , OtherLanguages(..)
    , StylingTools(..)
    , TestTools(..)
    , TestsWrittenFor(..)
    , WhatElmVersion(..)
    , WhereDoYouUseElm(..)
    , ageToString
    , allAge
    , allApplicationDomains
    , allBuildTools
    , allDoYouUseElm
    , allDoYouUseElmFormat
    , allEditor
    , allElmResources
    , allHowFarAlong
    , allHowIsProjectLicensed
    , allHowLong
    , allNewsAndDiscussions
    , allOtherLanguages
    , allStylingTools
    , allTestTools
    , allTestsWrittenFor
    , allWhatElmVersion
    , applicationDomainsToString
    , buildToolsToString
    , doYouUseElmFormatToString
    , doYouUseElmToString
    , editorToString
    , elmResourcesToString
    , experienceToInt
    , howFarAlongToStringHobby
    , howFarAlongToStringWork
    , howIsProjectLicensedToString
    , howLongToString
    , intToExperience
    , newsAndDiscussionsToString
    , otherLanguagesToString
    , stylingToolsToString
    , testToolsToString
    , testsWrittenForToString
    , whatElmVersionToString
    )

import List.Nonempty exposing (Nonempty(..))


type Age
    = Under10
    | Age10To20
    | Age20To30
    | Age30To40
    | Age40To50
    | Age50To60
    | Over60


allAge : Nonempty Age
allAge =
    Nonempty Under10
        [ Age10To20
        , Age20To30
        , Age30To40
        , Age40To50
        , Age50To60
        , Over60
        ]


ageToString : Age -> String
ageToString age =
    case age of
        Under10 ->
            "Younger than 10"

        Age10To20 ->
            "Between 10 and 20"

        Age20To30 ->
            "Between 20 and 30"

        Age30To40 ->
            "Between 30 and 40"

        Age40To50 ->
            "Between 40 and 50"

        Age50To60 ->
            "Between 50 and 60"

        Over60 ->
            "60 years or older"


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


experienceToInt : ExperienceLevel -> Int
experienceToInt a =
    case a of
        Level0 ->
            0

        Level1 ->
            1

        Level2 ->
            2

        Level3 ->
            3

        Level4 ->
            4

        Level5 ->
            5

        Level6 ->
            6

        Level7 ->
            7

        Level8 ->
            8

        Level9 ->
            9

        Level10 ->
            10


intToExperience : Int -> ExperienceLevel
intToExperience a =
    case a of
        0 ->
            Level0

        1 ->
            Level1

        2 ->
            Level2

        3 ->
            Level3

        4 ->
            Level4

        5 ->
            Level5

        6 ->
            Level6

        7 ->
            Level7

        8 ->
            Level8

        9 ->
            Level9

        10 ->
            Level10

        _ ->
            Level0


type DoYouUseElm
    = YesAtWork
    | YesInSideProjects
    | YesAsAStudent
    | IUsedToButIDontAnymore
    | NoButImCuriousAboutIt
    | NoAndIDontPlanTo


allDoYouUseElm : Nonempty DoYouUseElm
allDoYouUseElm =
    Nonempty
        YesAtWork
        [ YesInSideProjects
        , YesAsAStudent
        , IUsedToButIDontAnymore
        , NoButImCuriousAboutIt
        , NoAndIDontPlanTo
        ]


doYouUseElmToString : DoYouUseElm -> String
doYouUseElmToString doYouUseElm =
    case doYouUseElm of
        YesAtWork ->
            "Yes, at work"

        YesInSideProjects ->
            "Yes, in side projects"

        YesAsAStudent ->
            "Yes, as a student"

        IUsedToButIDontAnymore ->
            "I used to, but I don't anymore"

        NoButImCuriousAboutIt ->
            "No, but I'm curious about it"

        NoAndIDontPlanTo ->
            "No, and I don't plan to"


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


allOtherLanguages : Nonempty OtherLanguages
allOtherLanguages =
    Nonempty
        JavaScript
        [ TypeScript
        , Go
        , Haskell
        , CSharp
        , C
        , CPlusPlus
        , OCaml
        , Python
        , Swift
        , PHP
        , Java
        , Ruby
        , Elixir
        , Clojure
        , Rust
        , FSharp
        ]
        |> List.Nonempty.sortBy otherLanguagesToString


otherLanguagesToString : OtherLanguages -> String
otherLanguagesToString otherLanguages =
    case otherLanguages of
        JavaScript ->
            "JavaScript"

        TypeScript ->
            "TypeScript"

        Go ->
            "Go"

        Haskell ->
            "Haskell"

        CSharp ->
            "C#"

        C ->
            "C"

        CPlusPlus ->
            "C++"

        OCaml ->
            "OCaml"

        Python ->
            "Python"

        Swift ->
            "Swift"

        PHP ->
            "PHP"

        Java ->
            "Java"

        Ruby ->
            "Ruby"

        Elixir ->
            "Elixir"

        Clojure ->
            "Clojure"

        Rust ->
            "Rust"

        FSharp ->
            "F#"


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


allNewsAndDiscussions : Nonempty NewsAndDiscussions
allNewsAndDiscussions =
    Nonempty
        ElmDiscourse
        [ ElmSlack
        , ElmSubreddit
        , Twitter
        , ElmRadio
        , BlogPosts
        , Facebook
        , DevTo
        , Meetups
        , ElmWeekly
        , ElmNews
        ]
        |> List.Nonempty.sortBy newsAndDiscussionsToString


newsAndDiscussionsToString : NewsAndDiscussions -> String
newsAndDiscussionsToString newsAndDiscussions =
    case newsAndDiscussions of
        ElmDiscourse ->
            "Elm Discourse"

        ElmSlack ->
            "Elm Slack"

        ElmSubreddit ->
            "Elm Subreddit"

        Twitter ->
            "Twitter discussions"

        ElmRadio ->
            "Elm Radio"

        BlogPosts ->
            "Blog posts"

        Facebook ->
            "Facebook groups"

        DevTo ->
            "dev.to"

        Meetups ->
            "Meetups"

        ElmWeekly ->
            "Elm Weekly newsletter"

        ElmNews ->
            "elm-news.com"


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


allElmResources : Nonempty ElmResources
allElmResources =
    Nonempty
        DailyDrip
        [ ElmInActionBook
        , WeeklyBeginnersElmSubreddit
        , BeginningElmBook
        , StackOverflow
        , BuildingWebAppsWithElm
        , TheJsonSurvivalKit
        , EggheadCourses
        , ProgrammingElmBook
        , GuideElmLang
        , ElmForBeginners
        , ElmSlack_
        , FrontendMasters
        ]
        |> List.Nonempty.sortBy elmResourcesToString


elmResourcesToString : ElmResources -> String
elmResourcesToString elmResources =
    case elmResources of
        DailyDrip ->
            "Daily Drip"

        ElmInActionBook ->
            "Elm in Action (book)"

        WeeklyBeginnersElmSubreddit ->
            "Weekly beginners threads on the Elm Subreddit"

        BeginningElmBook ->
            "Beginning Elm (book)"

        StackOverflow ->
            "StackOverflow"

        BuildingWebAppsWithElm ->
            "Building Web Apps with Elm (Pragmatic Studio course)"

        TheJsonSurvivalKit ->
            "The JSON Survival Kit (book)"

        EggheadCourses ->
            "Egghead courses"

        ProgrammingElmBook ->
            "Programming Elm (book)"

        GuideElmLang ->
            "guide.elm-lang.org"

        ElmForBeginners ->
            "Elm for Beginners (KnowThen course)"

        ElmSlack_ ->
            "Elm Slack"

        FrontendMasters ->
            "Frontend Masters"


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


allApplicationDomains : Nonempty WhereDoYouUseElm
allApplicationDomains =
    Nonempty
        Education
        [ Gaming
        , ECommerce
        , Audio
        , Finance
        , Health
        , Productivity
        , Communication
        , DataVisualization
        , Transportation
        ]
        |> List.Nonempty.sortBy applicationDomainsToString


applicationDomainsToString : WhereDoYouUseElm -> String
applicationDomainsToString whereDoYouUseElm =
    case whereDoYouUseElm of
        Education ->
            "Education"

        Gaming ->
            "Gaming"

        ECommerce ->
            "E-commerce"

        Audio ->
            "Music"

        Finance ->
            "Finance"

        Health ->
            "Health"

        Productivity ->
            "Productivity"

        Communication ->
            "Communication"

        DataVisualization ->
            "Data visualization"

        Transportation ->
            "Transportation"


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


allHowLong : Nonempty HowLong
allHowLong =
    Nonempty
        Under3Months
        [ Between3MonthsAndAYear
        , OneYear
        , TwoYears
        , ThreeYears
        , FourYears
        , FiveYears
        , SixYears
        , SevenYears
        , EightYears
        , NineYears
        ]


howLongToString : HowLong -> String
howLongToString howLong =
    case howLong of
        Under3Months ->
            "Under three months"

        Between3MonthsAndAYear ->
            "Between three months and a year"

        OneYear ->
            "1 year"

        TwoYears ->
            "2 years"

        ThreeYears ->
            "3 years"

        FourYears ->
            "4 years"

        FiveYears ->
            "5 years"

        SixYears ->
            "6 years"

        SevenYears ->
            "7 years"

        EightYears ->
            "8 years"

        NineYears ->
            "9 years"


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


allHowFarAlong : Nonempty HowFarAlong
allHowFarAlong =
    Nonempty IHaveNotStarted
        [ PlanningLearningExplorationPhase
        , InDevelopment
        , InStaging
        , Shipped
        ]


allHowIsProjectLicensed : Nonempty HowIsProjectLicensed
allHowIsProjectLicensed =
    Nonempty ClosedSource
        [ OpenSourceShareAlike
        , OpenSourcePermissive
        ]


allWhatElmVersion : Nonempty WhatElmVersion
allWhatElmVersion =
    Nonempty Version0_19
        [ Version0_18
        , Version0_17
        , Version0_16
        ]


allDoYouUseElmFormat : Nonempty DoYouUseElmFormat
allDoYouUseElmFormat =
    Nonempty PreferElmFormat
        [ TriedButDontUseElmFormat
        , HeardButDontUseElmFormat
        , HaveNotHeardOfElmFormat
        ]


allStylingTools : Nonempty StylingTools
allStylingTools =
    Nonempty SassOrScss
        [ ElmCss
        , PlainCss
        , ElmUi
        , Tailwind
        , Bootstrap
        ]


allBuildTools : Nonempty BuildTools
allBuildTools =
    Nonempty ShellScripts
        [ ElmLive
        , CreateElmApp
        , Webpack
        , Brunch
        , ElmMakeStandalone
        , Gulp
        , Make
        , ElmReactor
        , Lamdera
        , Parcel
        ]
        |> List.Nonempty.sortBy buildToolsToString


allEditor : Nonempty Editor
allEditor =
    Nonempty SublimeText
        [ Vim
        , Atom
        , Emacs
        , VSCode
        , Intellij
        ]


allTestTools : Nonempty TestTools
allTestTools =
    Nonempty IDontWriteTests
        [ BrowserAcceptanceTests
        , ElmBenchmark
        , ElmTest
        , ElmProgramTest
        , VisualRegressionTests
        ]


allTestsWrittenFor : Nonempty TestsWrittenFor
allTestsWrittenFor =
    Nonempty ComplicatedFunctions
        [ FunctionsThatReturnCmds
        , AllPublicFunctions
        , HtmlFunctions
        , JsonDecodersAndEncoders
        , MostPublicFunctions
        ]


howFarAlongToStringWork : HowFarAlong -> String
howFarAlongToStringWork howFarAlong =
    case howFarAlong of
        IHaveNotStarted ->
            "I have not started an Elm project at work"

        PlanningLearningExplorationPhase ->
            "In the planning / learning / exploration phase"

        InDevelopment ->
            "In development"

        InStaging ->
            "In staging"

        Shipped ->
            "Shipped / released to users / in production"


howFarAlongToStringHobby : HowFarAlong -> String
howFarAlongToStringHobby howFarAlong =
    case howFarAlong of
        IHaveNotStarted ->
            "I have not started a side project using Elm"

        PlanningLearningExplorationPhase ->
            "In the planning / learning / exploration phase"

        InDevelopment ->
            "In development"

        InStaging ->
            "In staging"

        Shipped ->
            "Shipped / released to users / in production"


howIsProjectLicensedToString : HowIsProjectLicensed -> String
howIsProjectLicensedToString a =
    case a of
        ClosedSource ->
            "Closed source"

        OpenSourceShareAlike ->
            "Open source (share-alike license like GPL)"

        OpenSourcePermissive ->
            "Open source (permissive license like BSD)"


whatElmVersionToString : WhatElmVersion -> String
whatElmVersionToString a =
    case a of
        Version0_19 ->
            "0.19 or 0.19.1"

        Version0_18 ->
            "0.18"

        Version0_17 ->
            "0.17"

        Version0_16 ->
            "0.16"


doYouUseElmFormatToString : DoYouUseElmFormat -> String
doYouUseElmFormatToString a =
    case a of
        PreferElmFormat ->
            "I prefer to use elm-format"

        TriedButDontUseElmFormat ->
            "I have tried elm-format, but prefer to not use it"

        HeardButDontUseElmFormat ->
            "I have heard of elm-format, but have not used it"

        HaveNotHeardOfElmFormat ->
            "I have not previously heard of elm-format"


stylingToolsToString : StylingTools -> String
stylingToolsToString a =
    case a of
        SassOrScss ->
            "SASS/SCSS"

        ElmCss ->
            "elm-css"

        PlainCss ->
            "plain CSS"

        ElmUi ->
            "elm-ui"

        Tailwind ->
            "Tailwind"

        Bootstrap ->
            "Bootstrap"


buildToolsToString : BuildTools -> String
buildToolsToString a =
    case a of
        ShellScripts ->
            "Shell scripts"

        ElmLive ->
            "elm-live"

        CreateElmApp ->
            "create-elm-app"

        Webpack ->
            "Webpack"

        Brunch ->
            "Brunch"

        ElmMakeStandalone ->
            "ElmMakeStandalone"

        Gulp ->
            "Gulp"

        Make ->
            "Make"

        ElmReactor ->
            "elm-reactor"

        Lamdera ->
            "Lamdera"

        Parcel ->
            "Parcel"


editorToString : Editor -> String
editorToString a =
    case a of
        SublimeText ->
            "Sublime Text"

        Vim ->
            "Vim"

        Atom ->
            "Atom"

        Emacs ->
            "Emacs"

        VSCode ->
            "VSCode"

        Intellij ->
            "Intellij"


testToolsToString : TestTools -> String
testToolsToString a =
    case a of
        IDontWriteTests ->
            "I don't write tests for my Elm projects"

        BrowserAcceptanceTests ->
            "Browser acceptance testing (e.g. Capybara)"

        ElmBenchmark ->
            "elm-benchmark"

        ElmTest ->
            "elm-test"

        ElmProgramTest ->
            "elm-program-test"

        VisualRegressionTests ->
            "Visual regression testing (e.g. Percy.io)"


testsWrittenForToString : TestsWrittenFor -> String
testsWrittenForToString a =
    case a of
        ComplicatedFunctions ->
            "Your most complicated functions"

        FunctionsThatReturnCmds ->
            "Functions that return Cmd"

        AllPublicFunctions ->
            "All public functions in your modules"

        HtmlFunctions ->
            "Functions that return Html"

        JsonDecodersAndEncoders ->
            "JSON encoders/decoders"

        MostPublicFunctions ->
            "Most public functions in your modules"
