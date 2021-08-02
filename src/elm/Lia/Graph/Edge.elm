module Lia.Graph.Edge exposing
    ( Edge
    , Edges
    , add
    )

import Lia.Graph.Node as Node exposing (Node)


type alias Edge =
    { from : String
    , to : String
    }


type alias Edges =
    List Edge


add : Node -> Node -> Edges -> Edges
add from to edges =
    let
        edge =
            Edge (Node.id from) (Node.id to)
    in
    if List.member edge edges then
        edges

    else
        edge :: edges
