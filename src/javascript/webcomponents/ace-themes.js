"use strict";

function get_theme(name) {
  let theme_name = theme[name];

  return "ace/theme/" + theme_name ? theme_name : name;
}

const theme = {
//"actionscript":     "actionscript",
  "as":               "actionscript",

  "apache":           "apache_conf",
  "apacheconf":       "apache_conf",

  "adoc":             "asciidoc",
//"asciidoc":         "asciidoc",

  "arm":              "assembly_x86",
  "armasm":           "assembly_x86",
  "asm":              "assembly_x86",
  "avrasm":           "assembly_x86",
  "x86asm":           "assembly_x86",

  "bat":              "batchfile",
  "btm":              "batchfile",
  "cmd":              "batchfile",

  "c":                "c_cpp",
  "cc":               "c_cpp",
  "cpp":              "c_cpp",
  "c++":              "c_cpp",
  "h":                "c_cpp",
  "hpp":              "c_cpp",
  "h++":              "c_cpp",

  "clj":              "clojure",
//"clojure":          "clojure",

//"coffee":           "coffee",
  "coffeescript":     "coffee",
  "cson":             "coffee",
  "iced":             "coffee",

  "cs":               "csharp",
//"csharp":           "csharp",
  "c#":               "csharp",

//"diff":             "diff",
  "patch":            "diff",

//"django":           "django",
  "jinja":            "django",

  "docker":           "dockerfile",
//"dockerfile":       "dockerfile",

  "ex":               "elixir",
//"elixir":           "elixir",
  "exs":              "elixir",

  "erl":              "erlang",
//"erlang":           "erlang",

  "fs":               "fsharp",
//"fsharp":           "fsharp",
  "f#":               "fsharp",

//"fortran":          "fortran",
  "f90":              "fortran",
  "f95":              "fortran",

//"gcode":            "gcode",
  "nc":               "gcode",

  "go":               "golang",
//"golang":           "golang",

//"handlebars":       "handlebars",
  "hbs":              "handlebars",
  "html.handlebars":  "handlebars",
  "html.hbs":         "handlebars",

//"haskell":          "haskell",
  "hs":               "haskell",

//"haxe":             "haxe",
  "hx":               "haxe",

  "atom":             "html",
  "html":             "html",
  "plist":            "html",
  "rss":              "html",
  "xhtml":            "html",
  "xjb":              "html",
  "xsd":              "html",
  "xsl":              "html",

//"javascript":       "javascript",
  "js":               "javascript",

//"livescript":       "livescript",
  "ls":               "livescript",

  "mak":              "makefile",
//"makefile":         "makefile",
  "mk":               "makefile",

//"markdown":         "markdown",
  "md":               "markdown",
  "mkd":              "markdown",
  "mkdown":           "markdown",

  "ml":               "ocaml",
//"ocaml":            "ocaml",

  "mm":               "objectivec",
  "objc":             "objectivec",
//"objectivec":       "objectivec",
  "obj-c":            "objectivec",

  "delphi":           "pascal",
  "dfm":              "pascal",
  "dpr":              "pascal",
  "freepascal":       "pascal",
  "lazarus":          "pascal",
  "lfm":              "pascal",
  "lpr":              "pascal",
  "pas":              "pascal",
//"pascal":           "pascal",

//"php":              "php",
  "php3":             "php",
  "php4":             "php",
  "php5":             "php",
  "php6":             "php",

//"perl":             "perl",
  "pl":               "perl",
  "pm":               "perl",

//"powershell":       "powershell",
  "ps":               "powershell",

  "pp":               "puppet",
//"puppet":           "puppet",

  "gyp":              "python",
  "py":               "python",
//"python":           "python",

  "irb":              "ruby",
  "gemspec":          "ruby",
  "podspec":          "ruby",
  "rb":               "ruby",
//"ruby":             "ruby",
  "thor":             "ruby",

  "rs":               "rust",
//"rust":             "rust",

//"scad":             "scad",
  "openscad":         "scad",

  "bash":             "sh",
  "console":          "sh",
  "shell":            "sh",
  "zsh":              "sh",

  "styl":             "stylus",
//"stylus":           "stylus",

//"tcl":              "tcl",
  "tk":               "tcl",

  "craftcms":         "twig",
//"twig":             "twig",

  "ts":               "typescript",
//"typescript":       "typescript",

  "vbs":              "vbscript",
//"vbscript":         "vbscript",

  "v":                "verilog",
//"verilog":          "verilog",

  "xpath":            "xquery",
  "xq":               "xquery",
};

export default get_theme;
