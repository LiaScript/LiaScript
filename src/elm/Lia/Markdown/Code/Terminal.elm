module Lia.Markdown.Code.Terminal exposing
    ( Msg(..)
    , Terminal
    , init
    , update
    , view
    )

import Accessibility.Key exposing (enter)
import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import I18n.Translations exposing (Lang(..))
import Lia.Markdown.Code.Editor as Editor
import Lia.Markdown.Effect.Script.Types exposing (Msg(..))


type alias Terminal =
    { input : String
    , backup : String
    , history : Array String
    , history_value : Int
    , enter : Bool
    }


init : Terminal
init =
    Terminal "" "" Array.empty 0 False



-- UPDATE


type Msg
    = Ignore
    | History Bool
    | Enter
    | Input String


update : Msg -> Terminal -> ( Terminal, Maybe String )
update msg terminal =
    case msg of
        Enter ->
            ( print_to { terminal | enter = True }
            , Just <| terminal.input ++ "\n"
            )

        History up ->
            ( restore_input up terminal
            , Nothing
            )

        Input str ->
            ( { terminal
                | input =
                    if terminal.enter then
                        terminal.input

                    else
                        str
                , enter = False
              }
            , Nothing
            )

        Ignore ->
            ( terminal
            , Nothing
            )



-- VIEW


view : Terminal -> Html Msg
view terminal =
    Html.div
        [ Attr.class "lia-code-terminal__input"
        ]
        [ Html.i [ Attr.class "icon icon-chevron-double-right" ] []
        , Editor.editor
            [ Editor.onChange Input
            , Attr.style "min-height" "3.4rem"
            , Attr.style "max-height" "3.4rem"
            , Editor.readOnly False
            , Editor.value terminal.input
            , Editor.showCursor True
            , Editor.highlightActiveLine True
            , Editor.mode "js"
            , Attr.style "width" "100%"
            , Editor.showGutter False
            , Editor.theme "twilight"
            , Editor.showPrintMargin False
            , Editor.maxLines 10
            , Attr.style "min-height" <|
                "calc( "
                    ++ (terminal.input |> String.lines |> List.length |> String.fromInt)
                    ++ " * var(--global-font-size, 1.5rem) * var(--font-size-multiplier) * 1.3333 + 1.47rem)"

            -- Example of using the new key binding system
            , Editor.keyBindings
                [ ( "execute", { win = "Enter", mac = "Enter" }, "terminalExecute" )
                , ( "historyUp", { win = "Up", mac = "Up" }, "terminalHistoryUp" )
                , ( "historyDown", { win = "Down", mac = "Down" }, "terminalHistoryDown" )
                , ( "enlarge", { win = "Shift-Enter", mac = "Command-Enter" }, "terminalEnlarge" )
                ]
            , Editor.onKeyBinding "terminalExecute" Enter
            , Editor.onKeyBinding "terminalHistoryUp" (History True)
            , Editor.onKeyBinding "terminalHistoryDown" (History False)
            , Editor.onKeyBinding "terminalEnlarge" Ignore
            ]
            []
        ]


print_to : Terminal -> Terminal
print_to terminal =
    if
        (terminal.history
            |> Array.get terminal.history_value
            |> Maybe.map (\h -> h /= terminal.input)
            |> Maybe.withDefault True
        )
            && (terminal.input /= "")
    then
        { terminal
            | input = ""
            , history = Array.push terminal.input terminal.history
            , history_value = Array.length terminal.history + 1
        }

    else
        { terminal
            | input = ""
            , history_value = terminal.history_value + 1
        }


restore_input : Bool -> Terminal -> Terminal
restore_input up terminal =
    let
        new_hist =
            if up then
                if terminal.history_value > 0 then
                    terminal.history_value - 1

                else
                    0

            else if terminal.history_value < Array.length terminal.history then
                terminal.history_value + 1

            else
                terminal.history_value
    in
    case Array.get new_hist terminal.history of
        Just str ->
            { terminal
                | input = str
                , history_value = new_hist
                , backup =
                    if terminal.history_value == Array.length terminal.history then
                        terminal.input

                    else
                        terminal.backup
            }

        Nothing ->
            { terminal
                | input = terminal.backup
                , history_value = new_hist
            }
