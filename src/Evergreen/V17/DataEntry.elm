module Evergreen.V17.DataEntry exposing (..)

import List.Nonempty


type DataEntry a
    = DataEntry (List.Nonempty.Nonempty Int)
