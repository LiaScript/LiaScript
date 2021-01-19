module Lia.Markdown.Task.Parser exposing (parse)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , ignore
        , map
        , modifyState
        , string
        , succeed
        , withState
        )
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Parser exposing (maybeJS)
import Lia.Markdown.Quiz.Vector.Parser exposing (either, groupBy)
import Lia.Markdown.Task.Types exposing (Task)
import Lia.Parser.Context exposing (Context)


parse : Parser Context Task
parse =
    either "[xX]" " "
        |> groupBy (string "- [") (string "]")
        |> map List.unzip
        |> andThen modify_State
        |> andMap maybeJS


modify_State : ( List Bool, List Inlines ) -> Parser Context (Maybe String -> Task)
modify_State ( states, tasks ) =
    let
        addTask s =
            { s
                | task_vector =
                    Array.push
                        (Array.fromList states)
                        s.task_vector
            }
    in
    (.task_vector >> Array.length >> succeed)
        |> withState
        |> map (Task tasks)
        |> ignore (modifyState addTask)
