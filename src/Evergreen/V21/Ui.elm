module Evergreen.V21.Ui exposing (..)

import AssocSet


type alias Size =
    { width : Int
    , height : Int
    }


type alias MultiChoiceWithOther a =
    { choices : AssocSet.Set a
    , otherChecked : Bool
    , otherText : String
    }
