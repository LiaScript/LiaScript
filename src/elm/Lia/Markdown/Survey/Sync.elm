module Lia.Markdown.Survey.Sync exposing
    ( Data
    , Sync
    , decoder
    , encoder
    , event
    , lockAnswered
    , matrix
    , select
    , sync
    , toString
    , toText
    , vector
    , wordCount
    )

{-| Sharing survey answers within a classroom and summarizing the answers of
all peers for the diagrams and tables of `Survey.View`.
-}

import Array
import Dict exposing (Dict)
import Helper.Array as Array
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Survey.Json as Json
import Lia.Markdown.Survey.Types as Survey
import Lia.Sync.Container as Container exposing (Container)
import Lia.Utils exposing (percentage)
import List.Extra
import Service.Event as Event exposing (Event)
import Service.Sync


{-| The submitted answer of a peer.
-}
type Sync
    = Sync Survey.State


{-| A summarized answer: how many peers chose it (`absolute`) and the share in
percent (`relative`).
-}
type alias Data =
    { value : String
    , absolute : Int
    , relative : Float
    }


{-| Only submitted surveys are shared.
-}
sync : Survey.Element -> Maybe Sync
sync survey =
    if survey.submitted then
        Just (Sync survey.state)

    else
        Nothing


{-| The event that shares the answer of survey `id`, `Event.none` if it is not
submitted.
-}
event : Int -> Survey.Element -> Event
event id =
    sync
        >> Maybe.map (encoder >> Service.Sync.survey id)
        >> Maybe.withDefault Event.none


{-| A survey submitted from another session/device (or synced faster than a
local restore) is already known to the classroom. Lock it here too
(restoring the submitted answer), so it can't be silently re-answered and
overwrite the shared classroom state.
-}
lockAnswered :
    Maybe String
    -> Dict Int (Container Sync)
    -> Maybe Int
    -> Survey.Vector
    -> Survey.Vector
lockAnswered ownId answered sectionID vec =
    case ( sectionID, ownId ) of
        ( Just sID, Just myId ) ->
            case Dict.get sID answered of
                Just container ->
                    Array.indexedMap
                        (\idx elem ->
                            if elem.submitted then
                                elem

                            else
                                case Container.get idx container |> Maybe.andThen (Dict.get myId) of
                                    Just (Sync state) ->
                                        { elem | submitted = True, state = state }

                                    Nothing ->
                                        elem
                        )
                        vec

                Nothing ->
                    vec

        _ ->
            vec


{-| Count the comma-separated words of all text answers, case-insensitive.
-}
wordCount : List Sync -> Maybe (List Data)
wordCount list =
    let
        words =
            list
                |> List.filterMap toText
                |> List.concatMap (String.toUpper >> String.split "," >> List.map String.trim)

        total =
            toFloat (List.length words)
    in
    words
        |> List.foldl (\word -> Dict.update word (Maybe.withDefault 0 >> (+) 1 >> Just)) Dict.empty
        |> Dict.toList
        |> List.map (\( word, absolute ) -> Data word absolute (percentage total absolute))
        |> ifEmpty


{-| The text of a text answer.
-}
toText : Sync -> Maybe String
toText (Sync s) =
    case s of
        Survey.Text_State str ->
            Just str

        _ ->
            Nothing


ifEmpty : List x -> Maybe (List x)
ifEmpty list =
    if List.isEmpty list then
        Nothing

    else
        Just list


{-| How often every option (the ids in `orderBy`) of a vector was chosen.
-}
vector : List String -> List Sync -> Maybe (List Data)
vector orderBy =
    List.filterMap toVector >> summarize orderBy


{-| **private:** Count the checked variables in `orderBy`, `Nothing` if there
are no answers.
-}
summarize : List String -> List (Dict String Bool) -> Maybe (List Data)
summarize orderBy answers =
    if List.isEmpty answers then
        Nothing

    else
        let
            total =
                toFloat (List.length answers)
        in
        orderBy
            |> List.map
                (\key ->
                    let
                        absolute =
                            answers
                                |> List.filter (Dict.get key >> (==) (Just True))
                                |> List.length
                    in
                    Data key absolute (percentage total absolute)
                )
            |> ifEmpty


toVector : Sync -> Maybe (Dict String Bool)
toVector (Sync s) =
    case s of
        Survey.Vector_State _ dict ->
            Just dict

        _ ->
            Nothing


{-| The answer of a peer as cells of the details table, `keys` are the ids of
the options (vector and matrix).
-}
toString : List String -> Sync -> List String
toString keys (Sync s) =
    case s of
        Survey.Vector_State False dict ->
            keys
                |> List.filterMap (\key -> Dict.get key dict)
                |> List.map
                    (\value ->
                        if value then
                            "🗹"

                        else
                            ""
                    )

        Survey.Vector_State True dict ->
            keys
                |> List.filterMap (\key -> Dict.get key dict)
                |> List.map checkbox

        Survey.Text_State str ->
            [ str ]

        Survey.Select_State _ i ->
            [ String.fromInt (i + 1) ]

        Survey.DragAndDrop_State _ _ i ->
            [ String.fromInt (i + 1) ]

        Survey.Matrix_State _ state ->
            state
                |> Array.toList
                |> List.concatMap
                    (\dict ->
                        List.map
                            (\key ->
                                Dict.get key dict
                                    |> Maybe.map checkbox
                                    |> Maybe.withDefault ""
                            )
                            keys
                    )


checkbox : Bool -> String
checkbox value =
    if value then
        "🗹"

    else
        "☐"


{-| How often every option (`1` to `maxElements`) of a select or drop survey
was chosen.
-}
select : Int -> List Sync -> Maybe (List Data)
select maxElements list =
    case List.filterMap toSelect list of
        [] ->
            Nothing

        data ->
            let
                total =
                    toFloat (List.length data)
            in
            data
                |> List.foldl (\i -> Array.update i ((+) 1)) (Array.repeat maxElements 0)
                |> Array.toIndexedList
                |> List.map (\( i, absolute ) -> Data (String.fromInt (i + 1)) absolute (percentage total absolute))
                |> ifEmpty


toSelect : Sync -> Maybe Int
toSelect (Sync s) =
    case s of
        Survey.Select_State _ i ->
            Just i

        Survey.DragAndDrop_State _ _ i ->
            Just i

        _ ->
            Nothing


{-| How often every option (the ids in `orderBy`) was chosen per row of a
matrix, as one list of rows per option. If the peers have different numbers
of rows, only the common rows are counted.
-}
matrix : List String -> List Sync -> Maybe (List (List Data))
matrix orderBy list =
    case List.filterMap toMatrix list of
        [] ->
            Nothing

        first :: rest ->
            rest
                |> List.foldl (List.map2 (::)) (List.map List.singleton first)
                |> List.map (summarize orderBy >> Maybe.withDefault [])
                |> List.Extra.transpose
                |> Just


toMatrix : Sync -> Maybe (List (Dict String Bool))
toMatrix (Sync s) =
    case s of
        Survey.Matrix_State _ state ->
            Just (Array.toList state)

        _ ->
            Nothing


{-| -}
encoder : Sync -> JE.Value
encoder (Sync state) =
    Json.fromState state


{-| -}
decoder : JD.Decoder Sync
decoder =
    JD.map Sync Json.toState
