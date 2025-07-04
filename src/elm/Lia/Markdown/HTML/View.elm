module Lia.Markdown.HTML.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Keyed
import Json.Encode as JE
import Lia.Markdown.HTML.Attributes exposing (Parameters, toAttribute)
import Lia.Markdown.HTML.Types exposing (Node(..))
import Svg


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

        InnerHtml content ->
            containerX [ Attr.property "innerHTML" <| JE.string content ] []

        OuterHtml name attrs body ->
            Html.node name
                (attr
                    |> List.append attrs
                    |> toAttribute
                )
                [ Html.text body ]

        SvgNode attrs body foreignObjects ->
            Html.Keyed.node "div"
                []
                [ ( body
                  , Svg.svg
                        ((body
                            |> JE.string
                            |> Attr.property "innerHTML"
                         )
                            :: toAttribute attrs
                        )
                        (foreignObjects
                            |> List.map
                                (\( foreignAttributes, foreignObject ) ->
                                    foreignObject
                                        |> List.map fn
                                        |> Svg.foreignObject (toAttribute foreignAttributes)
                                )
                        )
                  )
                ]
