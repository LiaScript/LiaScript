module Lia.Code.Event exposing (eval, flip_view, fullscreen, input, load, stop, store, version_append, version_update)

import Array exposing (Array)
import Json.Encode as JE
import Lia.Code.Json exposing (file2json, log2json, vector2json, version2json)
import Lia.Code.Types exposing (File, Log, Project, Vector, Version, noLog)


eval : Int -> String -> JE.Value
eval idx eval_str =
    JE.list [ JE.string "eval", JE.int idx, JE.string eval_str ]


store : Vector -> JE.Value
store model =
    JE.list [ JE.list [ JE.string "store", vector2json model ] ]


stop : Int -> JE.Value
stop idx =
    JE.list [ JE.string "stop", JE.int idx, JE.null ]


input : Int -> String -> JE.Value
input idx string =
    JE.list [ JE.string "input", JE.int idx, JE.string string ]


version_update : Int -> Project -> ( Project, List JE.Value )
version_update idx project =
    ( project
    , [ JE.list
            [ JE.string "version_update"
            , JE.int idx
            , JE.object
                [ ( "version_active", JE.int project.version_active )
                , ( "log", log2json project.log )
                , ( "version"
                  , case Array.get project.version_active project.version of
                        Just version ->
                            version2json version

                        Nothing ->
                            JE.null
                  )
                ]
            ]
      ]
    )


version_append : Int -> Project -> JE.Value
version_append idx project =
    JE.list
        [ JE.string "version_append"
        , JE.int idx
        , JE.object
            [ ( "version_active", JE.int project.version_active )
            , ( "log", log2json project.log )
            , ( "file", JE.array <| Array.map file2json project.file )
            , ( "version"
              , case Array.get (Array.length project.version - 1) project.version of
                    Just version ->
                        version2json version

                    Nothing ->
                        JE.null
              )
            ]
        ]



--version_push : Int -> Project (Project, List JE.Value)


load : Int -> Project -> ( Project, List JE.Value )
load idx project =
    ( project
    , [ JE.list
            [ JE.string "load"
            , JE.int idx
            , JE.object
                [ ( "file", JE.array <| Array.map file2json project.file )
                , ( "version_active", JE.int project.version_active )
                , ( "log", log2json project.log )
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
