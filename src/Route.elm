module Route exposing
    ( Route(..)
    , SurveyYear(..)
    , UnsubscribeId
    , currentSurvey
    , decode
    , encode
    , yearToString
    )

import Id exposing (Id)
import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>))


type Route
    = SurveyRoute SurveyYear
    | AdminRoute
    | UnsubscribeRoute (Id UnsubscribeId)


type UnsubscribeId
    = UnsubscribeToken Never


type SurveyYear
    = Year2022
    | Year2023


currentSurvey : SurveyYear
currentSurvey =
    Year2023


yearToString : SurveyYear -> String
yearToString surveyYear =
    case surveyYear of
        Year2022 ->
            "2022"

        Year2023 ->
            "2023"


encode : Route -> String
encode route =
    case route of
        SurveyRoute Year2022 ->
            Url.Builder.absolute [ path2022 ] []

        SurveyRoute Year2023 ->
            Url.Builder.absolute [ path2023 ] []

        AdminRoute ->
            Url.Builder.absolute [ pathAdmin ] []

        UnsubscribeRoute token ->
            Url.Builder.absolute [ pathUnsubscribe, Id.toString token ] []


pathUnsubscribe =
    "unsubscribe"


path2022 =
    "2022"


path2023 =
    "2023"


pathAdmin =
    "admin"


decode : Url -> Route
decode url =
    Url.Parser.parse
        (Url.Parser.oneOf
            [ Url.Parser.top |> Url.Parser.map (SurveyRoute currentSurvey)
            , Url.Parser.s path2022 |> Url.Parser.map (SurveyRoute Year2022)
            , Url.Parser.s path2023 |> Url.Parser.map (SurveyRoute Year2023)
            , Url.Parser.s pathAdmin |> Url.Parser.map AdminRoute
            , Url.Parser.s pathUnsubscribe
                </> Url.Parser.string
                |> Url.Parser.map (\token -> UnsubscribeRoute (Id.fromString token))
            ]
        )
        url
        |> Maybe.withDefault (SurveyRoute Year2023)
