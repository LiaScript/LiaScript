module Session exposing
    ( Screen
    , Session
    , Type(..)
    , getType
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


type Type
    = Index
    | Course String Int


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


getType : Url -> Type
getType url =
    case url.query of
        Just str ->
            url.fragment
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault 1
                |> Course str

        Nothing ->
            Index
