module Lia.Code.View exposing (view)

import Array
import Dict
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
            highlight lang block ""

        Evaluate lang idx x ->
            case Dict.get idx model of
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
                        , if Array.length elem.history > 1 then
                            Html.text (toString (Array.length elem.history))
                          else
                            Html.text ""
                        , case elem.result of
                            Ok rslt ->
                                Html.pre [] [ Lia.Utils.stringToHtml rslt ]

                            Err rslt ->
                                Html.pre [ Attr.style [ ( "color", "red" ) ] ] [ Html.text ("Error: " ++ rslt) ]
                        ]

                Nothing ->
                    Html.text ""


highlight : String -> String -> String -> Html Msg
highlight lang code idx =
    Html.pre
        (if idx == "" then
            [ Attr.class "lia-code" ]
         else
            [ Attr.class "lia-code", onDoubleClick (FlipMode idx) ]
        )
        [ Html.code [ Attr.class "lia-code-highlight" ]
            [ Lia.Utils.highlight lang code ]
        ]
