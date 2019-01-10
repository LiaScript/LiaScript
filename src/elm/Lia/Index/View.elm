module Lia.Index.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onInput)
import Lia.Index.Model exposing (Model)
import Lia.Index.Update exposing (Msg(..))
import Translations exposing (Lang, baseSearch)


view : Lang -> Model -> Html Msg
view lang model =
    Html.span [ Attr.class "lia-toolbar" ]
        -- [ Html.span [ Attr.class "lia-icon", Attr.style [ ( "float", "left" ), ( "font-size", "16px" ) ] ] [ Html.text "search" ]
        --, Html.span [ Attr.style [ ( "float", "right" ), ( "max-width", "100px" ), ( "position", "relative" ) ] ]
        [ Html.input
            [ Attr.type_ "input"
            , Attr.value model.search
            , Attr.class "lia-input"
            , Attr.placeholder (baseSearch lang)
            , Attr.style "max-width" "100%"
            , onInput ScanIndex
            ]
            []

        --  ]
        ]
