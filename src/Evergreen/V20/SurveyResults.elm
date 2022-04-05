module Evergreen.V20.SurveyResults exposing (..)

import Evergreen.V20.DataEntry
import Evergreen.V20.Questions


type alias Data =
    { doYouUseElm : Evergreen.V20.DataEntry.DataEntry Evergreen.V20.Questions.DoYouUseElm
    , age : Evergreen.V20.DataEntry.DataEntry Evergreen.V20.Questions.Age
    , functionalProgrammingExperience : Evergreen.V20.DataEntry.DataEntry Evergreen.V20.Questions.ExperienceLevel
    , doYouUseElmAtWork : Evergreen.V20.DataEntry.DataEntry Evergreen.V20.Questions.DoYouUseElmAtWork
    , howLargeIsTheCompany : Evergreen.V20.DataEntry.DataEntry Evergreen.V20.Questions.HowLargeIsTheCompany
    , howLong : Evergreen.V20.DataEntry.DataEntry Evergreen.V20.Questions.HowLong
    , doYouUseElmFormat : Evergreen.V20.DataEntry.DataEntry Evergreen.V20.Questions.DoYouUseElmFormat
    , doYouUseElmReview : Evergreen.V20.DataEntry.DataEntry Evergreen.V20.Questions.DoYouUseElmReview
    }
