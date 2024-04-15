module Lia.Markdown.Effect.Script.Types exposing
    ( Msg(..)
    , Script
    , Scripts
    , Stdout(..)
    , count
    , filterMap
    , get
    , isError
    , outputs
    , push
    , replaceInputs
    , scriptChildren
    , set
    , text
    , updateChildren
    )

import Array exposing (Array)
import Lia.Markdown.Effect.Script.Input as Input exposing (Input)
import Lia.Markdown.Effect.Script.Intl as Intl exposing (Intl)
import Lia.Markdown.HTML.Attributes as Attr exposing (Parameters)
import Regex
import Service.Event exposing (Event)
import Service.Script


type alias Scripts a =
    Array (Script a)


type Stdout a
    = Error String
    | Text String
    | HTML String
    | IFrame a


type Msg sub
    = Click Int
    | Reset Int
    | Execute Int String
    | Activate Bool Int
    | Value Int Bool String
    | Radio Int Bool String
    | Checkbox Int Bool String
    | Edit Bool Int
    | EditCode Int String
    | NoOp
    | Handle Event
    | Delay Float (Msg sub)
    | Sub Int sub


isError : Stdout a -> Bool
isError stdout =
    case stdout of
        Error _ ->
            True

        _ ->
            False


text : Stdout a -> Maybe String
text stdout =
    case stdout of
        Text str ->
            Just str

        _ ->
            Nothing


type alias Script a =
    { effect_id : Int
    , script : String
    , updated : Bool -- use this for preventing closing
    , running : Bool
    , block : Bool -- this indicates script execution is triggered by an external handler
    , update : Bool
    , runOnce : Bool
    , modify : Bool
    , edit : Bool
    , result : Maybe (Stdout a)
    , output : Maybe String
    , inputs : List String
    , counter : Int
    , input : Input
    , intl : Maybe Intl
    , worker : Bool
    }


input : Regex.Regex
input =
    Maybe.withDefault Regex.never <|
        Regex.fromString "@input\\(`([^`]+)`\\)"


push : String -> Int -> Parameters -> String -> Scripts a -> Scripts a
push lang id params script javascript =
    Array.push
        { effect_id = id
        , script = script
        , updated = False -- use this for preventing closing
        , running = False
        , block = Attr.isSet "block" params
        , update = False
        , runOnce = Attr.isSet "run-once" params
        , modify = Attr.isNotSet "modify" params
        , edit = False
        , result =
            params
                |> Attr.get "default"
                |> Maybe.map Text
        , output = Attr.get "output" params
        , inputs =
            script
                |> Regex.find input
                |> List.concatMap .submatches
                |> List.filterMap identity
        , counter = 0
        , input = Input.from params
        , intl = Intl.from lang params
        , worker = Attr.isSet "worker" params
        }
        javascript


count : Scripts a -> Int
count =
    Array.length >> (+) -1


filterMap : (Script a -> Bool) -> (Script a -> x) -> Scripts a -> List ( Int, x )
filterMap filter map =
    Array.toIndexedList
        >> List.filter (Tuple.second >> filter)
        >> List.map (Tuple.mapSecond map)


outputs : Scripts a -> List ( String, String )
outputs =
    Array.toList
        >> List.filterMap
            (\js ->
                case ( js.output, js.result ) of
                    ( Just output, Just (Text result) ) ->
                        Just ( output, result )

                    _ ->
                        Nothing
            )


replaceInputs : Scripts a -> List { id : Int, worker : Bool, script : String, input_ : Maybe String } -> List ( Int, Bool, String )
replaceInputs javascript =
    let
        inputs =
            outputs javascript
    in
    List.map
        (\{ id, worker, script, input_ } ->
            ( id
            , worker
            , inputs
                |> List.foldl Service.Script.replace_inputKey script
                |> (\code ->
                        case input_ of
                            Just str ->
                                Service.Script.replace_input str code

                            Nothing ->
                                code
                   )
            )
        )


updateChildren : String -> Scripts a -> Scripts a
updateChildren output =
    Array.map
        (\js ->
            if js.running && List.member output js.inputs then
                { js | update = True }

            else
                js
        )


scriptChildren : String -> Scripts a -> List ( Int, Bool, String )
scriptChildren output javascript =
    javascript
        |> Array.toIndexedList
        |> List.filterMap
            (\( i, js ) ->
                if not js.running && not js.block && List.member output js.inputs then
                    Just
                        { id = i
                        , worker = js.worker
                        , script = js.script
                        , input_ = Input.getValue js.input
                        }

                else
                    Nothing
            )
        |> replaceInputs javascript


get : (Script a -> x) -> Int -> Scripts a -> Maybe x
get fn id =
    Array.get id >> Maybe.map fn


set : Int -> (Script a -> Script a) -> Scripts a -> Scripts a
set idx fn javascript =
    case Array.get idx javascript of
        Just js ->
            Array.set idx (fn js) javascript

        _ ->
            javascript
