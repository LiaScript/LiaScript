module UrlResolution exposing (resourceOriginSuite, suite)

{-| Relative resource URLs (images, `src`/`href` attributes) are resolved by
concatenating the course's `origin` with the relative path and then
re-running `link`, since GitLab's raw-file API isn't a real directory
hierarchy - `origin` must stay in its untranslated, hierarchical form so
that concatenation makes sense before `link` rewrites the whole thing.
-}

import Expect
import Lia.Markdown.HTML.Attributes exposing (toURL)
import Lia.Parser.PatReplace exposing (link, resourceOrigin)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "toURL (relative resource resolution)"
        [ test "self-hosted GitLab: sibling image resolves through the raw-files API" <|
            \_ ->
                toURL "https://gitlab.opencode.de/oc00016929979/liascript/-/blob/main/" "" "test.png"
                    |> Expect.equal "https://gitlab.opencode.de/api/v4/projects/oc00016929979%2Fliascript/repository/files/test.png/raw?ref=main"
        , test "GitHub: sibling image resolves through raw.githubusercontent.com" <|
            \_ ->
                toURL "https://github.com/LiaScript/docs/blob/master/" "" "img/logo.png"
                    |> Expect.equal "https://raw.githubusercontent.com/LiaScript/docs/master/img/logo.png"
        , test "plain website: relative path is left untouched" <|
            \_ ->
                toURL "https://example.com/course/" "" "pic.jpg"
                    |> Expect.equal "https://example.com/course/pic.jpg"
        , test "absolute URLs bypass the origin entirely" <|
            \_ ->
                toURL "https://gitlab.opencode.de/oc00016929979/liascript/-/blob/main/" "" "https://other.host/pic.jpg"
                    |> Expect.equal "https://other.host/pic.jpg"
        , test "gitlab.com: file nested in a subfolder is percent-encoded as a single path segment" <|
            \_ ->
                toURL "https://gitlab.com/dannori/wvs-liascript/-/raw/main/LF04/" "" "verschluesselung.md"
                    |> Expect.equal "https://gitlab.com/api/v4/projects/dannori%2Fwvs-liascript/repository/files/LF04%2Fverschluesselung.md/raw?ref=main"
        , test "gitlab.com: link is idempotent on an already-resolved API URL (query survives a second pass)" <|
            \_ ->
                let
                    resolved =
                        "https://gitlab.com/api/v4/projects/dannori%2Fwvs-liascript/repository/files/LF04%2Fverschluesselung.md/raw?ref=main"
                in
                link resolved
                    |> Expect.equal resolved
        ]


{-| The browser's address bar ends up holding the *resolved* course URL after
every load (LiaScript canonicalizes it there), not the original human-typed
one - so `resourceOrigin` has to work from that resolved form directly.
-}
resourceOriginSuite : Test
resourceOriginSuite =
    describe "resourceOrigin (origin from an already-resolved URL)"
        [ test "gitlab.com: unpacks the API URL back into its hierarchical directory" <|
            \_ ->
                resourceOrigin "https://gitlab.com/api/v4/projects/dannori%2Fwvs-liascript/repository/files/LF04%2Fverschluesselung.md/raw?ref=main"
                    |> Expect.equal "https://gitlab.com/dannori/wvs-liascript/-/raw/main/LF04/"
        , test "gitlab.com: file at the repo root has no directory segment" <|
            \_ ->
                resourceOrigin "https://gitlab.com/api/v4/projects/dannori%2Fwvs-liascript/repository/files/README.md/raw?ref=main"
                    |> Expect.equal "https://gitlab.com/dannori/wvs-liascript/-/raw/main/"
        , test "self-hosted GitLab: same unpacking, any domain" <|
            \_ ->
                resourceOrigin "https://gitlab.opencode.de/api/v4/projects/oc00016929979%2Fliascript/repository/files/README.md/raw?ref=main"
                    |> Expect.equal "https://gitlab.opencode.de/oc00016929979/liascript/-/raw/main/"
        , test "GitHub: already-hierarchical URLs just get their last segment cut off" <|
            \_ ->
                resourceOrigin "https://raw.githubusercontent.com/LiaScript/docs/master/README.md"
                    |> Expect.equal "https://raw.githubusercontent.com/LiaScript/docs/master/"
        , test "round-trip: resourceOrigin + toURL reconstructs the exact working image URL" <|
            \_ ->
                let
                    resolvedReadme =
                        "https://gitlab.com/api/v4/projects/dannori%2Fwvs-liascript/repository/files/LF04%2Fverschluesselung.md/raw?ref=main"
                in
                toURL (resourceOrigin resolvedReadme) "?ref=main" "02_img/lf4_ls1_asymmetrische_verschluesselung.svg"
                    |> Expect.equal "https://gitlab.com/api/v4/projects/dannori%2Fwvs-liascript/repository/files/LF04%2F02_img%2Flf4_ls1_asymmetrische_verschluesselung.svg/raw?ref=main"
        ]
