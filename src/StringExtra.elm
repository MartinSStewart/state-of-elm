module StringExtra exposing (addSeparators, dropPrefix, dropSuffix, removeTrailing0s)

import List.Extra as List
import Round


removeTrailing0s : Int -> Float -> String
removeTrailing0s decimalPoints value =
    case Round.round decimalPoints value |> String.split "." of
        [ nonDecimal, decimal ] ->
            if decimalPoints > 0 then
                nonDecimal
                    ++ "."
                    ++ (String.foldr
                            (\char ( text, reachedNonZero ) ->
                                if reachedNonZero || char /= '0' then
                                    ( text, True )

                                else
                                    ( String.dropRight 1 text, False )
                            )
                            ( decimal, False )
                            decimal
                            |> Tuple.first
                       )
                    |> dropSuffix "."

            else
                nonDecimal

        [ nonDecimal ] ->
            nonDecimal

        _ ->
            "0"


addSeparators : String -> String
addSeparators =
    String.toList
        >> List.reverse
        >> List.greedyGroupsOf 3
        >> List.map (List.reverse >> String.fromList)
        >> List.reverse
        >> String.join " "


dropSuffix : String -> String -> String
dropSuffix suffix string =
    if String.endsWith suffix string then
        String.dropRight (String.length suffix) string

    else
        string


dropPrefix : String -> String -> String
dropPrefix prefix string =
    if String.startsWith prefix string then
        String.dropLeft (String.length prefix) string

    else
        string
