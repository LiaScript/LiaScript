module Lia.Code.Update exposing (Msg(..), update)

import Array
import Lia.Code.Model exposing (Model)
import Lia.Utils


type Msg
    = Eval Int String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Eval idx code ->
            ( Array.set idx (Just <| Lia.Utils.evaluateJS code) model, Cmd.none )
