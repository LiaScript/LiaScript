module Lia.Inline.Types exposing (Annotation, Inline(..), Inlines, MultInlines, Reference(..), Url(..))

import Dict exposing (Dict)


type alias Inlines =
    List Inline


type alias MultInlines =
    List Inlines


type alias Annotation =
    Maybe (Dict String String)


type Inline
    = Chars String
    | Symbol String
    | Bold Inline Annotation
    | Italic Inline
    | Strike Inline
    | Underline Inline
    | Superscript Inline
    | Verbatim String
    | Formula Bool String
    | Ref Reference
    | HTML String
    | EInline Int (Maybe String) String Inlines
    | Container Inlines



--| Annotated Inline Parameters


type Url
    = Mail String
    | Full String
    | Partial String


type Reference
    = Link String Url
    | Image String Url (Maybe String)
    | Movie String Url (Maybe String)
