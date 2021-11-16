module Lia.Markdown.Survey.Sync exposing
    ( Sync
    , decoder
    , encoder
    , sync
    , text
    , vector
    )

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


vector : List Sync -> Maybe (List ( String, Float ))
vector list =
    let
        data =
            List.filterMap toVector list

        total =
            List.length data |> toFloat
    in
    data
        |> List.foldl
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
        |> Dict.toList
        |> List.map (Tuple.mapSecond (\i -> 100 * toFloat i / total))
        |> ifEmpty


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


encoder : Sync -> JE.Value
encoder (Sync state) =
    Json.fromState state


decoder : JD.Decoder Sync
decoder =
    JD.map Sync Json.toState
