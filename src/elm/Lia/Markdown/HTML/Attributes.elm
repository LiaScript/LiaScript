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
        , many
        , many1
        , map
        , or
        , regex
        , string
        , succeed
        , whitespace
        )
import Combine.Num exposing (int)
import Dict
import Hex
import Html exposing (Attribute)
import Html.Attributes as Attr
import Lia.Markdown.HTML.NamedCharacterReferences as NamedCharacterReferences


{-| Used internaly to store HTML parameter as Tuples of `(name, value)`.

**Note:** The name value is automatically stored in lowercase.

-}
type alias Parameters =
    List ( String, String )


{-| Search the attribute list for a certain key, the corresponding value will be
returned, if present.

    get "height" [ ( "width", "100%" ), ( "height", "300px" ) ]
        == Just "300px"

-}
get : String -> Parameters -> Maybe String
get name attr =
    case attr of
        [] ->
            Nothing

        ( key, value ) :: xs ->
            if key == name then
                Just value

            else
                get name xs


{-| Filter a list of Parameters with a list of names, so that only Parameters
get returned that are within the filter list:

    filterNames
        [ "height" ]
        [ ( "width", "100%" ), ( "height", "300px" ) ]
        == [ ( "height", "300px" ) ]

-}
filterNames : List String -> Parameters -> Parameters
filterNames names =
    List.filter (isMemberOf names)


isMemberOf : List String -> ( String, x ) -> Bool
isMemberOf names ( name, _ ) =
    List.member name names


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


{-| Add the classname and to the parameter list and translate them into a list
of attributes...
-}
annotation : String -> Parameters -> List (Attribute msg)
annotation cls =
    (::) ( "class", cls ) >> toAttribute


{-| Translate a list of Parameters into HTML attributes.
-}
toAttribute : Parameters -> List (Attribute msg)
toAttribute =
    List.map (\( key, value ) -> Attr.attribute key value)


{-| Parameters of type:

    "src", "href", "data", "data-src", "formaction", "poster"

are checked if they definee a relative or absolute path. If it is a relative
URL, then the base-URL is automatically added to the front:

    base "http://base.url/" ( "src", "pic.jpg" )
        == ( "src", "http://base.url/pic.jpg" )

-}
base : String -> ( String, String ) -> ( String, String )
base url ( key, value ) =
    ( key
    , if
        key
            == "src"
            || key
            == "href"
            || key
            == "data"
            || key
            == "data-src"
            || key
            == "formaction"
            || key
            == "poster"
      then
        toURL url value

      else
        value
    )


{-| Used to identify relative paths. If the URL does not start with "http", the
basis is automatically added:

    toUrl "https://base.url/" "pic.jpg"
        == "https://base.url/pic.jpg"

    toUtl "https://base.url/" "http://url.de/pic.jpg"
        == "http://url.de/pic.jpg"

-}
toURL : String -> String -> String
toURL basis url =
    if
        url
            |> String.toLower
            |> String.startsWith "http"
    then
        url

    else
        basis ++ url


{-| General HTML attribute parser, the base-URL is added in front of relative
paths, as defined in function `base`:

    Combine.parse (parse "http://base.url/" "SRC = 'img.jpg'")
        == Ok ( "src", "http://base.url/img.jpg" )

-}
parse : String -> Parser context ( String, String )
parse url =
    regex "[A-Za-z0-9_\\-]+"
        |> map (String.toLower >> Tuple.pair)
        |> ignore whitespace
        |> andMap tagAttributeValue
        |> ignore whitespace
        |> map (base url)


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


tagAttributeQuotedValue : String -> Parser context String
tagAttributeQuotedValue quote =
    string quote
        |> keep
            (choice
                [ ("([^" ++ quote ++ "]*|\\\\" ++ quote ++ "|\\\\)*")
                    |> regex
                    |> map (String.replace ("\\" ++ quote) quote)
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
