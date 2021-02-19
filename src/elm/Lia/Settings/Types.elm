module Lia.Settings.Types exposing
    ( Action(..)
    , Mode(..)
    , Settings
    , init
    )


type alias Settings =
    { table_of_contents : Bool
    , support_menu : Bool
    , mode : Mode
    , theme : String
    , light : Bool
    , editor : String
    , font_size : Int
    , sound : Bool
    , lang : String
    , action : Maybe Action
    , speaking : Bool
    , initialized : Bool
    , hasShareApi : Bool
    }


type Action
    = ShowInformation
    | ShowTranslations
    | ShowSettings
    | ShowModes
    | Share


type Mode
    = Slides -- Underline Comments and Effects
    | Presentation -- Only effects
    | Textbook -- Render Comments and Effects at ones


init : Bool -> Mode -> Settings
init hasShareApi mode =
    { table_of_contents = True
    , support_menu = True
    , mode = mode
    , theme = "default"
    , light = True
    , editor = "dreamweaver"
    , font_size = 100
    , sound = True
    , lang = "default"
    , action = Nothing
    , speaking = False
    , initialized = False
    , hasShareApi = hasShareApi
    }
