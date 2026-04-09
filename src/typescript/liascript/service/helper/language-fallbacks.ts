const LANGUAGE_FALLBACKS: Record<string, string[]> = {
  // Germanic
  de: ['nl'],
  nl: ['de'],
  af: ['nl', 'de'],
  en: ['de', 'nl'],
  fy: ['nl', 'de'],
  lb: ['de', 'nl', 'fr'],
  yi: ['de', 'nl'],
  da: ['no', 'sv', 'de'],
  no: ['da', 'sv', 'de'],
  sv: ['no', 'da', 'de'],
  is: ['no', 'da', 'sv'],
  fo: ['da', 'no'],

  // Romance
  fr: ['it', 'es', 'pt'],
  it: ['es', 'fr', 'pt'],
  es: ['pt', 'it', 'fr'],
  pt: ['es', 'it', 'fr'],
  ca: ['es', 'fr', 'it'],
  gl: ['pt', 'es', 'it'],
  ro: ['it', 'fr', 'es'],
  rm: ['it', 'de', 'fr'],
  oc: ['fr', 'ca', 'es', 'it'],
  co: ['it', 'fr', 'es'],
  sc: ['it', 'es', 'fr'],

  // West Slavic
  pl: ['cs', 'sk', 'de'],
  cs: ['sk', 'pl', 'de'],
  sk: ['cs', 'pl', 'de'],
  sl: ['hr', 'sr', 'cs', 'sk'],

  // South Slavic
  hr: ['sr', 'bs', 'sl', 'mk'],
  sr: ['hr', 'bs', 'mk', 'bg', 'ru'],
  bs: ['hr', 'sr', 'sl'],
  mk: ['bg', 'sr', 'hr', 'ru'],
  bg: ['mk', 'sr', 'ru', 'hr'],

  // East Slavic
  ru: ['uk', 'bg', 'sr'],
  uk: ['ru', 'bg', 'sr'],
  be: ['ru', 'uk', 'pl'],

  // Baltic
  lt: ['lv', 'pl', 'ru'],
  lv: ['lt', 'ru', 'pl'],

  // Celtic
  ga: ['gd', 'cy'],
  gd: ['ga', 'cy'],
  cy: ['ga', 'gd'],
  br: ['fr', 'cy'],
  gv: ['ga', 'gd'],
  kw: ['cy', 'br'],

  // Hellenic / Albanian / Armenian
  el: ['it', 'bg'],
  sq: ['mk', 'hr', 'it'],
  hy: ['ru', 'el'],

  // Uralic
  fi: ['et', 'sv'],
  et: ['fi', 'lv', 'sv'],
  hu: ['de', 'sk', 'cs'],
  se: ['fi', 'no', 'sv'],

  // Turkic in Europe / nearby
  tr: ['bg', 'sr', 'el'],
  az: ['tr', 'ru'],

  // Caucasus / nearby European coverage cases
  ab: ['ru', 'ka'],
  av: ['ru', 'ka'],
  ka: ['ru', 'tr'],

  // Maltese
  mt: ['it'],

  // Basque
  eu: ['es', 'fr'],

  // Austronesian (Southeast Asia)
  ace: ['id', 'ms'],
  ban: ['id', 'jv', 'ms'],

  // Nilotic (East Africa)
  ach: ['sw'],
  alz: ['ach', 'sw'],

  // Cushitic (Horn of Africa)
  aa: ['so', 'om', 'am', 'fr'],

  // Semitic (Ethiopic script)
  am: ['ti'],

  // Indo-Aryan (Eastern, Bengali-Assamese script)
  as: ['bn', 'hi'],

  // Indo-Aryan (Devanagari, Northern India)
  awa: ['hi', 'ur'],

  // Andean (South America)
  ay: ['qu', 'es'],

  // Semitic (Arabic / Hebrew)
  ar: ['fa', 'ur', 'he'],
  he: ['ar', 'fa'],
  iw: ['he', 'ar', 'fa'], // Google's legacy code for Hebrew

  // Iranian
  fa: ['ur', 'ar'], // covers fa-AF (Dari) via baseLang
  ps: ['fa', 'ur'],
  ku: ['fa', 'tr', 'ar'],
  ckb: ['fa', 'ar', 'ku'],
  tg: ['fa', 'ru'],
  bal: ['fa', 'ur'],
  os: ['ru', 'ka'],

  // Turkic (Central / Asian)
  kk: ['tr', 'uz', 'ru'],
  ky: ['kk', 'tr', 'ru'],
  uz: ['kk', 'tr', 'ru'],
  tk: ['uz', 'tr', 'ru'],
  tt: ['ba', 'kk', 'ru'],
  ba: ['tt', 'kk', 'ru'],
  cv: ['tt', 'ru'],
  sah: ['ru'],
  tyv: ['mn', 'ru'],
  ug: ['kk', 'uz', 'zh'],
  crh: ['tt', 'kk', 'ru'], // covers crh-Latn via baseLang

  // Mongolic
  mn: ['ru', 'zh'],
  bua: ['mn', 'ru'],

  // Uralic (additional)
  kv: ['ru', 'fi'],
  udm: ['ru', 'fi'],
  chm: ['ru', 'fi'],

  // Nakh-Daghestanian
  ce: ['ru', 'av'],

  // Dravidian
  ta: ['te', 'kn', 'ml'],
  te: ['ta', 'kn', 'ml'],
  kn: ['te', 'ta', 'ml'],
  ml: ['ta', 'kn', 'te'],
  tcy: ['kn', 'ml'],

  // Indo-Aryan (South Asian)
  hi: ['ur', 'mr', 'ne'],
  ur: ['hi', 'pa', 'fa'],
  bn: ['as', 'hi'],
  pa: ['hi', 'ur'], // covers pa-Arab via baseLang
  gu: ['hi', 'mr'],
  mr: ['hi', 'gu', 'ne'],
  ne: ['hi', 'mr'],
  or: ['bn', 'hi'],
  sa: ['hi', 'ne', 'mr'],
  sd: ['ur', 'hi'],
  bho: ['hi', 'awa'],
  mai: ['hi', 'bn'],
  doi: ['hi', 'pa'],
  mwr: ['hi', 'gu'],
  gom: ['mr', 'hi'],
  new: ['ne', 'hi'],
  sat: ['bn', 'hi'], // covers sat-Latn via baseLang
  dv: ['si', 'ta'],
  si: ['ta', 'hi'],
  mni: ['bn', 'hi'], // covers mni-Mtei via baseLang

  // Tibeto-Burman
  my: ['th', 'lo'],
  bo: ['zh', 'ne'],
  dz: ['bo', 'ne', 'hi'],
  kac: ['my', 'zh'],
  shn: ['my', 'th'],
  lus: ['hi', 'bn'],
  cnh: ['my'],
  trp: ['bn', 'hi'],

  // Sinitic / Chinese
  zh: ['ja', 'ko'], // covers zh-CN and zh-TW via baseLang
  yue: ['zh', 'ja', 'ko'],

  // Japonic / Koreanic
  ja: ['zh', 'ko'],
  ko: ['ja', 'zh'],

  // Tai-Kadai
  th: ['lo', 'km'],
  lo: ['th', 'km'],

  // Austroasiatic
  km: ['th', 'lo', 'vi'],
  vi: ['km', 'th'],
  kha: ['bn', 'hi'],

  // Austronesian (Maritime SE Asia)
  id: ['ms'],
  ms: ['id'], // covers ms-Arab via baseLang
  jw: ['id', 'ms'],
  su: ['id', 'jw', 'ms'],
  bew: ['id', 'jw', 'ms'],
  mad: ['id', 'jw', 'ms'],
  mak: ['id', 'ms'],
  min: ['id', 'ms'],
  btx: ['id', 'ms'],
  bts: ['id', 'ms'],
  bbc: ['id', 'ms'],
  iba: ['ms', 'id'],
  tl: ['id', 'ms'],
  ceb: ['tl', 'id'],
  hil: ['ceb', 'tl'],
  ilo: ['tl', 'id'],
  bik: ['tl', 'id'],
  pam: ['tl', 'id'],
  war: ['ceb', 'tl'],
  pag: ['tl', 'id'],
  mg: ['sw', 'fr'],
  tet: ['pt', 'id'],

  // Austronesian (Pacific)
  mi: ['sm', 'tl'],
  sm: ['to', 'mi'],
  to: ['sm', 'mi'],
  fj: ['sm', 'to'],
  mh: ['sm'],
  ch: ['tl', 'id'],
  chk: ['sm'],
  ty: ['sm', 'fr'],
  haw: ['sm', 'tl'],

  // Eskimo-Aleut
  iu: ['en'], // covers iu-Latn via baseLang
  kl: ['da'],

  // Afroasiatic (additional)
  ha: ['ar', 'fr'],
  so: ['ar', 'sw'],
  om: ['so', 'am', 'sw'],
  ti: ['am', 'ar'],
  kr: ['ha', 'ar'],

  // Nilo-Saharan
  nus: ['din', 'sw'],
  din: ['nus', 'sw'],

  // Niger-Congo – Bantu
  sw: ['lg', 'rw'],
  sn: ['st', 'nr', 'sw'],
  xh: ['zu', 'st', 'tn'],
  zu: ['xh', 'st', 'nr'],
  st: ['tn', 'zu', 'xh'],
  tn: ['st', 'zu', 'xh'],
  nr: ['zu', 'xh', 'sn'],
  ss: ['zu', 'xh', 'st'],
  ts: ['st', 'zu'],
  ve: ['st', 'tn'],
  nso: ['st', 'tn', 'zu'],
  rw: ['rn', 'sw', 'fr'],
  rn: ['rw', 'sw', 'fr'],
  lg: ['rw', 'sw'],
  ny: ['st', 'sw'],
  tum: ['ny', 'sw'],
  ndc: ['sn', 'st'], // covers ndc-ZW via baseLang
  dov: ['sn', 'st', 'sw'],
  ln: ['fr', 'sw'],
  kg: ['fr', 'sw', 'ln'],
  lua: ['fr', 'sw'],
  ktu: ['kg', 'fr'],
  bem: ['ny', 'sw'],
  cgg: ['rw', 'sw'],

  // Niger-Congo – West African
  yo: ['ig', 'ha', 'fr'],
  ig: ['yo', 'ha'],
  ak: ['yo', 'fon', 'fr'],
  ee: ['yo', 'fon', 'fr'],
  fon: ['yo', 'fr'],
  gaa: ['ak', 'yo'],
  bm: ['fr', 'wo'], // covers bm-Nkoo via baseLang
  dyu: ['bm', 'fr'],
  bci: ['fr'],
  ff: ['ha', 'fr'],
  wo: ['fr'],
  sus: ['fr', 'wo'],
  tiv: ['yo'],

  // Niger-Congo – Central / East African
  sg: ['fr', 'ln'],
  luo: ['ach', 'sw'],

  // Creoles & Pidgins
  ht: ['fr', 'es'],
  jam: ['en'],
  mfe: ['fr'],
  crs: ['fr'],
  tpi: ['en', 'id'],
  kri: ['en'],
  pap: ['es', 'pt', 'nl'],

  // Germanic (additional)
  li: ['nl', 'de'],
  hrx: ['de', 'pt', 'nl'],
  szl: ['pl', 'cs', 'de'],

  // Romance (additional)
  la: ['it', 'es', 'fr', 'pt'],
  vec: ['it', 'fr', 'es'],
  lij: ['it', 'fr'],
  lmo: ['it', 'fr'],
  scn: ['it', 'es', 'fr'],
  fur: ['it', 'de'],
  rom: ['hi', 'ro', 'sk'],

  // Constructed
  eo: ['it', 'es', 'fr', 'de'],

  // Baltic (additional)
  ltg: ['lv', 'lt'],

  // Berber / Tamazight
  ber: ['ar', 'fr'], // covers ber-Latn via baseLang

  // Hmong-Mien
  hmn: ['zh', 'vi', 'th'],

  // Mayan / Mesoamerican
  yua: ['es'],
  kek: ['es'],
  mam: ['es'],
  nhe: ['es'],
  zap: ['es'],

  // Quechuan / Tupian
  qu: ['es', 'ay'],
  gn: ['es', 'pt'],
}
// Maps legacy/non-standard language codes to their canonical BCP-47 base tags.
// Used by normalizeLangTag so that e.g. Google's "iw" is treated the same as "he".
export const LEGACY_LANGUAGE_MAP: Record<string, string> = {
  iw: 'he', // Hebrew (Google legacy)
  ji: 'yi', // Yiddish (legacy)
  in: 'id', // Indonesian (legacy)
  jw: 'jv', // Javanese (Google uses jw, ISO is jv)
}

export default LANGUAGE_FALLBACKS
