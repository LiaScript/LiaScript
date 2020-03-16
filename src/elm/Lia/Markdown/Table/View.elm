module Lia.Markdown.Table.View exposing (view)

-- exposing (Msg(..))

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Annotation, Inlines, MultInlines)
import Lia.Markdown.Inline.View exposing (annotation)
import Lia.Markdown.Table.Types exposing (Table(..), Vector)
import Lia.Markdown.Table.Update as Sub
import Lia.Markdown.Update exposing (Msg(..))


view : (Inlines -> List (Html Msg)) -> Annotation -> Table -> Vector -> Html Msg
view viewer attr table vector =
    Html.table (annotation "lia-table" attr) <|
        case table of
            Unformatted rows id ->
                Array.get id vector
                    |> Maybe.withDefault ( -1, False )
                    |> unformatted viewer rows id

            Formatted head format rows id ->
                Array.get id vector
                    |> Maybe.withDefault ( -1, False )
                    |> formatted viewer head format rows id


unformatted : (Inlines -> List (Html Msg)) -> List MultInlines -> Int -> ( Int, Bool ) -> List (Html Msg)
unformatted viewer rows id order =
    case sort order rows of
        [] ->
            []

        head :: tail ->
            tail
                |> List.map
                    (List.map (viewer >> Html.td [ Attr.align "left" ])
                        >> Html.tr [ Attr.class "lia-inline lia-table-row" ]
                    )
                |> (::)
                    (head
                        |> view_head1 viewer id order
                        |> Html.tr [ Attr.class "lia-inline lia-table-row" ]
                    )


formatted : (Inlines -> List (Html Msg)) -> MultInlines -> List String -> List MultInlines -> Int -> ( Int, Bool ) -> List (Html Msg)
formatted viewer head format rows id order =
    rows
        |> sort order
        |> List.map
            (List.map2 (\f -> viewer >> Html.td [ Attr.align f ]) format
                >> Html.tr [ Attr.class "lia-inline lia-table-row" ]
            )
        |> (::)
            (head
                |> view_head2 viewer id format order
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


sort : ( Int, Bool ) -> List MultInlines -> List MultInlines
sort ( column, dir ) =
    if column /= -1 then
        if dir then
            List.sortBy (get column >> Maybe.map stringify >> Maybe.withDefault "")

        else
            List.sortBy (get column >> Maybe.map stringify >> Maybe.withDefault "") >> List.reverse

    else
        identity


view_head1 : (Inlines -> List (Html Msg)) -> Int -> ( Int, Bool ) -> List Inlines -> List (Html Msg)
view_head1 viewer id order =
    List.indexedMap
        (\i r ->
            header viewer id "left" order i r
                |> Html.td [ Attr.align "left" ]
        )


view_head2 : (Inlines -> List (Html Msg)) -> Int -> List String -> ( Int, Bool ) -> List Inlines -> List (Html Msg)
view_head2 viewer id format order =
    List.map2 Tuple.pair format
        >> List.indexedMap
            (\i ( f, r ) ->
                header viewer id f order i r
                    |> Html.th [ Attr.align f, Attr.style "height" "100%" ]
            )


header : (Inlines -> List (Html Msg)) -> Int -> String -> ( Int, Bool ) -> Int -> Inlines -> List (Html Msg)
header viewer id format ( column, dir ) i r =
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
                if column == i && dir then
                    "red"

                else
                    "gray"
            ]
            [ Html.text "arrow_drop_up" ]
        , Html.div
            [ Attr.style "height" "6px"
            , Attr.style "color" <|
                if column == i && not dir then
                    "red"

                else
                    "gray"
            ]
            [ Html.text "arrow_drop_down" ]
        ]
    ]
