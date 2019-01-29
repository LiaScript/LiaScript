module Lia.Markdown.Code.Event exposing (eval, flip_view, fullscreen, input, load, stop, store, version_append, version_update)

--eval, flip_view, fullscreen, input, load, stop, store, version_append, version_update)

import Array exposing (Array)
import Json.Encode as JE
import Lia.Event as Event exposing (Event)
import Lia.Markdown.Code.Json as Json
import Lia.Markdown.Code.Types exposing (File, Log, Project, Vector, Version, noLog)


eval : Int -> String -> Event
eval idx eval_str =
    --JE.list [ JE.string "eval", JE.int idx, JE.string eval_str ]
    Event "eval" idx <| JE.string eval_str


store : Vector -> Event
store model =
    --JE.list [ JE.list [ JE.string "store", vector2json model ] ]
    Event "store" -1 <| Json.fromVector model


stop : Int -> Event
stop idx =
    --JE.list [ JE.string "stop", JE.int idx, JE.null ]
    Event "stop" idx JE.null


input : Int -> String -> Event
input idx string =
    --JE.list [ JE.string "input", JE.int idx, JE.string string ]
    Event "input" idx <| JE.string string


version_update : Int -> Project -> ( Project, List Event )
version_update idx project =
    --    ( project
    --    , [ JE.list
    --            [ JE.string "version_update"
    --            , JE.int idx
    --            , JE.object
    --                [ ( "version_active", JE.int project.version_active )
    --                , ( "log", Json.fromLog project.log )
    --                , ( "version"
    --                  , case Array.get project.version_active project.version of
    --                        Just version ->
    --                            Json.fromVersion version
    --
    --                        Nothing ->
    --                            JE.null
    --                  )
    --                ]
    --            ]
    --      ]
    --    )
    ( project
    , [ Event "version_update" idx <|
            JE.object
                [ ( "version_active", JE.int project.version_active )
                , ( "log", Json.fromLog project.log )
                , ( "version"
                  , case Array.get project.version_active project.version of
                        Just version ->
                            Json.fromVersion version

                        Nothing ->
                            JE.null
                  )
                ]
      ]
    )


version_append : Int -> Project -> Event
version_append idx project =
    --    JE.list
    --        [ JE.string "version_append"
    --        , JE.int idx
    --        , JE.object
    --            [ ( "version_active", JE.int project.version_active )
    --            , ( "log", Json.fromLog project.log )
    --            , ( "file", JE.array <| Array.map Json.fromFile project.file )
    --            , ( "version"
    --              , case Array.get (Array.length project.version - 1) project.version of
    --                    Just version ->
    --                        Json.fromVersion version
    --
    --                    Nothing ->
    --                        JE.null
    --              )
    --            ]
    --        ]
    Event "version_append" idx <|
        JE.object
            [ ( "version_active", JE.int project.version_active )
            , ( "log", Json.fromLog project.log )
            , ( "file", JE.array Json.fromFile project.file )
            , ( "version"
              , case Array.get (Array.length project.version - 1) project.version of
                    Just version ->
                        Json.fromVersion version

                    Nothing ->
                        JE.null
              )
            ]



--version_push : Int -> Project (Project, List JE.Value)


load : Int -> Project -> ( Project, List Event )
load idx project =
    --    ( project
    --    , [ JE.list
    --            [ JE.string "load"
    --            , JE.int idx
    --            , JE.object
    --                [ ( "file", JE.array <| Array.map Json.fromFile project.file )
    --                , ( "version_active", JE.int project.version_active )
    --                , ( "log", Json.fromLog project.log )
    --                ]
    --            ]
    --      ]
    --    )
    ( project
    , [ Event "load" idx <|
            JE.object
                [ ( "file", JE.array Json.fromFile project.file )
                , ( "version_active", JE.int project.version_active )
                , ( "log", Json.fromLog project.log )
                ]
      ]
    )


flip_view : Int -> Int -> Bool -> Event
flip_view id1 id2 b =
    --    JE.list
    --        [ JE.list
    --            [ JE.string "flip_view"
    --            , JE.int id1
    --            , JE.int id2
    --            , JE.bool b
    --            ]
    --        ]
    JE.bool b
        |> Event "view" id2
        |> Event.toJson
        |> Event "flip" id2


fullscreen : Int -> Int -> Bool -> Event
fullscreen id1 id2 b =
    --JE.list
    --    [ JE.list
    --        [ JE.string "fullscreen"
    --        , JE.int id1
    --        , JE.int id2
    --        , JE.bool b
    --        ]
    --    ]
    JE.bool b
        |> Event "fullscreen" id2
        |> Event.toJson
        |> Event "flip" id2
