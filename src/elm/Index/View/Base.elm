module Index.View.Base exposing (..)

import Const
import Html exposing (Attribute)
import Html.Attributes as Attr
import Lia.Parser.PatReplace exposing (link)


href : String -> Attribute msg
href =
    link >> (++) "./?" >> Attr.href


view =
    Html.section [] <|
        [ Html.br [] []
        , Html.p
            [ Attr.class "lia-paragraph" ]
            [ Html.text "If you cannot see any courses in this list, try out one of the following links, to get more information about this project and to visit some examples and free interactive books."
            ]
        , Html.u
            []
            [ Html.li []
                [ Html.a
                    [ Attr.href Const.urlLiascript, Attr.target "_blank" ]
                    [ Html.text "Project-Website" ]
                ]
            , Html.li []
                [ Html.a
                    [ href "https://raw.githubusercontent.com/liaScript/docs/master/README.md", Attr.target "_blank" ]
                    [ Html.text "Project-Documentation" ]
                ]
            , Html.li []
                [ Html.a
                    [ href "https://raw.githubusercontent.com/liaScript/index/master/README.md", Attr.target "_blank" ]
                    [ Html.text "Index" ]
                ]
            ]
        , Html.br [] []
        , Html.p
            [ Attr.class "lia-paragraph" ]
            [ Html.text "At the end, we hope to learn from your courses." ]
        , Html.p
            [ Attr.class "lia-paragraph" ]
            [ Html.text "Have a nice one ;-) ..." ]
        ]
