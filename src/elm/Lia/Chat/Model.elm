module Lia.Chat.Model exposing
    ( Model
    , init
    )

import Lia.Section as Section


type alias Model =
    { input : String
    , messages : List Section.SubSection
    }


init : Model
init =
    { input = ""
    , messages = []
    }
