module Lia.Markdown.Inline.Parser exposing
    ( annotations
    , comment
    , eScript
    , inlines
    , javascript
    , line
    , line2
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
        , fail
        , ignore
        , keep
        , lazy
        , lookAhead
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
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.Inline.Multimedia as Multimedia
import Lia.Markdown.Inline.Parser.Formula exposing (formula)
import Lia.Markdown.Inline.Parser.Symbol exposing (arrows, smileys)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..), combine)
import Lia.Markdown.Macro.Parser as Macro
import Lia.Markdown.Quiz.Block.Parser as Input
import Lia.Markdown.Quiz.Block.Types as Input
import Lia.Parser.Context
    exposing
        ( Context
        , searchIndex
        )
import Lia.Parser.Helper exposing (inlineCode, spaces)
import Lia.Parser.Input as Context
import Translations exposing (Lang(..))


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


line2 : Parser Context Inlines
line2 =
    inlines2 |> many1 |> map combine


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
                     , input
                     , strings
                     ]
                        |> choice
                        |> andMap (Macro.macro |> keep annotations)
                        |> or (eScript [] |> map (\( attr, id ) -> Script id attr))
                    )


inlines2 : Parser Context Inline
inlines2 =
    lazy <|
        \() ->
            Macro.macro
                |> keep
                    ([ code
                     , Footnote.inline parse_inlines
                     , input
                     , reference
                     , formula
                     , inlines
                        |> Effect.inline
                        |> map EInline
                     , stringExceptions
                     , strings
                     ]
                        |> choice
                        |> andMap (Macro.macro |> keep annotations)
                        |> or (eScript [] |> map (\( attr, id ) -> Script id attr))
                    )


input : Parser Context (Parameters -> Inline)
input =
    Context.getPermission
        |> andThen
            (\isAllowed ->
                if isAllowed then
                    Input.pattern parse_inlines
                        |> andThen Context.add
                        |> map Quiz

                else
                    fail "no inputs allowed"
            )


url : Parser Context String
url =
    regex "[a-zA-Z]+://(/)?[a-zA-Z0-9\\.\\-\\_]+\\.([a-z\\.]{2,6})[^ \\]\\)\t\n\"]*"
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
        |> map refToEmbed


refToEmbed : Reference -> Reference
refToEmbed ref =
    case ref of
        Audio info ( extern, link ) title ->
            if
                not extern
                    && (String.contains "soundcloud.com" link
                            || String.contains "spotify.com" link
                       )
            then
                Embed info link title

            else
                ref

        _ ->
            ref


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
                , dashes
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
                , lineBreak
                , stringBase2
                ]


stringBase : Parser s (Parameters -> Inline)
stringBase =
    regex "[^\\[\\]\\(\\)@*+_~:;`\\^{}\\\\\\n<>=$ \"\\-|]+"
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


dashes : Parser Context (Parameters -> Inline)
dashes =
    or
        (string "---"
            |> keep (succeed (Chars "—"))
        )
        (string "--"
            |> keep (succeed (Chars "–"))
        )


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
    regex "[\\[\\]\\(\\)~:_;=${}\\-+\"*<>|]"
        |> map Chars


stringSpaces : Parser s (Parameters -> Inline)
stringSpaces =
    regex "[ \t]+"
        |> map Chars


stringBase2 : Parser s (Parameters -> Inline)
stringBase2 =
    regex "[^\n*+\\-]+"
        |> map Chars


stringExceptions : Parser Context (Parameters -> Inline)
stringExceptions =
    string "|"
        |> lookAhead
        |> onsuccess (Chars "")


lineBreak : Parser s (Parameters -> Inline)
lineBreak =
    string "\\\n"
        |> onsuccess (always (IHTML (InnerHtml "<br>") []))


code : Parser s (Parameters -> Inline)
code =
    inlineCode |> map Verbatim



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
