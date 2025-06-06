module Error.Message exposing
    ( badStatus
    , emptyFile
    , getHelp
    , loadingCourse
    , loadingResource
    , multiple
    , parseDefinition
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

* mail: [LiaScript\\@web.de](mailto:LiaScript@web.de)
* chat: https://gitter.im/LiaScript/community
* twitter: https://twitter.com/liascript

Have nice day and happy coding!
"""


loadingCourse : String -> Http.Error -> String
loadingCourse =
    loadingError "It seems, that I could not load the following LiaScript document for some reason:"


badStatus : String -> Int -> String
badStatus url statusCode =
    "> I received a response back with a nice status code, but the status code indicates failure...\n\n"
        ++ parseNetworkError (Http.BadStatus statusCode)
        ++ "\n\n---\n\n"
        ++ "The following URL seems to be broken:\n\n"
        ++ url
        ++ "\n\n---\n\n"
        ++ "The error message is:\n\n"
        ++ (case statusCode of
                400 ->
                    "__Bad Request: The server cannot process the request due to a client error. The request may be malformed.__"
                        ++ "\n\n**Hint:** Check if the URL contains special characters that need encoding."

                401 ->
                    "__Unauthorized: Authentication is required and has failed or has not been provided.__"
                        ++ "\n\n**Hint:** You may need to log in or provide authentication credentials to access this resource."

                403 ->
                    "__Forbidden: You don't have permission to access this resource.__"
                        ++ "\n\n**Hint:** The server understood the request but refuses to authorize it. Contact the resource owner if you believe you should have access."

                404 ->
                    "__Not Found: The requested resource could not be found on the server.__"
                        ++ "\n\n1. **Hint:** Check if the URL is typed correctly. The resource might have been moved or deleted."
                        ++ "\n\n2. **Hint:** Check if the repository is publicly available, a private repository cannot be accessed."

                405 ->
                    "__Method Not Allowed: The request method is not supported for the requested resource.__"
                        ++ "\n\n**Hint:** This is typically a server configuration issue and not something you can fix as a user."

                408 ->
                    "__Request Timeout: The server timed out waiting for the request.__"
                        ++ "\n\n**Hint:** Try again later when your connection is more stable or the server is less busy."

                429 ->
                    "__Too Many Requests: You have sent too many requests in a given amount of time.__"
                        ++ "\n\n- **Hint:** Wait before trying again. The server is limiting how often you can access this resource."

                _ ->
                    if statusCode >= 400 && statusCode < 500 then
                        "__Client Error "
                            ++ String.fromInt statusCode
                            ++ ": Your request contains an error.__"
                            ++ "\n\n**Hint:** Check the URL and try again. If the problem persists, the resource might be temporarily unavailable."

                    else
                        "__Error "
                            ++ String.fromInt statusCode
                            ++ ": An unknown error occurred.__"
                            ++ "\n\n**Hint:** If this persists, contact the website administrator or check if the service is down."
           )


loadingResource : String -> Http.Error -> String
loadingResource =
    loadingError """I could not load the resource below. It contains a set of macros that need to
be loaded before the course. A later version of LiaScript might be more resilient
to errors, but at the moment everything needs to be in place..."""


loadingError : String -> String -> Http.Error -> String
loadingError message url networkStatus =
    let
        hasProxy =
            String.startsWith Const.urlProxy url

        rootUrl =
            if hasProxy then
                String.replace Const.urlProxy "" url

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

* Project-website: """ ++ Const.urlLiascript ++ """
* Blog: https://liascript.github.io/blog
* Documentation: https://liascript.github.io/course/?https://raw.githubusercontent.com/liaScript/docs/master/README.md
* YouTube: https://www.youtube.com/channel/UCyiTe2GkW_u05HSdvUblGYg

!?[LiaScript Intro](https://www.youtube.com/watch?v=YYhvGnE1PAA)
"""


emptyFile : String
emptyFile =
    """> The file you want me to load does not contain any content. Everything I see is only an empty string...
    
If you see this in message in an editor, try to copy and paste the following code:

```` md
<!--
author:   Your Name

email:    your@mail.org

version:  0.0.1

language: en

narrator: US English Female

comment:  Try to write a short comment about
          your course, multiline is also okay.
-->

# Course Main Title

This is your **course** initialization stub.

Please see the [Docs](""" ++ Const.urlLiascriptCourse ++ """https://raw.githubusercontent.com/liaScript/docs/master/README.md)
to find out what is possible in [LiaScript](""" ++ Const.urlLiascript ++ """).

If you want to use instant help in your Atom IDE, please type **lia** to see all available shortcuts.

## Markdown

You can use common [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) syntax to create your course, such as:

1. Lists
2. ordered or

   * unordered
   * ones ...


| Header 1   | Header 2   |
| :--------- | :--------- |
| Item 1     | Item 2     |


Images:

![images](https://farm2.static.flickr.com/1618/26701766821_7bea494826.jpg)


### Extensions

     --{{0}}--
But you can also include other features such as spoken text.

      --{{1}}--
Insert any kind of audio file:

       {{1}}
?[audio](https://bigsoundbank.com/UPLOAD/mp3/1068.mp3)


     --{{2}}--
Even videos or change the language completely.

       {{2-3}}
!?[video](https://www.youtube.com/watch?v=bICfKRyKTwE)


      --{{3 Russian Female}}--
Первоначально создан в 2004 году Джоном Грубером (англ. John Gruber) и Аароном
Шварцем. Многие идеи языка были позаимствованы из существующих соглашений по
разметке текста в электронных письмах...


    {{3}}
Type "voice" to see a list of all available languages.


### Styling

<!-- class = "animated rollIn" style = "animation-delay: 2s; color: purple" -->
The whole text-block should appear in purple color and with a wobbling effect.
Which is a **bad** example, please use it with caution ...
~~ only this is red ;-) ~~ <!-- class = "animated infinite bounce" style = "color: red;" -->

## Charts

Use ASCII-Art to draw diagrams:

                                    Multiline
    1.9 |    DOTS
        |                 ***
      y |               *     *
      - | r r r r r r r*r r r r*r r r r r r r
      a |             *         *
      x |            *           *
      i | B B B B B * B B B B B B * B B B B B
      s |         *                 *
        | *  * *                       * *  *
     -1 +------------------------------------
        0              x-axis               1

## Quizzes

### A Textquiz

What did the **fish** say when he hit a **concrete wall**?

    [[dam]]

### Multiple Choice

Just add as many points as you wish:

    [[X]] Only the **X** marks the correct point.
    [[ ]] Empty ones are wrong.
    [[X]] ...

### Single Choice

Just add as many points as you wish:

    [( )] ...
    [(X)] <-- Only the **X** is allowed.
    [( )] ...


## Executable Code

You can make your code executable and define projects:

``` js     -EvalScript.js
let who = data.first_name + " " + data.last_name;

if(data.online) {
  who + " is online"; }
else {
  who + " is NOT online"; }
```
``` json    +Data.json
{
  "first_name" :  "Sammy",
  "last_name"  :  "Shark",
  "online"     :  true
}
```
<script>
  // insert the JSON dataset into the local variable data
  let data = @input(1);

  // eval the script that uses this dataset
  eval(`@input(0)`);
</script>


## More

Find out what you also can do ...

""" ++ Const.urlLiascriptCourse ++ """https://raw.githubusercontent.com/liaScript/docs/master/README.md
````
"""


parseDefinition : Bool -> ( String, Int ) -> String -> String
parseDefinition first ( code, errorLine ) message =
    let
        begin =
            if errorLine < 10 then
                0

            else
                errorLine - 10

        end =
            if errorLine + 10 > String.length code then
                String.length code

            else
                errorLine + 10
    in
    (if first then
        """
> I was trying to parse the **first** part of the course, which is either an
> HTML-comment or something else, until I reach the header (which is marked by
> an `#`). But, everything I got was the following:"""

     else
        """> I have a problem with the following part of the code:"""
    )
        ++ """

<!-- data-showGutter data-firstLineNumber=\""""
        ++ String.fromInt begin
        ++ """" -->
````` markdown
...
"""
        ++ (code
                |> String.lines
                |> List.drop begin
                |> List.take (end - begin)
                |> String.join "\n"
           )
        ++ """
...
`````
"""
        ++ (if first then
                """
> I might be wrong, but in most cases this refers to a falsely loaded HTML page!
>
> Please make sure, that the course you try to load is a Markdown file, which
> is served as a plain text file...
"""

            else
                "> If you see this in the editor, try to fix it otherwise contact the creator.\n"
           )
        ++ """
---

**Error Message:**

```
"""
        ++ message
        ++ """
```

---

If it should work, and you think you have detected a bug, please contact us. For
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
                "This means I got a response back, but the status code indicates failure... You can check out [Wikipedia](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes) to see what the code means in detail."

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
