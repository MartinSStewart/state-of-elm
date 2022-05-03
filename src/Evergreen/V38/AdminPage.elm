module Evergreen.V38.AdminPage exposing (..)

import Effect.Time
import Evergreen.V38.AnswerMap
import Evergreen.V38.EmailAddress
import Evergreen.V38.Form
import Evergreen.V38.NetworkModel
import Evergreen.V38.SendGrid


type FormMappingEdit
    = TypedGroupName Evergreen.V38.Form.SpecificQuestion Evergreen.V38.AnswerMap.Hotkey String
    | TypedNewGroupName Evergreen.V38.Form.SpecificQuestion String
    | TypedOtherAnswerGroups Evergreen.V38.Form.SpecificQuestion Evergreen.V38.AnswerMap.OtherAnswer String
    | RemoveGroup Evergreen.V38.Form.SpecificQuestion Evergreen.V38.AnswerMap.Hotkey
    | TypedComment Evergreen.V38.Form.SpecificQuestion String


type SendEmailsStatus
    = EmailsNotSent
    | Sending
    | SendResult
        (List
            { emailAddress : Evergreen.V38.EmailAddress.EmailAddress
            , result : Result Evergreen.V38.SendGrid.Error ()
            }
        )


type alias Model =
    { forms :
        List
            { form : Evergreen.V38.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V38.NetworkModel.NetworkModel FormMappingEdit Evergreen.V38.Form.FormMapping
    , selectedMapping : Evergreen.V38.Form.SpecificQuestion
    , showEncodedState : Bool
    , sendEmailsStatus : SendEmailsStatus
    }


type Msg
    = PressedLogOut
    | TypedFormsData String
    | FormMappingEditMsg FormMappingEdit
    | PressedQuestionWithOther Evergreen.V38.Form.SpecificQuestion
    | PressedToggleShowEncodedState
    | NoOp
    | PressedSendEmails


type ToBackend
    = ReplaceFormsRequest ( List Evergreen.V38.Form.Form, Evergreen.V38.Form.FormMapping )
    | EditFormMappingRequest FormMappingEdit
    | LogOutRequest
    | SendEmailsRequest


type alias AdminLoginData =
    { forms :
        List
            { form : Evergreen.V38.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V38.Form.FormMapping
    , sendEmailsStatus : SendEmailsStatus
    }


type ToFrontend
    = EditFormMappingResponse FormMappingEdit
    | SendEmailsResponse
        (List
            { emailAddress : Evergreen.V38.EmailAddress.EmailAddress
            , result : Result Evergreen.V38.SendGrid.Error ()
            }
        )
