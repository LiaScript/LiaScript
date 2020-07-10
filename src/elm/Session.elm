module Session exposing
    ( Screen
    , Session
    , Type(..)
    , getType
    , load
    , navTo
    , navToHome
    , navToSlide
    , setQuery
    , setUrl
    )

import Browser.Navigation as Navigation
import Url exposing (Url)


type alias Session =
    { share : Bool
    , key : Navigation.Key
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


setQuery : String -> Session -> Session
setQuery query session =
    let
        url =
            session.url
    in
    { session | url = { url | query = Just query } }


navTo : Session -> Url -> Cmd msg
navTo session =
    Url.toString >> Navigation.pushUrl session.key


load : Url -> Cmd msg
load =
    Url.toString >> Navigation.load


navToHome : Session -> Cmd msg
navToHome session =
    let
        url =
            session.url
    in
    { url | query = Nothing, fragment = Nothing }
        |> navTo session


navToSlide : Session -> Int -> Cmd msg
navToSlide session id =
    let
        url =
            session.url
    in
    { url | fragment = Just <| String.fromInt (1 + id) }
        |> navTo session


getType : Url -> Type
getType url =
    case url.query of
        Just str ->
            url.fragment
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault 1
                |> (+) -1
                |> Course str

        Nothing ->
            Index
