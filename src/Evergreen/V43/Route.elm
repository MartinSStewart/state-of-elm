module Evergreen.V43.Route exposing (..)

import Evergreen.V43.Id


type SurveyYear
    = Year2022
    | Year2023


type UnsubscribeId
    = UnsubscribeToken Never


type Route
    = SurveyRoute SurveyYear
    | AdminRoute
    | UnsubscribeRoute (Evergreen.V43.Id.Id UnsubscribeId)
