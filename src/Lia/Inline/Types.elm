module Lia.Inline.Types exposing (ID, Inline(..), Line, Reference(..), Url(..))


type alias Line =
    List Inline


type alias ID =
    Int


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
