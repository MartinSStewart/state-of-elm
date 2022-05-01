module Evergreen.V24.AdminPage exposing (..)

import Effect.Time
import Evergreen.V24.AnswerMap
import Evergreen.V24.Form
import Evergreen.V24.NetworkModel


type FormMappingEdit
    = TypedGroupName Evergreen.V24.Form.SpecificQuestion Evergreen.V24.AnswerMap.Hotkey String
    | TypedNewGroupName Evergreen.V24.Form.SpecificQuestion String
    | TypedOtherAnswerGroups Evergreen.V24.Form.SpecificQuestion Evergreen.V24.AnswerMap.OtherAnswer String
    | RemoveGroup Evergreen.V24.Form.SpecificQuestion Evergreen.V24.AnswerMap.Hotkey
    | TypedComment Evergreen.V24.Form.SpecificQuestion String


type alias Model =
    { forms :
        List
            { form : Evergreen.V24.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V24.NetworkModel.NetworkModel FormMappingEdit Evergreen.V24.Form.FormMapping
    , selectedMapping : Evergreen.V24.Form.SpecificQuestion
    , showEncodedState : Bool
    }


type Msg
    = PressedLogOut
    | TypedFormsData String
    | FormMappingEditMsg FormMappingEdit
    | PressedQuestionWithOther Evergreen.V24.Form.SpecificQuestion
    | PressedToggleShowEncodedState
    | NoOp


type ToBackend
    = ReplaceFormsRequest ( List Evergreen.V24.Form.Form, Evergreen.V24.Form.FormMapping )
    | EditFormMappingRequest FormMappingEdit
    | LogOutRequest


type alias AdminLoginData =
    { forms :
        List
            { form : Evergreen.V24.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V24.Form.FormMapping
    }


type ToFrontend
    = EditFormMappingResponse FormMappingEdit
