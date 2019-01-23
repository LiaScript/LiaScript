port module Lia.Update exposing
    ( Msg(..)
    , get_active_section
    , send
    , subscriptions
    , update
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Effect.Update as Effect
import Lia.Event exposing (Event, jsonToEvent)
import Lia.Index.Update as Index
import Lia.Markdown.Update as Markdown
import Lia.Model exposing (..)
import Lia.Parser exposing (parse_section)
import Lia.Settings.Model exposing (Mode(..))
import Lia.Settings.Update as Settings
import Lia.Types exposing (Section, Sections)


port event2js : Event -> Cmd msg


port event2elm : (Event -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    case get_active_section model of
        Just section ->
            Sub.batch
                [ event2elm Handle
                , section
                    |> Markdown.subscriptions
                    |> Sub.map UpdateMarkdown
                ]

        Nothing ->
            event2elm Handle


type Msg
    = Load Int
    | InitSection
    | PrevSection
    | NextSection
    | UpdateIndex Index.Msg
    | UpdateSettings Settings.Msg
    | UpdateMarkdown Markdown.Msg
    | Handle Event


speak : Model -> Bool
speak model =
    if model.ready then
        model.settings.sound

    else
        False


send : Int -> List ( String, JE.Value ) -> Cmd Markdown.Msg -> Cmd Msg
send idx events cmd =
    case events of
        [] ->
            Cmd.map UpdateMarkdown cmd

        list ->
            list
                |> List.map (\( name, json ) -> event2js <| Event name idx json)
                |> (::) (Cmd.map UpdateMarkdown cmd)
                |> Cmd.batch


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load idx ->
            if (-1 < idx) && (idx < Array.length model.sections) then
                ( model
                , event2js <| Event "persistent" idx <| JE.string "store"
                )

            else
                ( model, Cmd.none )

        UpdateSettings childMsg ->
            case Settings.update childMsg model.settings of
                ( settings, [] ) ->
                    ( { model | settings = settings }
                    , Cmd.none
                    )

                ( settings, events ) ->
                    ( { model | settings = settings }
                    , events
                        |> List.map event2js
                        |> Cmd.batch
                    )

        UpdateIndex childMsg ->
            let
                ( index, sections ) =
                    Index.update childMsg model.index_model model.sections
            in
            ( { model
                | index_model = index
                , sections = sections
              }
            , Cmd.none
            )

        Handle event ->
            case event.topic of
                "settings" ->
                    ( { model | settings = Settings.load model.settings event.message, ready = True }
                    , Cmd.none
                    )

                "load" ->
                    update InitSection (generate { model | section_active = event.section })

                "reset" ->
                    ( model, event2js <| Event "reset" -1 JE.null )

                _ ->
                    case
                        ( Array.get
                            (if event.section == -1 then
                                model.section_active

                             else
                                event.section
                            )
                            model.sections
                        , jsonToEvent event.message
                        )
                    of
                        ( Just sec, Ok e ) ->
                            let
                                ( sec_, cmd_, events ) =
                                    Markdown.handle event.topic e sec
                            in
                            ( { model | sections = Array.set event.section sec_ model.sections }
                            , send event.section events cmd_
                            )

                        _ ->
                            ( model, Cmd.none )

        _ ->
            case ( msg, get_active_section model ) of
                ( UpdateMarkdown childMsg, Just sec ) ->
                    let
                        ( section, cmd, log_ ) =
                            Markdown.update childMsg sec
                    in
                    ( set_active_section model section
                    , send model.section_active log_ cmd
                    )

                ( NextSection, Just sec ) ->
                    if (model.settings.mode == Textbook) || not (Effect.has_next sec.effect_model) then
                        update (Load (model.section_active + 1)) model

                    else
                        let
                            ( sec_, cmd_, log_ ) =
                                Markdown.nextEffect (speak model) sec
                        in
                        ( set_active_section model sec_
                        , send model.section_active log_ cmd_
                        )

                ( PrevSection, Just sec ) ->
                    if (model.settings.mode == Textbook) || not (Effect.has_previous sec.effect_model) then
                        update (Load (model.section_active - 1)) model

                    else
                        let
                            ( sec_, cmd_, log_ ) =
                                Markdown.previousEffect (speak model) sec
                        in
                        ( set_active_section model sec_
                        , send model.section_active log_ cmd_
                        )

                ( InitSection, Just sec ) ->
                    let
                        ( sec_, cmd_, log_ ) =
                            case model.settings.mode of
                                Textbook ->
                                    Markdown.initEffect True False sec

                                _ ->
                                    Markdown.initEffect False (speak model) sec
                    in
                    ( set_active_section { model | to_do = [] } sec_
                    , model.to_do
                        |> List.map event2js
                        |> List.append
                            [ event2js <| Event "slide" model.section_active JE.null
                            , send model.section_active log_ cmd_
                            , event2js <| Event "persistent" model.section_active (JE.string "load")
                            ]
                        |> Cmd.batch
                    )

                _ ->
                    ( model, Cmd.none )


restore_ : Model -> Int -> JD.Value -> (JD.Value -> Result String a) -> (Section -> a -> Section) -> Model
restore_ model idx json json2vec update_ =
    case json2vec json of
        Ok vec ->
            case Array.get idx model.sections of
                Just s ->
                    { model | sections = Array.set idx (update_ s vec) model.sections }

                Nothing ->
                    model

        Err msg ->
            let
                x =
                    Debug.log "Error restore_" ( msg, json )
            in
            model


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
                        case Lia.Parser.parse_section model.definition sec of
                            Ok new_sec ->
                                new_sec

                            Err msg ->
                                { sec
                                    | body = []
                                    , error = Just msg
                                }

                ( javascript, logs ) =
                    section
                        |> .definition
                        |> Maybe.map .scripts
                        |> Maybe.withDefault []
                        |> load_src "script" model.javascript
            in
            set_active_section
                { model
                    | javascript =
                        javascript
                    , to_do =
                        model.to_do
                            |> List.append logs
                            |> add_load (Array.length section.quiz_vector) model.section_active "quiz"
                            -- todo  |> add_load (Array.length section.code_vector) model.section_active "code"
                            |> add_load (Array.length section.survey_vector) model.section_active "survey"
                }
                section

        Nothing ->
            model


log : String -> Maybe JE.Value -> Maybe ( String, JE.Value )
log topic msg =
    case msg of
        Just m ->
            Just ( topic, m )

        _ ->
            Nothing
