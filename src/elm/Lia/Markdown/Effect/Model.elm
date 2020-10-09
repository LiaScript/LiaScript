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
    , jsResult
    , set_annotation
    , toConfig
    )

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Types exposing (Inlines)


type alias Model =
    { visible : Int
    , effects : Int
    , comments : Map Element
    , javascript : Map (List JavaScript)
    , speaking : Maybe Int
    }


type alias JavaScript =
    { id : Int
    , script : String
    , result : Maybe String
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
    let
        counter =
            jsCount model
    in
    { model
        | javascript =
            Dict.insert idx
                (case Dict.get idx model.javascript of
                    Just a ->
                        List.append a [ JavaScript counter script Nothing ]

                    Nothing ->
                        [ JavaScript counter script Nothing ]
                )
                model.javascript
    }


toConfig : Model -> Dict Int String
toConfig =
    .javascript
        >> Dict.values
        >> List.concat
        >> List.filterMap
            (\js ->
                js.result
                    |> Maybe.map (Tuple.pair js.id)
            )
        >> Dict.fromList


jsResult : Int -> Model -> Maybe String
jsResult idx model =
    model.javascript
        |> Dict.values
        |> List.concat
        |> List.filter (.id >> (==) idx)
        |> List.head
        |> Maybe.andThen .result


jsCount : Model -> Int
jsCount =
    .javascript
        >> Dict.values
        >> List.map List.length
        >> List.sum


jsGet : Model -> List ( Int, String )
jsGet model =
    model.javascript
        |> Dict.get model.visible
        |> Maybe.map (List.map (\js -> ( js.id, js.script )))
        |> Maybe.withDefault []


jsGetAll : Model -> List ( Int, String )
jsGetAll =
    .javascript
        >> Dict.toList
        >> List.sortBy Tuple.first
        >> List.map (Tuple.second >> List.map (\js -> ( js.id, js.script )))
        >> List.concat


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
        Dict.empty
        Nothing
