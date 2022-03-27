module Questions exposing
    ( BuildTools(..)
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
    , YesNo(..)
    , allApplicationDomains
    , allBuildTools
    , allDoYouUseElm
    , allDoYouUseElmFormat
    , allEditor
    , allElmResources
    , allExperienceLevels
    , allHowFarAlong
    , allHowIsProjectLicensed
    , allHowLong
    , allNewsAndDiscussions
    , allOtherLanguages
    , allStylingTools
    , allTestTools
    , allTestsWrittenFor
    , allWhatElmVersion
    , allYesNo
    , applicationDomainsToString
    , buildToolsToString
    , doYouUseElmFormatToString
    , doYouUseElmToString
    , editorToString
    , elmResourcesToString
    , experienceLevelToString
    , howFarAlongToStringHobby
    , howFarAlongToStringWork
    , howIsProjectLicensedToString
    , howLongToString
    , newsAndDiscussionsToString
    , otherLanguagesToString
    , stylingToolsToString
    , testToolsToString
    , testsWrittenForToString
    , whatElmVersionToString
    , yesNoToString
    )

import List.Nonempty exposing (Nonempty(..))


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


allExperienceLevels : Nonempty ExperienceLevel
allExperienceLevels =
    Nonempty
        Level0
        [ Level1
        , Level2
        , Level3
        , Level4
        , Level5
        , Level6
        , Level7
        , Level8
        , Level9
        , Level10
        ]


experienceLevelToString : ExperienceLevel -> String
experienceLevelToString experienceLevel =
    case experienceLevel of
        Level0 ->
            "0"

        Level1 ->
            "1"

        Level2 ->
            "2"

        Level3 ->
            "3"

        Level4 ->
            "4"

        Level5 ->
            "5"

        Level6 ->
            "6"

        Level7 ->
            "7"

        Level8 ->
            "8"

        Level9 ->
            "9"

        Level10 ->
            "10"


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
    | R
    | Swift
    | PHP
    | Java


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
        , R
        , Swift
        , PHP
        , Java
        ]


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

        R ->
            "R"

        Swift ->
            "Swift"

        PHP ->
            "PHP"

        Java ->
            "Java"


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
            "Twitter"

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
            "Elm Weekly"

        ElmNews ->
            "Elm News"


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
        ]


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


type YesNo
    = Yes
    | No


allYesNo : Nonempty YesNo
allYesNo =
    Nonempty Yes [ No ]


yesNoToString : YesNo -> String
yesNoToString yesNo =
    case yesNo of
        Yes ->
            "Yes"

        No ->
            "No"


type WhereDoYouUseElm
    = Education
    | Gaming
    | ECommerce
    | Music
    | Finance


allApplicationDomains : Nonempty WhereDoYouUseElm
allApplicationDomains =
    Nonempty
        Education
        [ Gaming
        , ECommerce
        , Music
        , Finance
        ]


applicationDomainsToString : WhereDoYouUseElm -> String
applicationDomainsToString whereDoYouUseElm =
    case whereDoYouUseElm of
        Education ->
            "Education"

        Gaming ->
            "Gaming"

        ECommerce ->
            "E-commerce"

        Music ->
            "Music"

        Finance ->
            "Finance"


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
    Nonempty NotApplicable
        [ ClosedSource
        , OpenSourceShareAlike
        , OpenSourcePermissive
        ]


allWhatElmVersion : Nonempty WhatElmVersion
allWhatElmVersion =
    Nonempty Version0_19
        [ Version0_18
        , Version0_17
        , Version0_16
        , Version0_15
        , Version0_14
        , Version0_13
        , Version0_12
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
        ]


allBuildTools : Nonempty BuildTools
allBuildTools =
    Nonempty Broccoli
        [ ShellScripts
        , ElmLive
        , CreateElmApp
        , Webpack
        , Brunch
        , ElmMakeStandalone
        , Gulp
        , Make
        , Grunt
        , ElmReactor
        , Lamdera
        , Parcel
        ]


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
        NotApplicable ->
            "Not applicable"

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
            "0.19 and 0.19.1"

        Version0_18 ->
            "0.18"

        Version0_17 ->
            "0.17"

        Version0_16 ->
            "0.16"

        Version0_15 ->
            "0.15"

        Version0_14 ->
            "0.14"

        Version0_13 ->
            "0.13"

        Version0_12 ->
            "0.12"


doYouUseElmFormatToString : DoYouUseElmFormat -> String
doYouUseElmFormatToString a =
    case a of
        PreferElmFormat ->
            "I prefer to use elm-format"

        TriedButDontUseElmFormat ->
            "I have tried elm-format, but prefer to not use it"

        HeardButDontUseElmFormat ->
            "I have heard of elm-format, but have no used it"

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


buildToolsToString : BuildTools -> String
buildToolsToString a =
    case a of
        Broccoli ->
            "Broccoli"

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

        Grunt ->
            "Grunt"

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
