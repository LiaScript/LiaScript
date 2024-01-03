module Lia.Markdown.Quiz.Solution exposing
    ( Solution(..)
    , State
    , isOpen
    , toClass
    , toString
    )


type Solution
    = Open
    | Solved
    | ReSolved


type alias State =
    ( Solution, Int )


toString : Solution -> String
toString s =
    case s of
        Solved ->
            "solved"

        ReSolved ->
            "resolved"

        Open ->
            "open"


toClass : State -> Maybe Bool -> String
toClass ( solution, trials ) partiallyCorrect =
    case solution of
        Solved ->
            "is-success is-disabled"

        ReSolved ->
            "is-disabled"

        Open ->
            if trials == 0 then
                ""

            else if partiallyCorrect == Just True then
                "is-success"

            else
                "is-failure"


isOpen : State -> Bool
isOpen =
    Tuple.first >> (==) Open
