module Lia.Graph.Model exposing
    ( Model
    , addCourse
    , addHashtag
    , addLink
    , addSection
    , addSections
    , init
    , isRootNode
    , updateJson
    )

import Array exposing (Array)
import Dict
import Json.Encode as JE
import Lia.Graph.Graph as Graph exposing (Graph)
import Lia.Graph.Node as Node exposing (Node(..))
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)


type alias Model =
    { graph : Graph
    , root : Maybe Node
    , json : JE.Value
    }


init : Model
init =
    Model
        Graph.empty
        Nothing
        JE.null


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


updateJson : Model -> Model
updateJson model =
    { model
        | json =
            JE.object
                [ ( "tooltip", JE.object [] )
                , ( "legend", JE.object [ ( "data", JE.list JE.string Node.categories ) ] )
                , ( "animationDurationUpdate", JE.int 100 )
                , ( "animationEasingUpdate", JE.string "quintcInOut" )
                , ( "series"
                  , [ ( "type", JE.string "graph" )
                    , ( "layout", JE.string "force" )
                    , ( "animation", JE.bool True )
                    , ( "categories", JE.list base Node.categories )
                    , ( "label", JE.object [ ( "show", JE.bool True ) ] )
                    , ( "symbolSize", JE.float 20 )
                    , ( "roam", JE.bool True )
                    , ( "force", force )
                    , ( "draggable", JE.bool True )
                    , ( "data"
                      , model.graph.node
                            |> Dict.toList
                            |> List.map
                                (\( id, node ) ->
                                    [ ( "id", JE.string id )
                                    , ( "name", JE.string <| Node.name node )
                                    , ( "category", JE.int <| Node.category node )
                                    , ( "tooltip", formatter node )
                                    , ( "symbolSize", JE.float <| Node.weight node )
                                    , ( "itemStyle"
                                      , JE.object <|
                                            if isRootNode model node then
                                                [ ( "borderColor", JE.string "#000" )
                                                , ( "borderWidth", JE.int 3 )
                                                ]

                                            else if Node.isVisible node then
                                                []

                                            else
                                                [ ( "opacity", JE.float 0.1 ) ]
                                      )
                                    ]
                                )
                            |> JE.list JE.object
                      )
                    , ( "edges"
                      , model.graph.edge
                            |> List.sortBy .from
                            |> List.map
                                (\edge ->
                                    [ ( "source", JE.string edge.from )
                                    , ( "target", JE.string edge.to )
                                    , ( "symbolSize", JE.list JE.int [ 5 ] )
                                    ]
                                )
                            |> JE.list JE.object
                      )
                    ]
                        |> JE.object
                  )
                ]
    }


force : JE.Value
force =
    JE.object
        [ ( "repulsion", JE.int 2500 )
        , ( "edgeLength", JE.int 120 )
        , ( "gravity", JE.float 0.2 )
        ]


formatter : Node -> JE.Value
formatter node =
    JE.object
        [ ( "formatter"
          , JE.string <|
                case node of
                    Hashtag tag ->
                        tag.name

                    Link { name, url } ->
                        name ++ ":<br/><a href='" ++ url ++ "'>" ++ url ++ "</a>"

                    Section sec ->
                        sec.name

                    Course lia ->
                        lia.name ++ ":<br/><a href='" ++ lia.url ++ "'>" ++ lia.url ++ "</a>"
          )
        ]


base : String -> JE.Value
base name =
    JE.object
        [ ( "name", JE.string name )
        , ( "base", JE.string name )
        ]
