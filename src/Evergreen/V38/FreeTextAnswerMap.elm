module Evergreen.V38.FreeTextAnswerMap exposing (..)

import AssocSet


type FreeTextAnswerMap
    = FreeTextAnswerMap
        { otherMapping :
            List
                { groupName : String
                , otherAnswers : AssocSet.Set String
                }
        , comment : String
        }
