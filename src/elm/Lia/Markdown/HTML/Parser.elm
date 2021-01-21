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
        , regex
        , string
        , succeed
        , whitespace
        , withState
        )
import Lia.Markdown.HTML.Attributes as Params
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (stringTill)


parse : Parser Context x -> Parser Context (Node x)
parse =
    tag >> or liaKeep


tag : Parser Context x -> Parser Context (Node x)
tag parser =
    let
        attr =
            withState (.defines >> .base >> succeed)
                |> andThen Params.parse
    in
    regex "[ \\t]*<[ \\t]*"
        |> keep tagName
        |> map Tuple.pair
        |> ignore whitespace
        |> andMap (many attr)
        |> andThen
            (\( name, attributes ) ->
                if isVoidElement name then
                    succeed (Node name attributes [])
                        |> ignore whitespace
                        |> ignore (maybe (string "/"))
                        |> ignore whitespace
                        |> ignore (string ">")

                else
                    succeed (Node name attributes)
                        |> ignore (regex "[ \\t]*>[ \\t]*\\n*")
                        |> andMap
                            (manyTill
                                (parser |> ignore (regex "[\\n]*"))
                                (closingTag name)
                            )
            )


liaKeep : Parser Context (Node x)
liaKeep =
    string "<lia-keep>"
        |> keep (stringTill (string "</lia-keep>"))
        |> map InnerHtml


tagName : Parser Context String
tagName =
    "\\w+(\\-\\w+)*"
        |> regex
        |> map String.toLower
        |> andThen unscript


unscript : String -> Parser Context String
unscript name =
    if name == "script" then
        fail ""

    else
        succeed name


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



-- webcomponents
-- isWebComponent : String -> Bool
-- isWebComponent =
--    String.contains "-"
-- Void elements


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
