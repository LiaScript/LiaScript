module Lia.Markdown.Quiz.Matrix.View exposing (view)

import Accessibility.Role as A11y_Role
import Accessibility.Widget as A11y_Widget
import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Quiz.Matrix.Types exposing (Quiz, State)
import Lia.Markdown.Quiz.Matrix.Update exposing (Msg(..))
import Lia.Markdown.Quiz.Vector.Types as Vector


view :
    { config : Config sub
    , shuffle : List (Html (Msg sub)) -> List (Html (Msg sub))
    , open : Bool
    , class : Maybe Bool -> String
    , quiz : Quiz
    , state : State
    , partiallySolved : Array Bool
    }
    -> Html (Msg sub)
view { config, shuffle, open, class, quiz, state, partiallySolved } =
    Html.div [ Attr.class "lia-table-responsive has-thead-sticky has-last-col-sticky" ]
        [ Html.table [ Attr.class "lia-table lia-survey-matrix is-alternating" ]
            [ header config quiz.headers
            , state
                |> Array.toList
                |> List.indexedMap (tr open class partiallySolved)
                |> List.map2 (add_text config) quiz.options
                |> shuffle
                |> Html.tbody [ Attr.class "lia-table__body lia-survey-matrix__body" ]
            ]
        ]


header : Config sub -> List Inlines -> Html (Msg sub)
header config inlines =
    List.append (List.map (th config) inlines) [ Html.th [ Attr.class "lia-table__header lia-survey-matrix__header" ] [] ]
        |> Html.thead [ Attr.class "lia-table__head lia-survey-matrix__head" ]


th : Config sub -> Inlines -> Html (Msg sub)
th config =
    viewer config
        >> Html.th [ Attr.class "lia-table__header lia-survey-matrix__header", A11y_Role.columnHeader ]
        >> Html.map Script


tr : Bool -> (Maybe Bool -> String) -> Array Bool -> Int -> Vector.State -> ( List (Html (Msg sub)), Maybe Bool )
tr open class partiallySolved id state =
    let
        partialSolution =
            Array.get id partiallySolved
    in
    ( case state of
        Vector.SingleChoice list ->
            list
                |> List.indexedMap (radio open (class partialSolution) id)

        Vector.MultipleChoice list ->
            list
                |> List.indexedMap (check open (class partialSolution) id)
    , partialSolution
    )


radio : Bool -> String -> Int -> Int -> Bool -> Html (Msg sub)
radio open colorClass row_id column_id value =
    Html.td [ Attr.class "lia-table__data lia-survey-matrix__data" ]
        [ Html.input
            [ Attr.class "lia-radio"
            , Attr.class colorClass
            , Attr.type_ "radio"
            , Attr.checked value
            , A11y_Widget.label "Matrix quiz answer"
            , A11y_Role.radio
            , if open then
                onClick <| Toggle row_id column_id

              else
                Attr.disabled True
            ]
            []
        ]


check : Bool -> String -> Int -> Int -> Bool -> Html (Msg sub)
check open colorClass row_id column_id value =
    Html.td [ Attr.class "lia-table__data lia-survey-matrix__data" ]
        [ Html.input
            [ Attr.class "lia-checkbox"
            , Attr.class colorClass
            , Attr.type_ "checkbox"
            , Attr.checked value
            , A11y_Widget.label "Matrix quiz answer"
            , A11y_Role.checkBox
            , if open then
                onClick <| Toggle row_id column_id

              else
                Attr.disabled True
            ]
            []
        ]


add_text : Config sub -> Inlines -> ( List (Html (Msg sub)), Maybe Bool ) -> Html (Msg sub)
add_text config inline ( toRow, partiallySolved ) =
    inline
        |> viewer config
        |> Html.td [ Attr.class "lia-table__data lia-survey-matrix__data" ]
        |> Html.map Script
        |> List.singleton
        |> List.append toRow
        |> Html.tr
            [ Attr.class "lia-table__row lia-survey-matrix__row"
            , case partiallySolved of
                Nothing ->
                    Attr.class ""

                Just True ->
                    A11y_Widget.invalid False

                Just False ->
                    A11y_Widget.invalid True
            , A11y_Role.rowHeader
            ]
