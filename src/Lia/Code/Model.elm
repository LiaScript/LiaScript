module Lia.Code.Model exposing (Model)

import Array exposing (Array)
import Lia.Code.Types exposing (..)


type alias Model =
    Array (Maybe Codes)
