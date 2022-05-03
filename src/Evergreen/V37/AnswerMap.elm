module Evergreen.V37.AnswerMap exposing (..)

import AssocSet


type Hotkey
    = Hotkey Char


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
