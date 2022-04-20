module Evergreen.V21.AdminPage exposing (..)

import Effect.Time
import Evergreen.V21.Form


type alias AdminLoginData =
    { forms :
        List
            { form : Evergreen.V21.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V21.Form.FormMapping
    }


type Msg
    = PressedLogOut
    | TypedFormsData String


type ToBackend
    = ReplaceFormsRequest (List Evergreen.V21.Form.Form)
    | LogOutRequest
