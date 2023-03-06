module Route exposing (Route(..), SurveyYear(..), currentSurvey, decode, encode)

import Url exposing (Url)
import Url.Builder
import Url.Parser


type Route
    = SurveyRoute SurveyYear
    | AdminRoute


type SurveyYear
    = Year2022
    | Year2023


currentSurvey : SurveyYear
currentSurvey =
    Year2023


encode : Route -> String
encode route =
    case route of
        SurveyRoute Year2022 ->
            Url.Builder.absolute [ path2022 ] []

        SurveyRoute Year2023 ->
            Url.Builder.absolute [ path2023 ] []

        AdminRoute ->
            Url.Builder.absolute [ pathAdmin ] []


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
            ]
        )
        url
        |> Maybe.withDefault (SurveyRoute Year2023)
