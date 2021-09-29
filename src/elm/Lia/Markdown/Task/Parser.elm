module Lia.Markdown.Task.Parser exposing (parse)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , ignore
        , keep
        , map
        , maybe
        , modifyState
        , string
        , succeed
        , withState
        )
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Parser exposing (eScript)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Quiz.Vector.Parser exposing (either, groupBy)
import Lia.Markdown.Task.Types exposing (Task)
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces)
import Lia.Parser.Indentation as Indent


{-| Parse lines of GitHub flavored tasks:

    - [ ] some task
    - [X] some checked tasks
    <script> // do something with the input </script>

The associated script is a LiaScript feature, it is optional and will contain
some JavaScript code that is executed every time the user changes the input.

-}
parse : Parser Context Task
parse =
    either "[xX]" " "
        |> groupBy (string "- [") (string "]")
        |> map List.unzip
        |> andThen modify_State
        |> andMap maybeJS


{-| **@private:** Push the parsed state `List Bool` to the parser `Context` and
and return the list of inlines to be visualized.
-}
modify_State : ( List Bool, List Inlines ) -> Parser Context (Maybe ( Parameters, Int ) -> Task)
modify_State ( states, tasks ) =
    let
        addTask : Context -> Context
        addTask s =
            { s | task_vector = Array.push (Array.fromList states) s.task_vector }
    in
    (.task_vector >> Array.length >> succeed)
        |> withState
        |> map (Task tasks)
        |> ignore (modifyState addTask)


maybeJS : Parser Context (Maybe ( Parameters, Int ))
maybeJS =
    macro
        |> ignore (maybe Indent.check)
        |> keep
            (maybe
                (spaces
                    |> keep (eScript [ ( "input", "hidden" ) ])
                    |> ignore newline
                )
            )
