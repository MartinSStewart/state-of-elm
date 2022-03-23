module Types exposing (..)

import AssocSet exposing (Set)
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Questions exposing (DoYouUseElm, ElmResources, ExperienceLevel, HowLong, NewsAndDiscussions, OtherLanguages, WhereDoYouUseElm, YesNo)
import Ui exposing (MultiChoiceWithOther)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , form : Form
    }


type alias Form =
    { doYouUseElm : Set DoYouUseElm
    , functionalProgrammingExperience : Maybe ExperienceLevel
    , otherLanguages : MultiChoiceWithOther OtherLanguages
    , newsAndDiscussions : MultiChoiceWithOther NewsAndDiscussions
    , elmResources : MultiChoiceWithOther ElmResources
    , userGroupNearYou : Maybe YesNo
    , applicationDomains : MultiChoiceWithOther WhereDoYouUseElm
    , howLong : Maybe HowLong
    }


type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | FormChanged Form


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
