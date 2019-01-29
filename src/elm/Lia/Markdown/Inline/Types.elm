module Lia.Markdown.Inline.Types exposing
    ( Annotation
    , Inline(..)
    , Inlines
    , MultInlines
    , Reference(..)
    )

import Dict exposing (Dict)
import Html.Parser


type alias Inlines =
    List Inline


type alias MultInlines =
    List Inlines


type alias Annotation =
    Maybe (Dict String String)


type Inline
    = Chars String Annotation
    | Bold Inline Annotation
    | Italic Inline Annotation
    | Strike Inline Annotation
    | Underline Inline Annotation
    | Superscript Inline Annotation
    | Verbatim String Annotation
    | Formula String String Annotation
    | Ref Reference Annotation
    | FootnoteMark String Annotation
    | HTML (List Html.Parser.Node)
    | EInline Int Int Inlines Annotation
    | Container Inlines Annotation


type Reference
    = Link Inlines String String
    | Mail Inlines String String
    | Image String String String
    | Audio String String String
    | Movie String String String
