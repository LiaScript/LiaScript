module Lia.Update exposing (..)

import Lia.Model exposing (..)
import Lia.Type exposing (..)


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        Load int ->
            ( { model | slide = int }, Cmd.none )
