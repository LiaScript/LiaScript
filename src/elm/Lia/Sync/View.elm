module Lia.Sync.View exposing (..)

import Html exposing (Html)
import Lia.Sync.Types exposing (Sync)
import Lia.Utils exposing (modal)


view : Sync -> Html msg
view state =
    Html.text ""
