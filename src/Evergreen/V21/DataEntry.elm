module Evergreen.V21.DataEntry exposing (..)

import List.Nonempty


type DataEntry a
    = DataEntry (List.Nonempty.Nonempty Int)
