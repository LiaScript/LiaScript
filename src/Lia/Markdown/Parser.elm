module Lia.Markdown.Parser exposing (run)

import Combine exposing (..)
import Lia.Chart.Parser as Chart
import Lia.Code.Parser as Code
import Lia.Effect.Parser exposing (..)
import Lia.Inline.Parser exposing (..)
import Lia.Inline.Types exposing (Inline(..), Line)
import Lia.Markdown.Types exposing (..)
import Lia.PState exposing (PState)
import Lia.Quiz.Parser as Quiz
import Lia.Survey.Parser as Survey


run : Parser PState (List Markdown)
run =
    lazy <|
        \() ->
            many (blocks <* newlines)


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
                            |> string
                            |> skip

                reset s =
                    { s | identation_skip = False }
            in
            withState par <* modifyState reset


identation_append : String -> PState -> PState
identation_append str state =
    { state
        | identation_skip = True
        , identation = List.append state.identation [ str ]
    }


identation_pop : PState -> PState
identation_pop state =
    { state
        | identation_skip = False
        , identation =
            state.identation
                |> List.reverse
                |> List.drop 1
                |> List.reverse
    }


blocks : Parser PState Markdown
blocks =
    lazy <|
        \() ->
            let
                b =
                    choice
                        [ eblock blocks
                        , ecomment paragraph
                        , Chart <$> Chart.parse
                        , table
                        , Code <$> Code.parse
                        , quote
                        , horizontal_line
                        , Survey <$> Survey.parse
                        , Quiz <$> Quiz.parse <*> solution
                        , ordered_list
                        , unordered_list
                        , Paragraph <$> paragraph
                        ]
            in
            comments *> b


solution : Parser PState (Maybe ( List Markdown, Int ))
solution =
    let
        rslt e1 blocks_ e2 =
            ( blocks_, e2 - e1 )
    in
    maybe
        (rslt
            <$> (regex "( *)\\[\\[\\[[\\n]+"
                    *> withState (\s -> succeed s.num_effects)
                )
            <*> manyTill (blocks <* regex "[ \\n\\t]*") (regex "\\]\\]\\]")
            <*> withState (\s -> succeed s.num_effects)
        )


unordered_list : Parser PState Markdown
unordered_list =
    BulletList
        <$> many1
                (identation
                    *> regex "[*+-]( )"
                    *> (modifyState (identation_append "  ")
                            *> many1 (blocks <* regex "[\\n]?")
                            <* modifyState identation_pop
                       )
                )


ordered_list : Parser PState Markdown
ordered_list =
    OrderedList
        <$> many1
                (identation
                    *> regex "[0-9]+\\. "
                    *> (modifyState (identation_append "   ")
                            *> many1 (blocks <* regex "[\\n]?")
                            <* modifyState identation_pop
                       )
                )


horizontal_line : Parser PState Markdown
horizontal_line =
    HLine <$ (identation *> regex "--[\\-]+")


paragraph : Parser PState Line
paragraph =
    (\l -> combine <| List.concat l) <$> many1 (identation *> line <* newline)


table : Parser PState Markdown
table =
    let
        ending =
            regex "\\|[ \\t]*" *> newline

        row =
            identation *> manyTill (string "|" *> line) ending

        format =
            identation
                *> string "|"
                *> sepBy1 (string "|")
                    (choice
                        [ regex "[ \\t]*:--[\\-]+:[ \\t]*" $> "center"
                        , regex "[ \\t]*:--[\\-]+[ \\t]*" $> "left"
                        , regex "[ \\t]*--[\\-]+:[ \\t]*" $> "right"
                        , regex "[ \\t]*--[\\-]+[ \\t]*" $> "left"
                        ]
                    )
                <* ending

        simple_table =
            (Table [] [] <$> many1 row) <* newline

        format_table =
            (Table <$> row <*> format <*> many row) <* newline
    in
    choice [ format_table, simple_table ]


quote : Parser PState Markdown
quote =
    Quote
        <$> (string "> "
                *> (modifyState (identation_append "> ") *> many1 blocks <* modifyState identation_pop)
            )
