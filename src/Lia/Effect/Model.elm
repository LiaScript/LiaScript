module Lia.Effect.Model
    exposing
        ( Element
        , Map
        , Model
        , current_comment
        , current_paragraphs
        , get_paragraph
        , init
        , set_annotation
        )

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Markdown.Inline.Types exposing (Annotation, Inlines)


type alias Model =
    { visible : Int
    , effects : Int
    , comments : Map Element
    , javascript : Map (Array String)
    }


type alias Map e =
    Dict Int e


type alias Element =
    { narrator : String
    , comment : String
    , paragraphs : Array ( Annotation, Inlines )
    }


set_annotation : Int -> Int -> Map Element -> Annotation -> Map Element
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


get_paragraph : Int -> Int -> Model -> Maybe ( Annotation, Inlines )
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


current_paragraphs : Model -> List ( Annotation, Inlines )
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
    Model 0 0 Dict.empty Dict.empty
