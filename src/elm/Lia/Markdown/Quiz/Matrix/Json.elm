module Lia.Markdown.Quiz.Matrix.Json exposing
    ( encode
    , fromState
    , toState
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Inline.Json.Encode as Inline
import Lia.Markdown.Quiz.Matrix.Types exposing (Quiz, State)
import Lia.Markdown.Quiz.Vector.Json as Vector


encode : Quiz -> ( String, JE.Value )
encode quiz =
    ( uid
    , JE.object
        [ ( "headers", JE.list Inline.encode quiz.headers )
        , ( "options", JE.list Inline.encode quiz.options )
        , ( "solution", fromState quiz.solution )
        ]
    )


uid : String
uid =
    "Matrix"


fromState : State -> JE.Value
fromState state =
    JE.object <|
        [ ( uid, JE.array Vector.fromState state ) ]


toState : JD.Decoder State
toState =
    Vector.toState
        |> JD.array
        |> JD.field uid
