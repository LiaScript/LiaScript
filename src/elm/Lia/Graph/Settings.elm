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
    , showGlobalGraph : Bool
    }


type Msg
    = Indentation String
    | ShowDocumentStructure
    | ShowGlobalGraph


init =
    { highlightVisited = False
    , indentation = 3
    , showDocumentStructure = False
    , showGlobalGraph = False
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

        ShowDocumentStructure ->
            { settings | showDocumentStructure = not settings.showDocumentStructure }

        ShowGlobalGraph ->
            { settings | showGlobalGraph = not settings.showGlobalGraph }
