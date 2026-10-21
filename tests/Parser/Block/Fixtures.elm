module Parser.Block.Fixtures exposing
    ( Case
    , alertQuote
    , bulletList
    , hline
    , header
    , orderedList
    , paragraph
    , parse
    , parseWithState
    , quote
    , toTests
    )

{-| Shared building blocks for the block-parser test suites under
`tests/Parser/Block/`.
-}

import Combine
import Expect
import Lia.Definition.Types exposing (default)
import Lia.Markdown.Parser exposing (run)
import Lia.Markdown.Types exposing (Alert, Block(..), Blocks)
import Lia.Parser.Context as Context exposing (Context)
import Parser.Inline.Fixtures exposing (chars)
import Test exposing (Test, test)


initState : Context
initState =
    default "" "" |> Context.init Nothing Nothing


parse : String -> Blocks
parse str =
    parseWithState str |> Tuple.first


{-| Like `parse`, but also returns the final `Context`, for constructs whose
rendered content is only an index into some part of the context's state
(e.g. `task_vector`, `quiz_vector`, `survey_vector`, `code_model`) rather than
being fully self-contained in the returned `Blocks`.
-}
parseWithState : String -> ( Blocks, Context )
parseWithState str =
    case Combine.runParser run initState str of
        Ok ( resultState, _, result ) ->
            ( result, resultState )

        Err _ ->
            ( [], initState )


type alias Case =
    ( String, Block )


{-| Turn a list of (input, expected) pairs into individual `Test`s, one per
case, named after the raw input so a failure points straight at the markdown
that broke.
-}
toTests : List Case -> List Test
toTests =
    List.map
        (\( input, expected ) ->
            test input <|
                \_ ->
                    parse input |> Expect.equal [ expected ]
        )


header : Int -> String -> Block
header level text =
    Header [] ( level, [ chars text ] )


paragraph : String -> Block
paragraph text =
    Paragraph [] [ chars text ]


hline : Block
hline =
    HLine []


quote : List String -> Block
quote items =
    Quote [] Nothing (List.map paragraph items)


alertQuote : Alert -> Maybe String -> List String -> Block
alertQuote alert title items =
    Quote [] (Just ( alert, Maybe.map (\t -> [ chars t ]) title )) (List.map paragraph items)


bulletList : List String -> Block
bulletList items =
    BulletList [] (List.map (paragraph >> List.singleton) items)


orderedList : List ( String, String ) -> Block
orderedList items =
    OrderedList [] (List.map (\( number, text ) -> ( number, [ paragraph text ] )) items)
