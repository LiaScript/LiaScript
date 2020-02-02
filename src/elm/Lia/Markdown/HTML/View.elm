module Lia.Markdown.HTML.View exposing (view)

import Dict
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.Inline.Types exposing (Annotation)


view : (x -> Html msg) -> Annotation -> Node x -> Html msg
view fn attr (Node name attrs children) =
    children
        |> List.map fn
        |> Html.node name (toAttribute attrs)


toAttribute : List ( String, String ) -> List (Attribute msg)
toAttribute attrs =
    attrs
        |> Dict.fromList
        |> Dict.toList
        |> List.map (\( name, value ) -> Attr.attribute name value)
