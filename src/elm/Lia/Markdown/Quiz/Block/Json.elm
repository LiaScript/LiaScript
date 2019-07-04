module Lia.Markdown.Quiz.Block.Json exposing
    ( fromState
    , toState
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.Block.Types exposing (State(..))


fromState : State -> JE.Value
fromState state =
    JE.object <|
        case state of
            Text x ->
                [ ( "Text", JE.string x ) ]

            Select _ [ x ] ->
                [ ( "Select", JE.int x ) ]

            Select _ _ ->
                [ ( "Select", JE.int -1 ) ]


toState : JD.Decoder State
toState =
    JD.oneOf
        [ JD.field "Text" JD.string |> JD.map Text
        , JD.field "Select" JD.int |> JD.map (List.singleton >> Select False)
        ]
