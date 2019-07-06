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
    | Vector_State Bool (Dict String Bool)
    | Matrix_State Bool (Array (Dict String Bool))


toString : State -> String
toString state =
    case state of
        Text_State str ->
            str

        _ ->
            ""


type alias Survey =
    { survey : Type
    , id : Int
    , javascript : Maybe String
    }


type Type
    = Text Int
    | Vector Bool (List ( String, Inlines ))
    | Matrix Bool MultInlines (List String) MultInlines
