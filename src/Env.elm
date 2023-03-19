module Env exposing (..)

import Duration
import Effect.Time
import Quantity
import SendGrid
import Sha256


adminPassword : String
adminPassword =
    "123"


adminPasswordHash : String
adminPasswordHash =
    Sha256.sha256 adminPassword


presentSurveyResults_ : String
presentSurveyResults_ =
    "false"


presentSurveyResults : Bool
presentSurveyResults =
    String.toLower presentSurveyResults_ == "true"


isProduction_ : String
isProduction_ =
    "false"


isProduction : Bool
isProduction =
    String.toLower isProduction_ == "true"


surveyCloseTime : Effect.Time.Posix
surveyCloseTime =
    Effect.Time.millisToPosix 1680504853000


surveyIsOpen : Effect.Time.Posix -> Bool
surveyIsOpen time =
    Duration.from time surveyCloseTime |> Quantity.greaterThanZero


previewPassword : String
previewPassword =
    "abc"


sendGridKey_ : String
sendGridKey_ =
    ""


sendGridKey : SendGrid.ApiKey
sendGridKey =
    SendGrid.apiKey sendGridKey_


domain =
    "http://localhost:8000"
