module Lia.Chat.Model exposing
    ( Model
    , init
    , insert
    )

import Accessibility.Role exposing (definition)
import Dict exposing (Dict)
import Lia.Chat.Sync exposing (Change, Changes)
import Lia.Definition.Types exposing (Definition)
import Lia.Parser.Context exposing (searchIndex)
import Lia.Parser.Parser exposing (parse_section)
import Lia.Section as Section exposing (Section)


type alias Model =
    { input : String
    , messages : Dict String Section
    }


init : Model
init =
    { input = ""
    , messages = Dict.empty
    }


insert : (String -> String) -> Definition -> Model -> Changes -> Model
insert searchIndex definition model changes =
    { model
        | messages =
            List.foldl
                (parse searchIndex definition)
                model.messages
                changes
    }


parse : (String -> String) -> Definition -> Change -> Dict String Section -> Dict String Section
parse searchIndex definition change chat =
    case
        change.message
            ++ "\n\n"
            |> Section.Base 5 []
            |> Section.init 0 change.id
            |> parse_section searchIndex definition
    of
        Ok new ->
            Dict.insert
                (String.fromInt change.id)
                new
                chat

        Err _ ->
            chat
