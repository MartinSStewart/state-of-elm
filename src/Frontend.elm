module Frontend exposing (..)

import AssocSet as Set
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element exposing (Element)
import Lamdera
import Questions
import Types exposing (..)
import Ui
import Url


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( FrontendModel, Cmd FrontendMsg )
init _ key =
    let
        form : Form
        form =
            { doYouUseElm = Set.empty
            , functionalProgrammingExperience = Nothing
            , otherLanguages = Ui.multiChoiceWithOtherInit
            , newsAndDiscussions = Ui.multiChoiceWithOtherInit
            , elmResources = Ui.multiChoiceWithOtherInit
            , userGroupNearYou = Nothing
            , applicationDomains = Ui.multiChoiceWithOtherInit
            , howLong = Nothing
            , howFarAlongWork = Nothing
            , howIsProjectLicensedWork = Nothing
            , workAdoptionChallenge = ""
            , howFarAlongHobby = Nothing
            , howIsProjectLicensedHobby = Nothing
            , hobbyAdoptionChallenge = ""
            , elmVersion = Ui.multiChoiceWithOtherInit
            , doYouUseElmFormat = Nothing
            , stylingTools = Ui.multiChoiceWithOtherInit
            , buildTools = Ui.multiChoiceWithOtherInit
            , editors = Ui.multiChoiceWithOtherInit
            , jsInteropUseCases = ""
            , testTools = Ui.multiChoiceWithOtherInit
            , testsWrittenFor = Ui.multiChoiceWithOtherInit
            , elmInitialInterest = ""
            , biggestPainPoint = ""
            , whatDoYouLikeMost = ""
            , accept = Nothing
            }
    in
    ( { key = key, form = form }, Cmd.none )


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        FormChanged form ->
            ( { model | form = form }, Cmd.none )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title = "State of Elm 2022"
    , body =
        [ Element.layout
            []
            (Element.column
                [ Element.spacing 48 ]
                [ Element.paragraph
                    []
                    [ Element.text "After a 4 year hiatus, State of Elm is back! Feel free to fill in as many or as few questions as you are comfortable with and press submit when you are finished." ]
                , formView model.form
                ]
            )
        ]
    }


formView : Form -> Element FrontendMsg
formView form =
    Element.column
        [ Element.spacing 24 ]
        [ Ui.multiChoiceQuestion
            "Do you use Elm?"
            Nothing
            Questions.allDoYouUseElm
            Questions.doYouUseElmToString
            form.doYouUseElm
            (\a -> FormChanged { form | doYouUseElm = a })
        , Ui.singleChoiceQuestion
            "What is your level of experience with functional programming?"
            (Just "Where 0 is beginner and 10 is expert.")
            Questions.allExperienceLevels
            Questions.experienceLevelToString
            form.functionalProgrammingExperience
            (\a -> FormChanged { form | functionalProgrammingExperience = a })
        , Ui.multiChoiceQuestionWithOther
            "What programming languages, other than Elm, are you most familiar with?"
            (Just "Note that it's totally fine if that's \"none\"!")
            Questions.allOtherLanguages
            Questions.otherLanguagesToString
            form.otherLanguages
            (\a -> FormChanged { form | otherLanguages = a })
        , Ui.multiChoiceQuestionWithOther
            "Where do you go for Elm news and discussion?"
            Nothing
            Questions.allNewsAndDiscussions
            Questions.newsAndDiscussionsToString
            form.newsAndDiscussions
            (\a -> FormChanged { form | newsAndDiscussions = a })
        , Ui.multiChoiceQuestionWithOther
            "What resources did you use to learn Elm?"
            Nothing
            Questions.allElmResources
            Questions.elmResourcesToString
            form.elmResources
            (\a -> FormChanged { form | elmResources = a })
        , Ui.singleChoiceQuestion
            "Is there an Elm user group near you?"
            Nothing
            Questions.allYesNo
            Questions.yesNoToString
            form.userGroupNearYou
            (\a -> FormChanged { form | userGroupNearYou = a })
        , Ui.multiChoiceQuestionWithOther
            "In which application domains, if any, have you used Elm?"
            (Just "This means things like education, gaming, e-commerce, or music–not \"web development\". What are you using Elm for?")
            Questions.allApplicationDomains
            Questions.applicationDomainsToString
            form.applicationDomains
            (\a -> FormChanged { form | applicationDomains = a })
        , Ui.singleChoiceQuestion
            "How long have you been using Elm?"
            Nothing
            Questions.allHowLong
            Questions.howLongToString
            form.howLong
            (\a -> FormChanged { form | howLong = a })
        , Ui.singleChoiceQuestion
            "How far along is your most mature Elm project at work?"
            Nothing
            Questions.allHowFarAlong
            Questions.howFarAlongToStringWork
            form.howFarAlongWork
            (\a -> FormChanged { form | howFarAlongWork = a })
        , Ui.singleChoiceQuestion
            "How is that work project licensed?"
            (Just "Or, if it is not yet released, how will it be licensed?")
            Questions.allHowIsProjectLicensed
            Questions.howIsProjectLicensedToString
            form.howIsProjectLicensedWork
            (\a -> FormChanged { form | howIsProjectLicensedWork = a })
        , Ui.textInput
            "If you aren't using Elm at work, but want to, what's the main challenge preventing your organization from adopting it?"
            (Just "If you are already using Elm at work, please skip this question.")
            form.workAdoptionChallenge
            (\a -> FormChanged { form | workAdoptionChallenge = a })
        , Ui.singleChoiceQuestion
            "How far along is your most mature Elm side project?"
            (Just "Meaning anything done in your spare time. For example, an application or package.")
            Questions.allHowFarAlong
            Questions.howFarAlongToStringHobby
            form.howFarAlongHobby
            (\a -> FormChanged { form | howFarAlongHobby = a })
        , Ui.singleChoiceQuestion
            "How is that side project licensed?"
            (Just "Or, if it is not yet released, how will it be licensed?")
            Questions.allHowIsProjectLicensed
            Questions.howIsProjectLicensedToString
            form.howIsProjectLicensedHobby
            (\a -> FormChanged { form | howIsProjectLicensedHobby = a })
        , Ui.textInput
            "What is the biggest thing that prevents you from using Elm in your side projects?"
            (Just "If you already are using Elm in your side projects, please skip this question.")
            form.hobbyAdoptionChallenge
            (\a -> FormChanged { form | hobbyAdoptionChallenge = a })
        , Ui.multiChoiceQuestionWithOther
            "What versions of Elm are you using?"
            Nothing
            Questions.allWhatElmVersion
            Questions.whatElmVersionToString
            form.elmVersion
            (\a -> FormChanged { form | elmVersion = a })
        , Ui.singleChoiceQuestion
            "Do you format your code with elm-format?"
            Nothing
            Questions.allDoYouUseElmFormat
            Questions.doYouUseElmFormatToString
            form.doYouUseElmFormat
            (\a -> FormChanged { form | doYouUseElmFormat = a })
        , Ui.multiChoiceQuestionWithOther
            "What tools or libraries do you use to style your Elm applications?"
            Nothing
            Questions.allStylingTools
            Questions.stylingToolsToString
            form.stylingTools
            (\a -> FormChanged { form | stylingTools = a })
        , Ui.multiChoiceQuestionWithOther
            "What tools do you use to build your Elm applications?"
            Nothing
            Questions.allBuildTools
            Questions.buildToolsToString
            form.buildTools
            (\a -> FormChanged { form | buildTools = a })
        , Ui.multiChoiceQuestionWithOther
            "What editor(s) do you use to build your Elm applications?"
            Nothing
            Questions.allEditor
            Questions.editorToString
            form.editors
            (\a -> FormChanged { form | editors = a })
        , Ui.textInput
            "If you've used JavaScript interop, what have you used it for?"
            Nothing
            form.jsInteropUseCases
            (\a -> FormChanged { form | jsInteropUseCases = a })
        , Ui.multiChoiceQuestionWithOther
            "What tools do you use to test your Elm projects?"
            Nothing
            Questions.allTestTools
            Questions.testToolsToString
            form.testTools
            (\a -> FormChanged { form | testTools = a })
        , Ui.multiChoiceQuestionWithOther
            "What do you write tests for in your Elm projects?"
            Nothing
            Questions.allTestsWrittenFor
            Questions.testsWrittenForToString
            form.testsWrittenFor
            (\a -> FormChanged { form | testsWrittenFor = a })
        , Ui.textInput
            "What initially attracted you to Elm, or motivated you to try it?"
            Nothing
            form.elmInitialInterest
            (\a -> FormChanged { form | elmInitialInterest = a })
        , Ui.textInput
            "What has been your biggest pain point in your use of Elm?"
            Nothing
            form.biggestPainPoint
            (\a -> FormChanged { form | biggestPainPoint = a })
        , Ui.textInput
            "What do you like the most about your use of Elm?"
            Nothing
            form.whatDoYouLikeMost
            (\a -> FormChanged { form | whatDoYouLikeMost = a })
        , Ui.singleChoiceQuestion
            "One last thing before you go"
            (Just "Thank you for filling out the survey! We're going to publish the results based on the information you're giving us here, so please make sure that there's nothing you wouldn't want made public in your responses. Hit \"I accept\" to acknowledge that it's all good!")
            Questions.allAccept
            Questions.acceptToString
            form.accept
            (\a -> FormChanged { form | accept = a })
        ]
