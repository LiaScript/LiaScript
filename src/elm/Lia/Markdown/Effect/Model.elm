module Lia.Markdown.Effect.Model exposing
    ( Element
    , Map
    , Model
    , add_javascript
    , current_comment
    , current_paragraphs
    , get_all_javascript
    , get_javascript
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
    , javascript : Map (List String)
    }


type alias Map e =
    Dict Int e


type alias Element =
    { narrator : String
    , comment : String
    , paragraphs : Array ( Annotation, Inlines )
    }


add_javascript : Int -> String -> Model -> Model
add_javascript idx script model =
    { model
        | javascript =
            Dict.insert idx
                (case Dict.get idx model.javascript of
                    Just a ->
                        List.append a [ script ]

                    Nothing ->
                        [ script ]
                )
                model.javascript
    }


get_javascript : Model -> List String
get_javascript model =
    case Dict.get model.visible model.javascript of
        Just a ->
            a

        _ ->
            []


get_all_javascript : Model -> List String
get_all_javascript model =
    model.javascript
        |> Dict.toList
        |> List.sort
        |> List.map (\( _, v ) -> v)
        |> List.concat


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
