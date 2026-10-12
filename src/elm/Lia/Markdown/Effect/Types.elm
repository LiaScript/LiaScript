module Lia.Markdown.Effect.Types exposing
    ( Class(..)
    , Effect
    , class
    , empty
    , init
    , isIn
    )

{-| An animation fragment, either a block `{{1-3}}` or an inline `{1}{text}`.
The `content` is the wrapped markdown, `id` the running number of the effect
within its section, which is used to identify it during playback.
-}


{-| `begin` is the animation step at which the content appears (-1 if it is
not animated) and `end` the step at which it disappears again. `playback`
adds a button that reads the content out loud with the given `voice`.
-}
type alias Effect body =
    { content : List body
    , playback : Bool
    , begin : Int
    , end : Maybe Int
    , voice : String
    , id : Int
    }


{-| An empty effect, spoken with the passed narrator voice.
-}
init : String -> Effect body
init voice =
    { playback = False
    , begin = -1
    , end = Nothing
    , content = []
    , voice = voice
    , id = -1
    }


{-| Is the effect visible at the current animation step? `Nothing` (textbook
mode) shows everything.
-}
isIn : Maybe Int -> Effect x -> Bool
isIn visible effect =
    case visible of
        Nothing ->
            True

        Just id ->
            case effect.end of
                Nothing ->
                    effect.begin <= id

                Just end ->
                    effect.begin <= id && id < end


{-| An effect without animation step and playback is no effect at all.
-}
empty : Effect body -> Bool
empty e =
    not e.playback && e.begin < 0


{-| How to render an effect: only animated, only a playback button, or both.
-}
type Class
    = Animation
    | PlayBack
    | PlayBackAnimation


{-| -}
class : Effect body -> Class
class effect =
    if not effect.playback then
        Animation

    else if effect.begin < 0 then
        PlayBack

    else
        PlayBackAnimation
