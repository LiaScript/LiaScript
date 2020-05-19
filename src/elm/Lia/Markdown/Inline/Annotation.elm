module Lia.Markdown.Inline.Annotation exposing
    ( Parameters
    , annotation
    , toAttribute
    )

import Dict exposing (Dict)
import Html exposing (Attribute)
import Html.Attributes as Attr


type alias Parameters =
    List ( String, String )


annotation : String -> Parameters -> List (Attribute msg)
annotation cls =
    (::) ( "class", "lia-inline " ++ cls ) >> toAttribute


toAttribute : Parameters -> List (Attribute msg)
toAttribute =
    List.map (\( key, value ) -> Attr.attribute key value)
