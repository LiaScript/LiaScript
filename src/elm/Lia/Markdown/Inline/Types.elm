module Lia.Markdown.Inline.Types exposing
    ( Annotation
    , Inline(..)
    , Inlines
    , MultInlines
    , Reference(..)
    , htmlBlock
    , isHTML
    )

import Dict exposing (Dict)
import Lia.Markdown.HTML.Types exposing (Node(..))


type alias Inlines =
    List Inline


type alias MultInlines =
    List Inlines


type alias Annotation =
    Maybe (Dict String String)


type Inline
    = Chars String Annotation
    | Symbol String Annotation
    | Bold Inline Annotation
    | Italic Inline Annotation
    | Strike Inline Annotation
    | Underline Inline Annotation
    | Superscript Inline Annotation
    | Verbatim String Annotation
    | Formula String String Annotation
    | Ref Reference Annotation
    | FootnoteMark String Annotation
    | EInline Int Int Inlines Annotation
    | IHTML (Node Inline) Annotation
    | Container Inlines Annotation
    | Goto Inline Int



--| Goto Inline Int


type Reference
    = Link Inlines String String
    | Mail Inlines String String
    | Image Inlines String String
    | Audio Inlines ( Bool, String ) String
    | Movie Inlines ( Bool, String ) String


isHTML : Inline -> Bool
isHTML inline =
    case inline of
        IHTML _ _ ->
            True

        _ ->
            False


htmlBlock : Inline -> Maybe ( String, List ( String, String ), List Inline )
htmlBlock inline =
    case inline of
        IHTML (Node name attributes content) attr ->
            Just ( name, attributes, [ Container content attr ] )

        _ ->
            Nothing
