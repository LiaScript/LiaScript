module Lia.Markdown.Survey.Json exposing
    ( fromVector
    , toVector
    )

import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Survey.Types exposing (Element, State(..), Vector)


fromVector : Vector -> JE.Value
fromVector vector =
    JE.array fromElement vector


fromElement : Element -> JE.Value
fromElement ( b, state ) =
    JE.object
        [ ( "submitted", JE.bool b )
        , ( "state", fromState state )
        ]


fromState : State -> JE.Value
fromState state =
    JE.object <|
        case state of
            TextState str ->
                [ ( "Text"
                  , JE.string str
                  )
                ]

            VectorState True vector ->
                [ ( "SingleChoice"
                  , dict2json vector
                  )
                ]

            VectorState False vector ->
                [ ( "MultipleChoice"
                  , dict2json vector
                  )
                ]

            MatrixState True matrix ->
                [ ( "SingleChoiceMatrix"
                  , JE.array dict2json matrix
                  )
                ]

            MatrixState False matrix ->
                [ ( "MultipleChoiceMatrix"
                  , JE.array dict2json matrix
                  )
                ]


dict2json : Dict String Bool -> JE.Value
dict2json dict =
    dict
        |> Dict.toList
        |> List.map (\( s, b ) -> ( s, JE.bool b ))
        |> JE.object


toVector : JD.Value -> Result JD.Error Vector
toVector json =
    JD.decodeValue (JD.array toElement) json


toElement : JD.Decoder Element
toElement =
    JD.map2 Tuple.pair
        (JD.field "submitted" JD.bool)
        (JD.field "state" toState)


toState : JD.Decoder State
toState =
    JD.oneOf
        [ JD.field "Text" JD.string
            |> JD.map TextState
        , JD.field "SingleChoice" (JD.dict JD.bool)
            |> JD.map (VectorState True)
        , JD.field "MultipleChoice" (JD.dict JD.bool)
            |> JD.map (VectorState False)
        , JD.field "SingleChoiceMatrix" (JD.array (JD.dict JD.bool))
            |> JD.map (MatrixState False)
        , JD.field "MultipleChoiceMatrix" (JD.array (JD.dict JD.bool))
            |> JD.map (MatrixState True)
        ]
