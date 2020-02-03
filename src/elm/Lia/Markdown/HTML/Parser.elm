module Lia.Markdown.HTML.Parser exposing (parse)

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
        , many
        , many1
        , manyTill
        , map
        , maybe
        , modifyState
        , optional
        , or
        , regex
        , runParser
        , skip
        , string
        , succeed
        , whitespace
        , withState
        )
import Combine.Char exposing (anyChar)
import Combine.Num exposing (int)
import Dict exposing (Dict)
import Hex
import Lia.Markdown.HTML.NamedCharacterReferences as NamedCharacterReferences
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.Macro.Parser as Macro
import Lia.Parser.Context exposing (Context, searchIndex)
import Lia.Parser.Helper exposing (spaces, stringTill)


parse : Parser Context x -> Parser Context (Node x)
parse parser =
    regex "[ \\t]*<[ \\t]*"
        |> keep tagName
        |> map Tuple.pair
        |> ignore whitespace
        |> andMap tagAttributes
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
                        |> ignore (regex "[ \\t]*>[ \\t\\n]*")
                        |> andMap
                            (manyTill
                                (parser |> ignore (regex "[ \\t\\n]*"))
                                (closingTag name)
                            )
            )


tagName : Parser Context String
tagName =
    "\\w+(\\-\\w+)?"
        |> regex
        |> map String.toLower
        |> andThen unscript


unscript : String -> Parser Context String
unscript name =
    if name == "script" then
        fail ""

    else
        succeed name


tagAttributes : Parser Context (List ( String, String ))
tagAttributes =
    many tagAttribute


tagAttribute : Parser Context ( String, String )
tagAttribute =
    regex "\\w+"
        |> map (String.toLower >> Tuple.pair)
        |> ignore whitespace
        |> andMap tagAttributeValue
        |> ignore whitespace


tagAttributeValue : Parser Context String
tagAttributeValue =
    or
        (string "="
            |> ignore whitespace
            |> keep
                (choice
                    [ tagAttributeUnquotedValue
                    , tagAttributeQuotedValue "\""
                    , tagAttributeQuotedValue "'"
                    ]
                )
        )
        (succeed "")


tagAttributeQuotedValue : String -> Parser Context String
tagAttributeQuotedValue quote =
    string quote
        |> keep
            (choice
                [ regex <| "[^&" ++ quote ++ "]*"
                , characterReference
                ]
                |> many
                |> map (String.join "")
            )
        |> ignore (string quote)


tagAttributeUnquotedValue : Parser Context String
tagAttributeUnquotedValue =
    choice
        [ regex "[^\\s\"'=<>`&]+"
        , characterReference
        ]
        |> many1
        |> map (String.join "")


characterReference : Parser Context String
characterReference =
    string "&"
        |> keep
            (choice
                [ namedCharacterReference |> ignore (string ";")
                , numericCharacterReference |> ignore (string ";")
                , succeed "&"
                ]
            )


namedCharacterReference : Parser Context String
namedCharacterReference =
    regex "[a-zA-Z]+"
        |> map
            (\reference ->
                Dict.get reference NamedCharacterReferences.dict
                    |> Maybe.withDefault ("&" ++ reference ++ ";")
            )


numericCharacterReference : Parser Context String
numericCharacterReference =
    let
        codepoint =
            choice
                [ regex "(x|X)" |> keep hexadecimal
                , regex "0*" |> keep int
                ]
    in
    string "#"
        |> keep (map (Char.fromCode >> String.fromChar) codepoint)


hexadecimal : Parser Context Int
hexadecimal =
    regex "[0-9a-fA-F]+"
        |> andThen
            (\hex ->
                case Hex.fromString (String.toLower hex) of
                    Ok value ->
                        succeed value

                    Err err ->
                        fail err
            )


closingTag : String -> Parser Context ()
closingTag name =
    let
        chompName =
            regex "\\w+(-\\w+)?"
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
