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


view : Lang -> Bool -> Model -> Html Msg
view lang lightMode model =
    Html.Lazy.lazy3 chart lang lightMode model


chart : Lang -> Bool -> Model -> Html Msg
chart lang lightMode model =
    eCharts lang
        [ Attr.style "width" "100%"
        , Attr.style "height" "calc(100% - 7.8rem)"

        --, Attr.style "position" "absolute"
        , Attr.style "margin-top" "7.8rem"
        , onClick Clicked
        ]
        []
        lightMode
        Nothing
        model.json


onClick : (JE.Value -> msg) -> Html.Attribute msg
onClick msg =
    JD.value
        |> JD.at [ "target", "onClick" ]
        |> JD.map msg
        |> Html.Events.on "onClick"
