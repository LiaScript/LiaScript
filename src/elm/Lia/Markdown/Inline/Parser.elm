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
import Dict exposing (Dict)
import Html.Parser
import Lia.Markdown.Effect.Model exposing (add_javascript)
import Lia.Markdown.Effect.Parser as Effect
import Lia.Markdown.Footnote.Parser as Footnote
import Lia.Markdown.Inline.Multimedia as Multimedia
import Lia.Markdown.Inline.Parser.Formula exposing (formula)
import Lia.Markdown.Inline.Parser.Symbol exposing (arrows, smileys)
import Lia.Markdown.Inline.Types exposing (Annotation, Inline(..), Inlines, Reference(..))
import Lia.Markdown.Macro.Parser as Macro
import Lia.Parser.Context exposing (Context, getLine, searchIndex)
import Lia.Parser.Helper exposing (spaces, stringTill)


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
        |> keep (manyTill p (string "-->"))


comment_string : Parser s String
comment_string =
    anyChar
        |> comment
        |> map (String.fromList >> String.trim)


comments : Parser Context ()
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


annotations : Parser Context Annotation
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


html : Parser Context Inline
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


html_void : Parser Context Inline
html_void =
    regex "<[^>\\n]*>"
        |> andThen html_parse
        |> map HTML


html_parse : String -> Parser s (List Html.Parser.Node)
html_parse str =
    case Html.Parser.run str of
        Ok rslt ->
            succeed rslt

        Err _ ->
            fail "html parser failed"


html_block : Parser Context Inline
html_block =
    regex "<((\\w+|-)+)[\\s\\S]*?</\\1>"
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


line : Parser Context Inlines
line =
    inlines
        |> andThen goto
        |> many1
        |> map (append_space >> combine)


append_space : Inlines -> Inlines
append_space list =
    List.append list [ Chars " " Nothing ]


inlines : Parser Context Inline
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
                |> andThen goto


goto : Inline -> Parser Context Inline
goto i =
    map (Goto i) getLine


url : Parser s String
url =
    regex "[a-zA-Z]+://(/)?[a-zA-Z0-9\\.\\-\\_]+\\.([a-z\\.]{2,6})[^ \\]\\)\t\n]*"


email : Parser s String
email =
    string "mailto:"
        |> maybe
        |> keep (regex "[a-zA-Z0-9_.\\-]+@[a-zA-Z0-9_.\\-]+")
        |> map ((++) "mailto:")


inline_url : Parser Context (Annotation -> Inline)
inline_url =
    map (\u -> Ref (Link [ Chars u Nothing ] u "")) url


ref_info : Parser Context Inlines
ref_info =
    string "["
        |> keep (manyTill inlines (string "]"))


ref_title : Parser s String
ref_title =
    spaces
        |> ignore (string "\"")
        |> keep (stringTill (string "\""))
        |> ignore spaces
        |> optional ""


ref_url_1 : Parser Context String
ref_url_1 =
    choice
        [ url
        , andMap (regex "#\\S+") searchIndex
        , regex "[^\\)\n \"]*"
        ]


ref_url_2 : Parser Context String
ref_url_2 =
    withState (\s -> succeed s.defines.base)
        |> map (++)
        |> andMap (regex "[^\\)\n \"]*")
        |> or url



--ref_pattern : (a -> String -> String -> b) -> Parser s a -> Parser s String -> Parser s b


ref_pattern ref_type info_type url_type =
    map (nicer_ref ref_type) info_type
        |> ignore (string "(")
        |> andMap url_type
        |> andMap ref_title
        |> ignore (string ")")


nicer_ref ref_type info_string url_string title_string =
    ref_type info_string
        url_string
        (if String.isEmpty title_string then
            url_string

         else
            title_string
        )


ref_audio =
    map Audio ref_info
        |> ignore (string "(")
        |> andMap (map Multimedia.audio ref_url_2)
        |> andMap ref_title
        |> ignore (string ")")


ref_video =
    map Movie ref_info
        |> ignore (string "(")
        |> andMap (map Multimedia.movie ref_url_2)
        |> andMap ref_title
        |> ignore (string ")")


reference : Parser Context (Annotation -> Inline)
reference =
    lazy <|
        \() ->
            let
                mail_ =
                    ref_pattern Mail ref_info email

                link =
                    ref_pattern Link ref_info ref_url_1

                image =
                    string "!"
                        |> keep (ref_pattern Image ref_info ref_url_2)

                audio =
                    string "?"
                        |> keep ref_audio

                movie =
                    string "!?"
                        |> keep ref_video
            in
            [ movie, audio, image, mail_, link ]
                |> choice
                |> map Ref


between_ : String -> Parser Context Inline
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


strings : Parser Context (Annotation -> Inline)
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
                    regex "[~:_;\\-<>=${}\\[\\] ]"
                        |> map Chars

                base2 =
                    regex "[^\n|*]+"
                        |> map Chars
            in
            choice
                [ inline_url
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


code : Parser Context (Annotation -> Inline)
code =
    string "`"
        |> keep (regex "[^`\\n]+")
        |> ignore (string "`")
        |> map Verbatim
