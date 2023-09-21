module Main exposing
    ( Flags
    , main
    )

import Browser
import Browser.Navigation as Nav
import Const
import Dict
import Index.Model as Index
import Json.Encode as JE
import Lia.Parser.PatReplace exposing (link)
import Lia.Script
import Lia.Sync.Types as Sync
import Lia.Utils as Utils
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

  - `courseUrl`: define a fixed course-url that needs to be downloaded

  - `script`: pass the entire content of a Markdown document

  - `settings`: passes general rendering settings (style, mode, etc.)
    see `Lia/Settings/Model.elm` for more information

  - `screen`: initial screen-size passed from JavaScript, later it is updated by
    subscribing to `Browser.Events.onResize` in the main Update function

  - `hasShareAPI`: defines if the `navigation.share` API is present

  - `hasIndex`: does the "backend" provides an interface to store and thus to
    restore courses from an index? If this is the case, the home-button will be
    visible and an Index will be visualized.

-}
type alias Flags =
    { courseUrl : Maybe String
    , script : Maybe String
    , settings : JE.Value
    , screen : Screen
    , hasShareAPI : Bool
    , hasIndex : Bool
    , seed : Int
    , sync :
        { support : List String
        , enabled : Bool
        }
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
        model u s m =
            Model 4
                0
                flags.hasIndex
                Nothing
                Index.init
                Nothing
                (Session flags.hasShareAPI key flags.screen u)
                s
                m
                m
                Dict.empty

        courseUrl =
            { url | query = Maybe.map link url.query }

        openTableOfContents =
            flags.screen.width > Const.globalBreakpoints.sm
    in
    case ( courseUrl.query, flags.courseUrl, flags.script ) of
        -- directly parse the script
        ( _, _, Just script ) ->
            let
                subURL =
                    { courseUrl | query = Just "README.md" }
            in
            Lia.Script.init
                flags.seed
                flags.hasShareAPI
                openTableOfContents
                flags.settings
                flags.sync
                (get_base subURL)
                "README.md"
                ""
                Nothing
                |> model subURL Idle
                |> load_readme script

        -- Check if a URL was passed as a parameter
        ( _, Just query, _ ) ->
            Lia.Script.init
                flags.seed
                flags.hasShareAPI
                openTableOfContents
                flags.settings
                flags.sync
                (query
                    |> Url.fromString
                    |> Maybe.withDefault { courseUrl | query = Just query }
                    |> get_base
                )
                query
                (query
                    |> Utils.urlBasePath
                    |> Maybe.withDefault ""
                )
                url.fragment
                |> model { courseUrl | query = Just query } Loading
                |> getIndex query

        -- Use the url query-parameter as the course-url
        ( Just query, _, _ ) ->
            case Session.getType courseUrl of
                Session.Index ->
                    Lia.Script.init
                        flags.seed
                        flags.hasShareAPI
                        openTableOfContents
                        flags.settings
                        flags.sync
                        ""
                        ""
                        ""
                        url.fragment
                        |> model courseUrl Idle
                        |> Update.initIndex

                Session.Course _ fragment ->
                    Lia.Script.init
                        flags.seed
                        flags.hasShareAPI
                        openTableOfContents
                        flags.settings
                        flags.sync
                        (get_base courseUrl)
                        query
                        (courseUrl.query
                            |> Maybe.andThen Utils.urlBasePath
                            |> Maybe.withDefault ""
                        )
                        fragment
                        |> model courseUrl Loading
                        |> getIndex query

                Session.Class room fragment ->
                    Lia.Script.init
                        flags.seed
                        flags.hasShareAPI
                        openTableOfContents
                        flags.settings
                        flags.sync
                        (get_base courseUrl)
                        room.course
                        (room.course
                            |> Utils.urlBasePath
                            |> Maybe.withDefault ""
                        )
                        fragment
                        |> model courseUrl Loading
                        |> openSync room
                        |> getIndex room.course

        _ ->
            Lia.Script.init
                flags.seed
                flags.hasShareAPI
                openTableOfContents
                flags.settings
                flags.sync
                ""
                ""
                ""
                url.fragment
                |> model courseUrl Idle
                |> Update.initIndex


get_base : Url.Url -> String
get_base url =
    Url.toString { url | fragment = Nothing }


openSync : Session.Room -> Model -> Model
openSync room model =
    let
        settings =
            model.lia.settings

        lia =
            model.lia
    in
    { model
        | lia =
            { lia
                | sync = Sync.initRoom room lia.sync
                , settings =
                    { settings
                        | sync =
                            case settings.sync of
                                Just _ ->
                                    Just True

                                _ ->
                                    Nothing
                    }
            }
    }
