module Id exposing
    ( Id(..)
    , fromString
    , getUniqueId
    , toString
    )

import Env
import Sha256
import Time


type Id a
    = Id String


toString : Id a -> String
toString (Id hash) =
    hash


fromString : String -> Id a
fromString =
    Id


getUniqueId : Time.Posix -> { a | secretCounter : Int } -> ( { a | secretCounter : Int }, Id b )
getUniqueId time model =
    ( { model | secretCounter = model.secretCounter + 1 }
    , Env.secretKey
        ++ ":"
        ++ String.fromInt model.secretCounter
        ++ ":"
        ++ String.fromInt (Time.posixToMillis time)
        |> Sha256.sha256
        |> Id
    )
