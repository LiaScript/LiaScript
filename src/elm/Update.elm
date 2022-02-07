port module Update exposing
    ( Msg(..)
    , getIndex
    , initIndex
    , load_readme
    , subscriptions
    , update
    )

-- UPDATE

import Browser
import Browser.Events
import Browser.Navigation as Navigation
import Const
import Dict
import Error.Message
import Error.Report
import Http
import Index.Update as Index
import Json.Decode as JD
import Json.Encode as JE
import Lia.Definition.Types as Definition
import Lia.Json.Decode
import Lia.Markdown.Code.Log exposing (Level(..))
import Lia.Script
import Model exposing (Model, State(..))
import Process
import Return exposing (Return)
import Service.Database
import Service.Event as Event exposing (Event)
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
    | JIT String


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ jit JIT
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
        JIT code ->
            load_readme
                (code ++ "\n")
                { model
                    | parse_steps = 1
                    , lia = model.lia |> Lia.Script.backup
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
                            , download Load_ReadMe_Result url
                            )

                        Err _ ->
                            ( { model | preload = Nothing }
                            , download Load_ReadMe_Result model.lia.readme
                            )

                ( Nothing, _, ( "index_restore", param ) ) ->
                    case Lia.Json.Decode.decode model.lia.sync param of
                        Ok lia ->
                            start
                                { model
                                    | lia =
                                        Lia.Script.add_todos lia.definition
                                            { lia | settings = model.lia.settings }
                                }

                        Err _ ->
                            ( { model | preload = Nothing }
                            , download Load_ReadMe_Result model.lia.readme
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
                    , if url.query /= model.session.url.query || url.fragment /= Just "" then
                        url
                            |> Url.toString
                            |> Navigation.load

                      else
                        Cmd.none
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
                        in
                        ( { model
                            | lia = return.value
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
                        in
                        ( { model
                            | lia = return.value
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
                    |> Tuple.mapSecond
                        (\cmd ->
                            Cmd.batch
                                [ { cmd = "offline_TODO"
                                  , param = JE.string url
                                  }
                                    |> Event.init "offline"
                                    |> event2js
                                , cmd
                                ]
                        )

            else
                ( model
                , Session.setQuery (Const.urlProxy ++ url) model.session
                    |> .url
                    |> Session.load
                )

        Load_Template_Result url (Ok template) ->
            parsing
                { model
                    | lia =
                        template
                            |> removeCR
                            |> Lia.Script.add_imports model.lia
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
                ( model, download Load_Template_Result (Const.urlProxy ++ url) )


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
    ( { model | state = Running, lia = return.value, session = session }
    , batch LiaScript return
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
    let
        ( lia, code, templates ) =
            readme
                |> removeCR
                |> Lia.Script.init_script model.lia
    in
    load model lia code templates


{-| Start parsing and download external imports (templates).
-}
load : Model -> Lia.Script.Model -> Maybe ( String, Int ) -> List String -> ( Model, Cmd Msg )
load model lia code templates =
    case code of
        Just code_ ->
            ( { model
                | lia = lia
                , state = Parsing True <| List.length templates
                , code = code
                , size = code_ |> Tuple.first >> String.length >> toFloat
              }
            , templates
                |> List.map (\t -> download Load_Template_Result t)
                |> (::) (message LiaParse)
                |> Cmd.batch
            )

        Nothing ->
            startWithError
                { model
                    | state =
                        lia.error
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
download : (String -> Result Http.Error String -> Msg) -> String -> Cmd Msg
download msg url =
    Http.get
        { url = url
        , expect = Http.expectString (msg url)
        }


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
