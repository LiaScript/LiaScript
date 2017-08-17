module Lia.Type
    exposing
        ( Block(..)
        , Hints
        , Inline(..)
        , Mode(..)
        , Msg(..)
        , Quiz(..)
        , QuizElement
        , QuizState(..)
        , QuizVector
        , Reference(..)
        , Slide
        )

import Array exposing (Array)


type Msg
    = Load Int
    | PrevSlide
    | NextSlide
    | CheckBox Int Int
    | RadioButton Int Int
    | Input Int String
    | Check Int
    | ScanIndex String
    | ContentsTable
    | Speak String
    | TTS (Result String Never)


type alias QuizVector =
    Array QuizElement


type alias QuizElement =
    { solved : Maybe Bool
    , state : QuizState
    , trial : Int
    , hint : Int
    }


type alias Hints =
    List (List Inline)


type QuizState
    = Single Int Int
    | Multi (Array ( Bool, Bool ))
    | Text String String


type Mode
    = Slides
    | Plain


type alias Slide =
    { indentation : Int
    , title : String
    , body : List Block
    , effects : Int
    }


type Block
    = HorizontalLine
    | CodeBlock String String
    | Quote (List Inline)
    | Paragraph (List Inline)
    | Table (List (List Inline)) (List String) (List (List (List Inline)))
    | Quiz Quiz Int
    | EBlock Int (List Block)


type Quiz
    = SingleChoice Int (List (List Inline))
    | MultipleChoice (List ( Bool, List Inline )) Hints
    | TextInput String



--    | Bullet List Block


type Inline
    = Chars String
    | Symbol String
    | Bold Inline
    | Italic Inline
    | Underline Inline
    | Superscript Inline
    | Code String
    | Formula Bool String
    | Ref Reference
    | HTML String
    | EInline Int (List Inline)


type Reference
    = Link String String
    | Image String String
    | Movie String String


type Lia
    = LiaBool Bool
    | LiaInt Int
    | LiaFloat Float
    | LiaString String
    | LiaList (List Lia)
    | LiaCmd String (List Lia)
