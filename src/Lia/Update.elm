module Lia.Update
    exposing
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
import Lia.Utils exposing (set_local)
import Navigation


subscriptions : Model -> Sub Msg
subscriptions model =
    case get_active_section model of
        Just section ->
            Sub.batch [ Sub.map UpdateMarkdown (Markdown.subscriptions section) ]

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
    | SwitchMode
    | Toggle Toggle
    | Location String
    | IncreaseFontSize Bool


type Toggle
    = LOC
    | Settings
    | Translations
    | Informations
    | Share
    | Sound


update : Msg -> Model -> ( Model, Cmd Msg, Maybe ( String, JE.Value ) )
update msg model =
    case ( msg, get_active_section model ) of
        ( UpdateIndex childMsg, _ ) ->
            let
                index =
                    model.sections
                        |> Array.map .code
                        |> Array.toIndexedList
                        |> Index.update childMsg model.index_model
            in
            ( { model | index_model = index }, Cmd.none, Nothing )

        ( UpdateMarkdown childMsg, Just sec ) ->
            let
                ( section, cmd, log ) =
                    Markdown.update childMsg sec
            in
            ( set_active_section model section, Cmd.map UpdateMarkdown cmd, log )

        ( DesignTheme theme, _ ) ->
            ( { model
                | design =
                    { light = model.design.light
                    , theme = set_local "theme" theme
                    , font_size = model.design.font_size
                    , ace = model.design.ace
                    }
              }
            , Cmd.none
            , Nothing
            )

        ( DesignLight, _ ) ->
            ( { model
                | design =
                    { light =
                        set_local "theme_light" <|
                            if model.design.light == "light" then
                                "dark"
                            else
                                "light"
                    , theme = model.design.theme
                    , font_size = model.design.font_size
                    , ace = model.design.ace
                    }
              }
            , Cmd.none
            , Nothing
            )

        ( DesignAce theme, _ ) ->
            ( { model
                | design =
                    { light = model.design.light
                    , theme = model.design.theme
                    , font_size = model.design.font_size
                    , ace = set_local "ace" theme
                    }
              }
            , Cmd.none
            , Nothing
            )

        ( Load idx, Just _ ) ->
            if (-1 < idx) && (idx < Array.length model.sections) then
                let
                    unused =
                        if model.url == "" then
                            0
                        else
                            set_local model.url idx
                in
                update InitSection (generate { model | section_active = idx })
            else
                ( model, Cmd.none, Nothing )

        ( InitSection, Just sec ) ->
            let
                ( sec_, cmd_, log_ ) =
                    case model.mode of
                        Textbook ->
                            Markdown.initEffect True False sec

                        _ ->
                            Markdown.initEffect False model.sound sec
            in
            ( set_active_section model sec_
            , Cmd.map UpdateMarkdown cmd_
            , log_
            )

        ( NextSection, Just sec ) ->
            if (model.mode == Textbook) || not (Effect.has_next sec.effect_model) then
                update (Load <| model.section_active + 1) model
            else
                let
                    ( sec_, cmd_, log_ ) =
                        Markdown.nextEffect model.sound sec
                in
                ( set_active_section model sec_, Cmd.map UpdateMarkdown cmd_, log_ )

        ( PrevSection, Just sec ) ->
            if (model.mode == Textbook) || not (Effect.has_previous sec.effect_model) then
                update (Load <| model.section_active - 1) model
            else
                let
                    ( sec_, cmd_, log_ ) =
                        Markdown.previousEffect model.sound sec
                in
                ( set_active_section model sec_, Cmd.map UpdateMarkdown cmd_, log_ )

        ( SwitchMode, Just sec ) ->
            let
                mode =
                    set_local "mode"
                        (case model.mode of
                            Presentation ->
                                Slides

                            Slides ->
                                Textbook

                            Textbook ->
                                Presentation
                        )

                ( sec_, cmd_, log_ ) =
                    case mode of
                        Textbook ->
                            Markdown.initEffect True False sec

                        _ ->
                            Markdown.initEffect False False sec
            in
            ( set_active_section { model | mode = mode } sec_
            , Cmd.map UpdateMarkdown cmd_
            , log_
            )

        ( Toggle what, Just sec ) ->
            case what of
                Sound ->
                    let
                        ( sec_, cmd_, log_ ) =
                            Markdown.initEffect False (not model.sound) sec
                    in
                    ( { model | sound = set_local "sound" (not model.sound) }, Cmd.map UpdateMarkdown cmd_, log_ )

                _ ->
                    let
                        show =
                            Toogler model.show.loc False False False False
                    in
                    ( { model
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
                    , Cmd.none
                    , Nothing
                    )

        ( Location url, _ ) ->
            ( model, Navigation.load url, Nothing )

        ( IncreaseFontSize positive, _ ) ->
            let
                design =
                    model.design
            in
            ( { model
                | design =
                    { design
                        | font_size =
                            set_local "font_size" <|
                                if positive then
                                    design.font_size + 10
                                else if design.font_size <= 10 then
                                    design.font_size
                                else
                                    design.font_size - 10
                    }
              }
            , Cmd.none
            , Nothing
            )

        _ ->
            ( model, Cmd.none, Nothing )


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
                    case Lia.Parser.parse_section model.definition sec.code of
                        Ok ( blocks, codes, quizzes, surveys, effects, defines ) ->
                            { sec
                                | body = blocks
                                , error = Nothing
                                , visited = True
                                , code_vector = if_update sec.code_vector codes
                                , quiz_vector = if_update sec.quiz_vector quizzes
                                , survey_vector = if_update sec.survey_vector surveys
                                , effect_model = effects
                                , definition = defines
                            }

                        Err msg ->
                            { sec
                                | body = []
                                , error = Just msg
                            }
            in
            set_active_section
                { model
                    | javascript =
                        section.definition
                            |> Maybe.map .scripts
                            |> Maybe.map (load_javascript model.javascript)
                            |> Maybe.withDefault model.javascript
                }
                section

        Nothing ->
            model


if_update : Array a -> Array a -> Array a
if_update orig new =
    if Array.isEmpty orig then
        new
    else
        orig


log : String -> Maybe JE.Value -> Maybe ( String, JE.Value )
log topic msg =
    case msg of
        Just m ->
            Just ( topic, m )

        _ ->
            Nothing
