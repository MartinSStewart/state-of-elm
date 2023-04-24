module Question exposing (..)

import List.Nonempty exposing (Nonempty)


type alias Question a =
    { title : String
    , choices : Nonempty a
    , choiceToString : a -> String
    }
