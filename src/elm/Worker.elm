port module Worker exposing (Flags, Model, Msg, main)

import Array
import Error.Report
import Http
import Json.Encode as JE
import Lia.Definition.Json.Encode as Def
import Lia.Json.Encode as Lia
import Lia.Markdown.Quiz.Json as Quiz
import Lia.Markdown.Survey.Json as Survey
import Lia.Markdown.Task.Json as Task
import Lia.Parser.Parser exposing (parse_definition)
import Lia.Script
import Lia.Update exposing (generate)
import Model exposing (State(..))
import Platform
import Process
import Task
import Url


port output : ( Bool, String ) -> Cmd msg


port input : (List String -> msg) -> Sub msg


port helper : ( String, String ) -> Cmd msg


type Msg
    = Handle (List String)
    | LiaParse
    | Load_ReadMe_Result String (Result Http.Error String)
    | Load_Template_Result String (Result Http.Error String)


type alias Model =
    { state : State
    , cmd : String
    , code : Maybe String
    , lia : Lia.Script.Model
    }



-- MAIN


type alias Flags =
    { cmd : String }


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = \_ -> input Handle
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Lia.Script.init
        { seed = 0
        , hasShareApi = False
        , openTOC = True
        , isFullscreen = False
        , settings = JE.null
        , backends = { support = [], enabled = False }
        , url = ""
        , readme = ""
        , origin = ""
        , anchor = Nothing
        }
        |> Model Idle "" Nothing
    , if flags.cmd == "" then
        Cmd.none

      else
        flags.cmd
            |> defines
            |> output
    )


defines : String -> ( Bool, String )
defines str =
    str
        |> parse_definition "" ""
        |> Result.map (Tuple.first >> Def.encode >> JE.encode 2 >> Tuple.pair True)
        |> Result.withDefault ( False, "" )


message : msg -> Cmd msg
message msg =
    Process.sleep 0
        |> Task.map (always <| msg)
        |> Task.perform identity


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Handle [ "defines", readme ] ->
            ( model
            , load_readme readme { model | cmd = "json" }
                |> Tuple.first
                |> parsing
                |> Tuple.first
                |> respond
                |> Tuple.second
            )

        Handle [ "template", url, data ] ->
            update (Load_Template_Result url (Ok data)) model

        Handle [ cmd, readme ] ->
            case Url.fromString readme of
                Nothing ->
                    load_readme readme { model | cmd = cmd }

                _ ->
                    let
                        lia =
                            Lia.Script.init
                                { seed = 0
                                , hasShareApi = False
                                , openTOC = True
                                , isFullscreen = False
                                , settings = JE.null
                                , backends = { support = [], enabled = False }
                                , url = ""
                                , readme = ""
                                , origin = ""
                                , anchor = Nothing
                                }
                    in
                    ( { model
                        | cmd = cmd
                        , lia =
                            { lia
                                | readme = readme
                            }
                      }
                    , download Load_ReadMe_Result readme
                    )

        Handle cmd ->
            ( model
            , cmd
                |> String.join ","
                |> error "Handle"
            )

        LiaParse ->
            parsing model

        Load_ReadMe_Result _ (Ok readme) ->
            load_readme readme model

        Load_ReadMe_Result url (Err info) ->
            ( { model | state = Error.Report.add model.state (parse_error info) }
            , info
                |> parse_error
                |> error (url ++ " Load_ReadMe_Result")
            )

        Load_Template_Result url (Ok template) ->
            parsing
                { model
                    | lia =
                        template
                            |> String.replace "\u{000D}" ""
                            |> Lia.Script.add_imports { model = model.lia, base = url }
                    , state =
                        case model.state of
                            Parsing b templates ->
                                Parsing b (templates - 1)

                            _ ->
                                model.state
                }

        Load_Template_Result url (Err info) ->
            ( { model | state = Error.Report.add model.state (parse_error info) }
            , info
                |> parse_error
                |> error "Load_ReadMe_Result"
            )


error : String -> String -> Cmd Msg
error title =
    (++) ("Error (" ++ title ++ ") -> ") >> Tuple.pair False >> output


respond : Model -> ( Model, Cmd Msg )
respond model =
    ( { model | state = Idle }
    , case model.cmd of
        "json" ->
            model.lia
                |> Lia.encode
                |> JE.encode 2
                |> Tuple.pair True
                |> output

        "fulljson" ->
            let
                lia =
                    parseSection 0 model.lia
            in
            [ ( "lia"
              , Lia.encode lia
              )
            , ( "quiz"
              , lia.sections
                    |> Array.map .quiz_vector
                    |> JE.array Quiz.fromVector
              )
            , ( "survey"
              , lia.sections
                    |> Array.map .survey_vector
                    |> JE.array Survey.fromVector
              )
            , ( "task"
              , lia.sections
                    |> Array.map .task_vector
                    |> JE.array Task.fromVector
              )
            ]
                |> JE.object
                |> JE.encode 2
                |> Tuple.pair True
                |> output

        _ ->
            error "unknown cmd" model.cmd
    )


parseSection : Int -> Lia.Script.Model -> Lia.Script.Model
parseSection active lia =
    if Array.length lia.sections == active then
        lia

    else
        parseSection
            (active + 1)
            (generate { lia | section_active = active })


parsing : Model -> ( Model, Cmd Msg )
parsing model =
    case model.state of
        Parsing False 0 ->
            respond model

        Parsing True templates_to_load ->
            case model.code of
                Nothing ->
                    parsing { model | state = Parsing False templates_to_load }

                Just code ->
                    let
                        ( lia, remaining_code ) =
                            Lia.Script.parse_section model.lia ( code, 0 )

                        new_model =
                            { model | lia = lia, code = remaining_code |> Maybe.map Tuple.first }
                    in
                    if modBy 4 (Lia.Script.pages lia) == 0 then
                        ( new_model, message LiaParse )

                    else
                        parsing new_model

        _ ->
            ( model, Cmd.none )


load_readme : String -> Model -> ( Model, Cmd Msg )
load_readme readme model =
    let
        initial =
            readme
                |> String.replace "\u{000D}" ""
                |> Lia.Script.init_script model.lia
    in
    initial.code
        |> Maybe.map (\( code_, _ ) -> load model initial.model (Just code_) initial.templates)
        |> Maybe.withDefault ( model, Cmd.none )


debug : String -> String -> Cmd msg
debug title msg =
    helper ( "debug", title ++ " " ++ msg )


load : Model -> Lia.Script.Model -> Maybe String -> List String -> ( Model, Cmd Msg )
load model lia code templates =
    case ( code, templates ) of
        ( Just code_, [] ) ->
            ( { model
                | lia = lia
                , state = Parsing True 0
                , code = Just code_
              }
            , message LiaParse
            )

        ( Just code_, templates_ ) ->
            ( { model
                | lia = lia
                , state = Parsing True <| List.length templates_
                , code = Just code_
              }
            , templates
                |> List.map
                    (\url ->
                        if String.startsWith "http" url then
                            download Load_Template_Result url

                        else
                            helper ( "file", url )
                    )
                |> (::) (message LiaParse)
                |> Cmd.batch
            )

        ( Nothing, _ ) ->
            ( { model
                | state =
                    lia.error
                        |> Maybe.withDefault ""
                        |> Error.Report.add model.state
              }
            , Cmd.none
            )


parse_error : Http.Error -> String
parse_error msg =
    case msg of
        Http.BadUrl url ->
            "Bad Url " ++ url

        Http.Timeout ->
            "Network timeout"

        Http.BadStatus int ->
            "Bad status " ++ String.fromInt int

        Http.NetworkError ->
            "Network error"

        Http.BadBody body ->
            "Bad body " ++ body


{-| **@private:** Used by multiple times to connect a download with a message.
-}
download : (String -> Result Http.Error String -> Msg) -> String -> Cmd Msg
download msg url =
    Http.get
        { url = url
        , expect = Http.expectString (msg url)
        }
