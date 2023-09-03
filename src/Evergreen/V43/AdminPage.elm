module Evergreen.V43.AdminPage exposing (..)

import Effect.Time
import Evergreen.V43.AnswerMap
import Evergreen.V43.EmailAddress
import Evergreen.V43.Form2023
import Evergreen.V43.NetworkModel
import Evergreen.V43.SendGrid


type SendEmailsStatus
    = EmailsNotSent
    | Sending
    | SendResult
        (List
            { emailAddress : Evergreen.V43.EmailAddress.EmailAddress
            , result : Result Evergreen.V43.SendGrid.Error ()
            }
        )


type alias AdminLoginData =
    { forms :
        List
            { form : Evergreen.V43.Form2023.Form2023
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V43.Form2023.FormMapping
    , sendEmailsStatus : SendEmailsStatus
    }


type FormMappingEdit
    = TypedGroupName Evergreen.V43.Form2023.SpecificQuestion Evergreen.V43.AnswerMap.Hotkey String
    | TypedNewGroupName Evergreen.V43.Form2023.SpecificQuestion String
    | TypedOtherAnswerGroups Evergreen.V43.Form2023.SpecificQuestion Evergreen.V43.AnswerMap.OtherAnswer String
    | RemoveGroup Evergreen.V43.Form2023.SpecificQuestion Evergreen.V43.AnswerMap.Hotkey
    | TypedComment Evergreen.V43.Form2023.SpecificQuestion String


type alias Model =
    { forms :
        List
            { form : Evergreen.V43.Form2023.Form2023
            , submitTime : Maybe Effect.Time.Posix
            }
    , formMapping : Evergreen.V43.NetworkModel.NetworkModel FormMappingEdit Evergreen.V43.Form2023.FormMapping
    , selectedMapping : Evergreen.V43.Form2023.SpecificQuestion
    , showEncodedState : Bool
    , sendEmailsStatus : SendEmailsStatus
    }


type Msg
    = PressedLogOut
    | TypedFormsData String
    | FormMappingEditMsg FormMappingEdit
    | PressedQuestionWithOther Evergreen.V43.Form2023.SpecificQuestion
    | PressedToggleShowEncodedState
    | NoOp
    | PressedSendEmails


type ToBackend
    = ReplaceFormsRequest ( List Evergreen.V43.Form2023.Form2023, Evergreen.V43.Form2023.FormMapping )
    | EditFormMappingRequest FormMappingEdit
    | LogOutRequest
    | SendEmailsRequest


type ToFrontend
    = EditFormMappingResponse FormMappingEdit
    | SendEmailsResponse
        (List
            { emailAddress : Evergreen.V43.EmailAddress.EmailAddress
            , result : Result Evergreen.V43.SendGrid.Error ()
            }
        )
