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
import Dict
import Http
import Index.Update as Index
import Json.Encode as JE
import Lia.Json.Decode
import Lia.Script
import Model exposing (Model, State(..))
import Port.Event exposing (Event)
import Process
import Session exposing (Screen)
import Task
import Url
import Version


{-| **@private:** For most cases there will be only one outgoing port to
JavaScript. All events make use of the basic Event-structure:

    { topic = String, section = Int, message = JE.Value }

A message can also be of type `Event` or of something else. The JavaScript part
will handle these events accoring to the topic value...

-}
port event2js : Event -> Cmd msg


{-| **@private:** Incoming events are mostly of type `Event`. `Event.topic` and
`Event.section` are used to provide the correct path through the internal
LiaScript implementation and thus modules and submodules. In most cases it is
actually a nesting of messages like within the IP-stack
-}
port event2elm : (Event -> msg) -> Sub msg


{-| Base message structure for Lia

  - `LiaScript`: if a course has been successfully parsed, all communication is
    handled via this nested message
  - `Handle`: external events received via port `event2elm` are handled by this
    option, the Event.topic defines the next route of the message
  - `UpdateIndex`: if the backend offers an Index, all communication to the
    course overview is handled here
  - `Resize`: handle screen resizing
  - `LiaParse`: parse the document in chunks, so that the view can be updated.
    This message is called repetitive until the app/parsing process reches
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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ event2elm Handle
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


{-| **@private:** If a Markdown-file cannot be downloaded, for some reasons
(presumable due to some [CORS][cors] restrictions), this will be used as an
intermediate proxy. This means, there will be a second trial to download the
file, but not with the URL:

    "https://cors-anywhere.herokuapp.com/" ++ "https://.../README.md"

[cors]: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS

-}
proxy : String
proxy =
    "https://cors-anywhere.herokuapp.com/"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LiaScript childMsg ->
            let
                ( lia, cmd, events ) =
                    Lia.Script.update model.session childMsg model.lia
            in
            ( { model | lia = lia }
            , events
                |> List.map event2js
                |> (::) (Cmd.map LiaScript cmd)
                |> Cmd.batch
            )

        Handle event ->
            case event.topic of
                "index" ->
                    update
                        (event.message
                            |> Index.handle
                            |> UpdateIndex
                        )
                        model

                "getIndex" ->
                    let
                        ( id, course ) =
                            Index.decodeGet event.message
                    in
                    ( { model | preload = course }
                    , download Load_ReadMe_Result id
                    )

                "restore" ->
                    case Lia.Json.Decode.decode model.session.screen.width event.message of
                        Ok lia ->
                            start
                                { model
                                    | lia =
                                        Lia.Script.add_todos lia.definition
                                            { lia | settings = model.lia.settings }
                                }

                        Err info ->
                            ( { model | preload = Nothing }
                            , download Load_ReadMe_Result model.lia.readme
                            )

                _ ->
                    update
                        (event
                            |> Lia.Script.handle
                            |> LiaScript
                        )
                        model

        UpdateIndex childMsg ->
            let
                ( index, cmd, events ) =
                    Index.update childMsg model.index
            in
            ( { model | index = index }
            , events
                |> List.map event2js
                |> (::) (Cmd.map UpdateIndex cmd)
                |> Cmd.batch
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , if url.query == model.session.url.query then
                        Session.navTo model.session url

                      else
                        url
                            |> Url.toString
                            |> Navigation.load
                    )

                Browser.External href ->
                    ( model, Navigation.load href )

        UrlChanged url ->
            if url /= model.session.url then
                case Session.getType url of
                    Session.Index ->
                        initIndex
                            { model
                                | state = Idle
                                , session = Session.setUrl url model.session
                            }

                    Session.Course uri slide ->
                        let
                            session =
                                Session.setUrl url model.session

                            ( lia, cmd, events ) =
                                Lia.Script.load_slide session slide model.lia
                        in
                        ( { model
                            | lia = lia
                            , session = session
                          }
                        , events
                            |> List.map event2js
                            |> (::) (Cmd.map LiaScript cmd)
                            |> Cmd.batch
                        )

            else
                ( model, Cmd.none )

        Resize screen ->
            let
                session =
                    model.session
            in
            ( { model | session = { session | screen = screen } }, Cmd.none )

        LiaParse ->
            parsing model

        Load_ReadMe_Result url (Ok readme) ->
            load_readme readme model

        Load_ReadMe_Result url (Err info) ->
            if String.startsWith proxy url then
                ( { model | state = Error <| parse_error info }
                , url
                    |> JE.string
                    |> Event "offline" -1
                    |> event2js
                )

            else
                ( model
                , Session.setQuery (proxy ++ url) model.session
                    |> .url
                    |> Session.load
                )

        Load_Template_Result url (Ok template) ->
            parsing
                { model
                    | lia =
                        template
                            |> String.replace "\u{000D}" ""
                            |> Lia.Script.add_imports model.lia
                    , state =
                        case model.state of
                            Parsing b templates ->
                                Parsing b (templates - 1)

                            _ ->
                                model.state
                }

        Load_Template_Result url (Err info) ->
            if String.startsWith proxy url then
                ( { model | state = Error <| parse_error info }, Cmd.none )

            else
                ( model, download Load_Template_Result (proxy ++ url) )


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

        ( parsed, cmd, events ) =
            Lia.Script.load_first_slide session { lia | section_active = slide }
    in
    ( { model | state = Running, lia = parsed, session = session }
    , events
        |> List.map event2js
        |> (::) (Cmd.map LiaScript cmd)
        |> Cmd.batch
    )


parsing : Model -> ( Model, Cmd Msg )
parsing model =
    case model.state of
        Parsing False 0 ->
            start model

        Parsing True templates_to_load ->
            case model.code of
                Nothing ->
                    parsing { model | state = Parsing False templates_to_load }

                Just code ->
                    let
                        ( lia, remaining_code ) =
                            Lia.Script.parse_section model.lia code

                        new_model =
                            { model | lia = lia, code = remaining_code }
                    in
                    if modBy 4 (Lia.Script.pages lia) == 0 then
                        ( new_model, message LiaParse )

                    else
                        parsing new_model

        _ ->
            ( model, Cmd.none )


load_readme : String -> Model -> ( Model, Cmd Msg )
load_readme readme model =
    let
        ( lia, code, templates ) =
            readme
                |> String.replace "\u{000D}" ""
                |> Lia.Script.init_script model.lia
    in
    case model.preload of
        Nothing ->
            load model lia code templates

        Just course ->
            let
                latest =
                    course.versions
                        |> Dict.values
                        |> List.map (.definition >> .version >> Version.toInt)
                        |> List.sort
                        |> List.reverse
                        |> List.head
                        |> Maybe.withDefault -1
            in
            if
                latest
                    /= Version.toInt lia.definition.version
                    || Version.getMajor lia.definition.version
                    == 0
            then
                load model lia code templates

            else
                ( model
                , course.id
                    |> Index.restore (Version.getMajor lia.definition.version)
                    |> event2js
                )


load : Model -> Lia.Script.Model -> Maybe String -> List String -> ( Model, Cmd Msg )
load model lia code templates =
    case ( code, templates ) of
        ( Just code_, [] ) ->
            ( { model
                | lia = lia
                , state = Parsing True 0
                , code = Just code_
                , size = String.length code_ |> toFloat
              }
            , message LiaParse
            )

        ( Just code_, templates_ ) ->
            ( { model
                | lia = lia
                , state = Parsing True <| List.length templates_
                , code = Just code_
                , size = String.length code_ |> toFloat
              }
            , templates
                |> List.map (download Load_Template_Result)
                |> (::) (message LiaParse)
                |> Cmd.batch
            )

        ( Nothing, _ ) ->
            ( { model
                | state =
                    lia.error
                        |> Maybe.withDefault ""
                        |> Error
              }
            , Cmd.none
            )


{-| **@private:** Turns an Http.Error into a string message.
-}
parse_error : Http.Error -> String
parse_error msg =
    case msg of
        Http.BadUrl url ->
            "Bad Url " ++ url

        Http.Timeout ->
            "Network timeout"

        Http.BadStatus int ->
            "Bad status " ++ String.fromInt int

        Http.NetworkError ->
            "Network error"

        Http.BadBody body ->
            "Bad body " ++ body


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
    ( model, Index.get url |> event2js )


initIndex : Model -> ( Model, Cmd Msg )
initIndex model =
    ( model, event2js Index.init )
