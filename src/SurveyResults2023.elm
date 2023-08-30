module SurveyResults2023 exposing
    ( Data
    , DataEntrySegments
    , DataEntryWithOtherSegments
    , Mode(..)
    , Model
    , Msg(..)
    , Segment(..)
    , freeText
    , multiChoiceWithOther
    , simpleGraph
    , singleChoiceGraph
    , update
    , view
    )

import AssocList as Dict exposing (Dict)
import AssocSet as Set exposing (Set)
import Countries exposing (Country)
import DataEntry exposing (DataEntry, DataEntryWithOther(..))
import Effect.Browser.Dom as Dom
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Html exposing (Html)
import Html.Attributes
import List.Nonempty as Nonempty exposing (Nonempty)
import MarkdownThemed
import PackageName exposing (PackageName)
import Question exposing (Question)
import Questions2023
import Route exposing (SurveyYear(..))
import StringExtra
import SurveyResults2022
import Ui exposing (Size)


type alias Model =
    { data : Data
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
    , doYouUseElm : DataEntry Questions2023.DoYouUseElm
    , age : DataEntrySegments Questions2023.Age
    , functionalProgrammingExperience : DataEntrySegments Questions2023.ExperienceLevel
    , otherLanguages : DataEntryWithOtherSegments Questions2023.OtherLanguages
    , newsAndDiscussions : DataEntryWithOtherSegments Questions2023.NewsAndDiscussions
    , elmInitialInterest : DataEntryWithOtherSegments ()
    , countryLivingIn : DataEntrySegments Country
    , elmResources : DataEntryWithOther Questions2023.ElmResources
    , doYouUseElmAtWork : DataEntry Questions2023.DoYouUseElmAtWork
    , applicationDomains : DataEntryWithOther Questions2023.ApplicationDomains
    , howLargeIsTheCompany : DataEntry Questions2023.HowLargeIsTheCompany
    , whatLanguageDoYouUseForBackend : DataEntryWithOther Questions2023.WhatLanguageDoYouUseForBackend
    , howLong : DataEntry Questions2023.HowLong
    , elmVersion : DataEntryWithOther Questions2023.ElmVersion
    , doYouUseElmFormat : DataEntry Questions2023.DoYouUseElmFormat
    , stylingTools : DataEntryWithOther Questions2023.StylingTools
    , buildTools : DataEntryWithOther Questions2023.BuildTools
    , frameworks : DataEntryWithOther Questions2023.Frameworks
    , editors : DataEntryWithOther Questions2023.Editors
    , doYouUseElmReview : DataEntry Questions2023.DoYouUseElmReview
    , testTools : DataEntryWithOther Questions2023.TestTools
    , biggestPainPoint : DataEntryWithOther ()
    , whatDoYouLikeMost : DataEntryWithOther ()
    , elmJson : Dict PackageName Int
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


css : Html msg
css =
    Html.node "style"
        []
        [ Html.text """
.linkFocus:focus {
    outline: solid #9bcbff !important;
}
"""
        ]


linkAttributes : List (Element.Attribute msg)
linkAttributes =
    [ Element.Font.underline
    , Element.mouseOver [ Element.Font.color lightBlue ]
    , Element.htmlAttribute (Html.Attributes.class "linkFocus")
    ]


lightBlue : Element.Color
lightBlue =
    Element.rgb255 188 227 255


update : Msg -> Model -> Model
update msg model =
    case msg of
        PressedModeButton mode ->
            { model | mode = mode }

        PressedSegmentButton segment ->
            { model | segment = segment }


view : { a | windowSize : Size } -> SurveyResults2022.Data -> Model -> Element Msg
view config previousYear model =
    let
        windowSize =
            config.windowSize

        data =
            model.data

        modeWithoutPerCapita =
            case model.mode of
                Percentage ->
                    Percentage

                PerCapita ->
                    Percentage

                Total ->
                    Total
    in
    Element.column
        [ Element.width Element.fill, Element.behindContent (Element.html css) ]
        [ Ui.headerContainer
            windowSize
            Year2023
            [ Element.paragraph
                [ Element.Font.bold ]
                [ Element.text "The survey results are in!" ]
            , Element.paragraph
                []
                [ Element.text "Thank you to everyone who participated! "
                , Element.link
                    [ Element.Font.underline ]
                    { url = Route.encode (Route.SurveyRoute Year2022)
                    , label = Element.text "Previous year's results."
                    }
                ]
            ]
        , Element.column
            [ Element.width (Element.maximum 800 Element.fill)
            , Element.centerX
            , Element.spacing 64
            , Element.paddingXY 8 16
            ]
            [ simpleGraph
                { windowSize = windowSize
                , singleLine = False
                , isMultiChoice = False
                , customMaxCount = Nothing
                , mode = Total
                , title = "Number of participants"
                , filterUi = Element.none
                , comment = ""
                , data =
                    [ { choice = "2023", value = toFloat data.totalParticipants }
                    , { choice = "2022", value = toFloat previousYear.totalParticipants }
                    , { choice = "2018", value = 1176 }
                    , { choice = "2017", value = 1170 }
                    , { choice = "2016", value = 644 }
                    ]
                }
            , Ui.section
                windowSize
                "About you"
                [ multiChoiceGraph windowSize False False modeWithoutPerCapita data.doYouUseElm Questions2023.doYouUseElm
                , singleChoiceSegmentGraph windowSize False False Nothing modeWithoutPerCapita model.segment data.age Questions2023.age
                , singleChoiceSegmentGraph windowSize False False Nothing modeWithoutPerCapita model.segment data.functionalProgrammingExperience Questions2023.experienceLevel
                , multiChoiceWithOtherSegment windowSize True True modeWithoutPerCapita model.segment data.otherLanguages Questions2023.otherLanguages
                , multiChoiceWithOtherSegment windowSize False True modeWithoutPerCapita model.segment data.newsAndDiscussions Questions2023.newsAndDiscussions
                , freeTextSegment modeWithoutPerCapita model.segment windowSize data.elmInitialInterest Questions2023.initialInterestTitle
                , singleChoiceSegmentGraph windowSize True True (Just countryPopulation) model.mode model.segment data.countryLivingIn Questions2023.countryLivingIn
                ]
            , Ui.section
                windowSize
                "Questions for people who use(d) Elm"
                [ multiChoiceWithOther windowSize False True modeWithoutPerCapita data.elmResources Questions2023.elmResources
                , singleChoiceGraph windowSize False True modeWithoutPerCapita data.doYouUseElmAtWork Questions2023.doYouUseElmAtWork
                , multiChoiceWithOther windowSize False True modeWithoutPerCapita data.applicationDomains Questions2023.applicationDomains
                , singleChoiceGraph windowSize False False modeWithoutPerCapita data.howLargeIsTheCompany Questions2023.howLargeIsTheCompany
                , multiChoiceWithOther windowSize True True modeWithoutPerCapita data.whatLanguageDoYouUseForBackend Questions2023.whatLanguageDoYouUseForBackend
                , singleChoiceGraph windowSize False False modeWithoutPerCapita data.howLong Questions2023.howLong
                , multiChoiceWithOther windowSize False False modeWithoutPerCapita data.elmVersion Questions2023.elmVersion
                , singleChoiceGraph windowSize False True modeWithoutPerCapita data.doYouUseElmFormat Questions2023.doYouUseElmFormat
                , multiChoiceWithOther windowSize False True modeWithoutPerCapita data.stylingTools Questions2023.stylingTools
                , multiChoiceWithOther windowSize False True modeWithoutPerCapita data.buildTools Questions2023.buildTools
                , multiChoiceWithOther windowSize False True modeWithoutPerCapita data.frameworks Questions2023.frameworks
                , multiChoiceWithOther windowSize False True modeWithoutPerCapita data.editors Questions2023.editors
                , singleChoiceGraph windowSize False True modeWithoutPerCapita data.doYouUseElmReview Questions2023.doYouUseElmReview
                , multiChoiceWithOther windowSize False True modeWithoutPerCapita data.testTools Questions2023.testTools
                , freeText modeWithoutPerCapita windowSize data.biggestPainPoint Questions2023.biggestPainPointTitle
                , freeText modeWithoutPerCapita windowSize data.whatDoYouLikeMost Questions2023.whatDoYouLikeMostTitle
                ]
            ]
        , Element.el
            [ Element.Background.color Ui.blue0
            , Element.width Element.fill
            ]
            (Element.column
                [ Element.Font.color Ui.white
                , Ui.ifMobile windowSize (Element.paddingXY 22 24) (Element.paddingXY 34 36)
                , Element.centerX
                , Element.width (Element.maximum 800 Element.fill)
                , Element.spacing 24
                ]
                [ Element.paragraph [ Element.Font.bold ] [ Element.text "That's all folks!" ]
                , Element.paragraph [] [ Element.text "Thanks again for participating!" ]
                , Element.paragraph [] [ Element.text "The plan is to start running State of Elm annually again. I'll make an announcement post on Elm Discourse and Elm Slack when the time comes for the next one." ]
                , Ui.sourceCodeLink
                , Ui.disclaimer
                ]
            )
        ]


multiChoiceWithOtherSegment : Size -> Bool -> Bool -> Mode -> Segment -> DataEntryWithOtherSegments a -> Question a -> Element Msg
multiChoiceWithOtherSegment windowSize singleLine sortValues mode segment segmentData { title } =
    multiChoiceSegmentHelper windowSize singleLine sortValues mode segment segmentData title


multiChoiceSegmentHelper : Size -> Bool -> Bool -> Mode -> Segment -> DataEntryWithOtherSegments a -> String -> Element Msg
multiChoiceSegmentHelper windowSize singleLine sortValues mode segment segmentData title =
    let
        dataEntryWithOther =
            (case segment of
                AllUsers ->
                    DataEntry.combineDataEntriesWithOther segmentData.users segmentData.potentialUsers

                Users ->
                    segmentData.users

                PotentialUsers ->
                    segmentData.potentialUsers
            )
                |> DataEntry.get_

        otherKey =
            "Other"

        total =
            Dict.values dataEntryWithOther.data |> List.sum

        dataEntry =
            Dict.remove otherKey dataEntryWithOther.data

        maybeOther =
            Dict.get otherKey dataEntryWithOther.data

        emptyChoices : Set String
        emptyChoices =
            DataEntry.combineDataEntriesWithOther segmentData.users segmentData.potentialUsers
                |> (\(DataEntryWithOther a) -> a.data)
                |> Dict.filter (\_ count -> count == 0)
                |> Dict.keys
                |> Set.fromList
    in
    simpleGraph
        { windowSize = windowSize
        , singleLine = singleLine
        , isMultiChoice = True
        , customMaxCount = maxCountSegment mode segmentData |> Just
        , mode = mode
        , title = title
        , filterUi = percentVsTotalAndSegment False mode segment
        , comment = dataEntryWithOther.comment
        , data =
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
                |> List.filter (\{ choice } -> Set.member choice emptyChoices |> not)
                |> List.map (\{ choice, count } -> { choice = choice, value = getValue mode count total False })
        }


multiChoiceHelper : Size -> Bool -> Bool -> Mode -> DataEntryWithOther a -> String -> Element Msg
multiChoiceHelper windowSize singleLine sortValues mode dataEntryWithOther title =
    let
        otherKey =
            "Other"

        total =
            Dict.values (DataEntry.get_ dataEntryWithOther).data |> List.sum

        dataEntry =
            Dict.remove otherKey (DataEntry.get_ dataEntryWithOther).data

        maybeOther =
            Dict.get otherKey (DataEntry.get_ dataEntryWithOther).data
    in
    simpleGraph
        { windowSize = windowSize
        , singleLine = singleLine
        , isMultiChoice = True
        , customMaxCount = Nothing
        , mode = mode
        , title = title
        , filterUi = percentVsTotal mode
        , comment = (DataEntry.get_ dataEntryWithOther).comment
        , data =
            Dict.toList dataEntry
                |> List.map (\( groupName, count ) -> { choice = groupName, count = count })
                |> List.reverse
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
                |> List.map (\{ choice, count } -> { choice = choice, value = getValue mode count total False })
        }


percentVsTotal : Mode -> Element Msg
percentVsTotal mode =
    Element.row
        []
        [ filterButton (mode == Percentage || mode == PerCapita) Left (PressedModeButton Percentage) "% of answers"
        , filterButton (mode == Total) Right (PressedModeButton Total) "Total"
        ]


percentVsPerCapitaVsTotal : Mode -> Element Msg
percentVsPerCapitaVsTotal mode =
    Element.row
        []
        [ filterButton (mode == Percentage) Left (PressedModeButton Percentage) "% of answers"
        , filterButton (mode == PerCapita) Middle (PressedModeButton PerCapita) "Per capita"
        , filterButton (mode == Total) Right (PressedModeButton Total) "Total"
        ]


segmentFilter : Segment -> Element Msg
segmentFilter segment =
    Element.row
        []
        [ filterButton (segment == AllUsers) Left (PressedSegmentButton AllUsers) "All users"
        , filterButton (segment == Users) Middle (PressedSegmentButton Users) "Use(d) Elm"
        , filterButton (segment == PotentialUsers) Right (PressedSegmentButton PotentialUsers) "Considering Elm"
        ]


percentVsTotalAndSegment : Bool -> Mode -> Segment -> Element Msg
percentVsTotalAndSegment includePerCapita mode segment =
    Element.wrappedRow
        [ Element.spacingXY 16 8 ]
        [ if includePerCapita then
            percentVsPerCapitaVsTotal mode

          else
            percentVsTotal mode
        , segmentFilter segment
        ]


type Side
    = Left
    | Middle
    | Right


filterButton : Bool -> Side -> msg -> String -> Element msg
filterButton isSelected side onPress label =
    Element.Input.button
        [ Element.htmlAttribute (Dom.idToAttribute (Dom.id label))
        , (case side of
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
        , Element.mouseOver
            (if isSelected then
                []

             else
                [ Element.Background.color lightBlue ]
            )
        , Element.paddingXY 6 8
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
multiChoiceWithOther windowSize singleLine sortValues mode dataEntryWithOther { title } =
    multiChoiceHelper windowSize singleLine sortValues mode dataEntryWithOther title


commentView : String -> Element msg
commentView comment =
    MarkdownThemed.view comment


freeTextSegment : Mode -> Segment -> Size -> DataEntryWithOtherSegments () -> String -> Element Msg
freeTextSegment mode segment windowSize segmentData title =
    multiChoiceSegmentHelper windowSize False True mode segment segmentData title


maxCountSegment : Mode -> DataEntryWithOtherSegments a -> Float
maxCountSegment mode segmentData =
    case mode of
        Percentage ->
            [ segmentData.users
            , segmentData.potentialUsers
            , DataEntry.combineDataEntriesWithOther segmentData.users segmentData.potentialUsers
            ]
                |> List.concatMap
                    (\a ->
                        let
                            data : List Int
                            data =
                                (DataEntry.get_ a).data |> Dict.values

                            total =
                                List.sum data
                        in
                        List.map (\value -> 100 * toFloat value / toFloat total) data
                    )
                |> List.maximum
                |> Maybe.withDefault 1

        PerCapita ->
            1

        Total ->
            [ segmentData.users
            , segmentData.potentialUsers
            , DataEntry.combineDataEntriesWithOther segmentData.users segmentData.potentialUsers
            ]
                |> List.concatMap (DataEntry.get_ >> .data >> Dict.values)
                |> List.maximum
                |> Maybe.withDefault 1
                |> toFloat


freeText : Mode -> Size -> DataEntryWithOther () -> String -> Element Msg
freeText mode windowSize dataEntryWithOther title =
    multiChoiceHelper windowSize False True mode dataEntryWithOther title


getValue : Mode -> Int -> Int -> Bool -> Float
getValue mode count total includePerCapita =
    case mode of
        Percentage ->
            100 * toFloat count / toFloat total

        PerCapita ->
            if includePerCapita then
                toFloat count / 1000

            else
                100 * toFloat count / toFloat total

        Total ->
            toFloat count


barAndName : Mode -> String -> Float -> Float -> Element msg
barAndName mode name value maxCount =
    Element.column
        [ Element.width Element.fill, Element.spacing 1 ]
        [ Element.paragraph [ Element.Font.size 16 ] [ Element.text name ]
        , Element.el [ Element.width Element.fill, Element.height (Element.px 24) ] (bar mode value maxCount)
        ]


barRightPadding : number
barRightPadding =
    40


bar : Mode -> Float -> Float -> Element msg
bar mode value maxCount =
    let
        a =
            100000

        textValue =
            case mode of
                Percentage ->
                    StringExtra.removeTrailing0s 1 value ++ "%"

                PerCapita ->
                    StringExtra.removeTrailing0s 2 value

                Total ->
                    String.fromFloat value
    in
    Element.row
        [ Element.width Element.fill
        , Element.height Element.fill
        , Element.paddingEach { left = 0, right = barRightPadding, top = 0, bottom = 0 }
        ]
        [ Element.el
            [ Element.Background.color Ui.blue0
            , a * value |> round |> Element.fillPortion |> Element.minimum 2 |> Element.width
            , Element.height Element.fill
            , Element.Border.rounded 4
            , Element.Font.size 16
            , Element.text textValue
                |> Element.el [ Element.moveRight 4, Element.centerY ]
                |> Element.onRight
            ]
            Element.none
        , Element.el
            [ a * (maxCount - value) |> round |> Element.fillPortion |> Element.width ]
            Element.none
        ]


type Mode
    = Percentage
    | PerCapita
    | Total


simpleGraph :
    { windowSize : Size
    , singleLine : Bool
    , isMultiChoice : Bool
    , customMaxCount : Maybe Float
    , mode : Mode
    , title : String
    , filterUi : Element msg
    , comment : String
    , data : List { choice : String, value : Float }
    }
    -> Element msg
simpleGraph { windowSize, singleLine, isMultiChoice, customMaxCount, mode, title, filterUi, comment, data } =
    let
        maxCount : Float
        maxCount =
            case customMaxCount of
                Just maxCount_ ->
                    maxCount_

                Nothing ->
                    List.map .value data |> List.maximum |> Maybe.withDefault 1 |> max 1
    in
    container
        windowSize
        [ Element.column
            [ Element.spacing 12 ]
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
                            \{ value } ->
                                Element.el
                                    [ Element.width Element.fill
                                    , Element.height (Element.px 24)
                                    , Element.centerY
                                    ]
                                    (bar mode value maxCount)
                      }
                    ]
                }

          else
            List.map
                (\{ choice, value } -> barAndName mode choice value maxCount)
                data
                |> Element.column
                    [ Element.width Element.fill
                    , Element.spacing 8
                    ]
        , commentView comment
        ]


singleChoiceSegmentGraph : Size -> Bool -> Bool -> Maybe (a -> Int) -> Mode -> Segment -> DataEntrySegments a -> Question a -> Element Msg
singleChoiceSegmentGraph windowSize singleLine sortValues includePerCapita mode segment segmentData { title, choices, choiceToString } =
    let
        dataEntry =
            case segment of
                AllUsers ->
                    DataEntry.combineDataEntries segmentData.users segmentData.potentialUsers

                Users ->
                    segmentData.users

                PotentialUsers ->
                    segmentData.potentialUsers

        data : Nonempty { choice : a, count : Int }
        data =
            DataEntry.get choices dataEntry

        total : Int
        total =
            Nonempty.toList data |> List.map .count |> List.sum

        maxCount : Float
        maxCount =
            case mode of
                Percentage ->
                    [ segmentData.users
                    , segmentData.potentialUsers
                    , DataEntry.combineDataEntries segmentData.users segmentData.potentialUsers
                    ]
                        |> List.concatMap
                            (\a ->
                                let
                                    data_ : List Int
                                    data_ =
                                        DataEntry.get choices a |> Nonempty.toList |> List.map .count

                                    total_ =
                                        List.sum data_
                                in
                                List.map (\value -> 100 * toFloat value / toFloat total_) data_
                            )
                        |> List.maximum
                        |> Maybe.withDefault 1

                PerCapita ->
                    [ segmentData.users
                    , segmentData.potentialUsers
                    , DataEntry.combineDataEntries segmentData.users segmentData.potentialUsers
                    ]
                        |> List.concatMap
                            (DataEntry.get choices
                                >> Nonempty.toList
                                >> List.map
                                    (\{ choice, count } ->
                                        case includePerCapita of
                                            Just perCapitaFunction ->
                                                (1000000 * count) // perCapitaFunction choice

                                            Nothing ->
                                                count
                                    )
                            )
                        |> List.maximum
                        |> Maybe.withDefault 1
                        |> toFloat

                Total ->
                    [ segmentData.users
                    , segmentData.potentialUsers
                    , DataEntry.combineDataEntries segmentData.users segmentData.potentialUsers
                    ]
                        |> List.concatMap (DataEntry.get choices >> Nonempty.toList >> List.map .count)
                        |> List.maximum
                        |> Maybe.withDefault 1
                        |> toFloat

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
        { windowSize = windowSize
        , singleLine = singleLine
        , isMultiChoice = False
        , customMaxCount = Just maxCount
        , mode = mode
        , title = title
        , filterUi = percentVsTotalAndSegment (includePerCapita /= Nothing) mode segment
        , comment = DataEntry.comment dataEntry
        , data =
            Nonempty.toList data
                |> List.filterMap
                    (\a ->
                        if Set.member a.choice emptyChoices then
                            Nothing

                        else
                            Just
                                { choice = choiceToString a.choice
                                , value =
                                    let
                                        count =
                                            case ( includePerCapita, mode ) of
                                                ( Just perCapitaFunction, PerCapita ) ->
                                                    (1000000000 * a.count) // perCapitaFunction a.choice

                                                _ ->
                                                    a.count
                                    in
                                    getValue mode count total (includePerCapita /= Nothing)
                                }
                    )
                |> (if sortValues then
                        List.sortBy (\{ value } -> -value)

                    else
                        identity
                   )
        }


{-| Sourced from <https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population>
-}
countryPopulation : Country -> Int
countryPopulation country =
    case country.code of
        "US" ->
            332653266

        "DE" ->
            83222442

        "GB" ->
            67081000

        "FR" ->
            67841000

        "NL" ->
            17716681

        "AU" ->
            25990538

        "SE" ->
            10462498

        "CA" ->
            38669438

        "NO" ->
            5425270

        "PL" ->
            38057000

        "ES" ->
            47326687

        "BR" ->
            214575895

        "DK" ->
            5873420

        "IT" ->
            58952787

        "BE" ->
            11629213

        "CZ" ->
            10516707

        "CH" ->
            8736500

        "AT" ->
            9027999

        "IN" ->
            1375836525

        "FI" ->
            5550066

        "JP" ->
            125502000

        "PT" ->
            10347892

        "IL" ->
            9510140

        "RO" ->
            19186201

        "AR" ->
            45808747

        "HU" ->
            9689000

        "ZA" ->
            60142978

        "CN" ->
            1412600000

        "EC" ->
            17969808

        "ID" ->
            272248500

        "MX" ->
            127996051

        "RU" ->
            145478097

        "SG" ->
            5453600

        "SI" ->
            2108977

        "CO" ->
            51049498

        "EE" ->
            1330068

        "IE" ->
            5011500

        "PH" ->
            111824794

        "TR" ->
            84680273

        "UA" ->
            41130432

        "UY" ->
            3554915

        "AM" ->
            2963900

        "BA" ->
            3320954

        "BD" ->
            172642054

        "CY" ->
            888005

        "GH" ->
            30832019

        "IR" ->
            85401767

        "KE" ->
            47564296

        "NZ" ->
            5137444

        "PR" ->
            3285874

        "RS" ->
            6871547

        "TH" ->
            66782717

        "TT" ->
            1367558

        "VE" ->
            28705000

        "VN" ->
            98505400

        "BY" ->
            9349645

        "CL" ->
            19678363

        "GR" ->
            10678632

        "LT" ->
            2794961

        "MY" ->
            32712600

        "SK" ->
            5434712

        _ ->
            1


multiChoiceGraph : Size -> Bool -> Bool -> Mode -> DataEntry a -> Question a -> Element Msg
multiChoiceGraph windowSize singleLine sortValues mode dataEntry { title, choices, choiceToString } =
    let
        data =
            DataEntry.get choices dataEntry

        total =
            Nonempty.toList data |> List.map .count |> List.sum
    in
    simpleGraph
        { windowSize = windowSize
        , singleLine = singleLine
        , isMultiChoice = True
        , customMaxCount = Nothing
        , mode = mode
        , title = title
        , filterUi = percentVsTotal mode
        , comment = DataEntry.comment dataEntry
        , data =
            (if sortValues then
                nonemptySortBy (\{ count } -> -count) data

             else
                data
            )
                |> Nonempty.map (\a -> { choice = choiceToString a.choice, count = a.count })
                |> Nonempty.toList
                |> List.filter (\{ count } -> count > 0)
                |> List.map
                    (\{ choice, count } ->
                        { choice = choice
                        , value = getValue mode count total False
                        }
                    )
        }


singleChoiceGraph : Size -> Bool -> Bool -> Mode -> DataEntry a -> Question a -> Element Msg
singleChoiceGraph windowSize singleLine sortValues mode dataEntry { title, choices, choiceToString } =
    let
        data =
            DataEntry.get choices dataEntry

        total =
            Nonempty.toList data |> List.map .count |> List.sum
    in
    simpleGraph
        { windowSize = windowSize
        , singleLine = singleLine
        , isMultiChoice = False
        , customMaxCount = Nothing
        , mode = mode
        , title = title
        , filterUi = percentVsTotal mode
        , comment = DataEntry.comment dataEntry
        , data =
            (if sortValues then
                nonemptySortBy (\{ count } -> -count) data

             else
                data
            )
                |> Nonempty.map (\a -> { choice = choiceToString a.choice, count = a.count })
                |> Nonempty.toList
                |> List.filter (\{ count } -> count > 0)
                |> List.map
                    (\{ choice, count } ->
                        { choice = choice
                        , value = getValue mode count total False
                        }
                    )
        }


nonemptySortBy : (a -> comparable) -> Nonempty a -> Nonempty a
nonemptySortBy sortFunc nonempty =
    Nonempty.toList nonempty
        |> List.sortBy sortFunc
        |> Nonempty.fromList
        |> Maybe.withDefault (Nonempty.head nonempty |> Nonempty.singleton)
