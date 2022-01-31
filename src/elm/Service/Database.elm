module Service.Database exposing
    ( index_delete
    , index_get
    , index_list
    , index_reset
    , index_restore
    , index_store
    , load
    , settings
    , store
    , update
    )

import Index.Version
import Json.Encode as JE
import Lia.Json.Encode as Json
import Lia.Model
import Service.Event as Event exposing (Event)


{-| Load a specific record from the backend service in charge.
-}
load : String -> Int -> Event
load table id =
    Nothing
        |> record table id
        |> event "load"


store : String -> Int -> JE.Value -> Event
store table id data =
    Just data
        |> record table id
        |> event "store"


{-| This event-type contains different instructions on how to update certain
entries. The `sub` command is currently only used to update specific elements
within the "code" table. The `sub.id` is required to only target one specific
element within the state-arrays, that are stored per slide ...
-}
update : String -> Int -> { cmd : String, id : Int } -> JE.Value -> Event
update table id sub data =
    [ ( "cmd", JE.string sub.cmd )
    , ( "id", JE.int sub.id )
    , ( "data", data )
    ]
        |> JE.object
        |> Just
        |> record table id
        |> event "update"


record : String -> Int -> Maybe JE.Value -> JE.Value
record table id data =
    [ ( "table", JE.string table )
    , ( "id", JE.int id )
    , ( "data", Maybe.withDefault JE.null data )
    ]
        |> JE.object


settings : Maybe String -> JE.Value -> Event
settings customStyle config =
    [ ( "custom"
      , customStyle
            |> Maybe.map JE.string
            |> Maybe.withDefault JE.null
      )
    , ( "config", config )
    ]
        |> JE.object
        |> event "settings"


{-| TODO: Get Event
-}
index_get : String -> Event
index_get =
    JE.string >> index_ "get"


{-| Store an entire LiaScript model within the backend persistently.
-}
index_store : Lia.Model.Model -> Event
index_store =
    Json.encode >> index_ "store"


{-| Restore a certain course from the index, identified by a URL and by the version.

    restore { version = "1.0.12", url = "https://url.../README.md" }

-}
index_restore : { version : String, url : String } -> Event
index_restore =
    toJson >> index_ "restore"


{-| Query for a list of all courses within the index.
-}
index_list : Event
index_list =
    index_ "list" JE.null


{-| Delete all entries for a certain course identified by its.
-}
index_delete : String -> Event
index_delete url =
    url
        |> JE.string
        |> index_ "delete"


{-| Reset all stored states, including code, tasks, surveys, etc. for a certain
course identified by `url` and for a specific `version`.

    reset { version = "2.0.12", url = "htt.../README.md" }

-}
index_reset : { version : String, url : String } -> Event
index_reset =
    toJson >> index_ "reset"


{-| **private:** Helper function to generate index\_commands.
-}
index_ : String -> JE.Value -> Event
index_ cmd =
    event ("index_" ++ cmd)


{-| **private:** Helper for generating a JSON value from `version` and `url`.
The version has to be defined as a String in the format:

    version =
        "Major.Minor.Patch"

-}
toJson : { version : String, url : String } -> JE.Value
toJson { version, url } =
    [ ( "version"
      , version
            |> Index.Version.getMajor
            |> JE.int
      )
    , ( "url", JE.string url )
    ]
        |> JE.object


{-| **private:** Helper function to generate event - stubs that will be handled
by the service module `Database.ts`.
-}
event : String -> JE.Value -> Event
event cmd param =
    Event.init "db" { cmd = cmd, param = param }
