module Lia.Markdown.Inline.Types exposing
    ( Annotation
    , Inline(..)
    , Inlines
    , MultInlines
    , Reference(..)
    )

import Dict exposing (Dict)


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
    | Formula Bool String Annotation
    | Ref Reference Annotation
    | FootnoteMark String Annotation
    | HTML String
    | EInline Int Int Inlines Annotation
    | Container Inlines Annotation


type Reference
    = Link String String
    | Image String String
    | Audio String String
    | Movie String String
    | Mail String String
