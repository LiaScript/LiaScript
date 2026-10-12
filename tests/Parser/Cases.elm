module Parser.Cases exposing (suite)

{-| Cases of `Lia.Parser` that do not occur in the LiaBooks and LiaTemplates
corpora, which are otherwise used as a golden master.
-}

import Combine
import Expect
import Lia.Definition.Types exposing (default)
import Lia.Markdown.Inline.Types exposing (Inline(..), Reference(..))
import Lia.Markdown.Types exposing (Block(..))
import Lia.Parser.Context as Context
import Lia.Parser.Parser as Parser
import Lia.Section as Section
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Lia.Parser"
        [ test "links to a title are translated by the search index" <|
            \_ ->
                section "[link](#some-title)\n"
                    |> Parser.parse_section (\_ -> "#42") (default "" "")
                    |> Result.map .body
                    |> Expect.equal (Ok [ Paragraph [] [ Ref (Link [ Chars "link" [] ] "#42" Nothing) [] ] ])
        , test "the seed of a section is used for random numbers" <|
            \_ ->
                [ 1, 2, 12345 ]
                    |> List.map seeds
                    |> Expect.equal
                        [ [ 119662981, 95323777, 98191705 ]
                        , [ 24577598, 190647554, 196383410 ]
                        , [ 200252853, 165740709, 136831809 ]
                        ]
        , test "an error in the main definitions shows the line, column and expectations" <|
            \_ ->
                case Parser.parse_definition "" "" "<!--\nauthor: x\n-->\nno title" of
                    Err message ->
                        message
                            |> String.contains "Parse error around line: 3\n\nno title\n   ^\nI expected one of the following:\n\n* expected \"#\"\n\n* manyTill: reached end of input without finding end parser\n"
                            |> Expect.equal True

                    Ok _ ->
                        Expect.fail "a course without a title cannot be parsed"
        , test "a tab after the hashes starts a title" <|
            \_ ->
                Parser.parse_titles (default "" "") "#\tTitle\nbody\n"
                    |> Result.map (\( base, _ ) -> ( base.indentation, base.title, base.code ))
                    |> Expect.equal (Ok ( 1, [ Chars "Title" [] ], "body\n" ))
        , test "a void <br> does not hide the next title until a later </br>" <|
            \_ ->
                Parser.parse_titles (default "" "") "# A\na<br>\n\n# Second\n\nb </br>\n"
                    |> Result.map Tuple.second
                    |> Expect.equal (Ok "# Second\n\nb </br>\n")
        , test "a title within an HTML element is no title, the closing tag may contain spaces" <|
            \_ ->
                Parser.parse_titles (default "" "") "# A\n<div>\n# x\n</ div >\n"
                    |> Result.map Tuple.second
                    |> Expect.equal (Ok "")
        , test "randomized quizzes use the seed of the section" <|
            \_ ->
                let
                    quiz seed =
                        Section.init seed 0 { indentation = 1, title = [], code = "<!-- data-randomize -->\n- [[x]] a\n- [[ ]] b\n- [[ ]] c\n- [[x]] d\n" }
                            |> Parser.parse_section identity (default "" "")
                            |> Result.map (.quiz_vector >> Debug.toString)
                in
                quiz 99
                    |> Expect.notEqual (quiz 5)
        ]


section : String -> Section.Section
section code =
    Section.init 99 7 { indentation = 1, title = [], code = code }


{-| The first three random numbers for a seed.
-}
seeds : Int -> List Int
seeds seed =
    case
        Combine.runParser
            (Combine.sequence [ Context.getSeed, Context.getSeed, Context.getSeed ])
            (Context.init (Just seed) Nothing (default "" ""))
            ""
    of
        Ok ( _, _, numbers ) ->
            numbers

        Err _ ->
            []
