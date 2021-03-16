module Lia.Markdown.Quiz.Vector.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Quiz.Vector.Types exposing (Quiz, State(..))
import Lia.Markdown.Quiz.Vector.Update exposing (Msg(..))


view : Config sub -> Bool -> String -> Quiz -> State -> List (Html (Msg sub))
view config solved class quiz state =
    case ( quiz.solution, state ) of
        ( SingleChoice _, SingleChoice list ) ->
            table (radio config solved class) quiz.options list

        ( MultipleChoice _, MultipleChoice list ) ->
            table (check config solved class) quiz.options list

        _ ->
            []


table : (Bool -> ( Int, Inlines ) -> Html (Msg sub)) -> List Inlines -> List Bool -> List (Html (Msg sub))
table fn inlines bools =
    inlines
        |> List.indexedMap Tuple.pair
        |> List.map2 fn bools


check : Config sub -> Bool -> String -> Bool -> ( Int, Inlines ) -> Html (Msg sub)
check config solved colorClass checked ( id, line ) =
    Html.label [ Attr.class "lia-label" ]
        [ Html.input
            [ Attr.class "lia-checkbox"
            , Attr.class colorClass
            , Attr.type_ "checkbox"
            , Attr.checked checked
            , if solved then
                Attr.disabled True

              else
                onClick (Toggle id)
            ]
            []
        , line
            |> viewer config
            |> Html.span []
            |> Html.map Script
        ]


radio : Config sub -> Bool -> String -> Bool -> ( Int, Inlines ) -> Html (Msg sub)
radio config solved colorClass checked ( id, line ) =
    Html.label [ Attr.class "lia-label" ]
        [ Html.input
            [ Attr.class "lia-radio"
            , Attr.class colorClass
            , Attr.type_ "radio"
            , Attr.checked checked
            , if solved then
                Attr.disabled True

              else
                onClick (Toggle id)
            ]
            []
        , line
            |> viewer config
            |> Html.span []
            |> Html.map Script
        ]
