module Lia.Markdown.Task.Parser exposing (parse)

import Array
import Combine
    exposing
        ( Parser
        , andThen
        , ignore
        , map
        , modifyState
        , regex
        , string
        , succeed
        , withState
        )
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Parser exposing (maybeJS)
import Lia.Markdown.Quiz.Vector.Parser exposing (either, groupBy)
import Lia.Markdown.Task.Types exposing (Task, toString)
import Lia.Parser.Context exposing (Context)


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
        |> groupBy (regex "(\\-|\\*|\\+)[ \t]?\\[") (string "]")
        |> map List.unzip
        |> andThen modify_State


{-| **@private:** Push the parsed state `List Bool` to the parser `Context` and
and return the list of inlines to be visualized.
-}
modify_State : ( List Bool, List Inlines ) -> Parser Context Task
modify_State ( states, tasks ) =
    let
        addTask : Maybe Int -> Context -> Context
        addTask m s =
            { s
                | task_vector =
                    Array.push
                        { state = Array.fromList states
                        , scriptID = m
                        }
                        s.task_vector
                , effect_model =
                    case m of
                        Nothing ->
                            s.effect_model

                        Just scriptID ->
                            let
                                effect_model =
                                    s.effect_model
                            in
                            { effect_model
                                | javascript =
                                    case Array.get scriptID effect_model.javascript of
                                        Just script ->
                                            Array.set scriptID
                                                { script
                                                    | result =
                                                        Just
                                                            (Script.Text
                                                                (toString
                                                                    { state = Array.fromList states
                                                                    , scriptID = Nothing
                                                                    }
                                                                )
                                                            )
                                                }
                                                effect_model.javascript

                                        Nothing ->
                                            effect_model.javascript
                            }
            }
    in
    (.task_vector >> Array.length >> succeed)
        |> withState
        |> map (Task tasks)
        |> ignore
            (maybeJS
                |> map addTask
                |> andThen modifyState
            )
