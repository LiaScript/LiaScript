module Lia.Markdown.HTML.Attributes exposing
    ( Parameters
    , annotation
    , filterNames
    , get
    , isNotSet
    , isSet
    , isSetMaybe
    , parse
    , toAttribute
    , toString
    , toURL
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
        , many1
        , map
        , or
        , regex
        , string
        , succeed
        , whitespace
        )
import Combine.Num exposing (int)
import Hex
import Html exposing (Attribute)
import Html.Attributes as Attr
import Lia.Markdown.HTML.NamedCharacterReferences as NamedCharacterReferences
import Lia.Parser.PatReplace exposing (link)
import List.Extra


{-| Used internally to store HTML parameter as Tuples of `(name, value)`.

**Note:** Names are stored as written by the author, `viewBox` has to stay
`viewBox` for SVG. Lookups (`get`, `filterNames`, `isSet`, ...) are
case-insensitive.

-}
type alias Parameters =
    List ( String, String )


{-| Search the attribute list for a certain key, the corresponding value will be
returned, if present. Keys are matched case-insensitively, `name` has to be
passed in lowercase.

    get "height" [ ( "width", "100%" ), ( "height", "300px" ) ]
        == Just "300px"

-}
get : String -> Parameters -> Maybe String
get name =
    List.Extra.find (Tuple.first >> String.toLower >> (==) name)
        >> Maybe.map Tuple.second


{-| Filter a list of Parameters with a list of names, so that only Parameters
get returned that are within the filter list:

    filterNames
        [ "height" ]
        [ ( "width", "100%" ), ( "height", "300px" ) ]
        == [ ( "height", "300px" ) ]

-}
filterNames : List String -> Parameters -> Parameters
filterNames names =
    List.filter (\( name, _ ) -> List.member (String.toLower name) names)


{-| Return True or False, if a parameter is set in the parameter list:

    isSet "data" [ ( "data", "TrUe" ) ] == True

    isSet "data" [ ( "data", "1" ) ] == True

    isSet "data" [ ( "data", "" ) ] == True

    isSet "data" [ ( "data", "Moodle" ) ] == False

    isSet "data" [ ( "dat", "Moodle" ) ] == False

-}
isSet : String -> Parameters -> Bool
isSet name =
    isSetMaybe name >> Maybe.withDefault False


{-| Return `Maybe True` or `Maybe False`, if a parameter is set in the parameter
list:

    isSetMaybe "data" [ ( "data", "TrUe" ) ] == Just True

    isSetMaybe "data" [ ( "data", "1" ) ] == Just True

    isSetMaybe "data" [ ( "data", "" ) ] == Just True

    isSetMaybe "data" [ ( "data", "Moodle" ) ] == Just False

    isSetMaybe "data" [ ( "dat", "Moodle" ) ] == Nothing

-}
isSetMaybe : String -> Parameters -> Maybe Bool
isSetMaybe name =
    get name
        >> Maybe.map (String.trim >> String.toLower >> isTrue)


{-| Return True if the parameter is **Not** set in the parameter list:

    isNotSet "data" [ ( "data", "TrUe" ) ] == True

    isNotSet "data" [ ( "data", "1" ) ] == True

    isNotSet "data" [ ( "data", "" ) ] == True

    isNotSet "data" [ ( "data", "Moodle" ) ] == False

    isNotSet "data" [ ( "dat", "Moodle" ) ] == True

-}
isNotSet : String -> Parameters -> Bool
isNotSet name =
    isSetMaybe name >> Maybe.withDefault True


{-| **@private:** Check if a parameter is set to true, which is the case if the
passed string is somehow set to true:

    isTrue "" == True

    isTrue "1" == True

    isTrue "true" == True

    isTrue "everything else" == False

-}
isTrue : String -> Bool
isTrue val =
    val == "" || val == "1" || val == "true"


{-| Add a class-name to the parameter list and translate them into a list of
attributes.
-}
annotation : String -> Parameters -> List (Attribute msg)
annotation cls =
    (::) ( "class", cls ) >> toAttribute


{-| Translate a list of Parameters into HTML attributes.
-}
toAttribute : Parameters -> List (Attribute msg)
toAttribute =
    List.map (\( key, value ) -> Attr.attribute key value)


{-| Serialize Parameters back into HTML, empty values are written as plain names:

    toString [ ( "width", "100%" ), ( "hidden", "" ) ] == "width=\"100%\" hidden"

-}
toString : Parameters -> String
toString =
    List.map
        (\( key, value ) ->
            key
                ++ (if String.isEmpty value then
                        ""

                    else
                        "=\"" ++ value ++ "\""
                   )
        )
        >> String.join " "


{-| Parameters of type:

    "src", "href", "data", "data-src", "formaction", "poster"

are checked if they define a relative or absolute path. If it is a relative
URL, then the base-URL is automatically added to the front, `SRC` is treated
like `src`:

    base "http://base.url/" "" ( "src", "pic.jpg" )
        == ( "src", "http://base.url/pic.jpg" )

-}
base : String -> String -> ( String, String ) -> ( String, String )
base url appendix ( key, value ) =
    if List.member (String.toLower key) [ "src", "href", "data", "data-src", "formaction", "poster" ] then
        ( key, toURL url appendix value )

    else
        ( key, value )


{-| Used to identify relative paths. If the URL does not start with an allowed
protocol or `#`, the basis and the appendix are added:

    toURL "https://base.url/" "?ref=1" "pic.jpg"
        == "https://base.url/pic.jpg?ref=1"

    toURL "https://base.url/" "" "http://url.de/pic.jpg"
        == "http://url.de/pic.jpg"

-}
toURL : String -> String -> String -> String
toURL basis appendix url =
    if allowedProtocol url || String.startsWith "#" url then
        url

    else
        link (basis ++ url ++ appendix)


{-| URLs with these protocols are absolute and never touched.
-}
allowedProtocol : String -> Bool
allowedProtocol url =
    List.member
        (url
            |> String.split ":"
            |> List.head
            |> Maybe.withDefault ""
            |> String.toLower
        )
        protocols


protocols : List String
protocols =
    [ "https"
    , "http"
    , "data"
    , "file"
    , "hyper"
    , "dat"
    , "ipfs"
    , "ipns"
    , "blob"
    , "mailto"
    , "tel"
    , "sms"
    , "geo"
    , "webcal"
    , "sip"
    , "sips"
    , "ftp"
    , "ftps"
    , "magnet"
    , "bitcoin"
    , "matrix"
    , "agent" -- experimental protocol
    ]


{-| General HTML attribute parser, the base-URL is added in front of relative
paths, as defined in function `base`:

    Combine.parse (parse "http://base.url/" "SRC = 'img.jpg'")
        == Ok ( "src", "http://base.url/img.jpg" )

-}
parse : ( String, String ) -> Parser context ( String, String )
parse ( url, appendix ) =
    attributeName
        |> map Tuple.pair
        |> ignore whitespace
        |> andMap tagAttributeValue
        |> ignore whitespace
        |> map (base url appendix)


attributeName : Parser context String
attributeName =
    regex "[A-Za-z0-9_\\-:]+"


{-| **@private**: A tag attribute-value can be set with:

  - single quote:

        parse tagAttributeValue "= '100%'" == Ok "100%"

  - double quotes:

        parse tagAttributeValue "= \"100%\"" == Ok "100%"

  - no quotes:

        parse tagAttributeValue "= 100%" == Ok "100%"

  - or not set:

        parse tagAttributeValue "    " == Ok ""

-}
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


{-| **@private**: Everything up to the next quote, taken as is. Character
references are not decoded, `toString` writes the value back unescaped into
SVG code. There is no escaping, `\"` ends the value at the backslash, as in
HTML.
-}
tagAttributeQuotedValue : String -> Parser context String
tagAttributeQuotedValue quote =
    string quote
        |> keep (regex ("[^" ++ quote ++ "]*"))
        |> ignore (string quote)


tagAttributeUnquotedValue : Parser context String
tagAttributeUnquotedValue =
    choice
        [ regex "[^\\s\"'=<>`&]+"
        , characterReference
        ]
        |> many1
        |> map String.concat


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
                NamedCharacterReferences.get reference
                    |> Maybe.withDefault ("&" ++ reference ++ ";")
            )


numericCharacterReference : Parser context String
numericCharacterReference =
    let
        codePoint =
            choice
                [ regex "(x|X)" |> keep hexadecimal
                , regex "0*" |> keep int
                ]
    in
    string "#"
        |> keep (map (Char.fromCode >> String.fromChar) codePoint)


{-| **@private: ** Hexadecimal Strings are converted to Int

    parse hexadecimal "FF" == Ok 255

    parse hexadecimal "QQ" == Err "Invalid hexadecimal string"

-}
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
