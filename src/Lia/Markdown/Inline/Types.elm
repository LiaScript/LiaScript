module Lia.Markdown.Inline.Types
    exposing
        ( Annotation
        , Inline(..)
        , Inlines
        , MultInlines
        , Reference(..)
        , Url(..)
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
    | HTML String
    | JavaScirpt String
    | EInline Int Int Inlines Annotation
    | Container Inlines Annotation


type Url
    = Mail String
    | Full String
    | Partial String


type Reference
    = Link String Url
    | Image String Url
    | Movie String Url
