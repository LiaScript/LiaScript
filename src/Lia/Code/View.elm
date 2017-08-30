module Lia.Code.View exposing (view)

import Html exposing (Html)
import Html.Events exposing (onClick)
import Lia.Code.Model exposing (Model, get_result)
import Lia.Code.Types exposing (..)
import Lia.Code.Update exposing (Msg(..))
import Lia.Utils


view : Model -> Code -> Html Msg
view model code =
    case code of
        Highlight lang block ->
            Html.pre [] [ Html.code [] [ Lia.Utils.highlight lang block ] ]

        EvalJS block idx ->
            Html.div []
                [ Html.pre [] [ Html.code [] [ Lia.Utils.highlight "js" block ] ]
                , Html.button [ onClick (Eval idx block) ] [ Html.text "run" ]
                , case get_result idx model of
                    Nothing ->
                        Html.text ""

                    Just (Ok rslt) ->
                        Html.text rslt

                    Just (Err rslt) ->
                        Html.text rslt
                ]
