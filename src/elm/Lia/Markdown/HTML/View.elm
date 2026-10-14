module Lia.Markdown.HTML.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Keyed
import Json.Encode as JE
import Lia.Markdown.HTML.Attributes exposing (Parameters, toAttribute)
import Lia.Markdown.HTML.Types exposing (Node(..))
import Svg


{-| Render a `Node`, `container` wraps raw `InnerHtml`, `fn` renders the
children and `attr` are additional attributes (annotations) for `Node` and
`OuterHtml`.
-}
view : (List (Html.Attribute msg) -> List (Html msg) -> Html msg) -> (x -> Html msg) -> Parameters -> Node x -> Html msg
view container fn attr obj =
    case obj of
        Node name attrs children ->
            Html.node name
                (toAttribute (attrs ++ attr))
                (List.map fn children)

        InnerHtml content ->
            container [ innerHTML content ] []

        OuterHtml name attrs body ->
            Html.node name
                (toAttribute (attrs ++ attr))
                [ Html.text body ]

        SvgNode attrs body foreignObjects ->
            -- keyed by the svg code, a changed svg is replaced instead of
            -- patched, its innerHTML is not known to the virtual DOM
            Html.Keyed.node "div"
                []
                [ ( body
                  , Svg.svg
                        (innerHTML body :: toAttribute attrs)
                        (List.map
                            (\( foreignAttributes, children ) ->
                                Svg.foreignObject
                                    (toAttribute foreignAttributes)
                                    (List.map fn children)
                            )
                            foreignObjects
                        )
                  )
                ]


innerHTML : String -> Html.Attribute msg
innerHTML =
    JE.string >> Attr.property "innerHTML"
