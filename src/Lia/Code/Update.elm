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
                Just ( code, _, b ) ->
                    Array.set idx ( code, Just <| Lia.Utils.evaluateJS code, False ) model

                Nothing ->
                    model

        Update idx code ->
            case Array.get idx model of
                Just ( _, rslt, b ) ->
                    Array.set idx ( code, rslt, b ) model

                Nothing ->
                    model

        FlipMode idx ->
            case Array.get idx model of
                Just ( code, rslt, b ) ->
                    Array.set idx ( code, rslt, not b ) model

                Nothing ->
                    model
