module Evergreen.V23.AdminPage exposing (..)

import Effect.Time
import Evergreen.V23.AnswerMap
import Evergreen.V23.Form
import Evergreen.V23.NetworkModel


type FormMappingEdit
    = TypedGroupName Evergreen.V23.Form.SpecificQuestion Evergreen.V23.AnswerMap.Hotkey String
    | TypedNewGroupName Evergreen.V23.Form.SpecificQuestion String
    | TypedOtherAnswerGroups Evergreen.V23.Form.SpecificQuestion Evergreen.V23.AnswerMap.OtherAnswer String
    | RemoveGroup Evergreen.V23.Form.SpecificQuestion Evergreen.V23.AnswerMap.Hotkey
    | TypedComment Evergreen.V23.Form.SpecificQuestion String


type alias Model =
    { forms :
        List
            { form : Evergreen.V23.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V23.NetworkModel.NetworkModel FormMappingEdit Evergreen.V23.Form.FormMapping
    , selectedMapping : Evergreen.V23.Form.SpecificQuestion
    , showEncodedState : Bool
    }


type Msg
    = PressedLogOut
    | TypedFormsData String
    | FormMappingEditMsg FormMappingEdit
    | PressedQuestionWithOther Evergreen.V23.Form.SpecificQuestion
    | PressedToggleShowEncodedState


type ToBackend
    = ReplaceFormsRequest (List Evergreen.V23.Form.Form)
    | EditFormMappingRequest FormMappingEdit
    | LogOutRequest


type alias AdminLoginData =
    { forms :
        List
            { form : Evergreen.V23.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V23.Form.FormMapping
    }


type ToFrontend
    = EditFormMappingResponse FormMappingEdit
