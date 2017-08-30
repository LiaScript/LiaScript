module Lia.Code.Types exposing (Code(..))


type Code
    = Highlight String String
    | EvalJS String Int
