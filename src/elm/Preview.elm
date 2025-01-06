port module Preview exposing (..)

import Dict
import Json.Encode as JE
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Parser.Parser
    exposing
        ( parse_definition
        , parse_titles
        )
import Platform


port output : ( Bool, JE.Value ) -> Cmd msg


port input : (String -> msg) -> Sub msg


type alias Metadata =
    { logo : String
    , icon : String
    , title : String
    , author : String
    , tags : String
    , email : String
    , description : String
    , version : String
    }


type Msg
    = Analyze String


type alias Model =
    String



-- MAIN


type alias Flags =
    { cmd : String }


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = \_ -> input Analyze
        }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( ""
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        Analyze readme ->
            analyze readme


analyze : String -> ( Model, Cmd Msg )
analyze readme =
    case parse_definition "" "" readme of
        Ok ( definition, ( code, line ) ) ->
            let
                title =
                    parse_titles line Dict.empty definition code
                        |> Result.toMaybe
                        |> Maybe.map (Tuple.first >> .title)
                        |> Maybe.withDefault []
            in
            ( code
            , [ ( "logo", JE.string definition.logo )
              , ( "icon"
                , definition.macro
                    |> Dict.get "icon"
                    |> Maybe.map JE.string
                    |> Maybe.withDefault JE.null
                )
              , ( "title"
                , title
                    |> stringify
                    |> JE.string
                )
              , ( "author", JE.string definition.author )
              , ( "tags"
                , definition.macro
                    |> Dict.get "tags"
                    |> Maybe.withDefault ""
                    |> JE.string
                )
              , ( "email", JE.string definition.email )
              , ( "description"
                , definition.comment
                    |> stringify
                    |> JE.string
                )
              , ( "version", JE.string definition.version )
              ]
                |> JE.object
                |> Tuple.pair True
                |> output
            )

        Err log ->
            ( "", error "parse" log )


error : String -> String -> Cmd Msg
error title =
    (++) ("Error (" ++ title ++ ") -> ")
        >> JE.string
        >> Tuple.pair False
        >> output
