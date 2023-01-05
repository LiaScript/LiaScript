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
        , regex
        , string
        , succeed
        , whitespace
        , withState
        )
import Lia.Markdown.HTML.Attributes as Params exposing (Parameters)
import Lia.Markdown.HTML.Types as Tag exposing (Node(..))
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (stringTill)


parse : Parser Context x -> Parser Context (Node x)
parse parser =
    regex "[ \\t]*<[ \\t]*"
        |> keep tagName
        |> map Tuple.pair
        |> ignore whitespace
        |> andMap (many attrParser)
        |> andThen (tag parser)


attrParser : Parser Context ( String, String )
attrParser =
    (.defines >> .base >> succeed)
        |> withState
        |> andThen Params.parse


tag : Parser Context x -> ( Tag.Type, Parameters ) -> Parser Context (Node x)
tag parser ( tagType, attributes ) =
    case tagType of
        Tag.HtmlNode name ->
            succeed (Node name attributes)
                |> ignore (regex "[ \\t]*>[ \\t]*\\n*")
                |> andMap
                    (manyTill
                        (parser |> ignore (regex "[\\n]*"))
                        (closingTag name)
                    )

        Tag.HtmlVoidNode name ->
            succeed (Node name attributes [])
                |> ignore whitespace
                |> ignore (maybe (string "/"))
                |> ignore whitespace
                |> ignore (string ">")

        Tag.WebComponent name ->
            stringTill (closingTag name)
                |> map (toStringNode name attributes)
                |> map InnerHtml

        Tag.LiaKeep ->
            whitespace
                |> ignore (string ">")
                |> keep (stringTill (closingTag "lia-keep"))
                |> map InnerHtml


toStringNode : String -> Parameters -> String -> String
toStringNode name attributes tagBody =
    "<"
        ++ name
        ++ " "
        ++ (attributes
                |> List.map (\( key, value ) -> key ++ "=\"" ++ value ++ "\"")
                |> String.join " "
           )
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
            -- SVG and web-components are handled equally, since elm cannot directly
            -- show SVGs at the moment ... later this might change if there is a tighter
            -- integration between LiaScript and SVG
            succeed (Tag.WebComponent name)

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
    regex "[ \\t\\n]*</[ \\t]*"
        |> keep chompName
        |> ignore (regex "[ \\t\\n]*>")


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
