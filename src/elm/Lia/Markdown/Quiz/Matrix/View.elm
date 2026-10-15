module Lia.Markdown.Quiz.Matrix.View exposing (view)

import Accessibility.Aria as A11y_Aria
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
    , base : String
    , shuffle : List (Html (Msg sub)) -> List (Html (Msg sub))
    , open : Bool
    , class : Maybe Bool -> String
    , quiz : Quiz
    , state : State
    , partiallySolved : Array Bool
    }
    -> Html (Msg sub)
view { config, base, shuffle, open, class, quiz, state, partiallySolved } =
    Html.div [ Attr.class "lia-table-responsive has-thead-sticky has-last-col-sticky" ]
        [ Html.table [ Attr.class "lia-table lia-survey-matrix is-alternating" ]
            [ header config base quiz.headers
            , state
                |> Array.toList
                |> List.indexedMap (tr base open class partiallySolved)
                |> List.map2 (add_text config) quiz.options
                |> shuffle
                |> Html.tbody [ Attr.class "lia-table__body lia-survey-matrix__body" ]
            ]
        ]


{-| The column headers, every input is labeled by its row and column header
(`base`-row-i and `base`-col-j).
-}
header : Config sub -> String -> List Inlines -> Html (Msg sub)
header config base inlines =
    List.append
        (List.indexedMap (th config base) inlines)
        -- the corner above the statements is no column header
        [ Html.td [ Attr.class "lia-table__header lia-survey-matrix__header" ] [] ]
        |> Html.tr []
        |> List.singleton
        |> Html.thead [ Attr.class "lia-table__head lia-survey-matrix__head" ]


th : Config sub -> String -> Int -> Inlines -> Html (Msg sub)
th config base column =
    viewer config
        >> Html.th
            [ Attr.class "lia-table__header lia-survey-matrix__header"
            , Attr.scope "col"
            , Attr.id (base ++ "-col-" ++ String.fromInt column)
            ]
        >> Html.map Script


tr : String -> Bool -> (Maybe Bool -> String) -> Array Bool -> Int -> Vector.State -> ( List (Html (Msg sub)), ( String, Maybe Bool ) )
tr base open class partiallySolved id state =
    let
        partialSolution =
            Array.get id partiallySolved

        rowID =
            base ++ "-row-" ++ String.fromInt id

        input =
            { base = base
            , rowID = rowID
            , open = open
            , colorClass = class partialSolution
            , invalid = Maybe.map not partialSolution
            , row = id
            }
    in
    ( case state of
        Vector.SingleChoice list ->
            list
                |> List.indexedMap (cell "lia-radio" "radio" input)

        Vector.MultipleChoice list ->
            list
                |> List.indexedMap (cell "lia-checkbox" "checkbox" input)
    , ( rowID, partialSolution )
    )


{-| A radio button or checkbox, radio buttons of one row form a group.
-}
cell :
    String
    -> String
    ->
        { base : String
        , rowID : String
        , open : Bool
        , colorClass : String
        , invalid : Maybe Bool
        , row : Int
        }
    -> Int
    -> Bool
    -> Html (Msg sub)
cell inputClass inputType { base, rowID, open, colorClass, invalid, row } column value =
    Html.td [ Attr.class "lia-table__data lia-survey-matrix__data" ]
        [ Html.input
            [ Attr.class inputClass
            , Attr.class colorClass
            , Attr.type_ inputType
            , Attr.name rowID
            , Attr.checked value
            , A11y_Aria.labelledBy (rowID ++ " " ++ base ++ "-col-" ++ String.fromInt column)
            , invalid
                |> Maybe.map A11y_Aria.invalid
                |> Maybe.withDefault (Attr.class "")
            , if open then
                onClick <| Toggle row column

              else
                Attr.disabled True
            ]
            []
        ]


add_text : Config sub -> Inlines -> ( List (Html (Msg sub)), ( String, Maybe Bool ) ) -> Html (Msg sub)
add_text config inline ( toRow, ( rowID, _ ) ) =
    inline
        |> viewer config
        |> Html.th
            [ Attr.class "lia-table__data lia-survey-matrix__data"
            , Attr.scope "row"
            , Attr.id rowID
            ]
        |> Html.map Script
        |> List.singleton
        |> List.append toRow
        |> Html.tr [ Attr.class "lia-table__row lia-survey-matrix__row" ]
