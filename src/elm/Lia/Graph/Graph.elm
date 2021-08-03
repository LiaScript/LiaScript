module Lia.Graph.Graph exposing
    ( Graph
    , addLink
    , addNode
    , addParent
    , empty
    , getConnections
    , getLinks
    , getNodeById
    , getNodes
    , setSectionVisibility
    , toList
    , zip
    )

import Dict exposing (Dict)
import Lia.Graph.Node as Node exposing (Node(..))
import Set


type alias Graph =
    Dict String Node


empty : Graph
empty =
    Dict.empty


addNode : Node -> Graph -> Graph
addNode node =
    Dict.insert (Node.identifier node) node


addParent : Node -> Node -> Graph -> Graph
addParent parent child =
    Dict.update
        (Node.identifier parent)
        (Maybe.map (Node.addParent child))


addLink : Node -> Node -> Graph -> Graph
addLink parent child =
    Dict.update
        (Node.identifier parent)
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


zip : Int -> Graph -> Graph
zip indentation graph =
    if indentation >= 0 && indentation < 6 then
        zip_ indentation 6 graph

    else
        graph


zip_ minimum maximum graph =
    if minimum == maximum then
        graph

    else
        graph
            |> zipHelper maximum
            |> zip_ minimum (maximum - 1)


zipHelper : Int -> Graph -> Graph
zipHelper indentation graph =
    let
        ( true, false ) =
            Dict.partition (filter indentation) graph
    in
    false
        |> getNodes
        |> List.foldl
            (\node container ->
                case Node.parent node of
                    Just id ->
                        Dict.update id
                            (Maybe.map (shallowCopy graph node))
                            container

                    _ ->
                        container
            )
            true


shallowCopy : Graph -> Node -> Node -> Node
shallowCopy graph source target =
    case ( source, target ) of
        ( Section sourceData, Section targetData ) ->
            Section
                { targetData
                    | weight = targetData.weight + sourceData.weight
                    , links =
                        Set.union targetData.links sourceData.links
                            |> Set.map (updateLinks graph sourceData.indentation)
                }

        _ ->
            target


filter : Int -> String -> Node -> Bool
filter maximum _ node =
    case node of
        Section data ->
            maximum > data.indentation

        _ ->
            True


updateLinks : Graph -> Int -> String -> String
updateLinks db indentation id =
    case getNodeById db id of
        Just (Section data) ->
            if data.indentation >= indentation then
                Maybe.withDefault id data.parent

            else
                id

        _ ->
            id
