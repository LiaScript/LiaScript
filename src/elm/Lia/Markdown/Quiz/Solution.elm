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


toClass : State -> String
toClass ( solution, trials ) =
    case solution of
        Solved ->
            "is-success is-disabled"

        ReSolved ->
            "is-disabled"

        Open ->
            if trials == 0 then
                ""

            else
                "is-failure"


isOpen : State -> Bool
isOpen =
    Tuple.first >> (==) Open
