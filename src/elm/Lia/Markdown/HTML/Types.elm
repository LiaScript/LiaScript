module Lia.Markdown.HTML.Types exposing
    ( Node(..)
    , Type(..)
    , decode
    , encode
    )

import Dict
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.HTML.Attributes exposing (Parameters)


{-| A parsed HTML element, `content` are blocks or inlines:

  - `Node`: a plain HTML element with parsed Markdown children
  - `InnerHtml`: raw HTML, inserted as is (`<lia-keep>` or an `<svg>`)
  - `OuterHtml`: a web component with its body kept as text
  - `SvgNode`: SVG code with its `<foreignObject>`s cut out, these are parsed
    as Markdown and appended to the svg in the view

-}
type Node content
    = Node String Parameters (List content)
    | InnerHtml String
    | OuterHtml String Parameters String
    | SvgNode Parameters String (List ( Parameters, List content ))


{-| The kind of an opening tag, as identified by the parser.
-}
type Type
    = WebComponent String
    | HtmlNode String
    | HtmlVoidNode String
    | LiaKeep
    | SVG


{-| Used for inlines stored in the course index, `decode` reads it back.
Duplicate attribute names are dropped and the order is lost.
-}
encode : (content -> JE.Value) -> Node content -> JE.Value
encode contentEncoder obj =
    JE.object <|
        case obj of
            Node node attr children ->
                [ ( "node", JE.string node )
                , ( "attr", encAttr attr )
                , ( "children", JE.list contentEncoder children )
                ]

            InnerHtml content ->
                [ ( "node_inline", JE.string content ) ]

            OuterHtml name attr body ->
                [ ( "node_outline", JE.string name )
                , ( "attr", encAttr attr )
                , ( "body", JE.string body )
                ]

            SvgNode attr code foreignObjects ->
                [ ( "node_svg", JE.string code )
                , ( "attr", encAttr attr )
                , ( "foreignObjects"
                  , JE.list
                        (\( foreignAttr, children ) ->
                            JE.object
                                [ ( "attr", encAttr foreignAttr )
                                , ( "objects", JE.list contentEncoder children )
                                ]
                        )
                        foreignObjects
                  )
                ]


encAttr : Parameters -> JE.Value
encAttr =
    Dict.fromList >> JE.dict identity JE.string


decode : JD.Decoder content -> JD.Decoder (Node content)
decode contentDecoder =
    JD.oneOf
        [ JD.map3 Node
            (JD.field "node" JD.string)
            decAttr
            (JD.field "children" (JD.list contentDecoder))
        , JD.map InnerHtml (JD.field "node_inline" JD.string)
        , JD.map3 OuterHtml
            (JD.field "node_outline" JD.string)
            decAttr
            (JD.field "body" JD.string)
        , JD.map3 (\code attr -> SvgNode attr code)
            (JD.field "node_svg" JD.string)
            decAttr
            (JD.field "foreignObjects"
                (JD.list
                    (JD.map2 Tuple.pair
                        decAttr
                        (JD.field "objects" (JD.list contentDecoder))
                    )
                )
            )
        ]


decAttr : JD.Decoder Parameters
decAttr =
    JD.field "attr" (JD.dict JD.string) |> JD.map Dict.toList
