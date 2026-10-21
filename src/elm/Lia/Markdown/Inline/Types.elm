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


{-| Merge neighboring characters without annotations.
-}
combine : Inlines -> Inlines
combine list =
    combineHelper list []


{-| **@private:** Tail recursive helper of `combine`.
-}
combineHelper : Inlines -> Inlines -> Inlines
combineHelper input output =
    case ( input, output ) of
        ( [], _ ) ->
            List.reverse output

        ( (Chars str1 []) :: is, (Chars str2 []) :: os ) ->
            combineHelper is (Chars (str2 ++ str1) [] :: os)

        ( i :: is, _ ) ->
            combineHelper is (i :: output)
