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

{-| Events sent to JavaScript: running code (`Script` service, tracked by
`("project", id)`) and storing projects in the database. Database events
need a section id, within subsections (`Nothing`) nothing gets stored.
-}

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
    toProject projectID Service.Script.stop


{-| Send a line typed into the terminal to the running program.
-}
input : Int -> String -> Event
input projectID value =
    toProject projectID (Service.Script.input value)


{-| Run the project's code, in `syncMode` the classroom's version of it.
-}
eval : Array Sync -> Int -> Scripts a -> Project -> Event
eval sync projectID scripts project =
    (if project.syncMode then
        sync
            |> Array.get projectID
            |> Maybe.withDefault Array.empty

     else
        Array.map .code project.file
    )
        |> Array.toList
        |> Service.Script.eval project.evaluation (outputs scripts)
        |> toProject projectID


toProject : Int -> Event -> Event
toProject =
    Event.pushWithId "project"


{-| Store all executable projects of a section.
-}
store : Maybe Int -> Vector -> List Event
store sectionID model =
    case sectionID of
        Just id ->
            [ Service.Database.store "code" id (Json.fromVector model) ]

        Nothing ->
            []


{-| Store the active version and its log.
-}
updateVersion : Int -> Maybe Int -> Return Project msg sub -> Return Project msg sub
updateVersion projectID sectionID return =
    batch sectionID
        { cmd = "version", id = projectID }
        [ ( "version_active", JE.int return.value.version_active )
        , ( "log", Log.encode return.value.log )
        , ( "version"
          , return.value.version
                |> Array.get return.value.version_active
                |> Maybe.map Json.fromVersion
                |> Maybe.withDefault JE.null
          )
        ]
        return


{-| Store a newly appended version with the new repository entries.
-}
updateAppend : Int -> Project -> Repo -> Int -> Event
updateAppend projectID project repo_update sectionID =
    [ ( "version_active", JE.int project.version_active )
    , ( "log", Log.encode project.log )
    , ( "file", JE.array Json.fromFile project.file )
    , ( "version"
      , project.version
            |> Array.get (Array.length project.version - 1)
            |> Maybe.map Json.fromVersion
            |> Maybe.withDefault JE.null
      )
    , ( "repository", JE.dict identity JE.string repo_update )
    ]
        |> update_ sectionID { cmd = "append", id = projectID }


{-| Store the files and log after another version was loaded.
-}
updateActive : Int -> Maybe Int -> Return Project msg sub -> Return Project msg sub
updateActive projectID sectionID return =
    batch sectionID
        { cmd = "active", id = projectID }
        [ ( "file", JE.array Json.fromFile return.value.file )
        , ( "version_active", JE.int return.value.version_active )
        , ( "log", Log.encode return.value.log )
        ]
        return


{-| Store the toggled visibility of a file (`file` is the new state).
-}
flip_view : Maybe Int -> Int -> Int -> File -> List Event
flip_view sectionID projectID fileID file =
    toggle sectionID "flip_view" projectID fileID file.visible


{-| Store the toggled fullscreen state of a file (`file` is the new state).
-}
fullscreen : Maybe Int -> Int -> Int -> File -> List Event
fullscreen sectionID projectID fileID file =
    toggle sectionID "flip_fullscreen" projectID fileID file.fullscreen


toggle : Maybe Int -> String -> Int -> Int -> Bool -> List Event
toggle sectionID cmd projectID fileID value =
    case sectionID of
        Just id ->
            [ update_ id
                { cmd = cmd, id = projectID }
                [ ( "value", JE.bool value )
                , ( "file_id", JE.int fileID )
                ]
            ]

        Nothing ->
            []


batch : Maybe Int -> { cmd : String, id : Int } -> List ( String, JE.Value ) -> Return Project msg sub -> Return Project msg sub
batch sectionID cmd fields return =
    case sectionID of
        Just id ->
            Return.batchEvent (update_ id cmd fields) return

        Nothing ->
            return


update_ : Int -> { cmd : String, id : Int } -> List ( String, JE.Value ) -> Event
update_ id cmd =
    JE.object >> Service.Database.update "code" id cmd
