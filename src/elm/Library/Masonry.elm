module Library.Masonry exposing
    ( Masonry, Id, empty, init, map
    , Msg, update
    , Config, view
    )

{-| Distribute elements over columns, ordered from left to right while taking
element height into account so all columns are about the same length. Each
element goes into the currently shortest column, until its height is measured
it counts as 100 pixels.

@docs Masonry, Id, empty, init, map
@docs Msg, update
@docs Config, view

-}

import Browser.Dom exposing (Element)
import Dict exposing (Dict)
import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (class, id, style)
import Html.Keyed as Keyed
import Task


{-| Items with their ids and the measured heights.
-}
type Masonry a
    = Masonry
        { items : List ( Id, a )
        , heights : Dict String Float
        }


{-| A unique element `Id`, also used as the HTML id of its wrapper.
-}
type Id
    = Id String


{-| Each element gets rendered by `toView`, `columns` is the amount of columns.

Each element is wrapped in a `div` with the class
`"elm-masonry-item-height-unknown"`, once its height is known the class
changes to `"elm-masonry-item-height-known"`.

-}
type alias Config a msg =
    { toView : Id -> a -> Html msg
    , columns : Int
    , attributes : List (Attribute msg)
    }


{-| A `Masonry a` containing no items.
-}
empty : Masonry a
empty =
    Masonry { items = [], heights = Dict.empty }


{-| Create a `Masonry a` from `List a` and measure each element. Ids are
`elm-masonry-item-<index>` plus `-<id>` if an id is given, so that multiple
masonries on one page do not get mixed up.
-}
init : Maybe String -> List a -> ( Masonry a, Cmd Msg )
init masonryId xs =
    let
        items =
            List.indexedMap
                (\index x ->
                    ( Id
                        ("elm-masonry-item-"
                            ++ String.fromInt index
                            ++ (masonryId |> Maybe.map ((++) "-") |> Maybe.withDefault "")
                        )
                    , x
                    )
                )
                xs
    in
    ( Masonry { items = items, heights = Dict.empty }
    , items
        -- reversed on purpose, this gets the height of the first element first
        |> List.reverse
        |> List.map (Tuple.first >> getHeight)
        |> Cmd.batch
    )


{-| Change all items, their heights are kept.
-}
map : (a -> a) -> Masonry a -> Masonry a
map f (Masonry masonry) =
    Masonry { masonry | items = List.map (Tuple.mapSecond f) masonry.items }


getHeight : Id -> Cmd Msg
getHeight ((Id id) as itemId) =
    Browser.Dom.getElement id
        |> Task.map (Tuple.pair itemId)
        |> Task.attempt GotElement


{-| The measured height of an element.
-}
type Msg
    = GotElement (Result Browser.Dom.Error ( Id, Element ))


{-| Store a measured height.
-}
update : Msg -> Masonry a -> Masonry a
update msg (Masonry masonry) =
    case msg of
        GotElement (Ok ( Id id, { element } )) ->
            Masonry { masonry | heights = Dict.insert id element.height masonry.heights }

        GotElement (Err _) ->
            Masonry masonry


{-| Render the columns.
-}
view : Config a msg -> Masonry a -> Html msg
view { columns, toView, attributes } (Masonry { items, heights }) =
    let
        maxWidth =
            style "max-width" (String.fromFloat (100 / toFloat columns) ++ "%")

        viewItem ( (Id idString) as itemId, data ) =
            ( idString
            , div
                [ id idString
                , class "elm-masonry-item"
                , class <|
                    if Dict.member idString heights then
                        "elm-masonry-item-height-known"

                    else
                        "elm-masonry-item-height-unknown"
                ]
                [ toView itemId data ]
            )
    in
    items
        |> List.foldl (place heights) (List.repeat columns ( 0, [] ))
        |> List.map (Tuple.second >> List.reverse >> List.map viewItem >> Keyed.node "div" [ class "elm-masonry-column", maxWidth ])
        |> div (style "display" "flex" :: class "elm-masonry-columns" :: attributes)


{-| **@private:** Put the item into the shortest column (the first one on ties).
Columns are pairs of their height and their items in reverse order.
-}
place : Dict String Float -> ( Id, a ) -> List ( Float, List ( Id, a ) ) -> List ( Float, List ( Id, a ) )
place heights (( Id id, _ ) as item) columns =
    let
        shortest =
            columns
                |> List.indexedMap (\i ( height, _ ) -> ( height, i ))
                |> List.minimum
                |> Maybe.map Tuple.second
    in
    List.indexedMap
        (\i ( height, column ) ->
            if Just i == shortest then
                ( Dict.get id heights |> Maybe.withDefault 100 |> (+) height, item :: column )

            else
                ( height, column )
        )
        columns
