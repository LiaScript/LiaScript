module Lia.Update exposing
    ( Msg(..)
    , generate
    , get_active_section
    , key_decoder
    , subscriptions
    , update
    )

import Array
import Json.Decode as JD
import Json.Encode as JE
import Lia.Index.Update as Index
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Effect.Update as Effect
import Lia.Markdown.Update as Markdown
import Lia.Model exposing (Model, load_src)
import Lia.Parser.Parser exposing (parse_section)
import Lia.Section exposing (Section)
import Lia.Settings.Model exposing (Mode(..))
import Lia.Settings.Update as Settings
import Port.Event as Event exposing (Event)
import Session exposing (Session)


subscriptions : Model -> Sub Msg
subscriptions model =
    case get_active_section model of
        Just section ->
            section
                |> Markdown.subscriptions
                |> Sub.map UpdateMarkdown

        Nothing ->
            Sub.none


type Msg
    = Load Int
    | InitSection
    | PrevSection
    | NextSection
    | UpdateIndex Index.Msg
    | UpdateSettings Settings.Msg
    | UpdateMarkdown Markdown.Msg
    | Handle Event
    | Home
    | KeyPressIgnored
    | Script ( Int, Script.Msg Markdown.Msg )


send : Int -> List ( String, JE.Value ) -> List Event
send idx =
    List.map (\( name, json ) -> Event name idx json)


key_to_message : String -> ( Msg, Bool )
key_to_message s =
    case s of
        "ArrowLeft" ->
            ( PrevSection, True )

        "ArrowRight" ->
            ( NextSection, True )

        _ ->
            ( KeyPressIgnored, False )


key_decoder : JD.Decoder ( Msg, Bool )
key_decoder =
    JD.field "key" JD.string
        |> JD.map key_to_message


update : Session -> Msg -> Model -> ( Model, Cmd Msg, List Event )
update session msg model =
    case msg of
        Load idx ->
            if (-1 < idx) && (idx < Array.length model.sections) then
                ( { model | section_active = idx }
                , Session.navToSlide session idx
                , [ Event "persistent" idx <| JE.string "store" ]
                )

            else
                ( model, Cmd.none, [] )

        Home ->
            ( model, Session.navToHome session, [] )

        UpdateSettings childMsg ->
            let
                ( settings, events ) =
                    Settings.update childMsg model.settings
            in
            ( { model | settings = settings }
            , Cmd.none
            , events
            )

        UpdateIndex childMsg ->
            let
                ( index, sections ) =
                    Index.update childMsg model.sections
            in
            ( { model
                | index_model = index
                , sections = sections
              }
            , Cmd.none
            , []
            )

        Handle event ->
            case event.topic of
                "settings" ->
                    case event.message |> Event.decode of
                        Ok e ->
                            update
                                session
                                (e
                                    |> Settings.handle
                                    |> UpdateSettings
                                )
                                model

                        _ ->
                            ( model, Cmd.none, [] )

                "load" ->
                    update session InitSection (generate model)

                "reset" ->
                    ( model
                    , Cmd.none
                    , [ Event "reset" -1 JE.null ]
                    )

                "goto" ->
                    update session (Load event.section) model

                "swipe" ->
                    case JD.decodeValue JD.string event.message of
                        Ok "left" ->
                            update session NextSection model

                        Ok "right" ->
                            update session PrevSection model

                        _ ->
                            ( model, Cmd.none, [] )

                _ ->
                    case
                        ( Array.get event.section model.sections
                        , Event.decode event.message
                        )
                    of
                        ( Just sec, Ok e ) ->
                            let
                                ( sec_, cmd_, events ) =
                                    Markdown.handle event.topic e sec
                            in
                            ( { model | sections = Array.set event.section sec_ model.sections }
                            , Cmd.map UpdateMarkdown cmd_
                            , send event.section events
                            )

                        _ ->
                            ( model, Cmd.none, [] )

        KeyPressIgnored ->
            ( model, Cmd.none, [] )

        Script ( id, sub ) ->
            case Array.get id model.sections of
                Just sec ->
                    let
                        ( section, cmd_, log_ ) =
                            Markdown.updateScript (Just sub) ( sec, Cmd.none, [] )
                    in
                    ( { model | sections = Array.set id section model.sections }
                    , Cmd.map UpdateMarkdown cmd_
                    , send id log_
                    )

                _ ->
                    ( model, Cmd.none, [] )

        _ ->
            case ( msg, get_active_section model ) of
                ( UpdateMarkdown childMsg, Just sec ) ->
                    let
                        ( section, cmd_, log_ ) =
                            Markdown.update childMsg sec
                    in
                    ( set_active_section model section
                    , Cmd.map UpdateMarkdown cmd_
                    , send model.section_active log_
                    )

                ( NextSection, Just sec ) ->
                    if
                        (model.settings.mode == Textbook)
                            || (model.settings.mode == Newspaper)
                            || not (Effect.has_next sec.effect_model)
                    then
                        update session (Load (model.section_active + 1)) model

                    else
                        let
                            ( sec_, cmd_, log_ ) =
                                Markdown.nextEffect model.settings.sound sec
                        in
                        ( set_active_section model sec_
                        , Cmd.map UpdateMarkdown cmd_
                        , send model.section_active log_
                        )

                ( PrevSection, Just sec ) ->
                    if (model.settings.mode == Textbook) || not (Effect.has_previous sec.effect_model) then
                        update session (Load (model.section_active - 1)) model

                    else
                        let
                            ( sec_, cmd_, log_ ) =
                                Markdown.previousEffect model.settings.sound sec
                        in
                        ( set_active_section model sec_
                        , Cmd.map UpdateMarkdown cmd_
                        , send model.section_active log_
                        )

                ( InitSection, Just sec ) ->
                    let
                        ( sec_, cmd_, log_ ) =
                            case model.settings.mode of
                                Textbook ->
                                    Markdown.initEffect True False sec

                                _ ->
                                    Markdown.initEffect False model.settings.sound sec
                    in
                    ( set_active_section { model | to_do = [] } sec_
                    , Cmd.map UpdateMarkdown cmd_
                    , model.to_do
                        |> List.append (send model.section_active log_)
                        |> (::) (Event "slide" model.section_active JE.null)
                    )

                _ ->
                    ( model, Cmd.none, [] )


add_load : Int -> Int -> String -> List Event -> List Event
add_load length idx vector logs =
    if length == 0 then
        logs

    else
        (Event "load" idx <| JE.string vector) :: logs


get_active_section : Model -> Maybe Section
get_active_section model =
    Array.get model.section_active model.sections


set_active_section : Model -> Section -> Model
set_active_section model section =
    { model | sections = Array.set model.section_active section model.sections }


generate : Model -> Model
generate model =
    case get_active_section model of
        Just sec ->
            let
                section =
                    if sec.parsed then
                        let
                            effects =
                                sec.effect_model
                        in
                        { sec | effect_model = { effects | visible = 0 } }

                    else
                        case parse_section model.search_index model.definition sec of
                            Ok new_sec ->
                                new_sec

                            Err msg ->
                                { sec
                                    | body = []
                                    , error = Just msg
                                }

                ( resource, logs ) =
                    section
                        |> .definition
                        |> Maybe.map .resources
                        |> Maybe.withDefault []
                        |> load_src model.resource
            in
            set_active_section
                { model
                    | resource = resource
                    , to_do =
                        model.to_do
                            |> List.append logs
                            |> add_load (Array.length section.quiz_vector) model.section_active "quiz"
                            |> add_load (Array.length section.code_vector) model.section_active "code"
                            |> add_load (Array.length section.survey_vector) model.section_active "survey"
                }
                section

        Nothing ->
            model
