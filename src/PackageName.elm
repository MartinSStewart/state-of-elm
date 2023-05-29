module PackageName exposing (PackageName, codec, fromTuple)

import Serialize


type alias PackageName =
    { author : String, name : String, majorVersion : Int }


fromTuple : ( String, String ) -> Maybe PackageName
fromTuple ( name, version ) =
    case ( String.split "/" (String.trim name), String.split "." (String.trim version) |> List.map String.toInt ) of
        ( [ author, packageName ], [ Just major, _, _ ] ) ->
            Just { author = author, name = packageName, majorVersion = major }

        _ ->
            Nothing


codec : Serialize.Codec e PackageName
codec =
    Serialize.record PackageName
        |> Serialize.field .author Serialize.string
        |> Serialize.field .name Serialize.string
        |> Serialize.field .majorVersion Serialize.int
        |> Serialize.finishRecord
