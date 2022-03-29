module Ui exposing
    ( AnswerWithOther(..)
    , MultiChoiceWithOther
    , acceptTosQuestion
    , blue0
    , blue1
    , disclaimer
    , multiChoiceQuestion
    , multiChoiceQuestionWithOther
    , multiChoiceWithOtherInit
    , searchableTextInput
    , singleChoiceQuestion
    , slider
    , textInput
    , titleFontSize
    , white
    )

import AssocSet as Set exposing (Set)
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Element.Keyed
import Element.Region
import Html
import Html.Attributes
import Html.Events
import List.Nonempty exposing (Nonempty)
import Simple.Animation
import Simple.Animation.Animated
import Simple.Animation.Property


textInput : String -> Maybe String -> String -> (String -> model) -> Element model
textInput title maybeSubtitle text updateModel =
    container
        [ Element.Input.multiline
            multilineAttributes
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


searchableTextInput : String -> Maybe String -> List String -> String -> (String -> model) -> Element model
searchableTextInput title maybeSubtitle choices text updateModel =
    let
        id =
            title ++ "_list"
    in
    container
        [ Element.Input.text
            (Element.htmlAttribute (Html.Attributes.list id) :: multilineAttributes)
            { onChange = updateModel
            , text = text
            , placeholder = Nothing
            , label =
                Element.Input.labelAbove
                    [ Element.paddingEach { left = 0, right = 0, top = 0, bottom = 16 } ]
                    (titleAndSubtitle title maybeSubtitle)
            }
        , Html.datalist
            [ Html.Attributes.id id ]
            (List.map (\choice -> Html.option [ Html.Attributes.value choice ] []) choices)
            |> Element.html
            |> Element.el []
        ]


multilineAttributes : List (Element.Attribute msg)
multilineAttributes =
    [ Element.width Element.fill
    , Element.htmlAttribute (Html.Attributes.attribute "data-gramm_editor" "false")
    , Element.htmlAttribute (Html.Attributes.attribute "data-enable-grammarly" "false")
    , Element.Font.size 18
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
            |> Element.column []
        ]


radioButton : String -> String -> Bool -> Element ()
radioButton groupName text isChecked =
    Html.label
        [ Html.Attributes.style "padding" "6px"
        , Html.Attributes.style "white-space" "normal"
        , Html.Attributes.style "line-height" "24px"
        ]
        [ Html.input
            [ Html.Attributes.type_ "radio"
            , Html.Attributes.checked isChecked
            , Html.Attributes.name groupName
            , Html.Events.onClick ()
            , Html.Attributes.style "transform" "translateY(-2px)"
            , Html.Attributes.style "margin" "0 8px 0 0"
            ]
            []
        , Html.text text
        ]
        |> Element.html
        |> Element.el []


checkButton : String -> Bool -> Element ()
checkButton text isChecked =
    Html.label
        [ Html.Attributes.style "padding" "6px"
        , Html.Attributes.style "white-space" "normal"
        , Html.Attributes.style "line-height" "24px"
        ]
        [ Html.input
            [ Html.Attributes.type_ "checkbox"
            , Html.Attributes.checked isChecked
            , Html.Events.onClick ()
            , Html.Attributes.style "transform" "translateY(-2px)"
            , Html.Attributes.style "margin" "0 8px 0 0"
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
                |> Element.column []
            ]
        ]


acceptTosQuestion : Bool -> (Bool -> msg) -> msg -> Int -> Element msg
acceptTosQuestion acceptedTos toggledIAccept pressedSubmit pressSubmitCount =
    Element.el
        [ Element.Background.color blue0, Element.width Element.fill ]
        (Element.Keyed.column
            [ Element.paddingXY 22 24
            , Element.Font.color white
            , Element.spacing 16
            , Element.centerX
            , Element.width (Element.maximum 800 Element.fill)
            ]
            [ ( "title"
              , titleAndSubtitle
                    "Ready to submit the survey?"
                    (Just "We're going to publish the results based on the information you're giving us here, so please make sure that there's nothing you wouldn't want made public in your responses. Hit\u{00A0}\"I\u{00A0}accept\" to acknowledge that it's all good!")
              )
            , ( String.fromInt pressSubmitCount
              , (if pressSubmitCount > 0 then
                    animatedUi
                        Element.el
                        (Simple.Animation.steps
                            { startAt = [ Simple.Animation.Property.x 0 ], options = [] }
                            [ Simple.Animation.step 100 [ Simple.Animation.Property.x -8 ]
                            , Simple.Animation.step 100 [ Simple.Animation.Property.x 16 ]
                            , Simple.Animation.step 100 [ Simple.Animation.Property.x 0 ]
                            ]
                        )

                 else
                    Element.el
                )
                    []
                    (checkButton "I accept" acceptedTos)
                    |> Element.map (\() -> not acceptedTos |> toggledIAccept)
              )
            , ( "submit"
              , Element.Input.button
                    [ Element.Background.color white
                    , Element.Font.color black
                    , Element.Font.bold
                    , Element.padding 16
                    ]
                    { onPress = Just pressedSubmit
                    , label = Element.text "Submit survey"
                    }
              )
            ]
        )


disclaimer : Element msg
disclaimer =
    Element.paragraph
        [ Element.Font.color white, Element.Font.size 14 ]
        [ Element.text "This is a community run survey not affiliated with Evan Czaplicki or Elm" ]


animatedUi =
    Simple.Animation.Animated.ui
        { behindContent = Element.behindContent
        , htmlAttribute = Element.htmlAttribute
        , html = Element.html
        }


titleFontSize : Element.Attr decorative msg
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
        [ Element.paragraph [ titleFontSize, Element.Font.bold, Element.Region.heading 3 ] [ Element.text title ]
        , case maybeSubtitle of
            Just subtitle ->
                Element.paragraph [ subtitleFontSize, Element.Region.heading 4 ] [ Element.text subtitle ]

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


blue1 : Element.Color
blue1 =
    Element.rgb255 183 222 243


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


slider : String -> Maybe String -> Int -> Int -> Maybe Int -> (Int -> model) -> Element model
slider title maybeSubtitle minValue maxValue maybeSelection updateModel =
    container
        [ titleAndSubtitle title maybeSubtitle
        , Element.column
            [ Element.width Element.fill, Element.spacing 16 ]
            [ Element.el
                [ Element.Font.color blue0, Element.Font.size 16 ]
                (case maybeSelection of
                    Just selection ->
                        Element.text ("You selected: " ++ String.fromInt selection)

                    Nothing ->
                        Element.text "Drag the slider"
                )
            , Element.row
                [ Element.width Element.fill, Element.spacing 8 ]
                [ Element.text (String.fromInt minValue)
                , Element.Input.slider
                    [ Element.width Element.fill
                    , Element.height (Element.px 24)
                    , Element.behindContent
                        (Element.el
                            [ Element.Background.color blue1
                            , Element.paddingXY 4 0
                            , Element.width Element.fill
                            , Element.height (Element.px 6)
                            , Element.centerY
                            ]
                            Element.none
                        )
                    ]
                    { onChange = round >> updateModel
                    , label = Element.Input.labelHidden title
                    , value = toFloat (Maybe.withDefault 0 maybeSelection)
                    , min = toFloat minValue
                    , max = toFloat maxValue
                    , step = Just 1
                    , thumb =
                        Element.Input.thumb
                            [ Element.width (Element.px 24)
                            , Element.height (Element.px 24)
                            , Element.Border.rounded 99
                            , Element.Border.width 1
                            , Element.Border.color (Element.rgb 0.5 0.5 0.5)
                            , Element.Background.color (Element.rgb 1 1 1)
                            ]
                    }
                , Element.text (String.fromInt maxValue)
                ]
            ]
        ]


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
            [ Element.width Element.fill, Element.spacing 8 ]
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
                            ++ [ Element.column
                                    [ Element.spacing 8, Element.width Element.fill ]
                                    [ Element.el [ Element.alignTop ] (checkButton "Other" selection.otherChecked)
                                        |> Element.map (\() -> updateModel { selection | otherChecked = not selection.otherChecked })
                                    , if selection.otherChecked then
                                        Element.Input.multiline
                                            multilineAttributes
                                            { onChange = \text -> updateModel { selection | otherText = text }
                                            , text = selection.otherText
                                            , placeholder = Nothing
                                            , label = Element.Input.labelHidden "Other"
                                            , spellcheck = True
                                            }

                                      else
                                        Element.none
                                    ]
                               ]
                   )
                |> Element.column [ Element.width Element.fill ]
            ]
        ]


toggleSet : a -> Set a -> Set a
toggleSet a set =
    if Set.member a set then
        Set.remove a set

    else
        Set.insert a set
