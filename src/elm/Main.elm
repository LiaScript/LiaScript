module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Dict
import Index.Model as Index
import Json.Encode as JE
import Lia.Parser.PatReplace exposing (link)
import Lia.Script
import Model exposing (Model, State(..))
import Session exposing (Screen, Session)
import Update
    exposing
        ( Msg(..)
        , getIndex
        , load_readme
        , subscriptions
        , update
        )
import Url
import View exposing (view)


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


{-| Basic init information, that are passed to the init function at start-time:

  - `course`: define a fixed course-url that needs to be downloaded

  - `script`: pass the entire content of a Markdown document

  - `settings`: passes general rendering settings (style, mode, etc.)
    see `Lia/Settings/Model.elm` for more information

  - `screen`: initial screen-size passed from JavaScript, later it is updated by
    subscribing to `Browser.Events.onResize` in the main Update function

  - `share`: defines if the `navigation.share` API is present

  - `hasIndex`: does the "backend" provides an interface to store and thus to
    restore courses from an index? If this is the case, the home-button will be
    visible and an Index will be visualized.

-}
type alias Flags =
    { course : Maybe String
    , script : Maybe String
    , settings : JE.Value
    , screen : Screen
    , share : Bool
    , hasIndex : Bool
    }


{-| Course content can be passed in three ways:

1.  If the URL contains a parameter `.../?https://.../README.md`, then this
    parameter is used as a resource to load and parse course content.

2.  If a course url has been passed via the Flags, this one defines the course
    content.

3.  The course content can also be directly passed as a string, using the
    `Flag.script` attribute.

4.  If none of these values is passed, the app will be in idle state, which
    means it will depict an index of all previously loaded documents.

-}
init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        slide =
            url.fragment |> Maybe.andThen String.toInt

        model u s m =
            Model 4
                0
                flags.hasIndex
                Nothing
                Index.init
                Nothing
                (Session flags.share key flags.screen u)
                s
                m
                m
                Dict.empty

        courseUrl =
            { url | query = Maybe.map link url.query }

        openTableOfContents =
            flags.screen.width > 620
    in
    case ( courseUrl.query, flags.course, flags.script ) of
        ( Just query, _, _ ) ->
            Lia.Script.init
                openTableOfContents
                flags.settings
                (get_base courseUrl)
                query
                (get_origin courseUrl.query)
                slide
                |> model courseUrl Loading
                |> getIndex query

        ( _, Just query, _ ) ->
            Lia.Script.init
                openTableOfContents
                flags.settings
                (get_base courseUrl)
                query
                (get_origin courseUrl.query)
                slide
                |> model { courseUrl | query = Just query } Loading
                |> getIndex query

        ( _, _, Just script ) ->
            Lia.Script.init
                openTableOfContents
                flags.settings
                ""
                ""
                ""
                slide
                |> model courseUrl Idle
                |> load_readme script

        _ ->
            Lia.Script.init
                openTableOfContents
                flags.settings
                ""
                ""
                ""
                slide
                |> model courseUrl Idle
                |> Update.initIndex


{-| Cut of the file from an URL-string and return only the base:

    get_origin (Just "http://xy.com/path/file.me") == "http://xy.com/path/"

    get_origin Nothing == ""

-}
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
