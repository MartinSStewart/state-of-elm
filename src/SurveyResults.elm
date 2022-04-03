module SurveyResults exposing (Data, view)

import DataEntry exposing (DataEntry)
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import List.Nonempty as Nonempty exposing (Nonempty)
import List.Nonempty.Ancillary as Nonempty
import Questions exposing (Age, DoYouUseElm, DoYouUseElmAtWork, DoYouUseElmFormat, DoYouUseElmReview, ExperienceLevel, HowLargeIsTheCompany, HowLong)


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
        [ Element.width Element.fill, Element.spacing 24 ]
        [ singleChoiceGraph data.doYouUseElm Questions.allDoYouUseElm Questions.doYouUseElmToString
        , singleChoiceGraph data.age Questions.allAge Questions.ageToString
        , singleChoiceGraph data.functionalProgrammingExperience Questions.allExperienceLevel Questions.experienceLevelToString
        , singleChoiceGraph data.doYouUseElmAtWork Questions.allDoYouUseElmAtWork Questions.doYouUseElmAtWorkToString
        , singleChoiceGraph data.howLargeIsTheCompany Questions.allHowLargeIsTheCompany Questions.howLargeIsTheCompanyToString
        , singleChoiceGraph data.howLong Questions.allHowLong Questions.howLongToString
        , singleChoiceGraph data.doYouUseElmFormat Questions.allDoYouUseElmFormat Questions.doYouUseElmFormatToString
        , singleChoiceGraph data.doYouUseElmReview Questions.allDoYouUseElmReview Questions.doYouUseElmReviewToString
        ]


ellipsis text =
    if String.length text > 40 then
        String.left 37 text ++ "..."

    else
        text


singleChoiceGraph : DataEntry a -> Nonempty a -> (a -> String) -> Element msg
singleChoiceGraph dataEntry choices choiceToString =
    let
        data =
            DataEntry.get choices dataEntry

        maxCount =
            Nonempty.map .count data |> Nonempty.maximum |> max 1
    in
    Element.table
        [ Element.width Element.fill ]
        { data = Nonempty.toList data
        , columns =
            [ { header = Element.none
              , width = Element.shrink
              , view =
                    \{ choice } ->
                        Element.paragraph
                            [ Element.Font.alignRight, Element.Font.size 16, Element.padding 4 ]
                            [ choiceToString choice |> ellipsis |> Element.text ]
              }
            , { header = Element.none
              , width = Element.fill
              , view =
                    \{ choice, count } ->
                        let
                            a =
                                10000
                        in
                        Element.row
                            [ Element.width Element.fill
                            , Element.height Element.fill
                            , Element.padding 4
                            ]
                            [ Element.el
                                [ Element.Background.color (Element.rgb 0 0 0)
                                , Element.fillPortion ((a * count) // (a * maxCount)) |> Element.width
                                , Element.height Element.fill
                                , Element.Border.rounded 4
                                ]
                                Element.none
                            , Element.el
                                [ Element.fillPortion ((a * (maxCount - count)) // (a * maxCount)) |> Element.width ]
                                Element.none
                            ]
              }
            ]
        }
