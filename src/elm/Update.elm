port module Update exposing
    ( Msg(..)
    , getIndex
    , initIndex
    , load_readme
    , subscriptions
    , update
    )

-- UPDATE

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
import I18n.Translations as Translations
import Index.Model as Index
import Index.Update as Index
import Index.Version
import Json.Decode as JD
import Lia.Definition.Types as Definition
import Lia.Json.Decode
import Lia.Model
import Lia.Script
import Library.IPFS as IPFS
import Model exposing (Model, State(..))
import Process
import Return exposing (Return)
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Local
import Service.P2P
import Service.Zip
import Session exposing (Screen)
import Task
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
    | GotResponse String (Result Http.Error ResponseData)


type ResponseData
    = IsZip
    | IsMarkdown String


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
        |> Task.map (always <| msg)
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
                            , if isURI url then
                                download False url

                              else
                                download_text_or_zip url
                            )

                        Err _ ->
                            ( { model | preload = Nothing }
                            , download_text_or_zip model.lia.readme
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
                            , download_text_or_zip model.lia.readme
                            )

                ( Nothing, _, ( "lang", param ) ) ->
                    case JD.decodeValue (JD.list JD.string) param of
                        Ok [ language_code, language_name ] ->
                            let
                                lia =
                                    model.lia
                            in
                            ( { model
                                | lia =
                                    { lia
                                        | translation =
                                            language_code
                                                |> Translations.getLnFromCode
                                                |> Maybe.withDefault lia.translation
                                        , langName = Just language_name
                                        , langCode = language_code
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

                ( Nothing, _, ( "load", param ) ) ->
                    case Service.P2P.decode param of
                        ( False, uri, result ) ->
                            update (Load_ReadMe_Result uri result)
                                (if String.isEmpty model.lia.readme || model.lia.readme /= uri then
                                    let
                                        lia =
                                            model.lia
                                    in
                                    { model | lia = { lia | readme = uri, url = lia.url ++ "/?" ++ uri, origin = "" } }

                                 else
                                    model
                                )

                        ( True, uri, result ) ->
                            update (Load_Template_Result uri result) model

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
                    case ( url.query, model.session.url.query ) of
                        ( Just newCourseURL, Just oldCourseURL ) ->
                            if newCourseURL == oldCourseURL && url.fragment == model.session.url.fragment then
                                let
                                    return =
                                        Lia.Script.skip_to_main_content model.session model.lia
                                in
                                ( { model | lia = return.value }
                                , batch LiaScript return
                                )

                            else if newCourseURL /= oldCourseURL || url.fragment /= Just "" then
                                ( model
                                , url
                                    |> Url.toString
                                    |> Navigation.load
                                )

                            else
                                ( model
                                , Cmd.none
                                )

                        ( Nothing, Just oldCourseURL ) ->
                            ( model
                            , { url | query = Just oldCourseURL }
                                |> Url.toString
                                |> Navigation.load
                            )

                        _ ->
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
                                , lia = Lia.Model.clear model.lia
                                , index = Index.reset_modal model.index
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
            if info == Http.NetworkError && String.startsWith "local://http" url then
                let
                    lia =
                        model.lia
                in
                update (GotResponse (String.dropLeft 8 url) (Ok IsZip))
                    { model | lia = { lia | origin = "" } }
                -- Handle ZIP file URL

            else if String.startsWith Const.urlProxy url then
                startWithError
                    { model
                        | state =
                            Error.Message.loadingCourse url info
                                |> Error.Report.add model.state
                    }

            else if isOffline info && model.preload /= Nothing then
                restore model

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

        GotResponse url (Ok responseData) ->
            case responseData of
                IsMarkdown content ->
                    -- Handle Markdown content
                    update (Load_ReadMe_Result url (Ok content)) model

                IsZip ->
                    let
                        new_model =
                            { model | state = Loading_Zip, session = Session.setQuery "" model.session }
                    in
                    -- Handle ZIP file URL
                    ( new_model
                    , Service.Local.download url
                        |> event2js
                    )

        GotResponse url (Err info) ->
            update (Load_ReadMe_Result url (Err info)) model


restore : Model -> ( Model, Cmd Msg )
restore model =
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
      , url =
            model.session.url.query
                |> Maybe.withDefault model.lia.readme
      }
        |> Service.Database.index_restore
        |> event2js
    )


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
                    case lia.error of
                        Nothing ->
                            -- stop after 4 iterations to update the view
                            if modBy 4 (Lia.Script.pages lia) == 0 then
                                ( new_model, message LiaParse )

                            else
                                parsing new_model

                        Just error ->
                            startWithError
                                { model
                                    | state =
                                        error
                                            |> Error.Message.parseDefinition False ( code, 0 )
                                            |> Error.Report.add model.state
                                }

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
        initial =
            readme
                |> removeCR
                |> Lia.Script.init_script model.lia
    in
    if
        model.preload
            |> Maybe.map (Index.inCache initial.model.definition.version)
            |> Maybe.withDefault False
    then
        ( model
        , { version = initial.model.definition.version, url = initial.model.readme }
            |> Service.Database.index_restore
            |> event2js
        )

    else
        load model initial


{-| Start parsing and download external imports (templates).
-}
load : Model -> { model : Lia.Script.Model, code : Maybe String, templates : List String, event : Maybe Event } -> ( Model, Cmd Msg )
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
                , size = String.length code_ |> toFloat
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


isURI : String -> Bool
isURI url =
    String.startsWith "data:text" url
        || String.startsWith "magnet:" url
        || String.startsWith "nostr:" url


{-| **@private:** Used by multiple times to connect a download with a message.
-}
download : Bool -> String -> Cmd Msg
download template url =
    if String.startsWith "data:text" url then
        loadFromData template url

    else if String.startsWith "magnet:" url then
        { template = template, uri = url }
            |> Service.P2P.torrent
            |> event2js

    else if String.startsWith "nostr:" url then
        { template = template, uri = url }
            |> Service.P2P.nostr
            |> event2js

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
    , [ Service.Database.index_list
            |> Event.push "index"
      , Service.Local.clear
      ]
        |> List.map event2js
        |> Cmd.batch
    )


download_text_or_zip : String -> Cmd Msg
download_text_or_zip url =
    Http.request
        { method = "GET"
        , url = url
        , headers = []
        , expect =
            Http.expectStringResponse (GotResponse url) handleResponse
        , timeout = Nothing
        , tracker = Nothing
        , body = Http.emptyBody
        }


handleResponse : Http.Response String -> Result Http.Error ResponseData
handleResponse response =
    case response of
        Http.GoodStatus_ metadata body ->
            case getContentType metadata of
                Just ct ->
                    if String.contains "application/zip" ct then
                        Ok IsZip

                    else
                        Ok (IsMarkdown body)

                Nothing ->
                    Ok (IsMarkdown body)

        Http.BadStatus_ metadata _ ->
            Err (Http.BadStatus metadata.statusCode)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.BadUrl_ info ->
            Err (Http.BadUrl info)


getContentType : Http.Metadata -> Maybe String
getContentType metadata =
    metadata.headers
        |> Dict.toList
        |> List.filter (\( name, _ ) -> String.toLower name == "content-type")
        |> List.head
        |> Maybe.map Tuple.second
