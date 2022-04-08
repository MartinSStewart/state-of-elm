module AnswerMap exposing (FormMapData, fromFreeText, fromMultiChoiceWithOther, hotkey)

import AssocSet as Set exposing (Set)
import List.Extra as List
import List.Nonempty
import Questions exposing (Question)


type FormMapData
    = FormMapData
        { otherMapping : List { groupName : String, otherAnswers : Set String }
        , existingMapping : List (Set String)
        }


fromMultiChoiceWithOther : Question a -> FormMapData
fromMultiChoiceWithOther question =
    { otherMapping = []
    , existingMapping =
        (List.Nonempty.length question.choices - 1)
            |> List.range 0
            |> List.map (\_ -> Set.empty)
    }
        |> FormMapData


fromFreeText : FormMapData
fromFreeText =
    { otherMapping = []
    , existingMapping = []
    }
        |> FormMapData


type Hotkey
    = Hotkey Char


hotkey : Char -> Hotkey
hotkey =
    Hotkey


indexToHotkey : Int -> Hotkey
indexToHotkey index =
    Char.fromCode (index + Char.toCode 'a') |> hotkey


hotkeyToIndex : Hotkey -> Maybe Int
hotkeyToIndex (Hotkey char) =
    Char.toCode char - Char.toCode 'a' |> Just


addMapping : Hotkey -> String -> FormMapData -> FormMapData
addMapping hotkey_ otherAnswer (FormMapData formMapData) =
    (case hotkeyToIndex hotkey_ of
        Just index ->
            if index < List.length formMapData.existingMapping then
                { otherMapping = formMapData.otherMapping
                , existingMapping = List.updateAt index (Set.insert otherAnswer) formMapData.existingMapping
                }

            else
                { otherMapping = List { groupName = String, otherAnswers = Set String }
                , existingMapping = formMapData.existingMapping
                }

        Nothing ->
            formMapData
    )
        |> FormMapData
