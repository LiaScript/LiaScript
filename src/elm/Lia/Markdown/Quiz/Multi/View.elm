module Lia.Markdown.Quiz.Multi.View exposing (view)

--import Lia.Markdown.Quiz.Matrix.Update exposing (Msg(..))

import Html exposing (Html)
import Html.Attributes as Attr
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Quiz.Multi.Types exposing (Quiz, State)
import Lia.Markdown.Quiz.Multi.Update exposing (Msg(..))


view : Config sub -> Int -> Quiz Inlines -> State -> Html (Msg sub)
view config id quiz state =
    let
        config_ =
            { config | input = state, onInput = Just (onInput config.slide "quiz" id) }
    in
    quiz.elements
        |> List.map (viewer config_)
        |> List.head
        |> Maybe.withDefault []
        |> Html.div [ Attr.class "lia-table-responsive has-thead-sticky has-last-col-sticky" ]
        |> Html.map Script


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
