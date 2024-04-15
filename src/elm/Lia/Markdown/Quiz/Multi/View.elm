module Lia.Markdown.Quiz.Multi.View exposing (view)

import Array exposing (Array)
import Json.Encode as JE
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Multi.Types exposing (Quiz, State)
import Lia.Markdown.Quiz.Multi.Update exposing (Msg(..))


view : { config : Config sub, id : Int, active : Bool, partiallyCorrect : Array Bool, quiz : Quiz x Inlines, state : State } -> ( Config sub, Maybe x )
view { config, id, active, partiallyCorrect, quiz, state } =
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
            , on = onInput path
            , path = path
            , active = active
            , partiallyCorrect = partiallyCorrect
            }
      }
    , quiz.elements
        |> List.head
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
