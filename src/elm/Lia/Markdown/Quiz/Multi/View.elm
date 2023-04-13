module Lia.Markdown.Quiz.Multi.View exposing (view)

import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Multi.Types exposing (Quiz, State)
import Lia.Markdown.Quiz.Multi.Update exposing (Msg(..))


view : Config sub -> Int -> Bool -> Quiz x Inlines -> State -> ( Config sub, Maybe x )
view config id active quiz state =
    ( { config
        | input =
            { state = state
            , options = quiz.options
            , on = onInput config.slide "quiz" id
            , active = active
            }
      }
    , quiz.elements
        |> List.head
    )


onInput : Int -> String -> Int -> String -> Int -> String -> String
onInput slide type_ id1 cmd id2 param =
    "window.LIA.send({reply: true, track: [['"
        ++ type_
        ++ "', "
        ++ String.fromInt slide
        ++ "], ['input', "
        ++ String.fromInt id1
        ++ "]], service: 'input', message: { cmd: '"
        ++ cmd
        ++ "', param: {id: "
        ++ String.fromInt id2
        ++ ", value: "
        ++ param
        ++ "}}})"
