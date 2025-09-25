export function getMode(name: string): string {
  return 'ace/mode/' + (modes[name] || 'text')
}

const modes: {
  [key: string]: string
} = {
  // !--------------------------------------
  // ! A
  // !--------------------------------------

  abap: 'abap',
  'sap-abap': 'abap',
  /* ------------------------------------- */
  abc: 'abc',
  /* ------------------------------------- */
  actionscript: 'actionscript',
  as: 'actionscript',
  /* ------------------------------------- */
  ada: 'ada',
  adb: 'ada',
  alda: 'alda',
  /* ------------------------------------- */
  apache: 'apache_conf',
  apacheconf: 'apache_conf',
  apache_conf: 'apache_conf',
  htaccess: 'apache_conf',
  htgroups: 'apache_conf',
  htpasswd: 'apache_conf',
  /* ------------------------------------- */
  apex: 'apex',
  cls: 'apex',
  trigger: 'apex',
  tgr: 'apex',
  /* ------------------------------------- */
  applescript: 'applescript',
  oascript: 'applescript',
  /* ------------------------------------- */
  aql: 'aql',
  /* ------------------------------------- */
  arduino: 'c_cpp',
  ino: 'cpp',
  /* ------------------------------------- */
  armasm: 'assembly_arm32',
  arm: 'assembly_arm32',
  assembly_arm32: 'assembly_arm32',
  arm32: 'assembly_arm32',
  /* ------------------------------------- */
  asl: 'asl',
  dsl: 'asl',
  'asl.json': 'asl',
  /* ------------------------------------- */
  asciidoc: 'asciidoc',
  adoc: 'asciidoc',
  /* ------------------------------------- */
  aspectj: 'java',
  /* ------------------------------------- */
  astro: 'astro',
  /* ------------------------------------- */
  autohotkey: 'autohotkey',
  ahk: 'autohotkey',
  /* ------------------------------------- */
  avrasm: 'assembly_x86',
  asm: 'assembly_x86',
  a: 'assembly_x86',

  // !--------------------------------------
  // ! B
  // !--------------------------------------

  bash: 'sh',
  sh: 'sh',
  /* ------------------------------------- */
  basic: 'vbscript',
  bibtex: 'bibtex',
  bib: 'bibtex',

  // !--------------------------------------
  // ! C
  // !--------------------------------------

  c: 'c_cpp',
  h: 'c_cpp',
  /* ------------------------------------- */
  c9search: 'c9search',
  c9search_results: 'c9search',
  /* ------------------------------------- */
  cirru: 'cirru',
  /* ------------------------------------- */
  clojure: 'clojure',
  clj: 'clojure',
  cljs: 'clojure',
  edn: 'clojure',
  /* ------------------------------------- */
  cmake: 'makefile',
  'cmake.in': 'makefile',
  /* ------------------------------------- */
  cobol: 'cobol',
  cbl: 'cobol',
  cob: 'cobol',
  /* ------------------------------------- */
  coffeescript: 'coffee',
  coffee: 'coffee',
  cakefile: 'coffee',
  cf: 'coffee',
  cson: 'coffee',
  iced: 'coffee',
  /* ------------------------------------- */
  coldfusion: 'coldfusion',
  cfm: 'coldfusion',
  /* ------------------------------------- */
  cpp: 'c_cpp',
  cc: 'c_cpp',
  'c++': 'c_cpp',
  'h++': 'c_cpp',
  hpp: 'c_cpp',
  hh: 'c_cpp',
  hxx: 'c_cpp',
  cxx: 'c_cpp',
  /* ------------------------------------- */
  clue: 'clue',
  /* ------------------------------------- */
  crmsh: 'sh',
  crm: 'sh',
  pcmk: 'sh',
  /* ------------------------------------- */
  crystal: 'crystal',
  cr: 'crystal',
  /* ------------------------------------- */
  csharp: 'csharp',
  cs: 'csharp',
  'c#': 'csharp',
  /* ------------------------------------- */
  csound_document: 'csound_document',
  csd: 'csound_document',
  csound_orchestra: 'csound_orchestra',
  orc: 'csound_orchestra',
  csound_score: 'csound_score',
  sco: 'csound_score',
  /* ------------------------------------- */
  csp: 'csp',
  /* ------------------------------------- */
  css: 'css',
  /* ------------------------------------- */
  csv: 'csv',
  /* ------------------------------------- */
  curly: 'curly',
  /* ------------------------------------- */
  cuttlefish: 'cuttlefish',

  // !--------------------------------------
  // ! D
  // !--------------------------------------

  d: 'd',
  di: 'd',
  /* ------------------------------------- */
  dart: 'dart',
  /* ------------------------------------- */
  delphi: 'pascal',
  dpr: 'pascal',
  dfm: 'pascal',
  pas: 'pascal',
  pascal: 'pascal',
  /* ------------------------------------- */
  diff: 'diff',
  patch: 'diff',
  /* ------------------------------------- */
  django: 'django',
  jinja: 'django',
  /* ------------------------------------- */
  dockerfile: 'dockerfile',
  docker: 'dockerfile',
  /* ------------------------------------- */
  dos: 'batchfile',
  bat: 'batchfile',
  cmd: 'batchfile',
  batchfile: 'batchfile',
  /* ------------------------------------- */
  prql: 'prql',
  /* ------------------------------------- */
  drools: 'drools',
  drl: 'drools',
  /* ------------------------------------- */
  dot: 'dot',

  // !--------------------------------------
  // ! E
  // !--------------------------------------

  edifact: 'edifact',
  edi: 'edifact',
  /* ------------------------------------- */
  eiffel: 'eiffel',
  e: 'eiffel',
  ge: 'eiffel',
  /* ------------------------------------- */
  ejs: 'ejs',
  /* ------------------------------------- */
  elixir: 'elixir',
  ex: 'elixir',
  exs: 'elixir',
  /* ------------------------------------- */
  elm: 'elm',
  /* ------------------------------------- */
  erlang: 'erlang',
  erl: 'erlang',
  hrl: 'erlang',
  /* ------------------------------------- */
  eex: 'html_elixir',

  // !--------------------------------------
  // ! F
  // !--------------------------------------

  forth: 'forth',
  frt: 'forth',
  ldr: 'forth',
  fth: 'forth',
  '4th': 'forth',
  /* ------------------------------------- */
  fortran: 'fortran',
  f90: 'fortran',
  f95: 'fortran',
  f: 'fortran',
  /* ------------------------------------- */
  flix: 'flix',
  /* ------------------------------------- */
  fsharp: 'fsharp',
  fsi: 'fsharp',
  fs: 'fsharp',
  mli: 'fsharp',
  fsx: 'fsharp',
  fsscript: 'fsharp',
  'f#': 'fsharp',
  /* ------------------------------------- */
  fsl: 'fsl',
  /* ------------------------------------- */
  ftl: 'ftl',

  // !--------------------------------------
  // ! G
  // !--------------------------------------

  gcode: 'gcode',
  nc: 'gcode',
  /* ------------------------------------- */
  gherkin: 'gherkin',
  feature: 'gherkin',
  /* ------------------------------------- */
  gitignore: 'gitignore',
  '.gitignore': 'gitignore',
  /* ------------------------------------- */
  glsl: 'glsl',
  frag: 'glsl',
  vert: 'glsl',
  /* ------------------------------------- */
  gobstones: 'gobstones',
  /* ------------------------------------- */
  go: 'golang',
  golang: 'golang',
  /* ------------------------------------- */
  graphqlschema: 'graphqlschema',
  gql: 'graphqlschema',
  /* ------------------------------------- */
  groovy: 'groovy',

  // !--------------------------------------
  // ! H
  // !--------------------------------------

  haml: 'haml',
  /* ------------------------------------- */
  handlebars: 'handlebars',
  hbs: 'handlebars',
  'html.hbs': 'handlebars',
  'html.handlebars': 'handlebars',
  htmlbars: 'handlebars',
  tpl: 'handlebars',
  mustache: 'handlebars',
  /* ------------------------------------- */
  haskell: 'haskell',
  hs: 'haskell',
  /* ------------------------------------- */
  haskell_cabal: 'haskell_cabal',
  cabal: 'haskell_cabal',
  /* ------------------------------------- */
  haxe: 'haxe',
  hx: 'haxe',
  /* ------------------------------------- */
  hjson: 'hjson',
  /* ------------------------------------- */
  html_elixir: 'html_elixir',
  'html.eex': 'html_elixir',
  /* ------------------------------------- */
  html_ruby: 'html_ruby',
  erb: 'html_ruby',
  'html.erb': 'html_ruby',
  /* ------------------------------------- */
  hy: 'lisp',
  hylang: 'lisp',

  // !--------------------------------------
  // ! I
  // !--------------------------------------

  ini: 'ini',
  conf: 'ini',
  cfg: 'ini',
  prefs: 'ini',
  /* ------------------------------------- */
  // (makefile variants defined in section M)
  /* ------------------------------------- */
  io: 'io',
  ion: 'ion',

  // !--------------------------------------
  // ! J
  // !--------------------------------------

  jack: 'jack',
  /* ------------------------------------- */
  jade: 'jade',
  pug: 'jade',
  /* ------------------------------------- */
  java: 'java',
  jsp: 'jsp',
  /* ------------------------------------- */
  javascript: 'javascript',
  js: 'javascript',
  jsm: 'javascript',
  jsx: 'jsx',
  cjs: 'javascript',
  mjs: 'javascript',
  mts: 'typescript',
  cts: 'typescript',
  str: 'typescript',
  /* ------------------------------------- */
  jexl: 'jexl',
  /* ------------------------------------- */
  jsdoc: 'jsdoc',
  jsdoc_comment: 'jsdoc',
  /* ------------------------------------- */
  json: 'json',
  /* ------------------------------------- */
  json5: 'json5',
  /* ------------------------------------- */
  jsoniq: 'jsoniq',
  jq: 'jsoniq',
  /* ------------------------------------- */
  jssm: 'jssm',
  jssm_state: 'jssm',
  /* ------------------------------------- */
  julia: 'julia',
  jl: 'julia',

  // !--------------------------------------
  // ! K
  // !--------------------------------------

  kotlin: 'kotlin',
  kot: 'kotlin',
  kt: 'kotlin',
  kts: 'kotlin',

  // !--------------------------------------
  // ! L
  // !--------------------------------------

  latex: 'latex',
  ltx: 'latex',
  tex: 'tex',
  // duplicate bib mapping omitted to avoid conflict (bib -> bibtex above)
  /* ------------------------------------- */
  latte: 'latte',
  /* ------------------------------------- */
  less: 'less',
  /* ------------------------------------- */
  liquid: 'liquid',
  /* ------------------------------------- */
  lisp: 'lisp',
  /* ------------------------------------- */
  livescript: 'livescript',
  ls: 'livescript',
  /* ------------------------------------- */
  logiql: 'logiql',
  lql: 'logiql',
  /* ------------------------------------- */
  log: 'log',
  /* ------------------------------------- */
  logtalk: 'logtalk',
  lgt: 'logtalk',
  /* ------------------------------------- */
  lsl: 'lsl',
  /* ------------------------------------- */
  lua: 'lua',
  /* ------------------------------------- */
  luapage: 'luapage',
  lp: 'luapage',
  /* ------------------------------------- */
  lucene: 'lucene',

  // !--------------------------------------
  // ! M
  // !--------------------------------------

  makefile: 'makefile',
  make: 'makefile',
  mak: 'makefile',
  mk: 'makefile',
  gnumakefile: 'makefile',
  ocamlmakefile: 'makefile',
  /* ------------------------------------- */
  markdown: 'markdown',
  md: 'markdown',
  mkd: 'markdown',
  mkdown: 'markdown',
  /* ------------------------------------- */
  mask: 'mask',
  /* ------------------------------------- */
  matlab: 'matlab',
  /* ------------------------------------- */
  maze: 'maze',
  mz: 'maze',
  /* ------------------------------------- */
  mediawiki: 'mediawiki',
  wiki: 'mediawiki',
  /* ------------------------------------- */
  mel: 'mel',
  /* ------------------------------------- */
  mipsasm: 'mips',
  mips: 'mips',
  /* ------------------------------------- */
  mixal: 'mixal',
  /* ------------------------------------- */
  mushcode: 'mushcode',
  mc: 'mushcode',
  mush: 'mushcode',
  /* ------------------------------------- */
  mysql: 'mysql',

  // !--------------------------------------
  // ! N
  // !--------------------------------------

  nasal: 'nasal',
  /* ------------------------------------- */
  nginx: 'nginx',
  nginxconf: 'nginx',
  nas: 'nasal',
  /* ------------------------------------- */
  nim: 'nim',
  /* ------------------------------------- */
  nix: 'nix',
  nixos: 'nix',
  /* ------------------------------------- */
  nsis: 'nsis',
  nsh: 'nsis',
  /* ------------------------------------- */
  nunjucks: 'nunjucks',
  nunjs: 'nunjucks',
  nj: 'nunjucks',
  njk: 'nunjucks',
  // makefile variants removed here (kept in section M)
  // ! O
  // !--------------------------------------

  objectivec: 'objectivec',
  mm: 'objectivec',
  objc: 'objectivec',
  'obj-c': 'objectivec',
  'obj-c++': 'objectivec',
  'objective-c++': 'objectivec',
  /* ------------------------------------- */
  ocaml: 'ocaml',
  ml: 'ocaml',
  /* ------------------------------------- */
  odin: 'odin',
  /* ------------------------------------- */
  openscad: 'scad',
  scad: 'scad',

  // !--------------------------------------
  // ! P
  // !--------------------------------------
  partiql: 'partiql',
  pql: 'partiql',
  /* ------------------------------------- */
  perl: 'perl',
  pl: 'perl',
  pm: 'perl',
  /* ------------------------------------- */
  pgsql: 'pgsql',
  postgres: 'pgsql',
  postgresql: 'pgsql',
  /* ------------------------------------- */
  php: 'php',
  inc: 'php',
  phtml: 'php',
  shtml: 'php',
  php3: 'php',
  php4: 'php',
  php5: 'php',
  phps: 'php',
  phpt: 'php',
  aw: 'php',
  ctp: 'php',
  module: 'php',
  /* ------------------------------------- */
  php_laravel_blade: 'php_laravel_blade',
  'blade.php': 'php_laravel_blade',
  /* ------------------------------------- */
  pig: 'pig',
  /* ------------------------------------- */
  plain_text: 'plain_text',
  text: 'text',
  txt: 'text',
  /* ------------------------------------- */
  plsql: 'plsql',
  /* ------------------------------------- */
  powershell: 'powershell',
  pwsh: 'powershell',
  ps: 'powershell',
  ps1: 'powershell',
  /* ------------------------------------- */
  praat: 'praat',
  praatscript: 'praat',
  psc: 'praat',
  proc: 'praat',
  /* ------------------------------------- */
  prisma: 'prisma',
  /* ------------------------------------- */
  processing: 'c_cpp',
  pde: 'c_cpp',
  /* ------------------------------------- */
  prolog: 'prolog',
  plg: 'prolog',
  /* ------------------------------------- */
  properties: 'properties',
  /* ------------------------------------- */
  protobuf: 'protobuf',
  /* ------------------------------------- */
  puppet: 'puppet',
  pp: 'puppet',
  /* ------------------------------------- */
  purebasic: 'vbscript',
  pb: 'vbscript',
  pbi: 'vbscript',
  /* ------------------------------------- */
  python: 'python',
  py: 'python',
  gyp: 'python',
  ipython: 'python',
  pyi: 'python',

  // !--------------------------------------
  // ! Q
  // !--------------------------------------

  qml: 'qml',
  qt: 'qml',

  // !--------------------------------------
  // ! R
  // !--------------------------------------

  r: 'r',
  /* ------------------------------------- */
  raku: 'raku',
  rakumod: 'raku',
  rakutest: 'raku',
  p6: 'raku',
  pl6: 'raku',
  pm6: 'raku',
  /* ------------------------------------- */
  razor: 'razor',
  /* ------------------------------------- */
  rdoc: 'rdoc',
  /* ------------------------------------- */
  red: 'red',
  /* ------------------------------------- */
  redshift: 'redshift',
  /* ------------------------------------- */
  rhtml: 'rhtml',
  /* ------------------------------------- */
  robot: 'robot',
  resource: 'robot',
  /* ------------------------------------- */
  rst: 'rst',
  rest: 'rst',
  /* ------------------------------------- */
  ruby: 'ruby',
  gemspec: 'ruby',
  irb: 'ruby',
  podspec: 'ruby',
  guardfile: 'ruby',
  rakefile: 'ruby',
  gemfile: 'ruby',
  rb: 'ruby',
  thor: 'ruby',
  /* ------------------------------------- */
  rust: 'rust',
  rs: 'rust',

  // !--------------------------------------
  // ! S
  // !--------------------------------------

  sac: 'sac',
  /* ------------------------------------- */
  sass: 'sass',
  /* ------------------------------------- */
  scala: 'scala',
  sbt: 'scala',
  /* ------------------------------------- */
  scheme: 'scheme',
  scm: 'scheme',
  sm: 'scheme',
  rkt: 'scheme',
  oak: 'scheme',
  logic: 'logiql',
  /* ------------------------------------- */
  scrypt: 'scrypt',
  /* ------------------------------------- */
  scss: 'scss',
  /* ------------------------------------- */
  shell: 'sh',
  console: 'sh',
  shellsession: 'sh',
  /* ------------------------------------- */
  sjs: 'sjs',
  /* ------------------------------------- */
  slim: 'slim',
  skim: 'slim',
  /* ------------------------------------- */
  smarty: 'smarty',
  /* ------------------------------------- */
  smithy: 'smithy',
  /* ------------------------------------- */
  soy: 'soy',
  soy_template: 'soy',
  /* ------------------------------------- */
  space: 'space',
  /* ------------------------------------- */
  sparql: 'sparql',
  rq: 'sparql',
  /* ------------------------------------- */
  sql: 'sql',
  /* ------------------------------------- */
  sqlserver: 'sqlserver',
  /* ------------------------------------- */
  stylus: 'stylus',
  styl: 'stylus',
  /* ------------------------------------- */
  swift: 'swift',
  /* ------------------------------------- */
  // scad duplicate removed; defined earlier near openscad
  /* ------------------------------------- */
  snippets: 'snippets',

  // !--------------------------------------
  // ! T
  // !--------------------------------------

  tcl: 'tcl',
  tk: 'tcl',
  /* ------------------------------------- */
  terraform: 'terraform',
  tf: 'terraform',
  tfvars: 'terraform',
  terragrunt: 'terraform',
  /* ------------------------------------- */
  textile: 'textile',
  /* ------------------------------------- */
  turtle: 'turtle',
  ttl: 'turtle',
  /* ------------------------------------- */
  twig: 'twig',
  swig: 'twig',
  craftcms: 'twig',
  /* ------------------------------------- */
  typescript: 'typescript',
  ts: 'typescript',
  // mts/cts/str defined earlier with JS block
  /* ------------------------------------- */
  tsv: 'tsv',
  /* ------------------------------------- */
  tsx: 'tsx',

  // !--------------------------------------
  // ! V
  // !--------------------------------------

  vala: 'vala',
  /* ------------------------------------- */
  vbnet: 'vbscript',
  vb: 'vbscript',
  /* ------------------------------------- */
  vbscript: 'vbscript',
  vbs: 'vbscript',
  /* ------------------------------------- */
  velocity: 'velocity',
  vm: 'velocity',
  /* ------------------------------------- */
  verilog: 'verilog',
  sv: 'verilog',
  svh: 'verilog',
  v: 'verilog',
  vh: 'verilog',
  /* ------------------------------------- */
  vhdl: 'vhdl',
  vhd: 'vhdl',
  /* ------------------------------------- */
  visualforce: 'visualforce',
  vfp: 'visualforce',
  component: 'visualforce',
  page: 'visualforce',
  /* ------------------------------------- */
  vue: 'vue',

  // !--------------------------------------
  // ! W
  // !--------------------------------------

  wollok: 'wollok',
  wlk: 'wollok',
  wpgm: 'wollok',
  wtest: 'wollok',

  // !--------------------------------------
  // ! X
  // !--------------------------------------

  x86asm: 'assembly_x86',
  /* ------------------------------------- */
  xml: 'xml',
  atom: 'xml',
  html: 'html',
  plist: 'xml',
  rss: 'xml',
  wdsl: 'xml',
  svg: 'svg',
  wsf: 'xml',
  xbl: 'xml',
  xhtml: 'html',
  xjb: 'xml',
  xsd: 'xml',
  xsl: 'xml',
  htm: 'html',

  we: 'html',
  wpy: 'html',
  mathml: 'xml',
  mml: 'xml',
  rdf: 'xml',
  xaml: 'xml',
  xul: 'xml',
  /* ------------------------------------- */
  xquery: 'xquery',
  xpath: 'xquery',
  xq: 'xquery',

  // !--------------------------------------
  // ! Y
  // !--------------------------------------

  yaml: 'yaml',
  yml: 'yaml',

  // !--------------------------------------
  // ! Z
  // !--------------------------------------

  zeek: 'zeek',
  bro: 'zeek',

  zig: 'zig',
}
