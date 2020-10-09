module Lia.Markdown.Effect.Model exposing
    ( Element
    , Map
    , Model
    , current_comment
    , current_paragraphs
    , get_paragraph
    , init
    , jsAdd
    , jsCount
    , jsGet
    , jsGetAll
    , jsGetResult
    , jsSetResult
    , set_annotation
    , toConfig
    )

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Port.Eval exposing (Eval)


type alias Model =
    { visible : Int
    , effects : Int
    , comments : Map Element
    , javascript : Array JavaScript
    , speaking : Maybe Int
    }


type alias JavaScript =
    { effect_id : Int
    , script : String
    , result : Maybe (Result String String)
    }


type alias Map e =
    Dict Int e


type alias Element =
    { narrator : String
    , comment : String
    , paragraphs : Array ( Parameters, Inlines )
    }


jsAdd : Int -> String -> Model -> Model
jsAdd idx script model =
    { model
        | javascript =
            Array.push
                (JavaScript idx script Nothing)
                model.javascript
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


jsGetResult : Int -> Model -> Maybe String
jsGetResult idx =
    .javascript
        >> Array.get idx
        >> Maybe.andThen .result
        >> Maybe.andThen Result.toMaybe


jsSetResult : Int -> Model -> Eval -> Model
jsSetResult idx model eval =
    { model
        | javascript =
            case Array.get idx model.javascript of
                Just js ->
                    Array.set idx
                        { js
                            | result =
                                Just
                                    (if eval.ok then
                                        Ok eval.result

                                     else
                                        Err eval.result
                                    )
                        }
                        model.javascript

                _ ->
                    model.javascript
    }


jsCount : Model -> Int
jsCount =
    .javascript
        >> Array.length
        >> (+) -1


jsGet : Model -> List ( Int, String )
jsGet model =
    model.javascript
        |> Array.indexedMap
            (\i js ->
                if js.effect_id == model.visible then
                    Just ( i, js.script )

                else
                    Nothing
            )
        |> Array.toList
        |> List.filterMap identity


jsGetAll : Model -> List ( Int, String )
jsGetAll =
    .javascript
        >> Array.indexedMap (\i js -> ( i, js.script ))
        >> Array.toList
        >> List.sortBy Tuple.first


set_annotation : Int -> Int -> Map Element -> Parameters -> Map Element
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
