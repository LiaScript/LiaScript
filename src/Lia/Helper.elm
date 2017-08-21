module Lia.Helper
    exposing
        ( get_headers
        , get_slide
        , get_slide_effects
        )

import Lia.Type exposing (Block(..), Quiz(..), Slide)


get_headers : List Slide -> List ( Int, ( String, Int ) )
get_headers slides =
    slides
        |> List.map (\s -> ( s.title, s.indentation ))
        |> List.indexedMap (,)


get_slide : Int -> List Slide -> Maybe Slide
get_slide i slides =
    case ( i, slides ) of
        ( _, [] ) ->
            Nothing

        ( 0, x :: xs ) ->
            Just x

        ( n, _ :: xs ) ->
            get_slide (n - 1) xs


get_slide_effects : Int -> List Slide -> Int
get_slide_effects i slides =
    case get_slide i slides of
        Just slide ->
            slide.effects

        Nothing ->
            0
