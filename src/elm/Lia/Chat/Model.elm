module Lia.Chat.Model exposing
    ( Model
    , init
    , insert
    )

--import Service.Database

import Array
import Dict exposing (Dict)
import Json.Encode as JE
import Lia.Chat.Sync exposing (Change, Changes)
import Lia.Definition.Types exposing (Definition)
import Lia.Parser.Context exposing (searchIndex)
import Lia.Parser.Parser exposing (parse_section)
import Lia.Section as Section exposing (Section)
import Service.Event as Event exposing (Event)


type alias Model =
    { input : String
    , messages : Dict String Section
    }


init : Model
init =
    { input = ""
    , messages = Dict.empty
    }


insert : (String -> String) -> Definition -> Model -> Changes -> ( List Event, Model )
insert searchIndex definition model changes =
    let
        ( todo, messages ) =
            List.foldl
                (parse searchIndex definition)
                ( [], model.messages )
                changes
    in
    ( todo, { model | messages = messages } )


parse : (String -> String) -> Definition -> Change -> ( List Event, Dict String Section ) -> ( List Event, Dict String Section )
parse searchIndex definition change ( todo, chat ) =
    case
        change.message
            ++ "\n\n"
            |> Section.Base 5 []
            |> Section.init 0 change.id
            |> parse_section searchIndex definition
    of
        Ok new ->
            ( if Array.isEmpty new.code_model.evaluate then
                todo

              else
                load change.id :: todo
            , Dict.insert
                (String.fromInt change.id)
                new
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
