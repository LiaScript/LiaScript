module Lia.Markdown.HTML.Types exposing
    ( Node(..)
    , decode
    , encode
    , getContent
    )

import Dict
import Json.Decode as JD
import Json.Encode as JE


type Node content
    = Node String (List ( String, String )) (List content)


getContent : Node content -> List content
getContent (Node _ _ content) =
    content


encode : (content -> JE.Value) -> Node content -> JE.Value
encode contentEncoder (Node node attr children) =
    JE.object
        [ ( "node", JE.string node )
        , ( "attr"
          , attr
                |> Dict.fromList
                |> JE.dict identity JE.string
          )
        , ( "children", JE.list contentEncoder children )
        ]


decode : JD.Decoder content -> JD.Decoder (Node content)
decode contentDecoder =
    JD.map3 Node
        (JD.field "node" JD.string)
        (JD.field "attr" (JD.dict JD.string) |> JD.map Dict.toList)
        (JD.field "children" (JD.list contentDecoder))
