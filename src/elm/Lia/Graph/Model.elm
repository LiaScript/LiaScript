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
    , section
    )

import Array
import Dict exposing (Dict)
import Html exposing (node)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Section exposing (Section)


type Node
    = Hashtag String
    | Section { id : Int, weight : Int, name : String }
    | Link { name : String, url : String }
    | Course { name : String, url : String }


type alias Edge =
    { from : String
    , to : String
    }


type alias Graph =
    { root : Maybe Node
    , node : Dict String ( Node, Bool )
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
            Dict.insert (nodeID node) ( node, True ) graph.node
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
        Course lia ->
            "lia: " ++ lia.url

        Hashtag str ->
            "tag: " ++ String.toLower str

        Link link ->
            "url: " ++ link.url

        Section sec ->
            "sec: " ++ String.fromInt sec.id


addHashtag : String -> Graph -> Graph
addHashtag name =
    rootConnect (Hashtag name)


addLink : { name : String, url : String } -> Graph -> Graph
addLink link =
    rootConnect (Link link)


section : Int -> Node
section id =
    Section
        { id = id
        , weight = -1
        , name = ""
        }


addSection : Int -> Graph -> Graph
addSection id graph =
    case graph.root of
        Just root ->
            addEdge
                root
                (section id)
                graph

        _ ->
            graph


addCourse : { name : String, url : String } -> Graph -> Graph
addCourse lia =
    rootConnect (Course lia)


rootConnect : Node -> Graph -> Graph
rootConnect node graph =
    case graph.root of
        Just root ->
            graph
                |> addNode node
                |> addEdge root node

        Nothing ->
            addNode node graph


parseSections sections =
    parseSectionsHelper [] (Array.toList sections)


parseSectionsHelper prev sections graph =
    case ( sections, prev ) of
        ( [], _ ) ->
            graph

        ( x :: xs, [] ) ->
            graph
                |> addNode
                    (Section
                        { id = x.id
                        , weight = String.length x.code --x.indentation
                        , name = stringify x.title
                        }
                    )
                |> parseSectionsHelper [ x ] xs

        ( x :: xs, p :: ps ) ->
            if x.indentation > p.indentation then
                graph
                    |> addNode
                        (Section
                            { id = x.id
                            , weight = String.length x.code --x.indentation
                            , name = stringify x.title
                            }
                        )
                    |> addEdge (section p.id) (section x.id)
                    |> parseSectionsHelper (x :: prev) xs

            else
                parseSectionsHelper ps sections graph
