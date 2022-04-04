module Evergreen.V18.SurveyResults exposing (..)

import Evergreen.V18.DataEntry
import Evergreen.V18.Questions


type alias Data =
    { doYouUseElm : Evergreen.V18.DataEntry.DataEntry Evergreen.V18.Questions.DoYouUseElm
    , age : Evergreen.V18.DataEntry.DataEntry Evergreen.V18.Questions.Age
    , functionalProgrammingExperience : Evergreen.V18.DataEntry.DataEntry Evergreen.V18.Questions.ExperienceLevel
    , doYouUseElmAtWork : Evergreen.V18.DataEntry.DataEntry Evergreen.V18.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Evergreen.V18.DataEntry.DataEntry Evergreen.V18.Questions.HowLargeIsTheCompany
    , howLong : Evergreen.V18.DataEntry.DataEntry Evergreen.V18.Questions.HowLong
    , doYouUseElmFormat : Evergreen.V18.DataEntry.DataEntry Evergreen.V18.Questions.DoYouUseElmFormat
    , doYouUseElmReview : Evergreen.V18.DataEntry.DataEntry Evergreen.V18.Questions.DoYouUseElmReview
    }
