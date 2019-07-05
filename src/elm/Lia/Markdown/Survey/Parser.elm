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
        , maybe
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
import Lia.Parser.Context exposing (Context, indentation)
import Lia.Parser.Helper exposing (newline, spaces)


parse : Parser Context Survey
parse =
    survey |> andThen modify_State


survey : Parser Context Survey
survey =
    choice
        [ text_lines |> map Text
        , vector parens |> map (Vector False)
        , vector brackets |> map (Vector True)
        , header parens |> map (Matrix False) |> andMap questions
        , header brackets |> map (Matrix True) |> andMap questions
        ]
        |> andMap (withState (.survey_vector >> Array.length >> succeed))


text_lines : Parser Context Int
text_lines =
    maybe indentation
        |> ignore spaces
        |> ignore (string "[")
        |> keep (many1 (regex "_{3,}[\t ]*"))
        |> ignore (string "]")
        |> pattern
        |> map List.length


pattern : Parser Context a -> Parser Context a
pattern p =
    maybe indentation
        |> ignore (regex "[\t ]*\\[")
        |> keep p
        |> ignore (regex "][\t ]*")


id_str : Parser s String
id_str =
    regex "\\w(\\w+| )*"


vector : (Parser Context String -> Parser Context a) -> Parser Context (List ( a, Inlines ))
vector p =
    p id_str
        |> pattern
        |> question
        |> many1


header : (Parser Context String -> Parser Context Var) -> Parser Context (List Var)
header p =
    p id_str
        |> many1
        |> pattern
        |> ignore newline


questions : Parser Context MultInlines
questions =
    maybe indentation
        |> ignore (regex "[\t ]*\\[[\t ]+\\]")
        |> keep line
        |> ignore newline
        |> many1


question : Parser Context a -> Parser Context ( a, Inlines )
question p =
    map Tuple.pair p
        |> andMap line
        |> ignore newline


modify_State : Survey -> Parser Context Survey
modify_State survey_ =
    let
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


add_state : State -> Context -> Context
add_state state c =
    { c | survey_vector = Array.push ( False, state ) c.survey_vector }
