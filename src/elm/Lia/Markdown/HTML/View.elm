module Lia.Markdown.HTML.View exposing (view)

import Dict
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Json.Encode as JE
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.Inline.Types exposing (Annotation)


view : (List (Html.Attribute msg) -> List (Html msg) -> Html msg) -> (x -> Html msg) -> Annotation -> Node x -> Html msg
view containerX fn attr obj =
    case obj of
        Node name attrs children ->
            children
                |> List.map fn
                |> Html.node name (toAttribute attrs attr)

        NodeX content ->
            containerX [ Attr.property "innerHTML" <| JE.string content ] []


toAttribute : List ( String, String ) -> Annotation -> List (Attribute msg)
toAttribute attrs attr =
    List.map attribute <|
        case attr of
            Just dict ->
                attrs
                    |> Dict.fromList
                    |> Dict.union dict
                    |> Dict.toList

            Nothing ->
                attrs


attribute : ( String, String ) -> Attribute msg
attribute ( name, value ) =
    Attr.attribute name value
