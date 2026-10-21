module Parser.Inline.Fixtures exposing
    ( Case
    , audio
    , bold
    , bold_italic
    , chars
    , container
    , embed
    , footnoteMark
    , formula
    , htmlVoid
    , htmlNode
    , image
    , italic
    , link
    , mail
    , movie
    , parse
    , parseFootnotes
    , parseRaw
    , parseWithInputEnabled
    , previewLia
    , previewLink
    , qr
    , script
    , strike
    , superscript
    , symbol
    , toTests
    , underline
    , verbatim
    )

{-| Shared building blocks for the inline-parser test suites under
`tests/Parser/Inline/`.

`Case` pairs a raw markdown input with the `Inline` it should parse to. Each
topic file (`Basic`, `Emphasis`, `References`, `Media`, `HTML`, `Effects`,
`Typography`) turns its own `List Case` into `Test`s via `toTests`. Keeping
the cases as plain data (rather than one-off `test` calls) means a future
block-level test suite can import the same `List Case` values and re-wrap
their `input` strings in block syntax (`"# " ++ input`, `"> " ++ input`, a
list item, a table cell, ...) without duplicating how the expected `Inline`
values are built.

-}

import Combine
import Dict exposing (Dict)
import Expect
import Lia.Definition.Types exposing (default)
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.Inline.Parser exposing (line, parse_inlines)
import Lia.Markdown.Inline.Types exposing (Inline(..), Reference(..))
import Lia.Markdown.Types as Markdown
import Lia.Parser.Context as Context
import Lia.Parser.Input as Input
import Test exposing (Test, test)


parse : String -> List Inline
parse =
    default "" ""
        |> Context.init Nothing Nothing
        |> parse_inlines


{-| Like `parse`, but preserves literal newlines instead of collapsing them to
spaces, so constructs that key off an actual newline (e.g. the `\` line
break) can be exercised.
-}
parseRaw : String -> List Inline
parseRaw str =
    let
        state =
            default "" "" |> Context.init Nothing Nothing
    in
    case Combine.runParser line state str of
        Ok ( _, _, result ) ->
            result

        Err _ ->
            []


{-| Like `parse`, but enables the quiz-input permission first, so inline
`[[...]]`/`[->[...]]` blanks (only reachable when a surrounding quiz block has
granted that permission) can be exercised standalone.
-}
parseWithInputEnabled : String -> List Inline
parseWithInputEnabled str =
    let
        state =
            default "" "" |> Context.init Nothing Nothing
    in
    case Combine.runParser (Input.setPermission True |> Combine.keep line) state str of
        Ok ( _, _, result ) ->
            result

        Err _ ->
            []


{-| Parses `str` and returns the footnote definitions collected as a side
effect (e.g. by the inline `[^key](footnote text)` form), keyed by footnote
key.
-}
parseFootnotes : String -> Dict String Markdown.Blocks
parseFootnotes str =
    let
        state =
            default "" "" |> Context.init Nothing Nothing
    in
    case Combine.runParser line state str of
        Ok ( resultState, _, _ ) ->
            resultState.footnotes

        Err _ ->
            Dict.empty


type alias Case =
    ( String, Inline )


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


chars : String -> Inline
chars str =
    Chars str []


symbol : String -> Inline
symbol str =
    Symbol str []


bold : String -> Inline
bold str =
    Bold (chars str) []


italic : String -> Inline
italic str =
    Italic (chars str) []


bold_italic : String -> Inline
bold_italic str =
    Bold (italic str) []


strike : String -> Inline
strike str =
    Strike (chars str) []


underline : String -> Inline
underline str =
    Underline (chars str) []


superscript : String -> Inline
superscript str =
    Superscript (chars str) []


verbatim : String -> Inline
verbatim str =
    Verbatim str []


formula : Bool -> String -> Inline
formula mode str =
    Formula
        (if mode then
            "true"

         else
            "false"
        )
        str
        []


footnoteMark : String -> Inline
footnoteMark key =
    FootnoteMark key []


link : String -> String -> Inline
link text_ url =
    Ref (Link [ chars text_ ] url Nothing) []


image : String -> String -> Inline
image alt url =
    Ref (Image [ chars alt ] url Nothing) []


mail : String -> String -> Inline
mail text_ address =
    Ref (Mail [ chars text_ ] address Nothing) []


audio : String -> String -> Inline
audio text_ url =
    Ref (Audio [ chars text_ ] ( False, url ) Nothing) []


movie : String -> String -> Inline
movie text_ url =
    Ref (Movie [ chars text_ ] ( False, url ) Nothing) []


embed : String -> String -> Inline
embed text_ url =
    Ref (Embed [ chars text_ ] url Nothing) []


previewLia : String -> Inline
previewLia url =
    Ref (Preview_Lia url) []


previewLink : String -> Inline
previewLink url =
    Ref (Preview_Link url) []


qr : String -> Inline
qr url =
    Ref (QR_Link url Nothing) []


container : List Inline -> Inline
container list =
    Container list []


htmlNode : String -> List Inline -> Inline
htmlNode name content =
    IHTML (Node name [] content) []


htmlVoid : String -> Inline
htmlVoid name =
    IHTML (Node name [] []) []


script : Int -> Inline
script id =
    Script id []
