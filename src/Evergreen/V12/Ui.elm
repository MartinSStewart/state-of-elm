module Evergreen.V12.Ui exposing (..)

import AssocSet


type alias MultiChoiceWithOther a =
    { choices : AssocSet.Set a
    , otherChecked : Bool
    , otherText : String
    }
