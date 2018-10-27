module Lia.Effect.Parser exposing (comment, hidden_comment, inline, markdown)

import Array
import Combine exposing (..)
import Combine.Char exposing (anyChar)
import Combine.Num exposing (int)
import Dict
import Lia.Effect.Model exposing (Element)
import Lia.Helper exposing (..)
import Lia.Macro.Parser exposing (macro)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Annotation, Inline(..), Inlines)
import Lia.Markdown.Types exposing (Markdown(..))
import Lia.PState exposing (PState, ident_skip, identation)


markdown : Parser PState Markdown -> Parser PState ( Int, Int, List Markdown )
markdown blocks =
    (,,)
        <$> (regex "[\\t ]*{{" *> effect_number)
        <*> (optional 99999 (regex "[\t ]*-[\t ]*" *> int)
                <* regex "}}[\\t ]*\\n?"
            )
        <*> (multi blocks <|> single blocks)
        <* reset_effect_number


single : Parser PState Markdown -> Parser PState (List Markdown)
single blocks =
    List.singleton <$> blocks


multi : Parser PState Markdown -> Parser PState (List Markdown)
multi blocks =
    identation
        *> regex "[\\t ]*\\*{3,}[\\n]+"
        *> manyTill (blocks <* newlines) (regex "[\\t ]*\\*{3,}")


inline : Parser PState Inline -> Parser PState (Annotation -> Inline)
inline inlines =
    EInline
        <$> (string "{" *> effect_number)
        <*> (optional 99999 (regex "[\t ]*-[\t ]*" *> int) <* string "}")
        <*> (string "{" *> manyTill inlines (string "}"))
        <* reset_effect_number


effect_number : Parser PState Int
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
                *> succeed n
    in
    int >>= state


reset_effect_number : Parser PState ()
reset_effect_number =
    modifyState
        (\s ->
            { s
                | effect_number = List.drop 1 s.effect_number
            }
        )


comment : Parser PState Inlines -> Parser PState ( Int, Int )
comment paragraph =
    ((,,)
        <$> (regex "[ \\t]*--{{" *> effect_number)
        <*> maybe (spaces1 *> macro *> regex "[A-Za-z0-9 ]+")
        <* regex "}}--[ \\t]*"
        <* maybe (newlines1 *> ident_skip)
        <*> (identation *> paragraph)
        <* reset_effect_number
    )
        >>= add_comment True


hidden_comment : Parser PState ()
hidden_comment =
    skip
        (((\i voice text ->
            ( i, voice, [ Chars (text |> String.fromList |> String.trim) Nothing ] )
          )
            <$> (regex "<!--[ \\t]*--{{" *> effect_number)
            <*> maybe
                    (spaces1
                        *> macro
                        *> regex "[A-Za-z0-9 ]+"
                    )
            <* regex "}}--[ \\t]*"
            <*> manyTill anyChar (string "-->")
            <* reset_effect_number
         )
            >>= add_comment False
        )


add_comment : Bool -> ( Int, Maybe String, Inlines ) -> Parser PState ( Int, Int )
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
    (modifyState mod *> get_counter idx) >>= rslt


get_counter : Int -> Parser PState Int
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
