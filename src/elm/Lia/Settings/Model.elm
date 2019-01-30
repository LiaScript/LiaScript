module Lia.Settings.Model exposing (Buttons, Mode(..), Model, init, init_buttons)


type alias Model =
    { table_of_contents : Bool
    , mode : Mode
    , theme : String
    , light : Bool
    , editor : String
    , font_size : Int
    , sound : Bool
    , lang : String
    , buttons : Buttons
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


init : Mode -> Model
init mode =
    { table_of_contents = True
    , mode = mode
    , theme = "default"
    , light = True
    , editor = "dreamweaver"
    , font_size = 100
    , sound = True
    , lang = "default"
    , buttons = init_buttons
    }


init_buttons : Buttons
init_buttons =
    Buttons False False False False
