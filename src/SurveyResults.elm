module SurveyResults exposing (Data, view)

import AssocList as Dict
import DataEntry exposing (DataEntry, DataEntryWithOther(..))
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import List.Nonempty as Nonempty
import List.Nonempty.Ancillary as Nonempty
import Questions exposing (Age, ApplicationDomains, BuildTools, DoYouUseElm, DoYouUseElmAtWork, DoYouUseElmFormat, DoYouUseElmReview, Editors, ElmResources, ElmVersion, ExperienceLevel, Frameworks, HowLargeIsTheCompany, HowLong, NewsAndDiscussions, OtherLanguages, Question, StylingTools, TestTools, TestsWrittenFor, WhatLanguageDoYouUseForBackend, WhichElmReviewRulesDoYouUse)
import StringExtra
import Ui


type alias Data =
    { doYouUseElm : DataEntry DoYouUseElm
    , age : DataEntry Age
    , functionalProgrammingExperience : DataEntry ExperienceLevel
    , otherLanguages : DataEntryWithOther OtherLanguages
    , newsAndDiscussions : DataEntryWithOther NewsAndDiscussions
    , elmResources : DataEntryWithOther ElmResources
    , countryLivingIn : String
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


view : Data -> Element msg
view data =
    Element.column
        [ Element.width (Element.maximum 800 Element.fill)
        , Element.centerX
        , Element.spacing 24
        , Element.paddingXY 8 16
        ]
        [ singleChoiceGraph True data.doYouUseElm Questions.doYouUseElm
        , singleChoiceGraph False data.age Questions.age
        , singleChoiceGraph False data.functionalProgrammingExperience Questions.experienceLevel
        , multiChoiceWithOther data.otherLanguages Questions.otherLanguages
        , multiChoiceWithOther data.newsAndDiscussions Questions.newsAndDiscussions
        , multiChoiceWithOther data.elmResources Questions.elmResources
        , singleChoiceGraph True data.doYouUseElmAtWork Questions.doYouUseElmAtWork
        , multiChoiceWithOther data.applicationDomains Questions.applicationDomains
        , singleChoiceGraph False data.howLargeIsTheCompany Questions.howLargeIsTheCompany
        , multiChoiceWithOther data.whatLanguageDoYouUseForBackend Questions.whatLanguageDoYouUseForBackend
        , singleChoiceGraph False data.howLong Questions.howLong
        , multiChoiceWithOther data.elmVersion Questions.elmVersion
        , singleChoiceGraph True data.doYouUseElmFormat Questions.doYouUseElmFormat
        , multiChoiceWithOther data.stylingTools Questions.stylingTools
        , multiChoiceWithOther data.buildTools Questions.buildTools
        , multiChoiceWithOther data.frameworks Questions.frameworks
        , multiChoiceWithOther data.editors Questions.editors
        , singleChoiceGraph True data.doYouUseElmReview Questions.doYouUseElmReview
        ]


multiChoiceWithOther : DataEntryWithOther a -> Question a -> Element msg
multiChoiceWithOther (DataEntryWithOther dataEntryWithOther) { title, choices, choiceToString } =
    let
        data =
            Dict.toList dataEntryWithOther
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
            (\{ choice, count } -> barAndName choice count total)
            data
            |> Element.column [ Element.width Element.fill, Element.spacing 6 ]
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


barAndName : String -> Int -> Int -> Element msg
barAndName name count total =
    Element.column
        [ Element.width Element.fill, Element.spacing 1 ]
        [ Element.paragraph [ Element.Font.size 16 ] [ Element.text name ]
        , Element.el [ Element.width Element.fill, Element.height (Element.px 24) ] (bar count total)
        ]


bar : Int -> Int -> Element msg
bar count total =
    let
        a =
            10000

        percentage =
            100 * toFloat count / toFloat total |> StringExtra.removeTrailing0s 1
    in
    Element.row
        [ Element.width Element.fill
        , Element.height Element.fill
        ]
        [ Element.el
            [ Element.Background.color (Element.rgb 0 0 0)
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
            [ Element.fillPortion (a * (total - count)) |> Element.width ]
            Element.none
        ]


ellipsis : String -> Element msg
ellipsis text =
    if String.length text > 40 then
        Element.el [ Element.Font.size 14 ] (Element.text text)

    else
        Element.text text


singleChoiceGraph : Bool -> DataEntry a -> Question a -> Element msg
singleChoiceGraph sortValues dataEntry { title, choices, choiceToString } =
    let
        data =
            DataEntry.get choices dataEntry

        maxCount =
            Nonempty.map .count data |> Nonempty.maximum |> max 1

        total =
            Nonempty.map .count data |> Nonempty.toList |> List.sum |> max 1
    in
    Element.column
        [ Element.width Element.fill, Element.spacing 24 ]
        [ Element.paragraph [] [ Element.text title ]
        , Nonempty.toList data
            |> (if sortValues then
                    List.sortBy (\{ count } -> -count)

                else
                    identity
               )
            |> List.map (\{ choice, count } -> barAndName (choiceToString choice) count total)
            |> Element.column [ Element.width Element.fill, Element.spacing 6 ]
        ]
