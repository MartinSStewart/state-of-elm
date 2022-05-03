module Evergreen.V37.AdminPage exposing (..)

import Effect.Time
import Evergreen.V37.AnswerMap
import Evergreen.V37.EmailAddress
import Evergreen.V37.Form
import Evergreen.V37.NetworkModel
import Evergreen.V37.SendGrid


type FormMappingEdit
    = TypedGroupName Evergreen.V37.Form.SpecificQuestion Evergreen.V37.AnswerMap.Hotkey String
    | TypedNewGroupName Evergreen.V37.Form.SpecificQuestion String
    | TypedOtherAnswerGroups Evergreen.V37.Form.SpecificQuestion Evergreen.V37.AnswerMap.OtherAnswer String
    | RemoveGroup Evergreen.V37.Form.SpecificQuestion Evergreen.V37.AnswerMap.Hotkey
    | TypedComment Evergreen.V37.Form.SpecificQuestion String


type SendEmailsStatus
    = EmailsNotSent
    | Sending
    | SendResult
        (List
            { emailAddress : Evergreen.V37.EmailAddress.EmailAddress
            , result : Result Evergreen.V37.SendGrid.Error ()
            }
        )


type alias Model =
    { forms :
        List
            { form : Evergreen.V37.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V37.NetworkModel.NetworkModel FormMappingEdit Evergreen.V37.Form.FormMapping
    , selectedMapping : Evergreen.V37.Form.SpecificQuestion
    , showEncodedState : Bool
    , sendEmailsStatus : SendEmailsStatus
    }


type Msg
    = PressedLogOut
    | TypedFormsData String
    | FormMappingEditMsg FormMappingEdit
    | PressedQuestionWithOther Evergreen.V37.Form.SpecificQuestion
    | PressedToggleShowEncodedState
    | NoOp
    | PressedSendEmails


type ToBackend
    = ReplaceFormsRequest ( List Evergreen.V37.Form.Form, Evergreen.V37.Form.FormMapping )
    | EditFormMappingRequest FormMappingEdit
    | LogOutRequest
    | SendEmailsRequest


type alias AdminLoginData =
    { forms :
        List
            { form : Evergreen.V37.Form.Form
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V37.Form.FormMapping
    , sendEmailsStatus : SendEmailsStatus
    }


type ToFrontend
    = EditFormMappingResponse FormMappingEdit
    | SendEmailsResponse
        (List
            { emailAddress : Evergreen.V37.EmailAddress.EmailAddress
            , result : Result Evergreen.V37.SendGrid.Error ()
            }
        )
