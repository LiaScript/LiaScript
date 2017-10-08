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

        Evaluate lang idx x ->
            case Array.get idx model of
                Just elem ->
                    Html.div [ Attr.class "lia-code-eval" ]
                        [ if elem.editing then
                            Html.textarea
                                [ Attr.style [ ( "width", "100%" ) ]
                                , Attr.class "lia-input"
                                , elem.code |> String.lines |> List.length |> Attr.rows
                                , onInput <| Update idx
                                , Attr.value elem.code
                                , onDoubleClick (FlipMode idx)
                                ]
                                []
                          else
                            highlight lang elem.code idx
                        , if elem.running then
                            Html.button [ Attr.class "lia-btn lia-icon" ]
                                [ Html.text "settings" ]
                          else
                            Html.button [ Attr.class "lia-btn", Attr.class "lia-icon", onClick (Eval idx x) ]
                                [ Html.text "play_circle_filled" ]
                        , case elem.result of
                            Ok rslt ->
                                Html.text rslt

                            Err rslt ->
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
