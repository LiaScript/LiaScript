module Lia.Settings.Types exposing
    ( Buttons
    , Mode(..)
    , Settings
    , init
    , initButtons
    )


type alias Settings =
    { table_of_contents : Bool
    , mode : Mode
    , theme : String
    , light : Bool
    , editor : String
    , font_size : Int
    , sound : Bool
    , lang : String
    , buttons : Buttons
    , speaking : Bool
    , initialized : Bool
    }


type alias Buttons =
    { settings : Bool
    , informations : Bool
    , translations : Bool
    , share : Bool
    }


type Mode
    = Slides -- Underline Comments and Effects
    | Presentation -- Only effects
    | Textbook -- Render Comments and Effects at ones


init : Mode -> Settings
init mode =
    { table_of_contents = True
    , mode = mode
    , theme = "default"
    , light = True
    , editor = "dreamweaver"
    , font_size = 100
    , sound = True
    , lang = "default"
    , buttons = initButtons
    , speaking = False
    , initialized = False
    }


initButtons : Buttons
initButtons =
    Buttons False False False False
