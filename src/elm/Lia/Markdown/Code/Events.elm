module Lia.Markdown.Code.Events exposing (eval, evalDecode, flip_view, fullscreen, input, load, stop, store, version_append, version_update)

import Array
import Json.Encode as JE
import Lia.Event as Event exposing (Event)
import Lia.Markdown.Code.Json as Json
import Lia.Markdown.Code.Log as Log
import Lia.Markdown.Code.Types exposing (File, Project, Repo, Vector)


stop : Int -> List Event
stop idx =
    [ Event "stop" idx JE.null ]


input : Int -> String -> Event
input idx string =
    Event "input" idx <| JE.string string


eval : Int -> Project -> List Event
eval idx project =
    [ project.file
        |> Array.map .code
        |> Array.toList
        |> Event.eval idx project.evaluation
    ]


store : Vector -> Event
store model =
    model
        |> Json.fromVector
        |> Event.store


evalDecode : Event -> Event.Eval
evalDecode event =
    Event.evalDecode event.message


version_update : Int -> Project -> ( Project, List Event )
version_update idx project =
    ( project
    , [ Event "version_update" idx <|
            JE.object
                [ ( "version_active", JE.int project.version_active )
                , ( "log", Log.encode project.log )
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


version_append : Int -> Project -> Repo -> Event
version_append idx project repo_update =
    Event "version_append" idx <|
        JE.object
            [ ( "version_active", JE.int project.version_active )
            , ( "log", Log.encode project.log )
            , ( "file", JE.array Json.fromFile project.file )
            , ( "version"
              , case Array.get (Array.length project.version - 1) project.version of
                    Just version ->
                        Json.fromVersion version

                    Nothing ->
                        JE.null
              )
            , ( "repository", JE.dict identity JE.string repo_update )
            ]


load : Int -> Project -> ( Project, List Event )
load idx project =
    ( project
    , [ Event "load" idx <|
            JE.object
                [ ( "file", JE.array Json.fromFile project.file )
                , ( "version_active", JE.int project.version_active )
                , ( "log", Log.encode project.log )
                ]
      ]
    )


flip_view : Int -> Int -> File -> List Event
flip_view id1 id2 file =
    file.visible
        |> toggle "view" id1 id2


fullscreen : Int -> Int -> File -> List Event
fullscreen id1 id2 file =
    file.fullscreen
        |> toggle "fullscreen" id1 id2


toggle : String -> Int -> Int -> Bool -> List Event
toggle message id1 id2 value =
    [ value
        |> JE.bool
        |> Event message id2
        |> Event.toJson
        |> Event "flip" id1
    ]
