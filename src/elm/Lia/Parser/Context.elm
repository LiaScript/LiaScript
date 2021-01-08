module Lia.Parser.Context exposing
    ( Context
    , indentation
    , indentation_append
    , indentation_pop
    , indentation_skip
    , init
    , searchIndex
    )

import Array
import Combine exposing (Parser, ignore, modifyState, regex, skip, succeed, withState)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Code.Types as Code
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Footnote.Model as Footnote
import Lia.Markdown.Quiz.Types as Quiz
import Lia.Markdown.Survey.Types as Survey
import Lia.Markdown.Table.Types as Table
import Lia.Section exposing (SubSection)


type alias Context =
    { identation : List String
    , identation_skip : Bool
    , code_vector : Code.Vector
    , quiz_vector : Quiz.Vector
    , survey_vector : Survey.Vector
    , table_vector : Table.Vector
    , effect_model : Effect.Model SubSection
    , effect_number : List Int
    , effect_id : Int
    , defines : Definition
    , footnotes : Footnote.Model
    , defines_updated : Bool
    , search_index : String -> String
    }


init : (String -> String) -> Definition -> Context
init search_index global =
    { identation = []
    , identation_skip = False
    , code_vector = Array.empty
    , quiz_vector = Array.empty
    , survey_vector = Array.empty
    , table_vector = Array.empty
    , effect_model = Effect.init
    , effect_number = [ 0 ]
    , effect_id = 0
    , defines = global
    , footnotes = Footnote.init
    , defines_updated = False
    , search_index = search_index
    }


searchIndex : Parser Context (String -> String)
searchIndex =
    withState (\state -> state.search_index |> succeed)


par_ : Context -> Parser Context ()
par_ s =
    if s.identation == [] then
        succeed ()

    else if s.identation_skip then
        skip (succeed ())

    else
        String.concat s.identation
            |> regex
            |> skip


indentation : Parser Context ()
indentation =
    withState par_
        |> ignore (modifyState (skip_ False))


indentation_append : String -> Parser Context ()
indentation_append str =
    modifyState
        (\state ->
            { state
                | identation_skip = True
                , identation = List.append state.identation [ str ]
            }
        )


indentation_pop : Parser Context ()
indentation_pop =
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


indentation_skip : Parser Context ()
indentation_skip =
    modifyState (skip_ True)


skip_ : Bool -> Context -> Context
skip_ bool state =
    { state | identation_skip = bool }
