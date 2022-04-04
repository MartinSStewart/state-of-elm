module Evergreen.V17.SurveyResults exposing (..)

import Evergreen.V17.DataEntry
import Evergreen.V17.Questions


type alias Data =
    { doYouUseElm : Evergreen.V17.DataEntry.DataEntry Evergreen.V17.Questions.DoYouUseElm
    , age : Evergreen.V17.DataEntry.DataEntry Evergreen.V17.Questions.Age
    , functionalProgrammingExperience : Evergreen.V17.DataEntry.DataEntry Evergreen.V17.Questions.ExperienceLevel
    , doYouUseElmAtWork : Evergreen.V17.DataEntry.DataEntry Evergreen.V17.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Evergreen.V17.DataEntry.DataEntry Evergreen.V17.Questions.HowLargeIsTheCompany
    , howLong : Evergreen.V17.DataEntry.DataEntry Evergreen.V17.Questions.HowLong
    , doYouUseElmFormat : Evergreen.V17.DataEntry.DataEntry Evergreen.V17.Questions.DoYouUseElmFormat
    , doYouUseElmReview : Evergreen.V17.DataEntry.DataEntry Evergreen.V17.Questions.DoYouUseElmReview
    }
