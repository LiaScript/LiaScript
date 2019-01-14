port module Lia.Update exposing
    ( Msg(..)
    , get_active_section
    , maybe_event
    , subscriptions
    , update
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Effect.Update as Effect
import Lia.Helper exposing (ID)
import Lia.Index.Update as Index
import Lia.Markdown.Update as Markdown
import Lia.Model exposing (..)
import Lia.Parser exposing (parse_section)
import Lia.Settings.Model exposing (Mode(..))
import Lia.Settings.Update as Settings
import Lia.Types exposing (Section, Sections)



--import Navigation


port event2js : ( String, Int, JE.Value ) -> Cmd msg


port event2elm : (( String, Int, ( String, JD.Value ) ) -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    case get_active_section model of
        Just section ->
            Sub.batch
                [ event2elm Event
                , section
                    |> Markdown.subscriptions
                    |> Sub.map UpdateMarkdown
                ]

        Nothing ->
            event2elm Event


type Msg
    = Load ID Bool
    | InitSection
    | PrevSection
    | NextSection
    | UpdateIndex Index.Msg
    | UpdateSettings Settings.Msg
    | UpdateMarkdown Markdown.Msg
    | Event ( String, Int, ( String, JE.Value ) )


log_maybe : ID -> Maybe ( String, JE.Value ) -> List ( String, ID, JE.Value )
log_maybe idx log_ =
    case log_ of
        Nothing ->
            []

        Just ( name, json ) ->
            [ ( name, idx, json ) ]


speak : Model -> Bool
speak model =
    if model.ready then
        model.settings.sound

    else
        False


maybe_event : ID -> Maybe ( String, JE.Value ) -> Cmd Markdown.Msg -> Cmd Msg
maybe_event idx log_ cmd =
    case log_ of
        Nothing ->
            Cmd.map UpdateMarkdown cmd

        Just ( name, json ) ->
            Cmd.batch [ event2js ( name, idx, json ), Cmd.map UpdateMarkdown cmd ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load idx history ->
            if (-1 < idx) && (idx < Array.length model.sections) then
                ( model
                , if history then
                    Cmd.batch
                        [ event2js ( "persistent", idx, JE.string "store" )

                        --    , (idx + 1)
                        --        |> String.fromInt
                        --        |> (++) "#"
                        --        |> Navigation.newUrl
                        ]

                  else
                    event2js ( "persistent", idx, JE.string "store" )
                )

            else
                ( model, Cmd.none )

        UpdateSettings childMsg ->
            let
                ( new_settings, port_msg ) =
                    Settings.update childMsg model.settings
            in
            ( { model | settings = new_settings }
            , case port_msg of
                Nothing ->
                    Cmd.none

                Just event ->
                    event2js ( "preferences", -1, event )
            )

        UpdateIndex childMsg ->
            let
                index =
                    model.sections
                        |> Array.map .code
                        |> Array.toIndexedList
                        |> Index.update childMsg model.index_model
            in
            ( { model | index_model = index }, Cmd.none )

        Event ( "load", idx, ( _, _ ) ) ->
            update InitSection (generate { model | section_active = idx })

        Event ( "reset", i, ( _, val ) ) ->
            ( model, event2js ( "reset", -1, JE.null ) )

        {-
           Event ( "preferences", x, ( y, json ) ) ->
               ( json
                   |> json2settings
                   |> settings2model model
               , Cmd.none
               )
        -}
        Event ( topic, idx, ( msg_, json ) ) ->
            case Array.get idx model.sections of
                Just sec ->
                    let
                        ( sec_, cmd_, log_ ) =
                            Markdown.jsEventHandler topic msg_ json sec
                    in
                    ( { model | sections = Array.set idx sec_ model.sections }
                    , maybe_event idx log_ cmd_
                    )

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            case ( msg, get_active_section model ) of
                ( UpdateMarkdown childMsg, Just sec ) ->
                    let
                        ( section, cmd, log_ ) =
                            Markdown.update childMsg sec
                    in
                    ( set_active_section model section
                    , maybe_event model.section_active log_ cmd
                    )

                ( NextSection, Just sec ) ->
                    if (model.settings.mode == Textbook) || not (Effect.has_next sec.effect_model) then
                        update (Load (model.section_active + 1) True) model

                    else
                        let
                            ( sec_, cmd_, log_ ) =
                                Markdown.nextEffect (speak model) sec
                        in
                        ( set_active_section model sec_
                        , maybe_event model.section_active log_ cmd_
                        )

                ( PrevSection, Just sec ) ->
                    if (model.settings.mode == Textbook) || not (Effect.has_previous sec.effect_model) then
                        update (Load (model.section_active - 1) True) model

                    else
                        let
                            ( sec_, cmd_, log_ ) =
                                Markdown.previousEffect (speak model) sec
                        in
                        ( set_active_section model sec_
                        , maybe_event model.section_active log_ cmd_
                        )

                ( InitSection, Just sec ) ->
                    let
                        ( sec_, cmd_, log_ ) =
                            case model.settings.mode of
                                Textbook ->
                                    Markdown.initEffect True False sec

                                _ ->
                                    Markdown.initEffect False (speak model) sec
                    in
                    ( set_active_section { model | to_do = [] } sec_
                    , model.to_do
                        |> List.map event2js
                        |> List.append
                            [ event2js ( "slide", model.section_active, JE.null )
                            , maybe_event model.section_active log_ cmd_
                            , event2js ( "persistent", model.section_active, JE.string "load" )
                            ]
                        |> Cmd.batch
                    )

                _ ->
                    ( model, Cmd.none )


restore_ : Model -> Int -> JD.Value -> (JD.Value -> Result String a) -> (Section -> a -> Section) -> Model
restore_ model idx json json2vec update_ =
    case json2vec json of
        Ok vec ->
            case Array.get idx model.sections of
                Just s ->
                    { model | sections = Array.set idx (update_ s vec) model.sections }

                Nothing ->
                    model

        Err msg ->
            let
                x =
                    Debug.log "Error restore_" ( msg, json )
            in
            model


add_load : Int -> Int -> String -> List ( String, Int, JE.Value ) -> List ( String, Int, JE.Value )
add_load length idx vector logs =
    if length == 0 then
        logs

    else
        ( "load", idx, JE.string vector ) :: logs


get_active_section : Model -> Maybe Section
get_active_section model =
    Array.get model.section_active model.sections


set_active_section : Model -> Section -> Model
set_active_section model section =
    { model | sections = Array.set model.section_active section model.sections }


generate : Model -> Model
generate model =
    case get_active_section model of
        Just sec ->
            let
                section =
                    if sec.parsed then
                        let
                            effects =
                                sec.effect_model
                        in
                        { sec | effect_model = { effects | visible = 0 } }

                    else
                        case Lia.Parser.parse_section model.definition sec model.section_active of
                            Ok new_sec ->
                                new_sec

                            Err msg ->
                                { sec
                                    | body = []
                                    , error = Just msg
                                }

                ( javascript, logs ) =
                    section
                        |> .definition
                        |> Maybe.map .scripts
                        |> Maybe.withDefault []
                        |> load_src "script" model.javascript
            in
            set_active_section
                { model
                    | javascript =
                        javascript
                    , to_do =
                        model.to_do
                            |> List.append logs
                            |> add_load (Array.length section.quiz_vector) model.section_active "quiz"
                            |> add_load (Array.length section.code_vector) model.section_active "code"
                            |> add_load (Array.length section.survey_vector) model.section_active "survey"
                }
                section

        Nothing ->
            model


log : String -> Maybe JE.Value -> Maybe ( String, JE.Value )
log topic msg =
    case msg of
        Just m ->
            Just ( topic, m )

        _ ->
            Nothing
