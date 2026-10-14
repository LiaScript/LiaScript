module Lia.Markdown.Effect.Parser exposing
    ( comment
    , hidden_comment
    , inline
    , markdown
    )

{-| Parsers for animations and narrator comments:

    {{1-2 |> Voice}}         block effect, a single block or several
    ****                     blocks wrapped in stars
    ...
    ****

    {1}{inline effect}

    --{{1 Voice}}--
    narrator comment

    <!-- --{{1}}-- hidden narrator comment -->

All of them register their animation step in `effect_model.effects`, comments
are stored in `effect_model.comments`.

-}

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , choice
        , fail
        , ignore
        , keep
        , manyTill
        , map
        , maybe
        , modifyState
        , optional
        , or
        , putState
        , regex
        , skip
        , string
        , succeed
        , whitespace
        , withState
        )
import Combine.Char exposing (anyChar)
import Combine.Num exposing (int)
import Dict
import Lia.Markdown.Effect.Model exposing (Content, Element)
import Lia.Markdown.Effect.Types as Effect exposing (Effect)
import Lia.Markdown.Inline.Multimedia exposing (providerOf)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..))
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Types as Markdown
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newlines, spaces1)
import Lia.Parser.Indentation as Indent


{-| A block effect `{{...}}`, followed by a single block or by several blocks
enclosed in lines of at least three stars.
-}
markdown : Parser Context Markdown.Block -> Parser Context (Effect Markdown.Block)
markdown blocks =
    regex "[\t ]*{{"
        |> keep definition
        |> map setContent
        |> ignore (regex "}}[\t ]*")
        |> ignore (or (skip (string "\n")) Indent.skip)
        |> andMap (or (multi blocks) (map List.singleton blocks))
        |> ignore reset_effect_number
        |> andMap effect_id


multi : Parser Context Markdown.Block -> Parser Context Markdown.Blocks
multi blocks =
    Indent.check
        |> ignore (regex "[\t ]*\\*{3,}\n+")
        |> keep
            (manyTill
                (blocks |> ignore newlines)
                (regex "[\t ]*\\*{3,}")
            )


{-| An inline effect `{...}{content}`.
-}
inline : Parser Context Inline -> Parser Context (Effect Inline)
inline inlines =
    string "{"
        |> keep definition
        |> map setContent
        |> ignore (string "}{")
        |> andMap (manyTill inlines (string "}"))
        |> ignore reset_effect_number
        |> andMap effect_id


setContent : Effect x -> List x -> Int -> Effect x
setContent e content id =
    { e | content = content, id = id }


{-| The animation step, which is also pushed onto `effect_number`, so that
nested elements know the step they belong to (removed again by
`reset_effect_number`). The maximum step is stored in `effects`.
-}
effect_number : Parser Context Int
effect_number =
    int
        |> andThen
            (\n ->
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
            )


{-| Up to four modifiers in any order: a begin `1`, an end `-3`, a playback
`|>` or `!>` and a voice. At least a begin or a playback is required.
-}
definition : Parser Context (Effect x)
definition =
    withState (.defines >> .narrator >> succeed)
        |> map Effect.init
        |> andThen modifier
        |> andThen modifier
        |> andThen modifier
        |> andThen modifier
        |> andThen
            (\e ->
                if Effect.empty e then
                    fail "no effect definition"

                else
                    succeed e
            )


modifier : Effect x -> Parser Context (Effect x)
modifier e =
    whitespace
        |> keep
            (choice
                [ regex "-[\t ]*"
                    |> keep int
                    |> map (\i -> { e | end = Just i })
                , effect_number
                    |> map (\i -> { e | begin = i })
                , string "|>"
                    |> or (string "!>")
                    |> keep (succeed { e | playback = True })
                , macro
                    |> keep (regex "([A-Za-z][A-Za-z0-9]+[ \t]*)+")
                    |> map (\str -> { e | voice = String.trim str })
                ]
            )
        |> optional e


{-| The running number of the effect within the section.
-}
effect_id : Parser Context Int
effect_id =
    withState (.effect_id >> succeed)
        |> ignore (modifyState (\s -> { s | effect_id = s.effect_id + 1 }))


reset_effect_number : Parser Context ()
reset_effect_number =
    modifyState (\s -> { s | effect_number = List.drop 1 s.effect_number })


{-| A narrator comment `--{{1 Voice}}--` followed by a paragraph. Returns the
animation step and the position of the paragraph within its comments.
-}
comment : Parser Context Inlines -> Parser Context ( Int, Int )
comment paragraph =
    regex "[\t ]*--{{"
        |> keep commentHead
        |> ignore (maybe (newlines |> ignore Indent.check))
        |> andMap paragraph
        |> andThen (add_comment True)
        |> ignore reset_effect_number


{-| A narrator comment that is hidden within an HTML comment
`<!-- --{{1 Voice}}-- ... -->`, it is only read out loud.
-}
hidden_comment : Parser Context ()
hidden_comment =
    regex "<!--[\t ]*--{{"
        |> keep commentHead
        |> andMap
            (manyTill anyChar (string "-->")
                |> map (\text -> [ Chars (text |> String.fromList |> String.trim) [] ])
            )
        |> ignore reset_effect_number
        |> andThen (add_comment False)
        |> skip


{-| The rest of `--{{1 Voice}}--` after `--{{`, the voice is optional.
-}
commentHead : Parser Context (Inlines -> ( Int, Maybe String, Inlines ))
commentHead =
    effect_number
        |> map (\i voice text -> ( i, voice, text ))
        |> andMap
            (spaces1
                |> keep macro
                |> keep (regex "[A-Za-z0-9 ]+")
                |> maybe
            )
        |> ignore (regex "}}--[\t ]*")


{-| Append the paragraph to the comments of animation step `idx`. The first
comment of a step defines its narrator. An audio or video link at the
beginning or the end of the paragraph is moved into `audio` or `video`.
-}
add_comment : Bool -> ( Int, Maybe String, Inlines ) -> Parser Context ( Int, Int )
add_comment visible ( idx, narrator, par ) =
    withState
        (\s ->
            let
                content =
                    media True par visible

                e =
                    s.effect_model

                element =
                    case Dict.get idx e.comments of
                        Just cmt ->
                            { cmt | content = Array.push content cmt.content }

                        Nothing ->
                            narrator
                                |> Maybe.map String.trim
                                |> Maybe.withDefault s.defines.narrator
                                |> (\n -> Element n (Array.fromList [ content ]))
            in
            putState { s | effect_model = { e | comments = Dict.insert idx element e.comments } }
                |> keep (succeed ( idx, Array.length element.content - 1 ))
        )


{-| Turn a paragraph into a `Content`, with a leading audio, video or embedded
video (YouTube, Vimeo, ...) link as recording. If there is none (`start`), the last element is checked too.
-}
media : Bool -> Inlines -> Bool -> Content
media start par visible =
    case par of
        (Ref (Audio _ ( False, audio ) _) _) :: rest ->
            Content visible [] rest (Array.fromList [ audio ]) Array.empty Array.empty

        (Ref (Movie _ ( False, video ) _) _) :: rest ->
            Content visible [] rest Array.empty (Array.fromList [ video ]) Array.empty

        (Ref (Movie _ ( True, embed ) _) _) :: rest ->
            Content visible [] rest Array.empty Array.empty (Array.fromList [ { url = embed, provider = providerOf embed } ])

        _ ->
            if start then
                media False (List.reverse par) visible
                    |> (\c -> { c | content = List.reverse c.content })

            else
                Content visible [] par Array.empty Array.empty Array.empty
