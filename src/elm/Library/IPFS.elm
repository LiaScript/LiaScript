module Library.IPFS exposing (isIPFS, toHTTPS, fromHTTPS, origin)

{-| `ipfs://` URLs are loaded through the gateway <https://ipfs.io/ipfs/>.

@docs isIPFS, toHTTPS, fromHTTPS, origin

-}


proxy : String
proxy =
    "https://ipfs.io/ipfs/"


protocol : String
protocol =
    "ipfs://"


{-| Does the URL start with `ipfs://`?
-}
isIPFS : String -> Bool
isIPFS =
    String.startsWith protocol


{-| The gateway URL of an `ipfs://` URL, otherwise `fallback`.
-}
toHTTPS : String -> String -> String
toHTTPS fallback url =
    if isIPFS url then
        String.replace protocol proxy url

    else
        fallback


{-| The `ipfs://` URL of a gateway URL.
-}
fromHTTPS : String -> Maybe String
fromHTTPS url =
    if String.startsWith proxy url then
        Just (String.replace proxy protocol url)

    else
        Nothing


{-| The `ipfs://` URL of an `ipfs://` or gateway URL.
-}
origin : String -> Maybe String
origin url =
    if isIPFS url then
        Just url

    else
        fromHTTPS url
