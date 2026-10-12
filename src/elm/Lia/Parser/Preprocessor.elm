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
        , choice
        , fail
        , ignore
        , keep
        , many
        , map
        , regex
        , regexWith
        , string
        , succeed
        , withColumn
        )
import Lia.Markdown.Inline.Parser exposing (line)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Parser.Context exposing (Context)
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


{-| A section with its title and the unparsed body.
-}
section : Parser Context Section.Base
section =
    title_tag
        |> map Section.Base
        |> andMap title_str
        |> andMap body
