module SurveyResults exposing (Data, view)

import DataEntry exposing (DataEntry)
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import List.Nonempty as Nonempty exposing (Nonempty)
import List.Nonempty.Ancillary as Nonempty
import Questions exposing (Age, DoYouUseElm, DoYouUseElmAtWork, DoYouUseElmFormat, DoYouUseElmReview, ExperienceLevel, HowLargeIsTheCompany, HowLong, Question)
import StringExtra


type alias Data =
    { doYouUseElm : DataEntry DoYouUseElm
    , age : DataEntry Age
    , functionalProgrammingExperience : DataEntry ExperienceLevel
    , doYouUseElmAtWork : DataEntry DoYouUseElmAtWork
    , howLargeIsTheCompany : DataEntry HowLargeIsTheCompany
    , howLong : DataEntry HowLong
    , doYouUseElmFormat : DataEntry DoYouUseElmFormat
    , doYouUseElmReview : DataEntry DoYouUseElmReview
    }



--doYouUseElm : Set DoYouUseElm
--    , age : Maybe Age
--    , functionalProgrammingExperience : Maybe ExperienceLevel
--    , otherLanguages : MultiChoiceWithOther OtherLanguages
--    , newsAndDiscussions : MultiChoiceWithOther NewsAndDiscussions
--    , elmResources : MultiChoiceWithOther ElmResources
--    , countryLivingIn : String
--    , applicationDomains : MultiChoiceWithOther WhereDoYouUseElm
--    , doYouUseElmAtWork : Maybe DoYouUseElmAtWork
--    , howLargeIsTheCompany : Maybe HowLargeIsTheCompany
--    , whatLanguageDoYouUseForBackend : MultiChoiceWithOther WhatLanguageDoYouUseForTheBackend
--    , howLong : Maybe HowLong
--    , elmVersion : MultiChoiceWithOther WhatElmVersion
--    , doYouUseElmFormat : Maybe DoYouUseElmFormat
--    , stylingTools : MultiChoiceWithOther StylingTools
--    , buildTools : MultiChoiceWithOther BuildTools
--    , frameworks : MultiChoiceWithOther Frameworks
--    , editors : MultiChoiceWithOther Editor
--    , doYouUseElmReview : Maybe DoYouUseElmReview
--    , whichElmReviewRulesDoYouUse : MultiChoiceWithOther WhichElmReviewRulesDoYouUse
--    , testTools : MultiChoiceWithOther TestTools
--    , testsWrittenFor : MultiChoiceWithOther TestsWrittenFor
--    , elmInitialInterest : String
--    , biggestPainPoint : String
--    , whatDoYouLikeMost : String


view : Data -> Element msg
view data =
    Element.column
        [ Element.width Element.fill, Element.spacing 24, Element.paddingXY 0 16 ]
        [ singleChoiceGraph data.doYouUseElm Questions.doYouUseElm
        , singleChoiceGraph data.age Questions.age
        , singleChoiceGraph data.functionalProgrammingExperience Questions.experienceLevel
        , singleChoiceGraph data.doYouUseElmAtWork Questions.doYouUseElmAtWork
        , singleChoiceGraph data.howLargeIsTheCompany Questions.howLargeIsTheCompany
        , singleChoiceGraph data.howLong Questions.howLong
        , singleChoiceGraph data.doYouUseElmFormat Questions.doYouUseElmFormat
        , singleChoiceGraph data.doYouUseElmReview Questions.doYouUseElmReview
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
