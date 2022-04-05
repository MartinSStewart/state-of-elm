module Evergreen.V20.AdminPage exposing (..)

import Effect.Time
import Evergreen.V20.Form


type alias AdminLoginData =
    { forms :
        List
            { form : Evergreen.V20.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V20.Form.FormMapping
    }


type Msg
    = PressedLogOut
    | TypedFormsData String


type ToBackend
    = ReplaceFormsRequest (List Evergreen.V20.Form.Form)
    | LogOutRequest
