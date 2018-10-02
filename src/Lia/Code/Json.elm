module Lia.Code.Json exposing (decoder_result, json2event, json2project, json2vector, vector2json)

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Code.Types exposing (File, Log, Project, Vector, Version, noResult)


json2event : JD.Value -> Result String ( Bool, Int, String, JD.Value )
json2event json =
    JD.decodeValue
        (JD.map4 (,,,)
            (JD.index 0 JD.bool)
            (JD.index 1 JD.int)
            (JD.index 2 JD.string)
            (JD.index 3 JD.value)
        )
        json


vector2json : Vector -> JE.Value
vector2json vector =
    JE.array <| Array.map project2json vector


json2vector : JD.Value -> Result String Vector
json2vector json =
    JD.decodeValue (JD.array json2project) json


project2json : Project -> JE.Value
project2json project =
    JE.object
        [ ( "file", JE.array <| Array.map file2json project.file )
        , ( "version", JE.array <| Array.map version2json project.version )
        , ( "evaluation", JE.string project.evaluation )
        , ( "version_active", JE.int project.version_active )
        , ( "result", result2json project.result )
        ]


json2project : JD.Decoder Project
json2project =
    JD.map7 Project
        (JD.field "file" (JD.array json2file))
        (JD.field "version" (JD.array json2version))
        (JD.field "evaluation" JD.string)
        (JD.field "version_active" JD.int)
        (JD.field "result" json2result)
        (JD.succeed False)
        (JD.succeed Nothing)


file2json : File -> JE.Value
file2json file =
    JE.object
        [ ( "lang", JE.string file.lang )
        , ( "name", JE.string file.name )
        , ( "code", JE.string file.code )
        , ( "visible", JE.bool file.visible )
        , ( "fullscreen", JE.bool file.fullscreen )
        ]


json2file : JD.Decoder File
json2file =
    JD.map5 File
        (JD.field "lang" JD.string)
        (JD.field "name" JD.string)
        (JD.field "code" JD.string)
        (JD.field "visible" JD.bool)
        (JD.field "fullscreen" JD.bool)


version2json : Version -> JE.Value
version2json ( files, result ) =
    JE.object
        [ ( "files", JE.array <| Array.map JE.string files )
        , ( "results", result2json result )
        ]


json2version : JD.Decoder Version
json2version =
    JD.map2 (,)
        (JD.field "files" (JD.array JD.string))
        (JD.field "results" json2result)


result2json : Result Log Log -> JE.Value
result2json result =
    case result of
        Ok msg ->
            log2json True msg

        Err msg ->
            log2json False msg


json2result : JD.Decoder (Result Log Log)
json2result =
    JD.map3 decoder_result
        (JD.field "ok" JD.bool)
        (JD.field "message" JD.string)
        (JD.field "details" JD.value)


log2json : Bool -> Log -> JE.Value
log2json ok log =
    JE.object
        [ ( "ok", JE.bool ok )
        , ( "message", JE.string log.message )
        , ( "details", JE.array log.details )
        ]


decoder_result : Bool -> String -> JD.Value -> Result Log Log
decoder_result ok message details =
    (if ok then
        Ok

     else
        Err
    )
        (json2log message details)


json2log : String -> JD.Value -> Log
json2log message details =
    details
        |> json2details
        |> Log message


json2details : JD.Value -> Array JD.Value
json2details json =
    json
        |> JD.decodeValue (JD.array JD.value)
        |> Result.withDefault Array.empty
