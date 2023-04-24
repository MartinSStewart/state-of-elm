module EndToEndTests exposing (tests)

import AssocList
import Backend
import Bytes exposing (Bytes)
import Bytes.Encode
import Dict as RegularDict
import Duration
import Effect.Browser.Dom as Dom
import Effect.Http as Http
import Effect.Lamdera
import Effect.Test as TF
import EmailAddress exposing (EmailAddress)
import Env
import Frontend
import Html.Parser
import Json.Decode
import List.Nonempty
import Quantity
import Question exposing (Question)
import Questions2023
import Route exposing (Route(..), SurveyYear(..))
import Time exposing (Month(..))
import Types exposing (BackendModel, BackendMsg, FrontendModel(..), FrontendMsg(..), ToBackend(..), ToFrontend)
import Ui
import Unsafe
import Url


main : Program () (TF.Model FrontendModel) TF.Msg
main =
    TF.viewer tests


config =
    TF.Config
        { init = Frontend.init
        , update = Frontend.update
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , updateFromBackend = Frontend.updateFromBackend
        , subscriptions = Frontend.subscriptions
        , view = Frontend.view
        }
        { init = Backend.init
        , update = Backend.update
        , updateFromFrontend = Backend.updateFromFrontend
        , subscriptions = Backend.subscriptions
        }
        handleHttpRequests
        handlePortToJs
        handleFileRequest
        (Unsafe.url Env.domain)


handleHttpRequests : { currentRequest : TF.HttpRequest, pastRequests : List TF.HttpRequest } -> Http.Response Bytes
handleHttpRequests { currentRequest } =
    Http.GoodStatus_
        { url = currentRequest.url
        , statusCode = 200
        , statusText = "OK"
        , headers = RegularDict.empty
        }
        (Bytes.Encode.sequence [] |> Bytes.Encode.encode)


handlePortToJs :
    { currentRequest : TF.PortToJs, pastRequests : List TF.PortToJs }
    -> Maybe ( String, Json.Decode.Value )
handlePortToJs { currentRequest } =
    Nothing


handleFileRequest :
    { mimeTypes : List String }
    -> Maybe { name : String, mimeType : String, content : String, lastModified : Time.Posix }
handleFileRequest _ =
    { name = "Image0.png"
    , content = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAABhWlDQ1BJQ0MgcHJvZmlsZQAAKJF9kT1Iw0AcxV9Ta0UqgnYQcchQnayIijhKFYtgobQVWnUwufRDaNKQpLg4Cq4FBz8Wqw4uzro6uAqC4AeIm5uToouU+L+k0CLGg+N+vLv3uHsHCPUyU82OcUDVLCMVj4nZ3IoYfEUn/OhDAGMSM/VEeiEDz/F1Dx9f76I8y/vcn6NHyZsM8InEs0w3LOJ14ulNS+e8TxxmJUkhPiceNeiCxI9cl11+41x0WOCZYSOTmiMOE4vFNpbbmJUMlXiKOKKoGuULWZcVzluc1XKVNe/JXxjKa8tprtMcQhyLSCAJETKq2EAZFqK0aqSYSNF+zMM/6PiT5JLJtQFGjnlUoEJy/OB/8LtbszA54SaFYkDgxbY/hoHgLtCo2fb3sW03TgD/M3CltfyVOjDzSXqtpUWOgN5t4OK6pcl7wOUOMPCkS4bkSH6aQqEAvJ/RN+WA/luge9XtrbmP0wcgQ10t3QAHh8BIkbLXPN7d1d7bv2ea/f0AT2FymQ2GVEYAAAAJcEhZcwAALiMAAC4jAXilP3YAAAAHdElNRQflBgMSBgvJgnPPAAAAGXRFWHRDb21tZW50AENyZWF0ZWQgd2l0aCBHSU1QV4EOFwAAAAxJREFUCNdjmH36PwAEagJmf/sZfAAAAABJRU5ErkJggg=="
    , lastModified = Time.millisToPosix 0
    , mimeType = "image/png"
    }
        |> Just


windowSize =
    { width = 900, height = 800 }


decodePostmark : Json.Decode.Decoder ( String, EmailAddress, List Html.Parser.Node )
decodePostmark =
    Json.Decode.map3 (\subject to body -> ( subject, to, body ))
        (Json.Decode.field "Subject" Json.Decode.string)
        (Json.Decode.field "To" Json.Decode.string
            |> Json.Decode.andThen
                (\to ->
                    case EmailAddress.fromString to of
                        Just emailAddress ->
                            Json.Decode.succeed emailAddress

                        Nothing ->
                            Json.Decode.fail "Invalid email address"
                )
        )
        (Json.Decode.field "HtmlBody" Json.Decode.string
            |> Json.Decode.andThen
                (\html ->
                    case Html.Parser.run html of
                        Ok nodes ->
                            Json.Decode.succeed nodes

                        Err _ ->
                            Json.Decode.fail "Failed to parse html"
                )
        )


getRoutesFromHtml : List Html.Parser.Node -> List Route
getRoutesFromHtml nodes =
    List.filterMap
        (\( attributes, _ ) ->
            let
                maybeHref =
                    List.filterMap
                        (\( name, value ) ->
                            if name == "href" then
                                Just value

                            else
                                Nothing
                        )
                        attributes
                        |> List.head
            in
            maybeHref |> Maybe.andThen Url.fromString |> Maybe.map Route.decode
        )
        (findNodesByTag "a" nodes)


findNodesByTag : String -> List Html.Parser.Node -> List ( List Html.Parser.Attribute, List Html.Parser.Node )
findNodesByTag tagName nodes =
    List.concatMap
        (\node ->
            case node of
                Html.Parser.Element name attributes children ->
                    (if name == tagName then
                        [ ( attributes, children ) ]

                     else
                        []
                    )
                        ++ findNodesByTag tagName children

                _ ->
                    []
        )
        nodes


sessionId0 =
    Effect.Lamdera.sessionIdFromString "sessionId0"


sessionId1 =
    Effect.Lamdera.sessionIdFromString "sessionId1"


url =
    Unsafe.url Env.domain


adminUrl =
    Env.domain ++ Route.encode AdminRoute |> Unsafe.url


url2022 =
    Env.domain ++ Route.encode (SurveyRoute Year2022) |> Unsafe.url


clickCheckbox : { a | clickButton : Dom.HtmlId -> c -> b } -> Question d -> c -> b
clickCheckbox clientActions question instructions =
    clientActions.clickButton
        (List.Nonempty.head question.choices
            |> question.choiceToString
            |> checkboxId
            |> Dom.id
        )
        instructions


checkboxId text =
    "checkbox_" ++ text


clickRadio : { a | clickButton : Dom.HtmlId -> c -> b } -> Question d -> c -> b
clickRadio clientActions question instructions =
    clientActions.clickButton
        (List.Nonempty.head question.choices
            |> question.choiceToString
            |> (++) ("radio_" ++ question.title ++ "_")
            |> Dom.id
        )
        instructions


userEmailAddress =
    Unsafe.emailAddress "a@a.se"


tests : List (TF.Instructions ToBackend FrontendMsg FrontendModel ToFrontend BackendMsg BackendModel)
tests =
    [ TF.start config "Happy path"
        |> TF.fastForward (Duration.from TF.startTime Env.surveyCloseTime |> Quantity.minus Duration.minute)
        |> TF.connectFrontend
            sessionId0
            url
            windowSize
            (\( instructions, client ) ->
                instructions
                    |> shortWait
                    |> clickCheckbox client Questions2023.doYouUseElm
                    |> shortWait
                    |> clickRadio client Questions2023.age
                    |> shortWait
                    |> clickRadio client Questions2023.experienceLevel
                    |> client.inputText Ui.emailAddressInputId (EmailAddress.toString userEmailAddress)
                    |> shortWait
            )
        -- Client refreshes page
        |> TF.connectFrontend
            sessionId0
            url
            windowSize
            (\( instructions, client ) ->
                instructions
                    |> shortWait
                    |> client.clickButton (checkboxId "I accept" |> Dom.id)
                    |> shortWait
                    |> client.clickButton Ui.submitSurveyButtonId
                    |> shortWait
                    |> TF.checkBackend
                        (\backend ->
                            case AssocList.toList backend.subscribedEmails of
                                [ ( _, data ) ] ->
                                    if data.emailAddress == userEmailAddress then
                                        Ok ()

                                    else
                                        Err "Wrong email address found"

                                _ ->
                                    Err "Email address not found"
                        )
                    |> TF.simulateTime Duration.minute
            )
        |> TF.connectFrontend
            sessionId1
            adminUrl
            windowSize
            (\( instructions, client ) ->
                instructions
                    |> shortWait
                    |> client.inputText Frontend.passwordInputId Env.adminPassword
                    |> shortWait
                    |> client.clickButton Frontend.loginButtonId
                    |> shortWait
            )
        |> TF.fastForward (Duration.days 30)
        |> TF.connectFrontend
            sessionId0
            url
            windowSize
            (\( instructions, client ) ->
                instructions |> shortWait |> client.clickButton (Dom.id "Per capita") |> shortWait
            )
    , TF.start config "View 2022 results"
        |> TF.connectFrontend
            sessionId0
            url
            windowSize
            (\( instructions, client ) ->
                instructions
                    |> shortWait
                    |> client.clickButton (Dom.id "Per capita")
                    |> shortWait
            )
    ]


shortWait =
    TF.simulateTime (Duration.milliseconds 100)
