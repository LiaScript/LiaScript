module Lia.Markdown.HTML.Parser exposing (parse)

import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , fail
        , ignore
        , keep
        , many
        , manyTill
        , map
        , maybe
        , or
        , primitive
        , putState
        , regex
        , runParser
        , string
        , succeed
        , whitespace
        , withState
        )
import Lia.Markdown.HTML.Attributes as Params exposing (Parameters)
import Lia.Markdown.HTML.Types as Tag exposing (Node(..))
import Lia.Parser.Context as Context exposing (Context)
import Lia.Parser.Helper exposing (newlines, peek, startsWith, stringTill, trimSpaces)
import Lia.Parser.Indentation as Indent
import Regex


{-| Parse an HTML element, `parser` is used for the content of plain HTML
nodes and for `<foreignObject>`s within an `<svg>`.
-}
parse : Parser Context x -> Parser Context (Node x)
parse parser =
    regex "[ \t]*<[ \t]*"
        |> keep tagName
        |> map Tuple.pair
        |> ignore whitespace
        |> andMap (many attrParser)
        |> andThen (tag parser)


{-| An attribute, relative URLs are resolved against the course base.
-}
attrParser : Parser Context ( String, String )
attrParser =
    (\c -> succeed ( c.defines.base, c.defines.appendix ))
        |> withState
        |> andThen Params.parse


tag : Parser Context x -> ( Tag.Type, Parameters ) -> Parser Context (Node x)
tag parser ( tagType, attributes ) =
    case tagType of
        Tag.HtmlNode name ->
            -- without a closing tag the content would be parsed up to the end
            -- of the input, and every tag within it again and again
            (succeed (Node name attributes)
                |> ignore (regex "[ \t]*>[ \t]*\n*")
                |> ignore (Context.addAbort ("</" ++ name ++ ">"))
                |> andMap
                    (manyTill
                        (newlines
                            |> keep parser
                        )
                        (or (closingTag name)
                            -- within a quote the closing tag follows its `> `
                            (newlines
                                |> ignore atLineStart
                                |> ignore (peek (trimSpaces >> startsWith ">") Indent.check (fail ""))
                                |> keep (closingTag name)
                            )
                        )
                    )
                |> ignore Context.popAbort
            )
                |> requireClosingOf name
                |> Context.nested

        Tag.HtmlVoidNode name ->
            succeed (Node name attributes [])
                |> ignore whitespace
                |> ignore (maybe (string "/"))
                |> ignore whitespace
                |> ignore (string ">")

        Tag.WebComponent name ->
            succeed (OuterHtml name attributes)
                |> ignore (regex "[ \t]*>")
                |> andMap (stringTill (closingTag name))
                |> requireClosing name

        Tag.LiaKeep ->
            whitespace
                |> ignore (string ">")
                |> keep (stringTill (closingTag "lia-keep"))
                |> map InnerHtml
                |> requireClosing "lia-keep"

        Tag.SVG ->
            whitespace
                |> ignore (string ">")
                |> keep (stringTill (closingTag "svg"))
                |> andThen (svg parser attributes)
                |> requireClosing "svg"


{-| **@private:** Fail at once without a closing tag, otherwise `stringTill`
or the content parser run up to the end of the input for every unclosed tag.
`findAtMost 1` stops at the first closing tag, `Regex.contains` would collect
all of them.
-}
requireClosing : String -> Parser Context a -> Parser Context a
requireClosing name p =
    peek (Regex.findAtMost 1 (closingTagRegex name) >> List.isEmpty >> not) p (fail ("no closing tag: " ++ name))


{-| **@private:** Fail at once, if the element is not closed, so that `<div>`
x 20 with a single `</div>` is not parsed in every combination of elements and
text. Opening and closing tags with the same name are counted, the element is
closed by the first closing tag on its own level, as in HTML, the innermost
opening tag gets the next closing tag. Tags within code, comments, escapes,
`<lia-keep>` and `<svg>` are skipped. Without any closing tag it fails at once,
the counting would run up to the end of the input for every unclosed tag.

shortcut: with a closing tag far behind many unclosed ones (`<b>` x n + `</b>`)
it is still quadratic, cap the input size (chat) or cache the counting.

-}
requireClosingOf : String -> Parser Context a -> Parser Context a
requireClosingOf name p =
    requireClosing name
        (peek (closes (sameTags name) 0) p (fail ("no closing tag: " ++ name)))


closes : Regex.Regex -> Int -> String -> Bool
closes tags depth input =
    let
        matches =
            Regex.findAtMost 64 tags input
    in
    case countTags depth matches of
        Nothing ->
            True

        Just level ->
            case List.reverse matches of
                last :: _ ->
                    if List.length matches < 64 then
                        False

                    else
                        closes tags level (String.dropLeft (last.index + String.length last.match) input)

                [] ->
                    False


{-| The level after all `matches`, `Nothing` if one of them closes the
element.
-}
countTags : Int -> List Regex.Match -> Maybe Int
countTags depth matches =
    case matches of
        [] ->
            Just depth

        m :: ms ->
            case m.submatches of
                (Just opening) :: _ ->
                    if String.endsWith "/>" opening then
                        countTags depth ms

                    else
                        countTags (depth + 1) ms

                _ :: (Just _) :: _ ->
                    if depth == 0 then
                        Nothing

                    else
                        countTags (depth - 1) ms

                _ ->
                    countTags depth ms


{-| Opening tags `<name ...>` (self-closing `<name/>` too) and closing tags
`</name>` (see `closingTagRegex`) of one element name, as the first and second
submatch. Code blocks, inline code, comments, escaped characters, `<lia-keep>`
and `<svg>` match without a submatch, so that tags within them are skipped.
-}
sameTags : String -> Regex.Regex
sameTags name =
    Regex.fromStringWith { caseInsensitive = True, multiline = False }
        ("`{3,}[\\s\\S]*?`{3,}|`[^`\n]*`|<!--[\\s\\S]*?-->|\\\\[\\s\\S]"
            ++ "|<lia-keep[\\s\\S]*?</lia-keep\\s*>|<svg(?=[\\s>])[\\s\\S]*?</svg\\s*>"
            ++ "|(<"
            ++ name
            ++ "(?=[\\s/>])[^>]*>)|(</[ \t]*"
            ++ name
            ++ "\\s*>)"
        )
        |> Maybe.withDefault Regex.never


{-| An `<svg>` without `<foreignObject>`s is kept as raw HTML. Otherwise the
foreignObjects are cut out and their content is parsed as Markdown, the parser
state (effects, footnotes, ...) is passed on from one to the next.
-}
svg : Parser Context x -> Parameters -> String -> Parser Context (Node x)
svg parser attributes code =
    case cutForeignObjects code of
        ( _, [] ) ->
            succeed (InnerHtml (toStringNode "svg" attributes code))

        ( svgCode, foreignObjects ) ->
            withState
                (\state ->
                    let
                        ( newState, parsed ) =
                            List.foldl
                                (\( attrString, content ) ( beforeState, list ) ->
                                    let
                                        ( afterState, blocks ) =
                                            subParse beforeState parser content
                                    in
                                    ( afterState, ( parseAttributes state attrString, blocks ) :: list )
                                )
                                ( state, [] )
                                foreignObjects
                    in
                    putState newState
                        |> keep (succeed (SvgNode attributes svgCode (List.reverse parsed)))
                )


subParse : Context -> Parser Context content -> String -> ( Context, List content )
subParse state parser code =
    case runParser (regex "[ \t\n]*" |> keep (many parser)) state (code ++ "\n") of
        Ok ( newState, _, content ) ->
            ( newState, content )

        Err _ ->
            ( state, [] )


parseAttributes : Context -> String -> Parameters
parseAttributes state code =
    case runParser (many attrParser) state code of
        Ok ( _, _, attributes ) ->
            attributes

        Err _ ->
            []


{-| Remove all `<foreignObject>`s from svg code and return them separately as
pairs of their attribute string and content:

    cutForeignObjects "<g/><foreignObject x=1><b>hi</b></foreignObject><g/>"
        == ( "<g/><g/>", [ ( "x=1", "<b>hi</b>" ) ] )

-}
cutForeignObjects : String -> ( String, List ( String, String ) )
cutForeignObjects code =
    case breakOn "<foreignObject" code of
        ( before, Just rest ) ->
            let
                ( attrString, afterTag ) =
                    breakOn ">" rest |> Tuple.mapSecond (Maybe.withDefault "")

                ( content, after ) =
                    breakOn "</foreignObject>" afterTag |> Tuple.mapSecond (Maybe.withDefault "")

                ( svgCode, foreignObjects ) =
                    cutForeignObjects after
            in
            ( before ++ svgCode, ( String.trim attrString, content ) :: foreignObjects )

        ( _, Nothing ) ->
            ( code, [] )


{-| Split at the first occurrence of `separator`, which is dropped.
-}
breakOn : String -> String -> ( String, Maybe String )
breakOn separator code =
    case String.indexes separator code of
        i :: _ ->
            ( String.left i code, Just (String.dropLeft (i + String.length separator) code) )

        [] ->
            ( code, Nothing )


toStringNode : String -> Parameters -> String -> String
toStringNode name attributes tagBody =
    "<" ++ name ++ " " ++ Params.toString attributes ++ ">" ++ tagBody ++ "</" ++ name ++ ">"


tagName : Parser Context Tag.Type
tagName =
    "\\w+(\\-\\w+)*"
        |> regex
        |> map String.toLower
        |> andThen toTag


toTag : String -> Parser Context Tag.Type
toTag name =
    case name of
        "script" ->
            fail ""

        "lia-keep" ->
            succeed Tag.LiaKeep

        "svg" ->
            succeed Tag.SVG

        _ ->
            succeed
                (if String.contains "-" name then
                    Tag.WebComponent name

                 else if isVoidElement name then
                    Tag.HtmlVoidNode name

                 else
                    Tag.HtmlNode name
                )


closingTag : String -> Parser Context ()
closingTag name =
    let
        chompName =
            regex "\\w+(\\-\\w+)*"
                |> andThen
                    (\closingName ->
                        if String.toLower closingName == name then
                            succeed ()

                        else
                            fail ("closing tag does not match opening tag: " ++ name)
                    )
    in
    regex "[ \t\n]*</[ \t]*"
        |> keep chompName
        |> ignore (regex "\\s*>")


{-| Matches anything that `closingTag name` accepts.
-}
closingTagRegex : String -> Regex.Regex
closingTagRegex name =
    Regex.fromStringWith { caseInsensitive = True, multiline = False } ("</[ \t]*" ++ name ++ "\\s*>")
        |> Maybe.withDefault Regex.never


isVoidElement : String -> Bool
isVoidElement name =
    List.member name voidElements


voidElements : List String
voidElements =
    [ "area"
    , "base"
    , "br"
    , "col"
    , "embed"
    , "hr"
    , "img"
    , "input"
    , "link"
    , "meta"
    , "param"
    , "source"
    , "track"
    , "wbr"
    ]


{-| **@private:** Succeed only at the start of a line, so that the quote prefix
of a closing tag (see `tag`) is not taken from a `>` within the line.
-}
atLineStart : Parser s ()
atLineStart =
    primitive
        (\state stream ->
            if stream.position == 0 || String.slice (stream.position - 1) stream.position stream.data == "\n" then
                ( state, stream, Ok () )

            else
                ( state, stream, Err [ "not at line start" ] )
        )
