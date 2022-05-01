module Evergreen.V24.NetworkModel exposing (..)


type alias NetworkModel msg model =
    { localMsgs : List msg
    , serverState : model
    }
