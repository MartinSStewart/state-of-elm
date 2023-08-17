module NoMissingTypeConstructorTest exposing (all)

import NoMissingTypeConstructor exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "NoMissingTypeConstructor"
        [ test "should report when a declaration named `all...` that is of type `List <CustomTypeName>` does not have all the type constructors in its value (1)" <|
            \_ ->
                """module A exposing (..)
type Thing = A | B | C | D | E
allThings : List Thing
allThings = [ A, C, B ]
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`allThings` does not contain all the type constructors for `Thing`"
                            , details =
                                [ "We expect `allThings` to contain all the type constructors for `Thing`."
                                , """In this case, you are missing the following constructors:
    , D
    , E"""
                                ]
                            , under = "allThings"
                            }
                            |> Review.Test.atExactly { start = { row = 4, column = 1 }, end = { row = 4, column = 10 } }
                            |> Review.Test.whenFixed
                                """module A exposing (..)
type Thing = A | B | C | D | E
allThings : List Thing
allThings = [ A, C, B, D, E ]
"""
                        ]
        , test "should report when a declaration named `all...` that is of type `List <CustomTypeName>` does not have all the type constructors in its value (2)" <|
            \_ ->
                """module A exposing (..)
type Shenanigan = FirstThing | SecondThing | ThirdThing
allShenanigans : List Shenanigan
allShenanigans = [ FirstThing, ThirdThing ]
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`allShenanigans` does not contain all the type constructors for `Shenanigan`"
                            , details =
                                [ "We expect `allShenanigans` to contain all the type constructors for `Shenanigan`."
                                , """In this case, you are missing the following constructors:
    , SecondThing"""
                                ]
                            , under = "allShenanigans"
                            }
                            |> Review.Test.atExactly { start = { row = 4, column = 1 }, end = { row = 4, column = 15 } }
                            |> Review.Test.whenFixed
                                """module A exposing (..)
type Shenanigan = FirstThing | SecondThing | ThirdThing
allShenanigans : List Shenanigan
allShenanigans = [ FirstThing, ThirdThing, SecondThing ]
"""
                        ]
        , test "should report when a declaration named `all...` that is of type `List <CustomTypeName>` does not have all the type constructors in its value, where type is defined in a different module" <|
            \_ ->
                [ """module A exposing (..)
import CustomTypeHolder exposing (..)
allShenanigans : List Shenanigan
allShenanigans = [ FirstThing, ThirdThing ]
""", """module CustomTypeHolder exposing (..)
type Shenanigan = FirstThing | SecondThing | ThirdThing
""" ]
                    |> Review.Test.runOnModules rule
                    |> Review.Test.expectErrorsForModules
                        [ ( "A"
                          , [ Review.Test.error
                                { message = "`allShenanigans` does not contain all the type constructors for `Shenanigan`"
                                , details =
                                    [ "We expect `allShenanigans` to contain all the type constructors for `Shenanigan`."
                                    , """In this case, you are missing the following constructors:
    , SecondThing"""
                                    ]
                                , under = "allShenanigans"
                                }
                                |> Review.Test.atExactly { start = { row = 4, column = 1 }, end = { row = 4, column = 15 } }
                                |> Review.Test.whenFixed
                                    """module A exposing (..)
import CustomTypeHolder exposing (..)
allShenanigans : List Shenanigan
allShenanigans = [ FirstThing, ThirdThing, SecondThing ]
"""
                            ]
                          )
                        ]
        , test "should nt report when a declaration named `all...` that is of type `List <CustomTypeName>` has all the type constructors in its value, where type is defined in a different module (unqualified import)" <|
            \_ ->
                [ """module A exposing (..)
import CustomTypeHolder exposing (..)
allShenanigans : List Shenanigan
allShenanigans = [ FirstThing, SecondThing, ThirdThing ]
""", """module CustomTypeHolder exposing (..)
type Shenanigan = FirstThing | SecondThing | ThirdThing
""" ]
                    |> Review.Test.runOnModules rule
                    |> Review.Test.expectNoErrors
        , test "should nt report when a declaration named `all...` that is of type `List <CustomTypeName>` has all the type constructors in its value, where type is defined in a different module (qualified import)" <|
            \_ ->
                [ """module A exposing (..)
import CustomTypeHolder exposing (..)
allShenanigans : List Shenanigan
allShenanigans = [ CustomTypeHolder.FirstThing, CustomTypeHolder.SecondThing, CustomTypeHolder.ThirdThing ]
""", """module CustomTypeHolder exposing (..)
type Shenanigan = FirstThing | SecondThing | ThirdThing
""" ]
                    |> Review.Test.runOnModules rule
                    |> Review.Test.expectNoErrors
        , test "should not report when a declaration named `all...` that is of type `List <CustomTypeName>` has all the type constructors in its value" <|
            \_ ->
                """module A exposing (..)
type Thing = A | B | C | D | E
allThings : List Thing
allThings = [ A, C, B, D, E ]
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should not report when a declaration named `all...` is a list of an unknown custom type" <|
            \_ ->
                """module A exposing (..)
type Thing = A | B | C | D | E
allThings : List OtherThing
allThings = [ A, C, B ]
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should not report when a declaration is not named `all...`" <|
            \_ ->
                """module A exposing (..)
type Thing = A | B | C | D | E
someOfTheThings : List Thing
someOfTheThings = [ A, C, B ]
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should fix when a declaration named `all` that is of type `List <CustomTypeName>` does not have ANY of the type constructors in its value" <|
            \_ ->
                """module A exposing (..)
type Thing = A | B | C | D | E
all : List Thing
all = []
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`all` does not contain all the type constructors for `Thing`"
                            , details =
                                [ "We expect `all` to contain all the type constructors for `Thing`."
                                , """In this case, you are missing the following constructors:
    , A
    , B
    , C
    , D
    , E"""
                                ]
                            , under = "all"
                            }
                            |> Review.Test.atExactly { start = { row = 4, column = 1 }, end = { row = 4, column = 4 } }
                            |> Review.Test.whenFixed
                                """module A exposing (..)
type Thing = A | B | C | D | E
all : List Thing
all = [ A, B, C, D, E]
"""
                        ]
        , test "should handle nonempty constructors" <|
            \_ ->
                """module A exposing (..)
import List.Nonempty exposing (Nonempty(..))
type Thing = A | B | C | D | E
all : Nonempty Thing
all = Nonempty A []
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`all` does not contain all the type constructors for `Thing`"
                            , details =
                                [ "We expect `all` to contain all the type constructors for `Thing`."
                                , """In this case, you are missing the following constructors:
    , B
    , C
    , D
    , E"""
                                ]
                            , under = "all"
                            }
                            |> Review.Test.atExactly { start = { row = 5, column = 1 }, end = { row = 5, column = 4 } }
                            |> Review.Test.whenFixed
                                """module A exposing (..)
import List.Nonempty exposing (Nonempty(..))
type Thing = A | B | C | D | E
all : Nonempty Thing
all = Nonempty A [ B, C, D, E]
"""
                        ]
        ]
