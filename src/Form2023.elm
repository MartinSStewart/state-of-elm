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
import List.Nonempty exposing (Nonempty(..))
import PackageName exposing (PackageName)
import Questions2023 exposing (Age(..), ApplicationDomains(..), BuildTools(..), DoYouUseElm(..), DoYouUseElmAtWork(..), DoYouUseElmFormat(..), DoYouUseElmReview(..), Editors(..), ElmResources(..), ElmVersion(..), ExperienceLevel(..), Frameworks(..), HowLargeIsTheCompany(..), HowLong(..), NewsAndDiscussions(..), OtherLanguages(..), PleaseSelectYourGender(..), StylingTools(..), TestTools(..), WhatLanguageDoYouUseForBackend(..))
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
    , whatPreventsYouFromUsingElmAtWork : String
    , howDidItGoUsingElmAtWork : String
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
    , whatPreventsYouFromUsingElmAtWork : FreeTextAnswerMap
    , howDidItGoUsingElmAtWork : FreeTextAnswerMap
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
    , whatPreventsYouFromUsingElmAtWork = ""
    , howDidItGoUsingElmAtWork = ""
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
    | WhatPreventsYouFromUsingElmAtWork
    | HowDidItGoUsingElmAtWork
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
        |> Serialize.field .whatPreventsYouFromUsingElmAtWork FreeTextAnswerMap.codec
        |> Serialize.field .howDidItGoUsingElmAtWork FreeTextAnswerMap.codec
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
        |> Serialize.field .doYouUseElm (assocSetCodec (serializeNonemptyEnum allDoYouUseElm))
        |> Serialize.field .age (Serialize.maybe (serializeNonemptyEnum allAge))
        |> Serialize.field .pleaseSelectYourGender (Serialize.maybe (serializeNonemptyEnum allPleaseSelectYourGender))
        |> Serialize.field .functionalProgrammingExperience (Serialize.maybe (serializeNonemptyEnum allExperienceLevel))
        |> Serialize.field .otherLanguages (multiChoiceWithOtherCodec (serializeNonemptyEnum allOtherLanguages))
        |> Serialize.field .newsAndDiscussions (multiChoiceWithOtherCodec (serializeNonemptyEnum allNewsAndDiscussions))
        |> Serialize.field .elmResources (multiChoiceWithOtherCodec (serializeNonemptyEnum allElmResources))
        |> Serialize.field .countryLivingIn (Serialize.maybe countryCodec)
        |> Serialize.field .applicationDomains (multiChoiceWithOtherCodec (serializeNonemptyEnum allWhereDoYouUseElm))
        |> Serialize.field .doYouUseElmAtWork (Serialize.maybe (serializeNonemptyEnum allDoYouUseElmAtWork))
        |> Serialize.field .whatPreventsYouFromUsingElmAtWork Serialize.string
        |> Serialize.field .howDidItGoUsingElmAtWork Serialize.string
        |> Serialize.field .howLargeIsTheCompany (Serialize.maybe (serializeNonemptyEnum allHowLargeIsTheCompany))
        |> Serialize.field
            .whatLanguageDoYouUseForBackend
            (multiChoiceWithOtherCodec (serializeNonemptyEnum allWhatLanguageDoYouUseForTheBackend))
        |> Serialize.field .howLong (Serialize.maybe (serializeNonemptyEnum allHowLong))
        |> Serialize.field .elmVersion (multiChoiceWithOtherCodec (serializeNonemptyEnum allWhatElmVersion))
        |> Serialize.field .doYouUseElmFormat (Serialize.maybe (serializeNonemptyEnum allDoYouUseElmFormat))
        |> Serialize.field .stylingTools (multiChoiceWithOtherCodec (serializeNonemptyEnum allStylingTools))
        |> Serialize.field .buildTools (multiChoiceWithOtherCodec (serializeNonemptyEnum allBuildTools))
        |> Serialize.field .frameworks (multiChoiceWithOtherCodec (serializeNonemptyEnum allFrameworksCodec))
        |> Serialize.field .editors (multiChoiceWithOtherCodec (serializeNonemptyEnum allEditors))
        |> Serialize.field .doYouUseElmReview (Serialize.maybe (serializeNonemptyEnum allDoYouUseElmReview))
        |> Serialize.field .testTools (multiChoiceWithOtherCodec (serializeNonemptyEnum allTestTools))
        |> Serialize.field .elmInitialInterest Serialize.string
        |> Serialize.field .biggestPainPoint Serialize.string
        |> Serialize.field .whatDoYouLikeMost Serialize.string
        |> Serialize.field .emailAddress Serialize.string
        |> Serialize.field .elmJson (Serialize.list (Serialize.list PackageName.codec))
        |> Serialize.finishRecord


allAge : Nonempty Age
allAge =
    Nonempty
        Under10
        [ Age10To19, Age20To29, Age30To39, Age40To49, Age50To59, Over60, PreferNotToAnswer2 ]


allPleaseSelectYourGender : Nonempty PleaseSelectYourGender
allPleaseSelectYourGender =
    Nonempty
        Man
        [ NonBinary, OtherGender, PreferNotToAnswer, TransMan, TransWoman, Woman ]


allExperienceLevel : Nonempty ExperienceLevel
allExperienceLevel =
    Nonempty
        Beginner
        [ Expert, Intermediate, Professional ]


allOtherLanguages : Nonempty OtherLanguages
allOtherLanguages =
    Nonempty
        JavaScript
        [ C, CPlusPlus, CSharp, Clojure, Elixir, FSharp, Go, Haskell, Java, NoOtherLanguage, OCaml, PHP, Python, Ruby, Rust, Swift, TypeScript ]


allNewsAndDiscussions : Nonempty NewsAndDiscussions
allNewsAndDiscussions =
    Nonempty
        ElmDiscourse
        [ BlogPosts, DevTo, ElmCraft, ElmNews, ElmRadio, ElmSlack, ElmSubreddit, ElmWeekly, IncrementalElm, Meetups, NoNewsOrDiscussions, Twitter ]


allElmResources : Nonempty ElmResources
allElmResources =
    Nonempty
        DailyDrip
        [ BeginningElmBook, BuildingWebAppsWithElm, EggheadCourses, ElmForBeginners, ElmInActionBook, ElmOnline, ElmSlack_, FrontendMasters, GuideElmLang, NoElmResources, ProgrammingElmBook, StackOverflow, TheJsonSurvivalKit, WeeklyBeginnersElmSubreddit ]


allWhereDoYouUseElm : Nonempty ApplicationDomains
allWhereDoYouUseElm =
    Nonempty
        Education
        [ ArtAndCulture, Communication, DataVisualization, ECommerce, Engineering, EnvironmentOrClimate, Finance, Gaming, Health, Legal, Music, NoApplicationDomains, Productivity, SocialMedia, Sports, Transportation ]


allDoYouUseElmAtWork : Nonempty DoYouUseElmAtWork
allDoYouUseElmAtWork =
    Nonempty
        NotInterestedInElmAtWork
        [ HaveTriedElmInAWorkProject, IUseElmAtWork, NotEmployed, WouldLikeToUseElmAtWork ]


allHowLargeIsTheCompany : Nonempty HowLargeIsTheCompany
allHowLargeIsTheCompany =
    Nonempty
        Size1To10Employees
        [ Size100OrMore, Size11To50Employees, Size50To100Employees ]


allWhatLanguageDoYouUseForTheBackend : Nonempty WhatLanguageDoYouUseForBackend
allWhatLanguageDoYouUseForTheBackend =
    Nonempty
        JavaScript_
        [ AlsoElm, CPlusPlus_, CSharp_, C_, Clojure_, Elixir_, FSharp_, Go_, Haskell_, Java_, Kotlin_, NotApplicable, OCaml_, PHP_, Python_, Ruby_, Rust_, TypeScript_ ]


allHowLong : Nonempty HowLong
allHowLong =
    Nonempty
        Under3Months
        [ Between3MonthsAndAYear, EightYears, FiveYears, FourYears, NineYears, OneYear, SevenYears, SixYears, TenYears, ThreeYears, TwoYears ]


allWhatElmVersion : Nonempty ElmVersion
allWhatElmVersion =
    Nonempty
        Version0_19
        [ Version0_16, Version0_17, Version0_18 ]


allDoYouUseElmFormat : Nonempty DoYouUseElmFormat
allDoYouUseElmFormat =
    Nonempty
        PreferElmFormat
        [ HaveNotHeardOfElmFormat, HeardButDontUseElmFormat, TriedButDontUseElmFormat ]


allStylingTools : Nonempty StylingTools
allStylingTools =
    Nonempty
        SassOrScss
        [ Bootstrap, ElmCss, ElmTailwindModules, ElmUi, NoStylingTools, PlainCss, Tailwind ]


allFrameworksCodec : Nonempty Frameworks
allFrameworksCodec =
    Nonempty
        Lamdera_
        [ ElmLand, ElmPages, ElmPlayground, ElmSpa, NoFramework ]


allEditors : Nonempty Editors
allEditors =
    Nonempty
        SublimeText
        [ Atom, Emacs, Intellij, NoEditor, VSCode, Vim ]


allDoYouUseElmReview : Nonempty DoYouUseElmReview
allDoYouUseElmReview =
    Nonempty
        NeverHeardOfElmReview
        [ HeardOfItButNeverTriedElmReview, IUseElmReviewRegularly, IveTriedElmReview ]


allTestTools : Nonempty TestTools
allTestTools =
    Nonempty
        BrowserAcceptanceTests
        [ ElmBenchmark, ElmProgramTest, ElmTest, NoTestTools, VisualRegressionTests ]


countryCodec : Codec e Country
countryCodec =
    Serialize.record Country
        |> Serialize.field .name Serialize.string
        |> Serialize.field .code Serialize.string
        |> Serialize.field .flag Serialize.string
        |> Serialize.finishRecord


serializeNonemptyEnum nonempty =
    Serialize.enum (List.Nonempty.head nonempty) (List.Nonempty.tail nonempty)


allBuildTools : Nonempty BuildTools
allBuildTools =
    Nonempty
        ShellScripts
        [ ElmLive
        , CreateElmApp
        , Webpack
        , Brunch
        , ElmMakeStandalone
        , Gulp
        , Make
        , ElmReactor
        , Parcel
        , Vite
        , ElmWatch
        , ElmPages_
        , Lamdera__
        , ElmLand_
        , EsBuild
        , NoBuildTools
        ]


allDoYouUseElm : Nonempty DoYouUseElm
allDoYouUseElm =
    Nonempty
        YesAtWork
        [ IUsedToButIDontAnymore, NoAndIDontPlanTo, NoButImCuriousAboutIt, YesAsAStudent, YesInSideProjects ]


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
