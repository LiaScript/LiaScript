module Lia.Graph.Model exposing
    ( Edge
    , Graph
    , Node(..)
    , addCourse
    , addEdge
    , addHashtag
    , addLink
    , addNode
    , addSection
    , init
    , parseSections
    , rootSection
    )

import Array
import Dict exposing (Dict)
import Html exposing (node)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Section exposing (Section)


type Node
    = Hashtag String
    | Section Int Int String
    | Link String String
    | Course String String


type alias Edge =
    { from : String
    , to : String
    }


type alias Graph =
    { root : Maybe Node
    , node : Dict String Node
    , edge : List Edge
    }


init : Graph
init =
    Graph
        Nothing
        Dict.empty
        []


addNode : Node -> Graph -> Graph
addNode node graph =
    { graph
        | node =
            Dict.insert (nodeID node) node graph.node
    }


addEdge : Node -> Node -> Graph -> Graph
addEdge from to graph =
    let
        edge =
            Edge (nodeID from) (nodeID to)
    in
    if List.member edge graph.edge then
        graph

    else
        { graph
            | edge = Edge (nodeID from) (nodeID to) :: graph.edge
        }


nodeID : Node -> String
nodeID node =
    case node of
        Course _ url ->
            "lia: " ++ url

        Hashtag str ->
            "tag: " ++ String.toLower str

        Link _ url ->
            "url: " ++ url

        Section i _ _ ->
            "sec: " ++ String.fromInt i


addHashtag : String -> Graph -> Graph
addHashtag name =
    rootConnect (Hashtag name)


addLink : String -> String -> Graph -> Graph
addLink name url =
    rootConnect (Link name url)


addSection : Int -> Graph -> Graph
addSection id graph =
    case graph.root of
        Just root ->
            addEdge root (Section id -1 "") graph

        _ ->
            graph


addCourse : String -> String -> Graph -> Graph
addCourse name url =
    rootConnect (Course name url)


rootConnect : Node -> Graph -> Graph
rootConnect node graph =
    case graph.root of
        Just root ->
            graph
                |> addNode node
                |> addEdge root node

        Nothing ->
            addNode node graph


rootSection : Int -> Graph -> Graph
rootSection i graph =
    { graph | root = Just (Section i -1 "") }


parseSections sections =
    parseSectionsHelper [] (Array.toList sections)


parseSectionsHelper prev sections graph =
    case ( sections, prev ) of
        ( [], _ ) ->
            graph

        ( x :: xs, [] ) ->
            graph
                |> addNode (Section x.id x.indentation (stringify x.title))
                |> parseSectionsHelper [ x ] xs

        ( x :: xs, p :: ps ) ->
            if x.indentation > p.indentation then
                graph
                    |> addNode (Section x.id x.indentation (stringify x.title))
                    |> addEdge (Section p.id -1 "") (Section x.id -1 "")
                    |> parseSectionsHelper (x :: prev) xs

            else
                parseSectionsHelper ps sections graph
