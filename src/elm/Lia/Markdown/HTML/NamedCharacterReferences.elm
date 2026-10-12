module Lia.Markdown.HTML.NamedCharacterReferences exposing (get)

{-| HTML named character references, source:
<https://www.w3.org/TR/html5/syntax.html#named-character-references>
-}


{-| Translate the name of a character reference (without `&` and `;`) into its
characters:

    get "amp" == Just "&"

    get "unknown" == Nothing

A `case` instead of a `Dict`, a top-level `Dict` with 2125 entries would be
built on every app start, although it is hardly ever needed.

-}
get : String -> Maybe String
get name =
    case name of
        "Aacute" ->
            Just "Á"

        "aacute" ->
            Just "á"

        "Abreve" ->
            Just "Ă"

        "abreve" ->
            Just "ă"

        "ac" ->
            Just "∾"

        "acd" ->
            Just "∿"

        "acE" ->
            Just "∾̳"

        "Acirc" ->
            Just "Â"

        "acirc" ->
            Just "â"

        "acute" ->
            Just "´"

        "Acy" ->
            Just "А"

        "acy" ->
            Just "а"

        "AElig" ->
            Just "Æ"

        "aelig" ->
            Just "æ"

        "af" ->
            Just "\u{2061}"

        "Afr" ->
            Just "\u{D835}\u{DD04}"

        "afr" ->
            Just "\u{D835}\u{DD1E}"

        "Agrave" ->
            Just "À"

        "agrave" ->
            Just "à"

        "alefsym" ->
            Just "ℵ"

        "aleph" ->
            Just "ℵ"

        "Alpha" ->
            Just "Α"

        "alpha" ->
            Just "α"

        "Amacr" ->
            Just "Ā"

        "amacr" ->
            Just "ā"

        "amalg" ->
            Just "⨿"

        "amp" ->
            Just "&"

        "AMP" ->
            Just "&"

        "andand" ->
            Just "⩕"

        "And" ->
            Just "⩓"

        "and" ->
            Just "∧"

        "andd" ->
            Just "⩜"

        "andslope" ->
            Just "⩘"

        "andv" ->
            Just "⩚"

        "ang" ->
            Just "∠"

        "ange" ->
            Just "⦤"

        "angle" ->
            Just "∠"

        "angmsdaa" ->
            Just "⦨"

        "angmsdab" ->
            Just "⦩"

        "angmsdac" ->
            Just "⦪"

        "angmsdad" ->
            Just "⦫"

        "angmsdae" ->
            Just "⦬"

        "angmsdaf" ->
            Just "⦭"

        "angmsdag" ->
            Just "⦮"

        "angmsdah" ->
            Just "⦯"

        "angmsd" ->
            Just "∡"

        "angrt" ->
            Just "∟"

        "angrtvb" ->
            Just "⊾"

        "angrtvbd" ->
            Just "⦝"

        "angsph" ->
            Just "∢"

        "angst" ->
            Just "Å"

        "angzarr" ->
            Just "⍼"

        "Aogon" ->
            Just "Ą"

        "aogon" ->
            Just "ą"

        "Aopf" ->
            Just "\u{D835}\u{DD38}"

        "aopf" ->
            Just "\u{D835}\u{DD52}"

        "apacir" ->
            Just "⩯"

        "ap" ->
            Just "≈"

        "apE" ->
            Just "⩰"

        "ape" ->
            Just "≊"

        "apid" ->
            Just "≋"

        "apos" ->
            Just "'"

        "ApplyFunction" ->
            Just "\u{2061}"

        "approx" ->
            Just "≈"

        "approxeq" ->
            Just "≊"

        "Aring" ->
            Just "Å"

        "aring" ->
            Just "å"

        "Ascr" ->
            Just "\u{D835}\u{DC9C}"

        "ascr" ->
            Just "\u{D835}\u{DCB6}"

        "Assign" ->
            Just "≔"

        "ast" ->
            Just "*"

        "asymp" ->
            Just "≈"

        "asympeq" ->
            Just "≍"

        "Atilde" ->
            Just "Ã"

        "atilde" ->
            Just "ã"

        "Auml" ->
            Just "Ä"

        "auml" ->
            Just "ä"

        "awconint" ->
            Just "∳"

        "awint" ->
            Just "⨑"

        "backcong" ->
            Just "≌"

        "backepsilon" ->
            Just "϶"

        "backprime" ->
            Just "‵"

        "backsim" ->
            Just "∽"

        "backsimeq" ->
            Just "⋍"

        "Backslash" ->
            Just "∖"

        "Barv" ->
            Just "⫧"

        "barvee" ->
            Just "⊽"

        "barwed" ->
            Just "⌅"

        "Barwed" ->
            Just "⌆"

        "barwedge" ->
            Just "⌅"

        "bbrk" ->
            Just "⎵"

        "bbrktbrk" ->
            Just "⎶"

        "bcong" ->
            Just "≌"

        "Bcy" ->
            Just "Б"

        "bcy" ->
            Just "б"

        "bdquo" ->
            Just "„"

        "becaus" ->
            Just "∵"

        "because" ->
            Just "∵"

        "Because" ->
            Just "∵"

        "bemptyv" ->
            Just "⦰"

        "bepsi" ->
            Just "϶"

        "bernou" ->
            Just "ℬ"

        "Bernoullis" ->
            Just "ℬ"

        "Beta" ->
            Just "Β"

        "beta" ->
            Just "β"

        "beth" ->
            Just "ℶ"

        "between" ->
            Just "≬"

        "Bfr" ->
            Just "\u{D835}\u{DD05}"

        "bfr" ->
            Just "\u{D835}\u{DD1F}"

        "bigcap" ->
            Just "⋂"

        "bigcirc" ->
            Just "◯"

        "bigcup" ->
            Just "⋃"

        "bigodot" ->
            Just "⨀"

        "bigoplus" ->
            Just "⨁"

        "bigotimes" ->
            Just "⨂"

        "bigsqcup" ->
            Just "⨆"

        "bigstar" ->
            Just "★"

        "bigtriangledown" ->
            Just "▽"

        "bigtriangleup" ->
            Just "△"

        "biguplus" ->
            Just "⨄"

        "bigvee" ->
            Just "⋁"

        "bigwedge" ->
            Just "⋀"

        "bkarow" ->
            Just "⤍"

        "blacklozenge" ->
            Just "⧫"

        "blacksquare" ->
            Just "▪"

        "blacktriangle" ->
            Just "▴"

        "blacktriangledown" ->
            Just "▾"

        "blacktriangleleft" ->
            Just "◂"

        "blacktriangleright" ->
            Just "▸"

        "blank" ->
            Just "␣"

        "blk12" ->
            Just "▒"

        "blk14" ->
            Just "░"

        "blk34" ->
            Just "▓"

        "block" ->
            Just "█"

        "bne" ->
            Just "=⃥"

        "bnequiv" ->
            Just "≡⃥"

        "bNot" ->
            Just "⫭"

        "bnot" ->
            Just "⌐"

        "Bopf" ->
            Just "\u{D835}\u{DD39}"

        "bopf" ->
            Just "\u{D835}\u{DD53}"

        "bot" ->
            Just "⊥"

        "bottom" ->
            Just "⊥"

        "bowtie" ->
            Just "⋈"

        "boxbox" ->
            Just "⧉"

        "boxdl" ->
            Just "┐"

        "boxdL" ->
            Just "╕"

        "boxDl" ->
            Just "╖"

        "boxDL" ->
            Just "╗"

        "boxdr" ->
            Just "┌"

        "boxdR" ->
            Just "╒"

        "boxDr" ->
            Just "╓"

        "boxDR" ->
            Just "╔"

        "boxh" ->
            Just "─"

        "boxH" ->
            Just "═"

        "boxhd" ->
            Just "┬"

        "boxHd" ->
            Just "╤"

        "boxhD" ->
            Just "╥"

        "boxHD" ->
            Just "╦"

        "boxhu" ->
            Just "┴"

        "boxHu" ->
            Just "╧"

        "boxhU" ->
            Just "╨"

        "boxHU" ->
            Just "╩"

        "boxminus" ->
            Just "⊟"

        "boxplus" ->
            Just "⊞"

        "boxtimes" ->
            Just "⊠"

        "boxul" ->
            Just "┘"

        "boxuL" ->
            Just "╛"

        "boxUl" ->
            Just "╜"

        "boxUL" ->
            Just "╝"

        "boxur" ->
            Just "└"

        "boxuR" ->
            Just "╘"

        "boxUr" ->
            Just "╙"

        "boxUR" ->
            Just "╚"

        "boxv" ->
            Just "│"

        "boxV" ->
            Just "║"

        "boxvh" ->
            Just "┼"

        "boxvH" ->
            Just "╪"

        "boxVh" ->
            Just "╫"

        "boxVH" ->
            Just "╬"

        "boxvl" ->
            Just "┤"

        "boxvL" ->
            Just "╡"

        "boxVl" ->
            Just "╢"

        "boxVL" ->
            Just "╣"

        "boxvr" ->
            Just "├"

        "boxvR" ->
            Just "╞"

        "boxVr" ->
            Just "╟"

        "boxVR" ->
            Just "╠"

        "bprime" ->
            Just "‵"

        "breve" ->
            Just "˘"

        "Breve" ->
            Just "˘"

        "brvbar" ->
            Just "¦"

        "bscr" ->
            Just "\u{D835}\u{DCB7}"

        "Bscr" ->
            Just "ℬ"

        "bsemi" ->
            Just "⁏"

        "bsim" ->
            Just "∽"

        "bsime" ->
            Just "⋍"

        "bsolb" ->
            Just "⧅"

        "bsol" ->
            Just "\\"

        "bsolhsub" ->
            Just "⟈"

        "bull" ->
            Just "•"

        "bullet" ->
            Just "•"

        "bump" ->
            Just "≎"

        "bumpE" ->
            Just "⪮"

        "bumpe" ->
            Just "≏"

        "Bumpeq" ->
            Just "≎"

        "bumpeq" ->
            Just "≏"

        "Cacute" ->
            Just "Ć"

        "cacute" ->
            Just "ć"

        "capand" ->
            Just "⩄"

        "capbrcup" ->
            Just "⩉"

        "capcap" ->
            Just "⩋"

        "cap" ->
            Just "∩"

        "Cap" ->
            Just "⋒"

        "capcup" ->
            Just "⩇"

        "capdot" ->
            Just "⩀"

        "CapitalDifferentialD" ->
            Just "ⅅ"

        "caps" ->
            Just "∩︀"

        "caret" ->
            Just "⁁"

        "caron" ->
            Just "ˇ"

        "Cayleys" ->
            Just "ℭ"

        "ccaps" ->
            Just "⩍"

        "Ccaron" ->
            Just "Č"

        "ccaron" ->
            Just "č"

        "Ccedil" ->
            Just "Ç"

        "ccedil" ->
            Just "ç"

        "Ccirc" ->
            Just "Ĉ"

        "ccirc" ->
            Just "ĉ"

        "Cconint" ->
            Just "∰"

        "ccups" ->
            Just "⩌"

        "ccupssm" ->
            Just "⩐"

        "Cdot" ->
            Just "Ċ"

        "cdot" ->
            Just "ċ"

        "cedil" ->
            Just "¸"

        "Cedilla" ->
            Just "¸"

        "cemptyv" ->
            Just "⦲"

        "cent" ->
            Just "¢"

        "centerdot" ->
            Just "·"

        "CenterDot" ->
            Just "·"

        "cfr" ->
            Just "\u{D835}\u{DD20}"

        "Cfr" ->
            Just "ℭ"

        "CHcy" ->
            Just "Ч"

        "chcy" ->
            Just "ч"

        "check" ->
            Just "✓"

        "checkmark" ->
            Just "✓"

        "Chi" ->
            Just "Χ"

        "chi" ->
            Just "χ"

        "circ" ->
            Just "ˆ"

        "circeq" ->
            Just "≗"

        "circlearrowleft" ->
            Just "↺"

        "circlearrowright" ->
            Just "↻"

        "circledast" ->
            Just "⊛"

        "circledcirc" ->
            Just "⊚"

        "circleddash" ->
            Just "⊝"

        "CircleDot" ->
            Just "⊙"

        "circledR" ->
            Just "®"

        "circledS" ->
            Just "Ⓢ"

        "CircleMinus" ->
            Just "⊖"

        "CirclePlus" ->
            Just "⊕"

        "CircleTimes" ->
            Just "⊗"

        "cir" ->
            Just "○"

        "cirE" ->
            Just "⧃"

        "cire" ->
            Just "≗"

        "cirfnint" ->
            Just "⨐"

        "cirmid" ->
            Just "⫯"

        "cirscir" ->
            Just "⧂"

        "ClockwiseContourIntegral" ->
            Just "∲"

        "CloseCurlyDoubleQuote" ->
            Just "”"

        "CloseCurlyQuote" ->
            Just "’"

        "clubs" ->
            Just "♣"

        "clubsuit" ->
            Just "♣"

        "colon" ->
            Just ":"

        "Colon" ->
            Just "∷"

        "Colone" ->
            Just "⩴"

        "colone" ->
            Just "≔"

        "coloneq" ->
            Just "≔"

        "comma" ->
            Just ","

        "commat" ->
            Just "@"

        "comp" ->
            Just "∁"

        "compfn" ->
            Just "∘"

        "complement" ->
            Just "∁"

        "complexes" ->
            Just "ℂ"

        "cong" ->
            Just "≅"

        "congdot" ->
            Just "⩭"

        "Congruent" ->
            Just "≡"

        "conint" ->
            Just "∮"

        "Conint" ->
            Just "∯"

        "ContourIntegral" ->
            Just "∮"

        "copf" ->
            Just "\u{D835}\u{DD54}"

        "Copf" ->
            Just "ℂ"

        "coprod" ->
            Just "∐"

        "Coproduct" ->
            Just "∐"

        "copy" ->
            Just "©"

        "COPY" ->
            Just "©"

        "copysr" ->
            Just "℗"

        "CounterClockwiseContourIntegral" ->
            Just "∳"

        "crarr" ->
            Just "↵"

        "cross" ->
            Just "✗"

        "Cross" ->
            Just "⨯"

        "Cscr" ->
            Just "\u{D835}\u{DC9E}"

        "cscr" ->
            Just "\u{D835}\u{DCB8}"

        "csub" ->
            Just "⫏"

        "csube" ->
            Just "⫑"

        "csup" ->
            Just "⫐"

        "csupe" ->
            Just "⫒"

        "ctdot" ->
            Just "⋯"

        "cudarrl" ->
            Just "⤸"

        "cudarrr" ->
            Just "⤵"

        "cuepr" ->
            Just "⋞"

        "cuesc" ->
            Just "⋟"

        "cularr" ->
            Just "↶"

        "cularrp" ->
            Just "⤽"

        "cupbrcap" ->
            Just "⩈"

        "cupcap" ->
            Just "⩆"

        "CupCap" ->
            Just "≍"

        "cup" ->
            Just "∪"

        "Cup" ->
            Just "⋓"

        "cupcup" ->
            Just "⩊"

        "cupdot" ->
            Just "⊍"

        "cupor" ->
            Just "⩅"

        "cups" ->
            Just "∪︀"

        "curarr" ->
            Just "↷"

        "curarrm" ->
            Just "⤼"

        "curlyeqprec" ->
            Just "⋞"

        "curlyeqsucc" ->
            Just "⋟"

        "curlyvee" ->
            Just "⋎"

        "curlywedge" ->
            Just "⋏"

        "curren" ->
            Just "¤"

        "curvearrowleft" ->
            Just "↶"

        "curvearrowright" ->
            Just "↷"

        "cuvee" ->
            Just "⋎"

        "cuwed" ->
            Just "⋏"

        "cwconint" ->
            Just "∲"

        "cwint" ->
            Just "∱"

        "cylcty" ->
            Just "⌭"

        "dagger" ->
            Just "†"

        "Dagger" ->
            Just "‡"

        "daleth" ->
            Just "ℸ"

        "darr" ->
            Just "↓"

        "Darr" ->
            Just "↡"

        "dArr" ->
            Just "⇓"

        "dash" ->
            Just "‐"

        "Dashv" ->
            Just "⫤"

        "dashv" ->
            Just "⊣"

        "dbkarow" ->
            Just "⤏"

        "dblac" ->
            Just "˝"

        "Dcaron" ->
            Just "Ď"

        "dcaron" ->
            Just "ď"

        "Dcy" ->
            Just "Д"

        "dcy" ->
            Just "д"

        "ddagger" ->
            Just "‡"

        "ddarr" ->
            Just "⇊"

        "DD" ->
            Just "ⅅ"

        "dd" ->
            Just "ⅆ"

        "DDotrahd" ->
            Just "⤑"

        "ddotseq" ->
            Just "⩷"

        "deg" ->
            Just "°"

        "Del" ->
            Just "∇"

        "Delta" ->
            Just "Δ"

        "delta" ->
            Just "δ"

        "demptyv" ->
            Just "⦱"

        "dfisht" ->
            Just "⥿"

        "Dfr" ->
            Just "\u{D835}\u{DD07}"

        "dfr" ->
            Just "\u{D835}\u{DD21}"

        "dHar" ->
            Just "⥥"

        "dharl" ->
            Just "⇃"

        "dharr" ->
            Just "⇂"

        "DiacriticalAcute" ->
            Just "´"

        "DiacriticalDot" ->
            Just "˙"

        "DiacriticalDoubleAcute" ->
            Just "˝"

        "DiacriticalGrave" ->
            Just "`"

        "DiacriticalTilde" ->
            Just "˜"

        "diam" ->
            Just "⋄"

        "diamond" ->
            Just "⋄"

        "Diamond" ->
            Just "⋄"

        "diamondsuit" ->
            Just "♦"

        "diams" ->
            Just "♦"

        "die" ->
            Just "¨"

        "DifferentialD" ->
            Just "ⅆ"

        "digamma" ->
            Just "ϝ"

        "disin" ->
            Just "⋲"

        "div" ->
            Just "÷"

        "divide" ->
            Just "÷"

        "divideontimes" ->
            Just "⋇"

        "divonx" ->
            Just "⋇"

        "DJcy" ->
            Just "Ђ"

        "djcy" ->
            Just "ђ"

        "dlcorn" ->
            Just "⌞"

        "dlcrop" ->
            Just "⌍"

        "dollar" ->
            Just "$"

        "Dopf" ->
            Just "\u{D835}\u{DD3B}"

        "dopf" ->
            Just "\u{D835}\u{DD55}"

        "Dot" ->
            Just "¨"

        "dot" ->
            Just "˙"

        "DotDot" ->
            Just "⃜"

        "doteq" ->
            Just "≐"

        "doteqdot" ->
            Just "≑"

        "DotEqual" ->
            Just "≐"

        "dotminus" ->
            Just "∸"

        "dotplus" ->
            Just "∔"

        "dotsquare" ->
            Just "⊡"

        "doublebarwedge" ->
            Just "⌆"

        "DoubleContourIntegral" ->
            Just "∯"

        "DoubleDot" ->
            Just "¨"

        "DoubleDownArrow" ->
            Just "⇓"

        "DoubleLeftArrow" ->
            Just "⇐"

        "DoubleLeftRightArrow" ->
            Just "⇔"

        "DoubleLeftTee" ->
            Just "⫤"

        "DoubleLongLeftArrow" ->
            Just "⟸"

        "DoubleLongLeftRightArrow" ->
            Just "⟺"

        "DoubleLongRightArrow" ->
            Just "⟹"

        "DoubleRightArrow" ->
            Just "⇒"

        "DoubleRightTee" ->
            Just "⊨"

        "DoubleUpArrow" ->
            Just "⇑"

        "DoubleUpDownArrow" ->
            Just "⇕"

        "DoubleVerticalBar" ->
            Just "∥"

        "DownArrowBar" ->
            Just "⤓"

        "downarrow" ->
            Just "↓"

        "DownArrow" ->
            Just "↓"

        "Downarrow" ->
            Just "⇓"

        "DownArrowUpArrow" ->
            Just "⇵"

        "DownBreve" ->
            Just "̑"

        "downdownarrows" ->
            Just "⇊"

        "downharpoonleft" ->
            Just "⇃"

        "downharpoonright" ->
            Just "⇂"

        "DownLeftRightVector" ->
            Just "⥐"

        "DownLeftTeeVector" ->
            Just "⥞"

        "DownLeftVectorBar" ->
            Just "⥖"

        "DownLeftVector" ->
            Just "↽"

        "DownRightTeeVector" ->
            Just "⥟"

        "DownRightVectorBar" ->
            Just "⥗"

        "DownRightVector" ->
            Just "⇁"

        "DownTeeArrow" ->
            Just "↧"

        "DownTee" ->
            Just "⊤"

        "drbkarow" ->
            Just "⤐"

        "drcorn" ->
            Just "⌟"

        "drcrop" ->
            Just "⌌"

        "Dscr" ->
            Just "\u{D835}\u{DC9F}"

        "dscr" ->
            Just "\u{D835}\u{DCB9}"

        "DScy" ->
            Just "Ѕ"

        "dscy" ->
            Just "ѕ"

        "dsol" ->
            Just "⧶"

        "Dstrok" ->
            Just "Đ"

        "dstrok" ->
            Just "đ"

        "dtdot" ->
            Just "⋱"

        "dtri" ->
            Just "▿"

        "dtrif" ->
            Just "▾"

        "duarr" ->
            Just "⇵"

        "duhar" ->
            Just "⥯"

        "dwangle" ->
            Just "⦦"

        "DZcy" ->
            Just "Џ"

        "dzcy" ->
            Just "џ"

        "dzigrarr" ->
            Just "⟿"

        "Eacute" ->
            Just "É"

        "eacute" ->
            Just "é"

        "easter" ->
            Just "⩮"

        "Ecaron" ->
            Just "Ě"

        "ecaron" ->
            Just "ě"

        "Ecirc" ->
            Just "Ê"

        "ecirc" ->
            Just "ê"

        "ecir" ->
            Just "≖"

        "ecolon" ->
            Just "≕"

        "Ecy" ->
            Just "Э"

        "ecy" ->
            Just "э"

        "eDDot" ->
            Just "⩷"

        "Edot" ->
            Just "Ė"

        "edot" ->
            Just "ė"

        "eDot" ->
            Just "≑"

        "ee" ->
            Just "ⅇ"

        "efDot" ->
            Just "≒"

        "Efr" ->
            Just "\u{D835}\u{DD08}"

        "efr" ->
            Just "\u{D835}\u{DD22}"

        "eg" ->
            Just "⪚"

        "Egrave" ->
            Just "È"

        "egrave" ->
            Just "è"

        "egs" ->
            Just "⪖"

        "egsdot" ->
            Just "⪘"

        "el" ->
            Just "⪙"

        "Element" ->
            Just "∈"

        "elinters" ->
            Just "⏧"

        "ell" ->
            Just "ℓ"

        "els" ->
            Just "⪕"

        "elsdot" ->
            Just "⪗"

        "Emacr" ->
            Just "Ē"

        "emacr" ->
            Just "ē"

        "empty" ->
            Just "∅"

        "emptyset" ->
            Just "∅"

        "EmptySmallSquare" ->
            Just "◻"

        "emptyv" ->
            Just "∅"

        "EmptyVerySmallSquare" ->
            Just "▫"

        "emsp13" ->
            Just "\u{2004}"

        "emsp14" ->
            Just "\u{2005}"

        "emsp" ->
            Just "\u{2003}"

        "ENG" ->
            Just "Ŋ"

        "eng" ->
            Just "ŋ"

        "ensp" ->
            Just "\u{2002}"

        "Eogon" ->
            Just "Ę"

        "eogon" ->
            Just "ę"

        "Eopf" ->
            Just "\u{D835}\u{DD3C}"

        "eopf" ->
            Just "\u{D835}\u{DD56}"

        "epar" ->
            Just "⋕"

        "eparsl" ->
            Just "⧣"

        "eplus" ->
            Just "⩱"

        "epsi" ->
            Just "ε"

        "Epsilon" ->
            Just "Ε"

        "epsilon" ->
            Just "ε"

        "epsiv" ->
            Just "ϵ"

        "eqcirc" ->
            Just "≖"

        "eqcolon" ->
            Just "≕"

        "eqsim" ->
            Just "≂"

        "eqslantgtr" ->
            Just "⪖"

        "eqslantless" ->
            Just "⪕"

        "Equal" ->
            Just "⩵"

        "equals" ->
            Just "="

        "EqualTilde" ->
            Just "≂"

        "equest" ->
            Just "≟"

        "Equilibrium" ->
            Just "⇌"

        "equiv" ->
            Just "≡"

        "equivDD" ->
            Just "⩸"

        "eqvparsl" ->
            Just "⧥"

        "erarr" ->
            Just "⥱"

        "erDot" ->
            Just "≓"

        "escr" ->
            Just "ℯ"

        "Escr" ->
            Just "ℰ"

        "esdot" ->
            Just "≐"

        "Esim" ->
            Just "⩳"

        "esim" ->
            Just "≂"

        "Eta" ->
            Just "Η"

        "eta" ->
            Just "η"

        "ETH" ->
            Just "Ð"

        "eth" ->
            Just "ð"

        "Euml" ->
            Just "Ë"

        "euml" ->
            Just "ë"

        "euro" ->
            Just "€"

        "excl" ->
            Just "!"

        "exist" ->
            Just "∃"

        "Exists" ->
            Just "∃"

        "expectation" ->
            Just "ℰ"

        "exponentiale" ->
            Just "ⅇ"

        "ExponentialE" ->
            Just "ⅇ"

        "fallingdotseq" ->
            Just "≒"

        "Fcy" ->
            Just "Ф"

        "fcy" ->
            Just "ф"

        "female" ->
            Just "♀"

        "ffilig" ->
            Just "ﬃ"

        "fflig" ->
            Just "ﬀ"

        "ffllig" ->
            Just "ﬄ"

        "Ffr" ->
            Just "\u{D835}\u{DD09}"

        "ffr" ->
            Just "\u{D835}\u{DD23}"

        "filig" ->
            Just "ﬁ"

        "FilledSmallSquare" ->
            Just "◼"

        "FilledVerySmallSquare" ->
            Just "▪"

        "fjlig" ->
            Just "fj"

        "flat" ->
            Just "♭"

        "fllig" ->
            Just "ﬂ"

        "fltns" ->
            Just "▱"

        "fnof" ->
            Just "ƒ"

        "Fopf" ->
            Just "\u{D835}\u{DD3D}"

        "fopf" ->
            Just "\u{D835}\u{DD57}"

        "forall" ->
            Just "∀"

        "ForAll" ->
            Just "∀"

        "fork" ->
            Just "⋔"

        "forkv" ->
            Just "⫙"

        "Fouriertrf" ->
            Just "ℱ"

        "fpartint" ->
            Just "⨍"

        "frac12" ->
            Just "½"

        "frac13" ->
            Just "⅓"

        "frac14" ->
            Just "¼"

        "frac15" ->
            Just "⅕"

        "frac16" ->
            Just "⅙"

        "frac18" ->
            Just "⅛"

        "frac23" ->
            Just "⅔"

        "frac25" ->
            Just "⅖"

        "frac34" ->
            Just "¾"

        "frac35" ->
            Just "⅗"

        "frac38" ->
            Just "⅜"

        "frac45" ->
            Just "⅘"

        "frac56" ->
            Just "⅚"

        "frac58" ->
            Just "⅝"

        "frac78" ->
            Just "⅞"

        "frasl" ->
            Just "⁄"

        "frown" ->
            Just "⌢"

        "fscr" ->
            Just "\u{D835}\u{DCBB}"

        "Fscr" ->
            Just "ℱ"

        "gacute" ->
            Just "ǵ"

        "Gamma" ->
            Just "Γ"

        "gamma" ->
            Just "γ"

        "Gammad" ->
            Just "Ϝ"

        "gammad" ->
            Just "ϝ"

        "gap" ->
            Just "⪆"

        "Gbreve" ->
            Just "Ğ"

        "gbreve" ->
            Just "ğ"

        "Gcedil" ->
            Just "Ģ"

        "Gcirc" ->
            Just "Ĝ"

        "gcirc" ->
            Just "ĝ"

        "Gcy" ->
            Just "Г"

        "gcy" ->
            Just "г"

        "Gdot" ->
            Just "Ġ"

        "gdot" ->
            Just "ġ"

        "ge" ->
            Just "≥"

        "gE" ->
            Just "≧"

        "gEl" ->
            Just "⪌"

        "gel" ->
            Just "⋛"

        "geq" ->
            Just "≥"

        "geqq" ->
            Just "≧"

        "geqslant" ->
            Just "⩾"

        "gescc" ->
            Just "⪩"

        "ges" ->
            Just "⩾"

        "gesdot" ->
            Just "⪀"

        "gesdoto" ->
            Just "⪂"

        "gesdotol" ->
            Just "⪄"

        "gesl" ->
            Just "⋛︀"

        "gesles" ->
            Just "⪔"

        "Gfr" ->
            Just "\u{D835}\u{DD0A}"

        "gfr" ->
            Just "\u{D835}\u{DD24}"

        "gg" ->
            Just "≫"

        "Gg" ->
            Just "⋙"

        "ggg" ->
            Just "⋙"

        "gimel" ->
            Just "ℷ"

        "GJcy" ->
            Just "Ѓ"

        "gjcy" ->
            Just "ѓ"

        "gla" ->
            Just "⪥"

        "gl" ->
            Just "≷"

        "glE" ->
            Just "⪒"

        "glj" ->
            Just "⪤"

        "gnap" ->
            Just "⪊"

        "gnapprox" ->
            Just "⪊"

        "gne" ->
            Just "⪈"

        "gnE" ->
            Just "≩"

        "gneq" ->
            Just "⪈"

        "gneqq" ->
            Just "≩"

        "gnsim" ->
            Just "⋧"

        "Gopf" ->
            Just "\u{D835}\u{DD3E}"

        "gopf" ->
            Just "\u{D835}\u{DD58}"

        "grave" ->
            Just "`"

        "GreaterEqual" ->
            Just "≥"

        "GreaterEqualLess" ->
            Just "⋛"

        "GreaterFullEqual" ->
            Just "≧"

        "GreaterGreater" ->
            Just "⪢"

        "GreaterLess" ->
            Just "≷"

        "GreaterSlantEqual" ->
            Just "⩾"

        "GreaterTilde" ->
            Just "≳"

        "Gscr" ->
            Just "\u{D835}\u{DCA2}"

        "gscr" ->
            Just "ℊ"

        "gsim" ->
            Just "≳"

        "gsime" ->
            Just "⪎"

        "gsiml" ->
            Just "⪐"

        "gtcc" ->
            Just "⪧"

        "gtcir" ->
            Just "⩺"

        "gt" ->
            Just ">"

        "GT" ->
            Just ">"

        "Gt" ->
            Just "≫"

        "gtdot" ->
            Just "⋗"

        "gtlPar" ->
            Just "⦕"

        "gtquest" ->
            Just "⩼"

        "gtrapprox" ->
            Just "⪆"

        "gtrarr" ->
            Just "⥸"

        "gtrdot" ->
            Just "⋗"

        "gtreqless" ->
            Just "⋛"

        "gtreqqless" ->
            Just "⪌"

        "gtrless" ->
            Just "≷"

        "gtrsim" ->
            Just "≳"

        "gvertneqq" ->
            Just "≩︀"

        "gvnE" ->
            Just "≩︀"

        "Hacek" ->
            Just "ˇ"

        "hairsp" ->
            Just "\u{200A}"

        "half" ->
            Just "½"

        "hamilt" ->
            Just "ℋ"

        "HARDcy" ->
            Just "Ъ"

        "hardcy" ->
            Just "ъ"

        "harrcir" ->
            Just "⥈"

        "harr" ->
            Just "↔"

        "hArr" ->
            Just "⇔"

        "harrw" ->
            Just "↭"

        "Hat" ->
            Just "^"

        "hbar" ->
            Just "ℏ"

        "Hcirc" ->
            Just "Ĥ"

        "hcirc" ->
            Just "ĥ"

        "hearts" ->
            Just "♥"

        "heartsuit" ->
            Just "♥"

        "hellip" ->
            Just "…"

        "hercon" ->
            Just "⊹"

        "hfr" ->
            Just "\u{D835}\u{DD25}"

        "Hfr" ->
            Just "ℌ"

        "HilbertSpace" ->
            Just "ℋ"

        "hksearow" ->
            Just "⤥"

        "hkswarow" ->
            Just "⤦"

        "hoarr" ->
            Just "⇿"

        "homtht" ->
            Just "∻"

        "hookleftarrow" ->
            Just "↩"

        "hookrightarrow" ->
            Just "↪"

        "hopf" ->
            Just "\u{D835}\u{DD59}"

        "Hopf" ->
            Just "ℍ"

        "horbar" ->
            Just "―"

        "HorizontalLine" ->
            Just "─"

        "hscr" ->
            Just "\u{D835}\u{DCBD}"

        "Hscr" ->
            Just "ℋ"

        "hslash" ->
            Just "ℏ"

        "Hstrok" ->
            Just "Ħ"

        "hstrok" ->
            Just "ħ"

        "HumpDownHump" ->
            Just "≎"

        "HumpEqual" ->
            Just "≏"

        "hybull" ->
            Just "⁃"

        "hyphen" ->
            Just "‐"

        "Iacute" ->
            Just "Í"

        "iacute" ->
            Just "í"

        "ic" ->
            Just "\u{2063}"

        "Icirc" ->
            Just "Î"

        "icirc" ->
            Just "î"

        "Icy" ->
            Just "И"

        "icy" ->
            Just "и"

        "Idot" ->
            Just "İ"

        "IEcy" ->
            Just "Е"

        "iecy" ->
            Just "е"

        "iexcl" ->
            Just "¡"

        "iff" ->
            Just "⇔"

        "ifr" ->
            Just "\u{D835}\u{DD26}"

        "Ifr" ->
            Just "ℑ"

        "Igrave" ->
            Just "Ì"

        "igrave" ->
            Just "ì"

        "ii" ->
            Just "ⅈ"

        "iiiint" ->
            Just "⨌"

        "iiint" ->
            Just "∭"

        "iinfin" ->
            Just "⧜"

        "iiota" ->
            Just "℩"

        "IJlig" ->
            Just "Ĳ"

        "ijlig" ->
            Just "ĳ"

        "Imacr" ->
            Just "Ī"

        "imacr" ->
            Just "ī"

        "image" ->
            Just "ℑ"

        "ImaginaryI" ->
            Just "ⅈ"

        "imagline" ->
            Just "ℐ"

        "imagpart" ->
            Just "ℑ"

        "imath" ->
            Just "ı"

        "Im" ->
            Just "ℑ"

        "imof" ->
            Just "⊷"

        "imped" ->
            Just "Ƶ"

        "Implies" ->
            Just "⇒"

        "incare" ->
            Just "℅"

        "in" ->
            Just "∈"

        "infin" ->
            Just "∞"

        "infintie" ->
            Just "⧝"

        "inodot" ->
            Just "ı"

        "intcal" ->
            Just "⊺"

        "int" ->
            Just "∫"

        "Int" ->
            Just "∬"

        "integers" ->
            Just "ℤ"

        "Integral" ->
            Just "∫"

        "intercal" ->
            Just "⊺"

        "Intersection" ->
            Just "⋂"

        "intlarhk" ->
            Just "⨗"

        "intprod" ->
            Just "⨼"

        "InvisibleComma" ->
            Just "\u{2063}"

        "InvisibleTimes" ->
            Just "\u{2062}"

        "IOcy" ->
            Just "Ё"

        "iocy" ->
            Just "ё"

        "Iogon" ->
            Just "Į"

        "iogon" ->
            Just "į"

        "Iopf" ->
            Just "\u{D835}\u{DD40}"

        "iopf" ->
            Just "\u{D835}\u{DD5A}"

        "Iota" ->
            Just "Ι"

        "iota" ->
            Just "ι"

        "iprod" ->
            Just "⨼"

        "iquest" ->
            Just "¿"

        "iscr" ->
            Just "\u{D835}\u{DCBE}"

        "Iscr" ->
            Just "ℐ"

        "isin" ->
            Just "∈"

        "isindot" ->
            Just "⋵"

        "isinE" ->
            Just "⋹"

        "isins" ->
            Just "⋴"

        "isinsv" ->
            Just "⋳"

        "isinv" ->
            Just "∈"

        "it" ->
            Just "\u{2062}"

        "Itilde" ->
            Just "Ĩ"

        "itilde" ->
            Just "ĩ"

        "Iukcy" ->
            Just "І"

        "iukcy" ->
            Just "і"

        "Iuml" ->
            Just "Ï"

        "iuml" ->
            Just "ï"

        "Jcirc" ->
            Just "Ĵ"

        "jcirc" ->
            Just "ĵ"

        "Jcy" ->
            Just "Й"

        "jcy" ->
            Just "й"

        "Jfr" ->
            Just "\u{D835}\u{DD0D}"

        "jfr" ->
            Just "\u{D835}\u{DD27}"

        "jmath" ->
            Just "ȷ"

        "Jopf" ->
            Just "\u{D835}\u{DD41}"

        "jopf" ->
            Just "\u{D835}\u{DD5B}"

        "Jscr" ->
            Just "\u{D835}\u{DCA5}"

        "jscr" ->
            Just "\u{D835}\u{DCBF}"

        "Jsercy" ->
            Just "Ј"

        "jsercy" ->
            Just "ј"

        "Jukcy" ->
            Just "Є"

        "jukcy" ->
            Just "є"

        "Kappa" ->
            Just "Κ"

        "kappa" ->
            Just "κ"

        "kappav" ->
            Just "ϰ"

        "Kcedil" ->
            Just "Ķ"

        "kcedil" ->
            Just "ķ"

        "Kcy" ->
            Just "К"

        "kcy" ->
            Just "к"

        "Kfr" ->
            Just "\u{D835}\u{DD0E}"

        "kfr" ->
            Just "\u{D835}\u{DD28}"

        "kgreen" ->
            Just "ĸ"

        "KHcy" ->
            Just "Х"

        "khcy" ->
            Just "х"

        "KJcy" ->
            Just "Ќ"

        "kjcy" ->
            Just "ќ"

        "Kopf" ->
            Just "\u{D835}\u{DD42}"

        "kopf" ->
            Just "\u{D835}\u{DD5C}"

        "Kscr" ->
            Just "\u{D835}\u{DCA6}"

        "kscr" ->
            Just "\u{D835}\u{DCC0}"

        "lAarr" ->
            Just "⇚"

        "Lacute" ->
            Just "Ĺ"

        "lacute" ->
            Just "ĺ"

        "laemptyv" ->
            Just "⦴"

        "lagran" ->
            Just "ℒ"

        "Lambda" ->
            Just "Λ"

        "lambda" ->
            Just "λ"

        "lang" ->
            Just "⟨"

        "Lang" ->
            Just "⟪"

        "langd" ->
            Just "⦑"

        "langle" ->
            Just "⟨"

        "lap" ->
            Just "⪅"

        "Laplacetrf" ->
            Just "ℒ"

        "laquo" ->
            Just "«"

        "larrb" ->
            Just "⇤"

        "larrbfs" ->
            Just "⤟"

        "larr" ->
            Just "←"

        "Larr" ->
            Just "↞"

        "lArr" ->
            Just "⇐"

        "larrfs" ->
            Just "⤝"

        "larrhk" ->
            Just "↩"

        "larrlp" ->
            Just "↫"

        "larrpl" ->
            Just "⤹"

        "larrsim" ->
            Just "⥳"

        "larrtl" ->
            Just "↢"

        "latail" ->
            Just "⤙"

        "lAtail" ->
            Just "⤛"

        "lat" ->
            Just "⪫"

        "late" ->
            Just "⪭"

        "lates" ->
            Just "⪭︀"

        "lbarr" ->
            Just "⤌"

        "lBarr" ->
            Just "⤎"

        "lbbrk" ->
            Just "❲"

        "lbrace" ->
            Just "{"

        "lbrack" ->
            Just "["

        "lbrke" ->
            Just "⦋"

        "lbrksld" ->
            Just "⦏"

        "lbrkslu" ->
            Just "⦍"

        "Lcaron" ->
            Just "Ľ"

        "lcaron" ->
            Just "ľ"

        "Lcedil" ->
            Just "Ļ"

        "lcedil" ->
            Just "ļ"

        "lceil" ->
            Just "⌈"

        "lcub" ->
            Just "{"

        "Lcy" ->
            Just "Л"

        "lcy" ->
            Just "л"

        "ldca" ->
            Just "⤶"

        "ldquo" ->
            Just "“"

        "ldquor" ->
            Just "„"

        "ldrdhar" ->
            Just "⥧"

        "ldrushar" ->
            Just "⥋"

        "ldsh" ->
            Just "↲"

        "le" ->
            Just "≤"

        "lE" ->
            Just "≦"

        "LeftAngleBracket" ->
            Just "⟨"

        "LeftArrowBar" ->
            Just "⇤"

        "leftarrow" ->
            Just "←"

        "LeftArrow" ->
            Just "←"

        "Leftarrow" ->
            Just "⇐"

        "LeftArrowRightArrow" ->
            Just "⇆"

        "leftarrowtail" ->
            Just "↢"

        "LeftCeiling" ->
            Just "⌈"

        "LeftDoubleBracket" ->
            Just "⟦"

        "LeftDownTeeVector" ->
            Just "⥡"

        "LeftDownVectorBar" ->
            Just "⥙"

        "LeftDownVector" ->
            Just "⇃"

        "LeftFloor" ->
            Just "⌊"

        "leftharpoondown" ->
            Just "↽"

        "leftharpoonup" ->
            Just "↼"

        "leftleftarrows" ->
            Just "⇇"

        "leftrightarrow" ->
            Just "↔"

        "LeftRightArrow" ->
            Just "↔"

        "Leftrightarrow" ->
            Just "⇔"

        "leftrightarrows" ->
            Just "⇆"

        "leftrightharpoons" ->
            Just "⇋"

        "leftrightsquigarrow" ->
            Just "↭"

        "LeftRightVector" ->
            Just "⥎"

        "LeftTeeArrow" ->
            Just "↤"

        "LeftTee" ->
            Just "⊣"

        "LeftTeeVector" ->
            Just "⥚"

        "leftthreetimes" ->
            Just "⋋"

        "LeftTriangleBar" ->
            Just "⧏"

        "LeftTriangle" ->
            Just "⊲"

        "LeftTriangleEqual" ->
            Just "⊴"

        "LeftUpDownVector" ->
            Just "⥑"

        "LeftUpTeeVector" ->
            Just "⥠"

        "LeftUpVectorBar" ->
            Just "⥘"

        "LeftUpVector" ->
            Just "↿"

        "LeftVectorBar" ->
            Just "⥒"

        "LeftVector" ->
            Just "↼"

        "lEg" ->
            Just "⪋"

        "leg" ->
            Just "⋚"

        "leq" ->
            Just "≤"

        "leqq" ->
            Just "≦"

        "leqslant" ->
            Just "⩽"

        "lescc" ->
            Just "⪨"

        "les" ->
            Just "⩽"

        "lesdot" ->
            Just "⩿"

        "lesdoto" ->
            Just "⪁"

        "lesdotor" ->
            Just "⪃"

        "lesg" ->
            Just "⋚︀"

        "lesges" ->
            Just "⪓"

        "lessapprox" ->
            Just "⪅"

        "lessdot" ->
            Just "⋖"

        "lesseqgtr" ->
            Just "⋚"

        "lesseqqgtr" ->
            Just "⪋"

        "LessEqualGreater" ->
            Just "⋚"

        "LessFullEqual" ->
            Just "≦"

        "LessGreater" ->
            Just "≶"

        "lessgtr" ->
            Just "≶"

        "LessLess" ->
            Just "⪡"

        "lesssim" ->
            Just "≲"

        "LessSlantEqual" ->
            Just "⩽"

        "LessTilde" ->
            Just "≲"

        "lfisht" ->
            Just "⥼"

        "lfloor" ->
            Just "⌊"

        "Lfr" ->
            Just "\u{D835}\u{DD0F}"

        "lfr" ->
            Just "\u{D835}\u{DD29}"

        "lg" ->
            Just "≶"

        "lgE" ->
            Just "⪑"

        "lHar" ->
            Just "⥢"

        "lhard" ->
            Just "↽"

        "lharu" ->
            Just "↼"

        "lharul" ->
            Just "⥪"

        "lhblk" ->
            Just "▄"

        "LJcy" ->
            Just "Љ"

        "ljcy" ->
            Just "љ"

        "llarr" ->
            Just "⇇"

        "ll" ->
            Just "≪"

        "Ll" ->
            Just "⋘"

        "llcorner" ->
            Just "⌞"

        "Lleftarrow" ->
            Just "⇚"

        "llhard" ->
            Just "⥫"

        "lltri" ->
            Just "◺"

        "Lmidot" ->
            Just "Ŀ"

        "lmidot" ->
            Just "ŀ"

        "lmoustache" ->
            Just "⎰"

        "lmoust" ->
            Just "⎰"

        "lnap" ->
            Just "⪉"

        "lnapprox" ->
            Just "⪉"

        "lne" ->
            Just "⪇"

        "lnE" ->
            Just "≨"

        "lneq" ->
            Just "⪇"

        "lneqq" ->
            Just "≨"

        "lnsim" ->
            Just "⋦"

        "loang" ->
            Just "⟬"

        "loarr" ->
            Just "⇽"

        "lobrk" ->
            Just "⟦"

        "longleftarrow" ->
            Just "⟵"

        "LongLeftArrow" ->
            Just "⟵"

        "Longleftarrow" ->
            Just "⟸"

        "longleftrightarrow" ->
            Just "⟷"

        "LongLeftRightArrow" ->
            Just "⟷"

        "Longleftrightarrow" ->
            Just "⟺"

        "longmapsto" ->
            Just "⟼"

        "longrightarrow" ->
            Just "⟶"

        "LongRightArrow" ->
            Just "⟶"

        "Longrightarrow" ->
            Just "⟹"

        "looparrowleft" ->
            Just "↫"

        "looparrowright" ->
            Just "↬"

        "lopar" ->
            Just "⦅"

        "Lopf" ->
            Just "\u{D835}\u{DD43}"

        "lopf" ->
            Just "\u{D835}\u{DD5D}"

        "loplus" ->
            Just "⨭"

        "lotimes" ->
            Just "⨴"

        "lowast" ->
            Just "∗"

        "lowbar" ->
            Just "_"

        "LowerLeftArrow" ->
            Just "↙"

        "LowerRightArrow" ->
            Just "↘"

        "loz" ->
            Just "◊"

        "lozenge" ->
            Just "◊"

        "lozf" ->
            Just "⧫"

        "lpar" ->
            Just "("

        "lparlt" ->
            Just "⦓"

        "lrarr" ->
            Just "⇆"

        "lrcorner" ->
            Just "⌟"

        "lrhar" ->
            Just "⇋"

        "lrhard" ->
            Just "⥭"

        "lrm" ->
            Just "\u{200E}"

        "lrtri" ->
            Just "⊿"

        "lsaquo" ->
            Just "‹"

        "lscr" ->
            Just "\u{D835}\u{DCC1}"

        "Lscr" ->
            Just "ℒ"

        "lsh" ->
            Just "↰"

        "Lsh" ->
            Just "↰"

        "lsim" ->
            Just "≲"

        "lsime" ->
            Just "⪍"

        "lsimg" ->
            Just "⪏"

        "lsqb" ->
            Just "["

        "lsquo" ->
            Just "‘"

        "lsquor" ->
            Just "‚"

        "Lstrok" ->
            Just "Ł"

        "lstrok" ->
            Just "ł"

        "ltcc" ->
            Just "⪦"

        "ltcir" ->
            Just "⩹"

        "lt" ->
            Just "<"

        "LT" ->
            Just "<"

        "Lt" ->
            Just "≪"

        "ltdot" ->
            Just "⋖"

        "lthree" ->
            Just "⋋"

        "ltimes" ->
            Just "⋉"

        "ltlarr" ->
            Just "⥶"

        "ltquest" ->
            Just "⩻"

        "ltri" ->
            Just "◃"

        "ltrie" ->
            Just "⊴"

        "ltrif" ->
            Just "◂"

        "ltrPar" ->
            Just "⦖"

        "lurdshar" ->
            Just "⥊"

        "luruhar" ->
            Just "⥦"

        "lvertneqq" ->
            Just "≨︀"

        "lvnE" ->
            Just "≨︀"

        "macr" ->
            Just "¯"

        "male" ->
            Just "♂"

        "malt" ->
            Just "✠"

        "maltese" ->
            Just "✠"

        "Map" ->
            Just "⤅"

        "map" ->
            Just "↦"

        "mapsto" ->
            Just "↦"

        "mapstodown" ->
            Just "↧"

        "mapstoleft" ->
            Just "↤"

        "mapstoup" ->
            Just "↥"

        "marker" ->
            Just "▮"

        "mcomma" ->
            Just "⨩"

        "Mcy" ->
            Just "М"

        "mcy" ->
            Just "м"

        "mdash" ->
            Just "—"

        "mDDot" ->
            Just "∺"

        "measuredangle" ->
            Just "∡"

        "MediumSpace" ->
            Just "\u{205F}"

        "Mellintrf" ->
            Just "ℳ"

        "Mfr" ->
            Just "\u{D835}\u{DD10}"

        "mfr" ->
            Just "\u{D835}\u{DD2A}"

        "mho" ->
            Just "℧"

        "micro" ->
            Just "µ"

        "midast" ->
            Just "*"

        "midcir" ->
            Just "⫰"

        "mid" ->
            Just "∣"

        "middot" ->
            Just "·"

        "minusb" ->
            Just "⊟"

        "minus" ->
            Just "−"

        "minusd" ->
            Just "∸"

        "minusdu" ->
            Just "⨪"

        "MinusPlus" ->
            Just "∓"

        "mlcp" ->
            Just "⫛"

        "mldr" ->
            Just "…"

        "mnplus" ->
            Just "∓"

        "models" ->
            Just "⊧"

        "Mopf" ->
            Just "\u{D835}\u{DD44}"

        "mopf" ->
            Just "\u{D835}\u{DD5E}"

        "mp" ->
            Just "∓"

        "mscr" ->
            Just "\u{D835}\u{DCC2}"

        "Mscr" ->
            Just "ℳ"

        "mstpos" ->
            Just "∾"

        "Mu" ->
            Just "Μ"

        "mu" ->
            Just "μ"

        "multimap" ->
            Just "⊸"

        "mumap" ->
            Just "⊸"

        "nabla" ->
            Just "∇"

        "Nacute" ->
            Just "Ń"

        "nacute" ->
            Just "ń"

        "nang" ->
            Just "∠⃒"

        "nap" ->
            Just "≉"

        "napE" ->
            Just "⩰̸"

        "napid" ->
            Just "≋̸"

        "napos" ->
            Just "ŉ"

        "napprox" ->
            Just "≉"

        "natural" ->
            Just "♮"

        "naturals" ->
            Just "ℕ"

        "natur" ->
            Just "♮"

        "nbsp" ->
            Just "\u{00A0}"

        "nbump" ->
            Just "≎̸"

        "nbumpe" ->
            Just "≏̸"

        "ncap" ->
            Just "⩃"

        "Ncaron" ->
            Just "Ň"

        "ncaron" ->
            Just "ň"

        "Ncedil" ->
            Just "Ņ"

        "ncedil" ->
            Just "ņ"

        "ncong" ->
            Just "≇"

        "ncongdot" ->
            Just "⩭̸"

        "ncup" ->
            Just "⩂"

        "Ncy" ->
            Just "Н"

        "ncy" ->
            Just "н"

        "ndash" ->
            Just "–"

        "nearhk" ->
            Just "⤤"

        "nearr" ->
            Just "↗"

        "neArr" ->
            Just "⇗"

        "nearrow" ->
            Just "↗"

        "ne" ->
            Just "≠"

        "nedot" ->
            Just "≐̸"

        "NegativeMediumSpace" ->
            Just "\u{200B}"

        "NegativeThickSpace" ->
            Just "\u{200B}"

        "NegativeThinSpace" ->
            Just "\u{200B}"

        "NegativeVeryThinSpace" ->
            Just "\u{200B}"

        "nequiv" ->
            Just "≢"

        "nesear" ->
            Just "⤨"

        "nesim" ->
            Just "≂̸"

        "NestedGreaterGreater" ->
            Just "≫"

        "NestedLessLess" ->
            Just "≪"

        "NewLine" ->
            Just "\n"

        "nexist" ->
            Just "∄"

        "nexists" ->
            Just "∄"

        "Nfr" ->
            Just "\u{D835}\u{DD11}"

        "nfr" ->
            Just "\u{D835}\u{DD2B}"

        "ngE" ->
            Just "≧̸"

        "nge" ->
            Just "≱"

        "ngeq" ->
            Just "≱"

        "ngeqq" ->
            Just "≧̸"

        "ngeqslant" ->
            Just "⩾̸"

        "nges" ->
            Just "⩾̸"

        "nGg" ->
            Just "⋙̸"

        "ngsim" ->
            Just "≵"

        "nGt" ->
            Just "≫⃒"

        "ngt" ->
            Just "≯"

        "ngtr" ->
            Just "≯"

        "nGtv" ->
            Just "≫̸"

        "nharr" ->
            Just "↮"

        "nhArr" ->
            Just "⇎"

        "nhpar" ->
            Just "⫲"

        "ni" ->
            Just "∋"

        "nis" ->
            Just "⋼"

        "nisd" ->
            Just "⋺"

        "niv" ->
            Just "∋"

        "NJcy" ->
            Just "Њ"

        "njcy" ->
            Just "њ"

        "nlarr" ->
            Just "↚"

        "nlArr" ->
            Just "⇍"

        "nldr" ->
            Just "‥"

        "nlE" ->
            Just "≦̸"

        "nle" ->
            Just "≰"

        "nleftarrow" ->
            Just "↚"

        "nLeftarrow" ->
            Just "⇍"

        "nleftrightarrow" ->
            Just "↮"

        "nLeftrightarrow" ->
            Just "⇎"

        "nleq" ->
            Just "≰"

        "nleqq" ->
            Just "≦̸"

        "nleqslant" ->
            Just "⩽̸"

        "nles" ->
            Just "⩽̸"

        "nless" ->
            Just "≮"

        "nLl" ->
            Just "⋘̸"

        "nlsim" ->
            Just "≴"

        "nLt" ->
            Just "≪⃒"

        "nlt" ->
            Just "≮"

        "nltri" ->
            Just "⋪"

        "nltrie" ->
            Just "⋬"

        "nLtv" ->
            Just "≪̸"

        "nmid" ->
            Just "∤"

        "NoBreak" ->
            Just "\u{2060}"

        "NonBreakingSpace" ->
            Just "\u{00A0}"

        "nopf" ->
            Just "\u{D835}\u{DD5F}"

        "Nopf" ->
            Just "ℕ"

        "Not" ->
            Just "⫬"

        "not" ->
            Just "¬"

        "NotCongruent" ->
            Just "≢"

        "NotCupCap" ->
            Just "≭"

        "NotDoubleVerticalBar" ->
            Just "∦"

        "NotElement" ->
            Just "∉"

        "NotEqual" ->
            Just "≠"

        "NotEqualTilde" ->
            Just "≂̸"

        "NotExists" ->
            Just "∄"

        "NotGreater" ->
            Just "≯"

        "NotGreaterEqual" ->
            Just "≱"

        "NotGreaterFullEqual" ->
            Just "≧̸"

        "NotGreaterGreater" ->
            Just "≫̸"

        "NotGreaterLess" ->
            Just "≹"

        "NotGreaterSlantEqual" ->
            Just "⩾̸"

        "NotGreaterTilde" ->
            Just "≵"

        "NotHumpDownHump" ->
            Just "≎̸"

        "NotHumpEqual" ->
            Just "≏̸"

        "notin" ->
            Just "∉"

        "notindot" ->
            Just "⋵̸"

        "notinE" ->
            Just "⋹̸"

        "notinva" ->
            Just "∉"

        "notinvb" ->
            Just "⋷"

        "notinvc" ->
            Just "⋶"

        "NotLeftTriangleBar" ->
            Just "⧏̸"

        "NotLeftTriangle" ->
            Just "⋪"

        "NotLeftTriangleEqual" ->
            Just "⋬"

        "NotLess" ->
            Just "≮"

        "NotLessEqual" ->
            Just "≰"

        "NotLessGreater" ->
            Just "≸"

        "NotLessLess" ->
            Just "≪̸"

        "NotLessSlantEqual" ->
            Just "⩽̸"

        "NotLessTilde" ->
            Just "≴"

        "NotNestedGreaterGreater" ->
            Just "⪢̸"

        "NotNestedLessLess" ->
            Just "⪡̸"

        "notni" ->
            Just "∌"

        "notniva" ->
            Just "∌"

        "notnivb" ->
            Just "⋾"

        "notnivc" ->
            Just "⋽"

        "NotPrecedes" ->
            Just "⊀"

        "NotPrecedesEqual" ->
            Just "⪯̸"

        "NotPrecedesSlantEqual" ->
            Just "⋠"

        "NotReverseElement" ->
            Just "∌"

        "NotRightTriangleBar" ->
            Just "⧐̸"

        "NotRightTriangle" ->
            Just "⋫"

        "NotRightTriangleEqual" ->
            Just "⋭"

        "NotSquareSubset" ->
            Just "⊏̸"

        "NotSquareSubsetEqual" ->
            Just "⋢"

        "NotSquareSuperset" ->
            Just "⊐̸"

        "NotSquareSupersetEqual" ->
            Just "⋣"

        "NotSubset" ->
            Just "⊂⃒"

        "NotSubsetEqual" ->
            Just "⊈"

        "NotSucceeds" ->
            Just "⊁"

        "NotSucceedsEqual" ->
            Just "⪰̸"

        "NotSucceedsSlantEqual" ->
            Just "⋡"

        "NotSucceedsTilde" ->
            Just "≿̸"

        "NotSuperset" ->
            Just "⊃⃒"

        "NotSupersetEqual" ->
            Just "⊉"

        "NotTilde" ->
            Just "≁"

        "NotTildeEqual" ->
            Just "≄"

        "NotTildeFullEqual" ->
            Just "≇"

        "NotTildeTilde" ->
            Just "≉"

        "NotVerticalBar" ->
            Just "∤"

        "nparallel" ->
            Just "∦"

        "npar" ->
            Just "∦"

        "nparsl" ->
            Just "⫽⃥"

        "npart" ->
            Just "∂̸"

        "npolint" ->
            Just "⨔"

        "npr" ->
            Just "⊀"

        "nprcue" ->
            Just "⋠"

        "nprec" ->
            Just "⊀"

        "npreceq" ->
            Just "⪯̸"

        "npre" ->
            Just "⪯̸"

        "nrarrc" ->
            Just "⤳̸"

        "nrarr" ->
            Just "↛"

        "nrArr" ->
            Just "⇏"

        "nrarrw" ->
            Just "↝̸"

        "nrightarrow" ->
            Just "↛"

        "nRightarrow" ->
            Just "⇏"

        "nrtri" ->
            Just "⋫"

        "nrtrie" ->
            Just "⋭"

        "nsc" ->
            Just "⊁"

        "nsccue" ->
            Just "⋡"

        "nsce" ->
            Just "⪰̸"

        "Nscr" ->
            Just "\u{D835}\u{DCA9}"

        "nscr" ->
            Just "\u{D835}\u{DCC3}"

        "nshortmid" ->
            Just "∤"

        "nshortparallel" ->
            Just "∦"

        "nsim" ->
            Just "≁"

        "nsime" ->
            Just "≄"

        "nsimeq" ->
            Just "≄"

        "nsmid" ->
            Just "∤"

        "nspar" ->
            Just "∦"

        "nsqsube" ->
            Just "⋢"

        "nsqsupe" ->
            Just "⋣"

        "nsub" ->
            Just "⊄"

        "nsubE" ->
            Just "⫅̸"

        "nsube" ->
            Just "⊈"

        "nsubset" ->
            Just "⊂⃒"

        "nsubseteq" ->
            Just "⊈"

        "nsubseteqq" ->
            Just "⫅̸"

        "nsucc" ->
            Just "⊁"

        "nsucceq" ->
            Just "⪰̸"

        "nsup" ->
            Just "⊅"

        "nsupE" ->
            Just "⫆̸"

        "nsupe" ->
            Just "⊉"

        "nsupset" ->
            Just "⊃⃒"

        "nsupseteq" ->
            Just "⊉"

        "nsupseteqq" ->
            Just "⫆̸"

        "ntgl" ->
            Just "≹"

        "Ntilde" ->
            Just "Ñ"

        "ntilde" ->
            Just "ñ"

        "ntlg" ->
            Just "≸"

        "ntriangleleft" ->
            Just "⋪"

        "ntrianglelefteq" ->
            Just "⋬"

        "ntriangleright" ->
            Just "⋫"

        "ntrianglerighteq" ->
            Just "⋭"

        "Nu" ->
            Just "Ν"

        "nu" ->
            Just "ν"

        "num" ->
            Just "#"

        "numero" ->
            Just "№"

        "numsp" ->
            Just "\u{2007}"

        "nvap" ->
            Just "≍⃒"

        "nvdash" ->
            Just "⊬"

        "nvDash" ->
            Just "⊭"

        "nVdash" ->
            Just "⊮"

        "nVDash" ->
            Just "⊯"

        "nvge" ->
            Just "≥⃒"

        "nvgt" ->
            Just ">⃒"

        "nvHarr" ->
            Just "⤄"

        "nvinfin" ->
            Just "⧞"

        "nvlArr" ->
            Just "⤂"

        "nvle" ->
            Just "≤⃒"

        "nvlt" ->
            Just "<⃒"

        "nvltrie" ->
            Just "⊴⃒"

        "nvrArr" ->
            Just "⤃"

        "nvrtrie" ->
            Just "⊵⃒"

        "nvsim" ->
            Just "∼⃒"

        "nwarhk" ->
            Just "⤣"

        "nwarr" ->
            Just "↖"

        "nwArr" ->
            Just "⇖"

        "nwarrow" ->
            Just "↖"

        "nwnear" ->
            Just "⤧"

        "Oacute" ->
            Just "Ó"

        "oacute" ->
            Just "ó"

        "oast" ->
            Just "⊛"

        "Ocirc" ->
            Just "Ô"

        "ocirc" ->
            Just "ô"

        "ocir" ->
            Just "⊚"

        "Ocy" ->
            Just "О"

        "ocy" ->
            Just "о"

        "odash" ->
            Just "⊝"

        "Odblac" ->
            Just "Ő"

        "odblac" ->
            Just "ő"

        "odiv" ->
            Just "⨸"

        "odot" ->
            Just "⊙"

        "odsold" ->
            Just "⦼"

        "OElig" ->
            Just "Œ"

        "oelig" ->
            Just "œ"

        "ofcir" ->
            Just "⦿"

        "Ofr" ->
            Just "\u{D835}\u{DD12}"

        "ofr" ->
            Just "\u{D835}\u{DD2C}"

        "ogon" ->
            Just "˛"

        "Ograve" ->
            Just "Ò"

        "ograve" ->
            Just "ò"

        "ogt" ->
            Just "⧁"

        "ohbar" ->
            Just "⦵"

        "ohm" ->
            Just "Ω"

        "oint" ->
            Just "∮"

        "olarr" ->
            Just "↺"

        "olcir" ->
            Just "⦾"

        "olcross" ->
            Just "⦻"

        "oline" ->
            Just "‾"

        "olt" ->
            Just "⧀"

        "Omacr" ->
            Just "Ō"

        "omacr" ->
            Just "ō"

        "Omega" ->
            Just "Ω"

        "omega" ->
            Just "ω"

        "Omicron" ->
            Just "Ο"

        "omicron" ->
            Just "ο"

        "omid" ->
            Just "⦶"

        "ominus" ->
            Just "⊖"

        "Oopf" ->
            Just "\u{D835}\u{DD46}"

        "oopf" ->
            Just "\u{D835}\u{DD60}"

        "opar" ->
            Just "⦷"

        "OpenCurlyDoubleQuote" ->
            Just "“"

        "OpenCurlyQuote" ->
            Just "‘"

        "operp" ->
            Just "⦹"

        "oplus" ->
            Just "⊕"

        "orarr" ->
            Just "↻"

        "Or" ->
            Just "⩔"

        "or" ->
            Just "∨"

        "ord" ->
            Just "⩝"

        "order" ->
            Just "ℴ"

        "orderof" ->
            Just "ℴ"

        "ordf" ->
            Just "ª"

        "ordm" ->
            Just "º"

        "origof" ->
            Just "⊶"

        "oror" ->
            Just "⩖"

        "orslope" ->
            Just "⩗"

        "orv" ->
            Just "⩛"

        "oS" ->
            Just "Ⓢ"

        "Oscr" ->
            Just "\u{D835}\u{DCAA}"

        "oscr" ->
            Just "ℴ"

        "Oslash" ->
            Just "Ø"

        "oslash" ->
            Just "ø"

        "osol" ->
            Just "⊘"

        "Otilde" ->
            Just "Õ"

        "otilde" ->
            Just "õ"

        "otimesas" ->
            Just "⨶"

        "Otimes" ->
            Just "⨷"

        "otimes" ->
            Just "⊗"

        "Ouml" ->
            Just "Ö"

        "ouml" ->
            Just "ö"

        "ovbar" ->
            Just "⌽"

        "OverBar" ->
            Just "‾"

        "OverBrace" ->
            Just "⏞"

        "OverBracket" ->
            Just "⎴"

        "OverParenthesis" ->
            Just "⏜"

        "para" ->
            Just "¶"

        "parallel" ->
            Just "∥"

        "par" ->
            Just "∥"

        "parsim" ->
            Just "⫳"

        "parsl" ->
            Just "⫽"

        "part" ->
            Just "∂"

        "PartialD" ->
            Just "∂"

        "Pcy" ->
            Just "П"

        "pcy" ->
            Just "п"

        "percnt" ->
            Just "%"

        "period" ->
            Just "."

        "permil" ->
            Just "‰"

        "perp" ->
            Just "⊥"

        "pertenk" ->
            Just "‱"

        "Pfr" ->
            Just "\u{D835}\u{DD13}"

        "pfr" ->
            Just "\u{D835}\u{DD2D}"

        "Phi" ->
            Just "Φ"

        "phi" ->
            Just "φ"

        "phiv" ->
            Just "ϕ"

        "phmmat" ->
            Just "ℳ"

        "phone" ->
            Just "☎"

        "Pi" ->
            Just "Π"

        "pi" ->
            Just "π"

        "pitchfork" ->
            Just "⋔"

        "piv" ->
            Just "ϖ"

        "planck" ->
            Just "ℏ"

        "planckh" ->
            Just "ℎ"

        "plankv" ->
            Just "ℏ"

        "plusacir" ->
            Just "⨣"

        "plusb" ->
            Just "⊞"

        "pluscir" ->
            Just "⨢"

        "plus" ->
            Just "+"

        "plusdo" ->
            Just "∔"

        "plusdu" ->
            Just "⨥"

        "pluse" ->
            Just "⩲"

        "PlusMinus" ->
            Just "±"

        "plusmn" ->
            Just "±"

        "plussim" ->
            Just "⨦"

        "plustwo" ->
            Just "⨧"

        "pm" ->
            Just "±"

        "Poincareplane" ->
            Just "ℌ"

        "pointint" ->
            Just "⨕"

        "popf" ->
            Just "\u{D835}\u{DD61}"

        "Popf" ->
            Just "ℙ"

        "pound" ->
            Just "£"

        "prap" ->
            Just "⪷"

        "Pr" ->
            Just "⪻"

        "pr" ->
            Just "≺"

        "prcue" ->
            Just "≼"

        "precapprox" ->
            Just "⪷"

        "prec" ->
            Just "≺"

        "preccurlyeq" ->
            Just "≼"

        "Precedes" ->
            Just "≺"

        "PrecedesEqual" ->
            Just "⪯"

        "PrecedesSlantEqual" ->
            Just "≼"

        "PrecedesTilde" ->
            Just "≾"

        "preceq" ->
            Just "⪯"

        "precnapprox" ->
            Just "⪹"

        "precneqq" ->
            Just "⪵"

        "precnsim" ->
            Just "⋨"

        "pre" ->
            Just "⪯"

        "prE" ->
            Just "⪳"

        "precsim" ->
            Just "≾"

        "prime" ->
            Just "′"

        "Prime" ->
            Just "″"

        "primes" ->
            Just "ℙ"

        "prnap" ->
            Just "⪹"

        "prnE" ->
            Just "⪵"

        "prnsim" ->
            Just "⋨"

        "prod" ->
            Just "∏"

        "Product" ->
            Just "∏"

        "profalar" ->
            Just "⌮"

        "profline" ->
            Just "⌒"

        "profsurf" ->
            Just "⌓"

        "prop" ->
            Just "∝"

        "Proportional" ->
            Just "∝"

        "Proportion" ->
            Just "∷"

        "propto" ->
            Just "∝"

        "prsim" ->
            Just "≾"

        "prurel" ->
            Just "⊰"

        "Pscr" ->
            Just "\u{D835}\u{DCAB}"

        "pscr" ->
            Just "\u{D835}\u{DCC5}"

        "Psi" ->
            Just "Ψ"

        "psi" ->
            Just "ψ"

        "puncsp" ->
            Just "\u{2008}"

        "Qfr" ->
            Just "\u{D835}\u{DD14}"

        "qfr" ->
            Just "\u{D835}\u{DD2E}"

        "qint" ->
            Just "⨌"

        "qopf" ->
            Just "\u{D835}\u{DD62}"

        "Qopf" ->
            Just "ℚ"

        "qprime" ->
            Just "⁗"

        "Qscr" ->
            Just "\u{D835}\u{DCAC}"

        "qscr" ->
            Just "\u{D835}\u{DCC6}"

        "quaternions" ->
            Just "ℍ"

        "quatint" ->
            Just "⨖"

        "quest" ->
            Just "?"

        "questeq" ->
            Just "≟"

        "quot" ->
            Just "\""

        "QUOT" ->
            Just "\""

        "rAarr" ->
            Just "⇛"

        "race" ->
            Just "∽̱"

        "Racute" ->
            Just "Ŕ"

        "racute" ->
            Just "ŕ"

        "radic" ->
            Just "√"

        "raemptyv" ->
            Just "⦳"

        "rang" ->
            Just "⟩"

        "Rang" ->
            Just "⟫"

        "rangd" ->
            Just "⦒"

        "range" ->
            Just "⦥"

        "rangle" ->
            Just "⟩"

        "raquo" ->
            Just "»"

        "rarrap" ->
            Just "⥵"

        "rarrb" ->
            Just "⇥"

        "rarrbfs" ->
            Just "⤠"

        "rarrc" ->
            Just "⤳"

        "rarr" ->
            Just "→"

        "Rarr" ->
            Just "↠"

        "rArr" ->
            Just "⇒"

        "rarrfs" ->
            Just "⤞"

        "rarrhk" ->
            Just "↪"

        "rarrlp" ->
            Just "↬"

        "rarrpl" ->
            Just "⥅"

        "rarrsim" ->
            Just "⥴"

        "Rarrtl" ->
            Just "⤖"

        "rarrtl" ->
            Just "↣"

        "rarrw" ->
            Just "↝"

        "ratail" ->
            Just "⤚"

        "rAtail" ->
            Just "⤜"

        "ratio" ->
            Just "∶"

        "rationals" ->
            Just "ℚ"

        "rbarr" ->
            Just "⤍"

        "rBarr" ->
            Just "⤏"

        "RBarr" ->
            Just "⤐"

        "rbbrk" ->
            Just "❳"

        "rbrace" ->
            Just "}"

        "rbrack" ->
            Just "]"

        "rbrke" ->
            Just "⦌"

        "rbrksld" ->
            Just "⦎"

        "rbrkslu" ->
            Just "⦐"

        "Rcaron" ->
            Just "Ř"

        "rcaron" ->
            Just "ř"

        "Rcedil" ->
            Just "Ŗ"

        "rcedil" ->
            Just "ŗ"

        "rceil" ->
            Just "⌉"

        "rcub" ->
            Just "}"

        "Rcy" ->
            Just "Р"

        "rcy" ->
            Just "р"

        "rdca" ->
            Just "⤷"

        "rdldhar" ->
            Just "⥩"

        "rdquo" ->
            Just "”"

        "rdquor" ->
            Just "”"

        "rdsh" ->
            Just "↳"

        "real" ->
            Just "ℜ"

        "realine" ->
            Just "ℛ"

        "realpart" ->
            Just "ℜ"

        "reals" ->
            Just "ℝ"

        "Re" ->
            Just "ℜ"

        "rect" ->
            Just "▭"

        "reg" ->
            Just "®"

        "REG" ->
            Just "®"

        "ReverseElement" ->
            Just "∋"

        "ReverseEquilibrium" ->
            Just "⇋"

        "ReverseUpEquilibrium" ->
            Just "⥯"

        "rfisht" ->
            Just "⥽"

        "rfloor" ->
            Just "⌋"

        "rfr" ->
            Just "\u{D835}\u{DD2F}"

        "Rfr" ->
            Just "ℜ"

        "rHar" ->
            Just "⥤"

        "rhard" ->
            Just "⇁"

        "rharu" ->
            Just "⇀"

        "rharul" ->
            Just "⥬"

        "Rho" ->
            Just "Ρ"

        "rho" ->
            Just "ρ"

        "rhov" ->
            Just "ϱ"

        "RightAngleBracket" ->
            Just "⟩"

        "RightArrowBar" ->
            Just "⇥"

        "rightarrow" ->
            Just "→"

        "RightArrow" ->
            Just "→"

        "Rightarrow" ->
            Just "⇒"

        "RightArrowLeftArrow" ->
            Just "⇄"

        "rightarrowtail" ->
            Just "↣"

        "RightCeiling" ->
            Just "⌉"

        "RightDoubleBracket" ->
            Just "⟧"

        "RightDownTeeVector" ->
            Just "⥝"

        "RightDownVectorBar" ->
            Just "⥕"

        "RightDownVector" ->
            Just "⇂"

        "RightFloor" ->
            Just "⌋"

        "rightharpoondown" ->
            Just "⇁"

        "rightharpoonup" ->
            Just "⇀"

        "rightleftarrows" ->
            Just "⇄"

        "rightleftharpoons" ->
            Just "⇌"

        "rightrightarrows" ->
            Just "⇉"

        "rightsquigarrow" ->
            Just "↝"

        "RightTeeArrow" ->
            Just "↦"

        "RightTee" ->
            Just "⊢"

        "RightTeeVector" ->
            Just "⥛"

        "rightthreetimes" ->
            Just "⋌"

        "RightTriangleBar" ->
            Just "⧐"

        "RightTriangle" ->
            Just "⊳"

        "RightTriangleEqual" ->
            Just "⊵"

        "RightUpDownVector" ->
            Just "⥏"

        "RightUpTeeVector" ->
            Just "⥜"

        "RightUpVectorBar" ->
            Just "⥔"

        "RightUpVector" ->
            Just "↾"

        "RightVectorBar" ->
            Just "⥓"

        "RightVector" ->
            Just "⇀"

        "ring" ->
            Just "˚"

        "risingdotseq" ->
            Just "≓"

        "rlarr" ->
            Just "⇄"

        "rlhar" ->
            Just "⇌"

        "rlm" ->
            Just "\u{200F}"

        "rmoustache" ->
            Just "⎱"

        "rmoust" ->
            Just "⎱"

        "rnmid" ->
            Just "⫮"

        "roang" ->
            Just "⟭"

        "roarr" ->
            Just "⇾"

        "robrk" ->
            Just "⟧"

        "ropar" ->
            Just "⦆"

        "ropf" ->
            Just "\u{D835}\u{DD63}"

        "Ropf" ->
            Just "ℝ"

        "roplus" ->
            Just "⨮"

        "rotimes" ->
            Just "⨵"

        "RoundImplies" ->
            Just "⥰"

        "rpar" ->
            Just ")"

        "rpargt" ->
            Just "⦔"

        "rppolint" ->
            Just "⨒"

        "rrarr" ->
            Just "⇉"

        "Rrightarrow" ->
            Just "⇛"

        "rsaquo" ->
            Just "›"

        "rscr" ->
            Just "\u{D835}\u{DCC7}"

        "Rscr" ->
            Just "ℛ"

        "rsh" ->
            Just "↱"

        "Rsh" ->
            Just "↱"

        "rsqb" ->
            Just "]"

        "rsquo" ->
            Just "’"

        "rsquor" ->
            Just "’"

        "rthree" ->
            Just "⋌"

        "rtimes" ->
            Just "⋊"

        "rtri" ->
            Just "▹"

        "rtrie" ->
            Just "⊵"

        "rtrif" ->
            Just "▸"

        "rtriltri" ->
            Just "⧎"

        "RuleDelayed" ->
            Just "⧴"

        "ruluhar" ->
            Just "⥨"

        "rx" ->
            Just "℞"

        "Sacute" ->
            Just "Ś"

        "sacute" ->
            Just "ś"

        "sbquo" ->
            Just "‚"

        "scap" ->
            Just "⪸"

        "Scaron" ->
            Just "Š"

        "scaron" ->
            Just "š"

        "Sc" ->
            Just "⪼"

        "sc" ->
            Just "≻"

        "sccue" ->
            Just "≽"

        "sce" ->
            Just "⪰"

        "scE" ->
            Just "⪴"

        "Scedil" ->
            Just "Ş"

        "scedil" ->
            Just "ş"

        "Scirc" ->
            Just "Ŝ"

        "scirc" ->
            Just "ŝ"

        "scnap" ->
            Just "⪺"

        "scnE" ->
            Just "⪶"

        "scnsim" ->
            Just "⋩"

        "scpolint" ->
            Just "⨓"

        "scsim" ->
            Just "≿"

        "Scy" ->
            Just "С"

        "scy" ->
            Just "с"

        "sdotb" ->
            Just "⊡"

        "sdot" ->
            Just "⋅"

        "sdote" ->
            Just "⩦"

        "searhk" ->
            Just "⤥"

        "searr" ->
            Just "↘"

        "seArr" ->
            Just "⇘"

        "searrow" ->
            Just "↘"

        "sect" ->
            Just "§"

        "semi" ->
            Just ";"

        "seswar" ->
            Just "⤩"

        "setminus" ->
            Just "∖"

        "setmn" ->
            Just "∖"

        "sext" ->
            Just "✶"

        "Sfr" ->
            Just "\u{D835}\u{DD16}"

        "sfr" ->
            Just "\u{D835}\u{DD30}"

        "sfrown" ->
            Just "⌢"

        "sharp" ->
            Just "♯"

        "SHCHcy" ->
            Just "Щ"

        "shchcy" ->
            Just "щ"

        "SHcy" ->
            Just "Ш"

        "shcy" ->
            Just "ш"

        "ShortDownArrow" ->
            Just "↓"

        "ShortLeftArrow" ->
            Just "←"

        "shortmid" ->
            Just "∣"

        "shortparallel" ->
            Just "∥"

        "ShortRightArrow" ->
            Just "→"

        "ShortUpArrow" ->
            Just "↑"

        "shy" ->
            Just "\u{00AD}"

        "Sigma" ->
            Just "Σ"

        "sigma" ->
            Just "σ"

        "sigmaf" ->
            Just "ς"

        "sigmav" ->
            Just "ς"

        "sim" ->
            Just "∼"

        "simdot" ->
            Just "⩪"

        "sime" ->
            Just "≃"

        "simeq" ->
            Just "≃"

        "simg" ->
            Just "⪞"

        "simgE" ->
            Just "⪠"

        "siml" ->
            Just "⪝"

        "simlE" ->
            Just "⪟"

        "simne" ->
            Just "≆"

        "simplus" ->
            Just "⨤"

        "simrarr" ->
            Just "⥲"

        "slarr" ->
            Just "←"

        "SmallCircle" ->
            Just "∘"

        "smallsetminus" ->
            Just "∖"

        "smashp" ->
            Just "⨳"

        "smeparsl" ->
            Just "⧤"

        "smid" ->
            Just "∣"

        "smile" ->
            Just "⌣"

        "smt" ->
            Just "⪪"

        "smte" ->
            Just "⪬"

        "smtes" ->
            Just "⪬︀"

        "SOFTcy" ->
            Just "Ь"

        "softcy" ->
            Just "ь"

        "solbar" ->
            Just "⌿"

        "solb" ->
            Just "⧄"

        "sol" ->
            Just "/"

        "Sopf" ->
            Just "\u{D835}\u{DD4A}"

        "sopf" ->
            Just "\u{D835}\u{DD64}"

        "spades" ->
            Just "♠"

        "spadesuit" ->
            Just "♠"

        "spar" ->
            Just "∥"

        "sqcap" ->
            Just "⊓"

        "sqcaps" ->
            Just "⊓︀"

        "sqcup" ->
            Just "⊔"

        "sqcups" ->
            Just "⊔︀"

        "Sqrt" ->
            Just "√"

        "sqsub" ->
            Just "⊏"

        "sqsube" ->
            Just "⊑"

        "sqsubset" ->
            Just "⊏"

        "sqsubseteq" ->
            Just "⊑"

        "sqsup" ->
            Just "⊐"

        "sqsupe" ->
            Just "⊒"

        "sqsupset" ->
            Just "⊐"

        "sqsupseteq" ->
            Just "⊒"

        "square" ->
            Just "□"

        "Square" ->
            Just "□"

        "SquareIntersection" ->
            Just "⊓"

        "SquareSubset" ->
            Just "⊏"

        "SquareSubsetEqual" ->
            Just "⊑"

        "SquareSuperset" ->
            Just "⊐"

        "SquareSupersetEqual" ->
            Just "⊒"

        "SquareUnion" ->
            Just "⊔"

        "squarf" ->
            Just "▪"

        "squ" ->
            Just "□"

        "squf" ->
            Just "▪"

        "srarr" ->
            Just "→"

        "Sscr" ->
            Just "\u{D835}\u{DCAE}"

        "sscr" ->
            Just "\u{D835}\u{DCC8}"

        "ssetmn" ->
            Just "∖"

        "ssmile" ->
            Just "⌣"

        "sstarf" ->
            Just "⋆"

        "Star" ->
            Just "⋆"

        "star" ->
            Just "☆"

        "starf" ->
            Just "★"

        "straightepsilon" ->
            Just "ϵ"

        "straightphi" ->
            Just "ϕ"

        "strns" ->
            Just "¯"

        "sub" ->
            Just "⊂"

        "Sub" ->
            Just "⋐"

        "subdot" ->
            Just "⪽"

        "subE" ->
            Just "⫅"

        "sube" ->
            Just "⊆"

        "subedot" ->
            Just "⫃"

        "submult" ->
            Just "⫁"

        "subnE" ->
            Just "⫋"

        "subne" ->
            Just "⊊"

        "subplus" ->
            Just "⪿"

        "subrarr" ->
            Just "⥹"

        "subset" ->
            Just "⊂"

        "Subset" ->
            Just "⋐"

        "subseteq" ->
            Just "⊆"

        "subseteqq" ->
            Just "⫅"

        "SubsetEqual" ->
            Just "⊆"

        "subsetneq" ->
            Just "⊊"

        "subsetneqq" ->
            Just "⫋"

        "subsim" ->
            Just "⫇"

        "subsub" ->
            Just "⫕"

        "subsup" ->
            Just "⫓"

        "succapprox" ->
            Just "⪸"

        "succ" ->
            Just "≻"

        "succcurlyeq" ->
            Just "≽"

        "Succeeds" ->
            Just "≻"

        "SucceedsEqual" ->
            Just "⪰"

        "SucceedsSlantEqual" ->
            Just "≽"

        "SucceedsTilde" ->
            Just "≿"

        "succeq" ->
            Just "⪰"

        "succnapprox" ->
            Just "⪺"

        "succneqq" ->
            Just "⪶"

        "succnsim" ->
            Just "⋩"

        "succsim" ->
            Just "≿"

        "SuchThat" ->
            Just "∋"

        "sum" ->
            Just "∑"

        "Sum" ->
            Just "∑"

        "sung" ->
            Just "♪"

        "sup1" ->
            Just "¹"

        "sup2" ->
            Just "²"

        "sup3" ->
            Just "³"

        "sup" ->
            Just "⊃"

        "Sup" ->
            Just "⋑"

        "supdot" ->
            Just "⪾"

        "supdsub" ->
            Just "⫘"

        "supE" ->
            Just "⫆"

        "supe" ->
            Just "⊇"

        "supedot" ->
            Just "⫄"

        "Superset" ->
            Just "⊃"

        "SupersetEqual" ->
            Just "⊇"

        "suphsol" ->
            Just "⟉"

        "suphsub" ->
            Just "⫗"

        "suplarr" ->
            Just "⥻"

        "supmult" ->
            Just "⫂"

        "supnE" ->
            Just "⫌"

        "supne" ->
            Just "⊋"

        "supplus" ->
            Just "⫀"

        "supset" ->
            Just "⊃"

        "Supset" ->
            Just "⋑"

        "supseteq" ->
            Just "⊇"

        "supseteqq" ->
            Just "⫆"

        "supsetneq" ->
            Just "⊋"

        "supsetneqq" ->
            Just "⫌"

        "supsim" ->
            Just "⫈"

        "supsub" ->
            Just "⫔"

        "supsup" ->
            Just "⫖"

        "swarhk" ->
            Just "⤦"

        "swarr" ->
            Just "↙"

        "swArr" ->
            Just "⇙"

        "swarrow" ->
            Just "↙"

        "swnwar" ->
            Just "⤪"

        "szlig" ->
            Just "ß"

        "Tab" ->
            Just "\t"

        "target" ->
            Just "⌖"

        "Tau" ->
            Just "Τ"

        "tau" ->
            Just "τ"

        "tbrk" ->
            Just "⎴"

        "Tcaron" ->
            Just "Ť"

        "tcaron" ->
            Just "ť"

        "Tcedil" ->
            Just "Ţ"

        "tcedil" ->
            Just "ţ"

        "Tcy" ->
            Just "Т"

        "tcy" ->
            Just "т"

        "tdot" ->
            Just "⃛"

        "telrec" ->
            Just "⌕"

        "Tfr" ->
            Just "\u{D835}\u{DD17}"

        "tfr" ->
            Just "\u{D835}\u{DD31}"

        "there4" ->
            Just "∴"

        "therefore" ->
            Just "∴"

        "Therefore" ->
            Just "∴"

        "Theta" ->
            Just "Θ"

        "theta" ->
            Just "θ"

        "thetasym" ->
            Just "ϑ"

        "thetav" ->
            Just "ϑ"

        "thickapprox" ->
            Just "≈"

        "thicksim" ->
            Just "∼"

        "ThickSpace" ->
            Just "\u{205F}\u{200A}"

        "ThinSpace" ->
            Just "\u{2009}"

        "thinsp" ->
            Just "\u{2009}"

        "thkap" ->
            Just "≈"

        "thksim" ->
            Just "∼"

        "THORN" ->
            Just "Þ"

        "thorn" ->
            Just "þ"

        "tilde" ->
            Just "˜"

        "Tilde" ->
            Just "∼"

        "TildeEqual" ->
            Just "≃"

        "TildeFullEqual" ->
            Just "≅"

        "TildeTilde" ->
            Just "≈"

        "timesbar" ->
            Just "⨱"

        "timesb" ->
            Just "⊠"

        "times" ->
            Just "×"

        "timesd" ->
            Just "⨰"

        "tint" ->
            Just "∭"

        "toea" ->
            Just "⤨"

        "topbot" ->
            Just "⌶"

        "topcir" ->
            Just "⫱"

        "top" ->
            Just "⊤"

        "Topf" ->
            Just "\u{D835}\u{DD4B}"

        "topf" ->
            Just "\u{D835}\u{DD65}"

        "topfork" ->
            Just "⫚"

        "tosa" ->
            Just "⤩"

        "tprime" ->
            Just "‴"

        "trade" ->
            Just "™"

        "TRADE" ->
            Just "™"

        "triangle" ->
            Just "▵"

        "triangledown" ->
            Just "▿"

        "triangleleft" ->
            Just "◃"

        "trianglelefteq" ->
            Just "⊴"

        "triangleq" ->
            Just "≜"

        "triangleright" ->
            Just "▹"

        "trianglerighteq" ->
            Just "⊵"

        "tridot" ->
            Just "◬"

        "trie" ->
            Just "≜"

        "triminus" ->
            Just "⨺"

        "TripleDot" ->
            Just "⃛"

        "triplus" ->
            Just "⨹"

        "trisb" ->
            Just "⧍"

        "tritime" ->
            Just "⨻"

        "trpezium" ->
            Just "⏢"

        "Tscr" ->
            Just "\u{D835}\u{DCAF}"

        "tscr" ->
            Just "\u{D835}\u{DCC9}"

        "TScy" ->
            Just "Ц"

        "tscy" ->
            Just "ц"

        "TSHcy" ->
            Just "Ћ"

        "tshcy" ->
            Just "ћ"

        "Tstrok" ->
            Just "Ŧ"

        "tstrok" ->
            Just "ŧ"

        "twixt" ->
            Just "≬"

        "twoheadleftarrow" ->
            Just "↞"

        "twoheadrightarrow" ->
            Just "↠"

        "Uacute" ->
            Just "Ú"

        "uacute" ->
            Just "ú"

        "uarr" ->
            Just "↑"

        "Uarr" ->
            Just "↟"

        "uArr" ->
            Just "⇑"

        "Uarrocir" ->
            Just "⥉"

        "Ubrcy" ->
            Just "Ў"

        "ubrcy" ->
            Just "ў"

        "Ubreve" ->
            Just "Ŭ"

        "ubreve" ->
            Just "ŭ"

        "Ucirc" ->
            Just "Û"

        "ucirc" ->
            Just "û"

        "Ucy" ->
            Just "У"

        "ucy" ->
            Just "у"

        "udarr" ->
            Just "⇅"

        "Udblac" ->
            Just "Ű"

        "udblac" ->
            Just "ű"

        "udhar" ->
            Just "⥮"

        "ufisht" ->
            Just "⥾"

        "Ufr" ->
            Just "\u{D835}\u{DD18}"

        "ufr" ->
            Just "\u{D835}\u{DD32}"

        "Ugrave" ->
            Just "Ù"

        "ugrave" ->
            Just "ù"

        "uHar" ->
            Just "⥣"

        "uharl" ->
            Just "↿"

        "uharr" ->
            Just "↾"

        "uhblk" ->
            Just "▀"

        "ulcorn" ->
            Just "⌜"

        "ulcorner" ->
            Just "⌜"

        "ulcrop" ->
            Just "⌏"

        "ultri" ->
            Just "◸"

        "Umacr" ->
            Just "Ū"

        "umacr" ->
            Just "ū"

        "uml" ->
            Just "¨"

        "UnderBar" ->
            Just "_"

        "UnderBrace" ->
            Just "⏟"

        "UnderBracket" ->
            Just "⎵"

        "UnderParenthesis" ->
            Just "⏝"

        "Union" ->
            Just "⋃"

        "UnionPlus" ->
            Just "⊎"

        "Uogon" ->
            Just "Ų"

        "uogon" ->
            Just "ų"

        "Uopf" ->
            Just "\u{D835}\u{DD4C}"

        "uopf" ->
            Just "\u{D835}\u{DD66}"

        "UpArrowBar" ->
            Just "⤒"

        "uparrow" ->
            Just "↑"

        "UpArrow" ->
            Just "↑"

        "Uparrow" ->
            Just "⇑"

        "UpArrowDownArrow" ->
            Just "⇅"

        "updownarrow" ->
            Just "↕"

        "UpDownArrow" ->
            Just "↕"

        "Updownarrow" ->
            Just "⇕"

        "UpEquilibrium" ->
            Just "⥮"

        "upharpoonleft" ->
            Just "↿"

        "upharpoonright" ->
            Just "↾"

        "uplus" ->
            Just "⊎"

        "UpperLeftArrow" ->
            Just "↖"

        "UpperRightArrow" ->
            Just "↗"

        "upsi" ->
            Just "υ"

        "Upsi" ->
            Just "ϒ"

        "upsih" ->
            Just "ϒ"

        "Upsilon" ->
            Just "Υ"

        "upsilon" ->
            Just "υ"

        "UpTeeArrow" ->
            Just "↥"

        "UpTee" ->
            Just "⊥"

        "upuparrows" ->
            Just "⇈"

        "urcorn" ->
            Just "⌝"

        "urcorner" ->
            Just "⌝"

        "urcrop" ->
            Just "⌎"

        "Uring" ->
            Just "Ů"

        "uring" ->
            Just "ů"

        "urtri" ->
            Just "◹"

        "Uscr" ->
            Just "\u{D835}\u{DCB0}"

        "uscr" ->
            Just "\u{D835}\u{DCCA}"

        "utdot" ->
            Just "⋰"

        "Utilde" ->
            Just "Ũ"

        "utilde" ->
            Just "ũ"

        "utri" ->
            Just "▵"

        "utrif" ->
            Just "▴"

        "uuarr" ->
            Just "⇈"

        "Uuml" ->
            Just "Ü"

        "uuml" ->
            Just "ü"

        "uwangle" ->
            Just "⦧"

        "vangrt" ->
            Just "⦜"

        "varepsilon" ->
            Just "ϵ"

        "varkappa" ->
            Just "ϰ"

        "varnothing" ->
            Just "∅"

        "varphi" ->
            Just "ϕ"

        "varpi" ->
            Just "ϖ"

        "varpropto" ->
            Just "∝"

        "varr" ->
            Just "↕"

        "vArr" ->
            Just "⇕"

        "varrho" ->
            Just "ϱ"

        "varsigma" ->
            Just "ς"

        "varsubsetneq" ->
            Just "⊊︀"

        "varsubsetneqq" ->
            Just "⫋︀"

        "varsupsetneq" ->
            Just "⊋︀"

        "varsupsetneqq" ->
            Just "⫌︀"

        "vartheta" ->
            Just "ϑ"

        "vartriangleleft" ->
            Just "⊲"

        "vartriangleright" ->
            Just "⊳"

        "vBar" ->
            Just "⫨"

        "Vbar" ->
            Just "⫫"

        "vBarv" ->
            Just "⫩"

        "Vcy" ->
            Just "В"

        "vcy" ->
            Just "в"

        "vdash" ->
            Just "⊢"

        "vDash" ->
            Just "⊨"

        "Vdash" ->
            Just "⊩"

        "VDash" ->
            Just "⊫"

        "Vdashl" ->
            Just "⫦"

        "veebar" ->
            Just "⊻"

        "vee" ->
            Just "∨"

        "Vee" ->
            Just "⋁"

        "veeeq" ->
            Just "≚"

        "vellip" ->
            Just "⋮"

        "verbar" ->
            Just "|"

        "Verbar" ->
            Just "‖"

        "vert" ->
            Just "|"

        "Vert" ->
            Just "‖"

        "VerticalBar" ->
            Just "∣"

        "VerticalLine" ->
            Just "|"

        "VerticalSeparator" ->
            Just "❘"

        "VerticalTilde" ->
            Just "≀"

        "VeryThinSpace" ->
            Just "\u{200A}"

        "Vfr" ->
            Just "\u{D835}\u{DD19}"

        "vfr" ->
            Just "\u{D835}\u{DD33}"

        "vltri" ->
            Just "⊲"

        "vnsub" ->
            Just "⊂⃒"

        "vnsup" ->
            Just "⊃⃒"

        "Vopf" ->
            Just "\u{D835}\u{DD4D}"

        "vopf" ->
            Just "\u{D835}\u{DD67}"

        "vprop" ->
            Just "∝"

        "vrtri" ->
            Just "⊳"

        "Vscr" ->
            Just "\u{D835}\u{DCB1}"

        "vscr" ->
            Just "\u{D835}\u{DCCB}"

        "vsubnE" ->
            Just "⫋︀"

        "vsubne" ->
            Just "⊊︀"

        "vsupnE" ->
            Just "⫌︀"

        "vsupne" ->
            Just "⊋︀"

        "Vvdash" ->
            Just "⊪"

        "vzigzag" ->
            Just "⦚"

        "Wcirc" ->
            Just "Ŵ"

        "wcirc" ->
            Just "ŵ"

        "wedbar" ->
            Just "⩟"

        "wedge" ->
            Just "∧"

        "Wedge" ->
            Just "⋀"

        "wedgeq" ->
            Just "≙"

        "weierp" ->
            Just "℘"

        "Wfr" ->
            Just "\u{D835}\u{DD1A}"

        "wfr" ->
            Just "\u{D835}\u{DD34}"

        "Wopf" ->
            Just "\u{D835}\u{DD4E}"

        "wopf" ->
            Just "\u{D835}\u{DD68}"

        "wp" ->
            Just "℘"

        "wr" ->
            Just "≀"

        "wreath" ->
            Just "≀"

        "Wscr" ->
            Just "\u{D835}\u{DCB2}"

        "wscr" ->
            Just "\u{D835}\u{DCCC}"

        "xcap" ->
            Just "⋂"

        "xcirc" ->
            Just "◯"

        "xcup" ->
            Just "⋃"

        "xdtri" ->
            Just "▽"

        "Xfr" ->
            Just "\u{D835}\u{DD1B}"

        "xfr" ->
            Just "\u{D835}\u{DD35}"

        "xharr" ->
            Just "⟷"

        "xhArr" ->
            Just "⟺"

        "Xi" ->
            Just "Ξ"

        "xi" ->
            Just "ξ"

        "xlarr" ->
            Just "⟵"

        "xlArr" ->
            Just "⟸"

        "xmap" ->
            Just "⟼"

        "xnis" ->
            Just "⋻"

        "xodot" ->
            Just "⨀"

        "Xopf" ->
            Just "\u{D835}\u{DD4F}"

        "xopf" ->
            Just "\u{D835}\u{DD69}"

        "xoplus" ->
            Just "⨁"

        "xotime" ->
            Just "⨂"

        "xrarr" ->
            Just "⟶"

        "xrArr" ->
            Just "⟹"

        "Xscr" ->
            Just "\u{D835}\u{DCB3}"

        "xscr" ->
            Just "\u{D835}\u{DCCD}"

        "xsqcup" ->
            Just "⨆"

        "xuplus" ->
            Just "⨄"

        "xutri" ->
            Just "△"

        "xvee" ->
            Just "⋁"

        "xwedge" ->
            Just "⋀"

        "Yacute" ->
            Just "Ý"

        "yacute" ->
            Just "ý"

        "YAcy" ->
            Just "Я"

        "yacy" ->
            Just "я"

        "Ycirc" ->
            Just "Ŷ"

        "ycirc" ->
            Just "ŷ"

        "Ycy" ->
            Just "Ы"

        "ycy" ->
            Just "ы"

        "yen" ->
            Just "¥"

        "Yfr" ->
            Just "\u{D835}\u{DD1C}"

        "yfr" ->
            Just "\u{D835}\u{DD36}"

        "YIcy" ->
            Just "Ї"

        "yicy" ->
            Just "ї"

        "Yopf" ->
            Just "\u{D835}\u{DD50}"

        "yopf" ->
            Just "\u{D835}\u{DD6A}"

        "Yscr" ->
            Just "\u{D835}\u{DCB4}"

        "yscr" ->
            Just "\u{D835}\u{DCCE}"

        "YUcy" ->
            Just "Ю"

        "yucy" ->
            Just "ю"

        "yuml" ->
            Just "ÿ"

        "Yuml" ->
            Just "Ÿ"

        "Zacute" ->
            Just "Ź"

        "zacute" ->
            Just "ź"

        "Zcaron" ->
            Just "Ž"

        "zcaron" ->
            Just "ž"

        "Zcy" ->
            Just "З"

        "zcy" ->
            Just "з"

        "Zdot" ->
            Just "Ż"

        "zdot" ->
            Just "ż"

        "zeetrf" ->
            Just "ℨ"

        "ZeroWidthSpace" ->
            Just "\u{200B}"

        "Zeta" ->
            Just "Ζ"

        "zeta" ->
            Just "ζ"

        "zfr" ->
            Just "\u{D835}\u{DD37}"

        "Zfr" ->
            Just "ℨ"

        "ZHcy" ->
            Just "Ж"

        "zhcy" ->
            Just "ж"

        "zigrarr" ->
            Just "⇝"

        "zopf" ->
            Just "\u{D835}\u{DD6B}"

        "Zopf" ->
            Just "ℤ"

        "Zscr" ->
            Just "\u{D835}\u{DCB5}"

        "zscr" ->
            Just "\u{D835}\u{DCCF}"

        "zwj" ->
            Just "\u{200D}"

        "zwnj" ->
            Just "\u{200C}"

        _ ->
            Nothing
