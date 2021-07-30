module Lia.Sync.Update exposing (..)

import Lia.Sync.Types exposing (Sync)


type Msg
    = InputRoom String


update : Msg -> Sync -> Sync
update msg model =
    case msg of
        InputRoom name ->
            { model | room = name }
