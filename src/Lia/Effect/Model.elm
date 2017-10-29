module Lia.Effect.Model
    exposing
        ( Model
        , Status(..)
        , get_comment
        , init
        , init_silent
          --  , scan_for_comments
        )

--import Lia.Index.Model exposing (parse_inlines)

import Array exposing (Array)
import Lia.Types exposing (Block(..), Section)


type alias Model =
    { visible : Int
    , effects : Int
    , status : Status
    , comments : Array (Maybe String)
    , narrator : String
    }


type Status
    = Speaking
    | Silent
    | Error String


init : String -> Maybe Section -> Model
init narrator maybe =
    --case maybe of
    --Just slide ->
    --    Model 0 slide.effects Silent (scan_for_comments slide.effects slide.body) narrator
    --Nothing ->
    Model 0 0 Silent Array.empty narrator


init_silent : Model
init_silent =
    Model 9999 9999 Silent Array.empty ""


get_comment : Model -> Maybe String
get_comment model =
    model.comments
        |> Array.get model.visible
        |> Maybe.andThen (\a -> a)



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
