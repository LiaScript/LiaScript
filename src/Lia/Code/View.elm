module Lia.Code.View exposing (view)

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onDoubleClick, onInput)
import Lia.Code.Model exposing (Model)
import Lia.Code.Types exposing (Code(..))
import Lia.Code.Update exposing (Msg(..))
import Lia.Utils


view : Model -> Code -> Html Msg
view model code =
    case code of
        Highlight lang block ->
            highlight lang block -1

        EvalJS idx ->
            case Array.get idx model of
                Just ( code, rslt, b ) ->
                    Html.div []
                        [ if b then
                            Html.textarea [ onInput <| Update idx, Attr.value code ] []
                          else
                            highlight "js" code idx
                        , Html.button [ onClick (Eval idx) ]
                            [ Html.text "run" ]
                        , case rslt of
                            Nothing ->
                                Html.text ""

                            Just (Ok rslt) ->
                                Html.text rslt

                            Just (Err rslt) ->
                                Html.text rslt
                        ]

                Nothing ->
                    Html.text ""


highlight : String -> String -> Int -> Html Msg
highlight lang code idx =
    Html.pre
        (if idx > -1 then
            [ onDoubleClick (FlipMode idx) ]
         else
            []
        )
        [ Html.code []
            [ Lia.Utils.highlight lang code ]
        ]
