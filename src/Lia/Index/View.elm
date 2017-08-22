module Lia.Index.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onInput)
import Lia.Index.Model exposing (Model)
import Lia.Index.Update exposing (Msg(..))


view : Model -> Html Msg
view model =
    Html.input
        [ Attr.type_ "input"
        , Attr.style [ ( "margin-bottom", "24px" ) ]
        , Attr.value model.search
        , onInput ScanIndex
        ]
        []
