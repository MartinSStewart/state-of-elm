module Tests exposing (..)

import Backend
import Effect.Test as TF
import EndToEndTests
import Expect
import List.Nonempty exposing (Nonempty(..))
import Parser
import Test exposing (Test)


appTests : Test
appTests =
    Test.describe "App tests" (List.map TF.toTest EndToEndTests.tests)


parserTests =
    Test.describe "Parser tests"
        [ Test.test "17 - None" <|
            \_ ->
                Parser.run Backend.responseParser "17 - None"
                    |> Expect.equal (Ok (Nonempty 17 []))
        , Test.test "[1,12 - 13]" <|
            \_ ->
                Parser.run Backend.responseParser "[1,12 - 13]"
                    |> Expect.equal (Ok (Nonempty 1 [ 12, 13 ]))
        ]
