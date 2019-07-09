module Lia.Event.Eval exposing
    ( Eval
    , decode
    , decoder
    , encode
    , event
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Event.Base as Event exposing (Event)
import Lia.Utils exposing (toJSstring)


type alias Eval =
    { ok : Bool
    , result : String
    , details : List JE.Value
    }


event : Int -> String -> List String -> Event
event id code replacement =
    let
        replacement_0 =
            replacement
                |> List.head
                |> Maybe.withDefault ""
                |> toJSstring
    in
    replacement
        |> List.indexedMap (\i r -> ( i, toJSstring r ))
        |> List.foldl replace_input code
        |> String.replace "@input" replacement_0
        |> JE.string
        |> Event "eval" id


replace_input : ( Int, String ) -> String -> String
replace_input ( int, insert ) into =
    String.replace ("@input(" ++ String.fromInt int ++ ")") insert into


decoder : JD.Decoder Eval
decoder =
    JD.map3 Eval
        (JD.field "ok" JD.bool)
        (JD.field "result" JD.string)
        (JD.field "details" (JD.list JD.value))


decode : JD.Value -> Eval
decode json =
    case JD.decodeValue decoder json of
        Ok result ->
            result

        Err info ->
            Eval False (JD.errorToString info) []


encode : Eval -> JE.Value
encode { ok, result, details } =
    JE.object
        [ ( "ok", JE.bool ok )
        , ( "result", JE.string result )
        , ( "details", JE.list identity details )
        ]
