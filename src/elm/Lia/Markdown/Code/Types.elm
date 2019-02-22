module Lia.Markdown.Code.Types exposing
    ( Code(..)
    , EventMsg
    , File
    , Project
    , Snippet
    , Vector
    , Version
    , initProject
    , loadVersion
    , updateVersion
    )

import Array exposing (Array)
import Dict exposing (Dict)
import Json.Encode as JE
import Lia.Markdown.Code.Log as Log exposing (Log)
import Lia.Markdown.Code.Terminal exposing (Terminal)
import MD5


type alias Hash =
    String


type alias Version =
    ( List Hash, Log )


type alias Vector =
    Array Project


type alias EventMsg =
    List JE.Value


type alias Project =
    { file : Array File
    , version : Array Version
    , evaluation : String
    , version_active : Int
    , log : Log
    , running : Bool
    , terminal : Maybe Terminal
    , repository : Dict Hash String
    }


type alias File =
    { lang : String
    , name : String
    , code : String
    , visible : Bool
    , fullscreen : Bool
    }


type alias Snippet =
    { lang : String
    , name : String
    , code : String
    }


type Code
    = Highlight (List Snippet)
    | Evaluate Int


toFile : ( Snippet, Bool ) -> File
toFile ( { lang, name, code }, visible ) =
    File lang name code visible False


initProject : Array ( Snippet, Bool ) -> String -> Log -> Project
initProject array comment output =
    let
        files =
            Array.map toFile array

        repository =
            files
                |> Array.map hash
                |> Array.toList
    in
    { file = files
    , version =
        Array.fromList [ ( List.map Tuple.first repository, Log.empty ) ]
    , evaluation = comment
    , version_active = 0
    , log = output
    , running = False
    , terminal = Nothing
    , repository = Dict.fromList repository
    }


hash : File -> ( Hash, String )
hash file =
    ( MD5.hex file.code, file.code )


updateVersion : Project -> Maybe Project
updateVersion project =
    let
        code =
            Array.map .code project.file

        hashes =
            Array.map MD5.hex code
                |> Array.toList
    in
    if
        project.version
            |> Array.get project.version_active
            |> Maybe.map Tuple.first
            |> Maybe.map ((/=) hashes)
            |> Maybe.withDefault False
    then
        Just
            { project
                | version = Array.push ( hashes, Log.empty ) project.version
                , version_active = Array.length project.version
                , log = Log.empty
                , repository =
                    List.map2
                        Tuple.pair
                        hashes
                        (Array.toList code)
                        |> Dict.fromList
                        |> Dict.union project.repository
            }

    else
        Nothing


loadVersion : Int -> Project -> Project
loadVersion idx project =
    case Array.get idx project.version of
        Just ( hashes, log ) ->
            let
                get h =
                    Dict.get h project.repository

                code =
                    hashes
                        |> List.map get
                        |> Array.fromList
            in
            { project
                | version_active = idx
                , file =
                    Array.indexedMap
                        (\i a ->
                            { a
                                | code =
                                    case Array.get i code of
                                        Just (Just str) ->
                                            str

                                        _ ->
                                            a.code
                            }
                        )
                        project.file
                , log = log
            }

        _ ->
            project
