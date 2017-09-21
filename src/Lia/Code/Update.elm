module Lia.Code.Update exposing (Msg(..), update)

import Array
import Lia.Code.Model exposing (Model)
import Lia.Utils


type Msg
    = Eval Int
    | Update Int String
    | FlipMode Int


update : Msg -> Model -> Model
update msg model =
    case msg of
        Eval idx ->
            case Array.get idx model of
                Just ( code_str, _, _ ) ->
                    Array.set idx ( code_str, Just <| Lia.Utils.evaluateJS code_str, False ) model

                Nothing ->
                    model

        Update idx code_str ->
            case Array.get idx model of
                Just ( _, rslt, b ) ->
                    Array.set idx ( code_str, rslt, b ) model

                Nothing ->
                    model

        FlipMode idx ->
            case Array.get idx model of
                Just ( code_str, rslt, b ) ->
                    Array.set idx ( code_str, rslt, not b ) model

                Nothing ->
                    model
