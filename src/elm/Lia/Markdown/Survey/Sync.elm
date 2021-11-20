module Lia.Markdown.Survey.Sync exposing
    ( Sync
    , decoder
    , encoder
    , select
    , sync
    , text
    , vector
    , wordCount
    )

import Array exposing (Array)
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Survey.Json as Json
import Lia.Markdown.Survey.Types as Survey


type Sync
    = Sync Survey.State


sync : Survey.Element -> Maybe Sync
sync survey =
    if survey.submitted then
        Just (Sync survey.state)

    else
        Nothing


wordCount : List Sync -> Maybe (List ( String, Int ))
wordCount =
    List.foldl
        (\s dict ->
            s
                |> toText
                |> Maybe.map (String.trim >> String.toUpper)
                |> Maybe.map
                    (\key ->
                        Dict.insert key
                            (dict
                                |> Dict.get key
                                |> Maybe.map ((+) 1)
                                |> Maybe.withDefault 1
                            )
                            dict
                    )
                |> Maybe.withDefault dict
        )
        Dict.empty
        >> Dict.toList
        >> ifEmpty


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


vector : List String -> List Sync -> Maybe (List ( String, Float ))
vector orderBy list =
    let
        data =
            List.filterMap toVector list

        total =
            List.length data |> toFloat

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
            (\o result ->
                ( o
                , Dict.get o union
                    |> Maybe.map (percentage total)
                    |> Maybe.withDefault 0
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
                |> Dict.map
                    (\_ v ->
                        if v then
                            1

                        else
                            0
                    )
                |> Just

        _ ->
            Nothing


select : Int -> List Sync -> Maybe (List Float)
select maxElements list =
    let
        data =
            List.filterMap toSelect list

        total =
            List.length data |> toFloat
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
        |> Array.map (percentage total)
        |> Array.toList
        |> ifEmpty


toSelect : Sync -> Maybe Int
toSelect (Sync s) =
    case s of
        Survey.Select_State _ i ->
            Just i

        _ ->
            Nothing


toMatrix : Sync -> Maybe (Array (Dict String Int))
toMatrix (Sync s) =
    case s of
        Survey.Matrix_State _ matrix ->
            matrix
                |> Array.map
                    (Dict.map
                        (\_ v ->
                            if v then
                                1

                            else
                                0
                        )
                    )
                |> Just

        _ ->
            Nothing


encoder : Sync -> JE.Value
encoder (Sync state) =
    Json.fromState state


decoder : JD.Decoder Sync
decoder =
    JD.map Sync Json.toState
