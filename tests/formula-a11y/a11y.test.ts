// node --test tests/formula-a11y/
//
// The text that screen readers and TTS read for a <lia-formula>, per language.

import { test } from 'node:test'
import assert from 'node:assert/strict'
import 'katex/contrib/mhchem/mhchem.js'

import renderA11yString from '../../src/typescript/webcomponents/formula/a11y/index.ts'
import en from '../../src/typescript/webcomponents/formula/a11y/en.ts'
import de from '../../src/typescript/webcomponents/formula/a11y/de.ts'

// [LaTeX, English, German]
const cases: [string, string, string][] = [
  // fractions, powers, indices
  ['\\frac{1}{2}', 'one half', 'ein halb'],
  [
    '\\frac{a+b}{2}',
    'start fraction, a plus b, divided by, 2, end fraction',
    'Anfang Bruch, a plus b, geteilt durch, 2, Ende Bruch',
  ],
  [
    'x^2+y^2=z^2',
    'x squared plus y squared, equals, z squared',
    'x zum Quadrat plus y zum Quadrat, gleich, z zum Quadrat',
  ],
  ['x^3', 'x cubed', 'x hoch drei'],
  [
    'x^{n+1}',
    'x, start superscript, n plus 1, end superscript',
    'x, Anfang Exponent, n plus 1, Ende Exponent',
  ],
  ['a_i', 'a sub i', 'a Index i'],
  ['a_{ij}', 'a sub i j', 'a Index i j'],
  ['x^n', 'x to the power of n', 'x hoch n'],
  ['10^{-3}', '10 to the power of minus 3', '10 hoch minus 3'],
  [
    'e^{i\\pi}+1=0',
    'e to the power of i pi, plus 1, equals, 0',
    'e hoch i pi, plus 1, gleich, 0',
  ],
  ['\\frac{dy}{dx}', 'd y by d x', 'd y nach d x'],
  [
    '\\frac{\\partial f}{\\partial x}',
    'partial f by partial x',
    'partiell f nach partiell x',
  ],
  ["f'(x)", 'f prime of x', 'f Strich von x'],
  ["f''(x)", 'f double prime of x', 'f zwei Strich von x'],
  ['90^\\circ', '90 degrees', '90 Grad'],

  // roots
  ['\\sqrt{x}', 'square root of x', 'Wurzel aus x'],
  [
    '\\sqrt{x+1}',
    'square root of x plus 1, end square root',
    'Wurzel aus x plus 1, Ende Wurzel',
  ],
  ['\\sqrt[3]{x}', 'cube root of x', 'dritte Wurzel aus x'],
  ['\\sqrt[n]{x}', 'nth root of x', 'n-te Wurzel aus x'],

  // big operators and limits
  [
    '\\sum_{i=1}^{n} i',
    'sum from i equals 1 to n, i',
    'Summe von i gleich 1 bis n, i',
  ],
  [
    '\\prod_{k=1}^n k',
    'product from k equals 1 to n, k',
    'Produkt von k gleich 1 bis n, k',
  ],
  [
    '\\int_0^1 f(x)\\,dx',
    'integral from 0 to 1, f of x d x',
    'Integral von 0 bis 1, f von x d x',
  ],
  [
    '\\iint_D f\\,dA',
    'double integral from D, f d A',
    'Doppelintegral von D, f d A',
  ],
  [
    '\\lim_{x \\to \\infty} \\frac{1}{x}',
    'limit as x to infinity, 1 over x',
    'Limes für x gegen unendlich, 1 durch x',
  ],
  [
    '\\max_{x \\in A} f(x)',
    'maximum over x is an element of A, f of x',
    'Maximum über x Element von A, f von x',
  ],
  ['\\log_2 x', 'log base 2, x', 'Logarithmus Basis 2, x'],

  // functions
  [
    '\\sin^2 x + \\cos^2 x = 1',
    'sine squared x plus cosine squared x, equals, 1',
    'Sinus zum Quadrat x plus Kosinus zum Quadrat x, gleich, 1',
  ],
  ['\\exp(x)', 'exponential of x', 'Exponentialfunktion von x'],
  ['\\operatorname{rank}(A)', 'rank of A', 'rank von A'],
  ['n!', 'n factorial', 'n Fakultät'],

  // Greek
  ['\\alpha + \\Omega', 'alpha plus capital omega', 'alpha plus großes omega'],
  [
    '\\varphi = \\Delta \\theta',
    'phi, equals, capital delta theta',
    'phi, gleich, großes delta theta',
  ],

  // sets and logic
  [
    '\\forall x \\in \\mathbb{R}',
    'for all x, is an element of, the real numbers',
    'für alle x, Element von, die reellen Zahlen',
  ],
  [
    '\\exists n \\in \\N',
    'there exists n, is an element of, the natural numbers',
    'es existiert n, Element von, die natürlichen Zahlen',
  ],
  [
    'A \\cup B \\cap C',
    'A union B intersection C',
    'A vereinigt mit B geschnitten mit C',
  ],
  ['A \\subseteq B', 'A, is a subset of, B', 'A, Teilmenge von, B'],
  [
    'x \\notin \\emptyset',
    'x, is not an element of, empty set',
    'x, nicht Element von, leere Menge',
  ],
  [
    '\\{1, 2, 3\\}',
    'left brace 1 comma 2 comma 3 right brace',
    'geschweifte Klammer auf 1 Komma 2 Komma 3 geschweifte Klammer zu',
  ],
  ['A \\Rightarrow B', 'A, implies, B', 'A, daraus folgt, B'],
  ['A \\iff B', 'A, if and only if, B', 'A, genau dann wenn, B'],

  // relations and operators
  ['a \\neq b', 'a, does not equal, b', 'a, ungleich, b'],
  ['a \\leq b', 'a, is less than or equal to, b', 'a, kleiner gleich, b'],
  ['a \\cdot b', 'a times b', 'a mal b'],
  [
    'a \\equiv b \\pmod{n}',
    'a, is equivalent to, b left parenthesis modulo n right parenthesis',
    'a, ist äquivalent zu, b Klammer auf modulo n Klammer zu',
  ],
  [
    'P(A \\mid B)',
    'P left parenthesis A, vertical bar, B right parenthesis',
    'P Klammer auf A, senkrechter Strich, B Klammer zu',
  ],
  ['5\\,\\mathrm{kg}', '5 kilograms', '5 Kilogramm'],
  ['-x \\pm 1', 'minus x plus minus 1', 'minus x plus minus 1'],
  ['f\\colon A \\to B', 'f, colon, A, to, B', 'f, Doppelpunkt, A, gegen, B'],
  [
    'x \\mapsto x^2',
    'x, maps to, x squared',
    'x, wird abgebildet auf, x zum Quadrat',
  ],
  [
    'x \\xrightarrow{f} y',
    'x, right arrow, with f on top, y',
    'x, Pfeil nach rechts, mit f darüber, y',
  ],

  // numbers
  ['3.14', '3.14', '3,14'],
  ['3{,}14', '3.14', '3,14'],
  [
    '\\pi \\approx 3.14159',
    'pi, approximately equals, 3.14159',
    'pi, ungefähr gleich, 3,14159',
  ],
  [
    'x_1, \\ldots, x_n',
    'x sub 1 comma dots comma x sub n',
    'x Index 1 Komma Punkte Komma x Index n',
  ],

  // accents and decorations
  ['\\vec{v}', 'vector v', 'Vektor v'],
  ['\\bar{x}', 'x bar', 'x quer'],
  ['\\dot{x}', 'x dot', 'x Punkt'],
  [
    '\\overrightarrow{AB}',
    'A B, with right arrow on top',
    'A B, mit Pfeil nach rechts darüber',
  ],
  ['\\overline{z}', 'z bar', 'z quer'],
  [
    '\\color{red}{x}',
    'start color red, x, end color red',
    'Anfang Farbe red, x, Ende Farbe red',
  ],

  // delimiters
  [
    '\\left| x \\right|',
    'open vertical bar x close vertical bar',
    'Betrag auf x Betrag zu',
  ],
  ['|x|', 'open vertical bar x close vertical bar', 'Betrag auf x Betrag zu'],
  [
    '|a| + |b|',
    'open vertical bar a close vertical bar plus open vertical bar b close vertical bar',
    'Betrag auf a Betrag zu plus Betrag auf b Betrag zu',
  ],
  [
    '\\{x | x > 0\\}',
    'left brace x, vertical bar, x, is greater than, 0 right brace',
    'geschweifte Klammer auf x, senkrechter Strich, x, größer als, 0 geschweifte Klammer zu',
  ],
  [
    '\\|v\\|',
    'double vertical bar v double vertical bar',
    'doppelter senkrechter Strich v doppelter senkrechter Strich',
  ],
  [
    '\\binom{n}{k}',
    'start binomial, n, choose, k, end binomial',
    'Anfang Binomialkoeffizient, n, über, k, Ende Binomialkoeffizient',
  ],

  // matrices, cases, text, tags
  [
    '\\begin{pmatrix}1&2\\\\3&4\\end{pmatrix}',
    'start 2 by 2 matrix, row 1, 1, 2, row 2, 3, 4, end matrix',
    'Anfang 2 mal 2 Matrix, Zeile 1, 1, 2, Zeile 2, 3, 4, Ende Matrix',
  ],
  [
    'f(x) = \\begin{cases} x & x \\geq 0 \\\\ -x & \\text{else} \\end{cases}',
    'f of x, equals, start cases, case 1, x, if x is greater than or equal to 0, case 2, minus x, else, end cases',
    'f von x, gleich, Anfang Fallunterscheidung, Fall 1, x, falls x größer gleich 0, Fall 2, minus x, else, Ende Fallunterscheidung',
  ],
  [
    '\\text{for all } x > 0',
    'for all x, is greater than, 0',
    'for all x, größer als, 0',
  ],
  [
    'E = mc^2 \\tag{1}',
    'E, equals, m c squared, equation 1',
    'E, gleich, m c zum Quadrat, Gleichung 1',
  ],

  // read wrong or failed before
  ['a \\not= b', 'a, does not equal, b', 'a, ungleich, b'],
  ['x \\not\\in A', 'x, is not an element of, A', 'x, nicht Element von, A'],
  ['\\vdots', 'vertical dots', 'senkrechte Punkte'],
  ['a \\\\ b', 'a, b', 'a, b'],
  [
    '0 \\lt x \\gt 1',
    '0, is less than, x, is greater than, 1',
    '0, kleiner als, x, größer als, 1',
  ],
  ['\\ce{A <=> B}', 'A, equilibrium arrow, B', 'A, Gleichgewichtspfeil, B'],
  [
    'A \\xhookrightarrow{f} B',
    'A, hook right arrow, with f on top, B',
    'A, Hakenpfeil nach rechts, mit f darüber, B',
  ],

  // less common symbols
  [
    'a \\nleq b \\therefore a > b',
    'a, is not less than or equal to, b, therefore, a, is greater than, b',
    'a, nicht kleiner gleich, b, also, a, größer als, b',
  ],
  ['A^\\top', 'A transpose', 'A transponiert'],
  ['\\tg x', 'tangent x', 'Tangens x'],
  ['\\oiint_S F', 'surface integral from S, F', 'Oberflächenintegral von S, F'],
  [
    'f\\colon A \\hookrightarrow B',
    'f, colon, A, hook right arrow, B',
    'f, Doppelpunkt, A, Hakenpfeil nach rechts, B',
  ],
  ['\\operatorname{argmax}_x f', 'arg max over x, f', 'arg max über x, f'],
  [
    'A \\subsetneq B',
    'A, is a proper subset of, B',
    'A, echte Teilmenge von, B',
  ],

  // typed as Unicode
  ['x ≤ 2', 'x, is less than or equal to, 2', 'x, kleiner gleich, 2'],
  ['x → ∞', 'x, right arrow, infinity', 'x, Pfeil nach rechts, unendlich'],
  [
    '∀ x ∈ ℝ',
    'for all x, is an element of, the real numbers',
    'für alle x, Element von, die reellen Zahlen',
  ],
  ['α · β', 'alpha times beta', 'alpha mal beta'],
  ['x² − 1', 'x squared minus 1', 'x zum Quadrat minus 1'],
  ['½ ± ∅', 'one half plus minus empty set', 'ein halb plus minus leere Menge'],
  ['90°', '90 degrees', '90 Grad'],
  ['A ⇒ B', 'A, implies, B', 'A, daraus folgt, B'],

  // environments
  [
    '\\begin{vmatrix} a & b \\\\ c & d \\end{vmatrix}',
    'start 2 by 2 determinant, row 1, a, b, row 2, c, d, end determinant',
    'Anfang 2 mal 2 Determinante, Zeile 1, a, b, Zeile 2, c, d, Ende Determinante',
  ],
  [
    '\\begin{aligned} a &= b + c \\\\ &= d \\end{aligned}',
    'start equations, line 1, a, equals, b plus c, line 2, equals, d, end equations',
    'Anfang Gleichungen, Zeile 1, a, gleich, b plus c, Zeile 2, gleich, d, Ende Gleichungen',
  ],
  [
    '\\begin{array}{cc} a & b \\end{array}',
    'start array, row 1, a, b, end array',
    'Anfang Tabelle, Zeile 1, a, b, Ende Tabelle',
  ],
  [
    '\\sum_{\\substack{i<n \\\\ j<m}} a',
    'sum from i is less than n and j is less than m, a',
    'Summe von i kleiner als n und j kleiner als m, a',
  ],

  // labels, evaluation bars and fonts
  [
    'a \\stackrel{def}{=} b',
    'a, equals, with def on top, b',
    'a, gleich, mit def darüber, b',
  ],
  [
    '\\underbrace{a+b}_{n}',
    'start underbrace, a plus b, end underbrace, with n underneath',
    'Anfang Klammer unten, a plus b, Ende Klammer unten, mit n darunter',
  ],
  [
    '\\left. f \\right|_{x=0}',
    'f, evaluated at x equals 0',
    'f, ausgewertet bei x gleich 0',
  ],
  ['F \\Big|_a^b', 'F, evaluated from a to b', 'F, ausgewertet von a bis b'],
  [
    '\\mathbf{v} + \\mathcal{L} + \\mathfrak{g}',
    'bold v plus script L plus fraktur g',
    'fett v plus Schreibschrift L plus Fraktur g',
  ],

  // chemistry
  ['\\ce{CuSO4 * 5H2O}', 'Cu S O 4 times 5 H 2 O', 'Cu S O 4 mal 5 H 2 O'],
  ['\\ce{H2O}', 'H 2 O', 'H 2 O'],
]

// How people read maths: markers and pauses only where they are needed
const rules: [string, string, string][] = [
  // fractions by name, like ClearSpeak: denominators up to 10, numerators
  // below 20, the number itself is spoken by the voice
  ['\\frac{3}{8}', '3 eighths', '3 Achtel'],
  ['\\frac{1}{3}', 'one third', 'ein Drittel'],
  ['\\frac{3}{2}', '3 halves', '3 Halbe'],
  ['\\frac{19}{10}', '19 tenths', '19 Zehntel'],
  ['\\frac{12}{17}', '12 over 17', '12 durch 17'],
  ['\\frac{20}{3}', '20 over 3', '20 durch 3'],

  // roots with an ordinal number
  ['\\sqrt[5]{x}', 'fifth root of x', 'fünfte Wurzel aus x'],
  ['\\sqrt[17]{x}', '17th root of x', 'Wurzel mit Index 17 aus x'],
  ['\\sqrt[22]{x}', '22nd root of x', 'Wurzel mit Index 22 aus x'],
  [
    '\\sqrt[4]{x+1}',
    'fourth root of x plus 1, end root',
    'vierte Wurzel aus x plus 1, Ende Wurzel',
  ],

  // KaTeX aliases need only one entry in the dictionary: \\le is \\leq
  [
    'a \\le b \\land \\lnot c \\gets \\varnothing',
    'a, is less than or equal to, b and not c, left arrow, empty set',
    'a, kleiner gleich, b und nicht c, Pfeil nach links, leere Menge',
  ],

  // long numbers are not rounded
  [
    '3.14159265358979323846',
    '3.14159265358979323846',
    '3,14159265358979323846',
  ],

  // units, after a number in \\pu or with a space, Intl.NumberFormat reads the
  // everyday units, others (N, kJ, K, powers) stay symbols
  [
    '\\pu{9,81 m/s^2}',
    '9.81 m slash s squared',
    '9,81 m Schrägstrich s zum Quadrat',
  ],
  ['\\pu{1 kg}', '1 kilogram', '1 Kilogramm'],
  [
    '\\pu{9.81 m s^-2}',
    '9.81 m s to the power of minus 2',
    '9,81 m s hoch minus 2',
  ],
  ['\\pu{123 kJ/mol}', '123 kJ slash mol', '123 kJ Schrägstrich mol'],
  ['\\pu{21.5 °C}', '21.5 degrees Celsius', '21,5 Grad Celsius'],
  ['\\pu{3 m s^-1}', '3 meters per second', '3 Meter pro Sekunde'],
  ['\\pu{5 N m}', '5 N m', '5 N m'],
  ['\\pu{300 K}', '300 K', '300 K'],
  [
    'c = 3 \\cdot 10^8\\,\\mathrm{m/s}',
    'c, equals, 3 times 10 to the power of 8 meters per second',
    'c, gleich, 3 mal 10 hoch 8 Meter pro Sekunde',
  ],
  ['300\\,\\mathrm{K}', '300 K', '300 K'],
  ['\\ce{2N2}', '2 N 2', '2 N 2'],
  ['1^\\circ + 90^\\circ', '1 degree plus 90 degrees', '1 Grad plus 90 Grad'],

  // markers only when needed
  [
    'e^{i\\pi} + 1 = 0',
    'e to the power of i pi, plus 1, equals, 0',
    'e hoch i pi, plus 1, gleich, 0',
  ],
  ['x_{ij}', 'x sub i j', 'x Index i j'],
  [
    'e^{-x^2}',
    'e, start superscript, minus x squared, end superscript',
    'e, Anfang Exponent, minus x zum Quadrat, Ende Exponent',
  ],
  [
    '\\frac{1}{2} + \\frac{3}{4}',
    'one half plus 3 quarters',
    'ein halb plus 3 Viertel',
  ],
  [
    '\\frac{a}{b} + \\frac{5}{7}',
    'a over b plus 5 sevenths',
    'a durch b plus 5 Siebtel',
  ],

  // pauses only at boundaries
  ['a + b = c', 'a plus b, equals, c', 'a plus b, gleich, c'],
  [
    '\\sum_{i=1}^{n} i',
    'sum from i equals 1 to n, i',
    'Summe von i gleich 1 bis n, i',
  ],
  [
    '\\frac{a+b}{2}',
    'start fraction, a plus b, divided by, 2, end fraction',
    'Anfang Bruch, a plus b, geteilt durch, 2, Ende Bruch',
  ],

  // common readings for accents
  [
    '\\vec{v} + \\bar{x} + \\hat{H} + \\dot{x}',
    'vector v plus x bar plus H hat plus x dot',
    'Vektor v plus x quer plus H Dach plus x Punkt',
  ],
  ['\\overline{z}', 'z bar', 'z quer'],
  ['\\vec{AB}', 'A B, with vector on top', 'A B, mit Vektorpfeil darüber'],

  // chemistry
  ['\\ce{2H2O}', '2 H 2 O', '2 H 2 O'],
  ['\\ce{Zn^2+}', 'Zn 2 plus', 'Zn 2 plus'],
  ['\\ce{SO4^2-}', 'S O 4, 2 minus', 'S O 4, 2 minus'],

  // operators in context
  ['\\nabla \\cdot \\vec{E}', 'del dot vector E', 'Nabla Punkt Vektor E'],
  ['\\nabla \\times \\vec{B}', 'del cross vector B', 'Nabla Kreuz Vektor B'],

  // derivatives
  ['\\frac{dy}{dx}', 'd y by d x', 'd y nach d x'],
  ['\\frac{d}{dx} f', 'd by d x, f', 'd nach d x, f'],
  [
    '\\frac{\\partial f}{\\partial x}',
    'partial f by partial x',
    'partiell f nach partiell x',
  ],

  // numbers: the point groups thousands only if it is repeated or followed by
  // a decimal comma, a single 1.000 stays a decimal number (LaTeX)
  ['1.000.000', '1000000', '1000000'],
  ['12.345{,}67', '12345.67', '12345,67'],
  ['1.000', '1.000', '1,000'],
  ['1\\,000\\,000', '1000000', '1000000'],
  ['x = 3.', 'x, equals, 3', 'x, gleich, 3'],
  // other ways to write a decimal comma
  [
    '3\\mathord{,}14 + 3,\\!14 + 3\\text{,}14',
    '3.14 plus 3.14 plus 3.14',
    '3,14 plus 3,14 plus 3,14',
  ],
  [
    '\\{,\\}',
    'left brace comma right brace',
    'geschweifte Klammer auf Komma geschweifte Klammer zu',
  ],

  // named functions, a comma within a function of one argument is a decimal
  // comma, f(3,14) has two arguments
  ['\\sin(x)', 'sine of x', 'Sinus von x'],
  ['\\sin x', 'sine x', 'Sinus x'],
  ['\\sin(3,14159)', 'sine of 3.14159', 'Sinus von 3,14159'],
  ['\\cos(2x)', 'cosine of 2 x', 'Kosinus von 2 x'],
  ['\\sin^2(x)', 'sine squared of x', 'Sinus zum Quadrat von x'],
  ['\\max(a, b)', 'maximum of a comma b', 'Maximum von a Komma b'],
  ['f(3,14)', 'f of 3 comma 14', 'f von 3 Komma 14'],
  [
    '\\sin(\\omega t + \\varphi)',
    'sine of left parenthesis omega t plus phi right parenthesis',
    'Sinus von Klammer auf omega t plus phi Klammer zu',
  ],

  // function application, only f, g and h
  ['f(x) = x^2', 'f of x, equals, x squared', 'f von x, gleich, x zum Quadrat'],
  ["f'(x)", 'f prime of x', 'f Strich von x'],
  ['g(x, y)', 'g of x comma y', 'g von x Komma y'],
  [
    'a(b+c)',
    'a left parenthesis b plus c right parenthesis',
    'a Klammer auf b plus c Klammer zu',
  ],

  // every function gets "von", the parentheses are read if the argument is
  // not short, they show where it ends
  [
    'f(x+1)',
    'f of left parenthesis x plus 1 right parenthesis',
    'f von Klammer auf x plus 1 Klammer zu',
  ],
  [
    '\\sin\\left(\\frac{x}{2}\\right)',
    'sine of left parenthesis x over 2 right parenthesis',
    'Sinus von Klammer auf x durch 2 Klammer zu',
  ],
  ['\\ln\\left(x\\right)', 'natural log of x', 'natürlicher Logarithmus von x'],
  [
    'f(g(x))',
    'f of left parenthesis g of x right parenthesis',
    'f von Klammer auf g von x Klammer zu',
  ],
  // a variable or a function: \mathop marks a function, so do primes, \circ
  // and \colon within the same formula, everything else stays neutral
  [
    '\\mathop{a}(b+c)',
    'a of left parenthesis b plus c right parenthesis',
    'a von Klammer auf b plus c Klammer zu',
  ],
  ["u'(x) = 2x", 'u prime of x, equals, 2 x', 'u Strich von x, gleich, 2 x'],
  [
    'u \\circ v = u(v)',
    'u composed with v, equals, u of v',
    'u verkettet mit v, gleich, u von v',
  ],
  [
    'u\\colon A \\to B, \\; u(a)',
    'u, colon, A, to, B comma u of a',
    'u, Doppelpunkt, A, gegen, B Komma u von a',
  ],
  [
    'a(b+c) = ab + ac',
    'a left parenthesis b plus c right parenthesis, equals, a b plus a c',
    'a Klammer auf b plus c Klammer zu, gleich, a b plus a c',
  ],
]

for (const [tex, english, german] of [...cases, ...rules]) {
  test(tex, () => {
    // display mode, because \tag needs it
    const settings = { displayMode: true }
    assert.equal(renderA11yString(tex, settings, 'en'), english)
    assert.equal(renderA11yString(tex, settings, 'de-DE'), german)
  })
}

// Larger formulas, it is enough that they are read without any LaTeX
const smoke = [
  '\\ce{CO2 + H2O -> H2CO3}',
  '\\ce{2H2 + O2 -> 2H2O}',
  'x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}',
  '\\begin{aligned} a &= b + c \\\\ &= d \\end{aligned}',
  '\\oint_C \\vec{F} \\cdot d\\vec{r}',
  '\\nabla \\times \\vec{E} = -\\frac{\\partial \\vec{B}}{\\partial t}',
  '\\det \\begin{vmatrix} a & b \\\\ c & d \\end{vmatrix} = ad - bc',
  '\\overbrace{1 + \\cdots + 1}^{n}',
  '\\cancel{x} \\boxed{y}',
  '\\hat{\\theta} \\sim \\mathcal{N}(\\mu, \\sigma^2)',
  '\\lfloor x \\rfloor + \\lceil y \\rceil',
  '\\vec{a} \\perp \\vec{b}',
  '\\widehat{ABC} = 90^\\circ',
  '\\mathbf{A}^{-1} \\mathbf{A} = \\mathbf{I}',
]

for (const tex of smoke) {
  test('no LaTeX left: ' + tex, () => {
    for (const lang of ['en', 'de']) {
      const text = renderA11yString(tex, {}, lang)
      assert.ok(!text.includes('\\'), `${lang}: ${text}`)
    }
  })
}

test('course macros are used', () => {
  const macros = { '\\RR': '\\mathbb{R}' }
  assert.equal(renderA11yString('\\RR', { macros }, 'en'), 'the real numbers')
})

test('unknown languages fall back to English', () => {
  assert.equal(renderA11yString('a = b', {}, 'xx'), 'a, equals, b')
})

test('German has the same entries as English', () => {
  for (const key of Object.keys(en) as (keyof typeof en)[]) {
    if (typeof en[key] === 'object') {
      assert.deepEqual(
        Object.keys(de[key]).sort(),
        Object.keys(en[key]).sort(),
        key
      )
    }
  }
})

test('works without Intl.PluralRules and unit formatting (KaiOS)', () => {
  const { PluralRules, NumberFormat } = Intl
  // @ts-ignore
  delete Intl.PluralRules
  // @ts-ignore
  Intl.NumberFormat = function (locale, options) {
    if (options?.style === 'unit') throw new RangeError('no units')
    return new NumberFormat(locale, options)
  }
  try {
    assert.equal(renderA11yString('\\pu{2 h}', {}, 'de'), '2 h')
    assert.equal(renderA11yString('90^\\circ', {}, 'en'), '90 degrees')
    assert.equal(renderA11yString('\\frac{3}{8}', {}, 'en'), '3 eighths')
    assert.equal(renderA11yString('\\sqrt[17]{x}', {}, 'en'), '17th root of x')
  } finally {
    Intl.PluralRules = PluralRules
    Intl.NumberFormat = NumberFormat
  }
})
