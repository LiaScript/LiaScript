module Lia.Index.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onInput)
import Lia.Index.Model exposing (Model)
import Lia.Index.Update exposing (Msg(..))
import Translations exposing (..)


view : Lang -> Model -> Html Msg
view lang model =
    Html.div [ Attr.class "lia-toolbar" ]
        [ Html.input
            [ Attr.type_ "input"
            , Attr.value model.search
            , Attr.class "lia-search lia-input"
            , Attr.placeholder (search lang)
            , onInput ScanIndex
            ]
            []
        ]
