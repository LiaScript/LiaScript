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
import Html.Parser
import Lia.Markdown.Effect.Model exposing (add_javascript)
import Lia.Markdown.Effect.Parser as Effect
import Lia.Markdown.Footnote.Parser as Footnote
import Lia.Markdown.Inline.Types exposing (..)
import Lia.Markdown.Macro.Parser as Macro
import Lia.Parser.Helper exposing (..)
import Lia.Parser.State exposing (State)


comment : Parser s a -> Parser s (List a)
comment p =
    string "<!--"
        |> keep (manyTill p (string "-->"))


comment_string : Parser s String
comment_string =
    anyChar
        |> comment
        |> map (String.fromList >> String.trim)


comments : Parser State ()
comments =
    Effect.hidden_comment
        |> or (skip (comment anyChar))
        |> many
        |> skip


attribute : Parser s ( String, String )
attribute =
    whitespace
        |> keep (regex "\\w+")
        |> ignore (regex "[ \t\n]*=[ \t\n]*\"")
        |> map (\k v -> ( String.toLower k, v ))
        |> andMap (stringTill (regex "\"[ \t\n]*"))


annotations : Parser State Annotation
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


html : Parser State Inline
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
    choice
        [ javascript
            |> andThen state
            |> keep (succeed (Chars "" Nothing))
        , html_void
        , html_block
        ]


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
        |> andThen html_parse
        |> map HTML


html_parse : String -> Parser s (List Html.Parser.Node)
html_parse str =
    case Html.Parser.run str of
        Ok rslt ->
            succeed rslt

        Err info ->
            fail "html parser failed"


html_block : Parser s Inline
html_block =
    regex "<(\\w+)[\\s\\S]*?</\\1>"
        |> andThen html_parse
        |> map HTML


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


line : Parser State Inlines
line =
    inlines
        |> many1
        |> map (append_space >> combine)


append_space : Inlines -> Inlines
append_space list =
    List.append list [ Chars " " Nothing ]


inlines : Parser State Inline
inlines =
    lazy <|
        \() ->
            Macro.macro
                |> keep
                    ([ code
                     , Footnote.inline
                     , reference
                     , formula
                     , Effect.inline inlines
                     , strings
                     ]
                        |> choice
                        |> andMap (Macro.macro |> keep annotations)
                        |> or html
                    )


formula : Parser s (Annotation -> Inline)
formula =
    or formula_block formula_inline


formula_inline : Parser s (Annotation -> Inline)
formula_inline =
    string "$"
        |> keep (regex "[^\\n$]+")
        |> ignore (string "$")
        |> map (Formula "false")


formula_block : Parser s (Annotation -> Inline)
formula_block =
    string "$$"
        |> keep (stringTill (string "$$"))
        |> map (Formula "true")


url : Parser s String
url =
    regex "[a-zA-Z]+://(/)?[a-zA-Z0-9\\.\\-\\_]+\\.([a-z\\.]{2,6})[^ \\]\\)\t\n]*"


email : Parser s String
email =
    string "mailto:"
        |> maybe
        |> keep (regex "[a-zA-Z0-9_.\\-]+@[a-zA-Z0-9_.\\-]+")
        |> map ((++) "mailto:")


inline_url : Parser s Reference
inline_url =
    map (\u -> Link [ Chars u Nothing ] u "") url


ref_info : Parser s String
ref_info =
    brackets (regex "[^\\]\n]*")


ref_info2 : Parser State Inlines
ref_info2 =
    string "["
        |> keep (manyTill inlines (string "]"))


ref_title : Parser s String
ref_title =
    spaces
        |> ignore (string "\"")
        |> keep (stringTill (string "\""))
        |> ignore spaces
        |> optional ""


ref_url_1 : Parser s String
ref_url_1 =
    or url (regex "[^\\)\n \"]*")


ref_url_2 : Parser State String
ref_url_2 =
    withState (\s -> succeed s.defines.base)
        |> map (++)
        |> andMap (regex "[^\\)\n \"]*")
        |> or url


ref_pattern ref_type info_type url_type =
    map ref_type info_type
        |> ignore (string "(")
        |> andMap url_type
        |> andMap ref_title
        |> ignore (string ")")


reference : Parser State (Annotation -> Inline)
reference =
    lazy <|
        \() ->
            let
                mail_ =
                    ref_pattern Mail ref_info2 email

                link =
                    ref_pattern Link ref_info2 ref_url_1

                image =
                    string "!"
                        |> keep (ref_pattern Image ref_info ref_url_2)

                audio =
                    string "?"
                        |> keep (ref_pattern Audio ref_info ref_url_2)

                movie =
                    string "!?"
                        |> keep (ref_pattern Movie ref_info ref_url_2)
            in
            [ movie, audio, image, mail_, link ]
                |> choice
                |> map Ref


arrows : Parser s (Annotation -> Inline)
arrows =
    choice
        [ string "<-->" |> onsuccess (Symbol "⟷")
        , string "<--" |> onsuccess (Symbol "⟵")
        , string "-->" |> onsuccess (Symbol "⟶")
        , string "<<-" |> onsuccess (Symbol "↞")
        , string "->>" |> onsuccess (Symbol "↠")
        , string "<->" |> onsuccess (Symbol "↔")
        , string ">->" |> onsuccess (Symbol "↣")
        , string "<-<" |> onsuccess (Symbol "↢")
        , string "->" |> onsuccess (Symbol "→")
        , string "<-" |> onsuccess (Symbol "←")
        , string "<~" |> onsuccess (Symbol "↜")
        , string "~>" |> onsuccess (Symbol "↝")
        , string "<==>" |> onsuccess (Symbol "⟺")
        , string "==>" |> onsuccess (Symbol "⟹")
        , string "<==" |> onsuccess (Symbol "⟸")
        , string "<=>" |> onsuccess (Symbol "⇔")
        , string "=>" |> onsuccess (Symbol "⇒")
        , string "<=" |> onsuccess (Symbol "⇐")
        ]


smileys : Parser s (Annotation -> Inline)
smileys =
    choice
        [ string ":-)" |> onsuccess (Symbol "🙂")
        , string ";-)" |> onsuccess (Symbol "😉")
        , string ":-D" |> onsuccess (Symbol "😀")
        , string ":-O" |> onsuccess (Symbol "😮")
        , string ":-(" |> onsuccess (Symbol "🙁")
        , string ":-|" |> onsuccess (Symbol "😐")
        , string ":-/" |> onsuccess (Symbol "😕")
        , string ":-P" |> onsuccess (Symbol "😛")
        , string ";-P" |> onsuccess (Symbol "😜")
        , string ":-*" |> onsuccess (Symbol "😗")
        , string ":')" |> onsuccess (Symbol "😂")
        , string ":'(" |> onsuccess (Symbol "😢")
        ]


between_ : String -> Parser State Inline
between_ str =
    lazy <|
        \() ->
            [ string str
                |> keep inlines
                |> ignore (string str)
            , string str
                |> keep (manyTill inlines (string str))
                |> map (\list -> Container (combine list) Nothing)
            ]
                |> choice


strings : Parser State (Annotation -> Inline)
strings =
    lazy <|
        \() ->
            let
                base =
                    regex "[^*_~:;`!\\^\\[\\]|{}\\\\\\n\\-<>=$ ]+"
                        |> map Chars

                escape =
                    string "\\"
                        |> keep (regex "[\\^*_+-~`\\\\${}\\[\\]|#]")
                        |> map Chars

                italic =
                    or (between_ "*") (between_ "_")
                        |> map Italic

                bold =
                    or (between_ "**") (between_ "__")
                        |> map Bold

                strike =
                    between_ "~"
                        |> map Strike

                underline =
                    between_ "~~"
                        |> map Underline

                superscript =
                    between_ "^"
                        |> map Superscript

                characters =
                    regex "[~:_;\\-<>=${} ]"
                        |> map Chars

                base2 =
                    regex "[^\\n|*\\[\\]]+"
                        |> map Chars
            in
            choice
                [ map Ref inline_url
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
    string "`"
        |> keep (regex "[^`\\n]+")
        |> ignore (string "`")
        |> map Verbatim
