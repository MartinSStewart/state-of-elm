module Evergreen.V27.AdminPage exposing (..)

import Effect.Time
import Evergreen.V27.AnswerMap
import Evergreen.V27.Form
import Evergreen.V27.NetworkModel


type FormMappingEdit
    = TypedGroupName Evergreen.V27.Form.SpecificQuestion Evergreen.V27.AnswerMap.Hotkey String
    | TypedNewGroupName Evergreen.V27.Form.SpecificQuestion String
    | TypedOtherAnswerGroups Evergreen.V27.Form.SpecificQuestion Evergreen.V27.AnswerMap.OtherAnswer String
    | RemoveGroup Evergreen.V27.Form.SpecificQuestion Evergreen.V27.AnswerMap.Hotkey
    | TypedComment Evergreen.V27.Form.SpecificQuestion String


type alias Model =
    { forms :
        List
            { form : Evergreen.V27.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V27.NetworkModel.NetworkModel FormMappingEdit Evergreen.V27.Form.FormMapping
    , selectedMapping : Evergreen.V27.Form.SpecificQuestion
    , showEncodedState : Bool
    }


type Msg
    = PressedLogOut
    | TypedFormsData String
    | FormMappingEditMsg FormMappingEdit
    | PressedQuestionWithOther Evergreen.V27.Form.SpecificQuestion
    | PressedToggleShowEncodedState
    | NoOp


type ToBackend
    = ReplaceFormsRequest ( List Evergreen.V27.Form.Form, Evergreen.V27.Form.FormMapping )
    | EditFormMappingRequest FormMappingEdit
    | LogOutRequest


type alias AdminLoginData =
    { forms :
        List
            { form : Evergreen.V27.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V27.Form.FormMapping
    }


type ToFrontend
    = EditFormMappingResponse FormMappingEdit
