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
import Http
import Index.Update as Index
import Json.Decode as JD
import Json.Encode as JE
import Lia.Json.Decode
import Lia.Script
import Model exposing (Model, State(..))
import Port.Event exposing (Event)
import Process
import Session exposing (Screen)
import Task
import Translations
import Url


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


{-| **@private:** Combine commands and events to one command output.
-}
batch : (a -> msg) -> Cmd a -> List Event -> Cmd msg
batch map cmd events =
    if List.isEmpty events then
        Cmd.map map cmd

    else
        events
            |> List.map event2js
            |> (::) (Cmd.map map cmd)
            |> Cmd.batch


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LiaScript childMsg ->
            let
                ( lia, cmd, events ) =
                    Lia.Script.update model.session childMsg model.lia
            in
            ( { model | lia = lia }
            , batch LiaScript cmd events
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
                    case Lia.Json.Decode.decode event.message of
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

                "lang" ->
                    case JD.decodeValue JD.string event.message of
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
                ( index, cmd, events ) =
                    Index.update childMsg model.index
            in
            ( { model | index = index }
            , batch UpdateIndex cmd events
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , url
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

                            ( lia, cmd, events ) =
                                Lia.Script.load_slide session True slide model.lia
                        in
                        ( { model
                            | lia = lia
                            , session = session
                          }
                        , batch LiaScript cmd events
                        )

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

        Load_Template_Result _ (Ok template) ->
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
                }

        Load_Template_Result url (Err info) ->
            if String.startsWith proxy url then
                ( { model | state = Error <| parse_error info }, Cmd.none )

            else
                ( model, download Load_Template_Result (proxy ++ url) )


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

        ( parsed, cmd, events ) =
            Lia.Script.load_first_slide session { lia | section_active = slide }
    in
    ( { model | state = Running, lia = parsed, session = session }
    , batch LiaScript cmd events
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
                    -- stop after 4 iterations to update the view
                    if modBy 4 (Lia.Script.pages lia) == 0 then
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
    if
        model.preload
            |> Maybe.map (Index.inCache lia.definition.version)
            |> Maybe.withDefault False
    then
        ( model
        , lia.readme
            |> Index.restore lia.definition.version
            |> event2js
        )

    else
        load model lia code templates


{-| Start parsing and download external imports (templates).
-}
load : Model -> Lia.Script.Model -> Maybe String -> List String -> ( Model, Cmd Msg )
load model lia code templates =
    case code of
        Just code_ ->
            ( { model
                | lia = lia
                , state = Parsing True <| List.length templates
                , code = code
                , size = String.length code_ |> toFloat
              }
            , templates
                |> List.map (download Load_Template_Result)
                |> (::) (message LiaParse)
                |> Cmd.batch
            )

        Nothing ->
            ( { model
                | state =
                    lia.error
                        |> Maybe.withDefault ""
                        |> Error
              }
            , Cmd.none
            )


{-| **@private:** purge the "Windows" carriage return.

> Since all following grammers in parsing use only `\n` as newline instead of
> `\r\n`, this char needs to be purged entirely.

-}
removeCR : String -> String
removeCR =
    String.replace "\u{000D}" ""


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
