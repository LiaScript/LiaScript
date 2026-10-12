module Lia.Parser.Preprocessor exposing
    ( section
    , title_tag
    )

{-| Split a course into sections: the title of a section is parsed directly,
its body is kept as a string and parsed later on demand.
-}

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
        , map
        , optional
        , regex
        , regexWith
        , string
        , succeed
        , withColumn
        , withState
        )
import Dict exposing (Dict)
import Lia.Markdown.Inline.Parser exposing (line)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Parser.Context exposing (Context, getLine)
import Lia.Parser.Helper exposing (newline, spaces1)
import Lia.Section as Section


{-| The `#`s of a title, the result is the level.
-}
title_tag : Parser Context Int
title_tag =
    regex "#+"
        |> map String.length
        |> ignore spaces1


{-| Fail at the beginning of a line, used to stop at the next title.
-}
notFirstColumn : Int -> Parser s ()
notFirstColumn c =
    if c == 0 then
        fail ""

    else
        succeed ()


{-| The rest of the title line as inline elements.
-}
title_str : Parser Context Inlines
title_str =
    line |> ignore newline


{-| Everything until the next title, code blocks, comments and HTML elements
are skipped as a whole, so that a `#` within them does not start a section.
-}
body : Parser Context String
body =
    [ regex "(?:[^#`<]+|[\\x0D\n]+|<!--[\\S\\s]{0,1000}?-->)" -- comment
    , regex "(`{3,})[\\S\\s]*?\\1" -- code_block or ascii art
    , regex "`.+?`" -- code_block or ascii art
    , regexWith { caseInsensitive = True, multiline = False } "<(?:area|base|br|col|embed|hr|img|input|link|meta|param|source|track|wbr)[ \t]*/?>"
    , regex "(?:<([\\w+\\-]+)[\\S\\s]*?<[ \t]*/[ \t]*\\1[ \t]*>|`|<)"
    , regex "#+(\\w|[^\\u0000-\\u007F]|[ \t]*\n)"
    , withColumn notFirstColumn |> keep (string "#")
    ]
        |> choice
        |> many
        |> map String.concat


{-| A section with its title and the unparsed body, plus the editor line where
the next section starts.
-}
section : Parser Context ( Section.Base, Int )
section =
    title_tag
        |> map base
        |> andMap getLine
        |> andMap
            (title_str
                |> map Tuple.pair
                |> andMap (withState (.backup >> succeed))
                |> andThen memo
            )
        |> andMap body
        |> map Tuple.pair
        |> andMap getLine


base : Int -> Int -> ( Inlines, String ) -> String -> Section.Base
base indentation_ line_ ( title_, head ) tail =
    Section.Base indentation_ line_ title_ (head ++ tail)


memo : ( Inlines, Dict String String ) -> Parser Context ( Inlines, String )
memo ( key, dict ) =
    Dict.get (stringify key) dict
        |> Maybe.map (string >> optional "")
        |> Maybe.withDefault (succeed "")
        |> map (Tuple.pair key)



-->> Maybe.withDefault (fail "not head not found")
