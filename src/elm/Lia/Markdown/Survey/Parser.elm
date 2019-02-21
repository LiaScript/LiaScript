module Lia.Markdown.Survey.Parser exposing (parse)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , brackets
        , choice
        , ignore
        , keep
        , many1
        , map
        , modifyState
        , parens
        , regex
        , string
        , succeed
        , withState
        )
import Dict
import Lia.Markdown.Inline.Parser exposing (line)
import Lia.Markdown.Inline.Types exposing (Inlines, MultInlines)
import Lia.Markdown.Survey.Types exposing (State(..), Survey(..), Var)
import Lia.Parser.Helper exposing (newline)
import Lia.Parser.State exposing (State)


parse : Parser State Survey
parse =
    survey |> andThen modify_State


survey : Parser State Survey
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


id_str : Parser s String
id_str =
    regex "\\w(\\w+| )*"


vector : (Parser s String -> Parser State a) -> Parser State (List ( a, Inlines ))
vector p =
    let
        vec x =
            many1 (question (pattern (p x)))
    in
    vec id_str


header : (Parser s String -> Parser s1 Var) -> Parser s1 (List Var)
header p =
    many1 (p id_str)
        |> pattern
        |> ignore newline


questions : Parser State MultInlines
questions =
    regex "[\t ]*\\[[\t ]+\\]"
        |> keep line
        |> ignore newline
        |> many1


question : Parser State a -> Parser State ( a, Inlines )
question p =
    map Tuple.pair p
        |> andMap line
        |> ignore newline


modify_State : Survey -> Parser State Survey
modify_State survey_ =
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
