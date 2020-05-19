module Lia.Markdown.HTML.Attributes exposing
    ( Parameters
    , annotation
    , parse
    , toAttribute
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
        , many
        , many1
        , manyTill
        , map
        , maybe
        , or
        , regex
        , string
        , succeed
        , whitespace
        )
import Combine.Num exposing (int)
import Dict exposing (Dict)
import Hex
import Html exposing (Attribute)
import Html.Attributes as Attr
import Lia.Markdown.HTML.NamedCharacterReferences as NamedCharacterReferences


type alias Parameters =
    List ( String, String )


annotation : String -> Parameters -> List (Attribute msg)
annotation cls =
    (::) ( "class", "lia-inline " ++ cls ) >> toAttribute


toAttribute : Parameters -> List (Attribute msg)
toAttribute =
    List.map (\( key, value ) -> Attr.attribute key value)


parse : Parser context ( String, String )
parse =
    regex "[A-Za-z0-9_\\-]+"
        |> map (String.toLower >> Tuple.pair)
        |> ignore whitespace
        |> andMap tagAttributeValue
        |> ignore whitespace


tagAttributeValue : Parser context String
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


tagAttributeQuotedValue : String -> Parser context String
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


tagAttributeUnquotedValue : Parser context String
tagAttributeUnquotedValue =
    choice
        [ regex "[^\\s\"'=<>`&]+"
        , characterReference
        ]
        |> many1
        |> map (String.join "")


characterReference : Parser context String
characterReference =
    string "&"
        |> keep
            (choice
                [ namedCharacterReference |> ignore (string ";")
                , numericCharacterReference |> ignore (string ";")
                , succeed "&"
                ]
            )


namedCharacterReference : Parser context String
namedCharacterReference =
    regex "[a-zA-Z]+"
        |> map
            (\reference ->
                Dict.get reference NamedCharacterReferences.dict
                    |> Maybe.withDefault ("&" ++ reference ++ ";")
            )


numericCharacterReference : Parser context String
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


hexadecimal : Parser context Int
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
