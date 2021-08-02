module Lia.Graph.View exposing (..)

import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Html.Lazy
import Json.Decode as JD
import Json.Encode as JE
import Lia.Graph.Model exposing (Graph, Node(..))
import Lia.Graph.Update exposing (Msg(..))
import Lia.Markdown.Chart.View exposing (eCharts)
import Translations exposing (Lang)


view lang graph =
    Html.Lazy.lazy2 chart lang graph


chart : Lang -> Graph -> Html Msg
chart lang graph =
    JE.object
        [ ( "tooltip", JE.object [] )
        , legend
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
                    [ ( "repulsion", JE.int 2500 )
                    , ( "edgeLength", JE.int 120 )
                    , ( "gravity", JE.float 0.2 )
                    ]
              )
            , ( "draggable", JE.bool True )
            , ( "data"
              , graph.node
                    |> Dict.toList
                    |> List.sortBy Tuple.first
                    |> List.map
                        (\( id, node ) ->
                            [ ( "id", JE.string id )
                            , ( "name"
                              , getName node
                                    |> JE.string
                              )
                            , categoryID node
                            , tooltip node
                            , ( "symbolSize", JE.float <| getValue node )
                            , ( "itemStyle"
                              , JE.object <|
                                    if isRoot graph node then
                                        [ ( "borderColor", JE.string "#000" )
                                        , ( "borderWidth", JE.int 3 )
                                        ]

                                    else if isVisible node then
                                        []

                                    else
                                        [ ( "opacity", JE.float 0.1 )
                                        ]
                              )

                            --, ( "fixed", JE.bool True )
                            --, ( "x", JE.int 100 )
                            --, ( "y", JE.int 100 )
                            ]
                        )
                    |> JE.list JE.object
              )
            , ( "edges"
              , graph.edge
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

            --, ( "emphasis", JE.object [ ( "focus", JE.string "adjacency" ), ( "scale", JE.bool True ) ] )
            ]
                |> JE.object
          )
        ]
        |> eCharts lang
            [ Attr.style "width" "100%"
            , Attr.style "height" "calc(100% - 7.8rem)"

            --, Attr.style "position" "absolute"
            , Attr.style "margin-top" "7.8rem"
            , onClick Clicked
            ]
            []
            True
            Nothing


tooltip node =
    ( "tooltip"
    , JE.object
        [ ( "formatter"
          , JE.string <|
                case node of
                    Hashtag tag ->
                        tag.name

                    Link { name, url } ->
                        name ++ ":<br/><a href='" ++ url ++ "'>" ++ url ++ "</a>"

                    Section sec ->
                        sec.name

                    _ ->
                        "basdfasf<br/>asdfasfdafd"
          )
        ]
    )


isVisible : Node -> Bool
isVisible node =
    case node of
        Section sec ->
            sec.visible

        _ ->
            True


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
            Course _ ->
                0

            Hashtag _ ->
                1

            Link _ ->
                2

            Section _ ->
                3
    )


legend =
    ( "legend", JE.object [ ( "data", categoryList |> JE.list JE.string ) ] )


getName : Node -> String
getName node =
    case node of
        Section sec ->
            sec.name

        Course lia ->
            lia.name

        Hashtag tag ->
            tag.name

        Link link ->
            link.name


getValue : Node -> Float
getValue node =
    case node of
        Course _ ->
            50

        Hashtag _ ->
            10

        Link _ ->
            10

        Section sec ->
            toFloat sec.weight / 60


onClick : (JE.Value -> msg) -> Html.Attribute msg
onClick msg =
    JD.value
        |> JD.at [ "target", "onClick" ]
        |> JD.map msg
        |> Html.Events.on "onClick"


equal : Node -> Node -> Bool
equal node1 node2 =
    case ( node1, node2 ) of
        ( Section sec1, Section sec2 ) ->
            sec1.id == sec2.id

        ( Hashtag str1, Hashtag str2 ) ->
            str1 == str2

        ( Link link1, Link link2 ) ->
            link1.url == link2.url

        ( Course lia1, Course lia2 ) ->
            lia1.url == lia2.url

        _ ->
            False


isRoot : Graph -> Node -> Bool
isRoot graph node =
    case ( graph.root, node ) of
        ( Just (Section sec1), Section sec2 ) ->
            sec1.id == sec2.id

        _ ->
            False
