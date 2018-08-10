module Lia.Code.Highlight2Ace exposing (highlight2ace)


highlight2ace : String -> String
highlight2ace lang =
    lang
        |> String.toLower
        |> check translations


check : List ( String, List String ) -> String -> String
check t lang =
    case t of
        [] ->
            lang

        ( ace, highlightjs ) :: ts ->
            if List.member lang highlightjs then
                ace
            else
                check ts lang


translations : List ( String, List String )
translations =
    [ ( "actionscript", [ "actionscript", "as" ] )
    , ( "apache_conf", [ "apache", "apacheconf" ] )
    , ( "asciidoc", [ "asciidoc", "adoc" ] )
    , ( "assembly_x86", [ "armasm", "arm", "avrasm" ] )
    , ( "batchfile", [ "bash", "sh", "zsh" ] )
    , ( "c_cpp", [ "cpp", "c", "cc", "h", "c++", "h++", "hpp" ] )
    , ( "clojure", [ "clojure", "clj" ] )
    , ( "coffee", [ "coffeescript", "coffee", "cson", "iced" ] )
    , ( "csharp", [ "cs", "csharp" ] )
    , ( "diff", [ "diff", "patch" ] )
    , ( "dockerfile", [ "dockerfile", "docker" ] )
    , ( "erlang", [ "erl", "erlang" ] )
    , ( "gcode", [ "gcode", "nc" ] )
    , ( "golang", [ "go", "golang" ] )
    , ( "handlebars", [ "handlebars", "hbs", "html.hbs", "html.handlebars" ] )
    , ( "haskell", [ "hs", "haskell" ] )
    , ( "haxe", [ "haxe", "hx" ] )
    , ( "html", [ "html", "xhtml", "rss", "atom", "xjb", "xsd", "xsl", "plist" ] )
    , ( "javascript", [ "javascript", "js" ] )
    , ( "livescript", [ "livescript", "ls" ] )
    , ( "makefile", [ "makefile", "mk", "mak" ] )
    , ( "markdown", [ "markdown", "md", "mkdown", "mkd" ] )
    , ( "ocaml", [ "ocaml", "ml" ] )
    , ( "objectivec", [ "objectivec", "mm", "objc", "obj-c" ] )
    , ( "php", [ "php", "php3", "php4", "php5", "php6" ] )
    , ( "perl", [ "perl", "pl", "pm" ] )
    , ( "powershell", [ "powershell", "ps" ] )
    , ( "python", [ "python", "py", "gyp" ] )
    , ( "ruby", [ "ruby", "rb", "gemspec", "podspec", "thor", "irb" ] )
    , ( "stylus", [ "stylus", "styl" ] )
    , ( "tcl", [ "tcl", "tk" ] )
    , ( "twig", [ "twig", "craftcms" ] )
    , ( "typescript", [ "typescript", "ts" ] )
    , ( "vbscript", [ "vbscript", "vbs" ] )
    , ( "verilog", [ "v", "verilog" ] )
    , ( "xquery", [ "xpath", "xq" ] )
    ]
