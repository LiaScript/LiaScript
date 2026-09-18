module Lia.Markdown.Task.Json exposing
    ( encode
    , fromVector
    , toVector
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Task.Types exposing (Task, Vector)


encode : (body -> JE.Value) -> Task body -> JE.Value
encode encoder task =
    JE.object
        [ ( "id", JE.int task.id )
        , ( "tasks", JE.list (JE.list encoder) task.task )
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
