port module Update exposing
    ( Msg(..)
    , getIndex
    , initIndex
    , load_readme
    , subscriptions
    , update
    )

-- UPDATE

import Array
import Base64
import Browser
import Browser.Events
import Browser.Navigation as Navigation
import Conditional.List as CList
import Const
import Dict
import Error.Message
import Error.Report
import Http
import Index.Update as Index
import Index.Version
import Json.Decode as JD
import Lia.Definition.Types as Definition
import Lia.Json.Decode
import Lia.Markdown.Code.Log exposing (Level(..))
import Lia.Script
import Library.IPFS as IPFS
import Model exposing (Model, State(..))
import Process
import Return exposing (Return)
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Zip
import Session exposing (Screen)
import Task
import Translations
import Url


{-| **@private:** For most cases there will be only one outgoing port to
JavaScript. All events make use of the basic Event-structure:

    { topic = String, section = Int, message = JE.Value }

A message can also be of type `Event` or of something else. The JavaScript part
will handle these events according to the topic value...

-}
port event2js : Event -> Cmd msg


{-| **@private:** Incoming events are mostly of type `Event`. `Event.topic` and
`Event.section` are used to provide the correct path through the internal
LiaScript implementation and thus modules and sub-modules. In most cases it is
actually a nesting of messages like within the IP-stack
-}
port event2elm : (Event -> msg) -> Sub msg


port jit : (String -> msg) -> Sub msg


port compile : (String -> msg) -> Sub msg


{-| Base message structure for Lia

  - `LiaScript`: if a course has been successfully parsed, all communication is
    handled via this nested message
  - `Handle`: external events received via port `event2elm` are handled by this
    option, the Event.topic defines the next route of the message
  - `UpdateIndex`: if the backend offers an Index, all communication to the
    course overview is handled here
  - `Resize`: handle screen resizing
  - `LiaParse`: parse the document in chunks, so that the view can be updated.
    This message is called repetitive until the app/parsing process reaches
    `State` `Parsing False 0`.
  - `LinkClicked`
  - `UrlChanged`
  - `Load_ReadMe_Result`: message for handling the course download, it also
    starts the parsing process
  - `Load_Template_Result`: similar to `Load_ReadMe_Result`, but it downloads
    all referenced templates and parses only the main header of these documents,
    content gets ignored

-}
type Msg
    = LiaScript Lia.Script.Msg
    | Handle Event
    | UpdateIndex Index.Msg
    | Resize Screen
    | LiaParse
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Load_ReadMe_Result String (Result Http.Error String)
    | Load_Template_Result String (Result Http.Error String)
    | Port_JIT String
    | Port_Compile String


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ jit Port_JIT
        , compile Port_Compile
        , event2elm Handle
        , Sub.map LiaScript (Lia.Script.subscriptions model.lia)
        , Sub.map Resize (Browser.Events.onResize Screen)
        ]


{-| **@private:** This is only used internally during parsing (`Msg.LiaParse`).
This way the process does not block the app entirely, but instead it is cut into
pieces so that the view can update a progress-bar.
-}
message : msg -> Cmd msg
message msg =
    Process.sleep 0
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


{-| **@private:** Combine commands and events to one command output.
-}
batch : (a -> msg) -> Return model a sub -> Cmd msg
batch map ret =
    ret.events
        |> List.map event2js
        |> (::) (Cmd.map map ret.command)
        |> Cmd.batch


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Port_JIT code ->
            load_readme
                (code ++ "\n")
                { model
                    | parse_steps = 1
                    , lia = model.lia |> Lia.Script.backup
                    , lia_ = model.lia
                }

        Port_Compile code ->
            let
                lia =
                    model.lia
            in
            load_readme
                (code ++ "\n")
                { model
                    | parse_steps = 4
                    , lia =
                        { lia
                            | backup = Dict.empty
                            , sections = Array.empty
                        }
                    , lia_ = model.lia
                }

        LiaScript childMsg ->
            let
                return =
                    Lia.Script.update model.session childMsg model.lia
            in
            ( { model | lia = return.value }
            , batch LiaScript return
            )

        Handle event ->
            case Event.destructure event of
                ( Just "index", _, _ ) ->
                    update
                        (event
                            |> Event.pop
                            |> Tuple.second
                            |> Index.handle
                            |> UpdateIndex
                        )
                        model

                ( Nothing, _, ( "index_get", param ) ) ->
                    case Index.decodeGet param of
                        Ok ( url, course ) ->
                            ( { model | preload = course }
                            , download False url
                            )

                        Err _ ->
                            ( { model | preload = Nothing }
                            , download False model.lia.readme
                            )

                ( Nothing, _, ( "index_restore", param ) ) ->
                    case Lia.Json.Decode.decode model.lia.seed model.lia.pane model.lia.sync param of
                        Ok lia ->
                            start
                                { model
                                    | lia =
                                        Lia.Script.add_todos lia.definition
                                            { lia | settings = model.lia.settings }
                                }

                        Err _ ->
                            ( { model | preload = Nothing }
                            , download False model.lia.readme
                            )

                ( Nothing, _, ( "lang", param ) ) ->
                    case JD.decodeValue JD.string param of
                        Ok str ->
                            let
                                lia =
                                    model.lia
                            in
                            ( { model
                                | lia =
                                    { lia
                                        | translation =
                                            str
                                                |> Translations.getLnFromCode
                                                |> Maybe.withDefault lia.translation
                                        , langCode = str
                                    }
                              }
                            , Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

                ( Nothing, _, ( "unzip", param ) ) ->
                    update
                        (case Service.Zip.decode param of
                            ( False, id, result ) ->
                                Load_ReadMe_Result id result

                            ( True, id, result ) ->
                                Load_Template_Result id result
                        )
                        model

                _ ->
                    update
                        (event
                            |> Lia.Script.handle
                            |> LiaScript
                        )
                        model

        UpdateIndex childMsg ->
            let
                ( settings, ( index, cmd, events ) ) =
                    Index.update childMsg model.lia.settings model.index

                lia =
                    model.lia
            in
            ( { model | index = index, lia = { lia | settings = settings } }
            , Return.val 0
                |> Return.cmd cmd
                |> Return.batchEvents events
                |> batch UpdateIndex
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , case ( url.query, model.session.url.query ) of
                        ( Just newCourseURL, Just oldCourseURL ) ->
                            if newCourseURL /= oldCourseURL || url.fragment /= Just "" then
                                url
                                    |> Url.toString
                                    |> Navigation.load

                            else
                                Cmd.none

                        ( Nothing, Just oldCourseURL ) ->
                            { url | query = Just oldCourseURL }
                                |> Url.toString
                                |> Navigation.load

                        _ ->
                            url
                                |> Url.toString
                                |> Navigation.load
                    )

                Browser.External href ->
                    ( model, Navigation.load href )

        UrlChanged url ->
            if url /= model.session.url then
                case Session.getType url of
                    Session.Course _ fragment ->
                        let
                            slide =
                                fragment
                                    |> Maybe.andThen (Lia.Script.getSectionNumberFrom model.lia.search_index)
                                    |> Maybe.withDefault 0

                            session =
                                model.session
                                    |> Session.setUrl url
                                    |> Session.setFragment (slide + 1)

                            return =
                                Lia.Script.load_slide session True slide model.lia

                            lia =
                                return.value
                        in
                        ( { model
                            | lia = { lia | url = Url.toString { url | fragment = Nothing } }
                            , session = session
                          }
                        , batch LiaScript return
                        )

                    Session.Class room fragment ->
                        let
                            slide =
                                fragment
                                    |> Maybe.andThen (Lia.Script.getSectionNumberFrom model.lia.search_index)
                                    |> Maybe.withDefault 0

                            session =
                                model.session
                                    |> Session.setClass room
                                    |> Session.setFragment (slide + 1)

                            return =
                                Lia.Script.load_slide session True slide model.lia

                            lia =
                                return.value
                        in
                        ( { model
                            | lia = { lia | url = Url.toString { url | fragment = Nothing } }
                            , session = session
                          }
                        , batch LiaScript return
                        )

                    Session.Index ->
                        initIndex
                            { model
                                | state = Idle
                                , session = Session.setUrl url model.session
                            }

            else
                ( model, Cmd.none )

        Resize screen ->
            ( { model | session = Session.setScreen screen model.session }
            , Cmd.none
            )

        LiaParse ->
            parsing model

        Load_ReadMe_Result _ (Ok readme) ->
            load_readme readme model

        Load_ReadMe_Result url (Err info) ->
            if String.startsWith Const.urlProxy url then
                startWithError
                    { model
                        | state =
                            Error.Message.loadingCourse url info
                                |> Error.Report.add model.state
                    }

            else if isOffline info && model.preload /= Nothing then
                ( model
                , { version =
                        model.preload
                            |> Maybe.andThen .active
                            |> Maybe.withDefault
                                (model.preload
                                    |> Maybe.andThen
                                        (.versions
                                            >> Dict.keys
                                            >> Index.Version.max
                                        )
                                    |> Maybe.withDefault "0"
                                )
                  , url = url
                  }
                    |> Service.Database.index_restore
                    |> event2js
                )

            else if IPFS.isIPFS url then
                ( model
                , case Session.getType model.session.url of
                    Session.Class room _ ->
                        Session.setClass
                            { room | course = IPFS.toHTTPS (Const.urlProxy ++ url) url }
                            model.session
                            |> .url
                            |> Session.load

                    _ ->
                        Session.setQuery
                            (IPFS.toHTTPS (Const.urlProxy ++ url) url)
                            model.session
                            |> .url
                            |> Session.load
                )

            else
                ( model
                , Session.setQuery (IPFS.toHTTPS (Const.urlProxy ++ url) url) model.session
                    |> .url
                    |> Session.load
                )

        Load_Template_Result url (Ok template) ->
            parsing
                { model
                    | lia =
                        template
                            |> removeCR
                            |> Lia.Script.add_imports { model = model.lia, base = url }
                    , state =
                        case model.state of
                            Parsing b templates ->
                                Parsing b (templates - 1)

                            _ ->
                                model.state
                    , templates = Dict.insert url template model.templates
                }

        Load_Template_Result url (Err info) ->
            if String.startsWith Const.urlProxy url then
                startWithError
                    { model
                        | state =
                            Error.Message.loadingResource url info
                                |> Error.Report.add model.state
                    }

            else
                ( model, download True (IPFS.toHTTPS (Const.urlProxy ++ url) url) )


isOffline : Http.Error -> Bool
isOffline error =
    case error of
        Http.NetworkError ->
            True

        Http.Timeout ->
            True

        _ ->
            False


{-| **@private:** Parsing has been finished, initialize lia, update the url and
switch to the LiaScript state `RUNNING`.
-}
start : Model -> ( Model, Cmd Msg )
start model =
    let
        session =
            model.session
                |> Session.setQuery model.lia.readme

        slide =
            session.url.fragment
                |> Maybe.andThen String.toInt
                |> Maybe.map ((+) -1)
                |> Maybe.withDefault lia.section_active

        lia =
            model.lia

        return =
            Lia.Script.load_first_slide session { lia | section_active = slide }
    in
    ( { model
        | state = Running
        , lia = return.value
        , session = session
      }
    , Cmd.batch
        [ batch LiaScript return
        , if session.url.fragment == Nothing then
            Session.navToSlide session slide

          else
            Cmd.none
        ]
    )


startWithError : Model -> ( Model, Cmd Msg )
startWithError model =
    let
        session =
            model.session
                |> Session.setQuery model.lia.readme

        lia =
            model.lia

        return =
            Lia.Script.load_first_slide session
                { lia
                    | section_active = 0
                    , sections = Error.Report.generate model.state
                    , definition = Definition.setPersistent False lia.definition
                }
    in
    ( { model | lia = return.value, session = session }
    , batch LiaScript return
    )


{-| **@private:** General parsing procedure, thus the course is still parsed.
-}
parsing : Model -> ( Model, Cmd Msg )
parsing model =
    case model.state of
        -- parsing done
        Parsing False 0 ->
            start model

        -- still parsing
        Parsing True templates_to_load ->
            case model.code of
                -- stop parsing, but there might still be some templates to load
                Nothing ->
                    parsing { model | state = Parsing False templates_to_load }

                -- go on with parsing
                Just code ->
                    let
                        ( lia, remaining_code ) =
                            Lia.Script.parse_section model.lia code

                        new_model =
                            { model | lia = lia, code = remaining_code }
                    in
                    if modBy model.parse_steps (Lia.Script.pages lia) == 1 then
                        ( new_model, message LiaParse )

                    else
                        parsing new_model

        _ ->
            ( model, Cmd.none )


{-| This function is called if the README was downloaded successfully. If there
is a version that has been parsed earlier, and stored in `model.preload`, the
versions of both are compared.

  - major 0 versions will be interpreted immediately
  - if cached and downloaded versions are equal, the cached gets loaded
  - otherwise the newly downloaded is interpreted

-}
load_readme : String -> Model -> ( Model, Cmd Msg )
load_readme readme model =
    readme
        |> removeCR
        |> Lia.Script.init_script model.lia
        |> load model


{-| Start parsing and download external imports (templates).
-}
load : Model -> { model : Lia.Script.Model, code : Maybe ( String, Int ), templates : List String, event : Maybe Event } -> ( Model, Cmd Msg )
load model initial =
    case initial.code of
        Just code_ ->
            ( { model
                | lia = initial.model
                , state =
                    initial.templates
                        |> List.length
                        |> Parsing True
                , code = initial.code
                , size = code_ |> Tuple.first >> String.length >> toFloat
              }
            , initial.templates
                |> List.map (download True)
                |> (::) (message LiaParse)
                |> CList.addWhen
                    (initial.event
                        |> Maybe.map event2js
                    )
                |> Cmd.batch
            )

        Nothing ->
            startWithError
                { model
                    | state =
                        initial.model.error
                            |> Maybe.withDefault ""
                            |> Error.Report.add model.state
                }


{-| **@private:** purge the "Windows" carriage return.

> Since all following grammars in parsing use only `\n` as newline instead of
> `\r\n`, this char needs to be purged entirely.

-}
removeCR : String -> String
removeCR =
    String.replace "\u{000D}" ""


{-| **@private:** Used by multiple times to connect a download with a message.
-}
download : Bool -> String -> Cmd Msg
download template url =
    if String.startsWith "data:text" url then
        loadFromData template url

    else
        Http.get
            { url = url
            , expect =
                Http.expectString
                    (if template then
                        Load_Template_Result url

                     else
                        Load_ReadMe_Result url
                    )
            }


toCmd msg result =
    Task.perform
        (result |> msg |> always)
        (Task.succeed ())


loadFromData : Bool -> String -> Cmd Msg
loadFromData template url =
    let
        msg =
            if template then
                Load_Template_Result url

            else
                Load_ReadMe_Result url
    in
    case String.split "," url of
        [ protocol, data ] ->
            if String.endsWith "gzip;base64" protocol then
                { template = template
                , id = url
                , data = data
                }
                    |> Service.Zip.decompress
                    |> event2js

            else
                toCmd msg <|
                    if String.endsWith "base64" protocol then
                        case Base64.decode data of
                            Err info ->
                                Err (Http.BadBody info)

                            Ok string ->
                                Ok string

                    else
                        case Url.percentDecode data of
                            Just string ->
                                Ok string

                            _ ->
                                Err (Http.BadBody "could not apply percent decode")

        _ ->
            toCmd msg <|
                Err (Http.BadBody "wrong data protocol")


getIndex : String -> Model -> ( Model, Cmd Msg )
getIndex url model =
    ( model, Service.Database.index_get url |> event2js )


initIndex : Model -> ( Model, Cmd Msg )
initIndex model =
    ( model
    , Service.Database.index_list
        |> Event.push "index"
        |> event2js
    )
