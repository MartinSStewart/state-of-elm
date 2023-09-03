module Evergreen.V43.DataEntry exposing (..)

import AssocList
import List.Nonempty


type DataEntry a
    = DataEntry
        { data : List.Nonempty.Nonempty Int
        , comment : String
        }


type DataEntryWithOther a
    = DataEntryWithOther
        { data : AssocList.Dict String Int
        , comment : String
        }
