module Lia.Inline.Types exposing (Inline(..), Reference(..))


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
    | EInline Int (List Inline)
    | Container (List Inline)


type Reference
    = Link String String
    | Image String String String
    | Movie String String String
