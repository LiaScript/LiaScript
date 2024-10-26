module Library.Masonry exposing
    ( Masonry
    , empty
    , init
    , append
    , Config
    , view
    , viewList
    , Msg
    , update
    , done
    , Id
    , getHeight
    )

{-| Distribute elements over columns, ordered from left to right while taking
element height into account so all columns are about the same length.


# Create

@docs Masonry
@docs empty
@docs init
@docs append


# View

@docs Config
@docs view
@docs viewList


# Update

@docs Msg
@docs update
@docs done


# Height

Sometimes the element height changes after page initialization, like when it
contains an image for example.

Update the height of an element with `getHeight`.

    type Msg
        = ImageLoaded Masonry.Id

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        case msg of
            ImageLoaded id ->
                ( model
                , Cmd.map MasonryMsg (Masonry.getHeight id)
                )

    viewItem : Masonry.Id -> () -> Html msg
    viewItem id _ =
        img [ on "load" (Decode.succeed (ImageLoaded id)) ] []

@docs Id
@docs getHeight

-}

import Browser.Dom exposing (Element)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed as Keyed
import Task



--  DEFINITIONS


{-| -}
type Masonry a
    = Masonry
        { items : List ( Id, a )
        , heights : Dict String Height
        , id : Maybe String
        }


{-| A unique element `Id`.
-}
type Id
    = Id String


type Height
    = Known Float
    | Average Float


{-| Configure how you want your `Masonry a` to render.
Each element gets rendered by `toView` and `columns` is the amount of columns.

Each element is wrapped in a `div` and rendered with the class
`"elm-masonry-item-height-unknown"`. Once the height is known the class
is updated to `"elm-masonry-item-height-known"`. Because we need the elements
to render in order to measure their height you might see some reordering
happening live in the browser. Set `opacity: 0;` of elements
with an unknown height class if this is bothersome.

-}
type alias Config a msg =
    { toView : Id -> a -> Html msg
    , columns : Int
    , attributes : List (Attribute msg)
    }



--  VIEW


{-| Render `Masonry a` and distribute elements over columns
taking the height of each element into account.
-}
view : Config a msg -> Masonry a -> Html msg
view { columns, toView, attributes } ((Masonry { id }) as masonry) =
    viewColumns attributes toView id (toColumns columns masonry)


{-| Render a `List a` without all the fancy height calculations.

If you know all elements will be about the same height you don't really need
to get each element height and calculate in what order the elements should be
displayed.

This function will just distribute all elements over each column
ordered from left to right regardless of their height.

-}
viewList : Config a msg -> List a -> Html msg
viewList { columns, toView, attributes } =
    viewColumns attributes toView Nothing << toColumns columns << Tuple.first << init Nothing


{-| Masonry has finished rearranging items.
-}
done : Masonry a -> Bool
done (Masonry { heights, items }) =
    let
        missing ( Id id, _ ) =
            case Dict.get id heights of
                Nothing ->
                    True

                Just (Average _) ->
                    True

                Just (Known _) ->
                    False
    in
    if List.isEmpty items then
        False

    else
        not (List.any missing items)



--  INIT


{-| A `Masonry a` containing no items.

If you're rendering multiple `Masonry a` on the same page
provide an id to not get the elements mixed up when getting their height.

    Masonry.empty Nothing

-}
empty : Maybe String -> Masonry a
empty id =
    Masonry
        { items = []
        , heights = Dict.empty
        , id = id
        }


{-| Create a `Masonry a` from `List a` and get each element height.

If you're rendering multiple `Masonry a` on the same page
provide an id to not get the elements mixed up when getting their height.

    Masonry.init (Just "search-results") results

-}
init : Maybe String -> List a -> ( Masonry a, Cmd Msg )
init id xs =
    append xs (empty id)


{-| Append `List a` to an existing `Masonry a` and get each element height.
-}
append : List a -> Masonry a -> ( Masonry a, Cmd Msg )
append xs ((Masonry masonry_) as masonry) =
    let
        height =
            averageHeight masonry

        addedItems =
            addId (List.length masonry_.items) masonry_.id xs
    in
    ( Masonry
        { masonry_
            | items = masonry_.items ++ addedItems
            , heights =
                List.foldl (\( Id id, _ ) acc -> Dict.insert id (Average height) acc)
                    masonry_.heights
                    addedItems
        }
    , Cmd.batch <|
        -- Reverse list on purpose, this gets the height of the
        -- first element first instead of last
        List.foldl ((::) << getHeight << Tuple.first) [] addedItems
    )


averageHeight : Masonry a -> Float
averageHeight (Masonry { heights }) =
    if Dict.isEmpty heights then
        100

    else
        Dict.foldl sumHeight 0 heights


sumHeight : String -> Height -> Float -> Float
sumHeight _ height acc =
    case height of
        Known h ->
            (acc + h) / 2

        _ ->
            acc


{-| Get the height of the element with given `Id`.
-}
getHeight : Id -> Cmd Msg
getHeight ((Id id) as itemId) =
    Task.attempt GotElement <|
        Task.map (Tuple.pair itemId) (Browser.Dom.getElement id)


{-| A message type for the `Masonry a` to update.
-}
type Msg
    = GotElement (Result Browser.Dom.Error ( Id, Element ))


{-| Update `Masonry a`.
-}
update : Msg -> Masonry a -> Masonry a
update msg ((Masonry masonry_) as masonry) =
    case msg of
        GotElement (Err (Browser.Dom.NotFound _)) ->
            masonry

        GotElement (Ok ( Id id, { element } )) ->
            Masonry
                { masonry_
                    | heights = Dict.insert id (Known element.height) masonry_.heights
                }



-- TO COLUMN


type alias Item a =
    { id : Id
    , height : Height
    , data : a
    }


toColumns : Int -> Masonry a -> List (List (Item a))
toColumns columnCount (Masonry masonry) =
    let
        initDict v =
            Dict.fromList <|
                List.map (\columnId -> ( columnId, v )) <|
                    List.range 0 (columnCount - 1)

        columnHeights =
            initDict 0

        columns =
            initDict []
    in
    Dict.foldr (\_ v acc -> List.reverse v :: acc) [] <|
        Tuple.second <|
            List.foldl (insert masonry.heights) ( columnHeights, columns ) masonry.items


insert :
    Dict String Height
    -> ( Id, a )
    -> ( Dict Int Float, Dict Int (List (Item a)) )
    -> ( Dict Int Float, Dict Int (List (Item a)) )
insert heights ( (Id id_) as id, data ) (( columnHeights, columns ) as acc) =
    case Maybe.map2 Tuple.pair (Dict.get id_ heights) (pickColumn columnHeights) of
        Just ( height, columnId ) ->
            ( upsert columnId (heightToFloat height) columnHeights
            , Dict.update columnId (Maybe.map ((::) (Item id height data))) columns
            )

        _ ->
            acc


heightToFloat : Height -> Float
heightToFloat height =
    case height of
        Known h ->
            h

        Average h ->
            h


pickColumn : Dict Int Float -> Maybe Int
pickColumn dict =
    let
        comp id h1 acc =
            case Maybe.map (\( _, h2 ) -> h1 <= h2) acc of
                Just False ->
                    acc

                _ ->
                    Just ( id, h1 )
    in
    Maybe.map Tuple.first <|
        Dict.foldr comp Nothing dict


upsert : Int -> Float -> Dict Int Float -> Dict Int Float
upsert k v dict =
    case Dict.get k dict of
        Nothing ->
            Dict.insert k v dict

        Just v2 ->
            Dict.insert k (v + v2) dict



-- ID HELPERS


addId : Int -> Maybe String -> List a -> List ( Id, a )
addId offset masonryId xs =
    case masonryId of
        Nothing ->
            List.indexedMap (\index x -> ( Id (toStringId (index + offset)), x )) xs

        Just id ->
            List.indexedMap
                (\index x -> ( Id (toStringId (index + offset) ++ "-" ++ id), x ))
                xs


toStringId : Int -> String
toStringId index =
    "elm-masonry-item-" ++ String.fromInt index



-- VIEW HELPERS


viewColumns : List (Attribute msg) -> (Id -> a -> Html msg) -> Maybe String -> List (List (Item a)) -> Html msg
viewColumns attributes toView id columns =
    div (style "display" "flex" :: class "elm-masonry-columns" :: attributes) <|
        List.map (viewColumn toView id) columns


viewColumn : (Id -> a -> Html msg) -> Maybe String -> List (Item a) -> Html msg
viewColumn toView id column =
    Keyed.node "div" [ class "elm-masonry-column" ] <|
        List.map (viewItem toView id) column


viewItem : (Id -> a -> Html msg) -> Maybe String -> Item a -> ( String, Html msg )
viewItem toView masonryId item =
    let
        (Id idString) =
            item.id
    in
    ( idString
    , div
        [ id idString
        , class "elm-masonry-item"
        , class (heightToClass item.height)
        ]
        [ toView item.id item.data ]
    )


heightToClass : Height -> String
heightToClass height =
    case height of
        Known _ ->
            "elm-masonry-item-height-known"

        Average _ ->
            "elm-masonry-item-height-unknown"
