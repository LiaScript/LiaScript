module Lia.Markdown.Quiz.Multi.Json exposing
    ( encode
    , fromState
    , toState
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Inline.Json.Encode as Inline
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Block.Json as Block
import Lia.Markdown.Quiz.Multi.Types exposing (Quiz, State)


{-| Encode the quiz definition, without the block that contains the inputs.
-}
encode : Quiz x Inlines -> ( String, JE.Value )
encode quiz =
    ( uid
    , JE.object
        [ ( "elements"
          , JE.null
          )
        , ( "options"
          , quiz.options
                |> JE.array (JE.list Inline.encode)
          )
        , ( "solution", fromState quiz.solution )
        ]
    )


uid : String
uid =
    "Multi"


{-| -}
fromState : State -> JE.Value
fromState state =
    JE.object <|
        [ ( uid, JE.array Block.fromState state ) ]


{-| -}
toState : JD.Decoder State
toState =
    Block.toState
        |> JD.array
        |> JD.field uid
