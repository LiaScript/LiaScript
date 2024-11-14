module Lia.Markdown.HTML.Parser exposing (checkClosingTag, parse)

import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , fail
        , ignore
        , keep
        , lookAhead
        , many
        , manyTill
        , map
        , maybe
        , modifyState
        , regex
        , string
        , succeed
        , whitespace
        , withState
        )
import Lia.Markdown.HTML.Attributes as Params exposing (Parameters)
import Lia.Markdown.HTML.Types as Tag exposing (Node(..))
import Lia.Parser.Context exposing (Context)
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
    (.defines >> .base >> succeed)
        |> withState
        |> andThen Params.parse


tag : Parser Context x -> ( Tag.Type, Parameters ) -> Parser Context (Node x)
tag parser ( tagType, attributes ) =
    case tagType of
        Tag.HtmlNode name ->
            succeed (Node name attributes)
                |> ignore (regex "[ \t]*>[ \t]*\n*")
                |> ignore (pushClosingTag name)
                |> andMap
                    (manyTill
                        (newlines
                            |> keep parser
                        )
                        (closingTag name)
                    )
                |> ignore popClosingTag

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
                |> map (toStringNode "svg" attributes >> InnerHtml)


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


checkClosingTag : Parser Context ()
checkClosingTag =
    withState
        (\context ->
            case context.abort.stack of
                [] ->
                    succeed ()

                name :: _ ->
                    if context.abort.isTrue then
                        fail "abort"

                    else
                        lookAhead (maybe (string name))
                            |> andThen
                                (\found ->
                                    case found of
                                        Nothing ->
                                            succeed ()

                                        Just _ ->
                                            modifyState (\s -> { s | abort = { stack = s.abort.stack, isTrue = True } })
                                                |> keep (fail "abort")
                                )
        )


pushClosingTag : String -> Parser Context ()
pushClosingTag name =
    modifyState
        (\s ->
            { s
                | abort =
                    { stack = ("</" ++ name ++ ">") :: s.abort.stack
                    , isTrue = False
                    }
            }
        )


popClosingTag : Parser Context ()
popClosingTag =
    modifyState
        (\s ->
            { s
                | abort =
                    { stack = List.drop 1 s.abort.stack
                    , isTrue = False
                    }
            }
        )
        |> ignore (succeed ())
