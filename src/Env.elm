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


isProduction_ : String
isProduction_ =
    "false"


isProduction : Bool
isProduction =
    String.toLower isProduction_ == "true"


canShowLatestResults_ : String
canShowLatestResults_ =
    "true"


canShowLatestResults : Bool
canShowLatestResults =
    String.toLower canShowLatestResults_ == "true"


surveyCloseTime : Effect.Time.Posix
surveyCloseTime =
    Effect.Time.millisToPosix 1696363200000


presentResultsTime : Effect.Time.Posix
presentResultsTime =
    Duration.addTo surveyCloseTime (Duration.days 14)


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


domain : String
domain =
    "http://localhost:8000"


secretKey : String
secretKey =
    ""


openAiApiKey : String
openAiApiKey =
    ""
