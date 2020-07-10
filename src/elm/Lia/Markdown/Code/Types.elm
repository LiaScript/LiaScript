module Lia.Markdown.Code.Types exposing
    ( Code(..)
    , File
    , Project
    , Repo
    , Snippet
    , Vector
    , Version
    , initProject
    , loadVersion
    , updateVersion
    )

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Markdown.Code.Log as Log exposing (Log)
import Lia.Markdown.Code.Terminal exposing (Terminal)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import MD5


type alias Hash =
    String


type alias Version =
    ( List Hash, Log )


type alias Repo =
    Dict Hash String


type alias Vector =
    Array Project


type alias Project =
    { file : Array File
    , focus : Int
    , version : Array Version
    , version_active : Int
    , repository : Repo
    , evaluation : String
    , log : Log
    , running : Bool
    , terminal : Maybe Terminal
    , compact_view : Bool
    , attr : List Parameters
    }


type alias File =
    { lang : String
    , name : String
    , code : String
    , visible : Bool
    , fullscreen : Bool
    }


type alias Snippet =
    { attr : Parameters
    , lang : String
    , name : String
    , code : String
    }


type Code
    = Highlight (List Snippet)
    | Evaluate Int


toFile : ( Snippet, Bool ) -> ( Parameters, File )
toFile ( { attr, lang, name, code }, visible ) =
    ( attr, File lang name code visible False )


initProject : Array ( Snippet, Bool ) -> String -> Log -> Project
initProject array comment output =
    let
        ( attr, files ) =
            Array.foldl
                (\s ( a, f ) ->
                    let
                        ( a_, f_ ) =
                            toFile s
                    in
                    ( List.append a [ a_ ]
                    , Array.push f_ f
                    )
                )
                ( [], Array.empty )
                array

        repository =
            files
                |> Array.map hash
                |> Array.toList
    in
    { file = files
    , attr = attr
    , focus = -1
    , version = Array.fromList [ ( List.map Tuple.first repository, Log.empty ) ]
    , evaluation = comment
    , version_active = 0
    , log = output
    , running = False
    , terminal = Nothing
    , repository = Dict.fromList repository
    , compact_view = False
    }


hash : File -> ( Hash, String )
hash file =
    ( MD5.hex file.code, file.code )


updateVersion : Project -> Maybe ( Project, Repo )
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
        let
            repository =
                List.map2
                    Tuple.pair
                    hashes
                    (Array.toList code)
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
