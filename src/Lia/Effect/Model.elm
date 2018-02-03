module Lia.Effect.Model
    exposing
        ( Element
        , Map
        , Model
        , current_comment
        , current_paragraphs
        , get_paragraph
        , init
        )

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Markdown.Inline.Types exposing (Annotation, Inlines)


type alias Model =
    { visible : Int
    , effects : Int
    , comments : Map
    }


type alias Map =
    Dict Int Element


type alias Element =
    { narrator : String
    , comment : String
    , paragraphs : Array ( Annotation, Inlines )
    }


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


current_comment : Model -> Maybe String
current_comment model =
    model.comments
        |> Dict.get model.visible
        |> Maybe.map .comment



--type Status
--    = Speaking
--    | Silent
--    | Error String
--init : String -> Maybe Section -> Model


init : Model
init =
    --case maybe of
    --Just slide ->
    --    Model 0 slide.effects Silent (scan_for_comments slide.effects slide.body) narrator
    --Nothing ->
    Model 0 0 Dict.empty



--Silent Array.empty narrator
--init_silent : Model
--init_silent =
--    Model 9999 9999 Silent Array.empty ""
--get_comment : Model -> Maybe String
--get_comment model =
--    model.comments
--        |> Array.get model.visible
--        |> Maybe.andThen (\a -> a)
-- scan_for_comments : Int -> List Block -> Array (Maybe String)
-- scan_for_comments effect_count blocks =
--     let
--         ecomment block =
--             case block of
--                 EComment idx paragraph ->
--                     Just ( idx, parse_inlines paragraph )
--
--                 _ ->
--                     Nothing
--
--         find : List ( Int, String ) -> Int -> Maybe String -> Maybe String
--         find comments idx _ =
--             comments
--                 |> List.filter (\( i, _ ) -> i == idx)
--                 |> List.head
--                 |> Maybe.andThen (\( _, str ) -> Just str)
--     in
--     case List.filterMap ecomment blocks of
--         [] ->
--             Array.empty
--
--         comments ->
--             let
--                 find_comments =
--                     find comments
--             in
--             Array.repeat (effect_count + 1) Nothing
--                 |> Array.indexedMap find_comments
