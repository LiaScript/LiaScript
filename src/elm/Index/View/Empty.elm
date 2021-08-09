module Index.View.Empty exposing (view)

import Const
import Html exposing (Html)
import Html.Attributes as Attr
import Index.View.Base as Base


view : Html msg
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
                    [ Attr.href Const.urlLiascript ]
                    [ Html.text "Project-Website" ]
                ]
            , Html.li []
                [ Html.a
                    [ Base.href "https://raw.githubusercontent.com/liaScript/docs/master/README.md" ]
                    [ Html.text "Project-Documentation" ]
                ]
            , Html.li []
                [ Html.a
                    [ Base.href "https://raw.githubusercontent.com/liaScript/index/master/README.md" ]
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
