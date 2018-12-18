module Lia.Markdown.Inline.Parser exposing
    ( annotations
    , attribute
    , combine
    , comment
    , comment_string
    , comments
    , inlines
    , javascript
    , line
    )

import Combine exposing (..)
import Combine.Char exposing (..)
import Dict exposing (Dict)
import Lia.Effect.Model exposing (add_javascript)
import Lia.Effect.Parser as Effect
import Lia.Helper exposing (..)
import Lia.Macro.Parser as Macro
import Lia.Markdown.Footnote.Parser as Footnote
import Lia.Markdown.Inline.Types exposing (..)
import Lia.PState exposing (PState)


comment : Parser s a -> Parser s (List a)
comment p =
    string "<!--"
        |> keep (manyTill p (string "-->"))


comment_string : Parser s String
comment_string =
    anyChar
        |> comment
        |> map (String.fromList >> String.trim)


comments : Parser PState ()
comments =
    Effect.hidden_comment
        |> or (skip (comment anyChar))
        |> many
        |> skip


attribute : Parser s ( String, String )
attribute =
    (\k v -> ( String.toLower k, String.fromList v ))
        <$> (whitespace *> regex "\\w+" <* regex "[ \\t\\n]*=[ \\t\\n]*\"")
        <*> manyTill anyChar (regex "\"[ \\t\\n]*")


annotations : Parser PState Annotation
annotations =
    spaces
        |> keep (comment attribute)
        |> map (Dict.fromList >> attr_)
        |> maybe
        |> ignore comments


attr_ : Dict String String -> Dict String String
attr_ dict =
    Dict.insert "style"
        (case Dict.get "style" dict of
            Just value ->
                "display: inline-block;" ++ value

            Nothing ->
                "display: inline-block;"
        )
        dict


javascript : Parser s String
javascript =
    string "<script>"
        |> keep (stringTill (string "</script>"))


html : Parser PState Inline
html =
    let
        state script =
            modifyState
                (\s ->
                    { s
                        | effect_model =
                            add_javascript
                                (s.effect_number
                                    |> List.head
                                    |> Maybe.withDefault 0
                                )
                                script
                                s.effect_model
                    }
                )
    in
    ((javascript >>= state) *> succeed (Chars "" Nothing)) <|> html_void <|> html_block


html_void : Parser s Inline
html_void =
    [ regex "<area[^>\\n]*>"
    , regex "<base[^>\\n]*>"
    , regex "<br[^>\\n]*>"
    , regex "<col[^>\\n]*>"
    , regex "<embed[^>\\n]*>"
    , regex "<hr[^>\\n]*>"
    , regex "<img[^>\\n]*>"
    , regex "<input[^>\\n]*>"
    , regex "<keygen[^>\\n]*>"
    , regex "<link[^>\\n]*>"
    , regex "<menuitem[^>\\n]*>"
    , regex "<meta[^>\\n]*>"
    , regex "<param[^>\\n]*>"
    , regex "<source[^>\\n]*>"
    , regex "<track[^>\\n]*>"
    , regex "<wbr[^>\\n]*>"
    ]
        |> choice
        |> map HTML


html_block : Parser s Inline
html_block =
    HTML <$> regex "<(\\w+)[\\s\\S]*?</\\1>"


combine : Inlines -> Inlines
combine list =
    case list of
        [] ->
            []

        [ xs ] ->
            [ xs ]

        x1 :: x2 :: xs ->
            case ( x1, x2 ) of
                ( Chars str1 Nothing, Chars str2 Nothing ) ->
                    combine (Chars (str1 ++ str2) Nothing :: xs)

                _ ->
                    x1 :: combine (x2 :: xs)


line : Parser PState Inlines
line =
    inlines
        |> many1
        |> map (append_space >> combine)


append_space : Inlines -> Inlines
append_space list =
    List.append list [ Chars " " Nothing ]


inlines : Parser PState Inline
inlines =
    lazy <|
        \() ->
            Macro.macro
                *> (html
                        <|> (choice
                                [ code
                                , Footnote.inline
                                , reference
                                , formula
                                , Effect.inline inlines
                                , strings
                                ]
                                <*> (Macro.macro *> annotations)
                            )
                   )


formula : Parser s (Annotation -> Inline)
formula =
    or formula_block formula_inline


formula_inline : Parser s (Annotation -> Inline)
formula_inline =
    string "$"
        |> keep (regex "[^\\n$]+")
        |> ignore (string "$")
        |> map (Formula False)


formula_block : Parser s (Annotation -> Inline)
formula_block =
    string "$$"
        |> keep (stringTill (string "$$"))
        |> map (Formula True)


url : Parser s String
url =
    regex "[a-zA-Z]+://(/)?[a-zA-Z0-9\\.\\-\\_]+\\.([a-z\\.]{2,6})[^ \\]\\)\\t\\n]*"


email : Parser s String
email =
    maybe (string "mailto:") *> regex "[a-zA-Z0-9_.\\-]+@[a-zA-Z0-9_.\\-]+"


inline_url : Parser s Reference
inline_url =
    (\u -> Link [ Chars u Nothing ] ( u, "" )) <$> url


reference : Parser PState (Annotation -> Inline)
reference =
    lazy <|
        \() ->
            let
                info =
                    brackets (regex "[^\\]\n]*")

                info2 =
                    string "[" *> manyTill inlines (string "]")

                title =
                    optional "" (spaces *> string "\"" *> stringTill (string "\"")) <* spaces

                url_1 =
                    url <|> regex "[^\\)\n \"]*"

                url_2 =
                    url <|> ((++) <$> withState (\s -> succeed s.defines.base) <*> regex "[^\\)\n \"]*")

                mail_ =
                    Mail <$> info2 <*> parens ((,) <$> email <*> title)

                link =
                    Link <$> info2 <*> parens ((,) <$> url_1 <*> title)

                image =
                    Image
                        <$> (string "!" *> info)
                        <*> parens ((,) <$> url_2 <*> title)

                audio =
                    Audio
                        <$> (string "?" *> info)
                        <*> parens ((,) <$> url_2 <*> title)

                movie =
                    Movie
                        <$> (string "!?" *> info)
                        <*> parens ((,) <$> url_2 <*> title)
            in
            Ref <$> choice [ movie, audio, image, mail_, link ]


arrows : Parser s (Annotation -> Inline)
arrows =
    choice
        [ string "<-->" $> Symbol "&#10231;" --"⟷"
        , string "<--" $> Symbol "&#10229;" --"⟵"
        , string "-->" $> Symbol "&#10230;" --"⟶"
        , string "<<-" $> Symbol "&#8606;" --"↞"
        , string "->>" $> Symbol "&#8608;" --"↠"
        , string "<->" $> Symbol "&#8596;" --"↔"
        , string ">->" $> Symbol "&#8611;" --"↣"
        , string "<-<" $> Symbol "&#8610;" --"↢"
        , string "->" $> Symbol "&#8594;" --"→"
        , string "<-" $> Symbol "&#8592;" --"←"
        , string "<~" $> Symbol "&#8604;" --"↜"
        , string "~>" $> Symbol "&#8605;" --"↝"
        , string "<==>" $> Symbol "&#10234;" --"⟺"
        , string "==>" $> Symbol "&#10233;" --"⟹"
        , string "<==" $> Symbol "&#10232;" --"⟸"
        , string "<=>" $> Symbol "&#8660;" --"⇔"
        , string "=>" $> Symbol "&#8658;" --"⇒"
        , string "<=" $> Symbol "&#8656;" --"⇐"
        ]


smileys : Parser s (Annotation -> Inline)
smileys =
    choice
        [ string ":-)" $> Symbol "&#x1f600;" --"🙂"
        , string ";-)" $> Symbol "&#x1f609;" --"😉"
        , string ":-D" $> Symbol "&#x1f600;" --"😀"
        , string ":-O" $> Symbol "&#128558;" --"😮"
        , string ":-(" $> Symbol "&#128542;" --"🙁"
        , string ":-|" $> Symbol "&#128528;" --"😐"
        , string ":-/" $> Symbol "&#128533;" --"😕"
        , string ":-P" $> Symbol "&#128539;" --"😛"
        , string ";-P" $> Symbol "&#128540;" --"😜"
        , string ":-*" $> Symbol "&#128535;" --"😗"
        , string ":')" $> Symbol "&#128514;" --"😂"
        , string ":'(" $> Symbol "&#128554;" --"😢"😪
        ]


between_ : String -> Parser PState Inline
between_ str =
    lazy <|
        \() ->
            choice
                [ string str *> inlines <* string str
                , (\list -> Container (combine list) Nothing)
                    <$> (string str *> manyTill inlines (string str))
                ]


strings : Parser PState (Annotation -> Inline)
strings =
    lazy <|
        \() ->
            let
                base =
                    Chars <$> regex "[^*_~:;`!\\^\\[\\]|{}\\\\\\n\\-<>=$ ]+" <?> "base string"

                escape =
                    Chars <$> (string "\\" *> regex "[\\^*_+-~`\\\\${}\\[\\]|#]") <?> "escape string"

                italic =
                    Italic <$> (between_ "*" <|> between_ "_") <?> "italic string"

                bold =
                    Bold <$> (between_ "**" <|> between_ "__") <?> "bold string"

                strike =
                    Strike <$> between_ "~" <?> "striked out string"

                underline =
                    Underline <$> between_ "~~" <?> "underlined string"

                superscript =
                    Superscript <$> between_ "^" <?> "superscript string"

                characters =
                    Chars <$> regex "[~:_;\\-<>=${} ]"

                base2 =
                    Chars <$> regex "[^\\n|*\\[\\]]+" <?> "base string"
            in
            choice
                [ Ref <$> inline_url
                , base
                , arrows
                , smileys
                , escape
                , bold
                , italic
                , underline
                , strike
                , superscript
                , characters
                , base2
                ]


code : Parser s (Annotation -> Inline)
code =
    Verbatim <$> (string "`" *> regex "[^`\\n]+" <* string "`") <?> "inline code"
