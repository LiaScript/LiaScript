module Lia.Graph.Model exposing
    ( Model
    , addCourse
    , addHashtag
    , addLink
    , addSection
    , addSections
    , init
    , isRootNode
    )

import Array exposing (Array)
import Lia.Graph.Graph as Graph exposing (Graph)
import Lia.Graph.Node as Node exposing (Node(..))
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)


type alias Model =
    { graph : Graph
    , root : Maybe Node
    }


init : Model
init =
    Model
        Graph.empty
        Nothing


isRootNode : Model -> Node -> Bool
isRootNode model node =
    case ( model.root, node ) of
        ( Just (Section sec1), Section sec2 ) ->
            sec1.id == sec2.id

        _ ->
            False


addCourse : { name : String, url : String } -> Model -> Model
addCourse lia =
    rootConnect (Course { name = lia.name, url = lia.url, visible = True })


addHashtag : String -> Model -> Model
addHashtag name =
    rootConnect (Hashtag { name = name, visible = True })


addLink : { name : String, url : String } -> Model -> Model
addLink link =
    rootConnect (Link { name = link.name, url = link.url, visible = True })


addSection : Int -> Model -> Model
addSection id model =
    case model.root of
        Just root ->
            { model
                | graph =
                    Graph.addEdge
                        root
                        (Node.section id)
                        model.graph
            }

        _ ->
            model


rootConnect : Node -> Model -> Model
rootConnect node model =
    { model
        | graph =
            case model.root of
                Just root ->
                    model.graph
                        |> Graph.addNode node
                        |> Graph.addEdge root node

                Nothing ->
                    model.graph
                        |> Graph.addNode node
    }


addSections :
    Array
        { section
            | title : Inlines
            , id : Int
            , indentation : Int
            , code : String
        }
    -> Model
    -> Model
addSections sections model =
    { model | graph = addSectionsHelper [] (Array.toList sections) model.graph }


addSectionsHelper :
    List
        { section
            | title : Inlines
            , id : Int
            , indentation : Int
            , code : String
        }
    ->
        List
            { section
                | title : Inlines
                , id : Int
                , indentation : Int
                , code : String
            }
    -> Graph
    -> Graph
addSectionsHelper prev sections graph =
    case ( sections, prev ) of
        ( [], _ ) ->
            graph

        ( x :: xs, [] ) ->
            graph
                |> Graph.addNode
                    (Section
                        { id = x.id
                        , weight = String.length x.code
                        , indentation = x.indentation
                        , name = stringify x.title
                        , visible = True
                        }
                    )
                |> addSectionsHelper [ x ] xs

        ( x :: xs, p :: ps ) ->
            if x.indentation > p.indentation then
                graph
                    |> Graph.addNode
                        (Section
                            { id = x.id
                            , weight = String.length x.code
                            , indentation = x.indentation
                            , name = stringify x.title
                            , visible = True
                            }
                        )
                    |> Graph.addEdge (Node.section p.id) (Node.section x.id)
                    |> addSectionsHelper (x :: prev) xs

            else
                addSectionsHelper ps sections graph
