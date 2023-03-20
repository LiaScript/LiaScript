module Lia.Chat.Model exposing
    ( Model
    , init
    )

import Array
import Lia.Section exposing (Sections)


type alias Model =
    { input : String
    , messages : Sections
    }


init : Model
init =
    { input = ""
    , messages = Array.empty
    }
