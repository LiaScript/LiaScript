module Lia.Survey.Parser exposing (parse)

import Array
import Combine exposing (..)
import Dict
import Lia.Inline.Parser exposing (..)
import Lia.Inline.Types exposing (..)
import Lia.PState exposing (PState)
import Lia.Survey.Types exposing (..)


parse : Parser PState Survey
parse =
    survey >>= modify_PState


survey : Parser PState Survey
survey =
    choice
        [ Text <$> text_lines
        , SingleChoice <$> vector parens
        , SingleChoiceBlock <$> header parens <*> questions
        , MultiChoice <$> vector brackets
        , MultiChoiceBlock <$> header brackets <*> questions
        ]
        <*> increment_counter


text_lines : Parser s Int
text_lines =
    List.length <$> pattern (string "[" *> many1 (regex "(__(_)+)" <* whitespace) <* string "]")


pattern : Parser s a -> Parser s a
pattern p =
    regex "[ \\t]*\\[" *> p <* string "]"


id_int : Parser s String
id_int =
    regex "\\-?[0-9]+"


id_str : Parser s String
id_str =
    string ":" *> regex "[0-9a-zA-Z_ ]+"


vector : (Parser s String -> Parser PState a) -> Parser PState (List ( a, List Inline ))
vector p =
    let
        vec x =
            many1 (question (pattern (p x)))
    in
    vec id_int <|> vec id_str


header : (Parser s String -> Parser s1 Var) -> Parser s1 (List Var)
header p =
    pattern
        (choice [ many1 (p id_int), many1 (p id_str) ])
        <* newline


questions : Parser PState (List Line)
questions =
    many1 (regex "[ \\t]*\\[[ \\t]+\\]" *> line <* newline)


question : Parser PState a -> Parser PState ( a, List Inline )
question p =
    (\i l -> ( i, l )) <$> p <*> (line <* newline)


increment_counter : Parser PState Int
increment_counter =
    let
        pp par =
            succeed par.num_survey

        increment c =
            { c | num_survey = c.num_survey + 1 }
    in
    withState pp <* modifyState increment


modify_PState : Survey -> Parser PState Survey
modify_PState survey_ =
    let
        add_state e s =
            { s | survey_vector = Array.push ( False, e ) s.survey_vector }

        state =
            let
                extractor fn v =
                    v
                        |> List.map fn
                        |> Dict.fromList
            in
            case survey_ of
                Text _ _ ->
                    TextState ""

                SingleChoice vars _ ->
                    vars
                        |> extractor (\( v, _ ) -> ( v, False ))
                        |> SingleChoiceState

                MultiChoice vars _ ->
                    vars
                        |> extractor (\( v, _ ) -> ( v, False ))
                        |> MultiChoiceState

                SingleChoiceBlock vars qs _ ->
                    vars
                        |> extractor (\v -> ( v, False ))
                        |> Array.repeat (List.length qs)
                        |> SingleChoiceBlockState

                MultiChoiceBlock vars qs _ ->
                    vars
                        |> extractor (\v -> ( v, False ))
                        |> Array.repeat (List.length qs)
                        |> MultiChoiceBlockState
    in
    modifyState (add_state state) *> succeed survey_
