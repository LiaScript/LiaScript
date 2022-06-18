module Lia.Markdown.Inline.Parser exposing
    ( annotations
    , comment
    , eScript
    , inlines
    , javascript
    , line
    , lineWithProblems
    , mediaReference
    , parse_inlines
    )

import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , choice
        , ignore
        , keep
        , lazy
        , many
        , many1
        , many1Till
        , manyTill
        , map
        , maybe
        , modifyState
        , onsuccess
        , or
        , regex
        , regexWith
        , runParser
        , skip
        , string
        , succeed
        , whitespace
        , withState
        )
import Combine.Char exposing (anyChar)
import Lia.Markdown.Effect.Parser as Effect
import Lia.Markdown.Effect.Script.Types as JS
import Lia.Markdown.Footnote.Parser as Footnote
import Lia.Markdown.HTML.Attributes as Attributes exposing (Parameters, toURL)
import Lia.Markdown.HTML.Parser as HTML
import Lia.Markdown.Inline.Multimedia as Multimedia
import Lia.Markdown.Inline.Parser.Formula exposing (formula)
import Lia.Markdown.Inline.Parser.Symbol exposing (arrows, smileys)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..), combine)
import Lia.Markdown.Macro.Parser as Macro
import Lia.Parser.Context exposing (Context, searchIndex)
import Lia.Parser.Helper exposing (spaces)


parse_inlines : Context -> String -> Inlines
parse_inlines state str =
    case
        str
            |> String.replace "\n" " "
            |> runParser line state
    of
        Ok ( _, _, rslt ) ->
            rslt

        Err _ ->
            []


comment : Parser s a -> Parser s (List a)
comment p =
    string "<!--"
        |> ignore whitespace
        |> keep (manyTill p (string "-->"))


comments : Parser Context ()
comments =
    Effect.hidden_comment
        |> or (skip (comment anyChar))
        |> many
        |> skip


annotations : Parser Context Parameters
annotations =
    let
        attr =
            withState (.defines >> .base >> succeed)
                |> andThen Attributes.parse
    in
    spaces
        |> keep (comment attr)
        |> maybe
        |> map (Maybe.withDefault [])
        |> ignore comments


javascript : Parser s String
javascript =
    regexWith True False "<script>"
        |> keep scriptBody


javascriptWithAttributes : Parser Context ( Parameters, String )
javascriptWithAttributes =
    let
        attr =
            withState (.defines >> .base >> succeed)
                |> andThen Attributes.parse
    in
    regexWith True False "<script"
        |> keep (many (whitespace |> keep attr))
        |> ignore (string ">")
        |> map Tuple.pair
        |> andMap scriptBody


eScript : Parameters -> Parser Context ( Parameters, Int )
eScript default =
    let
        state ( attr, script ) =
            modifyState
                (\s ->
                    let
                        effect_model =
                            s.effect_model
                    in
                    { s
                        | effect_model =
                            { effect_model
                                | javascript =
                                    JS.push
                                        s.defines.language
                                        (s.effect_number
                                            |> List.head
                                            |> Maybe.withDefault 0
                                        )
                                        attr
                                        (String.trim script)
                                        effect_model.javascript
                            }
                    }
                )
                |> keep (succeed attr)
    in
    javascriptWithAttributes
        |> map (Tuple.mapFirst (\attr -> List.append attr default))
        |> andThen state
        |> map Tuple.pair
        |> andMap scriptID


scriptID : Parser Context Int
scriptID =
    withState (.effect_model >> .javascript >> JS.count >> succeed)


line : Parser Context Inlines
line =
    inlines |> many1 |> map combine


lineWithProblems : Parser Context Inlines
lineWithProblems =
    or inlines (regex "." |> map (\x -> Chars x []))
        |> many1
        |> map combine


inlines : Parser Context Inline
inlines =
    lazy <|
        \() ->
            Macro.macro
                |> keep
                    ([ code
                     , Footnote.inline parse_inlines
                     , reference
                     , formula
                     , inlines
                        |> Effect.inline
                        |> map EInline
                     , strings
                     ]
                        |> choice
                        |> andMap (Macro.macro |> keep annotations)
                        |> or (eScript [] |> map (\( attr, id ) -> Script id attr))
                    )


url : Parser Context String
url =
    regex "[a-zA-Z]+://(/)?[a-zA-Z0-9\\.\\-\\_]+\\.([a-z\\.]{2,6})[^ \\]\\)\t\n]*"
        |> andThen baseURL


baseURL : String -> Parser Context String
baseURL u =
    withState (.defines >> .base >> succeed)
        |> map (\base -> toURL base u)


email : Parser s String
email =
    string "mailto:"
        |> maybe
        |> keep (regex "[a-zA-Z0-9_.\\-]+@[a-zA-Z0-9_.\\-]+")
        |> map ((++) "mailto:")


inline_url : Parser Context (Parameters -> Inline)
inline_url =
    map (\u -> Ref (Link [ Chars u [] ] u Nothing)) url


ref_info : Parser Context Inlines
ref_info =
    string "["
        |> keep (manyTill inlines (string "]"))
        |> map combine


ref_title : Parser Context (Maybe Inlines)
ref_title =
    spaces
        |> ignore (string "\"")
        |> keep (manyTill inlines (string "\""))
        |> ignore spaces
        |> map combine
        |> maybe


ref_url_1 : Parser Context String
ref_url_1 =
    choice
        [ url
        , andMap (regex "#[^ \t\\)]+") searchIndex
        , regex "[^\\)\n \"]*" |> andThen baseURL
        ]


ref_url_2 : Parser Context String
ref_url_2 =
    withState (\s -> succeed s.defines.base)
        |> map (++)
        |> andMap (regex "[^\\)\n \"]*")
        |> or url



--ref_pattern : (a -> String -> String -> b) -> Parser s a -> Parser s String -> Parser s b
--ref_pattern : a -> b -> c -> Parser Context Reference


ref_pattern :
    (m -> String -> Maybe Inlines -> Reference)
    -> Parser Context m
    -> Parser Context String
    -> Parser Context Reference
ref_pattern ref_type info_type url_type =
    map (nicer_ref ref_type) info_type
        |> ignore (string "(")
        |> andMap url_type
        |> andMap ref_title
        |> ignore (string ")")


nicer_ref :
    (m -> String -> Maybe Inlines -> Reference)
    -> m
    -> String
    -> Maybe Inlines
    -> Reference
nicer_ref ref_type info_string url_string title_string =
    ref_type info_string
        url_string
        title_string


ref_audio : Parser Context Reference
ref_audio =
    map Audio ref_info
        |> ignore (string "(")
        |> andMap (map Multimedia.audio ref_url_2)
        |> andMap ref_title
        |> ignore (string ")")


ref_video : Parser Context Reference
ref_video =
    map Movie ref_info
        |> ignore (string "(")
        |> andMap (map Multimedia.movie ref_url_2)
        |> andMap ref_title
        |> ignore (string ")")


reference : Parser Context (Parameters -> Inline)
reference =
    [ refEmbed
    , refMovie
    , refAudio
    , refImage
    , refMail
    , refPreview
    , refQr
    , refLink
    ]
        |> choice
        |> map Ref


mediaReference : Parser Context Inline
mediaReference =
    [ refImage
    , refMovie
    , refAudio
    , refQr
    , refEmbed
    ]
        |> choice
        |> map Ref
        |> andMap (Macro.macro |> keep annotations)


refMail : Parser Context Reference
refMail =
    ref_pattern Mail ref_info email


refPreview : Parser Context Reference
refPreview =
    regexWith True False "\\[\\w*preview-"
        |> keep
            (choice
                [ regexWith True False "lia"
                    |> onsuccess Preview_Lia
                , regexWith True False "link"
                    |> onsuccess Preview_Link
                ]
            )
        |> ignore (regex "\\w*]")
        |> ignore (string "(")
        |> andMap ref_url_1
        |> ignore ref_title
        |> ignore (string ")")


refQr : Parser Context Reference
refQr =
    regexWith True False "\\[\\w*qr-code\\w*]"
        |> onsuccess QR_Link
        |> ignore (string "(")
        |> andMap ref_url_1
        |> andMap ref_title
        |> ignore (string ")")


refLink : Parser Context Reference
refLink =
    ref_pattern Link ref_info ref_url_1


refImage : Parser Context Reference
refImage =
    string "!"
        |> keep (ref_pattern Image ref_info ref_url_2)


refAudio : Parser Context Reference
refAudio =
    string "?"
        |> keep ref_audio


refMovie : Parser Context Reference
refMovie =
    string "!?"
        |> keep ref_video


refEmbed : Parser Context Reference
refEmbed =
    string "??"
        |> keep (ref_pattern Embed ref_info ref_url_1)


between_ : String -> Parser Context Inline
between_ str =
    string str
        |> keep (many1Till inlines (string str))
        |> map (combine >> toContainer)


toContainer : List Inline -> Inline
toContainer inline_list =
    case combine inline_list of
        [ one ] ->
            one

        moreThanOne ->
            Container moreThanOne []


strings : Parser Context (Parameters -> Inline)
strings =
    lazy <|
        \() ->
            choice
                [ inline_url
                , stringBase
                , arrows
                , smileys
                , stringEscape
                , stringBold
                , stringItalic
                , stringUnderline
                , stringStrike
                , stringSuperscript
                , stringSpaces
                , HTML.parse inlines |> map IHTML
                , stringCharacters
                , stringBase2
                ]


stringBase : Parser s (Parameters -> Inline)
stringBase =
    regex "[^\\[\\]\\(\\)@*+_~:;`\\^|{}\\\\\\n<>=$ \"\\-]+"
        |> map Chars


stringEscape : Parser s (Parameters -> Inline)
stringEscape =
    string "\\"
        |> keep (regex "[@\\^*_+~`\\\\${}\\[\\]|#\\-<>]")
        |> map Chars


stringItalic : Parser Context (Parameters -> Inline)
stringItalic =
    or (between_ "*") (between_ "_")
        |> map Italic


stringBold : Parser Context (Parameters -> Inline)
stringBold =
    or (between_ "**") (between_ "__")
        |> map Bold


stringStrike : Parser Context (Parameters -> Inline)
stringStrike =
    between_ "~"
        |> map Strike


stringUnderline : Parser Context (Parameters -> Inline)
stringUnderline =
    between_ "~~"
        |> map Underline


stringSuperscript : Parser Context (Parameters -> Inline)
stringSuperscript =
    between_ "^"
        |> map Superscript


stringCharacters : Parser s (Parameters -> Inline)
stringCharacters =
    regex "[\\[\\]\\(\\)~:_;=${}\\-+\"*<>]"
        |> map Chars


stringSpaces : Parser s (Parameters -> Inline)
stringSpaces =
    regex "[ \t]+"
        |> map Chars


stringBase2 : Parser s (Parameters -> Inline)
stringBase2 =
    regex "[^\n*|+\\-]+"
        |> map Chars


code : Parser s (Parameters -> Inline)
code =
    string "`"
        |> keep (regex "([^`\n\\\\]*|\\\\`|\\\\)+")
        |> ignore (string "`")
        |> map (String.replace "\\`" "`" >> Verbatim)



-- TODO: update also for multiline-comments and escapes in strings


scriptBody : Parser s String
scriptBody =
    regexWith True False "</script>"
        |> manyTill
            ([ regex "[^@\"'`</]+" --" this is only a comment for syntax-highlighting ...
             , regex "[ \t\n]+"
             , string "@'"
             , string "@"
             , regex "\"([^\"]*|\\\\\"|\\\\)*\""
             , regex "'([^']*|\\\\'|\\\\)*'"
             , regex "`([^`]*|\n|\\\\`|\\\\)*`"
             , regex "<(?!/)"
             , regex "//[^\n]*"
             , string "/"
             ]
                |> choice
            )
        |> map String.concat
