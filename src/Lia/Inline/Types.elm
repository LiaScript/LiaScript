module Lia.Inline.Types exposing (Inline(..), Inlines, MultInlines, Reference(..), Url(..))


type alias Inlines =
    List Inline


type alias MultInlines =
    List Inlines


type Inline
    = Chars String
    | Symbol String
    | Bold Inline
    | Italic Inline
    | Strike Inline
    | Underline Inline
    | Superscript Inline
    | Verbatim String
    | Formula Bool String
    | Ref Reference
    | HTML String
    | EInline Int (Maybe String) Inlines
    | Container Inlines


type Url
    = Mail String
    | Full String
    | Partial String


type Reference
    = Link String Url
    | Image String Url (Maybe String)
    | Movie String Url (Maybe String)
