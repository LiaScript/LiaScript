module Lia.Graph.Json exposing (encode)

import Dict
import Json.Encode as JE
import Lia.Graph.Model
    exposing
        ( Edge
        , Graph
        , Node(..)
        )


encode : Graph -> JE.Value
encode graph =
    JE.object
        [ ( "node"
          , graph.node
                |> Dict.map (\_ ( node, _ ) -> node)
                |> JE.dict identity fromNode
          )
        , ( "edge", JE.list fromEdge graph.edge )
        ]


fromEdge : Edge -> JE.Value
fromEdge edge =
    JE.list JE.string [ edge.from, edge.to ]


fromNode : Node -> JE.Value
fromNode node =
    case node of
        Section sec ->
            [ fromName sec
            , ( "id", JE.int sec.id )
            , ( "indentation", JE.int sec.indentation )
            , ( "weight", JE.int sec.weight )
            ]
                |> fromType "sec"

        Link link ->
            [ fromName link
            , fromUrl link
            ]
                |> fromType "url"

        Hashtag tag ->
            [ fromName tag ]
                |> fromType "tag"

        Course course ->
            [ fromName course
            , fromUrl course
            ]
                |> fromType "lia"


fromName : { node | name : String } -> ( String, JE.Value )
fromName node =
    ( "name", JE.string node.name )


fromUrl : { node | url : String } -> ( String, JE.Value )
fromUrl node =
    ( "url", JE.string node.url )


fromType : String -> List ( String, JE.Value ) -> JE.Value
fromType name obj =
    JE.object [ ( name, JE.object obj ) ]
