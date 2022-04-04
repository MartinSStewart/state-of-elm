module DataEntry exposing (DataEntry(..), fromForms, get)

import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty)
import List.Nonempty.Ancillary as Nonempty


type DataEntry a
    = DataEntry (Nonempty Int)


get : Nonempty a -> DataEntry a -> Nonempty { choice : a, count : Int }
get choices (DataEntry dataEntry) =
    Nonempty.zip choices dataEntry
        |> Nonempty.map (\( choice, count ) -> { choice = choice, count = count })


fromForms : Nonempty a -> List a -> DataEntry a
fromForms choices answers =
    let
        list =
            Nonempty.toList choices
    in
    List.foldl
        (\answer state ->
            case List.elemIndex answer list of
                Just index ->
                    Nonempty.updateAt index (\count -> count + 1) state

                Nothing ->
                    state
        )
        (Nonempty.map (always 0) choices)
        answers
        |> DataEntry
