module Lia.Graph.Json exposing (encode)

import Json.Encode as JE
import Lia.Graph.Graph exposing (Graph)
import Lia.Graph.Node exposing (Node(..))


encode : Graph -> JE.Value
encode graph =
    JE.dict identity fromNode graph


fromNode : Node -> JE.Value
fromNode node =
    case node of
        Section sec ->
            [ fromName sec
            , ( "id", JE.int sec.id )
            , ( "indentation", JE.int sec.indentation )
            , ( "weight", JE.int sec.weight )
            , ( "children", JE.list JE.string sec.children )
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
