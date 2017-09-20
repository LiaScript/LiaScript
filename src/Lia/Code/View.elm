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
                    Html.div [ Attr.class "lia-code-eval" ]
                        [ if b then
                            Html.textarea [ onInput <| Update idx, Attr.value code ] []
                          else
                            highlight "js" code idx
                        , Html.button [ Attr.class "lia-btn", onClick (Eval idx) ]
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
            [ Attr.class "lia-code", onDoubleClick (FlipMode idx) ]
         else
            [ Attr.class "lia-code" ]
        )
        [ Html.code [ Attr.class "lia-code-highlight" ]
            [ Lia.Utils.highlight lang code ]
        ]
