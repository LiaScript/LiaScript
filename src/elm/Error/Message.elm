module Error.Message exposing (..)


unknown : String
unknown =
    """It seems that an error has occured, but I do not know for sure what actually happened. There seems to be not enough information.
    
"""


getHelp : String
getHelp =
    "todo"


whatIsLiaScript : String
whatIsLiaScript =
    """LiaScript is domain specific language for educational content that is based on Markdown.
For more information visit some of the following sources:

* Project-website: https://LiaScript.github.io
* Documentation: https://github.com/liascript/docs
* YouTube: https://www.youtube.com/channel/UCyiTe2GkW_u05HSdvUblGYg
"""


emptyFile : String
emptyFile =
    """> The file you want me to load does not contain any content. Everything I see is only an empty string..."""


parseDefinintion : String -> String -> String
parseDefinintion code message =
    """
> I was trying to parse the **first** part of the course, which is either a
> HTML-comment or something else, until I reach the header (which is marked by
> an `#`). But, everything I got was the following:

```
"""
        ++ (code
                |> String.lines
                |> List.take 15
                |> List.intersperse "\n"
                |> String.concat
           )
        ++ """
...
```

> I might be wrong, but in most cases this refers to a falsly loaded HTML page!
>
> Please make shure, that the course you try to load is a Markdown file, which
> is served as a plain textfile...

---

**Error Message:**

```
"""
        ++ message
        ++ """
```

---

If it should work and you think you have detected bug, please contact us. For
more information see the [last Section](#get-help?).
"""
