module Index.Update exposing
    ( Msg(..)
    , decodeGet
    , handle
    , inCache
    , update
    )

import Browser.Navigation as Nav
import Dict
import I18n.Translations exposing (Lang(..))
import Index.Model exposing (Course, Modal, Model, Release)
import Index.Version as Version
import Json.Decode as JD
import Lia.Definition.Json.Decode as Definition
import Lia.Markdown.Inline.Json.Decode as Inline
import Lia.Settings.Types exposing (Settings)
import Lia.Settings.Update as Settings
import Lia.Update exposing (Msg(..))
import Library.Masonry as Masonry
import List.Extra
import Service.Console
import Service.Database
import Service.Event exposing (Event)
import Service.Share


type Msg
    = IndexList (List Course)
    | IndexError String
    | Input String
    | Delete String
    | Reset String (Maybe String)
    | Restore String (Maybe String)
    | Share { title : String, text : String, url : String, image : Maybe String }
    | Handle Event
    | Activate String (Maybe String)
    | NoOp
    | LoadCourse String
    | UpdateSettings Settings.Msg
    | Modal (Maybe Modal)
    | MasonryMsg Masonry.Msg


decodeGet : JD.Value -> Result JD.Error ( String, Maybe Course )
decodeGet event =
    case
        ( JD.decodeValue (JD.field "id" JD.string) event
        , JD.decodeValue decCourse event
        )
    of
        ( Ok uri, Ok course ) ->
            Ok ( uri, Just course )

        ( Ok uri, Err _ ) ->
            Ok ( uri, Nothing )

        ( Err info, _ ) ->
            Err info


handle : Event -> Msg
handle =
    Handle


update : Msg -> Settings -> Model -> ( Settings, ( Model, Cmd Msg, List Event ) )
update msg settings model =
    updateSettings msg settings <|
        case msg of
            IndexList list ->
                let
                    ( masonry, cmd ) =
                        Masonry.init (Just "card") list
                in
                ( { model
                    | courses = list
                    , initialized = True
                    , masonry = masonry
                  }
                , Cmd.map MasonryMsg cmd
                , []
                )

            IndexError _ ->
                ( model, Cmd.none, [] )

            Delete courseID ->
                let
                    courses =
                        model.courses
                            |> List.filter (.id >> (/=) courseID)

                    ( masonry, cmd ) =
                        Masonry.init (Just "card") courses
                in
                ( { model
                    | courses = courses
                    , masonry = masonry
                  }
                , Cmd.map MasonryMsg cmd
                , [ Service.Database.index_delete courseID ]
                )

            Reset courseID version ->
                ( model
                , Cmd.none
                , [ Service.Database.index_reset
                        { url = courseID
                        , version =
                            case version of
                                Just ver ->
                                    ver

                                Nothing ->
                                    model.courses
                                        |> List.Extra.find (.id >> (==) courseID)
                                        |> Maybe.map
                                            (\c ->
                                                c.versions
                                                    |> Dict.keys
                                                    |> List.filterMap String.toInt
                                                    |> List.maximum
                                                    |> Maybe.withDefault -1
                                                    |> String.fromInt
                                            )
                                        |> Maybe.withDefault "-1"
                        }
                  ]
                )

            Handle event ->
                case Service.Event.message event of
                    ( "index_list", param ) ->
                        model
                            |> update (decode param) settings
                            |> Tuple.second

                    ( "loading_error", param ) ->
                        ( { model
                            | error =
                                Just <|
                                    case JD.decodeValue JD.string param of
                                        Ok error ->
                                            error

                                        Err info ->
                                            JD.errorToString info
                          }
                        , Cmd.none
                        , []
                        )

                    ( unknown, _ ) ->
                        ( model
                        , Cmd.none
                        , [ Service.Console.warn <| "Index: unknown cmd => " ++ unknown ]
                        )

            Input url ->
                ( { model | input = url }, Cmd.none, [] )

            Restore course version ->
                ( model
                , Cmd.none
                , [ Service.Database.index_restore
                        { version = Maybe.withDefault "0.0.0" version
                        , url = course
                        }
                  ]
                )

            Activate course version ->
                ( { model
                    | courses =
                        model.courses
                            |> List.map (activate course version)
                    , masonry =
                        model.masonry
                            |> Masonry.map (activate course version)
                  }
                , Cmd.none
                , []
                )

            Share site ->
                ( model
                , Cmd.none
                , [ Service.Share.link site ]
                )

            LoadCourse url ->
                ( model, Nav.load url, [] )

            Modal modal ->
                ( { model
                    | modal = modal
                    , error =
                        case modal of
                            Just _ ->
                                model.error

                            _ ->
                                Nothing
                  }
                , Cmd.none
                , []
                )

            MasonryMsg masonryMsg ->
                ( { model | masonry = Masonry.update masonryMsg model.masonry }
                , Cmd.none
                , []
                )

            _ ->
                ( model, Cmd.none, [] )


updateSettings : Msg -> Settings -> ( Model, Cmd Msg, List Event ) -> ( Settings, ( Model, Cmd Msg, List Event ) )
updateSettings msg settings ( model, cmd, events ) =
    case msg of
        UpdateSettings subMsg ->
            let
                return =
                    Settings.update Nothing subMsg settings
            in
            ( return.value
            , ( model
              , Cmd.batch [ cmd, Cmd.map UpdateSettings return.command ]
              , List.append events return.events
              )
            )

        _ ->
            ( settings, ( model, cmd, events ) )


activate : String -> Maybe String -> Course -> Course
activate course version c =
    if c.id == course then
        { c
            | active =
                case version of
                    Just ver ->
                        c.versions
                            |> Dict.filter (\_ v -> v.definition.version == ver)
                            |> Dict.keys
                            |> List.head

                    _ ->
                        Nothing
        }

    else
        c


decode : JD.Value -> Msg
decode json =
    case JD.decodeValue decList json of
        Ok rslt ->
            rslt

        Err _ ->
            IndexError "decode"


decList : JD.Decoder Msg
decList =
    JD.list decCourse
        |> JD.map IndexList


decCourse : JD.Decoder Course
decCourse =
    JD.map4 Course
        (JD.field "id" JD.string)
        (JD.field "data" (JD.dict decRelease))
        (JD.succeed Nothing)
        (JD.field "updated_str" JD.string)


decRelease : JD.Decoder Release
decRelease =
    JD.map2 Release
        (JD.field "title" Inline.decode)
        Definition.decode


{-| Check if the current passed version string is also available as accessible
from the local cache. Major versions of `0` are not stored permanently.
-}
inCache : String -> Course -> Bool
inCache version course =
    (Version.getMajor version /= 0)
        && (course.versions
                |> Dict.values
                |> List.map (.definition >> .version)
                |> Version.max
                |> Maybe.map Version.toInt
                |> Maybe.withDefault -1
                |> (==) (Version.toInt version)
           )
