module Lia.Graph.Settings exposing
    ( Msg(..)
    , Settings
    , init
    , update
    )


type alias Settings =
    { highlightVisited : Bool
    , indentation : Int
    , showDocumentStructure : Bool
    }


type Msg
    = Indentation String
    | ShowDocumentStructure Bool


init =
    { highlightVisited = False
    , indentation = 3
    , showDocumentStructure = False
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

        ShowDocumentStructure bool ->
            { settings | showDocumentStructure = bool }
