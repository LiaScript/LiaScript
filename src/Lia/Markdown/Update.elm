module Lia.Markdown.Update exposing (Msg(..), nextEffect, previousEffect, update)

--import Lia.Helper exposing (get_slide)

import Json.Encode as JE
import Lia.Code.Update as Code
import Lia.Effect.Update as Effect
import Lia.Quiz.Update as Quiz
import Lia.Types exposing (Section)


type Msg
    = UpdateEffect Effect.Msg
    | UpdateCode Code.Msg
    | UpdateQuiz Quiz.Msg



--    | UpdateQuiz Quiz.Msg
--    | UpdateCode Code.Msg
--    | UpdateSurvey Survey.Msg
--    | UpdateEffect Effect.Msg
--    | Theme String
--    | ThemeLight
--    | ToggleSpeech
--    | SwitchMode


update : Msg -> Section -> ( Section, Cmd Msg, Maybe ( String, JE.Value ) )
update msg section =
    case msg of
        UpdateEffect childMsg ->
            let
                ( effect_model, cmd ) =
                    Effect.update childMsg section.effect_model
            in
            ( { section | effect_model = effect_model }, Cmd.map UpdateEffect cmd, Nothing )

        UpdateCode childMsg ->
            let
                ( code_vector, cmd ) =
                    Code.update childMsg section.code_vector
            in
            ( { section | code_vector = code_vector }, Cmd.map UpdateCode cmd, Nothing )

        UpdateQuiz childMsg ->
            let
                ( quiz_vector, log ) =
                    Quiz.update childMsg section.quiz_vector
            in
            ( { section | quiz_vector = quiz_vector }, Cmd.none, Nothing )


nextEffect : Section -> Maybe Section
nextEffect section =
    case Effect.next section.effect_model of
        Just effect_model ->
            Just { section | effect_model = effect_model }

        _ ->
            Nothing


previousEffect : Section -> Maybe Section
previousEffect section =
    case Effect.previous section.effect_model of
        Just effect_model ->
            Just { section | effect_model = effect_model }

        _ ->
            Nothing



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
