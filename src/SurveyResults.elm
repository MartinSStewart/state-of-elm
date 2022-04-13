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
        [ Element.width Element.fill, Element.spacing 24, Element.paddingXY 0 16 ]
        [ singleChoiceGraph data.doYouUseElm Questions.doYouUseElm
        , singleChoiceGraph data.age Questions.age
        , singleChoiceGraph data.functionalProgrammingExperience Questions.experienceLevel
        , multiChoiceWithOther data.otherLanguages Questions.otherLanguages
        , multiChoiceWithOther data.newsAndDiscussions Questions.newsAndDiscussions
        , multiChoiceWithOther data.elmResources Questions.elmResources
        , singleChoiceGraph data.doYouUseElmAtWork Questions.doYouUseElmAtWork
        , multiChoiceWithOther data.applicationDomains Questions.applicationDomains
        , singleChoiceGraph data.howLargeIsTheCompany Questions.howLargeIsTheCompany
        , multiChoiceWithOther data.whatLanguageDoYouUseForBackend Questions.whatLanguageDoYouUseForBackend
        , singleChoiceGraph data.howLong Questions.howLong
        , multiChoiceWithOther data.elmVersion Questions.elmVersion
        , singleChoiceGraph data.doYouUseElmFormat Questions.doYouUseElmFormat
        , multiChoiceWithOther data.stylingTools Questions.stylingTools
        , multiChoiceWithOther data.buildTools Questions.buildTools
        , multiChoiceWithOther data.frameworks Questions.frameworks
        , multiChoiceWithOther data.editors Questions.editors
        , singleChoiceGraph data.doYouUseElmReview Questions.doYouUseElmReview
        ]


multiChoiceWithOther : DataEntryWithOther a -> Question a -> Element msg
multiChoiceWithOther (DataEntryWithOther dataEntryWithOther) { title, choices, choiceToString } =
    let
        data =
            Dict.toList dataEntryWithOther
                |> List.sortBy Tuple.second
                |> List.map (\( groupName, count ) -> { choice = groupName, count = count })

        maxCount =
            List.map .count data |> List.maximum |> Maybe.withDefault 1 |> max 1

        total =
            List.map .count data |> List.sum |> max 1
    in
    Element.column
        [ Element.width Element.fill ]
        [ Element.paragraph [] [ Element.text title ]
        , Element.table
            [ Element.width Element.fill, Element.paddingEach { left = 0, top = 0, bottom = 0, right = 48 } ]
            { data = data
            , columns =
                [ { header = Element.none
                  , width = Element.shrink
                  , view =
                        \{ choice } ->
                            Element.paragraph
                                [ Element.Font.alignRight, Element.Font.size 16, Element.padding 4 ]
                                [ choice |> ellipsis ]
                  }
                , { header = Element.none
                  , width = Element.fill
                  , view =
                        \{ count } ->
                            let
                                a =
                                    10000

                                percentage =
                                    100 * toFloat count / toFloat total |> StringExtra.removeTrailing0s 1
                            in
                            Element.row
                                [ Element.width Element.fill
                                , Element.height Element.fill
                                , Element.padding 4
                                ]
                                [ Element.el
                                    [ Element.Background.color (Element.rgb 0 0 0)
                                    , Element.fillPortion (a * count) |> Element.minimum 2 |> Element.width
                                    , Element.height Element.fill
                                    , Element.Border.rounded 4
                                    , Element.Font.size 16
                                    , (percentage ++ "%")
                                        |> Element.text
                                        |> Element.el [ Element.moveRight 4 ]
                                        |> Element.onRight
                                    ]
                                    Element.none
                                , Element.el
                                    [ Element.fillPortion (a * (maxCount - count)) |> Element.width ]
                                    Element.none
                                ]
                  }
                ]
            }
        ]


ellipsis text =
    if String.length text > 40 then
        Element.el [ Element.Font.size 14 ] (Element.text text)

    else
        Element.text text


singleChoiceGraph : DataEntry a -> Question a -> Element msg
singleChoiceGraph dataEntry { title, choices, choiceToString } =
    let
        data =
            DataEntry.get choices dataEntry

        maxCount =
            Nonempty.map .count data |> Nonempty.maximum |> max 1

        total =
            Nonempty.map .count data |> Nonempty.toList |> List.sum |> max 1
    in
    Element.column
        [ Element.width Element.fill ]
        [ Element.paragraph [] [ Element.text title ]
        , Element.table
            [ Element.width Element.fill, Element.paddingEach { left = 0, top = 0, bottom = 0, right = 48 } ]
            { data = Nonempty.toList data
            , columns =
                [ { header = Element.none
                  , width = Element.shrink
                  , view =
                        \{ choice } ->
                            Element.paragraph
                                [ Element.Font.alignRight, Element.Font.size 16, Element.padding 4 ]
                                [ choiceToString choice |> ellipsis ]
                  }
                , { header = Element.none
                  , width = Element.fill
                  , view =
                        \{ count } ->
                            let
                                a =
                                    10000

                                percentage =
                                    100 * toFloat count / toFloat total |> StringExtra.removeTrailing0s 1
                            in
                            Element.row
                                [ Element.width Element.fill
                                , Element.height Element.fill
                                , Element.padding 4
                                ]
                                [ Element.el
                                    [ Element.Background.color (Element.rgb 0 0 0)
                                    , Element.fillPortion (a * count) |> Element.minimum 2 |> Element.width
                                    , Element.height Element.fill
                                    , Element.Border.rounded 4
                                    , Element.Font.size 16
                                    , (percentage ++ "%")
                                        |> Element.text
                                        |> Element.el [ Element.moveRight 4 ]
                                        |> Element.onRight
                                    ]
                                    Element.none
                                , Element.el
                                    [ Element.fillPortion (a * (maxCount - count)) |> Element.width ]
                                    Element.none
                                ]
                  }
                ]
            }
        ]
