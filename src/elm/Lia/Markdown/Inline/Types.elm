module Lia.Markdown.Inline.Types exposing
    ( Inline(..)
    , Inlines
    , Reference(..)
    , combine
    , htmlBlock
    , mediaBlock
    )

import Lia.Markdown.Effect.Types exposing (Effect)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.HTML.Types exposing (Node(..))


{-| A line of text.
-}
type alias Inlines =
    List Inline


{-| All inline elements, every element can have annotations `Parameters`
(HTML attributes).
-}
type Inline
    = Chars String Parameters
    | Symbol String Parameters
    | Bold Inline Parameters
    | Italic Inline Parameters
    | Strike Inline Parameters
    | Underline Inline Parameters
    | Superscript Inline Parameters
    | Verbatim String Parameters
    | Formula String String Parameters
    | Ref Reference Parameters
    | FootnoteMark String Parameters
    | EInline (Effect Inline) Parameters
    | Script Int Parameters
    | IHTML (Node Inline) Parameters
    | Container Inlines Parameters
    | Quiz ( String, Int ) Parameters -- (width, id)


{-| Links and media, most of them have an alternative text, a url, and an
optional title. For audio and movies the `Bool` defines whether the url
refers to an embeddable player (`iframe`) or to a media file.
-}
type Reference
    = Link Inlines String (Maybe Inlines)
    | Mail Inlines String (Maybe Inlines)
    | Image Inlines String (Maybe Inlines)
    | Audio Inlines ( Bool, String ) (Maybe Inlines)
    | Movie Inlines ( Bool, String ) (Maybe Inlines)
    | Embed Inlines String (Maybe Inlines)
    | Preview_Lia String
    | Preview_Link String
    | QR_Link String (Maybe Inlines)


{-| Split an inline HTML element into its tag name, attributes, and content.
-}
htmlBlock : Inline -> Maybe ( String, List ( String, String ), List Inline )
htmlBlock inline =
    case inline of
        IHTML (Node name attributes content) attr ->
            Just ( name, attributes, [ Container content attr ] )

        _ ->
            Nothing


{-| Images, movies, audio, qr-codes, and embeds are rendered as figures.
-}
mediaBlock : Inline -> Bool
mediaBlock inline =
    case inline of
        Ref (Image _ _ _) _ ->
            True

        Ref (Movie _ _ _) _ ->
            True

        Ref (Audio _ _ _) _ ->
            True

        Ref (QR_Link _ _) _ ->
            True

        Ref (Embed _ _ _) _ ->
            True

        _ ->
            False


{-| Merge neighboring characters with the same annotations.
-}
combine : Inlines -> Inlines
combine list =
    combineHelper list [] [] []


{-| **@private:** Tail recursive helper of `combine`, neighboring texts with
the same annotations `attr` are collected in `pieces` and joined once, `++` per
piece would build a deep rope string, which costs a lot of memory.
-}
combineHelper : Inlines -> Parameters -> List String -> Inlines -> Inlines
combineHelper input attr pieces output =
    case input of
        [] ->
            List.reverse (flush attr pieces output)

        (Chars str attr_) :: is ->
            if List.isEmpty pieces || attr_ == attr then
                combineHelper is attr_ (str :: pieces) output

            else
                combineHelper is attr_ [ str ] (flush attr pieces output)

        i :: is ->
            combineHelper is [] [] (i :: flush attr pieces output)


{-| **@private:** Add the collected texts (in reverse order) as one `Chars`.
-}
flush : Parameters -> List String -> Inlines -> Inlines
flush attr pieces output =
    case pieces of
        [] ->
            output

        [ one ] ->
            Chars one attr :: output

        _ ->
            Chars (String.concat (List.reverse pieces)) attr :: output
