module Lia.Markdown.Quiz.Block.Json exposing
    ( encode
    , fromState
    , toState
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Inline.Json.Encode as Inline
import Lia.Markdown.Quiz.Block.Types exposing (Quiz, State(..))


encode : Quiz -> ( String, JE.Value )
encode quiz =
    ( case quiz.solution of
        Text _ ->
            "Text"

        Select _ _ ->
            "Select"
    , JE.object
        [ ( "options", JE.list Inline.encode quiz.options )
        , ( "solution", fromState quiz.solution )
        ]
    )


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
