module Lia.PState exposing (..)

--import Combine exposing (Parser, skip, string)

import Array exposing (Array)
import Combine exposing (..)
import Dict exposing (Dict)
import Lia.Code.Types as Code
import Lia.Effect.Model as Effect
import Lia.Quiz.Types as Quiz
import Lia.Survey.Types as Survey


type alias PState =
    { identation : List String
    , identation_skip : Bool
    , num_effects : Int
    , code_temp : ( String, String ) -- Lang Code
    , code_vector : Code.Vector
    , quiz_vector : Quiz.Vector
    , survey_vector : Survey.Vector
    , comment_map : Effect.Map
    }


init : PState
init =
    { identation = []
    , identation_skip = False
    , num_effects = 0
    , code_temp = ( "", "" )
    , code_vector = Array.empty
    , quiz_vector = Array.empty
    , survey_vector = Array.empty
    , comment_map = Dict.empty
    }


identation : Parser PState ()
identation =
    lazy <|
        \() ->
            let
                par s =
                    if s.identation == [] then
                        succeed ()
                    else if s.identation_skip then
                        skip (succeed ())
                    else
                        String.concat s.identation
                            |> regex
                            |> skip
            in
            withState par <* modifyState (\s -> { s | identation_skip = False })


identation_append : String -> Parser PState ()
identation_append str =
    modifyState
        (\state ->
            { state
                | identation_skip = True
                , identation = List.append state.identation [ str ]
            }
        )


identation_pop : Parser PState ()
identation_pop =
    modifyState
        (\state ->
            { state
                | identation_skip = False
                , identation =
                    state.identation
                        |> List.reverse
                        |> List.drop 1
                        |> List.reverse
            }
        )


ident_skip : Parser PState ()
ident_skip =
    modifyState (\state -> { state | identation_skip = True })
