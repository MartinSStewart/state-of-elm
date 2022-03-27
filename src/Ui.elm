module Ui exposing
    ( AnswerWithOther(..)
    , MultiChoiceWithOther
    , acceptTosQuestion
    , blue0
    , multiChoiceQuestion
    , multiChoiceQuestionWithOther
    , multiChoiceWithOtherInit
    , singleChoiceQuestion
    , textInput
    , white
    )

import AssocSet as Set exposing (Set)
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Html
import Html.Attributes
import Html.Events
import List.Nonempty exposing (Nonempty)


textInput : String -> Maybe String -> String -> (String -> model) -> Element model
textInput title maybeSubtitle text updateModel =
    container
        [ Element.Input.multiline
            [ Element.width Element.fill
            , Element.htmlAttribute (Html.Attributes.attribute "data-gramm_editor" "false")
            , Element.htmlAttribute (Html.Attributes.attribute "data-enable-grammarly" "false")
            , Element.Font.size 18
            ]
            { onChange = updateModel
            , text = text
            , placeholder = Nothing
            , label =
                Element.Input.labelAbove
                    [ Element.paddingEach { left = 0, right = 0, top = 0, bottom = 16 } ]
                    (titleAndSubtitle title maybeSubtitle)
            , spellcheck = True
            }
        ]


type AnswerWithOther a
    = Answer a
    | Other String


singleChoiceQuestion :
    String
    -> Maybe String
    -> Nonempty a
    -> (a -> String)
    -> Maybe a
    -> (Maybe a -> model)
    -> Element model
singleChoiceQuestion title maybeSubtitle choices choiceToString selection updateModel =
    container
        [ titleAndSubtitle title maybeSubtitle
        , List.Nonempty.toList choices
            |> List.map
                (\choice ->
                    radioButton title (choiceToString choice) (Just choice == selection)
                        |> Element.map
                            (\() ->
                                if Just choice == selection then
                                    updateModel Nothing

                                else
                                    updateModel (Just choice)
                            )
                )
            |> Element.column [ Element.spacing 8 ]
        ]


radioButton : String -> String -> Bool -> Element ()
radioButton groupName text isChecked =
    Html.label []
        [ Html.input
            [ Html.Attributes.type_ "radio"
            , Html.Attributes.checked isChecked
            , Html.Attributes.name groupName
            , Html.Events.onClick ()
            ]
            []
        , Html.text text
        ]
        |> Element.html
        |> Element.el []


checkButton : String -> Bool -> Element ()
checkButton text isChecked =
    Html.label []
        [ Html.input
            [ Html.Attributes.type_ "checkbox"
            , Html.Attributes.checked isChecked
            , Html.Events.onClick ()
            , Html.Attributes.style "margin" "4px"
            ]
            []
        , Html.text text
        ]
        |> Element.html
        |> Element.el []


multiChoiceQuestion :
    String
    -> Maybe String
    -> Nonempty a
    -> (a -> String)
    -> Set a
    -> (Set a -> model)
    -> Element model
multiChoiceQuestion title maybeSubtitle choices choiceToString selection updateModel =
    container
        [ titleAndSubtitle title maybeSubtitle
        , Element.column
            [ Element.spacing 8 ]
            [ Element.paragraph [ Element.Font.size 16, Element.Font.color blue0 ] [ Element.text "Multiple choice" ]
            , List.Nonempty.toList choices
                |> List.map
                    (\choice ->
                        checkButton (choiceToString choice) (Set.member choice selection)
                            |> Element.map (\() -> updateModel (toggleSet choice selection))
                    )
                |> Element.column [ Element.spacing 8 ]
            ]
        ]


acceptTosQuestion : Bool -> (Bool -> msg) -> msg -> Element msg
acceptTosQuestion selection toggledIAccept pressedSubmit =
    Element.column
        [ Element.width Element.fill
        , Element.Background.color blue0
        , Element.paddingXY 22 16
        , Element.Font.color white
        , Element.spacing 16
        ]
        [ titleAndSubtitle
            "Ready to submit the survey?"
            (Just "We're going to publish the results based on the information you're giving us here, so please make sure that there's nothing you wouldn't want made public in your responses. Hit \"I accept\" to acknowledge that it's all good!")
        , checkButton "I accept" selection |> Element.map (\() -> not selection |> toggledIAccept)
        , Element.Input.button
            [ Element.Background.color white
            , Element.Font.color black
            , Element.Font.bold
            , Element.padding 16
            ]
            { onPress = Just pressedSubmit
            , label = Element.text "Submit survey"
            }
        ]


titleFontSize =
    Element.Font.size 22


subtitleFontSize =
    Element.Font.size 18


type alias MultiChoiceWithOther a =
    { choices : Set a
    , otherChecked : Bool
    , otherText : String
    }


multiChoiceWithOtherInit : MultiChoiceWithOther a
multiChoiceWithOtherInit =
    { choices = Set.empty
    , otherChecked = False
    , otherText = ""
    }


titleAndSubtitle : String -> Maybe String -> Element msg
titleAndSubtitle title maybeSubtitle =
    Element.column
        [ Element.spacing 8 ]
        [ Element.paragraph [ titleFontSize, Element.Font.bold ] [ Element.text title ]
        , case maybeSubtitle of
            Just subtitle ->
                Element.paragraph [ subtitleFontSize ] [ Element.text subtitle ]

            Nothing ->
                Element.none
        ]


white : Element.Color
white =
    Element.rgb 1 1 1


black : Element.Color
black =
    Element.rgb 0 0 0


blue0 : Element.Color
blue0 =
    Element.rgb255 18 147 216


container : List (Element msg) -> Element msg
container content =
    Element.el
        [ Element.behindContent
            (Element.el
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.moveDown 8
                , Element.moveRight 8
                , Element.Background.color blue0
                ]
                Element.none
            )
        ]
        (Element.column
            [ Element.spacing 16
            , Element.Border.width 2
            , Element.Border.color blue0
            , Element.Background.color white
            , Element.padding 12
            , Element.width Element.fill
            ]
            content
        )


multiChoiceQuestionWithOther :
    String
    -> Maybe String
    -> Nonempty a
    -> (a -> String)
    -> MultiChoiceWithOther a
    -> (MultiChoiceWithOther a -> model)
    -> Element model
multiChoiceQuestionWithOther title maybeSubtitle choices choiceToString selection updateModel =
    container
        [ titleAndSubtitle title maybeSubtitle
        , Element.column
            [ Element.spacing 8 ]
            [ Element.paragraph [ Element.Font.size 16, Element.Font.color blue0 ] [ Element.text "Multiple choice" ]
            , List.Nonempty.toList choices
                |> List.map
                    (\choice ->
                        checkButton (choiceToString choice) (Set.member choice selection.choices)
                            |> Element.map
                                (\() ->
                                    updateModel
                                        { selection | choices = toggleSet choice selection.choices }
                                )
                    )
                |> (\a ->
                        a
                            ++ [ Element.row
                                    [ Element.spacing 8, Element.width Element.fill ]
                                    [ checkButton "Other" selection.otherChecked
                                        |> Element.map (\() -> updateModel { selection | otherChecked = not selection.otherChecked })
                                    , if selection.otherChecked then
                                        Element.Input.text
                                            [ Element.width Element.fill, Element.Font.size 18, Element.padding 4 ]
                                            { onChange = \text -> updateModel { selection | otherText = text }
                                            , text = selection.otherText
                                            , placeholder = Nothing
                                            , label = Element.Input.labelHidden "Other"
                                            }

                                      else
                                        Element.none
                                    ]
                               ]
                   )
                |> Element.column [ Element.spacing 8 ]
            ]
        ]


toggleSet : a -> Set a -> Set a
toggleSet a set =
    if Set.member a set then
        Set.remove a set

    else
        Set.insert a set
