module Lia.Markdown.Survey.Parser exposing (parse)

import Array
import Combine exposing (..)
import Dict
import Lia.Helper exposing (..)
import Lia.Markdown.Inline.Parser exposing (..)
import Lia.Markdown.Inline.Types exposing (..)
import Lia.Markdown.Survey.Types exposing (..)
import Lia.PState exposing (PState)


parse : Parser PState Survey
parse =
    survey |> andThen modify_PState


survey : Parser PState Survey
survey =
    let
        get_id par =
            succeed (Array.length par.survey_vector)
    in
    choice
        [ text_lines |> map Text
        , vector parens |> map (Vector False)
        , vector brackets |> map (Vector True)
        , header parens |> map (Matrix False) |> andMap questions
        , header brackets |> map (Matrix True) |> andMap questions
        ]
        |> andMap (withState get_id)


text_lines : Parser s Int
text_lines =
    string "["
        |> keep (many1 (regex "_{3,}[\t ]*"))
        |> ignore (string "]")
        |> pattern
        |> map List.length


pattern : Parser s a -> Parser s a
pattern p =
    regex "[\t ]*\\["
        |> keep p
        |> ignore (regex "][\t ]*")


id_int : Parser s String
id_int =
    regex "\\-?\\d+"


id_str : Parser s String
id_str =
    string ":"
        |> keep (regex "[0-9a-zA-Z_ ]+")


vector : (Parser s String -> Parser PState a) -> Parser PState (List ( a, List Inline ))
vector p =
    let
        vec x =
            many1 (question (pattern (p x)))
    in
    or (vec id_int) (vec id_str)


header : (Parser s String -> Parser s1 Var) -> Parser s1 (List Var)
header p =
    or (many1 (p id_int)) (many1 (p id_str))
        |> pattern
        |> ignore newline


questions : Parser PState MultInlines
questions =
    regex "[\t ]*\\[[\t ]+\\]"
        |> keep line
        |> ignore newline
        |> many1


question : Parser PState a -> Parser PState ( a, List Inline )
question p =
    map Tuple.pair p
        |> andMap line
        |> ignore newline


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

                Vector bool vars _ ->
                    vars
                        |> extractor (\( v, _ ) -> ( v, False ))
                        |> VectorState bool

                Matrix bool vars qs _ ->
                    vars
                        |> extractor (\v -> ( v, False ))
                        |> Array.repeat (List.length qs)
                        |> MatrixState bool
    in
    modifyState (add_state state) |> keep (succeed survey_)
