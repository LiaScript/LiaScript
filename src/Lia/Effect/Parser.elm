module Lia.Effect.Parser exposing (comment, inline, markdown)

import Array
import Combine exposing (..)
import Combine.Num exposing (int)
import Dict
import Lia.Effect.Model exposing (Element)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Annotation, Inline(..), Inlines)
import Lia.Markdown.Types exposing (Markdown(..))
import Lia.PState exposing (PState)


markdown : Parser PState Markdown -> Parser PState ( Int, Int, List Markdown )
markdown blocks =
    (\i j list -> ( i, j, list ))
        <$> (regex "[\\t ]*{{" *> effect_number)
        <*> (optional 99999 (regex "[\t ]*-[\t ]*" *> int) <* regex "}}[\\t ]*\\n")
        <*> (multi blocks <|> single blocks)
        <* reset_effect_number


single : Parser PState Markdown -> Parser PState (List Markdown)
single blocks =
    List.singleton <$> (regex "[ \\n\\t]*" *> blocks)


multi : Parser PState Markdown -> Parser PState (List Markdown)
multi blocks =
    regex "[\\t ]*[=]{3,}[\\n]+" *> manyTill (blocks <* regex "[ \\n\\t]*") (regex "[\\t ]*[=]{3,}")


inline : Parser PState Inline -> Parser PState (Annotation -> Inline)
inline inlines =
    EInline
        <$> (string "{{" *> effect_number)
        <*> (optional 99999 (regex "[\t ]*-[\t ]*" *> int) <* string "}}")
        <*> (string "{{" *> manyTill inlines (string "}}"))
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
    ((\i n p -> ( i, n, p ))
        <$> (regex "[ \\t]*--{{" *> effect_number)
        <*> (maybe (regex "[ \\t]*<!--" *> regex "[A-Za-z0-9 ]+" <* regex "-->[ \\t]*")
                <* regex "}}--[ \\t]*[\\n]+"
            )
        <*> paragraph
        <* reset_effect_number
    )
        >>= add_comment


add_comment : ( Int, Maybe String, Inlines ) -> Parser PState ( Int, Int )
add_comment ( idx, temp_narrator, par ) =
    let
        mod s =
            let
                narrator =
                    case ( temp_narrator, s.defines.local ) of
                        ( Just tmp, _ ) ->
                            String.trim tmp

                        ( Nothing, Just local ) ->
                            local.narrator

                        _ ->
                            s.defines.global.narrator
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
                                        { cmt
                                            | comment = cmt.comment ++ "\\n" ++ stringify par
                                            , paragraphs = Array.push ( Nothing, par ) cmt.paragraphs
                                        }
                                        e.comments

                                _ ->
                                    Dict.insert idx
                                        (Element
                                            narrator
                                            (stringify par)
                                            (Array.fromList [ ( Nothing, par ) ])
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
