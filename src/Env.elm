module Env exposing (..)

import Sha256
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

        "AwaitingResults" ->
            AwaitingResults

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
