module AnswerMap exposing
    ( AnswerMap(..)
    , Hotkey
    , OtherAnswer(..)
    , addGroup
    , allGroups
    , comment
    , hotkey
    , hotkeyToIndex
    , hotkeyToString
    , indexToHotkey
    , init
    , otherAnswer
    , otherAnswerMapsTo
    , otherAnswerToString
    , removeGroup
    , renameGroup
    , updateOtherAnswer
    , withComment
    )

import AssocSet as Set exposing (Set)
import List.Extra as List
import List.Nonempty
import Questions exposing (Question)


type AnswerMap a
    = AnswerMap
        { otherMapping : List { groupName : String, otherAnswers : Set OtherAnswer }
        , existingMapping : List (Set OtherAnswer)
        , comment : String
        }


type OtherAnswer
    = OtherAnswer String


otherAnswer : String -> OtherAnswer
otherAnswer =
    normalizeOtherAnswer >> OtherAnswer


otherAnswerToString : OtherAnswer -> String
otherAnswerToString (OtherAnswer a) =
    a


normalizeOtherAnswer : String -> String
normalizeOtherAnswer =
    String.trim >> String.toLower


init : Question a -> AnswerMap a
init question =
    { otherMapping = []
    , existingMapping =
        (List.Nonempty.length question.choices - 1)
            |> List.range 0
            |> List.map
                (\index ->
                    List.Nonempty.get index question.choices
                        |> question.choiceToString
                        |> otherAnswer
                        |> List.singleton
                        |> Set.fromList
                )
    , comment = ""
    }
        |> AnswerMap


allGroups : Question a -> AnswerMap a -> List { hotkey : Hotkey, editable : Bool, groupName : String }
allGroups question (AnswerMap formMapData) =
    let
        existingChoicesCount =
            List.Nonempty.length question.choices
    in
    List.indexedMap
        (\index choice ->
            { hotkey = indexToHotkey index
            , groupName = question.choiceToString choice
            , editable = False
            }
        )
        (List.Nonempty.toList question.choices)
        ++ List.indexedMap
            (\index other ->
                { hotkey = indexToHotkey (index + existingChoicesCount)
                , groupName = other.groupName
                , editable = True
                }
            )
            formMapData.otherMapping


comment : AnswerMap a -> String
comment (AnswerMap answerMap) =
    answerMap.comment


withComment : String -> AnswerMap a -> AnswerMap a
withComment text (AnswerMap answerMap) =
    { answerMap | comment = text } |> AnswerMap


otherAnswerMapsTo : Question a -> OtherAnswer -> AnswerMap a -> List { hotkey : Hotkey, groupName : String }
otherAnswerMapsTo question otherAnswer_ (AnswerMap formMapData) =
    let
        existingCount =
            List.length formMapData.existingMapping
    in
    List.filterMap
        (\( index, set ) ->
            if Set.member otherAnswer_ set then
                { hotkey = indexToHotkey index
                , groupName =
                    List.Nonempty.get index question.choices
                        |> question.choiceToString
                }
                    |> Just

            else
                Nothing
        )
        (List.indexedMap Tuple.pair formMapData.existingMapping)
        ++ List.filterMap
            (\( index, { groupName, otherAnswers } ) ->
                if Set.member otherAnswer_ otherAnswers then
                    { hotkey = indexToHotkey (index + existingCount), groupName = groupName } |> Just

                else
                    Nothing
            )
            (List.indexedMap Tuple.pair formMapData.otherMapping)


updateOtherAnswer : List Hotkey -> OtherAnswer -> AnswerMap a -> AnswerMap a
updateOtherAnswer hotkeys otherAnswer_ (AnswerMap formMapData) =
    let
        indices : Set Int
        indices =
            List.filterMap hotkeyToIndex hotkeys |> Set.fromList

        offset =
            List.length formMapData.existingMapping
    in
    { otherMapping =
        List.indexedMap
            (\index a ->
                if Set.member (index + offset) indices then
                    { a | otherAnswers = Set.insert otherAnswer_ a.otherAnswers }

                else
                    { a | otherAnswers = Set.remove otherAnswer_ a.otherAnswers }
            )
            formMapData.otherMapping
    , existingMapping =
        List.indexedMap
            (\index set ->
                if Set.member index indices then
                    Set.insert otherAnswer_ set

                else
                    Set.remove otherAnswer_ set
            )
            formMapData.existingMapping
    , comment = formMapData.comment
    }
        |> AnswerMap


type Hotkey
    = Hotkey Char


hotkey : Char -> Hotkey
hotkey =
    Hotkey


indexToHotkey : Int -> Hotkey
indexToHotkey index =
    List.getAt index hotkeyChars |> Maybe.withDefault '9' |> hotkey


hotkeyToIndex : Hotkey -> Maybe Int
hotkeyToIndex (Hotkey char) =
    List.elemIndex char hotkeyChars


hotkeyToString : Hotkey -> String
hotkeyToString (Hotkey char) =
    String.fromChar char


hotkeyChars : List Char
hotkeyChars =
    [ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ]


renameGroup : Hotkey -> String -> AnswerMap a -> AnswerMap a
renameGroup hotkey_ newGroupName (AnswerMap formMapData) =
    (case hotkeyToIndex hotkey_ of
        Just index ->
            let
                existingMapping =
                    List.length formMapData.existingMapping
            in
            if index < existingMapping then
                formMapData

            else
                { formMapData
                    | otherMapping =
                        List.updateAt
                            (index - existingMapping)
                            (\a -> { a | groupName = newGroupName })
                            formMapData.otherMapping
                }

        Nothing ->
            formMapData
    )
        |> AnswerMap


removeGroup : Hotkey -> AnswerMap a -> AnswerMap a
removeGroup hotkey_ (AnswerMap formMapData) =
    (case hotkeyToIndex hotkey_ of
        Just index ->
            let
                existingMapping =
                    List.length formMapData.existingMapping
            in
            if index < existingMapping then
                formMapData

            else
                { formMapData
                    | otherMapping = List.removeAt (index - existingMapping) formMapData.otherMapping
                }

        Nothing ->
            formMapData
    )
        |> AnswerMap


addGroup : String -> AnswerMap a -> AnswerMap a
addGroup groupName (AnswerMap formMapData) =
    { formMapData
        | otherMapping = formMapData.otherMapping ++ [ { groupName = groupName, otherAnswers = Set.empty } ]
    }
        |> AnswerMap
