module Lia.Definition.Parser exposing (parse)

import Combine exposing (..)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Inline.Parser exposing (comment, comments, whitelines)
import Lia.PState exposing (PState)


parse : Parser PState ()
parse =
    lazy <|
        \() ->
            maybe definition
                *> many (choice [ whitelines, comments ])
                |> skip


definition : Parser PState ()
definition =
    lazy <|
        \() ->
            let
                list =
                    choice
                        [ string "author:" *> (ending >>= author)
                        , string "base:" *> (ending >>= base)
                        , string "comment:" *> (ending >>= comment_)
                        , string "date:" *> (ending >>= date)
                        , string "email:" *> (ending >>= email)
                        , string "language:" *> (ending >>= language)
                        , string "narrator:" *> (ending >>= narrator)
                        , string "script:" *> (ending >>= script)
                        , string "version:" *> (ending >>= version)
                        ]
            in
            (whitelines *> list <* whitelines)
                |> comment
                |> skip


ending : Parser s String
ending =
    String.trim <$> regex "[^\\n]+"


author : String -> Parser PState ()
author x =
    set (\def -> { def | author = x })


base : String -> Parser PState ()
base x =
    set (\def -> { def | base = x })


comment_ : String -> Parser PState ()
comment_ x =
    set (\def -> { def | comment = x })


date : String -> Parser PState ()
date x =
    set (\def -> { def | date = x })


email : String -> Parser PState ()
email x =
    set (\def -> { def | email = x })


language : String -> Parser PState ()
language x =
    set (\def -> { def | language = x })


narrator : String -> Parser PState ()
narrator x =
    set (\def -> { def | narrator = x })


script : String -> Parser PState ()
script x =
    set (\def -> { def | scripts = x :: def.scripts })


version : String -> Parser PState ()
version x =
    set (\def -> { def | version = x })



--set : (Definition -> Definition) -> PState -> PState
--set fct state =
--        { state | defines = fct state.defines }


set : (Definition -> Definition) -> Parser PState ()
set fct =
    modifyState (\s -> { s | defines = fct s.defines })
