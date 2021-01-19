module Index.Version exposing (getMajor, max, min, sort, toInt)

{-| Only for LiaScript-internal usage to handle and compare semantic versioning.

Versions are used to indicate, if something has changed. If the version-number
of a course did not change, then the preprocessed content can also be loaded
from the backend, if this is supported. (cf.: `hasIndex` in `src/elm/Main.elm`).

It is assumed that:

  - **Patch**: is updated if some typos have been corrected or the text and
    images have changed a littlebit

  - **Minor**: content has been added to the end of the document

  - **Major**: the structure of a document has changed entirely or
    segments, quizzes, surveys, and tasks have been moved around. In the
    browser, this will add a new "layer/version" to IndexedDB, since
    slide-numbers are used as primary keys.

> **Note:** If no version is defined, then `0` is used as default. A major
> version of `0` is treated as a LiaScript **development** version, which means,
> their updates are not stored permanently within the backend and that it gets
> parsed on every load.

-}


{-| Convert a semantic-version string (Major.Minor.Patch) to an integer, in
order to compare it with other versions.

Major numbers are multiplied with `10000`, Minor with `100` and Patch with `1`.

    toInt "1.1.1" =
        10101
    toInt "2.2" =
        20200
    toInt "3" =
        30000
    toInt "none" =
        0

-}
toInt : String -> Int
toInt str =
    case str |> String.split "." |> List.map String.toInt of
        (Just major) :: (Just minor) :: (Just patch) :: _ ->
            10000 * major + 100 * minor + patch

        (Just major) :: (Just minor) :: _ ->
            10000 * major + 100 * minor

        (Just major) :: _ ->
            10000 * major

        _ ->
            0


{-| Return only the Major version number, if no one is defined `0` is returned.

    getMajor "1.1.1" =
        1
    getMajor "2.2" =
        2
    getMajor "3" =
        3

    toInt "none" =
        0

-}
getMajor : String -> Int
getMajor ver =
    case ver |> String.split "." |> List.map String.toInt of
        (Just major) :: _ ->
            major

        _ ->
            0


{-| Sort a list of semantic version strings:

    sort [ "1.3.2", "33.1.1", "1.3.1" ]
        == [ "1.3.1", "1.3.2", "33.1.1" ]

-}
sort : List String -> List String
sort =
    List.sortBy toInt


{-| Get the minimal semantic version string:

    min [ "1.3.2", "33.1.1", "1.3.1" ]
        == Just "1.3.1"

-}
min : List String -> Maybe String
min =
    sort >> List.head


{-| Get the minimal semantic version string:

    max [ "1.3.2", "33.1.1", "1.3.1" ]
        == Just "33.1.1"

-}
max : List String -> Maybe String
max =
    sort >> List.reverse >> List.head
