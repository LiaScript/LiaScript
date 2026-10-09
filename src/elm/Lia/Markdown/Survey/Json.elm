module Lia.Markdown.Survey.Json exposing
    ( encode
    , fromState
    , fromVector
    , toState
    , toVector
    )

{-| JSON encoding of surveys (as part of the exported Markdown) and of the
survey states, which are stored and shared within a classroom.

The state keys `"SingleChoice"` and `"SingleChoiceMatrix"` are used for
checkboxes (`True`) and `"MultipleChoice"`/`"MultipleChoiceMatrix"` for radio
buttons. The names are swapped, but they are kept for stored data.

-}

import Conditional.List as CList
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Inline.Json.Encode as Inline
import Lia.Markdown.Survey.Types
    exposing
        ( Element
        , State(..)
        , Survey
        , Type(..)
        , Vector
        , initOptions
        )


{-| Encode the survey definition, `encoder` is used for the bodies of the
`Vector` options.
-}
encode : (body -> JE.Value) -> Survey body -> JE.Value
encode encoder survey =
    JE.object
        [ ( "id", JE.int survey.id )
        , case survey.survey of
            Text i ->
                ( "Text", JE.int i )

            Select elements ->
                ( "Select", JE.list Inline.encode elements )

            DragAndDrop elements ->
                ( "Drop", JE.list Inline.encode elements )

            Vector bool options _ ->
                ( "Vector"
                , JE.object
                    [ ( "bool", JE.bool bool )
                    , ( "options"
                      , options
                            |> List.map (Tuple.mapSecond (JE.list encoder))
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


{-| Encode the states of all surveys of a section, to be stored.
-}
fromVector : Vector -> JE.Value
fromVector =
    JE.array fromElement


{-| Only the user's input is stored, the options and scripts are defined by
the course.
-}
fromElement : Element -> JE.Value
fromElement element =
    [ ( "submitted", JE.bool element.submitted )
    , ( "state", fromState element.state )
    ]
        |> CList.addWhen (Maybe.map (JE.string >> Tuple.pair "errorMessage") element.errorMsg)
        |> JE.object


{-| Encode a state as an object with a single key, which defines its type. The
open dropdown and the drag state are not encoded.
-}
fromState : State -> JE.Value
fromState state =
    JE.object
        [ case state of
            Text_State str ->
                ( "Text", JE.string str )

            Select_State _ i ->
                ( "Select", JE.int i )

            DragAndDrop_State _ _ i ->
                ( "Drop", JE.int i )

            Vector_State checkbox vector ->
                ( if checkbox then
                    "SingleChoice"

                  else
                    "MultipleChoice"
                , fromDict vector
                )

            Matrix_State checkbox matrix ->
                ( if checkbox then
                    "SingleChoiceMatrix"

                  else
                    "MultipleChoiceMatrix"
                , JE.array fromDict matrix
                )
        ]


fromDict : Dict String Bool -> JE.Value
fromDict =
    Dict.toList
        >> List.map (Tuple.mapSecond JE.bool)
        >> JE.object


{-| Decode a stored vector, it has to be merged with the parsed one (see
`Survey.Update`), since the options and scripts are missing.
-}
toVector : JD.Value -> Result JD.Error Vector
toVector =
    JD.decodeValue (JD.array toElement)


toElement : JD.Decoder Element
toElement =
    JD.map3
        (\submitted state errorMsg ->
            { submitted = submitted
            , state = state
            , errorMsg = errorMsg
            , scriptID = Nothing
            , opt = initOptions
            }
        )
        (JD.field "submitted" JD.bool)
        (JD.field "state" toState)
        (JD.maybe (JD.field "errorMessage" JD.string))


{-| Decode a state encoded by `fromState`.

**Note:** The matrix types are decoded swapped (`"SingleChoiceMatrix"` becomes
`Matrix_State False`).

-}
toState : JD.Decoder State
toState =
    JD.oneOf
        [ JD.field "Text" JD.string
            |> JD.map Text_State
        , JD.field "Select" JD.int
            |> JD.map (Select_State False)
        , JD.field "Drop" JD.int
            |> JD.map (DragAndDrop_State False False)
        , JD.field "SingleChoice" (JD.dict JD.bool)
            |> JD.map (Vector_State True)
        , JD.field "MultipleChoice" (JD.dict JD.bool)
            |> JD.map (Vector_State False)
        , JD.field "SingleChoiceMatrix" (JD.array (JD.dict JD.bool))
            |> JD.map (Matrix_State False)
        , JD.field "MultipleChoiceMatrix" (JD.array (JD.dict JD.bool))
            |> JD.map (Matrix_State True)
        ]
