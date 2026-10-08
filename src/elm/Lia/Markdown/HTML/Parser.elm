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
import Lia.Parser.Helper exposing (newlines, stringTill)


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
            succeed (Node name attributes)
                |> ignore (regex "[ \t]*>[ \t]*\n*")
                |> ignore (Context.addAbort ("</" ++ name ++ ">"))
                |> andMap
                    (manyTill
                        (newlines
                            |> keep parser
                        )
                        (closingTag name)
                    )
                |> ignore Context.popAbort

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

        Tag.LiaKeep ->
            whitespace
                |> ignore (string ">")
                |> keep (stringTill (closingTag "lia-keep"))
                |> map InnerHtml

        Tag.SVG ->
            whitespace
                |> ignore (string ">")
                |> keep (stringTill (closingTag "svg"))
                |> andThen (svg parser attributes)


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
