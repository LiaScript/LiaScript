module Main exposing
    ( init
    , main
    )

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Index.Model as Index
import Json.Encode as JE
import Lia.Script
import Lia.Types exposing (Screen)
import Model exposing (Model, State(..))
import Process
import Task
import Update exposing (Msg(..), download, load_readme, subscriptions, update)
import Url
import View exposing (view)



-- MAIN


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


type alias Flags =
    { course : Maybe String
    , script : Maybe String
    , spa : Bool
    , debug : Bool
    , settings : JE.Value
    , screen : Screen
    }


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        slide =
            url.fragment |> Maybe.andThen String.toInt

        model =
            Model key 0 Nothing Index.init
    in
    case ( url.query, flags.course, flags.script ) of
        ( Just query, _, _ ) ->
            ( Lia.Script.init
                flags.settings
                (get_base url)
                query
                (get_origin url.query)
                slide
                flags.screen
                |> model Loading url
            , download (Load_ReadMe_Result query) query
            )

        ( _, Just query, _ ) ->
            ( Lia.Script.init
                flags.settings
                (get_base url)
                query
                (get_origin url.query)
                slide
                flags.screen
                |> model Loading { url | query = Just query }
            , download (Load_ReadMe_Result query) query
            )

        ( _, _, Just script ) ->
            Lia.Script.init
                flags.settings
                ""
                ""
                ""
                slide
                flags.screen
                |> model Idle url
                |> load_readme script

        _ ->
            Lia.Script.init
                flags.settings
                ""
                ""
                ""
                slide
                flags.screen
                |> model Idle url
                |> Update.initIndex


get_origin : Maybe String -> String
get_origin query =
    case query of
        Just url ->
            (url
                |> String.split "/"
                |> List.reverse
                |> List.drop 1
                |> List.reverse
                |> String.join "/"
            )
                ++ "/"

        Nothing ->
            ""


get_base : Url.Url -> String
get_base url =
    Url.toString { url | fragment = Nothing }
