module Lia.Markdown.Code.Highlight2Ace exposing (highlight2ace)


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
    [ ( "actionscript"
      , [ "actionscript", "as" ]
      )
    , ( "apache_conf"
      , [ "apache", "apacheconf" ]
      )
    , ( "asciidoc"
      , [ "asciidoc", "adoc" ]
      )
    , ( "assembly_x86"
      , [ "x86asm", "armasm", "arm", "avrasm", "asm" ]
      )
    , ( "batchfile"
      , [ "bash", "sh", "zsh" ]
      )
    , ( "c_cpp"
      , [ "cpp", "c", "cc", "h", "c++", "h++", "hpp" ]
      )
    , ( "clojure"
      , [ "clojure", "clj" ]
      )
    , ( "coffee"
      , [ "coffeescript", "coffee", "cson", "iced" ]
      )
    , ( "csharp"
      , [ "cs", "csharp", "c#" ]
      )
    , ( "diff"
      , [ "diff", "patch" ]
      )
    , ( "django"
      , [ "django", "jinja" ]
      )
    , ( "dockerfile"
      , [ "dockerfile", "docker" ]
      )
    , ( "elixir"
      , [ "elixir", "ex", "exs" ]
      )
    , ( "erlang"
      , [ "erl", "erlang" ]
      )
    , ( "fsharp"
      , [ "fsharp", "fs", "f#" ]
      )
    , ( "fortran"
      , [ "fortran", "f90", "f95" ]
      )
    , ( "gcode"
      , [ "gcode", "nc" ]
      )
    , ( "golang"
      , [ "go", "golang" ]
      )
    , ( "handlebars"
      , [ "handlebars", "hbs", "html.hbs", "html.handlebars" ]
      )
    , ( "haskell"
      , [ "hs", "haskell" ]
      )
    , ( "haxe"
      , [ "haxe", "hx" ]
      )
    , ( "html"
      , [ "html", "xhtml", "rss", "atom", "xjb", "xsd", "xsl", "plist" ]
      )
    , ( "javascript"
      , [ "javascript", "js" ]
      )
    , ( "livescript"
      , [ "livescript", "ls" ]
      )
    , ( "makefile"
      , [ "makefile", "mk", "mak" ]
      )
    , ( "markdown"
      , [ "markdown", "md", "mkdown", "mkd" ]
      )
    , ( "ocaml"
      , [ "ocaml", "ml" ]
      )
    , ( "objectivec"
      , [ "objectivec", "mm", "objc", "obj-c" ]
      )
    , ( "pascal"
      , [ "delphi", "dpr", "dfm", "pas", "pascal", "freepascal", "lazarus", "lpr", "lfm" ]
      )
    , ( "php"
      , [ "php", "php3", "php4", "php5", "php6" ]
      )
    , ( "perl"
      , [ "perl", "pl", "pm" ]
      )
    , ( "powershell"
      , [ "powershell", "ps" ]
      )
    , ( "puppet"
      , [ "puppet", "pp" ]
      )
    , ( "python"
      , [ "python", "py", "gyp" ]
      )
    , ( "ruby"
      , [ "ruby", "rb", "gemspec", "podspec", "thor", "irb" ]
      )
    , ( "rust"
      , [ "rust", "rs" ]
      )
    , ( "scad"
      , [ "scad", "openscad" ]
      )
    , ( "sh"
      , [ "shell", "console" ]
      )
    , ( "stylus"
      , [ "stylus", "styl" ]
      )
    , ( "tcl"
      , [ "tcl", "tk" ]
      )
    , ( "twig"
      , [ "twig", "craftcms" ]
      )
    , ( "typescript"
      , [ "typescript", "ts" ]
      )
    , ( "vbscript"
      , [ "vbscript", "vbs" ]
      )
    , ( "verilog"
      , [ "v", "verilog" ]
      )
    , ( "xquery"
      , [ "xpath", "xq" ]
      )
    ]
