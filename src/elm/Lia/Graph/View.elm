module Lia.Graph.View exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Html.Lazy
import Json.Decode as JD
import Json.Encode as JE
import Lia.Graph.Model exposing (Model)
import Lia.Graph.Update exposing (Msg(..))
import Lia.Markdown.Chart.View exposing (eCharts)
import Translations exposing (Lang)


view : Lang -> Model -> Html Msg
view lang model =
    Html.Lazy.lazy2 chart lang model


chart : Lang -> Model -> Html Msg
chart lang model =
    eCharts lang
        [ Attr.style "width" "100%"
        , Attr.style "height" "calc(100% - 7.8rem)"

        --, Attr.style "position" "absolute"
        , Attr.style "margin-top" "7.8rem"
        , onClick Clicked
        ]
        []
        True
        Nothing
        model.json


onClick : (JE.Value -> msg) -> Html.Attribute msg
onClick msg =
    JD.value
        |> JD.at [ "target", "onClick" ]
        |> JD.map msg
        |> Html.Events.on "onClick"
