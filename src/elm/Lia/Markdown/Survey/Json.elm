module Lia.Markdown.Survey.Json exposing
    ( encode
    , fromState
    , fromVector
    , toState
    , toVector
    )

import Conditional.List as CList
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Inline.Json.Encode as Inline
import Lia.Markdown.Survey.Types exposing (Element, State(..), Survey, Type(..), Vector)


encode : Survey -> JE.Value
encode survey =
    JE.object <|
        [ ( "id", JE.int survey.id )
        , case survey.survey of
            Text i ->
                ( "Text"
                , JE.int i
                )

            Select elements ->
                ( "Select"
                , JE.list Inline.encode elements
                )

            Vector bool options ->
                ( "Vector"
                , JE.object
                    [ ( "bool", JE.bool bool )
                    , ( "options"
                      , options
                            |> List.map (Tuple.mapSecond Inline.encode)
                            |> JE.object
                      )
                    ]
                )

            Matrix bool cols ids rows ->
                ( "Matrix"
                , JE.object
                    [ ( "bool", JE.bool bool )
                    , ( "cols", JE.list Inline.encode cols )
                    , ( "ids", JE.list JE.string ids )
                    , ( "rows", JE.list Inline.encode rows )
                    ]
                )
        ]


fromVector : Vector -> JE.Value
fromVector =
    JE.array fromElement


fromElement : Element -> JE.Value
fromElement element =
    [ ( "submitted", JE.bool element.submitted )
    , ( "state", fromState element.state )
    ]
        |> CList.addWhen (fromError element.errorMsg)
        |> JE.object


fromError : Maybe String -> Maybe ( String, JE.Value )
fromError =
    Maybe.map (JE.string >> Tuple.pair "errorMessage")


fromState : State -> JE.Value
fromState state =
    JE.object <|
        case state of
            Text_State str ->
                [ ( "Text"
                  , JE.string str
                  )
                ]

            Select_State _ i ->
                [ ( "Select"
                  , JE.int i
                  )
                ]

            Vector_State single vector ->
                [ ( if single then
                        "SingleChoice"

                    else
                        "MultipleChoice"
                  , dict2json vector
                  )
                ]

            Matrix_State single matrix ->
                [ ( if single then
                        "SingleChoiceMatrix"

                    else
                        "MultipleChoiceMatrix"
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
toVector =
    JD.decodeValue (JD.array toElement)


toElement : JD.Decoder Element
toElement =
    JD.map5 Element
        (JD.field "submitted" JD.bool)
        (JD.field "state" toState)
        (JD.maybe (JD.field "errorMessage" JD.string))
        (JD.succeed Nothing)
        (JD.succeed Nothing)


toState : JD.Decoder State
toState =
    JD.oneOf
        [ JD.field "Text" JD.string
            |> JD.map Text_State
        , JD.field "Select" JD.int
            |> JD.map (Select_State False)
        , JD.field "SingleChoice" (JD.dict JD.bool)
            |> JD.map (Vector_State True)
        , JD.field "MultipleChoice" (JD.dict JD.bool)
            |> JD.map (Vector_State False)
        , JD.field "SingleChoiceMatrix" (JD.array (JD.dict JD.bool))
            |> JD.map (Matrix_State False)
        , JD.field "MultipleChoiceMatrix" (JD.array (JD.dict JD.bool))
            |> JD.map (Matrix_State True)
        ]
