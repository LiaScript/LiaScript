module Lia.Markdown.Table.View exposing (view)

-- exposing (Msg(..))

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Annotation, Inlines, MultInlines)
import Lia.Markdown.Inline.View exposing (annotation)
import Lia.Markdown.Table.Types exposing (Class(..), Row, State, Table(..), Vector)
import Lia.Markdown.Table.Update as Sub
import Lia.Markdown.Update exposing (Msg(..))


view : (Inlines -> List (Html Msg)) -> Annotation -> Table -> Vector -> Html Msg
view viewer attr table vector =
    case table of
        Unformatted class rows id ->
            let
                state =
                    getState id vector
            in
            state
                |> unformatted viewer rows id
                |> toTable id attr class state.diagram

        Formatted class head format rows id ->
            let
                state =
                    getState id vector
            in
            state
                |> formatted viewer head format rows id
                |> toTable id attr class state.diagram


getState : Int -> Vector -> State
getState id =
    Array.get id >> Maybe.withDefault (State -1 False False)


toTable : Int -> Annotation -> Class -> Bool -> List (Html Msg) -> Html Msg
toTable id attr class diagram body =
    Html.div [ Attr.style "float" "left" ]
        [ Html.div
            [ Attr.class "lia-icon"
            , Attr.style "float" "left"
            , Attr.style "cursor" "pointer"
            , Attr.style "color" "gray"
            , onClick <| UpdateTable <| Sub.Toggle id
            ]
            [ Html.text <|
                if diagram then
                    "list"

                else
                    "bar_chart"
            ]
        , Html.div [] [ Html.table (annotation "lia-table" attr) body ]
        ]


unformatted : (Inlines -> List (Html Msg)) -> List Row -> Int -> State -> List (Html Msg)
unformatted viewer rows id state =
    case sort state rows of
        head :: tail ->
            tail
                |> List.map
                    (List.map (.inlines >> viewer >> Html.td [ Attr.align "left" ])
                        >> Html.tr [ Attr.class "lia-inline lia-table-row" ]
                    )
                |> (::)
                    (head
                        |> view_head1 viewer id state
                        |> Html.tr [ Attr.class "lia-inline lia-table-row" ]
                    )

        [] ->
            []


formatted : (Inlines -> List (Html Msg)) -> MultInlines -> List String -> List Row -> Int -> State -> List (Html Msg)
formatted viewer head format rows id state =
    rows
        |> sort state
        |> List.map
            (List.map2 (\f -> .inlines >> viewer >> Html.td [ Attr.align f ]) format
                >> Html.tr [ Attr.class "lia-inline lia-table-row" ]
            )
        |> (::)
            (head
                |> view_head2 viewer id format state
                |> Html.thead [ Attr.class "lia-inline lia-table-head" ]
            )


get : Int -> List x -> Maybe x
get i list =
    if i == 0 then
        List.head list

    else
        List.tail list
            |> Maybe.withDefault []
            |> get (i - 1)


sort : State -> List Row -> List Row
sort state =
    if state.column /= -1 then
        if state.dir then
            List.sortBy (get state.column >> Maybe.map .string >> Maybe.withDefault "")

        else
            List.sortBy (get state.column >> Maybe.map .string >> Maybe.withDefault "") >> List.reverse

    else
        identity


view_head1 : (Inlines -> List (Html Msg)) -> Int -> State -> Row -> List (Html Msg)
view_head1 viewer id state =
    List.indexedMap
        (\i r ->
            header viewer id "left" state i r.inlines
                |> Html.td [ Attr.align "left" ]
        )


view_head2 : (Inlines -> List (Html Msg)) -> Int -> List String -> State -> List Inlines -> List (Html Msg)
view_head2 viewer id format state =
    List.map2 Tuple.pair format
        >> List.indexedMap
            (\i ( f, r ) ->
                header viewer id f state i r
                    |> Html.th [ Attr.align f, Attr.style "height" "100%" ]
            )


header : (Inlines -> List (Html Msg)) -> Int -> String -> State -> Int -> Inlines -> List (Html Msg)
header viewer id format state i r =
    [ Html.span
        (if format /= "right" then
            [ Attr.style "float" format, Attr.style "height" "100%" ]

         else
            [ Attr.style "height" "100%" ]
        )
        (viewer r)
    , Html.span
        [ Attr.class "lia-icon"
        , Attr.style "float" "right"
        , Attr.style "cursor" "pointer"
        , Attr.style "margin-right" "-17px"
        , Attr.style "margin-top" "-10px"

        --  , Attr.style "height" "100%"
        --  , Attr.style "position" "relative"
        --  , Attr.style "vertical-align" "top"
        , onClick <| UpdateTable <| Sub.Sort id i
        ]
        [ Html.div
            [ Attr.style "height" "6px"
            , Attr.style "color" <|
                if state.column == i && state.dir then
                    "red"

                else
                    "gray"
            ]
            [ Html.text "arrow_drop_up" ]
        , Html.div
            [ Attr.style "height" "6px"
            , Attr.style "color" <|
                if state.column == i && not state.dir then
                    "red"

                else
                    "gray"
            ]
            [ Html.text "arrow_drop_down" ]
        ]
    ]
