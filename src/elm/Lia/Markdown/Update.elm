port module Lia.Markdown.Update exposing
    ( Msg(..)
    , initEffect
    , jsEventHandler
    , nextEffect
    , previousEffect
    , subscriptions
    , update
    )

--import Lia.Code.Update as Code
--import Lia.Quiz.Update as Quiz
--import Lia.Survey.Update as Survey

import Json.Encode as JE
import Lia.Effect.Update as Effect
import Lia.Quiz.Model
import Lia.Survey.Model
import Lia.Types exposing (Section)


port footnote : (String -> msg) -> Sub msg


type Msg
    = Event String String JE.Value
    | UpdateEffect Bool Effect.Msg
      --    | UpdateCode Code.Msg
      --    | UpdateQuiz Quiz.Msg
      --    | UpdateSurvey Survey.Msg
    | FootnoteHide
    | FootnoteShow String


subscriptions : Section -> Sub Msg
subscriptions section =
    Sub.batch
        [ --Sub.map (UpdateEffect False) (Effect.subscriptions section.effect_model)
          footnote FootnoteShow
        ]


maybeLog : String -> Maybe JE.Value -> Maybe ( String, JE.Value )
maybeLog name value =
    case value of
        Nothing ->
            Nothing

        Just json ->
            Just ( name, json )


update : Msg -> Section -> ( Section, Cmd Msg, Maybe ( String, JE.Value ) )
update msg section =
    case msg of
        UpdateEffect sound childMsg ->
            let
                ( effect_model, cmd, log_ ) =
                    Effect.update sound childMsg section.effect_model
            in
            ( { section | effect_model = effect_model }
            , Cmd.map (UpdateEffect sound) cmd
            , maybeLog "effect" log_
            )

        {-

              UpdateCode childMsg ->
                  let
                      ( code_vector, log ) =
                          Code.update childMsg section.code_vector
                  in
                  ( { section | code_vector = code_vector }, Cmd.none, maybeLog "code" log )

           UpdateQuiz childMsg ->
               let
                   ( quiz_vector, log ) =
                       Quiz.update childMsg section.quiz_vector
               in
               ( { section | quiz_vector = quiz_vector }
               , Cmd.none
               , maybeLog "quiz" log
               )

           UpdateSurvey childMsg ->
               let
                   ( survey_vector, log ) =
                       Survey.update childMsg section.survey_vector
               in
               ( { section | survey_vector = survey_vector }
               , Cmd.none
               , maybeLog "survey" log
               )
        -}
        FootnoteShow key ->
            ( { section | footnote2show = Just key }, Cmd.none, Nothing )

        FootnoteHide ->
            ( { section | footnote2show = Nothing }, Cmd.none, Nothing )

        {-
           Event "code" msg_ json ->
               let
                   ( vector, log_ ) =
                       case msg_ of
                           "restore" ->
                               Code.restore json section.code_vector

                           _ ->
                               Code.jsEventHandler msg json section.code_vector
               in
               ( { section | code_vector = vector }, Cmd.none, maybeLog "code" log_ )
        -}
        Event topic "restore" json ->
            restore <|
                case topic of
                    "quiz" ->
                        { section
                            | quiz_vector =
                                json
                                    |> Lia.Quiz.Model.json2vector
                                    |> Result.withDefault section.quiz_vector
                        }

                    "survey" ->
                        { section
                            | survey_vector =
                                json
                                    |> Lia.Survey.Model.json2vector
                                    |> Result.withDefault section.survey_vector
                        }

                    _ ->
                        section

        _ ->
            ( section, Cmd.none, Nothing )


nextEffect : Bool -> Section -> ( Section, Cmd Msg, Maybe ( String, JE.Value ) )
nextEffect sound =
    update (UpdateEffect sound Effect.next)


previousEffect : Bool -> Section -> ( Section, Cmd Msg, Maybe ( String, JE.Value ) )
previousEffect sound =
    update (UpdateEffect sound Effect.previous)


initEffect : Bool -> Bool -> Section -> ( Section, Cmd Msg, Maybe ( String, JE.Value ) )
initEffect run_all_javascript sound =
    update (UpdateEffect sound (Effect.init run_all_javascript))


log : String -> Maybe JE.Value -> Maybe ( String, JE.Value )
log topic msg =
    case msg of
        Just m ->
            Just ( topic, m )

        _ ->
            Nothing


jsEventHandler : String -> String -> JE.Value -> Section -> ( Section, Cmd Msg, Maybe ( String, JE.Value ) )
jsEventHandler topic msg json =
    update (Event topic msg json)


restore : Section -> ( Section, Cmd Msg, Maybe ( String, JE.Value ) )
restore section =
    ( section, Cmd.none, Nothing )
