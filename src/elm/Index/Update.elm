module Index.Update exposing
    ( Msg(..)
    , decodeGet
    , get
    , handle
    , init
    , restore
    , update
    )

import Index.Model exposing (Course, Model, Version)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Definition.Json.Decode as Definition
import Lia.Markdown.Inline.Json.Decode as Inline
import Port.Event as Event exposing (Event)


type Msg
    = IndexList (List Course)
    | IndexError String
    | Input String
    | Delete String
    | Handle JD.Value


init : Event
init =
    Event "list" -1 JE.null
        |> Event.encode
        |> Event "index" -1


delete : String -> Event
delete id =
    JE.string id
        |> Event "delete" -1


get : String -> Event
get id =
    JE.string id
        |> Event "get" -1
        |> Event.encode
        |> Event "index" -1


restore : Int -> String -> Event
restore version =
    JE.string
        >> Event "restore" version
        >> Event.encode
        >> Event "index" -1


decodeGet : JD.Value -> ( String, Maybe Course )
decodeGet event =
    case
        ( JD.decodeValue (JD.field "id" JD.string) event
        , JD.decodeValue (JD.field "course" decCourse) event
        )
    of
        ( Ok uri, Ok course ) ->
            ( uri, Just course )

        ( Ok uri, Err _ ) ->
            ( uri, Nothing )

        ( Err _, _ ) ->
            ( "", Nothing )


handle : JD.Value -> Msg
handle =
    Handle


update : Msg -> Model -> ( Model, Cmd Msg, List Event )
update msg model =
    case msg of
        IndexList list ->
            ( { model
                | courses = list
                , initialized = True
              }
            , Cmd.none
            , []
            )

        IndexError _ ->
            ( model, Cmd.none, [] )

        Delete courseID ->
            ( model, Cmd.none, [ delete courseID ] )

        Handle json ->
            update (decode json) model

        Input url ->
            ( { model | input = url }, Cmd.none, [] )


decode : JD.Value -> Msg
decode json =
    case JD.decodeValue decList json of
        Ok rslt ->
            rslt

        Err msg ->
            IndexError "decode"


decList : JD.Decoder Msg
decList =
    JD.list decCourse
        |> JD.field "list"
        |> JD.map IndexList


decCourse : JD.Decoder Course
decCourse =
    JD.map4 Course
        (JD.field "id" JD.string)
        (JD.field "data" (JD.dict decVersion))
        (JD.succeed Nothing)
        (JD.field "updated_str" JD.string)


decVersion : JD.Decoder Version
decVersion =
    JD.map2 Version
        (JD.field "title" Inline.decode)
        Definition.decode
