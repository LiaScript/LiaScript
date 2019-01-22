module Lia.Code.Json exposing
    ( file2json
    ,  json2details
       --  , json2event

    , json2project
    , json2vector
    , log2json
    , merge
    , vector2json
    , version2json
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Code.Types exposing (File, Log, Project, Vector, Version, noLog)


merge : Vector -> Vector -> Vector
merge old new =
    new
        |> Array.toList
        |> List.map2 copy_evaluation (Array.toList old)
        |> Array.fromList


copy_evaluation : Project -> Project -> Project
copy_evaluation old new =
    { new | evaluation = old.evaluation }



{- todo

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
-}


vector2json : Vector -> JE.Value
vector2json vector =
    JE.array project2json vector


json2vector : JD.Value -> Result JD.Error (Maybe Vector)
json2vector json =
    JD.decodeValue (JD.nullable (JD.array json2project)) json


project2json : Project -> JE.Value
project2json project =
    JE.object
        [ ( "file", JE.array file2json project.file )
        , ( "version", JE.array version2json project.version )

        --, ( "evaluation", JE.string project.evaluation )
        , ( "version_active", JE.int project.version_active )
        , ( "log", log2json project.log )
        ]


json2project : JD.Decoder Project
json2project =
    JD.map7 Project
        (JD.field "file" (JD.array json2file))
        (JD.field "version" (JD.array json2version))
        --(JD.field "evaluation" JD.string)
        (JD.succeed "")
        (JD.field "version_active" JD.int)
        (JD.field "log" json2log)
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
version2json ( files, log ) =
    JE.object
        [ ( "files", JE.array JE.string files )
        , ( "log", log2json log )
        ]


json2version : JD.Decoder Version
json2version =
    JD.map2 Tuple.pair
        (JD.field "files" (JD.array JD.string))
        (JD.field "log" json2log)


json2log : JD.Decoder Log
json2log =
    JD.map3 Log
        (JD.field "ok" JD.bool)
        (JD.field "message" JD.string)
        (JD.field "details" (JD.array JD.value))


log2json : Log -> JE.Value
log2json log =
    {- JE.object
       [ ( "ok", JE.bool log.ok )
       , ( "message", JE.string log.message )
       , ( "details", JE.array JD.value log.details )
       ]
    -}
    JE.object
        [ ( "ok", JE.bool log.ok )
        , ( "message", JE.string log.message )
        , ( "details", JE.null )
        ]


json2details : JD.Value -> Array JD.Value
json2details json =
    json
        |> JD.decodeValue (JD.array JD.value)
        |> Result.withDefault Array.empty
