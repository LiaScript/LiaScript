module Lia.Markdown.Inline.Types exposing
    ( Inline(..)
    , Inlines
    , MultInlines
    , Reference(..)
    , htmlBlock
    )

import Lia.Markdown.Effect.Types exposing (Effect)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Settings.Model exposing (Mode(..))


type alias Inlines =
    List Inline


type alias MultInlines =
    List Inlines


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


htmlBlock : Inline -> Maybe ( String, List ( String, String ), List Inline )
htmlBlock inline =
    case inline of
        IHTML (Node name attributes content) attr ->
            Just ( name, attributes, [ Container content attr ] )

        _ ->
            Nothing
