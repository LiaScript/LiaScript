module Index.Update exposing
    ( Msg(..)
    , decodeGet
    , get
    , handle
    , inCache
    , init
    , restore
    , update
    )

import Browser.Navigation as Nav
import Dict
import Index.Model exposing (Course, Model, Release)
import Index.Version as Version
import Json.Decode as JD
import Json.Encode as JE
import Lia.Definition.Json.Decode as Definition
import Lia.Markdown.Inline.Json.Decode as Inline
import Lia.Settings.Types exposing (Settings)
import Lia.Settings.Update as Settings
import Lia.Update exposing (Msg(..))
import Port.Event as Event exposing (Event)
import Port.Share exposing (share)


type Msg
    = IndexList (List Course)
    | IndexError String
    | Input String
    | Delete String
    | Reset String (Maybe String)
    | Restore String (Maybe String)
    | Share { title : String, text : String, url : String }
    | Handle JD.Value
    | Activate String (Maybe String)
    | NoOp
    | LoadCourse String
    | UpdateSettings Settings.Msg


index : Event -> Event
index =
    Event.encode
        >> Event "index" -1


init : Event
init =
    Event "list" -1 JE.null
        |> index


delete : String -> Event
delete =
    JE.string
        >> Event "delete" -1
        >> index


get : String -> Event
get =
    JE.string
        >> Event "get" -1
        >> index


restore : String -> String -> Event
restore version =
    JE.string
        >> Event "restore" (Version.getMajor version)
        >> index


reset : String -> Int -> Event
reset course version =
    course
        |> JE.string
        |> Event "reset" version
        |> index


decodeGet : JD.Value -> ( String, Maybe Course )
decodeGet event =
    case
        ( JD.decodeValue (JD.field "id" JD.string) event
        , JD.decodeValue (JD.field "course" decCourse) event
        )
    of
        ( Ok uri, Ok course ) ->
            ( uri, Just course )

        ( Ok uri, Err _ ) ->
            ( uri, Nothing )

        ( Err _, _ ) ->
            ( "", Nothing )


handle : JD.Value -> Msg
handle =
    Handle


update : Msg -> Settings -> Model -> ( Settings, ( Model, Cmd Msg, List Event ) )
update msg settings model =
    updateSettings msg settings <|
        case msg of
            IndexList list ->
                ( { model
                    | courses = list
                    , initialized = True
                  }
                , Cmd.none
                , []
                )

            IndexError _ ->
                ( model, Cmd.none, [] )

            Delete courseID ->
                ( { model
                    | courses =
                        model.courses
                            |> List.filter (.id >> (/=) courseID)
                  }
                , Cmd.none
                , [ delete courseID ]
                )

            Reset courseID version ->
                ( model
                , Cmd.none
                , [ reset courseID <|
                        Maybe.withDefault -1 <|
                            case version of
                                Just ver ->
                                    String.toInt ver

                                Nothing ->
                                    model.courses
                                        |> List.filter (.id >> (==) courseID)
                                        |> List.head
                                        |> Maybe.map
                                            (\c ->
                                                c.versions
                                                    |> Dict.keys
                                                    |> List.filterMap String.toInt
                                                    |> List.maximum
                                                    |> Maybe.withDefault -1
                                            )
                  ]
                )

            Handle json ->
                update (decode json) settings model
                    |> Tuple.second

            Input url ->
                ( { model | input = url }, Cmd.none, [] )

            Restore course version ->
                ( model
                , Cmd.none
                , [ restore (Maybe.withDefault "0.0.0" version) course ]
                )

            Activate course version ->
                ( { model
                    | courses =
                        model.courses
                            |> activate course version
                  }
                , Cmd.none
                , []
                )

            Share site ->
                ( model
                , Cmd.none
                , [ share site ]
                )

            LoadCourse url ->
                ( model, Nav.load url, [] )

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
              , Cmd.batch [ cmd, Cmd.map UpdateSettings return.cmd ]
              , List.append events return.events
              )
            )

        _ ->
            ( settings, ( model, cmd, events ) )


activate : String -> Maybe String -> List Course -> List Course
activate course version list =
    case list of
        [] ->
            []

        c :: cs ->
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
                    :: cs

            else
                c :: activate course version cs


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
        |> JD.field "list"
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


{-| Check if the current passed version string is allso available as accessible
from the local cache. Major verions of `0` are not stored permanently.
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
