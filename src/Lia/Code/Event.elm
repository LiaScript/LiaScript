module Lia.Code.Event exposing (eval, flip_view, fullscreen, load, stdin, store, version_update)

import Array exposing (Array)
import Json.Encode as JE
import Lia.Code.Json exposing (file2json, result2json, vector2json, version2json)
import Lia.Code.Types exposing (File, Log, Project, Vector, Version, noResult)


eval : Int -> String -> JE.Value
eval idx eval_str =
    JE.list [ JE.string "eval", JE.int idx, JE.string eval_str ]


store : Vector -> JE.Value
store model =
    JE.list [ JE.string "store", vector2json model ]


stdin : Int -> String -> JE.Value
stdin idx string =
    JE.list [ JE.string "stdin", JE.int idx, JE.string string ]


version_update : Int -> Project -> ( Project, List JE.Value )
version_update idx project =
    ( project
    , [ JE.list
            [ JE.string "version_update"
            , JE.int idx
            , JE.object
                [ ( "version_active", JE.int project.version_active )
                , ( "result", result2json project.result )
                ]
            ]
      ]
    )


load : Int -> Project -> ( Project, List JE.Value )
load idx project =
    ( project
    , [ JE.list
            [ JE.string "load"
            , JE.int idx
            , JE.object
                [ ( "file", JE.array <| Array.map file2json project.file )
                , ( "version_active", JE.int project.version_active )
                , ( "result", result2json project.result )
                ]
            ]
      ]
    )


flip_view : Int -> Int -> Bool -> JE.Value
flip_view id1 id2 b =
    JE.list
        [ JE.list
            [ JE.string "flip_view"
            , JE.int id1
            , JE.int id2
            , JE.bool b
            ]
        ]


fullscreen : Int -> Int -> Bool -> JE.Value
fullscreen id1 id2 b =
    JE.list
        [ JE.list
            [ JE.string "fullscreen"
            , JE.int id1
            , JE.int id2
            , JE.bool b
            ]
        ]
