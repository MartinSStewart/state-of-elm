module SurveyResults exposing (Data, view)

import DataEntry exposing (DataEntry)
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import List.Nonempty as Nonempty exposing (Nonempty)
import List.Nonempty.Ancillary as Nonempty
import Questions exposing (Age, ExperienceLevel)


type alias Data =
    { age : DataEntry Age
    , functionalProgrammingExperience : DataEntry ExperienceLevel
    }


view : Data -> Element msg
view data =
    Element.column
        [ Element.width Element.fill ]
        [ singleChoiceGraph data.age Questions.allAge Questions.ageToString
        , singleChoiceGraph data.functionalProgrammingExperience Questions.allExperienceLevel Questions.experienceLevelToString
        ]


singleChoiceGraph : DataEntry a -> Nonempty a -> (a -> String) -> Element msg
singleChoiceGraph dataEntry choices choiceToString =
    let
        data =
            DataEntry.get choices dataEntry

        maxCount =
            Nonempty.map .count data |> Nonempty.maximum
    in
    if maxCount == 0 then
        Element.none

    else
        Element.table
            [ Element.width Element.fill ]
            { data = Nonempty.toList data
            , columns =
                [ { header = Element.none
                  , width = Element.shrink
                  , view =
                        \{ choice } ->
                            Element.paragraph
                                [ Element.Font.alignRight, Element.width (Element.px 200) ]
                                [ Element.text (choiceToString choice) ]
                  }
                , { header = Element.none
                  , width = Element.fill
                  , view =
                        \{ choice, count } ->
                            let
                                a =
                                    10000
                            in
                            Element.row
                                [ Element.width Element.fill
                                , Element.height Element.fill
                                ]
                                [ Element.el
                                    [ Element.Background.color (Element.rgb 0 0 0)
                                    , Element.fillPortion ((a * count) // (a * maxCount)) |> Element.width
                                    , Element.height Element.fill
                                    , Element.Border.rounded 4
                                    ]
                                    Element.none
                                , Element.el
                                    [ Element.fillPortion ((a * (maxCount - count)) // (a * maxCount)) |> Element.width ]
                                    Element.none
                                ]
                  }
                ]
            }
