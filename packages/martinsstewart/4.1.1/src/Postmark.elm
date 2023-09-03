module Postmark exposing
    ( ApiKey
    , PostmarkEmailBody(..)
    , PostmarkSend
    , PostmarkSendResponse
    , PostmarkTemplateSend
    , apiKey
    , sendEmail
    , sendEmailTask
    , sendTemplateEmail
    )

import Effect.Command exposing (BackendOnly, Command)
import Effect.Http as Http
import Effect.Task as Task exposing (Task)
import Email.Html
import EmailAddress exposing (EmailAddress)
import Internal
import Json.Decode as D
import Json.Encode as E
import List.Nonempty
import String.Nonempty exposing (NonemptyString)


endpoint =
    "https://api.postmarkapp.com"


type ApiKey
    = ApiKey String


{-| Create an API key from a raw string.
-}
apiKey : String -> ApiKey
apiKey apiKey_ =
    ApiKey apiKey_


type PostmarkEmailBody
    = BodyHtml Email.Html.Html
    | BodyText String
    | BodyBoth Email.Html.Html String



-- Plain send


type alias PostmarkSend =
    { from : { name : String, email : EmailAddress }
    , to : List.Nonempty.Nonempty { name : String, email : EmailAddress }
    , subject : NonemptyString
    , body : PostmarkEmailBody
    , messageStream : String
    }


sendEmailTask : ApiKey -> PostmarkSend -> Task BackendOnly Http.Error PostmarkSendResponse
sendEmailTask (ApiKey token) d =
    let
        httpBody =
            Http.jsonBody <|
                E.object <|
                    [ ( "From", E.string <| emailToString d.from )
                    , ( "To", E.string <| emailsToString d.to )
                    , ( "Subject", E.string <| String.Nonempty.toString d.subject )
                    , ( "MessageStream", E.string d.messageStream )
                    ]
                        ++ bodyToJsonValues d.body
    in
    Http.task
        { method = "POST"
        , headers = [ Http.header "X-Postmark-Server-Token" token ]
        , url = endpoint ++ "/email"
        , body = httpBody
        , resolver = jsonResolver decodePostmarkSendResponse
        , timeout = Nothing
        }


sendEmail : (Result Http.Error PostmarkSendResponse -> msg) -> ApiKey -> PostmarkSend -> Command BackendOnly toMsg msg
sendEmail msg token d =
    sendEmailTask token d |> Task.attempt msg


emailsToString : List.Nonempty.Nonempty { name : String, email : EmailAddress } -> String
emailsToString nonEmptyEmails =
    nonEmptyEmails
        |> List.Nonempty.toList
        |> List.map emailToString
        |> String.join ", "


emailToString : { name : String, email : EmailAddress } -> String
emailToString address =
    if address.name == "" then
        EmailAddress.toString address.email

    else
        address.name ++ " <" ++ EmailAddress.toString address.email ++ ">"


type alias PostmarkSendResponse =
    { to : String
    , submittedAt : String
    , messageId : String
    , errorCode : Int
    , message : String
    }


decodePostmarkSendResponse =
    D.map5 PostmarkSendResponse
        (D.field "To" D.string)
        (D.field "SubmittedAt" D.string)
        (D.field "MessageID" D.string)
        (D.field "ErrorCode" D.int)
        (D.field "Message" D.string)



-- Template send


type alias PostmarkTemplateSend =
    { token : String
    , templateAlias : String
    , templateModel : E.Value
    , from : String
    , to : String
    , messageStream : String
    }


sendTemplateEmail : PostmarkTemplateSend -> Task BackendOnly Http.Error PostmarkTemplateSendResponse
sendTemplateEmail d =
    let
        httpBody =
            Http.jsonBody <|
                E.object <|
                    [ ( "From", E.string d.from )
                    , ( "To", E.string d.to )
                    , ( "MessageStream", E.string d.messageStream )
                    , ( "TemplateAlias", E.string d.templateAlias )
                    , ( "TemplateModel", d.templateModel )
                    ]
    in
    Http.task
        { method = "POST"
        , headers = [ Http.header "X-Postmark-Server-Token" d.token ]
        , url = endpoint ++ "/email/withTemplate"
        , body = httpBody
        , resolver = jsonResolver decodePostmarkTemplateSendResponse
        , timeout = Nothing
        }


type alias PostmarkTemplateSendResponse =
    { to : String
    , submittedAt : String
    , messageId : String
    , errorCode : String
    , message : String
    }


decodePostmarkTemplateSendResponse =
    D.map5 PostmarkTemplateSendResponse
        (D.field "To" D.string)
        (D.field "SubmittedAt" D.string)
        (D.field "MessageID" D.string)
        (D.field "ErrorCode" D.string)
        (D.field "Message" D.string)



-- Helpers


bodyToJsonValues : PostmarkEmailBody -> List ( String, E.Value )
bodyToJsonValues body =
    case body of
        BodyHtml html ->
            [ ( "HtmlBody", E.string <| Tuple.first <| Internal.toString html ) ]

        BodyText text ->
            [ ( "TextBody", E.string text ) ]

        BodyBoth html text ->
            [ ( "HtmlBody", E.string <| Tuple.first <| Internal.toString html )
            , ( "TextBody", E.string text )
            ]


jsonResolver : D.Decoder a -> Http.Resolver BackendOnly Http.Error a
jsonResolver decoder =
    Http.stringResolver <|
        \response ->
            case response of
                Http.GoodStatus_ _ body ->
                    D.decodeString decoder body
                        |> Result.mapError D.errorToString
                        |> Result.mapError Http.BadBody

                Http.BadUrl_ message ->
                    Err (Http.BadUrl message)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ metadata _ ->
                    Err (Http.BadStatus metadata.statusCode)
