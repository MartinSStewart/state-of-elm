module Questions exposing
    ( DoYouUseElm(..)
    , ElmResources(..)
    , ExperienceLevel(..)
    , HowLong(..)
    , NewsAndDiscussions(..)
    , OtherLanguages(..)
    , WhereDoYouUseElm(..)
    , YesNo(..)
    , allApplicationDomains
    , allDoYouUseElm
    , allElmResources
    , allExperienceLevels
    , allHowLong
    , allNewsAndDiscussions
    , allOtherLanguages
    , allYesNo
    , applicationDomainsToString
    , doYouUseElmToString
    , elmResourcesToString
    , experienceLevelToString
    , howLongToString
    , newsAndDiscussionsToString
    , otherLanguagesToString
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
