module Lia.Markdown.Quiz.Solution exposing
    ( Solution(..)
    , State
    , isOpen
    , toClass
    , toString
    )

{-| A quiz is open, solved, or resolved (the solution was revealed or all
trials failed).
-}


type Solution
    = Open
    | Solved
    | ReSolved


{-| The solution state and the number of trials.
-}
type alias State =
    ( Solution, Int )


{-| -}
toString : Solution -> String
toString s =
    case s of
        Solved ->
            "solved"

        ReSolved ->
            "resolved"

        Open ->
            "open"


{-| The class of inputs: disabled once solved or resolved, marked as correct or
wrong after a trial. `partiallyCorrect` marks a part (a matrix row) as correct
even if the whole quiz is not.
-}
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


{-| -}
isOpen : State -> Bool
isOpen =
    Tuple.first >> (==) Open
