module Unsafe exposing (emailAddress, url)

import EmailAddress exposing (EmailAddress)
import Url exposing (Url)


emailAddress : String -> EmailAddress
emailAddress text =
    case EmailAddress.fromString text of
        Just ok ->
            ok

        Nothing ->
            unreachable ()


url : String -> Url
url urlText =
    case Url.fromString urlText of
        Just url_ ->
            url_

        Nothing ->
            unreachable ()


{-| Be very careful when using this!
-}
unreachable : () -> a
unreachable () =
    let
        _ =
            causeStackOverflow 0
    in
    unreachable ()


causeStackOverflow : Int -> Int
causeStackOverflow value =
    causeStackOverflow value + 1
