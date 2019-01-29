module Lia.Markdown.Code.Json exposing
    ( fromFile
    , fromVector
    , fromVersion
    , merge
    , toDetails
    , toProject
    , toVector
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Event as Event
import Lia.Markdown.Code.Types exposing (File, Project, Vector, Version, noLog)


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


fromVector : Vector -> JE.Value
fromVector vector =
    JE.array fromProject vector


toVector : JD.Value -> Result JD.Error (Maybe Vector)
toVector json =
    JD.decodeValue (JD.nullable (JD.array toProject)) json


fromProject : Project -> JE.Value
fromProject project =
    JE.object
        [ ( "file", JE.array fromFile project.file )
        , ( "version", JE.array fromVersion project.version )

        --, ( "evaluation", JE.string project.evaluation )
        , ( "version_active", JE.int project.version_active )
        , ( "log", Event.evalEncode project.log )
        ]


toProject : JD.Decoder Project
toProject =
    JD.map7 Project
        (JD.field "file" (JD.array toFile))
        (JD.field "version" (JD.array toVersion))
        --(JD.field "evaluation" JD.string)
        (JD.succeed "")
        (JD.field "version_active" JD.int)
        (JD.field "log" Event.evalDecoder)
        (JD.succeed False)
        (JD.succeed Nothing)


fromFile : File -> JE.Value
fromFile file =
    JE.object
        [ ( "lang", JE.string file.lang )
        , ( "name", JE.string file.name )
        , ( "code", JE.string file.code )
        , ( "visible", JE.bool file.visible )
        , ( "fullscreen", JE.bool file.fullscreen )
        ]


toFile : JD.Decoder File
toFile =
    JD.map5 File
        (JD.field "lang" JD.string)
        (JD.field "name" JD.string)
        (JD.field "code" JD.string)
        (JD.field "visible" JD.bool)
        (JD.field "fullscreen" JD.bool)


fromVersion : Version -> JE.Value
fromVersion ( files, log ) =
    JE.object
        [ ( "files", JE.array JE.string files )
        , ( "log", Event.evalEncode log )
        ]


toVersion : JD.Decoder Version
toVersion =
    JD.map2 Tuple.pair
        (JD.field "files" (JD.array JD.string))
        (JD.field "log" Event.evalDecoder)


toDetails : JD.Value -> Array JD.Value
toDetails json =
    json
        |> JD.decodeValue (JD.array JD.value)
        |> Result.withDefault Array.empty
