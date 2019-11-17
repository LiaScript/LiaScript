module Session exposing (Screen, Session, setUrl)

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


setUrl : Url -> Session -> Session
setUrl url session =
    { session | url = url }
