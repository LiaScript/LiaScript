module Lia.Markdown.Code.Events exposing
    ( eval
    , flip_view
    , fullscreen
    , input
    , stop
    , store
    , updateActive
    , updateAppend
    , updateVersion
    )

import Array exposing (Array)
import Json.Encode as JE
import Lia.Markdown.Code.Json as Json
import Lia.Markdown.Code.Log as Log
import Lia.Markdown.Code.Sync exposing (Sync)
import Lia.Markdown.Code.Types exposing (File, Project, Repo, Vector)
import Lia.Markdown.Effect.Script.Types exposing (Scripts, outputs)
import Return exposing (Return)
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Script


stop : Int -> Event
stop projectID =
    Service.Script.stop
        |> toProject projectID


input : Int -> String -> Event
input projectID value =
    Service.Script.input value
        |> toProject projectID


eval : Maybe Int -> Array Sync -> Int -> Scripts a -> Project -> Event
eval delay sync projectID scripts project =
    let
        files =
            if project.syncMode then
                sync
                    |> Array.get projectID
                    |> Maybe.withDefault Array.empty

            else
                Array.map .code project.file
    in
    files
        |> Array.toList
        |> Service.Script.eval delay project.evaluation (outputs scripts)
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


updateVersion : Int -> Maybe Int -> Return Project msg sub -> Return Project msg sub
updateVersion projectID sectionID return =
    case sectionID of
        Just section ->
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
                        |> update_ section { cmd = "version", id = projectID }
                    )

        Nothing ->
            return


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


updateActive : Int -> Maybe Int -> Return Project msg sub -> Return Project msg sub
updateActive projectID sectionID return =
    case sectionID of
        Just section ->
            return
                |> Return.batchEvent
                    ([ ( "file", JE.array Json.fromFile return.value.file )
                     , ( "version_active", JE.int return.value.version_active )
                     , ( "log", Log.encode return.value.log )
                     ]
                        |> update_ section { cmd = "active", id = projectID }
                    )

        Nothing ->
            return


flip_view : Maybe Int -> Int -> Int -> File -> List Event
flip_view sectionID projectID fileID file =
    case sectionID of
        Just secID ->
            [ file.visible
                |> toggle fileID
                |> update_ secID { cmd = "flip_view", id = projectID }
            ]

        Nothing ->
            []


fullscreen : Maybe Int -> Int -> Int -> File -> List Event
fullscreen sectionID projectID fileID file =
    case sectionID of
        Just secID ->
            [ file.fullscreen
                |> toggle fileID
                |> update_ secID { cmd = "flip_fullscreen", id = projectID }
            ]

        Nothing ->
            []


toggle : Int -> Bool -> List ( String, JE.Value )
toggle file value =
    [ ( "value", JE.bool value )
    , ( "file_id", JE.int file )
    ]


update_ : Int -> { cmd : String, id : Int } -> List ( String, JE.Value ) -> Event
update_ id cmd =
    JE.object >> Service.Database.update "code" id cmd
