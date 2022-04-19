module Form exposing (Form, FormMapping, emptyForm, formCodec, noMapping)

import AssocList as Dict exposing (Dict)
import AssocSet as Set exposing (Set)
import Countries exposing (Country)
import Questions
    exposing
        ( Age(..)
        , BuildTools(..)
        , DoYouUseElm(..)
        , DoYouUseElmAtWork(..)
        , DoYouUseElmFormat(..)
        , DoYouUseElmReview(..)
        , Editor(..)
        , ElmResources(..)
        , ExperienceLevel(..)
        , Frameworks(..)
        , HowLargeIsTheCompany(..)
        , HowLong(..)
        , NewsAndDiscussions(..)
        , OtherLanguages(..)
        , StylingTools(..)
        , TestTools(..)
        , TestsWrittenFor(..)
        , WhatElmVersion(..)
        , WhatLanguageDoYouUseForTheBackend(..)
        , WhereDoYouUseElm(..)
        , WhichElmReviewRulesDoYouUse(..)
        )
import Serialize exposing (Codec)
import Ui exposing (MultiChoiceWithOther)


type alias Form =
    { doYouUseElm : Set DoYouUseElm
    , age : Maybe Age
    , functionalProgrammingExperience : Maybe ExperienceLevel
    , otherLanguages : MultiChoiceWithOther OtherLanguages
    , newsAndDiscussions : MultiChoiceWithOther NewsAndDiscussions
    , elmResources : MultiChoiceWithOther ElmResources
    , countryLivingIn : Maybe Country
    , applicationDomains : MultiChoiceWithOther WhereDoYouUseElm
    , doYouUseElmAtWork : Maybe DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : MultiChoiceWithOther WhatLanguageDoYouUseForTheBackend
    , howLong : Maybe HowLong
    , elmVersion : MultiChoiceWithOther WhatElmVersion
    , doYouUseElmFormat : Maybe DoYouUseElmFormat
    , stylingTools : MultiChoiceWithOther StylingTools
    , buildTools : MultiChoiceWithOther BuildTools
    , frameworks : MultiChoiceWithOther Frameworks
    , editors : MultiChoiceWithOther Editor
    , doYouUseElmReview : Maybe DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : MultiChoiceWithOther WhichElmReviewRulesDoYouUse
    , testTools : MultiChoiceWithOther TestTools
    , testsWrittenFor : MultiChoiceWithOther TestsWrittenFor
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
    , emailAddress : String
    }


type alias FormMapping =
    { otherLanguages : Dict String String
    , newsAndDiscussions : Dict String String
    , elmResources : Dict String String
    , applicationDomains : Dict String String
    , whatLanguageDoYouUseForBackend : Dict String String
    , elmVersion : Dict String String
    , stylingTools : Dict String String
    , buildTools : Dict String String
    , frameworks : Dict String String
    , editors : Dict String String
    , whichElmReviewRulesDoYouUse : Dict String String
    , testTools : Dict String String
    , testsWrittenFor : Dict String String
    , elmInitialInterest : Dict String String
    , biggestPainPoint : Dict String String
    , whatDoYouLikeMost : Dict String String
    }


emptyForm : Form
emptyForm =
    { doYouUseElm = Set.empty
    , age = Nothing
    , functionalProgrammingExperience = Nothing
    , otherLanguages = Ui.multiChoiceWithOtherInit
    , newsAndDiscussions = Ui.multiChoiceWithOtherInit
    , elmResources = Ui.multiChoiceWithOtherInit
    , countryLivingIn = Nothing
    , applicationDomains = Ui.multiChoiceWithOtherInit
    , doYouUseElmAtWork = Nothing
    , howLargeIsTheCompany = Nothing
    , whatLanguageDoYouUseForBackend = Ui.multiChoiceWithOtherInit
    , howLong = Nothing
    , elmVersion = Ui.multiChoiceWithOtherInit
    , doYouUseElmFormat = Nothing
    , stylingTools = Ui.multiChoiceWithOtherInit
    , buildTools = Ui.multiChoiceWithOtherInit
    , frameworks = Ui.multiChoiceWithOtherInit
    , editors = Ui.multiChoiceWithOtherInit
    , doYouUseElmReview = Nothing
    , whichElmReviewRulesDoYouUse = Ui.multiChoiceWithOtherInit
    , testTools = Ui.multiChoiceWithOtherInit
    , testsWrittenFor = Ui.multiChoiceWithOtherInit
    , elmInitialInterest = ""
    , biggestPainPoint = ""
    , whatDoYouLikeMost = ""
    , emailAddress = ""
    }


noMapping : FormMapping
noMapping =
    { otherLanguages = Dict.empty
    , newsAndDiscussions = Dict.empty
    , elmResources = Dict.empty
    , applicationDomains = Dict.empty
    , whatLanguageDoYouUseForBackend = Dict.empty
    , elmVersion = Dict.empty
    , stylingTools = Dict.empty
    , buildTools = Dict.empty
    , frameworks = Dict.empty
    , editors = Dict.empty
    , whichElmReviewRulesDoYouUse = Dict.empty
    , testTools = Dict.empty
    , testsWrittenFor = Dict.empty
    , elmInitialInterest = Dict.empty
    , biggestPainPoint = Dict.empty
    , whatDoYouLikeMost = Dict.empty
    }


formCodec : Codec e Form
formCodec =
    Serialize.record Form
        |> Serialize.field .doYouUseElm (assocSetCodec doYouUseElmCodec)
        |> Serialize.field .age (Serialize.maybe ageCodec)
        |> Serialize.field .functionalProgrammingExperience (Serialize.maybe experienceLevelCodec)
        |> Serialize.field .otherLanguages (multiChoiceWithOtherCodec otherLanguagesCodec)
        |> Serialize.field .newsAndDiscussions (multiChoiceWithOtherCodec newsAndDiscussionsCodec)
        |> Serialize.field .elmResources (multiChoiceWithOtherCodec elmResourcesCodec)
        |> Serialize.field .countryLivingIn (Serialize.maybe countryCodec)
        |> Serialize.field .applicationDomains (multiChoiceWithOtherCodec whereDoYouUseElmCodec)
        |> Serialize.field .doYouUseElmAtWork (Serialize.maybe doYouUseElmAtWorkCodec)
        |> Serialize.field .howLargeIsTheCompany (Serialize.maybe howLargeIsTheCompanyCodec)
        |> Serialize.field
            .whatLanguageDoYouUseForBackend
            (multiChoiceWithOtherCodec whatLanguageDoYouUseForTheBackendCodec)
        |> Serialize.field .howLong (Serialize.maybe howLongCodec)
        |> Serialize.field .elmVersion (multiChoiceWithOtherCodec whatElmVersionCodec)
        |> Serialize.field .doYouUseElmFormat (Serialize.maybe doYouUseElmFormatCodec)
        |> Serialize.field .stylingTools (multiChoiceWithOtherCodec stylingToolsCodec)
        |> Serialize.field .buildTools (multiChoiceWithOtherCodec buildToolsCodec)
        |> Serialize.field .frameworks (multiChoiceWithOtherCodec frameworksCodec)
        |> Serialize.field .editors (multiChoiceWithOtherCodec editorCodec)
        |> Serialize.field .doYouUseElmReview (Serialize.maybe doYouUseElmReviewCodec)
        |> Serialize.field .whichElmReviewRulesDoYouUse (multiChoiceWithOtherCodec whichElmReviewRulesDoYouUseCodec)
        |> Serialize.field .testTools (multiChoiceWithOtherCodec testToolsCodec)
        |> Serialize.field .testsWrittenFor (multiChoiceWithOtherCodec testsWrittenForCodec)
        |> Serialize.field .elmInitialInterest Serialize.string
        |> Serialize.field .biggestPainPoint Serialize.string
        |> Serialize.field .whatDoYouLikeMost Serialize.string
        |> Serialize.field .emailAddress Serialize.string
        |> Serialize.finishRecord


countryCodec : Codec e Country
countryCodec =
    Serialize.record Country
        |> Serialize.field .name Serialize.string
        |> Serialize.field .code Serialize.string
        |> Serialize.field .flag Serialize.string
        |> Serialize.finishRecord


testsWrittenForCodec : Codec e TestsWrittenFor
testsWrittenForCodec =
    Serialize.customType
        (\a b c d e f value ->
            case value of
                ComplicatedFunctions ->
                    a

                FunctionsThatReturnCmds ->
                    b

                AllPublicFunctions ->
                    c

                HtmlFunctions ->
                    d

                JsonDecodersAndEncoders ->
                    e

                MostPublicFunctions ->
                    f
        )
        |> Serialize.variant0 ComplicatedFunctions
        |> Serialize.variant0 FunctionsThatReturnCmds
        |> Serialize.variant0 AllPublicFunctions
        |> Serialize.variant0 HtmlFunctions
        |> Serialize.variant0 JsonDecodersAndEncoders
        |> Serialize.variant0 MostPublicFunctions
        |> Serialize.finishCustomType


testToolsCodec : Codec e TestTools
testToolsCodec =
    Serialize.customType
        (\a b c d e value ->
            case value of
                BrowserAcceptanceTests ->
                    a

                ElmBenchmark ->
                    b

                ElmTest ->
                    c

                ElmProgramTest ->
                    d

                VisualRegressionTests ->
                    e
        )
        |> Serialize.variant0 BrowserAcceptanceTests
        |> Serialize.variant0 ElmBenchmark
        |> Serialize.variant0 ElmTest
        |> Serialize.variant0 ElmProgramTest
        |> Serialize.variant0 VisualRegressionTests
        |> Serialize.finishCustomType


whichElmReviewRulesDoYouUseCodec : Codec e WhichElmReviewRulesDoYouUse
whichElmReviewRulesDoYouUseCodec =
    Serialize.customType
        (\a b c d e f value ->
            case value of
                ElmReviewUnused ->
                    a

                ElmReviewSimplify ->
                    b

                ElmReviewLicense ->
                    c

                ElmReviewDebug ->
                    d

                ElmReviewCommon ->
                    e

                ElmReviewCognitiveComplexity ->
                    f
        )
        |> Serialize.variant0 ElmReviewUnused
        |> Serialize.variant0 ElmReviewSimplify
        |> Serialize.variant0 ElmReviewLicense
        |> Serialize.variant0 ElmReviewDebug
        |> Serialize.variant0 ElmReviewCommon
        |> Serialize.variant0 ElmReviewCognitiveComplexity
        |> Serialize.finishCustomType


doYouUseElmReviewCodec : Codec e DoYouUseElmReview
doYouUseElmReviewCodec =
    Serialize.customType
        (\a b c d value ->
            case value of
                NeverHeardOfElmReview ->
                    a

                HeardOfItButNeverTriedElmReview ->
                    b

                IveTriedElmReview ->
                    c

                IUseElmReviewRegularly ->
                    d
        )
        |> Serialize.variant0 NeverHeardOfElmReview
        |> Serialize.variant0 HeardOfItButNeverTriedElmReview
        |> Serialize.variant0 IveTriedElmReview
        |> Serialize.variant0 IUseElmReviewRegularly
        |> Serialize.finishCustomType


editorCodec : Codec e Editor
editorCodec =
    Serialize.customType
        (\a b c d e f value ->
            case value of
                SublimeText ->
                    a

                Vim ->
                    b

                Atom ->
                    c

                Emacs ->
                    d

                VSCode ->
                    e

                Intellij ->
                    f
        )
        |> Serialize.variant0 SublimeText
        |> Serialize.variant0 Vim
        |> Serialize.variant0 Atom
        |> Serialize.variant0 Emacs
        |> Serialize.variant0 VSCode
        |> Serialize.variant0 Intellij
        |> Serialize.finishCustomType


frameworksCodec : Codec e Frameworks
frameworksCodec =
    Serialize.customType
        (\a b c d value ->
            case value of
                Lamdera_ ->
                    a

                ElmSpa ->
                    b

                ElmPages ->
                    c

                ElmPlayground ->
                    d
        )
        |> Serialize.variant0 Lamdera_
        |> Serialize.variant0 ElmSpa
        |> Serialize.variant0 ElmPages
        |> Serialize.variant0 ElmPlayground
        |> Serialize.finishCustomType


buildToolsCodec : Codec e BuildTools
buildToolsCodec =
    Serialize.customType
        (\a b c d e f g h i j k value ->
            case value of
                ShellScripts ->
                    a

                ElmLive ->
                    b

                CreateElmApp ->
                    c

                Webpack ->
                    d

                Brunch ->
                    e

                ElmMakeStandalone ->
                    f

                Gulp ->
                    g

                Make ->
                    h

                ElmReactor ->
                    i

                Parcel ->
                    j

                Vite ->
                    k
        )
        |> Serialize.variant0 ShellScripts
        |> Serialize.variant0 ElmLive
        |> Serialize.variant0 CreateElmApp
        |> Serialize.variant0 Webpack
        |> Serialize.variant0 Brunch
        |> Serialize.variant0 ElmMakeStandalone
        |> Serialize.variant0 Gulp
        |> Serialize.variant0 Make
        |> Serialize.variant0 ElmReactor
        |> Serialize.variant0 Parcel
        |> Serialize.variant0 Vite
        |> Serialize.finishCustomType


stylingToolsCodec : Codec e StylingTools
stylingToolsCodec =
    Serialize.customType
        (\a b c d e f g value ->
            case value of
                SassOrScss ->
                    a

                ElmCss ->
                    b

                PlainCss ->
                    c

                ElmUi ->
                    d

                Tailwind ->
                    e

                ElmTailwindModules ->
                    f

                Bootstrap ->
                    g
        )
        |> Serialize.variant0 SassOrScss
        |> Serialize.variant0 ElmCss
        |> Serialize.variant0 PlainCss
        |> Serialize.variant0 ElmUi
        |> Serialize.variant0 Tailwind
        |> Serialize.variant0 ElmTailwindModules
        |> Serialize.variant0 Bootstrap
        |> Serialize.finishCustomType


doYouUseElmFormatCodec : Codec e DoYouUseElmFormat
doYouUseElmFormatCodec =
    Serialize.customType
        (\a b c d value ->
            case value of
                PreferElmFormat ->
                    a

                TriedButDontUseElmFormat ->
                    b

                HeardButDontUseElmFormat ->
                    c

                HaveNotHeardOfElmFormat ->
                    d
        )
        |> Serialize.variant0 PreferElmFormat
        |> Serialize.variant0 TriedButDontUseElmFormat
        |> Serialize.variant0 HeardButDontUseElmFormat
        |> Serialize.variant0 HaveNotHeardOfElmFormat
        |> Serialize.finishCustomType


whatElmVersionCodec : Codec e WhatElmVersion
whatElmVersionCodec =
    Serialize.customType
        (\a b c d value ->
            case value of
                Version0_19 ->
                    a

                Version0_18 ->
                    b

                Version0_17 ->
                    c

                Version0_16 ->
                    d
        )
        |> Serialize.variant0 Version0_19
        |> Serialize.variant0 Version0_18
        |> Serialize.variant0 Version0_17
        |> Serialize.variant0 Version0_16
        |> Serialize.finishCustomType


howLongCodec : Codec e HowLong
howLongCodec =
    Serialize.customType
        (\a b c d e f g h i j k value ->
            case value of
                Under3Months ->
                    a

                Between3MonthsAndAYear ->
                    b

                OneYear ->
                    c

                TwoYears ->
                    d

                ThreeYears ->
                    e

                FourYears ->
                    f

                FiveYears ->
                    g

                SixYears ->
                    h

                SevenYears ->
                    i

                EightYears ->
                    j

                NineYears ->
                    k
        )
        |> Serialize.variant0 Under3Months
        |> Serialize.variant0 Between3MonthsAndAYear
        |> Serialize.variant0 OneYear
        |> Serialize.variant0 TwoYears
        |> Serialize.variant0 ThreeYears
        |> Serialize.variant0 FourYears
        |> Serialize.variant0 FiveYears
        |> Serialize.variant0 SixYears
        |> Serialize.variant0 SevenYears
        |> Serialize.variant0 EightYears
        |> Serialize.variant0 NineYears
        |> Serialize.finishCustomType


whatLanguageDoYouUseForTheBackendCodec : Codec e WhatLanguageDoYouUseForTheBackend
whatLanguageDoYouUseForTheBackendCodec =
    Serialize.customType
        (\a b c d e f g h i j k l m n o p value ->
            case value of
                JavaScript_ ->
                    a

                TypeScript_ ->
                    b

                Go_ ->
                    c

                Haskell_ ->
                    d

                CSharp_ ->
                    e

                OCaml_ ->
                    f

                Python_ ->
                    g

                PHP_ ->
                    h

                Java_ ->
                    i

                Ruby_ ->
                    j

                Elixir_ ->
                    k

                Clojure_ ->
                    l

                Rust_ ->
                    m

                FSharp_ ->
                    n

                AlsoElm ->
                    o

                NotApplicable ->
                    p
        )
        |> Serialize.variant0 JavaScript_
        |> Serialize.variant0 TypeScript_
        |> Serialize.variant0 Go_
        |> Serialize.variant0 Haskell_
        |> Serialize.variant0 CSharp_
        |> Serialize.variant0 OCaml_
        |> Serialize.variant0 Python_
        |> Serialize.variant0 PHP_
        |> Serialize.variant0 Java_
        |> Serialize.variant0 Ruby_
        |> Serialize.variant0 Elixir_
        |> Serialize.variant0 Clojure_
        |> Serialize.variant0 Rust_
        |> Serialize.variant0 FSharp_
        |> Serialize.variant0 AlsoElm
        |> Serialize.variant0 NotApplicable
        |> Serialize.finishCustomType


howLargeIsTheCompanyCodec : Codec e HowLargeIsTheCompany
howLargeIsTheCompanyCodec =
    Serialize.customType
        (\a b c d value ->
            case value of
                Size1To10Employees ->
                    a

                Size11To50Employees ->
                    b

                Size50To100Employees ->
                    c

                Size100OrMore ->
                    d
        )
        |> Serialize.variant0 Size1To10Employees
        |> Serialize.variant0 Size11To50Employees
        |> Serialize.variant0 Size50To100Employees
        |> Serialize.variant0 Size100OrMore
        |> Serialize.finishCustomType


doYouUseElmAtWorkCodec : Codec e DoYouUseElmAtWork
doYouUseElmAtWorkCodec =
    Serialize.customType
        (\a b c d e value ->
            case value of
                NotInterestedInElmAtWork ->
                    a

                WouldLikeToUseElmAtWork ->
                    b

                HaveTriedElmInAWorkProject ->
                    c

                MyTeamMostlyWritesNewCodeInElm ->
                    d

                NotEmployed ->
                    e
        )
        |> Serialize.variant0 NotInterestedInElmAtWork
        |> Serialize.variant0 WouldLikeToUseElmAtWork
        |> Serialize.variant0 HaveTriedElmInAWorkProject
        |> Serialize.variant0 MyTeamMostlyWritesNewCodeInElm
        |> Serialize.variant0 NotEmployed
        |> Serialize.finishCustomType


whereDoYouUseElmCodec : Codec e WhereDoYouUseElm
whereDoYouUseElmCodec =
    Serialize.customType
        (\a b c d e f g h i j value ->
            case value of
                Education ->
                    a

                Gaming ->
                    b

                ECommerce ->
                    c

                Music ->
                    d

                Finance ->
                    e

                Health ->
                    f

                Productivity ->
                    g

                Communication ->
                    h

                DataVisualization ->
                    i

                Transportation ->
                    j
        )
        |> Serialize.variant0 Education
        |> Serialize.variant0 Gaming
        |> Serialize.variant0 ECommerce
        |> Serialize.variant0 Music
        |> Serialize.variant0 Finance
        |> Serialize.variant0 Health
        |> Serialize.variant0 Productivity
        |> Serialize.variant0 Communication
        |> Serialize.variant0 DataVisualization
        |> Serialize.variant0 Transportation
        |> Serialize.finishCustomType


elmResourcesCodec : Codec e ElmResources
elmResourcesCodec =
    Serialize.customType
        (\a b c d e f g h i j k l m n value ->
            case value of
                DailyDrip ->
                    a

                ElmInActionBook ->
                    b

                WeeklyBeginnersElmSubreddit ->
                    c

                BeginningElmBook ->
                    d

                StackOverflow ->
                    e

                BuildingWebAppsWithElm ->
                    f

                TheJsonSurvivalKit ->
                    g

                EggheadCourses ->
                    h

                ProgrammingElmBook ->
                    i

                GuideElmLang ->
                    j

                ElmForBeginners ->
                    k

                ElmSlack_ ->
                    l

                FrontendMasters ->
                    m

                ElmOnline ->
                    n
        )
        |> Serialize.variant0 DailyDrip
        |> Serialize.variant0 ElmInActionBook
        |> Serialize.variant0 WeeklyBeginnersElmSubreddit
        |> Serialize.variant0 BeginningElmBook
        |> Serialize.variant0 StackOverflow
        |> Serialize.variant0 BuildingWebAppsWithElm
        |> Serialize.variant0 TheJsonSurvivalKit
        |> Serialize.variant0 EggheadCourses
        |> Serialize.variant0 ProgrammingElmBook
        |> Serialize.variant0 GuideElmLang
        |> Serialize.variant0 ElmForBeginners
        |> Serialize.variant0 ElmSlack_
        |> Serialize.variant0 FrontendMasters
        |> Serialize.variant0 ElmOnline
        |> Serialize.finishCustomType


newsAndDiscussionsCodec : Codec e NewsAndDiscussions
newsAndDiscussionsCodec =
    Serialize.customType
        (\a b c d e f g h i j k l value ->
            case value of
                ElmDiscourse ->
                    a

                ElmSlack ->
                    b

                ElmSubreddit ->
                    c

                Twitter ->
                    d

                ElmRadio ->
                    e

                BlogPosts ->
                    f

                Facebook ->
                    g

                DevTo ->
                    h

                Meetups ->
                    i

                ElmWeekly ->
                    j

                ElmNews ->
                    k

                ElmCraft ->
                    l
        )
        |> Serialize.variant0 ElmDiscourse
        |> Serialize.variant0 ElmSlack
        |> Serialize.variant0 ElmSubreddit
        |> Serialize.variant0 Twitter
        |> Serialize.variant0 ElmRadio
        |> Serialize.variant0 BlogPosts
        |> Serialize.variant0 Facebook
        |> Serialize.variant0 DevTo
        |> Serialize.variant0 Meetups
        |> Serialize.variant0 ElmWeekly
        |> Serialize.variant0 ElmNews
        |> Serialize.variant0 ElmCraft
        |> Serialize.finishCustomType


otherLanguagesCodec : Codec e OtherLanguages
otherLanguagesCodec =
    Serialize.customType
        (\a b c d e f g h i j k l m n o p q value ->
            case value of
                JavaScript ->
                    a

                TypeScript ->
                    b

                Go ->
                    c

                Haskell ->
                    d

                CSharp ->
                    e

                C ->
                    f

                CPlusPlus ->
                    g

                OCaml ->
                    h

                Python ->
                    i

                Swift ->
                    j

                PHP ->
                    k

                Java ->
                    l

                Ruby ->
                    m

                Elixir ->
                    n

                Clojure ->
                    o

                Rust ->
                    p

                FSharp ->
                    q
        )
        |> Serialize.variant0 JavaScript
        |> Serialize.variant0 TypeScript
        |> Serialize.variant0 Go
        |> Serialize.variant0 Haskell
        |> Serialize.variant0 CSharp
        |> Serialize.variant0 C
        |> Serialize.variant0 CPlusPlus
        |> Serialize.variant0 OCaml
        |> Serialize.variant0 Python
        |> Serialize.variant0 Swift
        |> Serialize.variant0 PHP
        |> Serialize.variant0 Java
        |> Serialize.variant0 Ruby
        |> Serialize.variant0 Elixir
        |> Serialize.variant0 Clojure
        |> Serialize.variant0 Rust
        |> Serialize.variant0 FSharp
        |> Serialize.finishCustomType


multiChoiceWithOtherCodec : Codec e a -> Codec e (MultiChoiceWithOther a)
multiChoiceWithOtherCodec codec =
    Serialize.record MultiChoiceWithOther
        |> Serialize.field .choices (assocSetCodec codec)
        |> Serialize.field .otherChecked Serialize.bool
        |> Serialize.field .otherText Serialize.string
        |> Serialize.finishRecord


assocSetCodec : Codec e a -> Codec e (Set a)
assocSetCodec codec =
    Serialize.list codec |> Serialize.map Set.fromList Set.toList


experienceLevelCodec : Codec e ExperienceLevel
experienceLevelCodec =
    Serialize.customType
        (\a b c d value ->
            case value of
                Beginner ->
                    a

                Intermediate ->
                    b

                Professional ->
                    c

                Expert ->
                    d
        )
        |> Serialize.variant0 Beginner
        |> Serialize.variant0 Intermediate
        |> Serialize.variant0 Professional
        |> Serialize.variant0 Expert
        |> Serialize.finishCustomType


ageCodec : Codec e Age
ageCodec =
    Serialize.customType
        (\a b c d e f g value ->
            case value of
                Under10 ->
                    a

                Age10To19 ->
                    b

                Age20To29 ->
                    c

                Age30To39 ->
                    d

                Age40To49 ->
                    e

                Age50To59 ->
                    f

                Over60 ->
                    g
        )
        |> Serialize.variant0 Under10
        |> Serialize.variant0 Age10To19
        |> Serialize.variant0 Age20To29
        |> Serialize.variant0 Age30To39
        |> Serialize.variant0 Age40To49
        |> Serialize.variant0 Age50To59
        |> Serialize.variant0 Over60
        |> Serialize.finishCustomType


doYouUseElmCodec : Codec e DoYouUseElm
doYouUseElmCodec =
    Serialize.customType
        (\a b c d e f value ->
            case value of
                YesAtWork ->
                    a

                YesInSideProjects ->
                    b

                YesAsAStudent ->
                    c

                IUsedToButIDontAnymore ->
                    d

                NoButImCuriousAboutIt ->
                    e

                NoAndIDontPlanTo ->
                    f
        )
        |> Serialize.variant0 YesAtWork
        |> Serialize.variant0 YesInSideProjects
        |> Serialize.variant0 YesAsAStudent
        |> Serialize.variant0 IUsedToButIDontAnymore
        |> Serialize.variant0 NoButImCuriousAboutIt
        |> Serialize.variant0 NoAndIDontPlanTo
        |> Serialize.finishCustomType
