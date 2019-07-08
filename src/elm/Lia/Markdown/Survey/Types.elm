module Lia.Markdown.Survey.Types exposing
    ( Element
    , State(..)
    , Survey
    , Type(..)
    , Vector
    , toString
    )

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Markdown.Inline.Types exposing (Inlines, MultInlines)


type alias Vector =
    Array Element


type alias Element =
    ( Bool, State )


type State
    = Text_State String
    | Select_State Bool Int
    | Vector_State Bool (Dict String Bool)
    | Matrix_State Bool (Array (Dict String Bool))


toString : State -> String
toString state =
    case state of
        Text_State str ->
            str

        Select_State _ i ->
            String.fromInt i

        Vector_State _ dict ->
            "{"
                ++ (dict
                        |> Dict.toList
                        |> List.map key_value_string
                        |> List.intersperse ", "
                        |> String.concat
                   )
                ++ "}"

        Matrix_State _ array ->
            "["
                ++ (array
                        |> Array.toList
                        |> List.map (Vector_State False >> toString)
                        |> List.intersperse ",\n"
                        |> String.concat
                   )
                ++ "]"


key_value_string : ( String, Bool ) -> String
key_value_string ( key, value ) =
    "\""
        ++ key
        ++ "\": "
        ++ (if value then
                "1"

            else
                "0"
           )


type alias Survey =
    { survey : Type
    , id : Int
    , javascript : Maybe String
    }


type Type
    = Text Int
    | Select MultInlines
    | Vector Bool (List ( String, Inlines ))
    | Matrix Bool MultInlines (List String) MultInlines
