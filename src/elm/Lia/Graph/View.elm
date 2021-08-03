module Lia.Graph.View exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Html.Lazy
import Json.Decode as JD
import Json.Encode as JE
import Lia.Graph.Model exposing (Model)
import Lia.Graph.Settings as Settings exposing (Settings)
import Lia.Graph.Update exposing (Msg(..))
import Lia.Markdown.Chart.View exposing (eCharts)
import Translations exposing (Lang)


view : Lang -> Bool -> Model -> Html Msg
view lang lightMode model =
    Html.div
        [ Attr.style "width" "100%"
        , Attr.style "height" "calc(100% - 7.8rem)"
        , Attr.style "margin-top" "7.8rem"
        ]
        [ Html.Lazy.lazy3 chart lang lightMode model
        , viewSettings model.settings
        ]


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
        |> Event.on "onClick"


viewSettings : Settings -> Html Msg
viewSettings settings =
    Html.div []
        [ Html.label []
            [ Html.text "Section: "
            , Html.input
                [ Attr.type_ "range"
                , Attr.min "1"
                , Attr.max "6"
                , Attr.value <| String.fromInt settings.indentation
                , Event.onInput (UpdateSettings << Settings.Indentation)
                ]
                []
            ]
        ]
