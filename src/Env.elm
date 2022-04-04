module Env exposing (..)

import Duration
import Quantity
import Sha256
import Time
import Types exposing (SurveyStatus(..))


adminPassword : String
adminPassword =
    "123"


adminPasswordHash : String
adminPasswordHash =
    Sha256.sha256 adminPassword


surveyStatus_ : String
surveyStatus_ =
    "SurveyOpen"


surveyStatus : SurveyStatus
surveyStatus =
    case surveyStatus_ of
        "SurveyOpen" ->
            SurveyOpen

        "SurveyFinished" ->
            SurveyFinished

        _ ->
            SurveyOpen


isProduction_ : String
isProduction_ =
    "false"


isProduction : Bool
isProduction =
    String.toLower isProduction_ == "true"


surveyCloseTime : Time.Posix
surveyCloseTime =
    Time.millisToPosix 1650286800000


surveyIsOpen : Time.Posix -> Bool
surveyIsOpen time =
    Duration.from time surveyCloseTime |> Quantity.greaterThanZero
