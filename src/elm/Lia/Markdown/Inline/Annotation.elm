module Lia.Markdown.Inline.Annotation exposing
    ( Annotation
    , annotation
    , attributes
    )

import Dict exposing (Dict)
import Html exposing (Attribute)
import Html.Attributes as Attr


type alias Annotation =
    Maybe (Dict String String)


annotation : String -> Annotation -> List (Attribute msg)
annotation cls attr =
    case attr of
        Just dict ->
            --Dict.update "class" (\v -> Maybe.map ()(++)(cls ++ " ")) v) dict
            dict
                |> Dict.insert "class"
                    (case Dict.get "class" dict of
                        Just c ->
                            "lia-inline " ++ cls ++ " " ++ c

                        Nothing ->
                            "lia-inline " ++ cls
                    )
                |> Dict.toList
                |> List.map (\( key, value ) -> Attr.attribute key value)

        Nothing ->
            [ Attr.class ("lia-inline " ++ cls) ]


attributes : Annotation -> List (Attribute msg)
attributes attr =
    case attr of
        Just dict ->
            dict
                |> Dict.toList
                |> List.map (\( key, value ) -> Attr.attribute key value)

        Nothing ->
            []
