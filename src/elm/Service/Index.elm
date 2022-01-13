module Service.Index exposing
    ( delete
    , get
    , list
    , reset
    , restore
    )

import Index.Version
import Json.Encode as JE
import Service.Event as Event exposing (Event)


{-| TODO: Get Event
-}
get : String -> Event
get =
    JE.string >> event "get"


{-| Restore a certain course from the index, identified by a URL and by the version.

    restore { version = "1.0.12", url = "https://url.../README.md" }

-}
restore : { version : String, url : String } -> Event
restore =
    toJson >> event "restore"


{-| Query for a list of all courses within the index.
-}
list : Event
list =
    event "list" JE.null


{-| Delete all entries for a certain course identified by its.
-}
delete : String -> Event
delete url =
    url
        |> JE.string
        |> event "delete"


{-| Reset all stored states, including code, tasks, surveys, etc. for a certain
course identified by `url` and for a specific `version`.

    reset { version = "2.0.12", url = "htt.../README.md" }

-}
reset : { version : String, url : String } -> Event
reset =
    toJson >> event "reset"


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
by the service module `Index.ts`.
-}
event : String -> JE.Value -> Event
event cmd param =
    { cmd = cmd, param = param }
        |> Event.init "index"
