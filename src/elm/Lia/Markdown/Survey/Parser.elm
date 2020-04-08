module Lia.Markdown.Survey.Parser exposing (parse)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , brackets
        , choice
        , fail
        , ignore
        , keep
        , many1
        , manyTill
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
import Lia.Markdown.Inline.Parser exposing (inlines, line)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Block.Parser as Block
import Lia.Markdown.Quiz.Block.Types as BlockTypes
import Lia.Markdown.Quiz.Parser exposing (maybeJS)
import Lia.Markdown.Survey.Types exposing (State(..), Survey, Type(..))
import Lia.Parser.Context exposing (Context, indentation)
import Lia.Parser.Helper exposing (newline, spaces)


parse : Parser Context Survey
parse =
    survey |> andThen modify_State


survey : Parser Context Survey
survey =
    choice
        [ text_lines |> map Text
        , Block.parse |> andThen toSelect
        , vector parens |> map (Vector False)
        , vector brackets |> map (Vector True)
        , header "(" ")" |> map (toMatrix False) |> andMap questions
        , header "[" "]" |> map (toMatrix True) |> andMap questions
        ]
        |> map Survey
        |> andMap (withState (.survey_vector >> Array.length >> succeed))
        |> andMap maybeJS


toMatrix : Bool -> List Inlines -> (List Inlines -> Type)
toMatrix bool ids =
    ids
        |> List.map stringify
        |> Matrix bool ids


text_lines : Parser Context Int
text_lines =
    maybe indentation
        |> ignore spaces
        |> ignore (string "[")
        |> keep (many1 (regex "_{3,}[\t ]*"))
        |> ignore (string "]")
        |> pattern
        |> map List.length
        |> ignore newline


toSelect : BlockTypes.Quiz -> Parser Context Type
toSelect quiz =
    case quiz.solution of
        BlockTypes.Select _ [] ->
            succeed <| Select quiz.options

        _ ->
            fail ""


pattern : Parser Context a -> Parser Context a
pattern p =
    maybe indentation
        |> ignore (regex "[\t ]*\\[")
        |> keep p
        |> ignore (regex "][\t ]*")


id_str : Parser s String
id_str =
    "\\w(\\w+| )*"
        |> regex
        |> andThen
            (\s ->
                if s == "X" then
                    fail ""

                else
                    succeed s
            )


vector : (Parser Context String -> Parser Context a) -> Parser Context (List ( a, Inlines ))
vector p =
    p id_str
        |> pattern
        |> question
        |> many1


header : String -> String -> Parser Context (List Inlines)
header begin end =
    string begin
        |> keep (manyTill inlines (string end))
        |> many1
        |> pattern
        |> ignore newline


questions : Parser Context (List Inlines)
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
            case survey_.survey of
                Text _ ->
                    Text_State ""

                Select _ ->
                    Select_State False -1

                Vector bool vars ->
                    vars
                        |> extractor (\( v, _ ) -> ( v, False ))
                        |> Vector_State bool

                Matrix bool _ vars qs ->
                    vars
                        |> extractor (\v -> ( v, False ))
                        |> Array.repeat (List.length qs)
                        |> Matrix_State bool
    in
    modifyState (add_state state) |> keep (succeed survey_)


add_state : State -> Context -> Context
add_state state c =
    { c | survey_vector = Array.push ( False, state ) c.survey_vector }
