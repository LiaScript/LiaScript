module Lia.Markdown.Code.Events exposing
    ( eval
    , flip_view
    , fullscreen
    , input
    , load
    , stop
    , store
    , updateAppend
    , updateVersion
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
import Service.Script


stop : Int -> Event
stop id =
    -- TODO:
    -- Event.initWithId Nothing "stop" id JE.null
    event "stop" JE.null


input : Int -> String -> Event
input id value =
    [ --projectID id
      ( "value", JE.string value )
    ]
        |> JE.object
        |> event "input"


eval : Int -> Scripts a -> Project -> Event
eval projectID scripts project =
    project.file
        |> Array.map .code
        |> Array.toList
        |> Service.Script.eval project.evaluation (outputs scripts)
        -- navigate the evaluation within the Code module
        |> toProject projectID


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


updateVersion : Int -> Int -> Return Project msg sub -> Return Project msg sub
updateVersion projectID sectionID return =
    return
        |> Return.batchEvent
            ([ ( "version_active"
               , JE.int return.value.version_active
               )
             , ( "log"
               , Log.encode return.value.log
               )
             , ( "version"
               , return.value.version
                    |> Array.get return.value.version_active
                    |> Maybe.map Json.fromVersion
                    |> Maybe.withDefault JE.null
               )
             ]
                |> update_ sectionID { cmd = "version", id = projectID }
            )


updateAppend : Int -> Project -> Repo -> Int -> Event
updateAppend projectID project repo_update sectionID =
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
        |> update_ sectionID { cmd = "append", id = projectID }


load : Int -> Return Project msg sub -> Return Project msg sub
load id return =
    return
        |> Return.batchEvent
            ([ ( "file", JE.array Json.fromFile return.value.file )
             , ( "version_active", JE.int return.value.version_active )
             , ( "log", Log.encode return.value.log )

             --, projectID id
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
toggle cmd projectID file value =
    [ [ ( "value", JE.bool value )

      --, projectID project
      , ( "file_id", JE.int file )
      ]
        |> JE.object
        |> event cmd
    ]



--projectID : Int -> ( String, JE.Value )
--projectID id =
-- ( "project_id", JE.int id )


event : String -> JE.Value -> Event
event cmd param =
    { cmd = cmd, param = param }
        |> Event.init "code"


update_ : Int -> { cmd : String, id : Int } -> List ( String, JE.Value ) -> Event
update_ id cmd =
    JE.object >> Service.Database.update "code" id cmd
