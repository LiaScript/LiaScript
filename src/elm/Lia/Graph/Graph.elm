module Lia.Graph.Graph exposing
    ( Graph
    , addEdge
    , addNode
    , empty
    , getNodeById
    , setSectionVisibility
    )

import Dict exposing (Dict)
import Lia.Graph.Edges as Edges exposing (Edges)
import Lia.Graph.Node as Node exposing (Node(..))


type alias Graph =
    { node : Dict String Node
    , edge : Edges
    }


empty : Graph
empty =
    Graph
        Dict.empty
        Edges.empty


addNode : Node -> Graph -> Graph
addNode node graph =
    { graph | node = Dict.insert (Node.id node) node graph.node }


addEdge : Node -> Node -> Graph -> Graph
addEdge from to graph =
    { graph | edge = Edges.add from to graph.edge }


setSectionVisibility : Graph -> List Int -> Graph
setSectionVisibility graph ids =
    { graph | node = Dict.map (secVisibility ids) graph.node }


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
    Dict.get identifier graph.node
