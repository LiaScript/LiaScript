module Session exposing
    ( Screen
    , Session
    , navTo
    , navToSlide
    , setUrl
    )

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


navTo : Session -> Url -> Cmd msg
navTo session =
    Url.toString >> Navigation.pushUrl session.key


navToSlide : Session -> Int -> Cmd msg
navToSlide session id =
    let
        url =
            session.url
    in
    { url | fragment = Just <| String.fromInt id }
        |> navTo session
