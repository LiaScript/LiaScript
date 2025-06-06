module Lia.Parser.UrlPattern.OneDrive exposing (by, pattern)

import Base64
import Lia.Parser.UrlPattern.Generic as Generic


by : String -> String -> String
by _ w =
    createOneDriveLink ("https://onedrive.live.com/" ++ w)


pattern : String
pattern =
    Generic.root "onedrive\\.live\\.com/(.*)"


{-| **private:** creates a OneDrive link from a given URL

this is based on the following script:

<https://github.com/felixrieseberg/onedrive-link/blob/main/bin/onedrive-link>

-}
createOneDriveLink : String -> String
createOneDriveLink url =
    let
        -- Step 1: Convert to base64
        base64 =
            Base64.encode url

        -- Step 2: Replace '/' with '_' and '+' with '-'
        modifiedBase64 =
            base64
                |> String.replace "/" "_"
                |> String.replace "+" "-"

        -- Step 3: Remove trailing '=' character if present
        finalBase64 =
            if String.endsWith "=" modifiedBase64 then
                String.dropRight 1 modifiedBase64

            else
                modifiedBase64
    in
    "https://api.onedrive.com/v1.0/shares/u!" ++ finalBase64 ++ "/root/content"
