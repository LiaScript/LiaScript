module Lia.Markdown.HTML.View exposing (view)

import Dict
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Json.Encode as JE
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.Inline.Annotation exposing (Parameters, toAttribute)


view : (List (Html.Attribute msg) -> List (Html msg) -> Html msg) -> (x -> Html msg) -> Parameters -> Node x -> Html msg
view containerX fn attr obj =
    case obj of
        Node name attrs children ->
            children
                |> List.map fn
                |> Html.node name
                    (attr
                        |> List.append attrs
                        |> toAttribute
                    )

        NodeX content ->
            containerX [ Attr.property "innerHTML" <| JE.string content ] []
