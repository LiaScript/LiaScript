module Session exposing (Screen, Session)

import Browser.Navigation as Navigation
import Url exposing (Url)


type alias Session =
    { key : Navigation.Key
    , screen : Screen
    , url : Url
    }


type alias Screen =
    { width : Int
    , height : Int
    }
