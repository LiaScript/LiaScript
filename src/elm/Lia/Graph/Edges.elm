module Lia.Graph.Edges exposing
    ( Edges
    , add
    , empty
    , toList
    )

import Dict exposing (Dict)
import Lia.Graph.Node as Node exposing (Node)


type alias Edges =
    Dict String (List String)


empty : Edges
empty =
    Dict.empty


add : Node -> Node -> Edges -> Edges
add from to edges =
    let
        fromID =
            Node.id from

        toID =
            Node.id to
    in
    case Dict.get fromID edges of
        Just connections ->
            if List.member toID connections then
                edges

            else
                Dict.insert fromID (toID :: connections) edges

        _ ->
            Dict.insert fromID [ toID ] edges


toList : Edges -> List ( String, String )
toList =
    Dict.toList
        >> List.map (\( from, to ) -> List.map (Tuple.pair from) to)
        >> List.concat
