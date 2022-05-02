module MarkdownThemed exposing (view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html
import Html.Attributes
import Markdown.Block exposing (..)
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer
import Ui


view : String -> Element msg
view markdownBody =
    let
        rendererMinimal =
            renderer
                |> (\r -> { r | heading = \data -> row [] [ paragraph [] data.children ] })
    in
    render rendererMinimal markdownBody


render : Markdown.Renderer.Renderer (Element msg) -> String -> Element msg
render chosenRenderer markdownBody =
    Markdown.Parser.parse markdownBody
        |> Result.withDefault []
        |> (\parsed ->
                parsed
                    |> Markdown.Renderer.render chosenRenderer
                    |> (\res ->
                            case res of
                                Ok elements ->
                                    elements

                                Err err ->
                                    [ text "Oops! Something went wrong rendering this page: ", text err ]
                       )
                    |> column
                        [ width fill
                        , spacing 20
                        ]
           )


renderer : Markdown.Renderer.Renderer (Element msg)
renderer =
    { heading = \data -> row [] [ heading data ]
    , paragraph = \children -> paragraph [ paddingXY 0 10 ] children
    , blockQuote =
        \children ->
            column
                [ Font.size 20
                , Font.italic
                , Border.widthEach { bottom = 0, left = 4, right = 0, top = 0 }
                , Border.color Ui.black
                , Font.color Ui.black
                , padding 10
                ]
                children
    , html = Markdown.Html.oneOf []
    , text = \s -> el [] <| text s
    , codeSpan =
        \content ->
            fromHtml <|
                Html.code
                    [ Html.Attributes.style "background-color" "rgb(235, 235, 235)"
                    , Html.Attributes.style "border-radius" "4px"
                    , Html.Attributes.style "padding" "1px 4px 1px 4px"
                    , Html.Attributes.style "font-size" "0.9em"
                    ]
                    [ Html.text content ]
    , strong = \list -> paragraph [ Font.bold ] list
    , emphasis = \list -> paragraph [ Font.italic ] list
    , hardLineBreak = fromHtml <| Html.br [] []
    , link =
        \{ title, destination } list ->
            link
                [ Font.underline
                , Font.color Ui.blue0
                ]
                { url = destination
                , label =
                    case title of
                        Just title_ ->
                            text title_

                        Nothing ->
                            paragraph [] list
                }
    , image =
        \{ alt, src, title } ->
            let
                attrs =
                    [ title |> Maybe.map (\title_ -> htmlAttribute <| Html.Attributes.attribute "title" title_) ]
                        |> justs
            in
            image
                attrs
                { src = src
                , description = alt
                }
    , unorderedList =
        \items ->
            column [ spacing 15, width fill ]
                (items
                    |> List.map
                        (\listItem ->
                            case listItem of
                                ListItem _ children ->
                                    wrappedRow
                                        [ spacing 5
                                        , paddingEach { top = 0, right = 0, bottom = 0, left = 20 }
                                        , width fill
                                        ]
                                        [ paragraph
                                            [ alignTop ]
                                            (text " • " :: children)
                                        ]
                        )
                )
    , orderedList =
        \startingIndex items ->
            column [ spacing 15, width fill ]
                (items
                    |> List.indexedMap
                        (\index itemBlocks ->
                            wrappedRow
                                [ spacing 5
                                , paddingEach { top = 0, right = 0, bottom = 0, left = 20 }
                                , width fill
                                ]
                                [ paragraph
                                    [ alignTop ]
                                    (text (String.fromInt (startingIndex + index) ++ ". ") :: itemBlocks)
                                ]
                        )
                )
    , codeBlock =
        \{ body } ->
            column
                [ Font.family [ Font.monospace ]
                , Background.color Ui.black
                , Border.rounded 5
                , padding 10
                , width fill
                , htmlAttribute <| Html.Attributes.class "preserve-white-space"
                , scrollbarX
                ]
                [ html (Html.text body)
                ]
    , thematicBreak = none
    , table = \children -> column [ width fill ] children
    , tableHeader = \children -> column [] children
    , tableBody = \children -> column [] children
    , tableRow = \children -> row [ width fill ] children
    , tableCell = \_ children -> column [ width fill ] children
    , tableHeaderCell = \_ children -> column [ width fill ] children
    , strikethrough = \children -> paragraph [ Font.strike ] children
    }


heading : { level : HeadingLevel, rawText : String, children : List (Element msg) } -> Element msg
heading { level, rawText, children } =
    paragraph
        ((case headingLevelToInt level of
            1 ->
                [ Font.size 28
                , Font.bold
                , Font.color Ui.black
                , paddingXY 0 20
                ]

            2 ->
                [ Font.color Ui.black
                , Font.size 20
                , Font.bold
                , paddingEach { top = 50, right = 0, bottom = 20, left = 0 }
                ]

            3 ->
                [ Font.color Ui.black
                , Font.size 18
                , Font.bold
                , paddingEach { top = 30, right = 0, bottom = 10, left = 0 }
                ]

            4 ->
                [ Font.color Ui.black
                , Font.size 16
                , Font.bold
                , paddingEach { top = 0, right = 0, bottom = 10, left = 0 }
                ]

            _ ->
                [ Font.size 12
                , Font.bold
                , Font.center
                , paddingXY 0 20
                ]
         )
            ++ [ Region.heading (headingLevelToInt level)
               , htmlAttribute
                    (Html.Attributes.attribute "name" (rawTextToId rawText))
               , htmlAttribute
                    (Html.Attributes.id (rawTextToId rawText))
               ]
        )
        children


rawTextToId rawText =
    rawText
        |> String.toLower
        |> String.replace " " "-"
        |> String.replace "." ""


fromHtml =
    html


justs =
    List.foldl
        (\v acc ->
            case v of
                Just el ->
                    [ el ] ++ acc

                Nothing ->
                    acc
        )
        []
