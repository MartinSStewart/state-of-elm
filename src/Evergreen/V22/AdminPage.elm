module Evergreen.V22.AdminPage exposing (..)

import Effect.Time
import Evergreen.V22.AnswerMap
import Evergreen.V22.Form


type alias Model =
    { forms :
        List
            { form : Evergreen.V22.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V22.Form.FormOtherQuestions
    , selectedMapping : Evergreen.V22.Form.SpecificQuestion
    , showEncodedState : Bool
    , debounceCount : Int
    }


type Msg
    = PressedLogOut
    | TypedFormsData String
    | TypedGroupName Evergreen.V22.AnswerMap.Hotkey String
    | TypedNewGroupName String
    | TypedOtherAnswerGroups Evergreen.V22.AnswerMap.OtherAnswer String
    | RemoveGroup Evergreen.V22.AnswerMap.Hotkey
    | PressedQuestionWithOther Evergreen.V22.Form.SpecificQuestion
    | PressedToggleShowEncodedState
    | DebounceSaveAnswerMap Int
    | TypedComment String


type ToBackend
    = ReplaceFormsRequest (List Evergreen.V22.Form.Form)
    | SaveAnswerMap Evergreen.V22.Form.FormOtherQuestions
    | LogOutRequest


type alias AdminLoginData =
    { forms :
        List
            { form : Evergreen.V22.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V22.Form.FormOtherQuestions
    }
