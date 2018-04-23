module Lia.PState exposing (..)

import Array exposing (Array)
import Combine exposing (..)
import Lia.Code.Types as Code
import Lia.Definition.Types exposing (Definition)
import Lia.Effect.Model as Effect
import Lia.Quiz.Types as Quiz
import Lia.Survey.Types as Survey


type alias PState =
    { identation : List String
    , identation_skip : Bool
    , code_vector : Code.Vector
    , quiz_vector : Quiz.Vector
    , survey_vector : Survey.Vector
    , effect_model : Effect.Model
    , effect_number : List Int
    , defines : Definition
    , defines_updated : Bool
    }


init : Definition -> PState
init global =
    { identation = []
    , identation_skip = False
    , code_vector = Array.empty
    , quiz_vector = Array.empty
    , survey_vector = Array.empty
    , effect_model = Effect.init
    , effect_number = [ 0 ]
    , defines = global
    , defines_updated = False
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
