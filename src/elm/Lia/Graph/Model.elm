module Lia.Graph.Model exposing
    ( Graph
    , addCourse
    , addEdge
    , addHashtag
    , addLink
    , addNode
    , addSection
    , init
    , isRootNode
    , parseSections
    , section
    )

import Array
import Browser.Events exposing (Visibility(..))
import Dict exposing (Dict)
import Html exposing (node)
import Lia.Graph.Edge as Edge exposing (Edges)
import Lia.Graph.Node as Node exposing (Node(..))
import Lia.Markdown.Inline.Stringify exposing (stringify)


type alias Graph =
    { root : Maybe Node
    , node : Dict String Node
    , edge : Edges
    }


init : Graph
init =
    Graph
        Nothing
        Dict.empty
        []


addNode : Node -> Graph -> Graph
addNode node graph =
    { graph | node = Dict.insert (Node.id node) node graph.node }


addEdge : Node -> Node -> Graph -> Graph
addEdge from to graph =
    { graph | edge = Edge.add from to graph.edge }


addHashtag : String -> Graph -> Graph
addHashtag name =
    rootConnect (Hashtag { name = name, visible = True })


addLink : { name : String, url : String } -> Graph -> Graph
addLink link =
    rootConnect (Link { name = link.name, url = link.url, visible = True })


section : Int -> Node
section id =
    Section
        { id = id
        , indentation = -1
        , weight = -1
        , name = ""
        , visible = False
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
    rootConnect (Course { name = lia.name, url = lia.url, visible = True })


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
                        , weight = String.length x.code
                        , indentation = x.indentation
                        , name = stringify x.title
                        , visible = True
                        }
                    )
                |> parseSectionsHelper [ x ] xs

        ( x :: xs, p :: ps ) ->
            if x.indentation > p.indentation then
                graph
                    |> addNode
                        (Section
                            { id = x.id
                            , weight = String.length x.code
                            , indentation = x.indentation
                            , name = stringify x.title
                            , visible = True
                            }
                        )
                    |> addEdge (section p.id) (section x.id)
                    |> parseSectionsHelper (x :: prev) xs

            else
                parseSectionsHelper ps sections graph


isRootNode : Graph -> Node -> Bool
isRootNode graph node =
    case ( graph.root, node ) of
        ( Just (Section sec1), Section sec2 ) ->
            sec1.id == sec2.id

        _ ->
            False
