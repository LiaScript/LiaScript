module Lia.Macro.Parser exposing (add, get, macro, pattern)

import Combine exposing (..)
import Dict exposing (Dict)
import Lia.Definition.Types exposing (Definition)
import Lia.PState exposing (PState, identation)
import Lia.Utils exposing (string_replace)


pattern : Parser s String
pattern =
    regex "@\\w+"


param : Parser PState String
param =
    choice
        [ string "```" *> regex "([^`]+|\\n)+" <* string "```"
        , string "`" *> regex "[^`\\n]+" <* string "`"
        , regex "[^),]+"
        ]


param_list : Parser PState (List String)
param_list =
    optional [] (parens (sepBy (string ",") param))


macro : Parser PState ()
macro =
    skip
        (maybe
            ((uid_macro >>= inject_macro)
                <|> (simple_macro >>= inject_macro)
                <|> macro_listing
            )
        )


uid_macro : Parser PState ( String, List String )
uid_macro =
    string "@uid" *> modifyState uid_update $> ( "@uid", [] )


uid_update : PState -> PState
uid_update state =
    let
        def =
            state.defines
    in
    { state | defines = { def | uid = def.uid + 1 } }


simple_macro : Parser PState ( String, List String )
simple_macro =
    (,) <$> pattern <*> param_list


code_block : Parser PState (List String)
code_block =
    manyTill
        (maybe identation *> regex "(.(?!```))*\\n?")
        (maybe identation *> string "```")


macro_listing : Parser PState ()
macro_listing =
    (string "```" *> regex ".*\\n" *> identation *> pattern)
        >>= (\name ->
                (param_list <* regex "[ \\t]*\\n")
                    >>= (\params ->
                            ((\code -> List.append params [ String.concat code ])
                                <$> code_block
                            )
                                >>= (\p -> inject_macro ( name, p ))
                        )
            )


inject_macro : ( String, List String ) -> Parser PState ()
inject_macro ( name, params ) =
    let
        inject state =
            case get name state.defines of
                Just code ->
                    let
                        code_ =
                            if state.identation == [] then
                                code
                            else
                                code
                                    |> String.lines
                                    |> String.join
                                        (state.identation
                                            |> String.concat
                                            |> (++) "\n"
                                        )

                        eval_param_ =
                            eval_param state

                        new_code =
                            params
                                |> List.indexedMap eval_param_
                                |> List.foldr string_replace code_
                    in
                    modifyStream ((++) new_code) *> succeed ()

                Nothing ->
                    fail "macro not found"
    in
    withState inject


eval_param : PState -> Int -> String -> ( String, String )
eval_param state int_key value =
    ( "@" ++ toString int_key, macro_parse value state )


get : String -> Definition -> Maybe String
get name def =
    case name of
        "@author" ->
            Just def.author

        "@date" ->
            Just def.date

        "@email" ->
            Just def.email

        "@version" ->
            Just def.version

        "@section" ->
            Just (toString def.section)

        "@uid" ->
            Just (toString def.section ++ "." ++ toString def.uid)

        _ ->
            Dict.get name def.macro


add : ( String, String ) -> Definition -> Definition
add ( name, code ) def =
    { def | macro = Dict.insert name code def.macro }


macro_parse : String -> PState -> String
macro_parse str defines =
    case runParser (String.concat <$> many1 (macro *> regex "[^@]+")) defines str of
        Ok ( _, _, s ) ->
            s

        _ ->
            str



{-
   module Lia.Macro.Parser exposing (add, get, macro, pattern)

   import Combine exposing (..)
   import Dict exposing (Dict)
   import Lia.Definition.Types exposing (Definition)
   import Lia.PState exposing (PState, identation)
   import Lia.Utils exposing (string_replace)


   pattern : Parser s String
   pattern =
       regex "@\\w+"


   param : Parser PState String
   param =
       choice
           [ string "```" *> regex "([^`]+|\\n)+" <* string "```"
           , string "`" *> regex "[^`\\n]+" <* string "`"
           , regex "[^),]+"
           ]


   param_list : Parser PState (List String)
   param_list =
       optional [] (parens (sepBy (string ",") param))



   {-
      macro : Parser PState ()
      macro =
          skip
              (maybe
                  ((pattern
                      >>= (\name ->
                              param_list >>= (\p -> identation_str >>= inject_macro name p)
                          )
                   )
                      <|> macro_listing
                  )
              )
   -}


   macro : Parser PState ()
   macro =
       simple_macro
           -- <|> listing_macro)
           >>= inject_macro
           |> maybe
           |> skip


   simple_macro : Parser PState ( String, List String )
   simple_macro =
       (,) <$> pattern <*> param_list


   code_line : Parser PState String
   code_line =
       maybe identation *> regex "(.(?!```))*\\n?"



   {-
      listing_macro : Parser PState ()
      listing_macro =
          (string "```" *> regex ".*\\n" *> identation *> pattern)
              >>= (\name ->
                      (param_list <* regex "[ \\t]*\\n")
                          >>= (\params ->
                                  ((\code -> List.append params [ String.concat code ])
                                      <$> manyTill code_line (identation *> string "```")
                                  )
                                      >>= (\p -> inject_macro name p)
                              )
                  )
   -}


   listing_macro : Parser PState ( String, List String )
   listing_macro =
       (\name params code -> ( name, List.append params [ String.concat code ] ))
           <$> (string "```" *> regex ".*\\n" *> identation *> pattern)
           <*> (param_list <* regex "[ \\t]*\\n")
           <*> manyTill code_line (identation *> string "```")


   inject_macro : ( String, List String ) -> Parser PState ()
   inject_macro ( name, params ) =
       let
           inject state =
               case get name state.defines of
                   Just code ->
                       let
                           code_ =
                               if state.identation == [] then
                                   code
                               else
                                   code
                                       |> String.lines
                                       |> String.join
                                           (state.identation
                                               |> String.concat
                                               |> (++) "\n"
                                           )

                           eval_param_ =
                               eval_param state

                           new_code =
                               params
                                   |> List.indexedMap eval_param_
                                   |> List.foldr string_replace code_
                       in
                       modifyStream ((++) new_code) *> succeed ()

                   Nothing ->
                       fail "macro not found"
       in
       withState succeed >>= inject


   eval_param : PState -> Int -> String -> ( String, String )
   eval_param state int_key value =
       ( "@" ++ toString int_key, macro_parse value state )


   get : String -> Definition -> Maybe String
   get name def =
       case name of
           "@author" ->
               Just def.author

           "@date" ->
               Just def.date

           "@email" ->
               Just def.email

           "@version" ->
               Just def.version

           _ ->
               Dict.get name def.macro


   add : ( String, String ) -> Definition -> Definition
   add ( name, code ) def =
       { def | macro = Dict.insert name code def.macro }


   macro_parse : String -> PState -> String
   macro_parse str defines =
       case runParser (String.concat <$> many1 (macro *> regex "[^@]+")) defines str of
           Ok ( _, _, s ) ->
               s

           _ ->
               str

-}
