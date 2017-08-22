module Lia.Parser exposing (run)

import Combine exposing (..)
import Combine.Char
import Lia.Effect.Parser exposing (..)
import Lia.Inline.Parser exposing (..)
import Lia.Inline.Types exposing (Inline(..))
import Lia.PState exposing (PState)
import Lia.Quiz.Parser exposing (..)
import Lia.Types exposing (..)


blocks : Parser PState Block
blocks =
    lazy <|
        \() ->
            let
                b =
                    choice
                        [ eblock blocks
                        , table
                        , code_block
                        , quote_block
                        , horizontal_line
                        , Quiz <$> quiz

                        --  , list
                        , paragraph
                        ]
            in
            comments *> b <* newlines


horizontal_line : Parser s Block
horizontal_line =
    HorizontalLine <$ regex "--[\\-]+"


paragraph : Parser PState Block
paragraph =
    (\l -> Paragraph <| combine <| List.concat l) <$> many (spaces *> line <* newline)


table : Parser PState Block
table =
    let
        ending =
            string "|" <* (spaces <* newline)

        row =
            string "|" *> sepBy1 (string "|") (many1 inlines) <* ending

        format =
            string "|"
                *> sepBy1 (string "|")
                    (choice
                        [ regex ":--[\\-]+:" $> "center"
                        , regex ":--[\\-]+" $> "left"
                        , regex "--[\\-]+:" $> "right"
                        , regex "--[\\-]+" $> "left"
                        ]
                    )
                <* ending

        simple_table =
            Table [] [] <$> many1 row <* newline

        format_table =
            Table <$> row <*> format <*> many row <* newline
    in
    choice [ format_table, simple_table ]


code_block : Parser s Block
code_block =
    let
        lang =
            string "```" *> spaces *> regex "([a-z,A-Z,0-9])*" <* spaces <* newline

        block =
            String.fromList <$> manyTill Combine.Char.anyChar (string "```")
    in
    CodeBlock <$> lang <*> block


quote_block : Parser PState Block
quote_block =
    let
        p =
            regex "^" *> string ">" *> optional [ Chars "" ] line <* newline
    in
    (\q -> Quote <| combine <| List.concat q) <$> many1 p


parse : Parser PState (List Slide)
parse =
    let
        tag =
            String.length <$> (newlines *> regex "#+" <* whitespace)

        title =
            String.trim <$> regex ".+" <* many1 newline

        body =
            many blocks

        effect_counter =
            let
                pp par =
                    succeed par.effects

                reset_effect c =
                    { c | effects = 0 }
            in
            withState pp <* modifyState reset_effect
    in
    comments *> many1 (Slide <$> tag <*> title <*> body <*> effect_counter)


run : String -> Result String (List Slide)
run script =
    case Combine.runParser parse Lia.PState.init script of
        Ok ( _, _, es ) ->
            Ok es

        Err ( _, stream, ms ) ->
            Err <| formatError ms stream


formatError : List String -> InputStream -> String
formatError ms stream =
    let
        location =
            currentLocation stream

        separator =
            "|> "

        expectationSeparator =
            "\n  * "

        lineNumberOffset =
            floor (logBase 10 (toFloat location.line)) + 1

        separatorOffset =
            String.length separator

        padding =
            location.column + separatorOffset + 2
    in
    "Parse error around line:\n\n"
        ++ toString location.line
        ++ separator
        ++ location.source
        ++ "\n"
        ++ String.padLeft padding ' ' "^"
        ++ "\nI expected one of the following:\n"
        ++ expectationSeparator
        ++ String.join expectationSeparator ms
