module Lia.Markdown.Task.Parser exposing (parse)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , ignore
        , keep
        , many
        , map
        , modifyState
        , regex
        , sepBy
        , sepBy1
        , string
        , succeed
        , withState
        )
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Quiz.Parser exposing (maybeJS)
import Lia.Markdown.Quiz.Vector.Parser exposing (either)
import Lia.Markdown.Task.Types exposing (Task, toString)
import Lia.Markdown.Types as Markdown
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces)
import Lia.Parser.Indentation as Indent


{-| Parse lines of GitHub flavored tasks:

    - [ ] some task
    - [X] some checked task
        that may continue with additional indented block content,
        such as a second paragraph or a fenced code block

    <script> // do something with the input </script>

The associated script is a LiaScript feature, it is optional and will contain
some JavaScript code that is executed every time the user changes the input.

-}
parse : Parser Context Markdown.Block -> Parser Context (Task Markdown.Block)
parse blocks =
    item blocks
        |> sepBy1 separator
        |> map List.unzip
        |> andThen modify_State


{-| **@private:** Separates consecutive task items, re-checking the
indentation of the surrounding context (e.g. when a task list is nested
within a block quote or another list) before the next item's marker.
-}
separator : Parser Context (List ())
separator =
    many newlineWithIndentation
        |> ignore Indent.check


newlineWithIndentation : Parser Context ()
newlineWithIndentation =
    Indent.maybeCheck
        |> ignore newline


{-| **@private:** Parse a single task item: its `[ ]`/`[x]` marker, followed
by its (possibly multi-block) content. The content is indented relative to
the marker, exactly as with regular (un-)ordered list items.
-}
item : Parser Context Markdown.Block -> Parser Context ( Bool, Markdown.Blocks )
item blocks =
    Indent.push "      "
        |> keep
            (marker
                |> map Tuple.pair
                |> andMap (sepBy (many newlineWithIndentation) blocks)
            )
        |> ignore Indent.pop


{-| **@private:** Parse the `- [ ]`/`- [x]` marker of a single task item,
returning its checked-state.
-}
marker : Parser Context Bool
marker =
    regex "[ \t]*(\\-|\\*|\\+)[ \t]?\\["
        |> keep (either "[xX]" " ")
        |> ignore (string "]")
        |> ignore spaces


{-| **@private:** Push the parsed state `List Bool` to the parser `Context` and
and return the list of blocks to be visualized.
-}
modify_State : ( List Bool, List Markdown.Blocks ) -> Parser Context (Task Markdown.Block)
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
