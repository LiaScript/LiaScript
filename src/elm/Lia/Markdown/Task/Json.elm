module Lia.Markdown.Task.Json exposing
    ( encode
    , fromVector
    , toVector
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Inline.Json.Encode as Inline
import Lia.Markdown.Task.Types exposing (Task, Vector)


encode : Task -> JE.Value
encode task =
    JE.object
        [ ( "id", JE.int task.id )
        , ( "tasks", JE.list Inline.encode task.task )
        ]


{-| Convert a Task vector into a JSON representation.
-}
fromVector : Vector -> JE.Value
fromVector =
    JE.array (.state >> JE.array JE.bool)


{-| Read in a Task vector from a JSON representation.
-}
toVector : JD.Value -> Result JD.Error Vector
toVector =
    JD.bool
        |> JD.array
        |> JD.map
            (\v ->
                { state = v
                , scriptID = Nothing
                }
            )
        |> JD.array
        |> JD.decodeValue
