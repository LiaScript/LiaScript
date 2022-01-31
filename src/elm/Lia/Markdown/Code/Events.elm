module Lia.Markdown.Code.Events exposing
    (  eval
       -- TODO:
       -- , evalDecode

    , flip_view
    , fullscreen
    , input
    , load
    , stop
    , store
    , version_append
    , version_update
    )

import Array
import Json.Encode as JE
import Lia.Markdown.Code.Json as Json
import Lia.Markdown.Code.Log as Log
import Lia.Markdown.Code.Types exposing (File, Project, Repo, Vector)
import Lia.Markdown.Effect.Script.Types exposing (Scripts, outputs)
import Return exposing (Return)
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Script as Script


stop : Int -> Event
stop id =
    -- TODO:
    -- Event.initWithId Nothing "stop" id JE.null
    event "stop" JE.null


input : Int -> String -> Event
input id value =
    [ projectID id
    , ( "value", JE.string value )
    ]
        |> JE.object
        |> event "input"


eval : Int -> Scripts a -> Project -> Event
eval id scripts project =
    project.file
        |> Array.map .code
        |> Array.toList
        |> Script.eval project.evaluation (outputs scripts)
        -- navigate the evaluation within the Code module
        |> toProject id


toProject : Int -> Event -> Event
toProject id =
    Event.pushWithId "project" id


store : Maybe Int -> Vector -> List Event
store sectionID model =
    case sectionID of
        Just id ->
            [ model
                |> Json.fromVector
                |> Service.Database.store "code" id
            ]

        Nothing ->
            []



-- TODO:
-- evalDecode : Event -> Eval
-- evalDecode =
--     Event.message >> Eval.decode


version_update : Int -> Return Project msg sub -> Return Project msg sub
version_update id return =
    return
        |> Return.batchEvent
            ([ ( "version_active", JE.int return.value.version_active )
             , ( "log", Log.encode return.value.log )
             , ( "version"
               , case Array.get return.value.version_active return.value.version of
                    Just version ->
                        Json.fromVersion version

                    Nothing ->
                        JE.null
               )
             , projectID id
             ]
                |> JE.object
                |> event "version_update"
            )


version_append : Int -> Project -> Repo -> Event
version_append id project repo_update =
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
    , projectID id
    ]
        |> JE.object
        |> event "version_append"


load : Int -> Return Project msg sub -> Return Project msg sub
load id return =
    return
        |> Return.batchEvent
            ([ ( "file", JE.array Json.fromFile return.value.file )
             , ( "version_active", JE.int return.value.version_active )
             , ( "log", Log.encode return.value.log )
             , projectID id
             ]
                |> JE.object
                |> event "load"
            )


flip_view : Int -> Int -> File -> List Event
flip_view id1 id2 file =
    file.visible
        |> toggle "toggle_view" id1 id2


fullscreen : Int -> Int -> File -> List Event
fullscreen id1 id2 file =
    file.fullscreen
        |> toggle "toggle_fullscreen" id1 id2


toggle : String -> Int -> Int -> Bool -> List Event
toggle cmd project file value =
    [ [ ( "value", JE.bool value )
      , projectID project
      , ( "file_id", JE.int file )
      ]
        |> JE.object
        |> event cmd
    ]


projectID : Int -> ( String, JE.Value )
projectID id =
    ( "project_id", JE.int id )


event : String -> JE.Value -> Event
event cmd param =
    { cmd = cmd, param = param }
        |> Event.init "code"
