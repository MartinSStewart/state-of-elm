module Form2023 exposing
    ( Form2023
    , FormMapping
    , SpecificQuestion(..)
    , doesNotUseElm
    , emptyForm
    , formCodec
    , formMappingCodec
    , getOtherAnswer
    , getOtherAnswer_
    , notInterestedInElm
    )

import AnswerMap exposing (AnswerMap)
import AssocSet as Set exposing (Set)
import Countries exposing (Country)
import FreeTextAnswerMap exposing (FreeTextAnswerMap)
import PackageName exposing (PackageName)
import Questions2023 exposing (Age(..), ApplicationDomains(..), BuildTools(..), DoYouUseElm(..), DoYouUseElmAtWork(..), DoYouUseElmFormat(..), DoYouUseElmReview(..), Editors(..), ElmResources(..), ElmVersion(..), ExperienceLevel(..), Frameworks(..), HowLargeIsTheCompany(..), HowLong(..), NewsAndDiscussions(..), OtherLanguages(..), PleaseSelectYourGender, StylingTools(..), TestTools(..), WhatLanguageDoYouUseForBackend(..))
import Serialize exposing (Codec)
import Ui exposing (MultiChoiceWithOther)


type alias Form2023 =
    { doYouUseElm : Set DoYouUseElm
    , age : Maybe Age
    , pleaseSelectYourGender : Maybe PleaseSelectYourGender
    , functionalProgrammingExperience : Maybe ExperienceLevel
    , otherLanguages : MultiChoiceWithOther OtherLanguages
    , newsAndDiscussions : MultiChoiceWithOther NewsAndDiscussions
    , elmResources : MultiChoiceWithOther ElmResources
    , countryLivingIn : Maybe Country
    , applicationDomains : MultiChoiceWithOther ApplicationDomains
    , doYouUseElmAtWork : Maybe DoYouUseElmAtWork
    , howLargeIsTheCompany : Maybe HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : MultiChoiceWithOther WhatLanguageDoYouUseForBackend
    , howLong : Maybe HowLong
    , elmVersion : MultiChoiceWithOther ElmVersion
    , doYouUseElmFormat : Maybe DoYouUseElmFormat
    , stylingTools : MultiChoiceWithOther StylingTools
    , buildTools : MultiChoiceWithOther BuildTools
    , frameworks : MultiChoiceWithOther Frameworks
    , editors : MultiChoiceWithOther Editors
    , doYouUseElmReview : Maybe DoYouUseElmReview
    , testTools : MultiChoiceWithOther TestTools
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
    , emailAddress : String
    , elmJson : List (List PackageName)
    }


doesNotUseElm : Form2023 -> Bool
doesNotUseElm form =
    Set.member NoButImCuriousAboutIt form.doYouUseElm
        || Set.member NoAndIDontPlanTo form.doYouUseElm


notInterestedInElm : Form2023 -> Bool
notInterestedInElm form =
    Set.member NoAndIDontPlanTo form.doYouUseElm


getOtherAnswer : MultiChoiceWithOther a -> Maybe String
getOtherAnswer multiChoiceWithOther =
    if multiChoiceWithOther.otherChecked && String.trim multiChoiceWithOther.otherText /= "" then
        String.trim multiChoiceWithOther.otherText |> Just

    else
        Nothing


getOtherAnswer_ : String -> Maybe String
getOtherAnswer_ text =
    if String.trim text /= "" then
        String.trim text |> Just

    else
        Nothing


type alias FormMapping =
    { doYouUseElm : String
    , age : String
    , pleaseSelectYourGender : String
    , functionalProgrammingExperience : String
    , otherLanguages : AnswerMap OtherLanguages
    , newsAndDiscussions : AnswerMap NewsAndDiscussions
    , elmResources : AnswerMap ElmResources
    , countryLivingIn : String
    , applicationDomains : AnswerMap ApplicationDomains
    , doYouUseElmAtWork : String
    , howLargeIsTheCompany : String
    , whatLanguageDoYouUseForBackend : AnswerMap WhatLanguageDoYouUseForBackend
    , howLong : String
    , elmVersion : AnswerMap ElmVersion
    , doYouUseElmFormat : String
    , stylingTools : AnswerMap StylingTools
    , buildTools : AnswerMap BuildTools
    , frameworks : AnswerMap Frameworks
    , editors : AnswerMap Editors
    , doYouUseElmReview : String
    , testTools : AnswerMap TestTools
    , elmInitialInterest : FreeTextAnswerMap
    , biggestPainPoint : FreeTextAnswerMap
    , whatDoYouLikeMost : FreeTextAnswerMap
    }


emptyForm : Form2023
emptyForm =
    { doYouUseElm = Set.empty
    , age = Nothing
    , pleaseSelectYourGender = Nothing
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
    , testTools = Ui.multiChoiceWithOtherInit
    , elmInitialInterest = ""
    , biggestPainPoint = ""
    , whatDoYouLikeMost = ""
    , emailAddress = ""
    , elmJson = []
    }


type SpecificQuestion
    = DoYouUseElmQuestion
    | AgeQuestion
    | PleaseSelectYourGenderQuestion
    | FunctionalProgrammingExperienceQuestion
    | OtherLanguagesQuestion
    | NewsAndDiscussionsQuestion
    | ElmResourcesQuestion
    | CountryLivingInQuestion
    | ApplicationDomainsQuestion
    | DoYouUseElmAtWorkQuestion
    | HowLargeIsTheCompanyQuestion
    | WhatLanguageDoYouUseForBackendQuestion
    | HowLongQuestion
    | ElmVersionQuestion
    | DoYouUseElmFormatQuestion
    | StylingToolsQuestion
    | BuildToolsQuestion
    | FrameworksQuestion
    | EditorsQuestion
    | DoYouUseElmReviewQuestion
    | TestToolsQuestion
    | ElmInitialInterestQuestion
    | BiggestPainPointQuestion
    | WhatDoYouLikeMostQuestion


formMappingCodec : Codec e FormMapping
formMappingCodec =
    Serialize.record FormMapping
        |> Serialize.field .doYouUseElm Serialize.string
        |> Serialize.field .age Serialize.string
        |> Serialize.field .pleaseSelectYourGender Serialize.string
        |> Serialize.field .functionalProgrammingExperience Serialize.string
        |> Serialize.field .otherLanguages AnswerMap.codec
        |> Serialize.field .newsAndDiscussions AnswerMap.codec
        |> Serialize.field .elmResources AnswerMap.codec
        |> Serialize.field .countryLivingIn Serialize.string
        |> Serialize.field .applicationDomains AnswerMap.codec
        |> Serialize.field .doYouUseElmAtWork Serialize.string
        |> Serialize.field .howLargeIsTheCompany Serialize.string
        |> Serialize.field .whatLanguageDoYouUseForBackend AnswerMap.codec
        |> Serialize.field .howLong Serialize.string
        |> Serialize.field .elmVersion AnswerMap.codec
        |> Serialize.field .doYouUseElmFormat Serialize.string
        |> Serialize.field .stylingTools AnswerMap.codec
        |> Serialize.field .buildTools AnswerMap.codec
        |> Serialize.field .frameworks AnswerMap.codec
        |> Serialize.field .editors AnswerMap.codec
        |> Serialize.field .doYouUseElmReview Serialize.string
        |> Serialize.field .testTools AnswerMap.codec
        |> Serialize.field .elmInitialInterest FreeTextAnswerMap.codec
        |> Serialize.field .biggestPainPoint FreeTextAnswerMap.codec
        |> Serialize.field .whatDoYouLikeMost FreeTextAnswerMap.codec
        |> Serialize.finishRecord


formCodec : Codec e Form2023
formCodec =
    Serialize.record Form2023
        |> Serialize.field .doYouUseElm (assocSetCodec doYouUseElmCodec)
        |> Serialize.field .age (Serialize.maybe ageCodec)
        |> Serialize.field .pleaseSelectYourGender (Serialize.maybe pleaseSelectYourGender)
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
        |> Serialize.field .testTools (multiChoiceWithOtherCodec testToolsCodec)
        |> Serialize.field .elmInitialInterest Serialize.string
        |> Serialize.field .biggestPainPoint Serialize.string
        |> Serialize.field .whatDoYouLikeMost Serialize.string
        |> Serialize.field .emailAddress Serialize.string
        |> Serialize.field .elmJson (Serialize.list (Serialize.list PackageName.codec))
        |> Serialize.finishRecord


countryCodec : Codec e Country
countryCodec =
    Serialize.record Country
        |> Serialize.field .name Serialize.string
        |> Serialize.field .code Serialize.string
        |> Serialize.field .flag Serialize.string
        |> Serialize.finishRecord


testToolsCodec : Codec e TestTools
testToolsCodec =
    Serialize.customType
        (\a b c d e f value ->
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

                NoTestTools ->
                    f
        )
        |> Serialize.variant0 BrowserAcceptanceTests
        |> Serialize.variant0 ElmBenchmark
        |> Serialize.variant0 ElmTest
        |> Serialize.variant0 ElmProgramTest
        |> Serialize.variant0 VisualRegressionTests
        |> Serialize.variant0 NoTestTools
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


editorCodec : Codec e Editors
editorCodec =
    Serialize.customType
        (\a b c d e f g value ->
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

                NoEditor ->
                    g
        )
        |> Serialize.variant0 SublimeText
        |> Serialize.variant0 Vim
        |> Serialize.variant0 Atom
        |> Serialize.variant0 Emacs
        |> Serialize.variant0 VSCode
        |> Serialize.variant0 Intellij
        |> Serialize.variant0 NoEditor
        |> Serialize.finishCustomType


frameworksCodec : Codec e Frameworks
frameworksCodec =
    Serialize.customType
        (\a b c d e f value ->
            case value of
                Lamdera_ ->
                    a

                ElmSpa ->
                    b

                ElmPages ->
                    c

                ElmPlayground ->
                    d

                NoFramework ->
                    e

                ElmLand ->
                    f
        )
        |> Serialize.variant0 Lamdera_
        |> Serialize.variant0 ElmSpa
        |> Serialize.variant0 ElmPages
        |> Serialize.variant0 ElmPlayground
        |> Serialize.variant0 NoFramework
        |> Serialize.variant0 ElmLand
        |> Serialize.finishCustomType


buildToolsCodec : Codec e BuildTools
buildToolsCodec =
    Serialize.customType
        (\a b c d e f g h i j k l value ->
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

                NoBuildTools ->
                    l
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
        |> Serialize.variant0 NoBuildTools
        |> Serialize.finishCustomType


stylingToolsCodec : Codec e StylingTools
stylingToolsCodec =
    Serialize.customType
        (\a b c d e f g h value ->
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

                NoStylingTools ->
                    h
        )
        |> Serialize.variant0 SassOrScss
        |> Serialize.variant0 ElmCss
        |> Serialize.variant0 PlainCss
        |> Serialize.variant0 ElmUi
        |> Serialize.variant0 Tailwind
        |> Serialize.variant0 ElmTailwindModules
        |> Serialize.variant0 Bootstrap
        |> Serialize.variant0 NoStylingTools
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


whatElmVersionCodec : Codec e ElmVersion
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
        (\a b c d e f g h i j k l value ->
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

                TenYears ->
                    l
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
        |> Serialize.variant0 TenYears
        |> Serialize.finishCustomType


whatLanguageDoYouUseForTheBackendCodec : Codec e WhatLanguageDoYouUseForBackend
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


whereDoYouUseElmCodec : Codec e ApplicationDomains
whereDoYouUseElmCodec =
    Serialize.customType
        (\a b c d e f g h i j k value ->
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

                NoApplicationDomains ->
                    k
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
        |> Serialize.variant0 NoApplicationDomains
        |> Serialize.finishCustomType


elmResourcesCodec : Codec e ElmResources
elmResourcesCodec =
    Serialize.customType
        (\a b c d e f g h i j k l m n o value ->
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

                NoElmResources ->
                    o
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
        |> Serialize.variant0 NoElmResources
        |> Serialize.finishCustomType


newsAndDiscussionsCodec : Codec e NewsAndDiscussions
newsAndDiscussionsCodec =
    Serialize.customType
        (\a b c d e f g h i j k l m value ->
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

                NoNewsOrDiscussions ->
                    m
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
        |> Serialize.variant0 NoNewsOrDiscussions
        |> Serialize.finishCustomType


otherLanguagesCodec : Codec e OtherLanguages
otherLanguagesCodec =
    Serialize.customType
        (\a b c d e f g h i j k l m n o p q r value ->
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

                NoOtherLanguage ->
                    r
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
        |> Serialize.variant0 NoOtherLanguage
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
        (\a b c d e f g h value ->
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

                PreferNotToAnswer2 ->
                    h
        )
        |> Serialize.variant0 Under10
        |> Serialize.variant0 Age10To19
        |> Serialize.variant0 Age20To29
        |> Serialize.variant0 Age30To39
        |> Serialize.variant0 Age40To49
        |> Serialize.variant0 Age50To59
        |> Serialize.variant0 Over60
        |> Serialize.variant0 PreferNotToAnswer2
        |> Serialize.finishCustomType


pleaseSelectYourGender : Codec e PleaseSelectYourGender
pleaseSelectYourGender =
    Serialize.customType
        (\manEncoder womanEncoder transManEncoder transWomanEncoder nonBinaryEncoder preferNotToAnswerEncoder otherGenderEncoder value ->
            case value of
                Questions2023.Man ->
                    manEncoder

                Questions2023.Woman ->
                    womanEncoder

                Questions2023.TransMan ->
                    transManEncoder

                Questions2023.TransWoman ->
                    transWomanEncoder

                Questions2023.NonBinary ->
                    nonBinaryEncoder

                Questions2023.PreferNotToAnswer ->
                    preferNotToAnswerEncoder

                Questions2023.OtherGender ->
                    otherGenderEncoder
        )
        |> Serialize.variant0 Questions2023.Man
        |> Serialize.variant0 Questions2023.Woman
        |> Serialize.variant0 Questions2023.TransMan
        |> Serialize.variant0 Questions2023.TransWoman
        |> Serialize.variant0 Questions2023.NonBinary
        |> Serialize.variant0 Questions2023.PreferNotToAnswer
        |> Serialize.variant0 Questions2023.OtherGender
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
