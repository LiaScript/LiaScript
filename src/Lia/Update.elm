module Lia.Update exposing
    ( Msg(..)
    , Toggle(..)
    , get_active_section
    , subscriptions
    , update
    )

import Array exposing (Array)
import Json.Encode as JE
import Lia.Effect.Update as Effect
import Lia.Helper exposing (ID)
import Lia.Index.Update as Index
import Lia.Markdown.Update as Markdown
import Lia.Model exposing (..)
import Lia.Parser exposing (parse_section)
import Lia.Types exposing (Mode(..), Section, Sections)
import Navigation


subscriptions : Model -> Sub Msg
subscriptions model =
    case get_active_section model of
        Just section ->
            Sub.batch
                [ section
                    |> Markdown.subscriptions
                    |> Sub.map UpdateMarkdown
                ]

        Nothing ->
            Sub.none


type Msg
    = Load ID
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
    | Location String
    | IncreaseFontSize Bool
    | Reset


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


log_settings : Model -> ( String, ID, JE.Value )
log_settings model =
    ( "update_settings", -1, model |> model2settings |> settings2json )


update : Msg -> Model -> ( Model, Cmd Msg, List ( String, ID, JE.Value ) )
update msg model =
    case msg of
        Load idx ->
            if (-1 < idx) && (idx < Array.length model.sections) then
                update InitSection (generate { model | section_active = idx })

            else
                ( model, Cmd.none, [] )

        UpdateSettings ->
            ( model, Cmd.none, [ log_settings model ] )

        Reset ->
            ( model, Cmd.none, [ ( "reset", -1, JE.null ) ] )

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

        Location url ->
            ( model, Navigation.load url, [] )

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
            ( { model | index_model = index }, Cmd.none, [] )

        _ ->
            case ( msg, get_active_section model ) of
                ( UpdateMarkdown childMsg, Just sec ) ->
                    let
                        ( section, cmd, log ) =
                            Markdown.update childMsg sec
                    in
                    ( set_active_section model section
                    , Cmd.map UpdateMarkdown cmd
                    , log_maybe model.section_active log
                    )

                ( NextSection, Just sec ) ->
                    if (model.mode == Textbook) || not (Effect.has_next sec.effect_model) then
                        update (Load <| model.section_active + 1) model

                    else
                        let
                            ( sec_, cmd_, log_ ) =
                                Markdown.nextEffect model.sound sec
                        in
                        ( set_active_section model sec_
                        , Cmd.map UpdateMarkdown cmd_
                        , log_maybe model.section_active log_
                        )

                ( PrevSection, Just sec ) ->
                    if (model.mode == Textbook) || not (Effect.has_previous sec.effect_model) then
                        update (Load <| model.section_active - 1) model

                    else
                        let
                            ( sec_, cmd_, log_ ) =
                                Markdown.previousEffect model.sound sec
                        in
                        ( set_active_section model sec_
                        , Cmd.map UpdateMarkdown cmd_
                        , log_maybe model.section_active log_
                        )

                ( InitSection, Just sec ) ->
                    let
                        ( sec_, cmd_, log_ ) =
                            case model.mode of
                                Textbook ->
                                    Markdown.initEffect True False sec

                                _ ->
                                    Markdown.initEffect False model.sound sec
                    in
                    ( set_active_section { model | to_do = [] } sec_
                    , Cmd.map UpdateMarkdown cmd_
                    , log_
                        |> log_maybe model.section_active
                        |> List.append model.to_do
                        |> (::) ( "slide", model.section_active, JE.null )
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
                    , Cmd.map UpdateMarkdown cmd_
                    , (::) (log_settings model_) (log_maybe model.section_active log_)
                    )

                ( Toggle Sound, Just sec ) ->
                    let
                        ( sec_, cmd_, log_ ) =
                            Markdown.initEffect False (not model.sound) sec

                        model_ =
                            { model | sound = not model.sound }
                    in
                    ( model_
                    , Cmd.map UpdateMarkdown cmd_
                    , (::) (log_settings model_) (log_maybe model.section_active log_)
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
                    ( model, Cmd.none, [] )


add_load : Int -> Int -> String -> List ( String, Int, JE.Value ) -> List ( String, Int, JE.Value )
add_load length idx vector logs =
    if length == 0 then
        logs

    else
        List.append logs [ ( "load", idx, JE.string vector ) ]


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
                        logs
                            |> List.append model.to_do
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
