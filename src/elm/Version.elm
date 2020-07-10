module Version exposing (getMajor, toInt)


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


getMajor : String -> Int
getMajor ver =
    case ver |> String.split "." |> List.map String.toInt of
        (Just major) :: _ ->
            major

        _ ->
            0
