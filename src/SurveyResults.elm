module SurveyResults exposing
    ( Data
    , DataEntrySegments
    , DataEntryWithOtherSegments
    , Mode(..)
    , Model
    , Msg
    , Segment(..)
    , freeText
    , multiChoiceWithOther
    , singleChoiceGraph
    , update
    , view
    )

import AssocList as Dict
import AssocSet as Set exposing (Set)
import Countries exposing (Country)
import DataEntry exposing (DataEntry, DataEntryWithOther(..))
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Html
import Html.Attributes
import List.Nonempty as Nonempty exposing (Nonempty(..))
import List.Nonempty.Ancillary as Nonempty
import Questions exposing (Age, ApplicationDomains, BuildTools, DoYouUseElm, DoYouUseElmAtWork, DoYouUseElmFormat, DoYouUseElmReview, Editors, ElmResources, ElmVersion, ExperienceLevel, Frameworks, HowLargeIsTheCompany, HowLong, NewsAndDiscussions, OtherLanguages, Question, StylingTools, SurveyYears, TestTools, TestsWrittenFor, WhatLanguageDoYouUseForBackend, WhichElmReviewRulesDoYouUse)
import StringExtra
import Ui exposing (Size)


type alias Model =
    { windowSize : Size
    , data : Data
    , mode : Mode
    , segment : Segment
    }


type Msg
    = PressedModeButton Mode
    | PressedSegmentButton Segment


type Segment
    = AllUsers
    | Users
    | PotentialUsers


type alias DataEntrySegments a =
    { users : DataEntry a
    , potentialUsers : DataEntry a
    }


type alias DataEntryWithOtherSegments a =
    { users : DataEntryWithOther a
    , potentialUsers : DataEntryWithOther a
    }


type alias Data =
    { totalParticipants : Int
    , doYouUseElm : DataEntry DoYouUseElm
    , age : DataEntrySegments Age
    , functionalProgrammingExperience : DataEntrySegments ExperienceLevel
    , otherLanguages : DataEntryWithOtherSegments OtherLanguages
    , newsAndDiscussions : DataEntryWithOtherSegments NewsAndDiscussions
    , elmResources : DataEntryWithOtherSegments ElmResources
    , elmInitialInterest : DataEntryWithOtherSegments ()
    , countryLivingIn : DataEntrySegments Country
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
    , biggestPainPoint : DataEntryWithOther ()
    , whatDoYouLikeMost : DataEntryWithOther ()
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


linkAttributes =
    [ Element.Font.underline
    , Element.mouseOver [ Element.Font.color (Element.rgb255 188 227 255) ]
    ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        PressedModeButton mode ->
            { model | mode = mode }

        PressedSegmentButton segment ->
            { model | segment = segment }


view : Model -> Element Msg
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
                [ Element.Font.bold ]
                [ Element.text "The survey results are in!" ]
            , Element.paragraph
                []
                [ Element.text "Thank you to everyone who participated!"
                ]
            , Element.paragraph
                []
                [ Element.text "There was a 4 year hiatus for the State of Elm survey. Previously "
                , Element.newTabLink linkAttributes
                    { url = "https://www.brianthicks.com/post/2018/12/26/state-of-elm-2018-results/"
                    , label = Element.text "Brian Hicks"
                    }
                , Element.text " ran this survey but going forward "
                , Element.newTabLink linkAttributes
                    { url = "https://github.com/MartinSStewart/state-of-elm"
                    , label = Element.text "I'll be managing it"
                    }
                , Element.text ". Special thanks to "
                , Element.newTabLink linkAttributes
                    { url = "https://github.com/wolfadex"
                    , label = Element.text "Wolfadex"
                    }
                , Element.text " for helping categorize all the free text answers."
                ]
            ]
        , Element.column
            [ Element.width (Element.maximum 800 Element.fill)
            , Element.centerX
            , Element.spacing 24
            , Element.paddingXY 8 16
            ]
            [ simpleGraph
                model.windowSize
                False
                False
                Total
                "Number of participants"
                Element.none
                """Fewer people participated in the survey this year compared to 2018 and 2017.

It's hard to say why that is. Maybe it's because this survey was open for 20 days and 2018's survey was open for 60 days (though the number of new submissions was increasing quite slowly by the 20 day mark). Maybe the community shrank in size? Maybe Brian Hicks is just better at spreading the word than I am. Or maybe it's some combination of those factors."""
                [ { choice = "2022", count = data.totalParticipants }
                , { choice = "2018", count = 1176 }
                , { choice = "2017", count = 1170 }
                ]
            , singleChoiceGraph model.windowSize False False model.mode data.doYouUseElm Questions.doYouUseElm
            , singleChoiceSegmentGraph model.windowSize False False model.mode model.segment data.age Questions.age
            , singleChoiceSegmentGraph model.windowSize False False model.mode model.segment data.functionalProgrammingExperience Questions.experienceLevel
            , multiChoiceWithOtherSegment model.windowSize True True model.mode model.segment data.otherLanguages Questions.otherLanguages
            , multiChoiceWithOtherSegment model.windowSize False True model.mode model.segment data.newsAndDiscussions Questions.newsAndDiscussions
            , multiChoiceWithOtherSegment model.windowSize False True model.mode model.segment data.elmResources Questions.elmResources

            --, freeText model.mode model.windowSize data.elmInitialInterest Questions.initialInterestTitle
            , singleChoiceSegmentGraph model.windowSize True True model.mode model.segment data.countryLivingIn Questions.countryLivingIn
            , singleChoiceGraph model.windowSize False True model.mode data.doYouUseElmAtWork Questions.doYouUseElmAtWork
            , multiChoiceWithOther model.windowSize False True model.mode data.applicationDomains Questions.applicationDomains
            , singleChoiceGraph model.windowSize False False model.mode data.howLargeIsTheCompany Questions.howLargeIsTheCompany
            , multiChoiceWithOther model.windowSize True True model.mode data.whatLanguageDoYouUseForBackend Questions.whatLanguageDoYouUseForBackend
            , singleChoiceGraph model.windowSize False False model.mode data.howLong Questions.howLong
            , multiChoiceWithOther model.windowSize False False model.mode data.elmVersion Questions.elmVersion
            , singleChoiceGraph model.windowSize False True model.mode data.doYouUseElmFormat Questions.doYouUseElmFormat
            , multiChoiceWithOther model.windowSize False True model.mode data.stylingTools Questions.stylingTools
            , multiChoiceWithOther model.windowSize False True model.mode data.buildTools Questions.buildTools
            , multiChoiceWithOther model.windowSize False True model.mode data.frameworks Questions.frameworks
            , multiChoiceWithOther model.windowSize False True model.mode data.editors Questions.editors
            , singleChoiceGraph model.windowSize False True model.mode data.doYouUseElmReview Questions.doYouUseElmReview

            --, freeText model.mode model.windowSize data.biggestPainPoint Questions.biggestPainPointTitle
            --, freeText model.mode model.windowSize data.whatDoYouLikeMost Questions.whatDoYouLikeMostTitle
            ]
        ]


multiChoiceWithOtherSegment : Size -> Bool -> Bool -> Mode -> Segment -> DataEntryWithOtherSegments a -> Question a -> Element Msg
multiChoiceWithOtherSegment windowSize singleLine sortValues mode segment segmentData { title, choices, choiceToString } =
    let
        (DataEntryWithOther dataEntryWithOther) =
            case segment of
                AllUsers ->
                    Debug.todo ""

                Users ->
                    segmentData.users

                PotentialUsers ->
                    segmentData.potentialUsers

        otherKey =
            "Other"

        dataEntry =
            Dict.remove otherKey dataEntryWithOther.data

        maybeOther =
            Dict.get otherKey dataEntryWithOther.data
    in
    Dict.toList dataEntry
        |> List.map (\( groupName, count ) -> { choice = groupName, count = count })
        |> (if sortValues then
                List.sortBy (\{ count } -> -count)

            else
                identity
           )
        |> (\a ->
                case maybeOther of
                    Just count ->
                        a ++ [ { choice = otherKey, count = count } ]

                    Nothing ->
                        a
           )
        |> simpleGraph
            windowSize
            singleLine
            True
            mode
            title
            (percentVsTotalAndSegment mode segment)
            dataEntryWithOther.comment


percentVsTotal : Mode -> Element Msg
percentVsTotal mode =
    Element.row
        []
        [ filterButton (mode == Percentage) Left (PressedModeButton Percentage) "% of answers"
        , filterButton (mode == Total) Right (PressedModeButton Total) "Total"
        ]


segmentFilter : Segment -> Element Msg
segmentFilter segment =
    Element.row
        []
        [ filterButton (segment == AllUsers) Left (PressedSegmentButton AllUsers) "All users"
        , filterButton (segment == Users) Middle (PressedSegmentButton Users) "Use(d) Elm"
        , filterButton (segment == PotentialUsers) Right (PressedSegmentButton PotentialUsers) "Potential users"
        ]


percentVsTotalAndSegment : Mode -> Segment -> Element Msg
percentVsTotalAndSegment mode segment =
    Element.wrappedRow
        [ Element.spacingXY 16 8 ]
        [ percentVsTotal mode, segmentFilter segment ]


type Side
    = Left
    | Middle
    | Right


filterButton : Bool -> Side -> msg -> String -> Element msg
filterButton isSelected side onPress label =
    Element.Input.button
        [ (case side of
            Left ->
                { topLeft = 4, bottomLeft = 4, topRight = 0, bottomRight = 0 }

            Middle ->
                { topLeft = 0, bottomLeft = 0, topRight = 0, bottomRight = 0 }

            Right ->
                { topLeft = 0, bottomLeft = 0, topRight = 4, bottomRight = 4 }
          )
            |> Element.Border.roundEach
        , Element.Border.color Ui.black
        , (case side of
            Left ->
                { left = 1, right = 1, top = 1, bottom = 1 }

            Middle ->
                { left = 0, right = 1, top = 1, bottom = 1 }

            Right ->
                { left = 0, right = 1, top = 1, bottom = 1 }
          )
            |> Element.Border.widthEach
        , Element.paddingXY 4 8
        , Element.Font.size 16
        , (if isSelected then
            Ui.blue1

           else
            Element.rgba 0 0 0 0
          )
            |> Element.Background.color
        , (if isSelected then
            Ui.white

           else
            Ui.black
          )
            |> Element.Font.color
        ]
        { onPress = Just onPress
        , label = Element.text label
        }


multiChoiceWithOther : Size -> Bool -> Bool -> Mode -> DataEntryWithOther a -> Question a -> Element Msg
multiChoiceWithOther windowSize singleLine sortValues mode (DataEntryWithOther dataEntryWithOther) { title, choices, choiceToString } =
    let
        otherKey =
            "Other"

        dataEntry =
            Dict.remove otherKey dataEntryWithOther.data

        maybeOther =
            Dict.get otherKey dataEntryWithOther.data
    in
    Dict.toList dataEntry
        |> List.map (\( groupName, count ) -> { choice = groupName, count = count })
        |> (if sortValues then
                List.sortBy (\{ count } -> -count)

            else
                identity
           )
        |> (\a ->
                case maybeOther of
                    Just count ->
                        a ++ [ { choice = otherKey, count = count } ]

                    Nothing ->
                        a
           )
        |> simpleGraph windowSize singleLine True mode title (percentVsTotal mode) dataEntryWithOther.comment


commentView : String -> Element msg
commentView comment =
    Html.div
        [ Html.Attributes.style "white-space" "pre-wrap"
        , Html.Attributes.style "line-height" "22px"
        , Html.Attributes.style "font-size" "18px"
        ]
        [ Html.text comment ]
        |> Element.html
        |> Element.el [ Element.paddingEach { left = 0, right = 0, top = 8, bottom = 0 } ]



--Element.paragraph
--    [ Element.paddingEach { left = 0, right = 0, top = 8, bottom = 0 }
--    , Element.Font.size 18
--    ]
--    [ Element.text comment ]


freeText : Mode -> Size -> DataEntryWithOther a -> String -> Element msg
freeText mode windowSize (DataEntryWithOther dataEntryWithOther) title =
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
            (\{ choice, count } -> barAndName mode choice count total maxCount)
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


barAndName : Mode -> String -> Int -> Int -> Int -> Element msg
barAndName mode name count total maxCount =
    Element.column
        [ Element.width Element.fill, Element.spacing 1 ]
        [ Element.paragraph [ Element.Font.size 16 ] [ Element.text name ]
        , Element.el [ Element.width Element.fill, Element.height (Element.px 24) ] (bar mode count total maxCount)
        ]


bar : Mode -> Int -> Int -> Int -> Element msg
bar mode count total maxCount =
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
            , (case mode of
                Percentage ->
                    percentage ++ "%"

                Total ->
                    String.fromInt count
              )
                |> Element.text
                |> Element.el [ Element.moveRight 4, Element.centerY ]
                |> Element.onRight
            ]
            Element.none
        , Element.el
            [ Element.fillPortion (a * (maxCount - count)) |> Element.width ]
            Element.none
        ]


type Mode
    = Percentage
    | Total


simpleGraph : Size -> Bool -> Bool -> Mode -> String -> Element msg -> String -> List { choice : String, count : Int } -> Element msg
simpleGraph windowSize singleLine isMultiChoice mode title filterUi comment data =
    let
        maxCount =
            List.map .count data |> List.maximum |> Maybe.withDefault 1 |> max 1

        total =
            List.map .count data |> List.sum |> max 1
    in
    container
        windowSize
        [ Element.column
            [ Element.spacing 8 ]
            [ Ui.title title
            , filterUi
            ]
        , if isMultiChoice then
            Ui.multipleChoiceIndicator

          else
            Element.none
        , if singleLine then
            Element.table
                [ Element.width Element.fill ]
                { data = data
                , columns =
                    [ { header = Element.none
                      , width = Element.shrink
                      , view =
                            \{ choice } ->
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
                                    (bar mode count total maxCount)
                      }
                    ]
                }

          else
            List.map
                (\{ choice, count } -> barAndName mode choice count total maxCount)
                data
                |> Element.column [ Element.width Element.fill, Element.spacing 8 ]
        , commentView comment
        ]


singleChoiceSegmentGraph : Size -> Bool -> Bool -> Mode -> Segment -> DataEntrySegments a -> Question a -> Element Msg
singleChoiceSegmentGraph windowSize singleLine sortValues mode segment segmentData { title, choices, choiceToString } =
    let
        dataEntry =
            case segment of
                AllUsers ->
                    DataEntry.combineDataEntries segmentData.users segmentData.potentialUsers

                Users ->
                    segmentData.users

                PotentialUsers ->
                    segmentData.potentialUsers

        data =
            DataEntry.get choices dataEntry

        emptyChoices : Set a
        emptyChoices =
            DataEntry.combineDataEntries segmentData.users segmentData.potentialUsers
                |> DataEntry.get choices
                |> Nonempty.toList
                |> List.filterMap
                    (\{ choice, count } ->
                        if count == 0 then
                            Just choice

                        else
                            Nothing
                    )
                |> Set.fromList
    in
    simpleGraph
        windowSize
        singleLine
        False
        mode
        title
        (percentVsTotalAndSegment mode segment)
        (DataEntry.comment dataEntry)
        ((if sortValues then
            nonemptySortBy (\{ count } -> -count) data

          else
            data
         )
            |> Nonempty.toList
            |> List.filterMap
                (\a ->
                    if Set.member a.choice emptyChoices then
                        Nothing

                    else
                        Just { choice = choiceToString a.choice, count = a.count }
                )
        )


singleChoiceGraph : Size -> Bool -> Bool -> Mode -> DataEntry a -> Question a -> Element Msg
singleChoiceGraph windowSize singleLine sortValues mode dataEntry { title, choices, choiceToString } =
    let
        data =
            DataEntry.get choices dataEntry
    in
    simpleGraph
        windowSize
        singleLine
        False
        mode
        title
        (percentVsTotal mode)
        (DataEntry.comment dataEntry)
        ((if sortValues then
            nonemptySortBy (\{ count } -> -count) data

          else
            data
         )
            |> Nonempty.map (\a -> { choice = choiceToString a.choice, count = a.count })
            |> Nonempty.toList
        )


nonemptySortBy sortFunc nonempty =
    Nonempty.toList nonempty
        |> List.sortBy sortFunc
        |> Nonempty.fromList
        |> Maybe.withDefault (Nonempty.head nonempty |> Nonempty.singleton)
