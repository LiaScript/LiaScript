module Lia.Chat.Model exposing
    ( Model
    , init
    , insert
    )

import Array
import Dict exposing (Dict)
import Json.Encode as JE
import Lia.Chat.Sync exposing (Change, Changes)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Effect.Script.Types exposing (Stdout(..))
import Lia.Parser.Parser exposing (parse_section)
import Lia.Section as Section exposing (Section)
import Service.Event as Event exposing (Event)
import Service.Script as Script


type alias Model =
    { input : String
    , messages : Dict String Section
    }


init : Model
init =
    { input = ""
    , messages = Dict.empty
    }


insert : Bool -> (String -> String) -> Definition -> Model -> Changes -> ( List Event, Model )
insert scriptsEnabled searchIndex definition model changes =
    let
        ( todo, messages ) =
            List.foldl
                (parse scriptsEnabled searchIndex definition)
                ( [], model.messages )
                changes
    in
    ( todo, { model | messages = messages } )


parse : Bool -> (String -> String) -> Definition -> Change -> ( List Event, Dict String Section ) -> ( List Event, Dict String Section )
parse scriptsEnabled searchIndex definition change ( todo, chat ) =
    case
        change.message
            ++ "\n\n"
            |> Section.Base 2 []
            |> Section.init 0 change.id
            |> parse_section searchIndex definition
    of
        Ok new ->
            let
                ( javascript, eval ) =
                    new.effect_model.javascript
                        |> Array.toList
                        |> List.map
                            (\js ->
                                ( if scriptsEnabled then
                                    js

                                  else
                                    { js
                                        | result =
                                            "<code class='notranslate lia-code lia-code--inline'>blocked script</code>"
                                                |> HTML
                                                |> Just
                                        , running = True
                                    }
                                , js.script
                                )
                            )
                        |> List.unzip

                newTodo =
                    if scriptsEnabled then
                        eval
                            |> List.indexedMap
                                (\id event ->
                                    Script.exec 350 False event
                                        |> Event.pushWithId "script" id
                                        |> Event.pushWithId "effect" change.id
                                )
                            |> List.append todo

                    else
                        todo

                effect_model =
                    new.effect_model

                section =
                    { new
                        | effect_model =
                            { effect_model
                                | javascript =
                                    Array.fromList javascript
                            }
                    }
            in
            ( if Array.isEmpty section.code_model.evaluate then
                newTodo

              else
                load change.id :: newTodo
            , Dict.insert
                (String.fromInt change.id)
                section
                chat
            )

        Err _ ->
            ( todo, chat )


{-| Load a specific record from the backend service in charge.
-}
load : Int -> Event
load id =
    { cmd = "load"
    , param =
        JE.object
            [ ( "table", JE.string "code" )
            , ( "id", JE.int id )
            , ( "data", JE.null )
            ]
    }
        |> Event.init "db"
        |> Event.pushWithId "code" id
