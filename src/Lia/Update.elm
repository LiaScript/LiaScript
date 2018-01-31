module Lia.Update exposing (Msg(..), generate, get_active_section, update)

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


type Msg
    = Load ID
    | PrevSection
    | NextSection
    | DesignTheme String
    | DesignLight
    | ToggleLOC
    | UpdateIndex Index.Msg
    | UpdateMarkdown Markdown.Msg
    | SwitchMode



--    | UpdateQuiz Quiz.Msg
--    | UpdateCode Code.Msg
--    | UpdateSurvey Survey.Msg
--    | UpdateEffect Effect.Msg
--    | Theme String
--    | ThemeLight
--    | ToggleSpeech
--    | SwitchMode


update : Msg -> Model -> ( Model, Cmd Msg, Maybe ( String, JE.Value ) )
update msg model =
    case ( msg, get_active_section model ) of
        ( ToggleLOC, _ ) ->
            ( { model | loc = not model.loc }, Cmd.none, Nothing )

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
                    }
              }
            , Cmd.none
            , Nothing
            )

        ( Load idx, Just _ ) ->
            if (-1 < idx) && (idx < Array.length model.sections) then
                let
                    unused =
                        case model.uid of
                            Just uid ->
                                set_local uid idx

                            Nothing ->
                                0
                in
                ( generate { model | section_active = idx }
                , Cmd.none
                , Nothing
                )
            else
                ( model, Cmd.none, Nothing )

        ( NextSection, Just sec ) ->
            case ( Effect.has_next sec.effect_model, model.mode ) of
                ( True, Presentation ) ->
                    let
                        ( sec_, cmd_, log_ ) =
                            Markdown.nextEffect sec
                    in
                    ( set_active_section model sec_, Cmd.map UpdateMarkdown cmd_, log_ )

                _ ->
                    update (Load <| model.section_active + 1) model

        ( PrevSection, Just sec ) ->
            case ( Effect.has_previous sec.effect_model, model.mode ) of
                ( True, Presentation ) ->
                    let
                        ( sec_, cmd_, log_ ) =
                            Markdown.previousEffect sec
                    in
                    ( set_active_section model sec_, Cmd.map UpdateMarkdown cmd_, log_ )

                _ ->
                    update (Load <| model.section_active - 1) model

        ( SwitchMode, Just _ ) ->
            if model.mode == Presentation then
                ( { model | mode = set_local "mode" Slides }, Cmd.none, Nothing )
            else
                ( { model | mode = set_local "mode" Presentation }, Cmd.none, Nothing )

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
            set_active_section model <|
                case Lia.Parser.parse_section model.definition sec.code of
                    Ok ( blocks, codes, quizzes, surveys, effects ) ->
                        { sec
                            | body = blocks
                            , error = Nothing
                            , visited = True
                            , code_vector = if_update sec.code_vector codes
                            , quiz_vector = if_update sec.quiz_vector quizzes
                            , survey_vector = if_update sec.survey_vector surveys
                            , effect_model = effects
                        }

                    Err msg ->
                        { sec
                            | body = []
                            , error = Just msg
                        }

        Nothing ->
            model


if_update : Array a -> Array a -> Array a
if_update orig new =
    if Array.isEmpty orig then
        new
    else
        orig



-- case msg of
--     Load int ->
--         if (-1 < int) && (int < List.length model.slides) then
--             let
--                 ( effect_model, cmd, _ ) =
--                     get_slide int model.slides
--                         |> EffectModel.init model.narrator
--                         |> Effect.init model.silent
--
--                 x =
--                     model.uid
--                         |> Maybe.map (\uid -> set_local uid (toString int))
--             in
--             ( { model
--                 | current_slide = int
--                 , effect_model = effect_model
--               }
--             , Cmd.map UpdateEffect cmd
--             , Nothing
--             )
--         else
--             ( model, Cmd.none, Nothing )
--
--     Theme theme ->
--         let
--             x =
--                 set_local "theme" theme
--         in
--         ( { model | theme = theme }, Cmd.none, Nothing )
--
--     ThemeLight ->
--         let
--             x =
--                 set_local "theme_light"
--                     (if not model.theme_light then
--                         "on"
--                      else
--                         "off"
--                     )
--         in
--         ( { model | theme_light = not model.theme_light }, Cmd.none, Nothing )
--
--     ToggleSpeech ->
--         if model.silent then
--             let
--                 ( effect_model, cmd, _ ) =
--                     Effect.repeat False model.effect_model
--
--                 x =
--                     set_local "silent" "false"
--             in
--             ( { model | silent = False, effect_model = effect_model }, Cmd.map UpdateEffect cmd, Nothing )
--         else
--             let
--                 x =
--                     if not model.silent then
--                         Effect.silence ()
--                     else
--                         False
--
--                 y =
--                     set_local "silent" "true"
--             in
--             ( { model | silent = True }, Cmd.none, Nothing )
--
--     SwitchMode ->
--         case model.mode of
--             Slides ->
--                 let
--                     x =
--                         Effect.silence ()
--
--                     y =
--                         set_local "mode" "Slides_only"
--                 in
--                 ( { model | mode = Slides_only, silent = True }, Cmd.none, Nothing )
--
--             _ ->
--                 let
--                     x =
--                         set_local "mode" "Slides"
--                 in
--                 update ToggleSpeech { model | mode = Slides, silent = True }
--
--     PrevSlide hidden_effects ->
--         let
--             effect_model =
--                 model.effect_model
--         in
--         case ( model.mode, Effect.previous model.silent { effect_model | effects = effect_model.effects - hidden_effects } ) of
--             ( Slides, ( effect_model, cmd, False ) ) ->
--                 ( { model | effect_model = effect_model }, Cmd.map UpdateEffect cmd, Nothing )
--
--             _ ->
--                 update (Load (model.current_slide - 1)) model
--
--     NextSlide hidden_effects ->
--         let
--             effect_model =
--                 model.effect_model
--         in
--         case ( model.mode, Effect.next model.silent { effect_model | effects = effect_model.effects - hidden_effects } ) of
--             ( Slides, ( effect_model, cmd, False ) ) ->
--                 ( { model | effect_model = effect_model }, Cmd.map UpdateEffect cmd, Nothing )
--
--             _ ->
--                 update (Load (model.current_slide + 1)) model
--
--     UpdateIndex childMsg ->
--         let
--             index_model =
--                 Index.update childMsg model.index_model
--         in
--         ( { model | index_model = index_model }, Cmd.none, Nothing )
--
--     UpdateSurvey childMsg ->
--         let
--             ( model_, info ) =
--                 Survey.update childMsg model.survey_model
--         in
--         ( { model | survey_model = model_ }, Cmd.none, log "survey" info )
--
--     UpdateCode childMsg ->
--         let
--             ( code_model, cmd ) =
--                 Code.update childMsg model.code_model
--         in
--         ( { model | code_model = code_model }, Cmd.map UpdateCode cmd, Nothing )
--
--     UpdateEffect childMsg ->
--         let
--             ( effect_model, cmd, _ ) =
--                 Effect.update childMsg model.effect_model
--         in
--         ( { model | effect_model = effect_model }, Cmd.map UpdateEffect cmd, Nothing )
--
--     ToggleContentsTable ->
--         ( { model | show_contents = not model.show_contents }, Cmd.none, Nothing )
--
--     UpdateQuiz quiz_msg ->
--         let
--             ( quiz_model, info ) =
--                 Quiz.update quiz_msg model.quiz_model
--         in
--         ( { model | quiz_model = quiz_model }, Cmd.none, log "quiz" info )


log : String -> Maybe JE.Value -> Maybe ( String, JE.Value )
log topic msg =
    case msg of
        Just m ->
            Just ( topic, m )

        _ ->
            Nothing
