module Questions2023 exposing
    ( Age(..)
    , ApplicationDomains(..)
    , BuildTools(..)
    , DoYouUseElm(..)
    , DoYouUseElmAtWork(..)
    , DoYouUseElmFormat(..)
    , DoYouUseElmReview(..)
    , Editors(..)
    , ElmResources(..)
    , ElmVersion(..)
    , ExperienceLevel(..)
    , Frameworks(..)
    , HowLargeIsTheCompany(..)
    , HowLong(..)
    , NewsAndDiscussions(..)
    , OtherLanguages(..)
    , PleaseSelectYourGender(..)
    , Question
    , StylingTools(..)
    , TestTools(..)
    , WhatLanguageDoYouUseForBackend(..)
    , age
    , applicationDomains
    , biggestPainPointTitle
    , buildTools
    , countryLivingIn
    , doYouUseElm
    , doYouUseElmAtWork
    , doYouUseElmFormat
    , doYouUseElmReview
    , editors
    , elmResources
    , elmVersion
    , experienceLevel
    , frameworks
    , howDidItGoUsingElmAtWorkTitle
    , howIsItGoingUsingElmAtWorkTitle
    , howLargeIsTheCompany
    , howLong
    , initialInterestTitle
    , newsAndDiscussions
    , otherLanguages
    , pleaseSelectYourGender
    , stylingTools
    , surveyImprovementsTitle
    , testTools
    , whatDoYouLikeMostTitle
    , whatLanguageDoYouUseForBackend
    , whatPackagesDoYouUseTitle
    , whatPreventsYouFromUsingElmAtWorkTitle
    )

import Countries exposing (Country)
import List.Nonempty exposing (Nonempty(..))


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


type DoYouUseElm
    = YesAtWork
    | YesInSideProjects
    | YesAsAStudent
    | IUsedToButIDontAnymore
    | NoButImCuriousAboutIt
    | NoAndIDontPlanTo


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


type DoYouUseElmReview
    = NeverHeardOfElmReview
    | HeardOfItButNeverTriedElmReview
    | IveTriedElmReview
    | IUseElmReviewRegularly


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


type TestTools
    = BrowserAcceptanceTests
    | ElmBenchmark
    | ElmTest
    | ElmProgramTest
    | VisualRegressionTests
    | NoTestTools


type alias Question a =
    { title : String
    , choices : Nonempty a
    , choiceToString : a -> String
    }


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


doYouUseElm : Question DoYouUseElm
doYouUseElm =
    { title = "Do you use Elm?"
    , choices = allDoYouUseElm
    , choiceToString =
        \a ->
            case a of
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
    }


allAge : Nonempty Age
allAge =
    Nonempty Under10
        [ Age10To19
        , Age20To29
        , Age30To39
        , Age40To49
        , Age50To59
        , Over60
        , PreferNotToAnswer2
        ]


age : Question Age
age =
    { title = "How old are you?"
    , choices = allAge
    , choiceToString =
        \a ->
            case a of
                Under10 ->
                    "Younger than 10"

                Age10To19 ->
                    "Between 10 and 19"

                Age20To29 ->
                    "Between 20 and 29"

                Age30To39 ->
                    "Between 30 and 39"

                Age40To49 ->
                    "Between 40 and 49"

                Age50To59 ->
                    "Between 50 and 59"

                Over60 ->
                    "60 years or older"

                PreferNotToAnswer2 ->
                    "Prefer not to answer"
    }


allPleaseSelectYourGender : Nonempty PleaseSelectYourGender
allPleaseSelectYourGender =
    Nonempty Woman
        [ Man
        , TransWoman
        , TransMan
        , NonBinary
        , PreferNotToAnswer
        , OtherGender
        ]


pleaseSelectYourGender : Question PleaseSelectYourGender
pleaseSelectYourGender =
    { title = "Please select the gender you most closely identify with"
    , choices = allPleaseSelectYourGender
    , choiceToString =
        \a ->
            case a of
                Man ->
                    "Man"

                Woman ->
                    "Woman"

                TransMan ->
                    "Trans man"

                TransWoman ->
                    "Trans woman"

                NonBinary ->
                    "Non-binary"

                PreferNotToAnswer ->
                    "Prefer not to answer"

                OtherGender ->
                    "Other"
    }


allExperienceLevels : Nonempty ExperienceLevel
allExperienceLevels =
    Nonempty
        Beginner
        [ Intermediate
        , Professional
        , Expert
        ]


experienceLevel : Question ExperienceLevel
experienceLevel =
    { title = "What is your level of experience with functional programming?"
    , choices = allExperienceLevels
    , choiceToString =
        \a ->
            case a of
                Beginner ->
                    "I'm a beginner"

                Intermediate ->
                    "Intermediate"

                Professional ->
                    "I'm good enough to use it professionally"

                Expert ->
                    "I'm an expert and could probably give a talk on category theory"
    }


allOtherLanguages : Nonempty OtherLanguages
allOtherLanguages =
    Nonempty
        C
        [ CSharp
        , CPlusPlus
        , Clojure
        , Elixir
        , FSharp
        , Go
        , Haskell
        , Java
        , JavaScript
        , OCaml
        , PHP
        , Python
        , Ruby
        , Rust
        , Swift
        , TypeScript
        , NoOtherLanguage
        ]


otherLanguages : Question OtherLanguages
otherLanguages =
    { title = "What programming languages, other than Elm, are you most familiar with?"
    , choices = allOtherLanguages
    , choiceToString =
        \a ->
            case a of
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

                NoOtherLanguage ->
                    "None"
    }


allNewsAndDiscussions : Nonempty NewsAndDiscussions
allNewsAndDiscussions =
    Nonempty
        BlogPosts
        [ ElmDiscourse
        , ElmRadio
        , ElmSlack
        , ElmSubreddit
        , ElmWeekly
        , Meetups
        , Twitter
        , DevTo
        , ElmNews
        , ElmCraft
        , IncrementalElm
        , NoNewsOrDiscussions
        ]


newsAndDiscussions : Question NewsAndDiscussions
newsAndDiscussions =
    { title = "Where do you go for Elm news and discussion?"
    , choices = allNewsAndDiscussions
    , choiceToString =
        \a ->
            case a of
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

                DevTo ->
                    "dev.to"

                Meetups ->
                    "Meetups"

                ElmWeekly ->
                    "Elm Weekly newsletter"

                ElmNews ->
                    "elm-news.com"

                ElmCraft ->
                    "elmcraft.org"

                IncrementalElm ->
                    "Incremental Elm"

                NoNewsOrDiscussions ->
                    "None"
    }


allElmResources : Nonempty ElmResources
allElmResources =
    Nonempty
        BeginningElmBook
        [ BuildingWebAppsWithElm
        , DailyDrip
        , EggheadCourses
        , ElmOnline
        , ElmSlack_
        , ElmForBeginners
        , ElmInActionBook
        , FrontendMasters
        , ProgrammingElmBook
        , StackOverflow
        , TheJsonSurvivalKit
        , WeeklyBeginnersElmSubreddit
        , GuideElmLang
        , NoElmResources
        ]


elmResources : Question ElmResources
elmResources =
    { title = "What resources did you use to learn Elm?"
    , choices = allElmResources
    , choiceToString =
        \a ->
            case a of
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

                ElmOnline ->
                    "Elm Online"

                NoElmResources ->
                    "None"
    }


initialInterestTitle : String
initialInterestTitle =
    "What initially attracted you to Elm, or motivated you to try it?"


countryLivingIn : Question Country
countryLivingIn =
    { title = "Which country do you live in?"
    , choices =
        List.Nonempty.fromList Countries.all
            |> Maybe.withDefault (Nonempty { name = "", code = "", flag = "" } [])
    , choiceToString =
        \{ name, flag } ->
            (case name of
                "United Kingdom of Great Britain and Northern Ireland" ->
                    "United Kingdom"

                "United States of America" ->
                    "United States"

                "Russian Federation" ->
                    "Russia"

                "Bosnia and Herzegovina" ->
                    "Bosnia"

                "Iran (Islamic Republic of)" ->
                    "Iran"

                "Venezuela (Bolivarian Republic of)" ->
                    "Venezuela"

                "Trinidad and Tobago" ->
                    "Trinidad"

                "Viet Nam" ->
                    "Vietnam"

                "Taiwan, Province of China" ->
                    "Taiwan"

                "South Georgia and the South Sandwich Islands" ->
                    "South Georgia"

                "Saint Helena, Ascension and Tristan da Cunha" ->
                    "Saint Helena"

                "Korea (Democratic People's Republic of)" ->
                    "North Korea"

                "Korea, Republic of" ->
                    "South Korea"

                _ ->
                    name
            )
                ++ " "
                ++ flag
    }


allApplicationDomains : Nonempty ApplicationDomains
allApplicationDomains =
    Nonempty
        Education
        [ Gaming
        , ECommerce
        , Music
        , Finance
        , Health
        , Productivity
        , Communication
        , DataVisualization
        , Transportation
        , SocialMedia
        , Engineering
        , Sports
        , ArtAndCulture
        , Legal
        , EnvironmentOrClimate
        , NoApplicationDomains
        ]


applicationDomains : Question ApplicationDomains
applicationDomains =
    { title = "In which application domains have you used Elm?"
    , choices = allApplicationDomains
    , choiceToString =
        \a ->
            case a of
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

                SocialMedia ->
                    "Social media"

                Engineering ->
                    "Engineering"

                Sports ->
                    "Sports"

                ArtAndCulture ->
                    "Art and culture"

                Legal ->
                    "Legal"

                EnvironmentOrClimate ->
                    "Environment and climate"

                NoApplicationDomains ->
                    "None"
    }


allDoYouUseElmAtWork : Nonempty DoYouUseElmAtWork
allDoYouUseElmAtWork =
    Nonempty NotInterestedInElmAtWork
        [ WouldLikeToUseElmAtWork
        , HaveTriedElmInAWorkProject
        , IUseElmAtWork
        , NotEmployed
        ]


doYouUseElmAtWork : Question DoYouUseElmAtWork
doYouUseElmAtWork =
    { title = "Do you use Elm at work?"
    , choices = allDoYouUseElmAtWork
    , choiceToString =
        \a ->
            case a of
                NotInterestedInElmAtWork ->
                    "No, and I'm not interested"

                WouldLikeToUseElmAtWork ->
                    "No, but I am interested"

                HaveTriedElmInAWorkProject ->
                    "I have tried Elm at work"

                IUseElmAtWork ->
                    "I use Elm at work"

                NotEmployed ->
                    "Not employed"
    }


whatPreventsYouFromUsingElmAtWorkTitle : String
whatPreventsYouFromUsingElmAtWorkTitle =
    "What prevents you from using Elm at work?"


howDidItGoUsingElmAtWorkTitle : String
howDidItGoUsingElmAtWorkTitle =
    "How did it go using Elm at work?"


howIsItGoingUsingElmAtWorkTitle : String
howIsItGoingUsingElmAtWorkTitle =
    "How is it going using Elm at work?"


allHowLargeIsTheCompany : Nonempty HowLargeIsTheCompany
allHowLargeIsTheCompany =
    Nonempty Size1To10Employees
        [ Size11To50Employees
        , Size50To100Employees
        , Size100OrMore
        ]


howLargeIsTheCompany : Question HowLargeIsTheCompany
howLargeIsTheCompany =
    { title = "How large is the company you work at?"
    , choices = allHowLargeIsTheCompany
    , choiceToString =
        \a ->
            case a of
                Size1To10Employees ->
                    "1 to 10 employees"

                Size11To50Employees ->
                    "11 to 50 employees"

                Size50To100Employees ->
                    "50 to 100 employees"

                Size100OrMore ->
                    "100+ employees"
    }


allBackendLanguages : Nonempty WhatLanguageDoYouUseForBackend
allBackendLanguages =
    Nonempty
        C_
        [ Clojure_
        , CPlusPlus_
        , CSharp_
        , Elixir_
        , AlsoElm
        , FSharp_
        , Go_
        , Haskell_
        , Java_
        , JavaScript_
        , Kotlin_
        , OCaml_
        , PHP_
        , Python_
        , Ruby_
        , Rust_
        , TypeScript_
        , NotApplicable
        ]


whatLanguageDoYouUseForBackend : Question WhatLanguageDoYouUseForBackend
whatLanguageDoYouUseForBackend =
    { title = "What languages does your company use on the backend?"
    , choices = allBackendLanguages
    , choiceToString =
        \a ->
            case a of
                JavaScript_ ->
                    "JavaScript"

                TypeScript_ ->
                    "TypeScript"

                Go_ ->
                    "Go"

                Haskell_ ->
                    "Haskell"

                CSharp_ ->
                    "C#"

                OCaml_ ->
                    "OCaml"

                Python_ ->
                    "Python"

                PHP_ ->
                    "PHP"

                Java_ ->
                    "Java"

                Ruby_ ->
                    "Ruby"

                Elixir_ ->
                    "Elixir"

                Clojure_ ->
                    "Clojure"

                Rust_ ->
                    "Rust"

                FSharp_ ->
                    "F#"

                AlsoElm ->
                    "Elm"

                NotApplicable ->
                    "Not applicable"

                C_ ->
                    "C"

                CPlusPlus_ ->
                    "C++"

                Kotlin_ ->
                    "Kotlin"
    }


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
        , TenYears
        ]


howLong : Question HowLong
howLong =
    { title = "How long have you been using Elm?"
    , choices = allHowLong
    , choiceToString =
        \a ->
            case a of
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

                TenYears ->
                    "10 years"
    }


allElmVersions : Nonempty ElmVersion
allElmVersions =
    Nonempty Version0_19 [ Version0_18, Version0_17, Version0_16 ]


elmVersion : Question ElmVersion
elmVersion =
    { title = "What versions of Elm are you using?"
    , choices = allElmVersions
    , choiceToString =
        \a ->
            case a of
                Version0_19 ->
                    "0.19"

                Version0_18 ->
                    "0.18"

                Version0_17 ->
                    "0.17"

                Version0_16 ->
                    "0.16"
    }


allDoYouUseElmFormat : Nonempty DoYouUseElmFormat
allDoYouUseElmFormat =
    Nonempty PreferElmFormat
        [ TriedButDontUseElmFormat
        , HeardButDontUseElmFormat
        , HaveNotHeardOfElmFormat
        ]


doYouUseElmFormat : Question DoYouUseElmFormat
doYouUseElmFormat =
    { title = "Do you format your code with elm-format?"
    , choices = allDoYouUseElmFormat
    , choiceToString =
        \a ->
            case a of
                PreferElmFormat ->
                    "I prefer to use elm-format"

                TriedButDontUseElmFormat ->
                    "I have tried elm-format, but prefer to not use it"

                HeardButDontUseElmFormat ->
                    "I have heard of elm-format, but have not used it"

                HaveNotHeardOfElmFormat ->
                    "I have not previously heard of elm-format"
    }


allStylingTools : Nonempty StylingTools
allStylingTools =
    Nonempty Bootstrap
        [ SassOrScss
        , Tailwind
        , ElmCss
        , ElmTailwindModules
        , ElmUi
        , PlainCss
        , NoStylingTools
        ]


stylingTools : Question StylingTools
stylingTools =
    { title = "What tools or libraries do you use to style your Elm applications?"
    , choices = allStylingTools
    , choiceToString =
        \a ->
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

                ElmTailwindModules ->
                    "elm-tailwind-modules"

                NoStylingTools ->
                    "None"
    }


allBuildTools : Nonempty BuildTools
allBuildTools =
    Nonempty Brunch
        [ Gulp
        , Make
        , Parcel
        , ShellScripts
        , Vite
        , Webpack
        , CreateElmApp
        , ElmLive
        , ElmMakeStandalone
        , ElmReactor
        , ElmWatch
        , ElmPages_
        , Lamdera__
        , ElmLand_
        , EsBuild
        , NoBuildTools
        ]


buildTools : Question BuildTools
buildTools =
    { title = "What tools do you use to build your Elm applications?"
    , choices = allBuildTools
    , choiceToString =
        \a ->
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
                    "elm-make standalone"

                Gulp ->
                    "Gulp"

                Make ->
                    "Make"

                ElmReactor ->
                    "elm-reactor"

                Parcel ->
                    "Parcel"

                Vite ->
                    "Vite"

                NoBuildTools ->
                    "None"

                ElmWatch ->
                    "elm-watch"

                ElmPages_ ->
                    "elm-pages"

                Lamdera__ ->
                    "Lamdera"

                ElmLand_ ->
                    "elm-land"

                EsBuild ->
                    "esbuild"
    }


allFrameworks : Nonempty Frameworks
allFrameworks =
    Nonempty Lamdera_ [ ElmPages, ElmPlayground, ElmSpa, ElmLand, NoFramework ]


frameworks : Question Frameworks
frameworks =
    { title = "What frameworks do you use?"
    , choices = allFrameworks
    , choiceToString =
        \a ->
            case a of
                Lamdera_ ->
                    "Lamdera"

                ElmSpa ->
                    "elm-spa"

                ElmPages ->
                    "elm-pages"

                ElmPlayground ->
                    "elm-playground"

                NoFramework ->
                    "None"

                ElmLand ->
                    "elm-land"
    }


allEditors : Nonempty Editors
allEditors =
    Nonempty Atom
        [ Emacs
        , Intellij
        , SublimeText
        , VSCode
        , Vim
        , NoEditor
        ]


editors : Question Editors
editors =
    { title = "What editor(s) do you use to write your Elm applications?"
    , choices = allEditors
    , choiceToString =
        \a ->
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

                NoEditor ->
                    "None"
    }


allDoYouUseElmReview : Nonempty DoYouUseElmReview
allDoYouUseElmReview =
    Nonempty NeverHeardOfElmReview
        [ HeardOfItButNeverTriedElmReview
        , IveTriedElmReview
        , IUseElmReviewRegularly
        ]


doYouUseElmReview : Question DoYouUseElmReview
doYouUseElmReview =
    { title = "Do you use elm-review?"
    , choices = allDoYouUseElmReview
    , choiceToString =
        \a ->
            case a of
                NeverHeardOfElmReview ->
                    "I've never heard of it"

                HeardOfItButNeverTriedElmReview ->
                    "I've heard of it but never tried it"

                IveTriedElmReview ->
                    "I use elm-review infrequently"

                IUseElmReviewRegularly ->
                    "I use elm-review regularly"
    }


allTestTools : Nonempty TestTools
allTestTools =
    Nonempty BrowserAcceptanceTests
        [ ElmBenchmark
        , ElmTest
        , ElmProgramTest
        , VisualRegressionTests
        , NoTestTools
        ]


testTools : Question TestTools
testTools =
    { title = "What tools do you use to test your Elm projects?"
    , choices = allTestTools
    , choiceToString =
        \a ->
            case a of
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

                NoTestTools ->
                    "None"
    }


biggestPainPointTitle : String
biggestPainPointTitle =
    "What has been your biggest pain point in your use of Elm?"


whatDoYouLikeMostTitle : String
whatDoYouLikeMostTitle =
    "What do you like the most about your use of Elm?"


surveyImprovementsTitle : String
surveyImprovementsTitle =
    "Do you have any comments or suggestions?"


whatPackagesDoYouUseTitle : String
whatPackagesDoYouUseTitle =
    "What packages do you use in your Elm apps?"
