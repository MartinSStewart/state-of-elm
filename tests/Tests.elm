module Tests exposing (..)

import Effect.Test as TF
import EndToEndTests
import Test exposing (Test)


appTests =
    Test.describe "App tests" (List.map TF.toTest EndToEndTests.tests)
