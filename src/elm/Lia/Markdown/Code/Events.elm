module Lia.Markdown.Code.Events exposing
    ( eval
    , evalDecode
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
import Port.Eval as Eval exposing (Eval)
import Port.Event as Event exposing (Event)
import Return exposing (Return)


stop : Int -> Event
stop id =
    Event.initWithId Nothing "stop" id JE.null


input : Int -> String -> Event
input id =
    JE.string
        >> Event.initWithId Nothing "input" id


eval : Scripts a -> Int -> Project -> Event
eval scripts idx project =
    project.file
        |> Array.map .code
        |> Array.toList
        |> Eval.event idx project.evaluation (outputs scripts)


store : Vector -> Event
store model =
    model
        |> Json.fromVector
        |> Event.store


evalDecode : Event -> Eval
evalDecode =
    Event.message >> Eval.decode


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
             ]
                |> JE.object
                |> Event.initWithId Nothing "version_update" id
            )


version_append : Int -> Project -> Repo -> Event
version_append id project repo_update =
    Event.initWithId Nothing "version_append" id <|
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


load : Int -> Return Project msg sub -> Return Project msg sub
load id return =
    return
        |> Return.batchEvent
            (Event.initWithId Nothing "load" id <|
                JE.object
                    [ ( "file", JE.array Json.fromFile return.value.file )
                    , ( "version_active", JE.int return.value.version_active )
                    , ( "log", Log.encode return.value.log )
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
        |> Event.initWithId Nothing message id2
        |> Event.pushWithId "flip" id1
    ]
