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
    { title = "Elm survey 2022"
    , body =
        [ Element.layout
            []
            (formView model.form)
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
            (\a -> FormChanged { form | functionalProgrammingExperience = Just a })
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
            (\a -> FormChanged { form | userGroupNearYou = Just a })
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
            (\a -> FormChanged { form | howLong = Just a })
        ]
