module Lia.Graph.View exposing (..)

import Dict
import Html exposing (Html)
import Html.Attributes exposing (title)
import Html.Lazy
import Json.Encode as JE
import Lia.Graph.Model exposing (Graph, Node(..))
import Lia.Markdown.Chart.View exposing (eCharts)
import Translations exposing (Lang)


view lang graph =
    Html.Lazy.lazy2 chart lang graph


chart : Lang -> Graph -> Html msg
chart lang graph =
    JE.object
        [ ( "tooltip", JE.object [] )
        , legend
        , ( "animation", JE.bool True )
        , ( "animationDurationUpdate", JE.int 1500 )
        , ( "animationEasingUpdate", JE.string "quintcInOut" )
        , ( "series"
          , [ ( "type", JE.string "graph" )
            , ( "layout", JE.string "force" )
            , ( "animation", JE.bool True )
            , categories
            , ( "label", JE.object [ ( "show", JE.bool True ) ] )
            , ( "symbolSize", JE.float 20 )
            , ( "roam", JE.bool True )
            , ( "force"
              , JE.object
                    [ ( "repulsion", JE.int 250 )
                    , ( "edgeLength", JE.int 100 )
                    , ( "gravity", JE.float 0.1 )
                    ]
              )
            , ( "draggable", JE.bool True )
            , ( "data"
              , graph.node
                    |> Dict.toList
                    |> List.map
                        (\( id, node ) ->
                            [ ( "id", JE.string id )
                            , ( "name"
                              , getName node
                                    |> JE.string
                              )
                            , categoryID node
                            , tooltip node
                            , ( "symbolSize", JE.int (getValue node) )

                            --, ( "fixed", JE.bool True )
                            --, ( "x", JE.int 100 )
                            --, ( "y", JE.int 100 )
                            ]
                        )
                    |> JE.list JE.object
              )
            , ( "edges"
              , graph.edge
                    |> List.map
                        (\edge ->
                            [ ( "source", JE.string edge.from )
                            , ( "target", JE.string edge.to )
                            , ( "symbolSize", JE.list JE.int [ 5 ] )
                            ]
                        )
                    |> JE.list JE.object
              )
            , ( "emphasis", JE.object [ ( "focus", JE.string "adjacency" ), ( "scale", JE.bool True ) ] )
            ]
                |> JE.object
          )
        ]
        |> eCharts lang [] True Nothing


tooltip node =
    ( "tooltip"
    , JE.object
        [ ( "formatter"
          , JE.string <|
                case node of
                    Hashtag name ->
                        name

                    Link name url ->
                        name ++ ":<br/><a href='" ++ url ++ "'>" ++ url ++ "</a>"

                    Section id _ name ->
                        name

                    _ ->
                        "basdfasf<br/>asdfasfdafd"
          )
        ]
    )


categoryList =
    [ "course"
    , "hashtag"
    , "link"
    , "section"
    ]


categories : ( String, JE.Value )
categories =
    ( "categories"
    , categoryList
        |> List.map category
        |> JE.list identity
    )


category name =
    JE.object
        [ ( "name", JE.string name )
        , ( "base", JE.string name )
        ]


categoryID : Node -> ( String, JE.Value )
categoryID node =
    ( "category"
    , JE.int <|
        case node of
            Course _ _ ->
                0

            Hashtag _ ->
                1

            Link _ _ ->
                2

            Section _ _ _ ->
                3
    )


legend =
    ( "legend", JE.object [ ( "data", categoryList |> JE.list JE.string ) ] )


getName : Node -> String
getName node =
    case node of
        Course title _ ->
            title

        Hashtag name ->
            name

        Link name _ ->
            name

        Section _ _ name ->
            name


getValue : Node -> Int
getValue node =
    case node of
        Course _ _ ->
            50

        Hashtag _ ->
            10

        Link _ _ ->
            10

        Section _ wheight _ ->
            (6 - wheight) * 6
