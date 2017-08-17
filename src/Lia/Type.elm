module Lia.Type
    exposing
        ( Block(..)
        , Inline(..)
        , Mode(..)
        , Msg(..)
        , Quiz(..)
        , QuizMatrix
        , QuizState(..)
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
    | ContentsTable
    | Speak String
    | TTS (Result String Never)


type alias QuizMatrix =
    Array ( Maybe Bool, QuizState, Int )


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
    | MultipleChoice (List ( Bool, List Inline ))
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
