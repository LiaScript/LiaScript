module Lia.Markdown.HTML.Types exposing
    ( Node(..)
    , Type(..)
    , decode
    , encode
    , getContent
    )

import Dict
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.HTML.Attributes exposing (Parameters)


type Node content
    = Node String Parameters (List content)
    | InnerHtml String
    | OuterHtml String Parameters String


type Type
    = WebComponent String
    | HtmlNode String
    | HtmlVoidNode String
    | LiaKeep
    | SVG


getContent : Node content -> List content
getContent node =
    case node of
        Node _ _ content ->
            content

        _ ->
            []


encode : (content -> JE.Value) -> Node content -> JE.Value
encode contentEncoder obj =
    JE.object <|
        case obj of
            Node node attr children ->
                [ ( "node", JE.string node )
                , ( "attr"
                  , attr
                        |> Dict.fromList
                        |> JE.dict identity JE.string
                  )
                , ( "children", JE.list contentEncoder children )
                ]

            InnerHtml content ->
                [ ( "node_inline", JE.string content ) ]

            OuterHtml name attr body ->
                [ ( "node_outline", JE.string name )
                , ( "attr"
                  , attr
                        |> Dict.fromList
                        |> JE.dict identity JE.string
                  )
                , ( "body", JE.string body )
                ]


decode : JD.Decoder content -> JD.Decoder (Node content)
decode contentDecoder =
    JD.map3 Node
        (JD.field "node" JD.string)
        (JD.field "attr" (JD.dict JD.string) |> JD.map Dict.toList)
        (JD.field "children" (JD.list contentDecoder))
