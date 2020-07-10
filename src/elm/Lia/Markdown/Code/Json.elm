module Lia.Markdown.Code.Json exposing
    ( fromFile
    , fromVector
    , fromVersion
    , merge
    , toVector
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Code.Log as Log
import Lia.Markdown.Code.Types exposing (File, Project, Repo, Vector, Version)
import Lia.Markdown.HTML.Attributes exposing (Parameters)


merge : Vector -> Vector -> Vector
merge old new =
    new
        |> Array.toList
        |> List.map2 copy (Array.toList old)
        |> Array.fromList


copy : Project -> Project -> Project
copy old new =
    { new | evaluation = old.evaluation }


fromVector : Vector -> JE.Value
fromVector vector =
    JE.array fromProject vector


toVector : JD.Value -> List (List Parameters) -> Result JD.Error (Maybe Vector)
toVector json attrs =
    json
        |> JD.decodeValue (JD.nullable (JD.array toProject))
        |> Result.map
            (Maybe.map
                (Array.toList
                    >> List.map2 (\a p -> p a) attrs
                    >> Array.fromList
                )
            )


fromProject : Project -> JE.Value
fromProject p =
    JE.object
        [ ( "file", JE.array fromFile p.file )
        , ( "version", JE.array fromVersion p.version )
        , ( "version_active", JE.int p.version_active )
        , ( "log", Log.encode p.log )
        , ( "repository", JE.dict identity JE.string p.repository )
        , ( "compact_view", JE.bool p.compact_view )
        ]


project :
    Array File
    -> Array Version
    -> Int
    -> Log.Log
    -> Repo
    -> Bool
    -> (List Parameters -> Project)
project files version active log repository compact =
    Project files -1 version active repository "" log False Nothing compact


toProject : JD.Decoder (List Parameters -> Project)
toProject =
    JD.map6 project
        (JD.field "file" (JD.array toFile))
        (JD.field "version" (JD.array toVersion))
        (JD.field "version_active" JD.int)
        (JD.field "log" Log.decoder)
        (JD.field "repository" (JD.dict JD.string))
        (JD.field "compact_view" JD.bool)


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
fromVersion ( hashes, log ) =
    JE.object
        [ ( "hashes", JE.list JE.string hashes )
        , ( "log", Log.encode log )
        ]


toVersion : JD.Decoder Version
toVersion =
    JD.map2 Tuple.pair
        (JD.field "hashes" (JD.list JD.string))
        (JD.field "log" Log.decoder)
