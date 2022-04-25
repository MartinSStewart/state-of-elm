module FreeTextAnswerMap exposing
    ( FreeTextAnswerMap(..)
    , addGroup
    , allGroups
    , comment
    , init
    , otherAnswerMapsTo
    , removeGroup
    , renameGroup
    , updateOtherAnswer
    , withComment
    )

import AnswerMap exposing (Hotkey, OtherAnswer)
import AssocSet as Set exposing (Set)
import List.Extra as List


type FreeTextAnswerMap
    = FreeTextAnswerMap
        { otherMapping : List { groupName : String, otherAnswers : Set String }
        , comment : String
        }


init : FreeTextAnswerMap
init =
    FreeTextAnswerMap { otherMapping = [], comment = "" }


allGroups : FreeTextAnswerMap -> List { hotkey : Hotkey, editable : Bool, groupName : String }
allGroups (FreeTextAnswerMap formMapData) =
    List.indexedMap
        (\index other ->
            { hotkey = AnswerMap.indexToHotkey index
            , groupName = other.groupName
            , editable = True
            }
        )
        formMapData.otherMapping


comment : FreeTextAnswerMap -> String
comment (FreeTextAnswerMap answerMap) =
    answerMap.comment


withComment : String -> FreeTextAnswerMap -> FreeTextAnswerMap
withComment text (FreeTextAnswerMap answerMap) =
    { answerMap | comment = text } |> FreeTextAnswerMap


otherAnswerMapsTo : OtherAnswer -> FreeTextAnswerMap -> List { hotkey : Hotkey, groupName : String }
otherAnswerMapsTo otherAnswer_ (FreeTextAnswerMap formMapData) =
    List.filterMap
        (\( index, { groupName, otherAnswers } ) ->
            if Set.member (AnswerMap.otherAnswerToString otherAnswer_) otherAnswers then
                { hotkey = AnswerMap.indexToHotkey index, groupName = groupName } |> Just

            else
                Nothing
        )
        (List.indexedMap Tuple.pair formMapData.otherMapping)


updateOtherAnswer : List Hotkey -> OtherAnswer -> FreeTextAnswerMap -> FreeTextAnswerMap
updateOtherAnswer hotkeys otherAnswer_ (FreeTextAnswerMap formMapData) =
    let
        indices : Set Int
        indices =
            List.filterMap AnswerMap.hotkeyToIndex hotkeys |> Set.fromList
    in
    { formMapData
        | otherMapping =
            List.indexedMap
                (\index a ->
                    if Set.member index indices then
                        { a | otherAnswers = Set.insert (AnswerMap.otherAnswerToString otherAnswer_) a.otherAnswers }

                    else
                        { a | otherAnswers = Set.remove (AnswerMap.otherAnswerToString otherAnswer_) a.otherAnswers }
                )
                formMapData.otherMapping
    }
        |> FreeTextAnswerMap


renameGroup : Hotkey -> String -> FreeTextAnswerMap -> FreeTextAnswerMap
renameGroup hotkey_ newGroupName (FreeTextAnswerMap formMapData) =
    (case AnswerMap.hotkeyToIndex hotkey_ of
        Just index ->
            { formMapData
                | otherMapping =
                    List.updateAt
                        index
                        (\a -> { a | groupName = newGroupName })
                        formMapData.otherMapping
            }

        Nothing ->
            formMapData
    )
        |> FreeTextAnswerMap


removeGroup : Hotkey -> FreeTextAnswerMap -> FreeTextAnswerMap
removeGroup hotkey_ (FreeTextAnswerMap formMapData) =
    (case AnswerMap.hotkeyToIndex hotkey_ of
        Just index ->
            { formMapData
                | otherMapping = List.removeAt index formMapData.otherMapping
            }

        Nothing ->
            formMapData
    )
        |> FreeTextAnswerMap


addGroup : String -> FreeTextAnswerMap -> FreeTextAnswerMap
addGroup groupName (FreeTextAnswerMap formMapData) =
    { formMapData
        | otherMapping = formMapData.otherMapping ++ [ { groupName = groupName, otherAnswers = Set.empty } ]
    }
        |> FreeTextAnswerMap
