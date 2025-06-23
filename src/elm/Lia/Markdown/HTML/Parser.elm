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


parse : Parser Context x -> Parser Context (Node x)
parse parser =
    regex "[ \t]*<[ \t]*"
        |> keep tagName
        |> map Tuple.pair
        |> ignore whitespace
        |> andMap (many attrParser)
        |> andThen (tag parser)


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
                |> map Tuple.pair
                |> andMap (withState (\state -> succeed state))
                |> map
                    (\( code, state ) ->
                        let
                            ( svgCode, foreignObjects ) =
                                getAllForeignObjects state code

                            ( newState, parsedForeignObjects ) =
                                foreignObjects
                                    |> List.foldl
                                        (\( attr, content ) ( beforeState, accList ) ->
                                            let
                                                ( afterState, parsedContent ) =
                                                    subParse beforeState parser content
                                            in
                                            ( afterState, ( attr, parsedContent ) :: accList )
                                        )
                                        ( state, [] )
                        in
                        case foreignObjects of
                            [] ->
                                ( state
                                , toStringNode "svg" attributes svgCode |> InnerHtml
                                )

                            _ ->
                                ( newState
                                , SvgNode attributes svgCode parsedForeignObjects
                                )
                    )
                |> andThen
                    (\( state, node ) ->
                        putState state
                            |> keep (succeed node)
                    )


subParse : Context -> Parser Context content -> String -> ( Context, List content )
subParse defines parser code =
    case
        runParser
            (regex "( |\t|\n)*" |> keep (many parser))
            defines
            (code ++ "\n")
    of
        Ok ( state, stream, s ) ->
            ( state, s )

        _ ->
            ( defines, [] )


getAllForeignObjects : Context -> String -> ( String, List ( Parameters, String ) )
getAllForeignObjects context svgCode =
    let
        findForeignObjects remaining offset results svgParts =
            case String.indexes "<foreignObject" remaining of
                [] ->
                    -- No more foreignObjects found, return the result
                    ( String.join "" (List.reverse (remaining :: svgParts))
                    , List.reverse results
                    )

                startIndex :: _ ->
                    let
                        -- Add the SVG part before the foreignObject
                        beforeForeignObject =
                            String.left startIndex remaining

                        contentStart =
                            startIndex + String.length "<foreignObject"

                        afterStart =
                            String.dropLeft contentStart remaining

                        tagEndIndex =
                            Maybe.withDefault (String.length afterStart) (String.indexes ">" afterStart |> List.head)

                        -- Extract the attributes string
                        attributesString =
                            String.slice 0 tagEndIndex afterStart
                                |> String.trim

                        -- Parse the attributes into Parameters
                        attributes =
                            parseAttributes attributesString

                        contentStartIndex =
                            contentStart + tagEndIndex + 1

                        content =
                            String.dropLeft contentStartIndex remaining

                        endTagIndex =
                            Maybe.withDefault (String.length content) (String.indexes "</foreignObject>" content |> List.head)

                        foreignObjectContent =
                            String.left endTagIndex content

                        newRemaining =
                            String.dropLeft (endTagIndex + String.length "</foreignObject>") content

                        -- Continue with the rest
                        newSvgParts =
                            beforeForeignObject :: svgParts
                    in
                    findForeignObjects newRemaining
                        (offset + contentStartIndex + endTagIndex + String.length "</foreignObject>")
                        (( attributes, foreignObjectContent ) :: results)
                        newSvgParts

        -- Helper function to parse attributes string into Parameters
        parseAttributes : String -> Parameters
        parseAttributes attrStr =
            case runParser (many attrParser) context attrStr of
                Ok ( _, _, attr ) ->
                    -- If parsing is successful, return the attributes
                    attr

                Err _ ->
                    -- If parsing fails, return an empty list
                    []
    in
    findForeignObjects svgCode 0 [] []


toStringNode : String -> Parameters -> String -> String
toStringNode name attributes tagBody =
    "<"
        ++ name
        ++ " "
        ++ Params.toString attributes
        ++ ">"
        ++ tagBody
        ++ "</"
        ++ name
        ++ ">"


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
    regex "\n*</[ \t]*"
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
