module Lia.Markdown.Effect.JavaScript exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Markdown.HTML.Attributes as Attr exposing (Parameters)
import Port.Eval as Eval exposing (Eval)
import Regex


type alias JavaScript =
    { effect_id : Int
    , script : String
    , running : Bool
    , update : Bool
    , runOnce : Bool
    , result : Maybe (Result String String)
    , output : Maybe String
    , input : List String
    , counter : Int
    }


input : Regex.Regex
input =
    Maybe.withDefault Regex.never <|
        Regex.fromString "@input\\(`([^`]+)`\\)"


push : Int -> Parameters -> String -> Array JavaScript -> Array JavaScript
push id params script javascript =
    Array.push
        (JavaScript id
            script
            False
            False
            (Attr.isSet "data-run-once" params)
            (params
                |> Attr.get "data-default"
                |> Maybe.map Ok
            )
            (params
                |> Attr.get "data-output"
            )
            (script
                |> Regex.find input
                |> List.map .submatches
                |> List.concat
                |> List.filterMap identity
            )
            0
        )
        javascript


setRunning : Int -> Bool -> Array JavaScript -> Array JavaScript
setRunning id state javascript =
    set id (\js -> { js | running = state }) javascript


count : Array JavaScript -> Int
count =
    Array.length >> (+) -1


getVisible : Int -> Array JavaScript -> List ( Int, String )
getVisible visble javascript =
    javascript
        |> getAll identity
        |> List.filter (Tuple.second >> .effect_id >> (==) visble)
        |> List.map (Tuple.mapSecond .script)
        |> replaceInputs javascript


filterMap : (JavaScript -> Bool) -> (JavaScript -> x) -> Array JavaScript -> List ( Int, x )
filterMap filter map =
    Array.toIndexedList
        >> List.filter (Tuple.second >> filter)
        >> List.map (Tuple.mapSecond map)


replaceInputs : Array JavaScript -> List ( Int, String ) -> List ( Int, String )
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
    List.map (Tuple.mapSecond (\s -> List.foldl Eval.replace_input s inputs))


updateChildren : String -> Array JavaScript -> Array JavaScript
updateChildren output =
    Array.map
        (\js ->
            if js.running && List.member output js.input then
                { js | update = True }

            else
                js
        )


scriptChildren : String -> Array JavaScript -> List ( Int, String )
scriptChildren output javascript =
    javascript
        |> Array.toIndexedList
        |> List.filterMap
            (\( i, js ) ->
                if not js.running && List.member output js.input then
                    Just ( i, js.script )

                else
                    Nothing
            )
        |> replaceInputs javascript


getAll : (JavaScript -> x) -> Array JavaScript -> List ( Int, x )
getAll =
    filterMap
        (\js ->
            not js.running || not (js.runOnce && js.counter == 1)
        )


get : (JavaScript -> x) -> Int -> Array JavaScript -> Maybe x
get fn id =
    Array.get id >> Maybe.map fn


getResult : Int -> Array JavaScript -> Maybe String
getResult id =
    get .result id
        >> Maybe.withDefault Nothing
        >> Maybe.andThen Result.toMaybe


set : Int -> (JavaScript -> JavaScript) -> Array JavaScript -> Array JavaScript
set idx fn javascript =
    case Array.get idx javascript of
        Just js ->
            Array.set idx (fn js) javascript

        _ ->
            javascript


update : Int -> Eval -> Array JavaScript -> Array JavaScript
update id e =
    set id (eval_ e)


eval_ : Eval -> JavaScript -> JavaScript
eval_ e js =
    { js
        | running = e.result == "\"LIA: wait\""
        , counter = js.counter + 1
        , result =
            if
                e.result
                    == "\"LIA: stop\""
                    || e.result
                    == "\"LIA: wait\""
            then
                js.result

            else if e.ok then
                Just (Ok e.result)

            else
                Just (Err e.result)
    }


setResult : Int -> Array JavaScript -> String -> Array JavaScript
setResult id javascript result =
    set id (\js -> { js | result = Just (Ok result) }) javascript


publish : Int -> Array JavaScript -> Array JavaScript
publish id javascript =
    case Array.get id javascript |> Maybe.andThen .output of
        Just output ->
            javascript
                |> Array.map
                    (\node ->
                        if List.member output node.input then
                            { node | update = True }

                        else
                            node
                    )

        _ ->
            javascript
