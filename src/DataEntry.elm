module DataEntry exposing
    ( DataEntry
    , DataEntryWithOther(..)
    , comment
    , fromForms
    , fromFreeText
    , fromMultiChoiceWithOther
    , get
    )

import AnswerMap exposing (AnswerMap)
import AssocList as Dict exposing (Dict)
import AssocSet as Set
import FreeTextAnswerMap exposing (FreeTextAnswerMap)
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty)
import List.Nonempty.Ancillary as Nonempty
import Questions exposing (Question)
import Ui exposing (MultiChoiceWithOther)


type DataEntry a
    = DataEntry { data : Nonempty Int, comment : String }


type DataEntryWithOther a
    = DataEntryWithOther { data : Dict String Int, comment : String }


comment : DataEntry a -> String
comment (DataEntry dataEntry) =
    dataEntry.comment


get : Nonempty a -> DataEntry a -> Nonempty { choice : a, count : Int }
get choices (DataEntry dataEntry) =
    Nonempty.zip choices dataEntry.data
        |> Nonempty.map (\( choice, count ) -> { choice = choice, count = count })


fromForms : String -> Nonempty a -> List a -> DataEntry a
fromForms comment_ choices answers =
    let
        list =
            Nonempty.toList choices
    in
    { data =
        List.foldl
            (\answer state ->
                case List.elemIndex answer list of
                    Just index ->
                        Nonempty.updateAt index (\count -> count + 1) state

                    Nothing ->
                        state
            )
            (Nonempty.map (always 0) choices)
            answers
    , comment = comment_
    }
        |> DataEntry


fromMultiChoiceWithOther : Question a -> AnswerMap a -> List (MultiChoiceWithOther a) -> DataEntryWithOther a
fromMultiChoiceWithOther question answerMap multiChoiceWithOther =
    let
        initDict : Dict String Int
        initDict =
            AnswerMap.allGroups
                question
                answerMap
                |> List.map
                    (\{ groupName } ->
                        ( groupName, 0 )
                    )
                |> Dict.fromList
    in
    { data =
        List.foldl
            (\{ otherText, otherChecked, choices } dict ->
                let
                    normalizedOther =
                        AnswerMap.otherAnswer otherText
                in
                (if otherChecked then
                    AnswerMap.otherAnswerMapsTo question normalizedOther answerMap
                        |> List.foldl
                            (\{ groupName } dict2 ->
                                Dict.update groupName (Maybe.map (\count -> count + 1)) dict2
                            )
                            dict

                 else
                    dict
                )
                    |> (\dict2 ->
                            List.foldl
                                (\answer dict3 ->
                                    Dict.update
                                        (question.choiceToString answer)
                                        (Maybe.map (\count -> count + 1))
                                        dict3
                                )
                                dict2
                                (Set.toList choices)
                       )
            )
            initDict
            multiChoiceWithOther
    , comment = AnswerMap.comment answerMap
    }
        |> DataEntryWithOther


fromFreeText : FreeTextAnswerMap -> List String -> DataEntryWithOther a
fromFreeText answerMap multiChoiceWithOther =
    let
        initDict : Dict String Int
        initDict =
            FreeTextAnswerMap.allGroups
                answerMap
                |> List.map
                    (\{ groupName } ->
                        ( groupName, 0 )
                    )
                |> Dict.fromList
    in
    { data =
        List.foldl
            (\otherText dict ->
                let
                    normalizedOther =
                        AnswerMap.otherAnswer otherText
                in
                FreeTextAnswerMap.otherAnswerMapsTo normalizedOther answerMap
                    |> List.foldl
                        (\{ groupName } dict2 ->
                            Dict.update groupName (Maybe.map (\count -> count + 1)) dict2
                        )
                        dict
            )
            initDict
            multiChoiceWithOther
    , comment = FreeTextAnswerMap.comment answerMap
    }
        |> DataEntryWithOther
