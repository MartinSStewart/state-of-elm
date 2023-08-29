module Ui exposing
    ( MultiChoiceWithOther
    , Size
    , acceptTosQuestion
    , black
    , blue0
    , blue1
    , button
    , container
    , customButton
    , disclaimer
    , emailAddressInput
    , emailAddressInputId
    , githubLogo
    , headerContainer
    , ifMobile
    , multiChoiceQuestion
    , multiChoiceQuestionWithOther
    , multiChoiceWithOtherInit
    , multilineAttributes
    , multipleChoiceIndicator
    , section
    , select
    , singleChoiceQuestion
    , sourceCodeLink
    , submitSurveyButtonId
    , subtitle
    , textInput
    , title
    , titleFontSize
    , white
    )

import AssocSet as Set exposing (Set)
import Effect.Browser.Dom as Dom exposing (HtmlId)
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
import List.Extra as List
import List.Nonempty exposing (Nonempty)
import Question exposing (Question)
import Route exposing (SurveyYear)
import Simple.Animation
import Simple.Animation.Animated
import Simple.Animation.Property
import Svg
import Svg.Attributes


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
            (Element.htmlAttribute (Dom.idToAttribute emailAddressInputId) :: multilineAttributes)
            { onChange = updateModel
            , text = emailAddress
            , label = Element.Input.labelHidden "What is your email address?"
            , placeholder = Nothing
            }
        ]


emailAddressInputId : HtmlId
emailAddressInputId =
    Dom.id "emailAddressInput"


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
            ([ Html.Attributes.type_ "radio"
             , Html.Attributes.name groupName
             , Html.Events.onClick ()
             , Html.Attributes.style "transform" "translateY(-2px)"
             , Html.Attributes.style "margin" "0 8px 0 0"
             , Html.Attributes.id ("radio_" ++ groupName ++ "_" ++ text)
             ]
                ++ (if isChecked then
                        [ Html.Attributes.checked isChecked ]

                    else
                        []
                   )
            )
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
            ([ Html.Attributes.type_ "checkbox"
             , Html.Events.onClick ()
             , Html.Attributes.style "transform" "translateY(-2px)"
             , Html.Attributes.style "margin" "0 8px 0 0"
             , Html.Attributes.id ("checkbox_" ++ text)
             ]
                ++ (if isChecked then
                        [ Html.Attributes.checked isChecked ]

                    else
                        []
                   )
            )
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
              , button submitSurveyButtonId pressedSubmit "Submit survey"
              )
            ]
        )


submitSurveyButtonId : HtmlId
submitSurveyButtonId =
    Dom.id "submitSurveyId"


button : HtmlId -> msg -> String -> Element msg
button htmlId onPress text =
    Element.Input.button
        [ Element.Background.color white
        , Element.Font.color black
        , Element.Font.bold
        , Element.padding 16
        , Element.htmlAttribute (Dom.idToAttribute htmlId)
        ]
        { onPress = Just onPress
        , label = Element.text text
        }


customButton : List (Element.Attribute msg) -> HtmlId -> msg -> Element msg -> Element msg
customButton attributes htmlId onPress label =
    Element.Input.button
        (Element.htmlAttribute (Dom.idToAttribute htmlId) :: attributes)
        { onPress = Just onPress
        , label = label
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


headerContainer : Size -> SurveyYear -> List (Element msg) -> Element msg
headerContainer windowSize surveyYear contents =
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
                [ Element.text ("State of Elm " ++ Route.yearToString surveyYear) ]
                :: contents
                ++ [ disclaimer ]
            )
        )


titleAndSubtitle : String -> Maybe String -> Element msg
titleAndSubtitle title_ maybeSubtitle =
    Element.column
        [ Element.spacing 12 ]
        [ title title_
        , case maybeSubtitle of
            Just text ->
                subtitle text

            Nothing ->
                Element.none
        ]


subtitle : String -> Element msg
subtitle text =
    Element.paragraph [ subtitleFontSize, Element.Region.heading 4 ] [ Element.text text ]


title : String -> Element msg
title title_ =
    let
        fragment =
            String.replace " " "-" title_
                |> String.toLower
                |> String.filter (\char -> char == '-' || Char.isAlphaNum char)
    in
    Html.h3
        [ Html.Attributes.style "margin" "0"
        , Html.Attributes.id fragment
        ]
        [ Html.a
            [ Html.Attributes.href ("#" ++ fragment)
            , Html.Attributes.style "text-decoration" "none"
            , Html.Attributes.style "color" "inherit"
            ]
            [ Html.text title_ ]
        ]
        |> Element.html
        |> List.singleton
        |> Element.paragraph [ titleFontSize, Element.Font.bold, Element.spacing 10 ]


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


section : Size -> String -> List (Element msg) -> Element msg
section windowSize text content =
    Element.column
        [ Element.spacing 24 ]
        [ Element.paragraph
            [ Element.Region.heading 2
            , Element.Font.size 24
            , Element.Font.bold
            , Element.Font.color blue0
            ]
            [ Element.text text ]
        , Element.column
            [ Element.spacing (ifMobile windowSize 36 48) ]
            content
        ]


sourceCodeLink : Element msg
sourceCodeLink =
    Element.link
        [ Element.Font.color white
        ]
        { url = "https://github.com/MartinSStewart/state-of-elm"
        , label =
            Element.row
                [ Element.Font.size 24
                , Element.spacing 8
                ]
                [ githubLogo
                , Element.el [ Element.moveDown 2 ] (Element.text "Source")
                ]
        }


githubLogo : Element msg
githubLogo =
    Svg.svg
        [ Svg.Attributes.width "24px"
        , Svg.Attributes.height "24px"
        , Svg.Attributes.viewBox "0 0 1024 1024"
        , Svg.Attributes.version "1.1"
        ]
        [ Svg.path
            [ Svg.Attributes.d "M511.957333 12.650667C229.248 12.650667 0 241.877333 0 524.672c0 226.197333 146.688 418.090667 350.165333 485.802667 25.6 4.693333 34.944-11.093333 34.944-24.682667 0-12.16-0.426667-44.352-0.682666-87.082667-142.421333 30.933333-172.48-68.629333-172.48-68.629333C188.672 770.944 155.093333 755.2 155.093333 755.2c-46.485333-31.786667 3.52-31.146667 3.52-31.146667 51.392 3.626667 78.421333 52.778667 78.421334 52.778667 45.674667 78.229333 119.829333 55.637333 149.013333 42.538667 4.650667-33.066667 17.877333-55.658667 32.512-68.437334-113.706667-12.928-233.216-56.853333-233.216-253.056 0-55.893333 19.946667-101.589333 52.693333-137.386666-5.269333-12.949333-22.826667-65.002667 5.013334-135.509334 0 0 42.986667-13.76 140.8 52.48 40.832-11.349333 84.629333-17.024 128.170666-17.216 43.477333 0.213333 87.296 5.866667 128.192 17.237334 97.749333-66.261333 140.650667-52.48 140.650667-52.48 27.946667 70.485333 10.368 122.538667 5.098667 135.466666 32.810667 35.818667 52.629333 81.514667 52.629333 137.408 0 196.693333-119.701333 239.978667-233.770667 252.650667 18.389333 15.786667 34.773333 47.061333 34.773334 94.805333 0 68.458667-0.64 123.669333-0.64 140.458667 0 13.696 9.216 29.632 35.2 24.618667C877.44 942.570667 1024 750.784 1024 524.672 1024 241.877333 794.730667 12.650667 511.957333 12.650667z"
            , Svg.Attributes.fill "currentColor"
            ]
            []
        ]
        |> Element.html
        |> Element.el []


select : Size -> (a -> msg) -> Maybe a -> Question a -> Element msg
select windowSize onSelect selection question =
    container
        windowSize
        [ titleAndSubtitle question.title Nothing
        , Html.select
            [ Html.Attributes.style "font-size" "16px"
            , Html.Attributes.style "font-family" "inherit"
            , Html.Attributes.style "font-weight" "inherit"
            , Html.Attributes.style "color" "inherit"

            --, Html.Attributes.style "-webkit-appearance" "none"
            --, Html.Attributes.style "appearance" "none"
            , Html.Events.onInput
                (\text ->
                    String.toInt text
                        |> Maybe.withDefault 0
                        |> (\a -> List.getAt a (List.Nonempty.toList question.choices))
                        |> Maybe.withDefault (List.Nonempty.head question.choices)
                        |> onSelect
                )
            ]
            ([ Html.option
                [ Html.Attributes.selected (Nothing == selection)
                , Html.Attributes.disabled True
                , Html.Attributes.hidden True
                ]
                [ Html.text "Select a country" ]
             ]
                ++ List.indexedMap
                    (\index option ->
                        Html.option
                            [ Html.Attributes.value (String.fromInt index)
                            , Html.Attributes.selected (Just option == selection)

                            --, Html.Attributes.style "font-family" "Arial"
                            ]
                            [ Html.text (question.choiceToString option) ]
                    )
                    (List.Nonempty.toList question.choices)
            )
            |> Element.html
            |> Element.el []
        ]


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
