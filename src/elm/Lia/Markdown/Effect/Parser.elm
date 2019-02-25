module Lia.Markdown.Effect.Parser exposing (comment, hidden_comment, inline, markdown)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , ignore
        , keep
        , manyTill
        , map
        , maybe
        , modifyState
        , optional
        , or
        , regex
        , skip
        , string
        , succeed
        , withState
        )
import Combine.Char exposing (anyChar)
import Combine.Num exposing (int)
import Dict
import Lia.Markdown.Effect.Model exposing (Element)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Annotation, Inline(..), Inlines)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Types exposing (Markdown(..))
import Lia.Parser.Context exposing (Context, indentation, indentation_skip)
import Lia.Parser.Helper exposing (newlines, newlines1, spaces1)


markdown : Parser Context Markdown -> Parser Context ( Int, Int, List Markdown )
markdown blocks =
    regex "[\t ]*{{"
        |> keep effect_number
        |> map (\a b c -> ( a, b, c ))
        |> andMap
            (regex "[\t ]*-[\t ]*"
                |> keep int
                |> optional 99999
            )
        |> ignore (regex "}}[\t ]*")
        |> ignore (or (skip (string "\n")) indentation_skip)
        |> andMap (or (multi blocks) (single blocks))
        |> ignore reset_effect_number


single : Parser Context Markdown -> Parser Context (List Markdown)
single blocks =
    blocks
        |> map List.singleton


multi : Parser Context Markdown -> Parser Context (List Markdown)
multi blocks =
    indentation
        |> ignore (regex "[\t ]*\\*{3,}\\n+")
        |> keep
            (manyTill
                (blocks
                    |> ignore newlines
                )
                (regex "[\t ]*\\*{3,}")
            )


inline : Parser Context Inline -> Parser Context (Annotation -> Inline)
inline inlines =
    string "{"
        |> keep effect_number
        |> map EInline
        |> andMap
            (regex "[\t ]*-[\t ]*"
                |> keep int
                |> optional 99999
            )
        |> ignore (string "}{")
        |> andMap (manyTill inlines (string "}"))
        |> ignore reset_effect_number


effect_number : Parser Context Int
effect_number =
    let
        state n =
            modifyState
                (\s ->
                    { s
                        | effect_model =
                            if n > s.effect_model.effects then
                                let
                                    e =
                                        s.effect_model
                                in
                                { e | effects = n }

                            else
                                s.effect_model
                        , effect_number = n :: s.effect_number
                    }
                )
                |> keep (succeed n)
    in
    int |> andThen state


reset_effect_number : Parser Context ()
reset_effect_number =
    modifyState
        (\s ->
            { s
                | effect_number = List.drop 1 s.effect_number
            }
        )


comment : Parser Context Inlines -> Parser Context ( Int, Int )
comment paragraph =
    regex "[\t ]*--{{"
        |> keep effect_number
        |> map (\a b c -> ( a, b, c ))
        |> andMap
            (maybe
                (spaces1
                    |> keep macro
                    |> keep (regex "[A-Za-z0-9 ]+")
                )
            )
        |> ignore (regex "}}--[\t ]*")
        |> ignore (maybe (newlines1 |> ignore indentation_skip))
        |> andMap (indentation |> keep paragraph)
        |> andThen (add_comment True)
        |> ignore reset_effect_number


hidden_comment : Parser Context ()
hidden_comment =
    regex "<!--[\t ]*--{{"
        |> keep effect_number
        |> map
            (\i voice text ->
                ( i, voice, [ Chars (text |> String.fromList |> String.trim) -1 Nothing ] )
            )
        |> andMap
            (spaces1
                |> keep macro
                |> keep (regex "[A-Za-z0-9 ]+")
                |> maybe
            )
        |> ignore (regex "}}--[\t ]*")
        |> andMap (manyTill anyChar (string "-->"))
        |> ignore reset_effect_number
        |> andThen (add_comment False)
        |> skip


add_comment : Bool -> ( Int, Maybe String, Inlines ) -> Parser Context ( Int, Int )
add_comment visible ( idx, temp_narrator, par ) =
    let
        mod s =
            let
                narrator =
                    temp_narrator
                        |> Maybe.map String.trim
                        |> Maybe.withDefault s.defines.narrator
            in
            { s
                | effect_model =
                    let
                        e =
                            s.effect_model
                    in
                    { e
                        | comments =
                            case Dict.get idx e.comments of
                                Just cmt ->
                                    Dict.insert idx
                                        (if visible then
                                            { cmt
                                                | comment = cmt.comment ++ "\n" ++ stringify par
                                                , paragraphs = Array.push ( Nothing, par ) cmt.paragraphs
                                            }

                                         else
                                            { cmt | comment = cmt.comment ++ "\n" ++ stringify par }
                                        )
                                        e.comments

                                _ ->
                                    Dict.insert idx
                                        (Element
                                            narrator
                                            (stringify par)
                                            (Array.fromList <|
                                                if visible then
                                                    [ ( Nothing, par ) ]

                                                else
                                                    []
                                            )
                                        )
                                        e.comments
                    }
            }

        rslt id2 =
            succeed ( idx, id2 )
    in
    modifyState mod
        |> keep (get_counter idx)
        |> andThen rslt


get_counter : Int -> Parser Context Int
get_counter idx =
    withState
        (\s ->
            succeed <|
                case Dict.get idx s.effect_model.comments of
                    Just e ->
                        Array.length e.paragraphs - 1

                    Nothing ->
                        0
        )
