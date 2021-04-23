module Error.Message exposing
    ( emptyFile
    , getHelp
    , loadingCourse
    , loadingResource
    , multiple
    , parseDefinintion
    , unknown
    , whatIsLiaScript
    )

import Const
import Http


multiple : String
multiple =
    """> There seem to be a couple of errors, I hope nothing really bad that cannot be fixed.
> However, I tried to list these errors within the following sub-subsections.
>
> If you have found a bug, contact us. See section [Get Help?](#get-help?)

"""


unknown : String
unknown =
    """It seems that an error has occurred, but I do not know for
sure what actually happened. There seems to be not enough information."""


getHelp : String
getHelp =
    """Feel free to contact us, if you need help, found a bug, or if you have some ideas for improvements.
You can reach us via:

* mail: LiaScript@web.de
* chat: https://gitter.im/LiaScript/community
* twitter: https://twitter.com/liascript

Have nice one 
"""


loadingCourse : String -> Http.Error -> String
loadingCourse =
    loadingError "It seems, that I could not load the following LiaScript document for some reason:"


loadingResource : String -> Http.Error -> String
loadingResource =
    loadingError """I could not load the resource below. It contains a set of macros that need to
be loaded before the course. A later version of LiaScript might be more resilient
to errors, but at the moment everything needs to be in place..."""


loadingError : String -> String -> Http.Error -> String
loadingError message url networkStatus =
    let
        hasProxy =
            String.startsWith Const.proxy url

        rootUrl =
            if hasProxy then
                String.replace Const.proxy "" url

            else
                url
    in
    "> "
        ++ message
        ++ "\n>\n> **"
        ++ rootUrl
        ++ " ** \n\n---\n"
        ++ "From the network I received the following status\n\n"
        ++ parseNetworkError networkStatus
        ++ (if hasProxy then
                "\n\n---\n\n**Note:** The URL below looks a bit strange...\n\n"
                    ++ url
                    ++ """


The reason for this is, that your resource could not be loaded in the first place.
In most cases this happens if
[CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing)
is not enabled on the root server. Hence, I tried to use a proxy to load it, but this didn't work either...
"""

            else
                ""
           )


whatIsLiaScript : String
whatIsLiaScript =
    """LiaScript is a domain specific language for educational content that is based on Markdown.
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
> I was trying to parse the **first** part of the course, which is either an
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

> I might be wrong, but in most cases this refers to a falsely loaded HTML page!
>
> Please make sure, that the course you try to load is a Markdown file, which
> is served as a plain text file...

---

**Error Message:**

```
"""
        ++ message
        ++ """
```

---

If it should work, and you think you have detected bug, please contact us. For
more information see the [last Section](#get-help?).
"""


{-| **@private:** Turns an Http.Error into a string message.
-}
parseNetworkError : Http.Error -> String
parseNetworkError msg =
    case msg of
        Http.BadUrl url ->
            reasonCause
                ("Bad Url " ++ url)
                "This means that the provided URL was not valid."

        Http.Timeout ->
            reasonCause
                "Network Timeout"
                "It took too long to get a response."

        Http.BadStatus int ->
            reasonCause
                ("Bad Status " ++ String.fromInt int)
                "This means I got a response back, but the status code indicates failure... You can check out [Wikipedia](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes) to see what this means in detail."

        Http.NetworkError ->
            reasonCause
                "Network Error"
                "This means that you might have no internet connection, have turned off your Wi-FI or you are in a cave..."

        Http.BadBody body ->
            reasonCause "Bad Body"
                "I received a response back with a nice status code, but the body of the response was something unexpected.\n\n```\n"
                ++ body
                ++ "\n```"


reasonCause : String -> String -> String
reasonCause reason cause =
    "**Error:** " ++ reason ++ "\n\n**Cause:** " ++ cause
