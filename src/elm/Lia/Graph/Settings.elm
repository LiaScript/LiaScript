module Lia.Graph.Settings exposing
    ( Msg(..)
    , Settings
    , init
    , update
    )


type alias Settings =
    { highlightVisited : Bool
    , indentation : Int
    }


type Msg
    = Indentation String


init =
    { highlightVisited = False
    , indentation = 3
    }


update : Msg -> Settings -> Settings
update msg settings =
    case msg of
        Indentation i ->
            case String.toInt i of
                Just indentation ->
                    { settings | indentation = indentation }

                _ ->
                    settings
