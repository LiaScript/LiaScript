module Lia.Markdown.Quiz.Multi.View exposing (view)

import Array exposing (Array)
import I18n.Translations exposing (Lang(..))
import Json.Encode as JE
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Block.Types exposing (State(..))
import Lia.Markdown.Quiz.Multi.Types exposing (Quiz, State)
import List.Extra


view :
    { config : Config sub
    , id : Int
    , active : Bool
    , partiallyCorrect : Array Bool
    , quiz : Quiz x Inlines
    , state : State
    , randomize : Maybe (List Int)
    }
    -> ( Config sub, Maybe x )
view { config, id, active, partiallyCorrect, quiz, state, randomize } =
    let
        input =
            config.input

        path =
            List.append input.path [ ( "quiz", config.slide ), ( "input", id ) ]
    in
    ( { config
        | input =
            { state = state
            , options = quiz.options
            , randomize =
                case randomize of
                    Just list ->
                        quiz.options
                            |> Array.foldl
                                (\opt ( start, array ) ->
                                    ( start + List.length opt
                                    , Array.push
                                        (List.Extra.splitAt start list
                                            |> Tuple.second
                                            |> List.Extra.splitAt (List.length opt)
                                            |> Tuple.first
                                        )
                                        array
                                    )
                                )
                                ( 0, Array.empty )
                            |> Tuple.second
                            |> Just

                    _ ->
                        Nothing
            , on = onInput path
            , path = path
            , active = active
            , partiallyCorrect = partiallyCorrect
            }
      }
    , List.head quiz.elements
    )


onInput : List ( String, Int ) -> String -> Int -> String -> String
onInput path cmd id2 param =
    "window.LIA.send({reply: true, track: "
        ++ (path
                |> JE.list (\( s, i ) -> JE.list identity [ JE.string s, JE.int i ])
                |> JE.encode 0
           )
        ++ ", service: 'input', message: { cmd: '"
        ++ cmd
        ++ "', param: {id: "
        ++ String.fromInt id2
        ++ ", value: "
        ++ param
        ++ "}}})"
