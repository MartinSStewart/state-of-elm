module Evergreen.V22.AnswerMap exposing (..)

import AssocSet


type OtherAnswer
    = OtherAnswer String


type AnswerMap a
    = AnswerMap
        { otherMapping :
            List
                { groupName : String
                , otherAnswers : AssocSet.Set OtherAnswer
                }
        , existingMapping : List (AssocSet.Set OtherAnswer)
        , comment : String
        }


type Hotkey
    = Hotkey Char
