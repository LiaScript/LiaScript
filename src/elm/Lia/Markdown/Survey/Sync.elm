module Lia.Markdown.Survey.Sync exposing
    ( Data
    , Sync
    , decoder
    , encoder
    , matrix
    , select
    , sync
    , text
    , vector
    , wordCount
    )

import Array
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Survey.Json as Json
import Lia.Markdown.Survey.Types as Survey


type Sync
    = Sync Survey.State


type alias Data =
    { value : String
    , absolute : Int
    , relative : Float
    }


sync : Survey.Element -> Maybe Sync
sync survey =
    if survey.submitted then
        Just (Sync survey.state)

    else
        Nothing


wordCount : List Sync -> Maybe (List Data)
wordCount =
    List.foldl
        (\s ( dict, counter ) ->
            s
                |> toText
                |> Maybe.map (String.trim >> String.toUpper)
                |> Maybe.map
                    (\key ->
                        ( Dict.insert key
                            (dict
                                |> Dict.get key
                                |> Maybe.map ((+) 1)
                                |> Maybe.withDefault 1
                            )
                            dict
                        , counter + 1
                        )
                    )
                |> Maybe.withDefault ( dict, counter )
        )
        ( Dict.empty, 0 )
        >> (\( dict, total ) ->
                dict
                    |> Dict.toList
                    |> List.map (\( key, value ) -> Data key value (percentage total value))
                    |> ifEmpty
           )


text : List Sync -> Maybe (List String)
text =
    List.filterMap toText >> ifEmpty


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


vector : List String -> List Sync -> Maybe (List Data)
vector orderBy list =
    case List.filterMap toVector list of
        [] ->
            Nothing

        data ->
            let
                total =
                    data
                        |> List.length
                        |> toFloat

                union =
                    List.foldl
                        (\v1 v2 ->
                            Dict.merge
                                Dict.insert
                                (\key a b -> Dict.insert key (a + b))
                                Dict.insert
                                v1
                                v2
                                Dict.empty
                        )
                        Dict.empty
                        data
            in
            orderBy
                |> List.foldr
                    (\key result ->
                        (union
                            |> Dict.get key
                            |> Maybe.map (\absolute -> Data key absolute (percentage total absolute))
                            |> Maybe.withDefault (Data key 0 0)
                        )
                            :: result
                    )
                    []
                |> ifEmpty


percentage : Float -> Int -> Float
percentage total i =
    100 * toFloat i / total


toVector : Sync -> Maybe (Dict String Int)
toVector (Sync s) =
    case s of
        Survey.Vector_State _ dict ->
            dict
                |> Dict.map boolToInt
                |> Just

        _ ->
            Nothing


select : Int -> List Sync -> Maybe (List Data)
select maxElements list =
    case List.filterMap toSelect list of
        [] ->
            Nothing

        data ->
            let
                total =
                    data
                        |> List.length
                        |> toFloat
            in
            data
                |> List.foldl
                    (\s array ->
                        case Array.get s array of
                            Just i ->
                                Array.set s (i + 1) array

                            Nothing ->
                                array
                    )
                    (Array.repeat maxElements 0)
                |> Array.indexedMap (\index absolute -> Data (String.fromInt (index + 1)) absolute (percentage total absolute))
                |> Array.toList
                |> ifEmpty


toSelect : Sync -> Maybe Int
toSelect (Sync s) =
    case s of
        Survey.Select_State _ i ->
            Just i

        _ ->
            Nothing


matrix : List String -> List Sync -> Maybe (List (List Data))
matrix orderBy list =
    list
        |> List.filterMap toMatrix
        |> List.foldl
            (\state result ->
                case result of
                    Just collection ->
                        collection
                            |> List.map2 (\s c -> Sync (Survey.Vector_State True s) :: c) state
                            |> Just

                    Nothing ->
                        state
                            |> List.map (Survey.Vector_State True >> Sync >> List.singleton)
                            |> Just
            )
            Nothing
        |> Maybe.map
            (List.map (vector orderBy)
                >> List.map (Maybe.withDefault (List.map (\key -> Data key 0 0) orderBy))
            )


toMatrix : Sync -> Maybe (List (Dict String Bool))
toMatrix (Sync s) =
    case s of
        Survey.Matrix_State _ state ->
            state
                |> Array.toList
                |> Just

        _ ->
            Nothing


boolToInt : String -> Bool -> Int
boolToInt _ v =
    if v then
        1

    else
        0


encoder : Sync -> JE.Value
encoder (Sync state) =
    Json.fromState state


decoder : JD.Decoder Sync
decoder =
    JD.map Sync Json.toState
