port module Chat exposing (main)

{-| A standalone LiaScript chat, without a course and without a classroom. The
host pushes all messages (`add`, `clear`) via `event2elm` with the service
`"chat"`, every message is parsed as a LiaScript section. The header of a
message (`import`, `script`, `link`, macros, `@onload`, `@style`) applies to
the entire chat, messages are buffered while templates are downloaded.
-}

import Array
import Browser
import Const
import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Keyed as Keyed
import Http
import I18n.Translations as Translations
import Json.Decode as JD
import Json.Encode as JE
import Lia.Chat.Model as Chat
import Lia.Chat.Sync as Change exposing (Change)
import Lia.Chat.Update as Chat
import Lia.Definition.Types as Definition exposing (Definition, Resource)
import Lia.Markdown.Config as Config
import Lia.Markdown.Effect.Update as Effect
import Lia.Markdown.Update as Markdown
import Lia.Markdown.View as Markdown
import Lia.Model exposing (loadResource)
import Lia.Parser.Parser exposing (parse_definition)
import Lia.Parser.PatReplace exposing (resourceOrigin)
import Lia.Section exposing (Section)
import Lia.Settings.Json
import Lia.Settings.Types as Settings exposing (Mode(..), Settings)
import Lia.Sync.Types as Sync
import Lia.Utils exposing (urlQuery)
import Library.IPFS as IPFS
import Service.Console
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Resource
import Session exposing (Screen)


port event2js : Event -> Cmd msg


port event2elm : (Event -> msg) -> Sub msg


type alias Flags =
    { base : String
    , screen : Screen
    }


type alias Model =
    { definition : Definition
    , resource : List Resource
    , imported : List String
    , pending : Int
    , queue : List Change
    , chat : Chat.Model
    , meta : Dict.Dict Int Meta
    , sync : Sync.Settings
    , settings : Settings
    , screen : Screen
    }


{-| How a message is shown: the `name` and `icon` of its sender, `self` for the
own messages (right aligned) and the formatted time.
-}
type alias Meta =
    { name : String
    , icon : String
    , self : Bool
    , clock : String
    }


type Msg
    = Handle Event
    | UpdateChat Chat.Msg
    | Template String (Result Http.Error String)


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> event2elm Handle
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { definition = Definition.default flags.base ""
      , resource = []
      , imported = []
      , pending = 0
      , queue = []
      , chat = Chat.init
      , meta = Dict.empty
      , sync = Sync.init []
      , settings = Settings.init Nothing False Textbook
      , screen = flags.screen
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Handle event ->
            case ( event.service, Event.pop event ) of
                ( "chat", _ ) ->
                    host event.message model

                ( _, ( Just "settings", e ) ) ->
                    let
                        settings =
                            Lia.Settings.Json.toModel model.settings e.message.param
                                |> Result.withDefault model.settings
                    in
                    ( { model | settings = { settings | mode = Textbook } }, Cmd.none )

                _ ->
                    update (UpdateChat (Chat.handle event)) model

        UpdateChat childMsg ->
            let
                ret =
                    Chat.update
                        { msg = childMsg
                        , definition = model.definition
                        , model = model.chat
                        , sync = model.sync
                        }
            in
            ( { model | chat = ret.value }
            , ret.events
                |> List.map event2js
                |> (::) (Cmd.map UpdateChat ret.command)
                |> Cmd.batch
            )

        Template url (Ok code) ->
            case parse_definition (resourceOrigin url) (urlQuery url |> Maybe.withDefault "") (code ++ "\n#") of
                Ok ( template, _ ) ->
                    let
                        ( resource, loads ) =
                            loadResource model.resource template.resources

                        definition =
                            Definition.add_macros model.definition template
                    in
                    templateDone
                        { model | definition = definition, resource = resource }
                        (loads ++ onload template.onload ++ style model.definition definition)

                Err info ->
                    templateDone model [ Service.Console.warn ("template " ++ url ++ ": " ++ info) ]

        Template url (Err _) ->
            if String.startsWith Const.urlProxy url then
                templateDone model [ Service.Console.warn ("could not load template " ++ url) ]

            else
                ( model, download (IPFS.toHTTPS (Const.urlProxy ++ url) url) )


{-| Commands send by the host application.
-}
host : { cmd : String, param : JE.Value } -> Model -> ( Model, Cmd Msg )
host { cmd, param } model =
    case cmd of
        "add" ->
            case JD.decodeValue Change.decoder param of
                Ok changes ->
                    List.foldl add
                        ( { model
                            | meta =
                                param
                                    |> JD.decodeValue (JD.list metaDecoder)
                                    |> Result.withDefault []
                                    |> Dict.fromList
                                    |> Dict.union model.meta
                          }
                        , []
                        , []
                        )
                        changes
                        |> toCmd

                Err info ->
                    ( model, event2js (Service.Console.warn (JD.errorToString info)) )

        "clear" ->
            -- loaded scripts and styles cannot be removed from the page
            ( { model
                | definition = Definition.default model.definition.base ""
                , imported = []
                , pending = 0
                , queue = []
                , chat = Chat.init
                , meta = Dict.empty
              }
            , Cmd.none
            )

        _ ->
            ( model, event2js (Service.Console.warn ("chat: unknown command " ++ cmd)) )


metaDecoder : JD.Decoder ( Int, Meta )
metaDecoder =
    let
        optional key decoder default =
            JD.oneOf [ JD.field key decoder, JD.succeed default ]
    in
    JD.map2 Tuple.pair
        (JD.field "id" JD.int)
        (JD.map4 Meta
            (optional "user" JD.string "")
            (optional "icon" JD.string "")
            (optional "self" JD.bool False)
            (optional "clock" JD.string "")
        )


{-| Parse and insert one message. If its header imports new templates, the
message and all following ones are buffered until the templates are merged.
-}
add : Change -> ( Model, List Event, List (Cmd Msg) ) -> ( Model, List Event, List (Cmd Msg) )
add change ( model, events, cmds ) =
    if model.pending > 0 then
        ( { model | queue = model.queue ++ [ change ] }, events, cmds )

    else
        let
            ( todo, chat ) =
                Chat.insert model.sync True identity model.definition model.chat [ change ]

            key =
                String.fromInt change.id

            section =
                Dict.get key chat.messages |> Maybe.map .section

            -- a section header contains the global definition plus its own
            definition =
                section
                    |> Maybe.andThen .definition
                    |> Maybe.withDefault model.definition

            imports =
                List.filter (\url -> not (List.member url model.imported)) definition.imports

            ( resource, loads ) =
                loadResource model.resource definition.resources

            new =
                { model
                    | definition = definition
                    , resource = resource
                    , imported = model.imported ++ imports
                }

            global =
                events ++ loads ++ onload (changed .onload model.definition definition) ++ style model.definition definition
        in
        if List.isEmpty imports then
            let
                ( initialized, initEffect ) =
                    if Maybe.map (.body >> List.isEmpty) section == Just True then
                        -- header only, nothing to show
                        ( { new | chat = { chat | messages = Dict.remove key chat.messages } }, Cmd.none )

                    else
                        -- like a slide: run all scripts, with @input replaced
                        update
                            (Markdown.UpdateEffect False (Effect.init True)
                                |> Chat.UpdateMarkdown key
                                |> UpdateChat
                            )
                            { new | chat = chat }
            in
            ( initialized
              -- ponytail: Chat.insert executes scripts raw, without replacing
              -- @input (also in the classroom chat), the init above replaces it
            , global ++ List.filter (.service >> (/=) "script") todo ++ loadStates change.id section
            , cmds ++ [ initEffect ]
            )

        else
            ( { new | pending = List.length imports, queue = [ change ] }
            , global
            , cmds ++ List.map download imports
            )


templateDone : Model -> List Event -> ( Model, Cmd Msg )
templateDone model events =
    if model.pending > 1 then
        ( { model | pending = model.pending - 1 }, Cmd.batch (List.map event2js events) )

    else
        List.foldl add ( { model | pending = 0, queue = [] }, events, [] ) model.queue
            |> toCmd


toCmd : ( Model, List Event, List (Cmd Msg) ) -> ( Model, Cmd Msg )
toCmd ( model, events, cmds ) =
    ( model, Cmd.batch (List.map event2js events ++ cmds) )


download : String -> Cmd Msg
download url =
    Http.get { url = url, expect = Http.expectString (Template url) }


{-| Restore quiz, survey and task states from the connector (code is already
requested by `Chat.insert`).
-}
loadStates : Int -> Maybe Section -> List Event
loadStates id section =
    case section of
        Just sec ->
            [ ( "quiz", Array.isEmpty sec.quiz_vector )
            , ( "survey", Array.isEmpty sec.survey_vector )
            , ( "task", Array.isEmpty sec.task_vector )
            ]
                |> List.filter (Tuple.second >> not)
                |> List.map (\( table, _ ) -> Service.Database.load table id |> Event.pushWithId table id)

        Nothing ->
            []


changed : (Definition -> String) -> Definition -> Definition -> String
changed fn old new =
    if fn old == fn new then
        ""

    else
        fn new


onload : String -> List Event
onload code =
    if String.isEmpty code then
        []

    else
        [ Event.init "chat" { cmd = "onload", param = JE.string code } ]


style : Definition -> Definition -> List Event
style old new =
    case changed (.macro >> Dict.get "style" >> Maybe.withDefault "") old new of
        "" ->
            []

        css ->
            [ Service.Resource.style css ]


view : Model -> Html Msg
view model =
    let
        config =
            Config.init
                (Translations.getLnFromCode model.definition.language |> Maybe.withDefault Translations.En)
                { old = model.definition.language, new = model.definition.language, name = Nothing }
                model.settings
                model.sync
                model.screen
                0
                (Just model.definition.formulas)
                Dict.empty
    in
    -- ids are the positions within the chat (0, 1, 2, ...)
    model.chat.messages
        |> Dict.toList
        |> List.filterMap (\( key, m ) -> String.toInt key |> Maybe.map (\id -> ( id, key, m.section )))
        |> List.sortBy (\( id, _, _ ) -> id)
        |> List.map
            (\( id, key, section ) ->
                ( key
                , Dict.get id model.meta
                    |> Maybe.withDefault { name = "", icon = "", self = False, clock = "" }
                    |> viewMessage (config section |> Config.setID id) section
                    |> Html.map (Chat.UpdateMarkdown key >> UpdateChat)
                )
            )
        |> Keyed.node "article" [ Attr.id "lia-chat-messages" ]


viewMessage : Config.Config Markdown.Msg -> Section -> Meta -> Html Markdown.Msg
viewMessage config section meta =
    Html.div
        [ Attr.classList
            [ ( "lia-chat__msg", True )
            , ( "lia-chat__msg--self", meta.self )
            , ( "lia-chat__msg--effects", section.effect_model.effects > 0 )
            ]
        ]
        [ Html.div [] (Markdown.viewContent config)
        , Html.div [ Attr.class "lia-chat__foot" ]
            [ if String.isEmpty meta.icon then
                Html.text ""

              else
                Html.img [ Attr.src meta.icon, Attr.alt "", Attr.class "lia-chat__icon" ] []
            , Html.text meta.name
            , Html.time [] [ Html.text meta.clock ]
            ]
        ]
