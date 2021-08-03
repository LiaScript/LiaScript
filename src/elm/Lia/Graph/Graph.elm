module Lia.Graph.Graph exposing
    ( Graph
    , addChild
    , addLink
    , addNode
    , empty
    , getChildren
    , getConnections
    , getLinks
    , getNodeById
    , getNodes
    , setSectionVisibility
    , toList
    )

import Dict exposing (Dict)
import Lia.Graph.Node as Node exposing (Node(..))


type alias Graph =
    Dict String Node


empty : Graph
empty =
    Dict.empty


addNode : Node -> Graph -> Graph
addNode node =
    Dict.insert (Node.id node) node


addChild : Node -> Node -> Graph -> Graph
addChild parent child =
    Dict.update
        (Node.id parent)
        (Maybe.map (Node.addChild child))


addLink : Node -> Node -> Graph -> Graph
addLink parent child =
    Dict.update
        (Node.id parent)
        (Maybe.map (Node.addLink child))


setSectionVisibility : Graph -> List Int -> Graph
setSectionVisibility graph ids =
    Dict.map (secVisibility ids) graph


secVisibility : List Int -> x -> Node -> Node
secVisibility ids _ node =
    case node of
        Section sec ->
            Section
                { sec
                    | visible =
                        if List.isEmpty ids then
                            True

                        else
                            List.member sec.id ids
                }

        _ ->
            node


getNodeById : Graph -> String -> Maybe Node
getNodeById graph identifier =
    Dict.get identifier graph


getNodes : Graph -> List Node
getNodes =
    Dict.values


toList : Graph -> List ( String, Node )
toList =
    Dict.toList


getLinks : Graph -> List ( String, String )
getLinks =
    getEdges Node.links


getChildren : Graph -> List ( String, String )
getChildren =
    getEdges Node.children


getConnections : Graph -> List ( String, String )
getConnections =
    getEdges Node.connections


getEdges : (Node -> List String) -> Graph -> List ( String, String )
getEdges fn =
    toList
        >> List.map
            (\( key, node ) ->
                node
                    |> fn
                    |> List.map (Tuple.pair key)
            )
        >> List.concat
