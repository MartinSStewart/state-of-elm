module Ui exposing
    ( AnswerWithOther(..)
    , MultiChoiceWithOther
    , multiChoiceQuestion
    , multiChoiceQuestionWithOther
    , multiChoiceWithOtherInit
    , singleChoiceQuestion
    , textInput
    )

import AssocSet as Set exposing (Set)
import Element exposing (Element)
import Element.Font
import Element.Input
import Html
import Html.Attributes
import Html.Events
import List.Nonempty exposing (Nonempty)


textInput : String -> Maybe String -> String -> (String -> model) -> Element model
textInput title maybeSubtitle text updateModel =
    Element.Input.multiline
        [ Element.width Element.fill
        , Element.htmlAttribute (Html.Attributes.attribute "data-gramm_editor" "false")
        , Element.htmlAttribute (Html.Attributes.attribute "data-enable-grammarly" "false")
        ]
        { onChange = updateModel
        , text = text
        , placeholder = Nothing
        , label = Element.Input.labelAbove [] (titleAndSubtitle title maybeSubtitle)
        , spellcheck = True
        }


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
    Element.column
        [ Element.spacing 16 ]
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
    let
        id =
            groupName ++ "_" ++ text
    in
    Html.div
        []
        [ Html.input
            [ Html.Attributes.type_ "radio"
            , Html.Attributes.checked isChecked
            , Html.Attributes.id id
            , Html.Attributes.name groupName
            , Html.Events.onClick ()
            ]
            []
        , Html.label [ Html.Attributes.for id ] [ Html.text text ]
        ]
        |> Element.html
        |> Element.el []


checkButton : String -> String -> Bool -> Element ()
checkButton groupName text isChecked =
    let
        id =
            groupName ++ "_" ++ text
    in
    Html.div
        []
        [ Html.input
            [ Html.Attributes.type_ "checkbox"
            , Html.Attributes.checked isChecked
            , Html.Attributes.id id
            , Html.Events.onClick ()
            ]
            []
        , Html.label [ Html.Attributes.for id ] [ Html.text text ]
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
    Element.column
        [ Element.spacing 16 ]
        [ titleAndSubtitle title maybeSubtitle
        , List.Nonempty.toList choices
            |> List.map
                (\choice ->
                    checkButton title (choiceToString choice) (Set.member choice selection)
                        |> Element.map (\() -> updateModel (toggleSet choice selection))
                )
            |> Element.column [ Element.spacing 8 ]
        ]


titleFontSize =
    Element.Font.size 20


subtitleFontSize =
    Element.Font.size 18



--
--
--singleChoiceQuestionWithOther : String -> Nonempty a -> (a -> String) -> Maybe (AnswerWithOther a) -> Element (AnswerWithOther a)
--singleChoiceQuestionWithOther title choices choiceToString selection =
--    Element.column
--        []
--        []
--
--


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
        [ Element.paragraph [ titleFontSize ] [ Element.text title ]
        , case maybeSubtitle of
            Just subtitle ->
                Element.paragraph [ subtitleFontSize ] [ Element.text subtitle ]

            Nothing ->
                Element.none
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
    Element.column
        [ Element.spacing 16 ]
        [ titleAndSubtitle title maybeSubtitle
        , List.Nonempty.toList choices
            |> List.map
                (\choice ->
                    checkButton title (choiceToString choice) (Set.member choice selection.choices)
                        |> Element.map
                            (\() ->
                                updateModel
                                    { selection | choices = toggleSet choice selection.choices }
                            )
                )
            |> (\a ->
                    a
                        ++ [ Element.row
                                [ Element.spacing 8 ]
                                [ checkButton title "Other" selection.otherChecked
                                    |> Element.map (\() -> updateModel { selection | otherChecked = not selection.otherChecked })
                                , if selection.otherChecked then
                                    Element.Input.text
                                        []
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


toggleSet : a -> Set a -> Set a
toggleSet a set =
    if Set.member a set then
        Set.remove a set

    else
        Set.insert a set
