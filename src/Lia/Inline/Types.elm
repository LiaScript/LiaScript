module Lia.Inline.Types exposing (Inline(..), Reference(..), Url(..))


type Inline
    = Chars String
    | Symbol String
    | Bold Inline
    | Italic Inline
    | Strike Inline
    | Underline Inline
    | Superscript Inline
    | Code String
    | Formula Bool String
    | Ref Reference
    | HTML String
    | EInline Int (Maybe String) (List Inline)
    | Container (List Inline)


type Url
    = Mail String
    | Full String
    | Partial String


type Reference
    = Link String Url
    | Image String Url (Maybe String)
    | Movie String Url (Maybe String)
