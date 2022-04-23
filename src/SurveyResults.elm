module SurveyResults exposing (Data, Model, freeText, multiChoiceWithOther, singleChoiceGraph, view)

import AssocList as Dict
import Countries exposing (Country)
import DataEntry exposing (DataEntry, DataEntryWithOther(..))
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import List.Nonempty as Nonempty
import List.Nonempty.Ancillary as Nonempty
import Questions exposing (Age, ApplicationDomains, BuildTools, DoYouUseElm, DoYouUseElmAtWork, DoYouUseElmFormat, DoYouUseElmReview, Editors, ElmResources, ElmVersion, ExperienceLevel, Frameworks, HowLargeIsTheCompany, HowLong, NewsAndDiscussions, OtherLanguages, Question, StylingTools, TestTools, TestsWrittenFor, WhatLanguageDoYouUseForBackend, WhichElmReviewRulesDoYouUse)
import StringExtra
import Ui exposing (Size)


type alias Model =
    { windowSize : Size
    , data : Data
    }


type alias Data =
    { doYouUseElm : DataEntry DoYouUseElm
    , age : DataEntry Age
    , functionalProgrammingExperience : DataEntry ExperienceLevel
    , otherLanguages : DataEntryWithOther OtherLanguages
    , newsAndDiscussions : DataEntryWithOther NewsAndDiscussions
    , elmResources : DataEntryWithOther ElmResources
    , countryLivingIn : DataEntry Country
    , doYouUseElmAtWork : DataEntry DoYouUseElmAtWork
    , applicationDomains : DataEntryWithOther ApplicationDomains
    , howLargeIsTheCompany : DataEntry HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : DataEntryWithOther WhatLanguageDoYouUseForBackend
    , howLong : DataEntry HowLong
    , elmVersion : DataEntryWithOther ElmVersion
    , doYouUseElmFormat : DataEntry DoYouUseElmFormat
    , stylingTools : DataEntryWithOther StylingTools
    , buildTools : DataEntryWithOther BuildTools
    , frameworks : DataEntryWithOther Frameworks
    , editors : DataEntryWithOther Editors
    , doYouUseElmReview : DataEntry DoYouUseElmReview
    , whichElmReviewRulesDoYouUse : DataEntryWithOther WhichElmReviewRulesDoYouUse
    , testTools : DataEntryWithOther TestTools
    , testsWrittenFor : DataEntryWithOther TestsWrittenFor
    , elmInitialInterest : String
    , biggestPainPoint : String
    , whatDoYouLikeMost : String
    }


container : Size -> List (Element msg) -> Element msg
container windowSize content =
    Element.el
        [ Element.behindContent
            (Element.el
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.moveDown 8
                , Element.moveRight 8
                , Element.Background.color Ui.blue0
                ]
                Element.none
            )
        , Element.width Element.fill
        ]
        (Element.column
            [ Element.spacing 16
            , Element.Border.width 2
            , Element.Border.color Ui.blue0
            , Element.Background.color Ui.white
            , Element.padding (Ui.ifMobile windowSize 12 24)
            , Element.width Element.fill
            ]
            content
        )


view : Model -> Element msg
view model =
    let
        data =
            model.data
    in
    Element.column
        [ Element.width Element.fill ]
        [ Ui.headerContainer
            model.windowSize
            [ Element.paragraph
                []
                [ Element.text "The survey results are in!" ]
            , Element.paragraph
                []
                [ Element.text "Thank you to everyone who participated!" ]
            ]
        , Element.column
            [ Element.width (Element.maximum 800 Element.fill)
            , Element.centerX
            , Element.spacing 24
            , Element.paddingXY 8 16
            ]
            [ singleChoiceGraph model.windowSize False False data.doYouUseElm Questions.doYouUseElm
            , singleChoiceGraph model.windowSize False False data.age Questions.age
            , singleChoiceGraph model.windowSize False False data.functionalProgrammingExperience Questions.experienceLevel
            , multiChoiceWithOther model.windowSize True data.otherLanguages Questions.otherLanguages
            , multiChoiceWithOther model.windowSize False data.newsAndDiscussions Questions.newsAndDiscussions
            , multiChoiceWithOther model.windowSize False data.elmResources Questions.elmResources
            , singleChoiceGraph model.windowSize True True data.countryLivingIn Questions.countryLivingIn
            , singleChoiceGraph model.windowSize False True data.doYouUseElmAtWork Questions.doYouUseElmAtWork
            , multiChoiceWithOther model.windowSize False data.applicationDomains Questions.applicationDomains
            , singleChoiceGraph model.windowSize False False data.howLargeIsTheCompany Questions.howLargeIsTheCompany
            , multiChoiceWithOther model.windowSize True data.whatLanguageDoYouUseForBackend Questions.whatLanguageDoYouUseForBackend
            , singleChoiceGraph model.windowSize False False data.howLong Questions.howLong
            , multiChoiceWithOther model.windowSize False data.elmVersion Questions.elmVersion
            , singleChoiceGraph model.windowSize False True data.doYouUseElmFormat Questions.doYouUseElmFormat
            , multiChoiceWithOther model.windowSize False data.stylingTools Questions.stylingTools
            , multiChoiceWithOther model.windowSize False data.buildTools Questions.buildTools
            , multiChoiceWithOther model.windowSize False data.frameworks Questions.frameworks
            , multiChoiceWithOther model.windowSize False data.editors Questions.editors
            , singleChoiceGraph model.windowSize False True data.doYouUseElmReview Questions.doYouUseElmReview
            ]
        ]


multiChoiceWithOther : Size -> Bool -> DataEntryWithOther a -> Question a -> Element msg
multiChoiceWithOther windowSize singleLine (DataEntryWithOther dataEntryWithOther) { title, choices, choiceToString } =
    let
        otherKey =
            "Other"

        dataEntry =
            Dict.remove otherKey dataEntryWithOther.data

        maybeOther =
            Dict.get otherKey dataEntryWithOther.data

        data =
            Dict.toList dataEntry
                |> List.map (\( groupName, count ) -> { choice = groupName, count = count })
                |> List.sortBy (\{ count } -> -count)
                |> (\a ->
                        case maybeOther of
                            Just count ->
                                a ++ [ { choice = otherKey, count = count } ]

                            Nothing ->
                                a
                   )

        maxCount =
            List.map .count data |> List.maximum |> Maybe.withDefault 1 |> max 1

        total =
            List.map .count data |> List.sum |> max 1
    in
    container
        windowSize
        [ Ui.title title
        , Ui.multipleChoiceIndicator
        , if singleLine then
            Element.table
                [ Element.width Element.fill ]
                { data = data
                , columns =
                    [ { header = Element.none
                      , width = Element.shrink
                      , view =
                            \{ choice, count } ->
                                Element.paragraph
                                    [ Element.Font.size 16
                                    , Element.Font.alignRight
                                    , Element.paddingEach { left = 0, right = 4, top = 6, bottom = 6 }
                                    ]
                                    [ Element.text choice ]
                      }
                    , { header = Element.none
                      , width = Element.fill
                      , view =
                            \{ count } ->
                                Element.el
                                    [ Element.width Element.fill
                                    , Element.height (Element.px 24)
                                    , Element.centerY
                                    ]
                                    (bar count total maxCount)
                      }
                    ]
                }

          else
            List.map
                (\{ choice, count } -> barAndName choice count total maxCount)
                data
                |> Element.column [ Element.width Element.fill, Element.spacing 8 ]
        , commentView dataEntryWithOther.comment
        ]


commentView : String -> Element msg
commentView comment =
    Element.paragraph
        [ Element.paddingEach { left = 0, right = 0, top = 8, bottom = 0 }
        , Element.Font.size 18
        ]
        [ Element.text comment ]


freeText : DataEntryWithOther a -> String -> Element msg
freeText (DataEntryWithOther dataEntryWithOther) title =
    let
        data =
            Dict.toList dataEntryWithOther.data
                |> List.map (\( groupName, count ) -> { choice = groupName, count = count })
                |> List.sortBy (\{ count } -> -count)

        maxCount =
            List.map .count data |> List.maximum |> Maybe.withDefault 1 |> max 1

        total =
            List.map .count data |> List.sum |> max 1
    in
    Element.column
        [ Element.width Element.fill, Element.spacing 24 ]
        [ Element.paragraph [] [ Element.text title ]
        , Ui.multipleChoiceIndicator
        , List.map
            (\{ choice, count } -> barAndName choice count total maxCount)
            data
            |> Element.column [ Element.width Element.fill, Element.spacing 6 ]
        , Element.paragraph [ Element.Font.size 18 ] [ Element.text dataEntryWithOther.comment ]
        ]



--Element.column
--    [ Element.width Element.fill ]
--    [ Element.paragraph [] [ Element.text title ]
--    , Element.table
--        [ Element.width Element.fill, Element.paddingEach { left = 0, top = 0, bottom = 0, right = 48 } ]
--        { data = data
--        , columns =
--            [ { header = Element.none
--              , width = Element.shrink
--              , view =
--                    \{ choice } ->
--                        Element.paragraph
--                            [ Element.Font.alignRight, Element.Font.size 16, Element.padding 4 ]
--                            [ choice |> ellipsis ]
--              }
--            , { header = Element.none
--              , width = Element.fill
--              , view = \{ count } -> bar count total
--              }
--            ]
--        }
--    ]


barAndName : String -> Int -> Int -> Int -> Element msg
barAndName name count total maxCount =
    Element.column
        [ Element.width Element.fill, Element.spacing 1 ]
        [ Element.paragraph [ Element.Font.size 16 ] [ Element.text name ]
        , Element.el [ Element.width Element.fill, Element.height (Element.px 24) ] (bar count total maxCount)
        ]


bar : Int -> Int -> Int -> Element msg
bar count total maxCount =
    let
        a =
            10000

        percentage =
            100 * toFloat count / toFloat total |> StringExtra.removeTrailing0s 1
    in
    Element.row
        [ Element.width Element.fill
        , Element.height Element.fill
        , Element.paddingEach { left = 0, right = 40, top = 0, bottom = 0 }
        ]
        [ Element.el
            [ Element.Background.color Ui.blue0
            , Element.fillPortion (a * count) |> Element.minimum 2 |> Element.width
            , Element.height Element.fill
            , Element.Border.rounded 4
            , Element.Font.size 16
            , (percentage ++ "%")
                |> Element.text
                |> Element.el [ Element.moveRight 4, Element.centerY ]
                |> Element.onRight
            ]
            Element.none
        , Element.el
            [ Element.fillPortion (a * (maxCount - count)) |> Element.width ]
            Element.none
        ]


ellipsis : String -> Element msg
ellipsis text =
    if String.length text > 40 then
        Element.el [ Element.Font.size 14 ] (Element.text text)

    else
        Element.text text


singleChoiceGraph : Size -> Bool -> Bool -> DataEntry a -> Question a -> Element msg
singleChoiceGraph windowSize singleLine sortValues dataEntry { title, choices, choiceToString } =
    let
        data =
            DataEntry.get choices dataEntry

        maxCount =
            Nonempty.map .count data |> Nonempty.maximum |> max 1

        total =
            Nonempty.map .count data |> Nonempty.toList |> List.sum |> max 1

        sorted =
            Nonempty.toList data
                |> (if sortValues then
                        List.sortBy (\{ count } -> -count)

                    else
                        identity
                   )
                |> List.filter (\{ count } -> count > 0)
    in
    container
        windowSize
        [ Ui.title title
        , if singleLine then
            Element.table
                [ Element.width Element.fill ]
                { data = sorted
                , columns =
                    [ { header = Element.none
                      , width = Element.shrink
                      , view =
                            \{ choice, count } ->
                                Element.paragraph
                                    [ Element.Font.size 16
                                    , Element.Font.alignRight
                                    , Element.paddingEach { left = 0, right = 4, top = 6, bottom = 6 }
                                    ]
                                    [ Element.text (choiceToString choice) ]
                      }
                    , { header = Element.none
                      , width = Element.fill
                      , view =
                            \{ count } ->
                                Element.el
                                    [ Element.width Element.fill
                                    , Element.height (Element.px 24)
                                    , Element.centerY
                                    ]
                                    (bar count total maxCount)
                      }
                    ]
                }

          else
            sorted
                |> List.map
                    (\{ choice, count } ->
                        barAndName (choiceToString choice) count total maxCount
                    )
                |> Element.column [ Element.width Element.fill, Element.spacing 8 ]
        , commentView (DataEntry.comment dataEntry)
        ]
