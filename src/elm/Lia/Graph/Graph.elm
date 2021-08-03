module Lia.Graph.Graph exposing
    ( Graph
    , addEdge
    , addNode
    , empty
    , getEdges
    , getNodeById
    , getNodes
    , setSectionVisibility
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


addEdge : Node -> Node -> Graph -> Graph
addEdge parent child =
    Dict.update
        (Node.id parent)
        (Maybe.map (Node.connect child))


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


getEdges : Graph -> List ( String, String )
getEdges =
    Dict.toList
        >> List.map
            (\( key, node ) ->
                node
                    |> Node.children
                    |> List.map (Tuple.pair key)
            )
        >> List.concat
