module Library.IPFS exposing
    ( fromHTTPS
    , isIPFS
    , origin
    , toHTTPS
    )


proxy : String
proxy =
    "https://ipfs.io/ipfs/"


protocol : String
protocol =
    "ipfs://"


isIPFS : String -> Bool
isIPFS =
    String.startsWith protocol


toHTTPS : String -> String -> String
toHTTPS fallback url =
    if isIPFS url then
        String.replace protocol proxy url

    else
        fallback


fromHTTPS : String -> Maybe String
fromHTTPS url =
    if String.startsWith proxy url then
        url
            |> String.replace proxy protocol
            |> Just

    else
        Nothing


origin : String -> Maybe String
origin url =
    if isIPFS url then
        Just url

    else
        url
            |> fromHTTPS
