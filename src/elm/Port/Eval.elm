module Port.Eval exposing
    ( Eval
    , decode
    , decoder
    , encode
    , event
    , replace_0
    , replace_id
    , replace_input
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Utils exposing (toEscapeString, toJSstring)
import Port.Event exposing (Event)


type alias Eval =
    { ok : Bool
    , result : String
    , details : List JE.Value
    }


event : Int -> String -> List ( String, String ) -> List String -> Event
event id code scripts inputs =
    let
        default =
            inputs
                |> List.head
                |> Maybe.withDefault ""
                |> toJSstring

        code_ =
            scripts
                |> List.foldl replace_input code
    in
    inputs
        |> List.indexedMap (\i r -> ( i, toJSstring r ))
        |> List.foldl replace_id code_
        |> replace_0 default
        |> JE.string
        |> Event "eval" id


replace_0 : String -> String -> String
replace_0 replacement =
    String.replace "@'input" (toEscapeString replacement)
        >> String.replace "@input" replacement


replace_id : ( Int, String ) -> String -> String
replace_id ( id, insert ) =
    String.replace ("@'input(" ++ String.fromInt id ++ ")") (toEscapeString insert)
        >> String.replace ("@input(" ++ String.fromInt id ++ ")") insert


replace_input : ( String, String ) -> String -> String
replace_input ( key, insert ) =
    String.replace ("@'input(`" ++ key ++ "`)") (toEscapeString insert)
        >> String.replace ("@input(`" ++ key ++ "`)") insert


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
