module Ui exposing
    ( MultiChoiceWithOther
    , Size
    , acceptTosQuestion
    , black
    , blue0
    , blue1
    , button
    , disclaimer
    , emailAddressInput
    , headerContainer
    , ifMobile
    , multiChoiceQuestion
    , multiChoiceQuestionWithOther
    , multiChoiceWithOtherInit
    , multipleChoiceIndicator
    , singleChoiceQuestion
    , textInput
    , title
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
import List.Nonempty
import Questions exposing (Question)
import Simple.Animation
import Simple.Animation.Animated
import Simple.Animation.Property


type alias Size =
    { width : Int, height : Int }


textInput : Size -> String -> Maybe String -> String -> (String -> model) -> Element model
textInput windowSize title_ maybeSubtitle text updateModel =
    container windowSize
        [ Element.Input.multiline
            multilineAttributes
            { onChange = updateModel
            , text = text
            , placeholder = Nothing
            , label =
                Element.Input.labelAbove
                    [ Element.paddingEach { left = 0, right = 0, top = 0, bottom = 16 } ]
                    (titleAndSubtitle title_ maybeSubtitle)
            , spellcheck = True
            }
        ]


multilineAttributes : List (Element.Attribute msg)
multilineAttributes =
    [ Element.width Element.fill
    , Element.htmlAttribute (Html.Attributes.attribute "data-gramm_editor" "false")
    , Element.htmlAttribute (Html.Attributes.attribute "data-enable-grammarly" "false")
    , Element.Font.size 18
    ]


emailAddressInput : Size -> String -> (String -> model) -> Element model
emailAddressInput windowSize emailAddress updateModel =
    container windowSize
        [ titleAndSubtitle
            "What is your email address?"
            (Just "This is optional. We will only use it to notify you when the survey results are released and when future surveys happen.")
        , Element.Input.email
            multilineAttributes
            { onChange = updateModel
            , text = emailAddress
            , label = Element.Input.labelHidden "What is your email address?"
            , placeholder = Nothing
            }
        ]


singleChoiceQuestion :
    Size
    -> Question a
    -> Maybe String
    -> Maybe a
    -> (Maybe a -> model)
    -> Element model
singleChoiceQuestion windowSize question maybeSubtitle selection updateModel =
    container windowSize
        [ titleAndSubtitle question.title maybeSubtitle
        , List.Nonempty.toList question.choices
            |> List.map
                (\choice ->
                    radioButton question.title (question.choiceToString choice) (Just choice == selection)
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
    Size
    -> Question a
    -> Maybe String
    -> Set a
    -> (Set a -> model)
    -> Element model
multiChoiceQuestion windowSize question maybeSubtitle selection updateModel =
    container windowSize
        [ titleAndSubtitle question.title maybeSubtitle
        , Element.column
            [ Element.spacing 8 ]
            [ Element.paragraph [ Element.Font.size 16, Element.Font.color blue0 ] [ Element.text "Multiple choice" ]
            , List.Nonempty.toList question.choices
                |> List.map
                    (\choice ->
                        checkButton (question.choiceToString choice) (Set.member choice selection)
                            |> Element.map (\() -> updateModel (toggleSet choice selection))
                    )
                |> Element.column []
            ]
        ]


acceptTosQuestion : Size -> Bool -> (Bool -> msg) -> msg -> Int -> Element msg
acceptTosQuestion windowSize acceptedTos toggledIAccept pressedSubmit pressSubmitCount =
    Element.el
        [ Element.Background.color blue0, Element.width Element.fill ]
        (Element.Keyed.column
            [ ifMobile windowSize (Element.paddingXY 22 24) (Element.paddingXY 34 36)
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
              , button pressedSubmit "Submit survey"
              )
            ]
        )


button : msg -> String -> Element msg
button onPress text =
    Element.Input.button
        [ Element.Background.color white
        , Element.Font.color black
        , Element.Font.bold
        , Element.padding 16
        ]
        { onPress = Just onPress
        , label = Element.text text
        }


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


headerContainer : Size -> List (Element msg) -> Element msg
headerContainer windowSize contents =
    Element.el
        [ Element.Background.color blue0
        , Element.width Element.fill
        ]
        (Element.column
            [ Element.Font.color white
            , ifMobile windowSize (Element.paddingXY 22 24) (Element.paddingXY 34 36)
            , Element.centerX
            , Element.width (Element.maximum 800 Element.fill)
            , Element.spacing 24
            ]
            (Element.paragraph
                [ Element.Font.size 48
                , Element.Font.bold
                , Element.Font.center
                ]
                [ Element.text "State of Elm 2022" ]
                :: contents
                ++ [ disclaimer ]
            )
        )


titleAndSubtitle : String -> Maybe String -> Element msg
titleAndSubtitle title_ maybeSubtitle =
    Element.column
        [ Element.spacing 8 ]
        [ title title_
        , case maybeSubtitle of
            Just subtitle ->
                Element.paragraph [ subtitleFontSize, Element.Region.heading 4 ] [ Element.text subtitle ]

            Nothing ->
                Element.none
        ]


title : String -> Element msg
title title_ =
    Element.paragraph
        [ titleFontSize, Element.Font.bold, Element.Region.heading 3 ]
        [ Element.text title_ ]


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
    Element.rgb255 38 167 246


ifMobile : Size -> a -> a -> a
ifMobile windowSize ifTrue ifFalse =
    if windowSize.width < 800 then
        ifTrue

    else
        ifFalse


container : Size -> List (Element msg) -> Element msg
container windowSize content =
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
            , Element.padding (ifMobile windowSize 12 24)
            , Element.width Element.fill
            ]
            content
        )


multipleChoiceIndicator : Element msg
multipleChoiceIndicator =
    Element.paragraph [ Element.Font.size 16, Element.Font.color blue0 ] [ Element.text "Multiple answers can be chosen" ]


multiChoiceQuestionWithOther :
    Size
    -> Question a
    -> Maybe String
    -> MultiChoiceWithOther a
    -> (MultiChoiceWithOther a -> model)
    -> Element model
multiChoiceQuestionWithOther windowSize question maybeSubtitle selection updateModel =
    container windowSize
        [ titleAndSubtitle question.title maybeSubtitle
        , Element.column
            [ Element.width Element.fill, Element.spacing 8 ]
            [ multipleChoiceIndicator
            , List.Nonempty.toList question.choices
                |> List.map
                    (\choice ->
                        checkButton (question.choiceToString choice) (Set.member choice selection.choices)
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
