module Lia.Markdown.JavaScript exposing (..)

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
    , inputs : List String
    , counter : Int
    , input : Input
    }


type Type
    = Checkbox_
      --| Color_
    | Date_
      --| DatetimeLocal_
      --| Email_
      --| File_
      --| Hidden_
      --| Image_
      --| Month_
    | Number_
      --| Password_
      --| Radio_
    | Range_



--| Reset_
--| Search_
--| Select_ (List String)
--| Submit_
--| Tel_
--| Text_ -- default
--| Time_
--| Url_
--| Week_


type alias Input =
    { active : Bool
    , value : String
    , default : String
    , type_ : Maybe String
    }


type Msg
    = Click Int
    | Date Int
    | Activate Int
    | Deactivate Int
    | Value Int String


setInput : Parameters -> Input
setInput params =
    let
        value =
            params
                |> Attr.get "value"
                |> Maybe.withDefault ""
    in
    params
        |> Attr.get "input"
        |> Input False value value


none : x -> ( x, Maybe y )
none x =
    ( x, Nothing )


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
            (Attr.isSet "run-once" params)
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
            (setInput params)
        )
        javascript


count : Array JavaScript -> Int
count =
    Array.length >> (+) -1


getVisible : Int -> Array JavaScript -> List ( Int, String )
getVisible visble javascript =
    javascript
        |> getAll identity
        |> List.filterMap
            (\( id, node ) ->
                if node.effect_id == visble then
                    Just ( id, node.script, node.input.value )

                else
                    Nothing
            )
        |> replaceInputs javascript


filterMap : (JavaScript -> Bool) -> (JavaScript -> x) -> Array JavaScript -> List ( Int, x )
filterMap filter map =
    Array.toIndexedList
        >> List.filter (Tuple.second >> filter)
        >> List.map (Tuple.mapSecond map)


replaceInputs : Array JavaScript -> List ( Int, String, String ) -> List ( Int, String )
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


updateChildren : String -> Array JavaScript -> Array JavaScript
updateChildren output =
    Array.map
        (\js ->
            if js.running && List.member output js.inputs then
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
                if not js.running && List.member output js.inputs then
                    Just ( i, js.script, js.input.value )

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
                        if List.member output node.inputs then
                            { node | update = True }

                        else
                            node
                    )

        _ ->
            javascript
