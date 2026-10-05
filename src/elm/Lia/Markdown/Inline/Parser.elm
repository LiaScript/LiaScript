module Lia.Markdown.Inline.Parser exposing
    ( annotations
    , comment
    , eScript
    , inlines
    , javascript
    , line
    , line2
    , lineWithProblems
    , mediaReference
    , parse_inlines
    )

import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , choice
        , fail
        , ignore
        , keep
        , lazy
        , lookAhead
        , many
        , many1
        , many1Till
        , manyTill
        , map
        , maybe
        , modifyState
        , onsuccess
        , or
        , regex
        , regexWith
        , runParser
        , skip
        , string
        , succeed
        , whitespace
        , withState
        )
import Combine.Char exposing (anyChar)
import Lia.Markdown.Effect.Parser as Effect
import Lia.Markdown.Effect.Script.Types as JS
import Lia.Markdown.Footnote.Parser as Footnote
import Lia.Markdown.HTML.Attributes as Attributes exposing (Parameters, toURL)
import Lia.Markdown.HTML.Parser as HTML
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.Inline.Multimedia as Multimedia
import Lia.Markdown.Inline.Parser.Formula exposing (formula)
import Lia.Markdown.Inline.Parser.Symbol exposing (arrows, smileys)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..), combine)
import Lia.Markdown.Macro.Parser as Macro
import Lia.Markdown.Quiz.Block.Parser as Input
import Lia.Parser.Context as Context exposing (Context)
import Lia.Parser.Helper exposing (inlineCode, peek, spaces, trimSpaces)
import Lia.Parser.Input as Context
import Regex exposing (Regex)


{-| Parse a string (newlines are treated as spaces) into a list of inlines,
an unparsable string results in an empty list.
-}
parse_inlines : Context -> String -> Inlines
parse_inlines state str =
    case
        str
            |> String.replace "\n" " "
            |> runParser line state
    of
        Ok ( _, _, rslt ) ->
            rslt

        Err _ ->
            []


{-| Parse the content of an HTML comment `<!-- ... -->` with `p`, comments
starting with three dashes `<!--- ... -->` are ignored completely.
-}
comment : Parser s a -> Parser s (List a)
comment p =
    or ignore_comment
        (string "<!--"
            |> ignore whitespace
            |> keep (manyTill p (string "-->"))
        )


{-| **@private:** Special comment parser for the HTML comments that totally
ignores everything within --- three dashed lines...
-}
ignore_comment : Parser s (List a)
ignore_comment =
    string "<!---"
        |> ignore (manyTill anyChar (string "-->"))
        |> onsuccess []


{-| **@private:** Skip all following ignored and hidden comments.
-}
comments : Parser Context ()
comments =
    choice
        [ ignore_comment |> skip
        , Effect.hidden_comment
        ]
        |> many
        |> skip


{-| **@private:** The `base` and `appendix` of the current document, required
to turn relative URLs into absolute ones.
-}
defines : Parser Context ( String, String )
defines =
    withState (\c -> succeed ( c.defines.base, c.defines.appendix ))


{-| **@private:** A single HTML attribute `key="value"`.
-}
attribute : Parser Context ( String, String )
attribute =
    andThen Attributes.parse defines


{-| Parse the optional attributes `<!-- key="value" ... -->` of an element,
followed comments are skipped.
-}
annotations : Parser Context Parameters
annotations =
    peek (trimSpaces >> String.startsWith "<!--")
        (spaces
            |> keep (comment attribute)
            |> maybe
            |> map (Maybe.withDefault [])
            |> ignore comments
        )
        (succeed [])


{-| Parse a `<script>...</script>` without attributes and return its body.
-}
javascript : Parser s String
javascript =
    regexWith { caseInsensitive = True, multiline = False } "<script>"
        |> keep scriptBody


{-| **@private:** Parse a `<script key="value" ...>...</script>` and return
its attributes and body.
-}
javascriptWithAttributes : Parser Context ( Parameters, String )
javascriptWithAttributes =
    regexWith { caseInsensitive = True, multiline = False } "<script"
        |> keep (many (whitespace |> keep attribute))
        |> ignore (string ">")
        |> map Tuple.pair
        |> andMap scriptBody


{-| Parse a script and push it into the `effect_model` of the context, the
`default` attributes are appended to the attributes of the script. The result
are the attributes and the id of the next script.
-}
eScript : Parameters -> Parser Context ( Parameters, Int )
eScript default =
    javascriptWithAttributes
        |> map (Tuple.mapFirst (\attr -> List.append attr default))
        |> andThen (\( attr, script ) -> modifyState (pushScript attr script) |> onsuccess attr)
        |> map Tuple.pair
        |> andMap scriptID


{-| **@private:** Add a script to the `effect_model`, it belongs to the
current effect fragment.
-}
pushScript : Parameters -> String -> Context -> Context
pushScript attr script state =
    let
        effect_model =
            state.effect_model
    in
    { state
        | effect_model =
            { effect_model
                | javascript =
                    JS.push
                        state.defines.language
                        (state.effect_number
                            |> List.head
                            |> Maybe.withDefault 0
                        )
                        attr
                        (String.trim script)
                        effect_model.javascript
            }
    }


{-| **@private:** The number of scripts pushed so far.
-}
scriptID : Parser Context Int
scriptID =
    withState (.effect_model >> .javascript >> JS.count >> succeed)


{-| Parse a line of inlines.
-}
line : Parser Context Inlines
line =
    inlines |> many1 |> map combine


{-| Parse a line of inlines within a table cell, see `inlines2`.
-}
line2 : Parser Context Inlines
line2 =
    inlines2 |> many1 |> map combine


{-| Parse a line of inlines, where every character that cannot be parsed is
taken as it is.
-}
lineWithProblems : Parser Context Inlines
lineWithProblems =
    or inlines (regex "." |> map (\x -> Chars x []))
        |> many1
        |> map combine


{-| Parse a single inline element.

`inlines` is used recursively by many of its own sub-parsers, the `lazy` only
defers to `inlineParser`, so that the parser itself is constructed only once
and not for every parsed element.

-}
inlines : Parser Context Inline
inlines =
    lazy (\() -> inlineParser)


{-| **@private:** See `inlines`.
-}
inlineParser : Parser Context Inline
inlineParser =
    Context.checkAbort
        |> keep
            (withAnnotations
                [ code
                , Footnote.inline parse_inlines
                , reference
                , formula
                , effect
                , input
                , strings
                ]
            )


{-| **@private:** Inlines within a table cell, the cell separator `|` is not
consumed.
-}
inlines2 : Parser Context Inline
inlines2 =
    withAnnotations
        [ code
        , Footnote.inline parse_inlines
        , input
        , reference
        , formula
        , effect
        , stringExceptions
        , strings
        ]


{-| **@private:** Macros get expanded in front of every element and its
annotations. The first of the `parsers` that matches gets its annotations,
a script is checked before all others.
-}
withAnnotations : List (Parser Context (Parameters -> Inline)) -> Parser Context Inline
withAnnotations parsers =
    Macro.macro
        |> keep
            (or (peek (String.startsWith "<") (eScript [] |> map (\( attr, id ) -> Script id attr)) (fail "no script"))
                (choice parsers |> andMap (Macro.macro |> keep annotations))
            )


{-| **@private:** An effect fragment `{1}{content}`.
-}
effect : Parser Context (Parameters -> Inline)
effect =
    Effect.inline inlines |> map EInline


{-| **@private:** A quiz input `[[ ... ]]`, which is only allowed if the
context permits it.
-}
input : Parser Context (Parameters -> Inline)
input =
    Context.getPermission
        |> andThen
            (\isAllowed ->
                if isAllowed then
                    Input.pattern parse_inlines
                        |> andThen Context.add
                        |> map Quiz

                else
                    fail "no inputs allowed"
            )


{-| **@private:** An absolute URL either plain or wrapped in `<...>`.
-}
url : Parser Context String
url =
    or (regex "[a-zA-Z]+://(/)?[a-zA-Z0-9\\.\\-\\_]+\\.([a-z\\.]{2,6})(\\\\.|[^ \\]\\)\t\n\"])*")
        (string "<"
            |> keep (regex "[a-zA-Z]+://(/)?[a-zA-Z0-9\\.\\-\\_]+\\.([a-z\\.]{2,6})[^>]*")
            |> ignore (string ">")
        )
        |> map (Regex.replace escapedParenthesis (.submatches >> List.head >> Maybe.andThen identity >> Maybe.withDefault ""))
        |> andThen baseURL


{-| **@private:** `\(` and `\)` within URLs.
-}
escapedParenthesis : Regex
escapedParenthesis =
    Regex.fromString "\\\\([()])" |> Maybe.withDefault Regex.never


{-| **@private:** Make a relative URL absolute.
-}
baseURL : String -> Parser Context String
baseURL u =
    map (\( base, appendix ) -> toURL base appendix u) defines


{-| **@private:** An email address, `mailto:` is optional.
-}
email : Parser s String
email =
    string "mailto:"
        |> maybe
        |> keep (regex "[a-zA-Z0-9_.\\-]+@[a-zA-Z0-9_.\\-]+")
        |> map ((++) "mailto:")


{-| **@private:** A plain URL within the text becomes a link.
-}
inline_url : Parser Context (Parameters -> Inline)
inline_url =
    map (\u -> Ref (Link [ Chars u [] ] u Nothing)) url


{-| **@private:** The text `[...]` of a reference. Plain URLs within the text
are not turned into links, nested links are not supported by markdown and
can cause problems with the reference parsing.
-}
ref_info : Parser Context Inlines
ref_info =
    string "["
        |> ignore (Context.addAbort "]")
        |> keep (manyTill inlines (string "]"))
        |> ignore Context.popAbort
        |> map (List.map unlink >> combine)


{-| **@private:** See `ref_info`.
-}
unlink : Inline -> Inline
unlink element =
    case element of
        Ref (Link [ Chars url_ [] ] _ Nothing) [] ->
            Chars url_ []

        _ ->
            element


{-| **@private:** The optional title `"..."` or `'...'` of a reference.
-}
ref_title : Parser Context (Maybe Inlines)
ref_title =
    spaces
        |> keep (or (between_ "\"") (between_ "'"))
        |> ignore spaces
        |> map toInlines
        |> maybe


{-| **@private:** Unpack an unstyled container.
-}
toInlines : Inline -> Inlines
toInlines element =
    case element of
        Container elements [] ->
            elements

        _ ->
            [ element ]


{-| **@private:** The URL of a link, which might also be a local `#anchor`.
-}
ref_url_1 : Parser Context String
ref_url_1 =
    choice
        [ url
        , andMap (regex "#[^ \t\\)]+") Context.searchIndex
        , ref_url_2
        ]


{-| **@private:** The URL of a media reference.
-}
ref_url_2 : Parser Context String
ref_url_2 =
    or url (regex "[^\\)\n \"]*" |> andThen baseURL)


{-| **@private:** The general reference pattern `[info](url "title")`.
-}
ref_pattern :
    (info -> url -> Maybe Inlines -> Reference)
    -> Parser Context info
    -> Parser Context url
    -> Parser Context Reference
ref_pattern ref_type info_type url_type =
    map ref_type info_type
        |> ignore (string "(")
        |> andMap url_type
        |> andMap ref_title
        |> ignore (string ")")


{-| **@private:** Audio files from soundcloud or spotify can only be embedded.
-}
refToEmbed : Reference -> Reference
refToEmbed ref =
    case ref of
        Audio info ( False, link ) title ->
            if String.contains "soundcloud.com" link || String.contains "spotify.com" link then
                Embed info link title

            else
                ref

        _ ->
            ref


{-| **@private:** All kinds of references, `[...](...)`, `![...](...)`, etc.
-}
reference : Parser Context (Parameters -> Inline)
reference =
    [ refEmbed
    , refMovie
    , refAudio
    , refImage
    , refMail
    , refPreview
    , refQr
    , refLink
    ]
        |> choice
        |> (\references -> peek (String.left 1 >> (\c -> c == "[" || c == "!" || c == "?")) references (fail "no reference"))
        |> map Ref


{-| Parse a single media reference (image, movie, audio, qr-code, or embed)
with its annotations.
-}
mediaReference : Parser Context Inline
mediaReference =
    [ refImage
    , refMovie
    , refAudio
    , refQr
    , refEmbed
    ]
        |> choice
        |> map Ref
        |> andMap (Macro.macro |> keep annotations)


refMail : Parser Context Reference
refMail =
    ref_pattern Mail ref_info email


{-| **@private:** `[preview-lia](url)` or `[preview-link](url)`, the title is
ignored.
-}
refPreview : Parser Context Reference
refPreview =
    regexWith { caseInsensitive = True, multiline = False } "\\[\\w*preview-"
        |> keep
            (choice
                [ regexWith { caseInsensitive = True, multiline = False } "lia"
                    |> onsuccess Preview_Lia
                , regexWith { caseInsensitive = True, multiline = False } "link"
                    |> onsuccess Preview_Link
                ]
            )
        |> ignore (regex "\\w*]")
        |> ignore (string "(")
        |> andMap ref_url_1
        |> ignore ref_title
        |> ignore (string ")")


refQr : Parser Context Reference
refQr =
    regexWith { caseInsensitive = True, multiline = False } "\\[\\w*qr-code\\w*]"
        |> onsuccess QR_Link
        |> ignore (string "(")
        |> andMap ref_url_1
        |> andMap ref_title
        |> ignore (string ")")


refLink : Parser Context Reference
refLink =
    ref_pattern Link ref_info ref_url_1


refImage : Parser Context Reference
refImage =
    string "!"
        |> keep (ref_pattern Image ref_info ref_url_2)


refAudio : Parser Context Reference
refAudio =
    string "?"
        |> keep (ref_pattern Audio ref_info (map Multimedia.audio ref_url_2))
        |> map refToEmbed


refMovie : Parser Context Reference
refMovie =
    string "!?"
        |> keep (ref_pattern Movie ref_info (map Multimedia.movie ref_url_2))


refEmbed : Parser Context Reference
refEmbed =
    string "??"
        |> keep (ref_pattern Embed ref_info ref_url_1)


{-| **@private:** Inlines enclosed by `str`.
-}
between_ : String -> Parser Context Inline
between_ str =
    between_2 str str


{-| **@private:** Inlines enclosed by `begin` and `end`.
-}
between_2 : String -> String -> Parser Context Inline
between_2 begin end =
    string begin
        |> keep (many1Till inlines (string end))
        |> map toContainer


{-| **@private:** Wrap multiple inlines into a container.
-}
toContainer : List Inline -> Inline
toContainer inline_list =
    case combine inline_list of
        [ one ] ->
            one

        moreThanOne ->
            Container moreThanOne []


{-| **@private:** Text, typography, styles, and inline HTML.
-}
strings : Parser Context (Parameters -> Inline)
strings =
    Context.checkAbort
        |> keep
            (choice
                [ inline_url
                , ellipsis
                , stringBase
                , arrows
                , dashes
                , smileys
                , stringEscape
                , stringWithStyle
                , stringSpaces
                , HTML.parse inlines |> map IHTML
                , stringCharacters
                , lineBreak
                , stringBase2
                ]
            )


{-| **@private:** Bold, italic, etc. and quoted text.
-}
stringWithStyle : Parser Context (Parameters -> Inline)
stringWithStyle =
    choice
        [ between_ "**" |> map Bold
        , between_ "__" |> map Bold
        , between_ "*" |> map Italic
        , between_ "_" |> map Italic
        , between_ "~~" |> map Underline
        , between_ "~" |> map Strike
        , between_ "^" |> map Superscript
        , stringQuote
        ]


stringBase : Parser s (Parameters -> Inline)
stringBase =
    regex "[^\\[\\]\\(\\)@*+_~:;`\\^{}\\\\\\n<>=$ \"\\-|']+"
        |> map Chars


stringEscape : Parser s (Parameters -> Inline)
stringEscape =
    string "\\"
        |> keep (regex "[@\\^*_+~`\\\\${}\\[\\]|#\\-<>'\".]")
        |> map Chars


{-| **@private:** Text in double quotes or in single quotes (preceded by a
space) gets the typographic quotation marks of the document language.
-}
stringQuote : Parser Context (Parameters -> Inline)
stringQuote =
    or
        (between_ "\""
            |> map (\text ( start, end ) -> Container [ Chars start [], text, Chars end [] ])
            |> andMap (withState (.defines >> .typographic_quotation >> .double >> succeed))
        )
        (between_2 " '" "'"
            |> map (\text ( start, end ) -> Container [ Chars (" " ++ start) [], text, Chars end [] ])
            |> andMap (withState (.defines >> .typographic_quotation >> .single >> succeed))
        )


dashes : Parser Context (Parameters -> Inline)
dashes =
    choice
        [ string "---" |> onsuccess (Chars "—")
        , string "--" |> onsuccess (Chars "–")
        ]


ellipsis : Parser Context (Parameters -> Inline)
ellipsis =
    string "..." |> onsuccess (Chars "…")


stringCharacters : Parser s (Parameters -> Inline)
stringCharacters =
    regex "[\\[\\]\\(\\)~:_;=${}\\-+\"*<>|']"
        |> map Chars


stringSpaces : Parser s (Parameters -> Inline)
stringSpaces =
    regex "[ \t]+"
        |> map Chars


stringBase2 : Parser s (Parameters -> Inline)
stringBase2 =
    regex "[^\n*+\\-]+"
        |> map Chars


{-| **@private:** Stop in front of a table cell separator.
-}
stringExceptions : Parser Context (Parameters -> Inline)
stringExceptions =
    string "|"
        |> lookAhead
        |> onsuccess (Chars "")


{-| **@private:** A backslash at the end of a line.
-}
lineBreak : Parser s (Parameters -> Inline)
lineBreak =
    string "\\\n"
        |> onsuccess (always (IHTML (InnerHtml "<br>") []))


code : Parser s (Parameters -> Inline)
code =
    inlineCode |> map Verbatim


{-| **@private:** Everything until `</script>`, strings, template strings, and
comments are consumed at once, so that they can contain a `</script>`.

TODO: update also for multiline-comments and escapes in strings

-}
scriptBody : Parser s String
scriptBody =
    regexWith { caseInsensitive = True, multiline = False } "</script>"
        |> manyTill
            ([ regex "[^@\"'`</]+" --" this is only a comment for syntax-highlighting ...
             , regex "\\s+"
             , string "@'"
             , string "@"
             , regex "'([^'\\\\\n]*|\\\\'|\\\\)*('|\n)"
             , regex "\"([^\"\\\\\n]*|\\\\\"|\\\\)*(\"|\n)"
             , regex "`([^`\\\\]*|\n|\\\\`|(\\\\)+)*`"
             , string "`"
             , regex "<(?!/)"
             , regex "/\\*[\\s\\S]*?\\*/"
             , regex "//[^<\n]*"
             , string "/"
             ]
                |> choice
            )
        |> map String.concat
