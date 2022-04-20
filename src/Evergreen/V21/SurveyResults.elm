module Evergreen.V21.SurveyResults exposing (..)

import Evergreen.V21.DataEntry
import Evergreen.V21.Questions


type alias Data =
    { doYouUseElm : Evergreen.V21.DataEntry.DataEntry Evergreen.V21.Questions.DoYouUseElm
    , age : Evergreen.V21.DataEntry.DataEntry Evergreen.V21.Questions.Age
    , functionalProgrammingExperience : Evergreen.V21.DataEntry.DataEntry Evergreen.V21.Questions.ExperienceLevel
    , doYouUseElmAtWork : Evergreen.V21.DataEntry.DataEntry Evergreen.V21.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Evergreen.V21.DataEntry.DataEntry Evergreen.V21.Questions.HowLargeIsTheCompany
    , howLong : Evergreen.V21.DataEntry.DataEntry Evergreen.V21.Questions.HowLong
    , doYouUseElmFormat : Evergreen.V21.DataEntry.DataEntry Evergreen.V21.Questions.DoYouUseElmFormat
    , doYouUseElmReview : Evergreen.V21.DataEntry.DataEntry Evergreen.V21.Questions.DoYouUseElmReview
    }
