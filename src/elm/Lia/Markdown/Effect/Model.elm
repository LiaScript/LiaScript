module Lia.Markdown.Effect.Model exposing
    ( Element
    , Model
    , current_comment
    , current_paragraphs
    , get_paragraph
    , init
    , set_annotation
    , toConfig
    )

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Markdown.Effect.JavaScript exposing (JavaScript)
import Lia.Markdown.HTML.Attributes as Attr exposing (Parameters)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Port.Eval exposing (Eval)


type alias Model =
    { visible : Int
    , effects : Int
    , comments : Dict Int Element
    , javascript : Array JavaScript
    , speaking : Maybe Int
    }


type alias Element =
    { narrator : String
    , comment : String
    , paragraphs : Array ( Parameters, Inlines )
    }


toConfig : Model -> Dict Int (Result String String)
toConfig =
    .javascript
        >> Array.indexedMap
            (\id js ->
                js.result
                    |> Maybe.map (Tuple.pair id)
            )
        >> Array.toList
        >> List.filterMap identity
        >> Dict.fromList


set_annotation : Int -> Int -> Dict Int Element -> Parameters -> Dict Int Element
set_annotation id1 id2 m attr =
    case Dict.get id1 m of
        Just e ->
            case Array.get id2 e.paragraphs of
                Just ( _, par ) ->
                    Dict.insert id1
                        { e
                            | paragraphs =
                                e.paragraphs
                                    |> Array.set id2 ( attr, par )
                        }
                        m

                Nothing ->
                    m

        Nothing ->
            m


get_paragraph : Int -> Int -> Model -> Maybe ( Parameters, Inlines )
get_paragraph id1 id2 model =
    case
        model.comments
            |> Dict.get id1
            |> Maybe.map .paragraphs
            |> Maybe.map (Array.get id2)
    of
        Just a ->
            a

        _ ->
            Nothing


current_paragraphs : Model -> List ( Parameters, Inlines )
current_paragraphs model =
    case Dict.get model.visible model.comments of
        Just e ->
            Array.toList e.paragraphs

        Nothing ->
            []


current_comment : Model -> Maybe ( String, String )
current_comment model =
    model.comments
        |> Dict.get model.visible
        |> Maybe.map (\e -> ( e.comment, e.narrator ))


init : Model
init =
    Model
        0
        0
        Dict.empty
        Array.empty
        Nothing
