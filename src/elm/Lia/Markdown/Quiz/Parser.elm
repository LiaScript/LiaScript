module Lia.Markdown.Quiz.Parser exposing (parse)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , choice
        , ignore
        , keep
        , many
        , many1
        , map
        , maybe
        , modifyState
        , onsuccess
        , regex
        , skip
        , string
        , succeed
        , withState
        )
import Lia.Markdown.Inline.Parser exposing (javascript, line, parse_inlines)
import Lia.Markdown.Inline.Types exposing (Inlines, MultInlines)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Quiz.Block.Parser as Block
import Lia.Markdown.Quiz.MultipleChoice.Parser as MultipleChoice
import Lia.Markdown.Quiz.SingleChoice.Parser as SingleChoice
import Lia.Markdown.Quiz.Types
    exposing
        ( Element
        , Hints
        , Quiz
        , Solution(..)
        , State(..)
        , Type(..)
        , initState
        )
import Lia.Parser.Helper exposing (newline, spaces, stringTill)
import Lia.Parser.State exposing (State, identation)


parse : Parser State Quiz
parse =
    [ map SingleChoice SingleChoice.parse
    , map MultipleChoice MultipleChoice.parse
    , onsuccess Empty empty
    , map Block Block.parse
    ]
        |> choice
        |> andThen adds
        |> andThen modify_State


adds : Type -> Parser State Quiz
adds type_ =
    map (Quiz type_) get_counter
        |> andMap hints
        |> andMap
            (macro
                |> keep
                    (maybe
                        (spaces
                            |> keep javascript
                            |> ignore newline
                        )
                    )
            )


get_counter : Parser State Int
get_counter =
    withState (\s -> succeed (Array.length s.quiz_vector))


empty : Parser State ()
empty =
    spaces
        |> ignore (string "[[!]]")
        |> ignore newline
        |> skip


hints : Parser State MultInlines
hints =
    identation
        |> keep (string "[[?]]")
        |> keep line
        |> ignore newline
        |> many


modify_State : Quiz -> Parser State Quiz
modify_State q =
    let
        add_state e s =
            { s
                | quiz_vector =
                    Array.push
                        (Element Open e 0 0 "")
                        s.quiz_vector
            }
    in
    q.quiz
        |> initState
        |> add_state
        |> modifyState
        |> keep (succeed q)
