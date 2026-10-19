module Lia.Markdown.Code.Types exposing
    ( Code(..)
    , File
    , Hash
    , Model
    , Project
    , Repo
    , Snippet
    , Vector
    , Version
    , init
    , initProject
    , loadVersion
    , updateVersion
    )

{-| Code blocks of a section. Every block (one or more consecutive listings)
becomes a `Project`. Executable projects are stored in `evaluate`, all others
in `highlight`, the `Code` value in the Markdown body points into one of them.

Executable projects keep a history of versions. The code of all versions is
stored once per content hash in the `repository`, a `Version` only refers to
the hashes of its files plus the log of its last run.

-}

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Markdown.Code.Log as Log exposing (Log)
import Lia.Markdown.Code.Terminal exposing (Terminal)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import MD5


{-| MD5 hex of a file's code, the key in the `Repo`.
-}
type alias Hash =
    String


{-| The hashes of all files of a project plus the log of the run.
-}
type alias Version =
    ( List Hash, Log )


{-| All code that was ever run in a project, by its hash.
-}
type alias Repo =
    Dict Hash String


{-| `copied` is the file that was copied to the clipboard last, the copy
button confirms it for a moment.
-}
type alias Model =
    { evaluate : Vector
    , highlight : Vector
    , copied : Maybe ( Code, Int )
    }


type alias Vector =
    Array Project


{-| `log` is the output of the local editor, `syncLog` the one of the
collaborative editor (`syncMode`) in a classroom. `attr` holds the
annotations of every file, `logSize` the height of the terminal set by the
user and `evaluation` the script that runs the code.
-}
type alias Project =
    { file : Array File
    , version : Array Version
    , version_active : Int
    , repository : Repo
    , evaluation : String
    , log : Log
    , logSize : Maybe String
    , running : Bool
    , terminal : Maybe Terminal
    , syncMode : Bool
    , syncLog : Log
    , attr : List Parameters
    }


{-| A file within a project, `visible` is its accordion state and
`fullscreen` shows all lines instead of at most 16.
-}
type alias File =
    { lang : String
    , name : String
    , code : String
    , visible : Bool
    , fullscreen : Bool
    }


{-| A parsed listing, `name` is the trimmed title after the language.
-}
type alias Snippet =
    { attr : Parameters
    , lang : String
    , name : String
    , code : String
    }


{-| Reference from the Markdown body to a project.
-}
type Code
    = Highlight Int
    | Evaluate Int


{-| An empty code model.
-}
init : Model
init =
    Model Array.empty Array.empty Nothing


{-| Create a project from its parsed listings (each with its visibility).
Executable projects start with collapsed files (`fullscreen = False`), the
first version contains the original code and an empty log.
-}
initProject : Bool -> Array ( Snippet, Bool ) -> String -> Log -> Project
initProject fullscreen snippets evaluation log =
    let
        files =
            Array.map
                (\( { lang, name, code }, visible ) -> File lang name code visible fullscreen)
                snippets

        hashes =
            Array.toList (Array.map (.code >> MD5.hex) files)
    in
    { file = files
    , attr = Array.toList (Array.map (Tuple.first >> .attr) snippets)
    , version = Array.fromList [ ( hashes, Log.empty ) ]
    , evaluation = evaluation
    , version_active = 0
    , log = log
    , logSize = Nothing
    , running = False
    , terminal = Nothing
    , syncMode = False
    , repository =
        files
            |> Array.toList
            |> List.map2 (\hash file -> ( hash, file.code )) hashes
            |> Dict.fromList
    , syncLog = Log.empty
    }


{-| Before a run: if the code differs from the active version, append a new
version (with an empty log), make it active and return the project together
with the newly added repository entries. Never in `syncMode`, there the code
belongs to the classroom.
-}
updateVersion : Project -> Maybe ( Project, Repo )
updateVersion project =
    let
        code =
            Array.toList (Array.map .code project.file)

        hashes =
            List.map MD5.hex code
    in
    project.version
        |> Array.get project.version_active
        |> Maybe.andThen
            (\( active, _ ) ->
                if project.syncMode || active == hashes then
                    Nothing

                else
                    let
                        repository =
                            List.map2 Tuple.pair hashes code
                                |> Dict.fromList
                                |> Dict.union project.repository
                    in
                    Just
                        ( { project
                            | version = Array.push ( hashes, Log.empty ) project.version
                            , version_active = Array.length project.version
                            , log = Log.empty
                            , repository = repository
                          }
                        , Dict.diff repository project.repository
                        )
            )


{-| Restore the code and log of version `idx`. Files whose hash is missing
in the repository keep their code, an unknown version changes nothing.
-}
loadVersion : Int -> Project -> Project
loadVersion idx project =
    case Array.get idx project.version of
        Just ( hashes, log ) ->
            let
                code =
                    Array.fromList hashes
            in
            { project
                | version_active = idx
                , file =
                    Array.indexedMap
                        (\i file ->
                            case Array.get i code |> Maybe.andThen (\h -> Dict.get h project.repository) of
                                Just str ->
                                    { file | code = str }

                                Nothing ->
                                    file
                        )
                        project.file
                , log = log
            }

        Nothing ->
            project
