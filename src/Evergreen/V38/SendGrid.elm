module Evergreen.V38.SendGrid exposing (..)


type alias ErrorMessage =
    { field : Maybe String
    , message : String
    , errorId : Maybe String
    }


type alias ErrorMessage403 =
    { message : Maybe String
    , field : Maybe String
    , help : Maybe String
    }


type Error
    = StatusCode400 (List ErrorMessage)
    | StatusCode401 (List ErrorMessage)
    | StatusCode403
        { errors : List ErrorMessage403
        , id : Maybe String
        }
    | StatusCode413 (List ErrorMessage)
    | UnknownError
        { statusCode : Int
        , body : String
        }
    | NetworkError
    | Timeout
    | BadUrl String
