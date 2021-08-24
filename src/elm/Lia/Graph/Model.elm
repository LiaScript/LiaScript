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
import Json.Encode as JE
import Lia.Graph.Graph as Graph exposing (Graph)
import Lia.Graph.Node as Node exposing (Node, Type(..))
import Lia.Graph.Settings as Settings exposing (Settings)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Set


type alias Model =
    { graph : Graph
    , root : Maybe Node
    , json : JE.Value
    , settings : Settings
    }


init : Model
init =
    Model
        Graph.empty
        Nothing
        JE.null
        Settings.init


isRootNode : Model -> Node -> Bool
isRootNode model node =
    model.root
        |> Maybe.map (Node.equal node)
        |> Maybe.withDefault False


addCourse : { name : String, url : String } -> Model -> Model
addCourse lia =
    rootConnect lia.name (Course lia.url)


addHashtag : String -> Model -> Model
addHashtag name =
    rootConnect name Hashtag


addLink : { name : String, url : String } -> Model -> Model
addLink link =
    rootConnect link.name (Link link.url)


addSection : Int -> Model -> Model
addSection id model =
    case model.root of
        Just root ->
            { model
                | graph =
                    Graph.addLink
                        root
                        (Node.section id)
                        model.graph
            }

        _ ->
            model


rootConnect : String -> Type -> Model -> Model
rootConnect name data model =
    { model
        | graph =
            case model.root of
                Just root ->
                    model.graph
                        |> Graph.addNode (new name data)
                        |> Graph.addLink root (new name data)

                Nothing ->
                    model.graph
                        |> Graph.addNode (new name data)
    }


new : String -> Type -> Node
new name =
    Node name True Set.empty


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
                    ({ id = x.id
                     , weight = String.length x.code
                     , indentation = x.indentation
                     , parent = Nothing
                     }
                        |> Section
                        |> Node (stringify x.title) True Set.empty
                    )
                |> addSectionsHelper [ x ] xs

        ( x :: xs, p :: ps ) ->
            if x.indentation > p.indentation then
                graph
                    |> Graph.addNode
                        ({ id = x.id
                         , weight = String.length x.code
                         , indentation = x.indentation
                         , parent = Just <| Node.identifier <| Node.section p.id
                         }
                            |> Section
                            |> Node (stringify x.title) True Set.empty
                        )
                    |> addSectionsHelper (x :: prev) xs

            else
                addSectionsHelper ps sections graph


updateJson : Model -> Model
updateJson model =
    let
        graph =
            if not model.settings.showGlobalGraph then
                model.root
                    |> Maybe.map (\root -> Graph.local root model.graph)
                    |> Maybe.withDefault model.graph

            else if model.settings.indentation < 6 then
                Graph.zip model.settings.indentation model.graph

            else
                model.graph
    in
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
                    , emphasis
                    , ( "data"
                      , graph
                            |> Graph.toList
                            |> List.map
                                (\( id, node ) ->
                                    [ ( "id", JE.string id )
                                    , ( "name", JE.string <| node.name )
                                    , ( "category", JE.int <| Node.category node )
                                    , ( "tooltip", formatter node )

                                    --, ( "symbolSize", JE.float <| Node.weight node )
                                    , ( "itemStyle"
                                      , JE.object <|
                                            if isRootNode model node then
                                                [ ( "borderColor", JE.string "#000" )
                                                , ( "borderWidth", JE.int 3 )
                                                ]

                                            else if node.visible then
                                                []

                                            else
                                                [ ( "opacity", JE.float 0.1 ) ]
                                      )
                                    ]
                                )
                            |> JE.list JE.object
                      )
                    , ( "edges"
                      , graph
                            |> (if model.settings.showDocumentStructure then
                                    Graph.getConnections

                                else
                                    Graph.getLinks
                               )
                            |> List.map
                                (\( from, to ) ->
                                    [ ( "source", JE.string from )
                                    , ( "target", JE.string to )
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
                case node.data of
                    Hashtag ->
                        node.name

                    Link url ->
                        node.name ++ ":<br/><a href='" ++ url ++ "'>" ++ url ++ "</a>"

                    Section _ ->
                        node.name

                    Course url ->
                        node.name ++ ":<br/><a href='" ++ url ++ "'>" ++ url ++ "</a>"
          )
        ]


base : String -> JE.Value
base name =
    JE.object
        [ ( "name", JE.string name )
        , ( "base", JE.string name )
        ]


emphasis : ( String, JE.Value )
emphasis =
    ( "emphasis"
    , JE.object
        [ ( "focus", JE.string "adjacency" )
        , ( "lineStyle", JE.object [ ( "width", JE.int 10 ) ] )
        ]
    )
