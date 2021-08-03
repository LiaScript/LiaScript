module Lia.Graph.Settings exposing
    ( Settings
    , init
    )


type alias Settings =
    { highlightVisited : Bool
    , indentation : Int
    }


init =
    { highlightVisited = False
    , indentation = 3
    }
