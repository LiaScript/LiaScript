port module Lia.Update exposing
    ( Msg(..)
    , Toggle(..)
    , get_active_section
    , maybe_event
    , subscriptions
    , update
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Effect.Update as Effect
import Lia.Helper exposing (ID)
import Lia.Index.Update as Index
import Lia.Markdown.Update as Markdown
import Lia.Model exposing (..)
import Lia.Parser exposing (parse_section)
import Lia.Types exposing (Mode(..), Section, Sections)
import Navigation



--import Navigation


port event2js : ( String, Int, JE.Value ) -> Cmd msg


port event2elm : (( String, Int, String, JD.Value ) -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    case get_active_section model of
        Just section ->
            Sub.batch
                [ event2elm Event
                , section
                    |> Markdown.subscriptions
                    |> Sub.map UpdateMarkdown
                ]

        Nothing ->
            event2elm Event


type Msg
    = Load ID Bool
    | InitSection
    | PrevSection
    | NextSection
    | DesignTheme String
    | DesignLight
    | DesignAce String
    | UpdateIndex Index.Msg
    | UpdateMarkdown Markdown.Msg
    | UpdateSettings
    | SwitchMode
    | Toggle Toggle
      --    | Location String
    | IncreaseFontSize Bool
    | Event ( String, Int, String, JE.Value )


type Toggle
    = LOC
    | Settings
    | Translations
    | Informations
    | Share
    | Sound


log_maybe : ID -> Maybe ( String, JE.Value ) -> List ( String, ID, JE.Value )
log_maybe idx log =
    case log of
        Nothing ->
            []

        Just ( name, json ) ->
            [ ( name, idx, json ) ]


speak : Model -> Bool
speak model =
    if model.ready then
        model.sound

    else
        False


maybe_event : ID -> Maybe ( String, JE.Value ) -> Cmd Markdown.Msg -> Cmd Msg
maybe_event idx log cmd =
    case log of
        Nothing ->
            Cmd.map UpdateMarkdown cmd

        Just ( name, json ) ->
            Cmd.batch [ event2js ( name, idx, json ), Cmd.map UpdateMarkdown cmd ]


log_settings : Model -> Cmd Msg
log_settings model =
    event2js ( "preferences", -1, model |> model2settings |> settings2json )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load idx history ->
            if (idx /= model.section_active || not model.ready) && (-1 < idx) && (idx < Array.length model.sections) then
                ( model
                , if history then
                    Cmd.batch
                        [ event2js ( "persistent", idx, JE.string "store" )
                        , (idx + 1)
                            |> toString
                            |> (++) "#"
                            |> Navigation.newUrl
                        ]

                  else
                    event2js ( "persistent", idx, JE.string "store" )
                )

            else
                ( model, Cmd.none )

        UpdateSettings ->
            ( model, model |> log_settings )

        DesignTheme theme ->
            let
                setting =
                    model.design
            in
            update UpdateSettings { model | design = { setting | theme = theme } }

        DesignLight ->
            let
                setting =
                    model.design
            in
            update UpdateSettings
                { model
                    | design =
                        { setting
                            | light =
                                if setting.light == "light" then
                                    "dark"

                                else
                                    "light"
                        }
                }

        DesignAce theme ->
            let
                setting =
                    model.design
            in
            update UpdateSettings { model | design = { setting | ace = theme } }

        IncreaseFontSize positive ->
            let
                design =
                    model.design
            in
            update UpdateSettings
                { model
                    | design =
                        { design
                            | font_size =
                                if positive then
                                    design.font_size + 10

                                else if design.font_size <= 10 then
                                    design.font_size

                                else
                                    design.font_size - 10
                        }
                }

        UpdateIndex childMsg ->
            let
                index =
                    model.sections
                        |> Array.map .code
                        |> Array.toIndexedList
                        |> Index.update childMsg model.index_model
            in
            ( { model | index_model = index }, Cmd.none )

        Event ( "load", idx, _, _ ) ->
            update InitSection (generate { model | section_active = idx })

        Event ( "reset", i, _, val ) ->
            ( model, event2js ( "reset", -1, JE.null ) )

        Event ( "preferences", x, y, json ) ->
            json
                |> json2settings
                |> settings2model model
                |> update InitSection

        Event ( topic, idx, msg, json ) ->
            case Array.get idx model.sections of
                Just sec ->
                    let
                        ( sec_, cmd_, log_ ) =
                            Markdown.jsEventHandler topic msg json sec
                    in
                    ( { model | sections = Array.set idx sec_ model.sections }
                    , maybe_event idx log_ cmd_
                    )

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            case ( msg, get_active_section model ) of
                ( UpdateMarkdown childMsg, Just sec ) ->
                    let
                        ( section, cmd, log ) =
                            Markdown.update childMsg sec
                    in
                    ( set_active_section model section
                    , maybe_event model.section_active log cmd
                    )

                ( NextSection, Just sec ) ->
                    if (model.mode == Textbook) || not (Effect.has_next sec.effect_model) then
                        update (Load (model.section_active + 1) True) model

                    else
                        let
                            ( sec_, cmd_, log_ ) =
                                Markdown.nextEffect (speak model) sec
                        in
                        ( set_active_section model sec_
                        , maybe_event model.section_active log_ cmd_
                        )

                ( PrevSection, Just sec ) ->
                    if (model.mode == Textbook) || not (Effect.has_previous sec.effect_model) then
                        update (Load (model.section_active - 1) True) model

                    else
                        let
                            ( sec_, cmd_, log_ ) =
                                Markdown.previousEffect (speak model) sec
                        in
                        ( set_active_section model sec_
                        , maybe_event model.section_active log_ cmd_
                        )

                ( InitSection, Just sec ) ->
                    let
                        ( sec_, cmd_, log_ ) =
                            case model.mode of
                                Textbook ->
                                    Markdown.initEffect True False sec

                                _ ->
                                    Markdown.initEffect False (speak model) sec
                    in
                    ( set_active_section { model | to_do = [] } sec_
                    , model.to_do
                        |> List.map event2js
                        |> List.append
                            [ event2js ( "slide", model.section_active, JE.null )
                            , maybe_event model.section_active log_ cmd_
                            , event2js ( "persistent", model.section_active, JE.string "load" )
                            ]
                        |> Cmd.batch
                    )

                ( SwitchMode, Just sec ) ->
                    let
                        mode =
                            case model.mode of
                                Presentation ->
                                    Slides

                                Slides ->
                                    Textbook

                                Textbook ->
                                    Presentation

                        ( sec_, cmd_, log_ ) =
                            case mode of
                                Textbook ->
                                    Markdown.initEffect True False sec

                                _ ->
                                    Markdown.initEffect False False sec

                        model_ =
                            { model | mode = mode }
                    in
                    ( set_active_section model_ sec_
                    , Cmd.batch
                        [ maybe_event model.section_active log_ cmd_
                        , log_settings model_
                        ]
                    )

                ( Toggle Sound, Just sec ) ->
                    let
                        ( sec_, cmd_, log_ ) =
                            Markdown.initEffect False (not model.sound) sec

                        model_ =
                            { model | sound = not model.sound }
                    in
                    ( model_
                    , Cmd.batch
                        [ maybe_event model.section_active log_ cmd_
                        , log_settings model_
                        ]
                    )

                ( Toggle what, _ ) ->
                    let
                        show =
                            Toogler model.show.loc False False False False
                    in
                    update UpdateSettings
                        { model
                            | show =
                                case what of
                                    LOC ->
                                        { show | loc = not show.loc }

                                    Settings ->
                                        { show | settings = not model.show.settings }

                                    Informations ->
                                        { show | informations = not model.show.informations }

                                    Translations ->
                                        { show | translations = not model.show.translations }

                                    _ ->
                                        { show | share = not model.show.share }
                        }

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


add_load : Int -> Int -> String -> List ( String, Int, JE.Value ) -> List ( String, Int, JE.Value )
add_load length idx vector logs =
    if length == 0 then
        logs

    else
        ( "load", idx, JE.string vector ) :: logs


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
                        case Lia.Parser.parse_section model.definition sec.code model.section_active of
                            Ok ( blocks, codes, quizzes, surveys, effects, footnotes, defines ) ->
                                { sec
                                    | body = blocks
                                    , error = Nothing
                                    , visited = True
                                    , code_vector = codes
                                    , quiz_vector = quizzes
                                    , survey_vector = surveys
                                    , effect_model = effects
                                    , footnotes = footnotes
                                    , definition = defines
                                    , parsed = True
                                }

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
                            |> add_load (Array.length section.code_vector) model.section_active "code"
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
