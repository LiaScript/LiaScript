module Lia.Markdown.Effect.Script.Types exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Markdown.Effect.Script.Input as Input exposing (Input)
import Lia.Markdown.Effect.Script.Intl as Intl exposing (Intl)
import Lia.Markdown.HTML.Attributes as Attr exposing (Parameters)
import Port.Eval as Eval exposing (Eval)
import Regex


type alias Scripts =
    Array Script


type alias Script =
    { effect_id : Int
    , script : String
    , updated : Bool -- use this for preventing closing
    , running : Bool
    , update : Bool
    , runOnce : Bool
    , modify : Bool
    , edit : Bool
    , result : Maybe (Result String String)
    , output : Maybe String
    , inputs : List String
    , counter : Int
    , input : Input
    , intl : Maybe Intl
    }


input : Regex.Regex
input =
    Maybe.withDefault Regex.never <|
        Regex.fromString "@input\\(`([^`]+)`\\)"


push : Int -> Parameters -> String -> Array Script -> Array Script
push id params script javascript =
    Array.push
        (Script id
            script
            False
            False
            False
            (Attr.isSet "run-once" params)
            (Attr.isNotSet "modify" params)
            False
            (params
                |> Attr.get "default"
                |> Maybe.map Ok
            )
            (params
                |> Attr.get "output"
            )
            (script
                |> Regex.find input
                |> List.map .submatches
                |> List.concat
                |> List.filterMap identity
            )
            0
            (Input.from params)
            (Intl.from params)
        )
        javascript


setRunning : Int -> Bool -> Array Script -> Array Script
setRunning id state javascript =
    set id (\js -> { js | running = state }) javascript


count : Array Script -> Int
count =
    Array.length >> (+) -1


filterMap : (Script -> Bool) -> (Script -> x) -> Array Script -> List ( Int, x )
filterMap filter map =
    Array.toIndexedList
        >> List.filter (Tuple.second >> filter)
        >> List.map (Tuple.mapSecond map)


replaceInputs : Array Script -> List ( Int, String, String ) -> List ( Int, String )
replaceInputs javascript =
    let
        inputs =
            javascript
                |> Array.toList
                |> List.filterMap
                    (\js ->
                        case ( js.output, js.result ) of
                            ( Just output, Just (Ok result) ) ->
                                Just ( output, result )

                            _ ->
                                Nothing
                    )
    in
    List.map
        (\( id, script, input_ ) ->
            ( id
            , inputs
                |> List.foldl Eval.replace_input script
                |> Eval.replace_0 input_
            )
        )


updateChildren : String -> Array Script -> Array Script
updateChildren output =
    Array.map
        (\js ->
            if js.running && List.member output js.inputs then
                { js | update = True }

            else
                js
        )


scriptChildren : String -> Array Script -> List ( Int, String )
scriptChildren output javascript =
    javascript
        |> Array.toIndexedList
        |> List.filterMap
            (\( i, js ) ->
                if not js.running && List.member output js.inputs then
                    Just ( i, js.script, js.input.value )

                else
                    Nothing
            )
        |> replaceInputs javascript


get : (Script -> x) -> Int -> Array Script -> Maybe x
get fn id =
    Array.get id >> Maybe.map fn


getResult : Int -> Array Script -> Maybe String
getResult id =
    get .result id
        >> Maybe.withDefault Nothing
        >> Maybe.andThen Result.toMaybe


set : Int -> (Script -> Script) -> Array Script -> Array Script
set idx fn javascript =
    case Array.get idx javascript of
        Just js ->
            Array.set idx (fn js) javascript

        _ ->
            javascript


setResult : Int -> Array Script -> String -> Array Script
setResult id javascript result =
    set id (\js -> { js | result = Just (Ok result) }) javascript


publish : Int -> Array Script -> Array Script
publish id javascript =
    case Array.get id javascript |> Maybe.andThen .output of
        Just output ->
            javascript
                |> Array.map
                    (\node ->
                        if List.member output node.inputs then
                            { node | update = True }

                        else
                            node
                    )

        _ ->
            javascript
