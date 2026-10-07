// Guesses the gender of a speech synthesis voice from its name and voiceURI.
// The Web Speech API has no gender field, so this relies on words in the name
// that belong to voices of one gender only ("Anna", "Microsoft Katja …",
// "de_DE-thorsten-high", "German+Annie", "de-de-x-dea-network"), generated
// from the test data in tests/tts-voices (see generate.mjs there).
//
// No lookbehind and no unicode property escapes, startup must work on Gecko 48.

export type Gender = 'female' | 'male' | 'unknown'

// <generated> by tests/tts-voices/generate.mjs, do not edit
const NAMES_FEMALE =
  /^(?:a(?:arohi|dri|egis|f[bips]|gnes|igul|l(?:ba|ena|i(?:c(?:e|ia|ja)|na)|lison|ma|va)|m(?:a(?:la?|ny)|elie|i(?:na|ra)|y|élie)|n(?:a(?:nya)?|drea|gelica|i(?:ka(?:robot)?|la)|n(?:a|ie)|u)|r(?:c|i(?:a(?:ne)?|na)|z)|silia|thina|u(?:a|c|d(?:e|rey)|ntie|rélie)|y(?:sha|umi))|b(?:anu|e(?:c|l(?:inda|kys)|nyw|rta)|lessica|n[fx])|c(?:a(?:f|llie|mila|r(?:m(?:ela|it)|oline)|t(?:a(?:lina|rina)|herine))|cc|f[gls]|h(?:a(?:ntal|rline)|ristel)|l(?:a(?:ire|ra)|b)|o(?:lette|ri)|tc)|d(?:a(?:lia|mayanti|niela|ria|sha)|e(?:a|n(?:a|ise))|fc|hwani|i(?:an[ae]|l(?:ara|navoz)|oco)|ongmei|ragana)|e(?:e[ace]|fu|katerina|l(?:ena|len|oise|sa|vira)|m(?:el|ily|ma)|n[ac]|sc|v(?:a|erita)|wa|zinne)|f(?:atima|e(?:derica|nna|rnanda)|iona|lo|r(?:ancisca|c|m))|g(?:a(?:brijela|dis)|b[acg]|eeta|osia|ra(?:ce|ndma)|u(?:drun|l))|h(?:a(?:aniye|n(?:a|han|na)|ruka|yley|zel)|e(?:a(?:mi|ther)|c|dda|e(?:ra)?|idi|l(?:ena|ia|le)|mkala|rena)|fd|i(?:a|c|la|u(?:gaai|maan))|o(?:aimy|da|rten(?:ce|se))|ra|siao(?:chen|yu)|tm|u(?:ayan|ihui))|i(?:dc|mani?|ngrid|o(?:ana|b|g)|rina|s(?:abel(?:a|la)?|ha|m)|tb|veta)|j(?:a(?:b|r|sietka|ya)|e(?:nny|ssica)|f[bs]|i(?:an?|mena)|o(?:ana|elle|y)|ulie)|k(?:a(?:l(?:ina|pana)|n(?:i|ya)|r(?:en|ina|la|mela)|sandra|t(?:e|h(?:leen|y)|ja|rin|ya))|da|e(?:omany|rstin)|f[lm]|iyara|lara|mn|n[nv]|o[bn]|ristin|sv|yoko)|l(?:a(?:da|ila|n(?:a|lan)|tifa|ura|yla)|e(?:ah|kha|ni|s(?:sac|ya)|tícia)|f[cs]|i(?:bby|li(?:an)?|n(?:da|h)|s(?:a|heng))|jspeech|orena|u(?:ciana|na)|yu(?:bov|dmila))|m(?:a(?:dina|gda|i(?:der|sie)|jlinger|r(?:garita|i(?:a(?:m|nna)?|e|ja|s(?:ka|ol))?|t(?:a|ha)|y(?:am|lux))|tilda|ya)|e(?:era|i(?:jia)?|kdes|lina)|fm|i(?:a|chelle|lena|ren)|o(?:ira|l(?:ly)?|n(?:ica|tse(?:rrat)?)|una)|r[ft]|s[ce]|ónica)|n(?:a(?:banita|n(?:ami|nan)|risa|t(?:a(?:lia|sha)|halie|ia)|zgul)|eerja|fh|i(?:cky|lar)|o(?:emi|ora|ra|ura)|wu)|o(?:da|na|rla)|p(?:a(?:dmavathi|l(?:lavi|oma)|npan|ola|ulina)|e(?:rnille|tra)|iya|o(?:lina|ppy)|r(?:emwadee|i(?:ncess|yamvada)|udence)|te)|r(?:a(?:mona|na|punzelina|quel|ya)|e(?:em|ginute|hema|n)|fj|osa|u[ce])|s(?:a(?:b(?:ela|ina|rina)|l(?:ka|ma|ome)|mantha|n(?:a|dy|geeta)|pna|ra(?:nya)?|tu)|e(?:r(?:aphina|ena)|vinch)|f[bgkps]|h(?:a(?:nshan|sha)|elley|ruti|u)|i(?:lvia|n(?:ji)?|qiniq|ti|wis)|lt|o(?:bhana|fi[ae]|ledad|nia|phie|ra|umya)|pomenka|reymom|sa|teph(?:anie)?|u(?:hyun|nhi|per(?:estrella|star)|san|ze)|vetlana|wara|ylvie)|t(?:a(?:ni(?:a|shaa)|ra|tiana)|e(?:f|resa|ssa|tiana)|f[bs]|h(?:a(?:lita|ndo)|ilini)|i(?:antian|n(?:a|g(?:ting)?))|p[cf]|racy|sync|uti|ünde)|u(?:bax|gla|mka|zma)|v(?:a(?:is|lentina|ni)|e(?:ena|nba|s(?:na|ta))|f[bvz]|i(?:c(?:toria)?|ktoria|rginie|vienne)|l(?:asta|f))|xi(?:ao(?:bei|ni|xiao|yi)?|mena)|y(?:a(?:n|oyao|smin|ting)|e(?:lda|sui)|fr|olanda|u(?:c|na))|z(?:ariyah|fg|ira|o(?:e|fia|sia)|u(?:ri|zana)))$/
const NAMES_MALE =
  /^(?:a(?:a(?:ron|sing)|b(?:dullah|eo)|da(?:bi|m)|hmet|ivars|l(?:an|bert|d|e(?:d|ksand(?:ar|r)|x)|i|onso|varo)|m(?:an?|eha|ir)|n(?:atol|bu|d(?:ika|re[isw]|y)|gelo|t(?:o(?:ine|ni[no])|ton)|xiousandy)|pope|r(?:di?|e|jun|naud|t(?:emiy|hur|ur))|sa[df]|u[bd]|vri|zamat)|b(?:a(?:bek|rt|s(?:hkar|s(?:el)?)|taa)|dl|e(?:d|n(?:gt|jamin))|in(?:bin)?|m[gh]|nm|o(?:bo?|ris(?:lav)?)|r(?:ian|yce)|ui)|c(?:a(?:du?|leb|rl(?:fm|os))|cd|e(?:m|zary)|h(?:anthavong|i(?:lemba|twan)|ristopher)|laude|m[hj]|o(?:lm|n(?:nor|rad)|simo)|te)|d(?:a(?:n(?:iel|ny)|r(?:iush|kman)|u(?:di|let)|v(?:efx|id))|e(?:b|g|nis)|fz|i(?:ego|m(?:as|itar)|ogo)|m(?:a|c|itr[iy])|sb|uarte)|e(?:d(?:dy|on|resson|ward)|e[df]|limu|mil(?:io)?|n(?:d|e|ric)|ric|s[df]|v(?:an|geniy))|f(?:a(?:b(?:er|rice)|hed|rid|s(?:ih|ol))|e(?:derico|lipe)|i(?:lip|nn)|l(?:emishguy|orian)|r(?:ank|b|ed))|g(?:a(?:gan|nji)|b[bd]|e(?:ne|orge|rard)|ft|i(?:lles|orgi|useppe)|mu|o(?:gleddol|nzalo|r(?:an|don))|randpa|u(?:illaume|lnawaz|nnar|stave|y)|wryw|yro)|h(?:a(?:m(?:dan|ed)|n|ohao|rri|ttori)|e(?:di?|mant|nri(?:k|que)?)|i[de]|rb|sb|ugo|yunsu)|i(?:an|brahim|chiro|de|lir|mre|njoon|o[lm]|s(?:eke|lom|mael)|t[cd]|v(?:an|en))|j(?:a(?:c(?:ky|ques)|d|jang|kub|m(?:al|es|ie)|n|vier)|e(?:an|ff|ppe)|irka|m[kn]|o(?:aquim|e|hn|n(?:as)?|r(?:di|ge)|seph)|u(?:an|nior))|k(?:a(?:dlec|lev|ngkang|r(?:eem|lsson|sten)|ukovalta)|e(?:ita|rt)|i(?:ko|llian)|latt|nm|o[cd]|rzysztof|sp|u(?:mar|sal))|l(?:a(?:do|ith|nfrica)|e(?:euw|onas)|i(?:am|feannouncementsystem)|orenzo|u(?:ca|is|k(?:as|e)))|m(?:a(?:arten|dhur|g(?:ed|nus)|jed|n(?:ohar|uel)|r(?:c(?:elo|o)|ek|io|k(?:us)?|tin)|t(?:e[jo]|tias)|x)|i(?:ch(?:a(?:el|l)|el)|dhun|guel|hai|k(?:e|hail)|nsu|tchell)|mn|n[nv]|o(?:az|han)|s[dgv]|uuse|ykyta)|n(?:a(?:ayf|mminh|t(?:an|han))|e(?:el|storas)|guyen|i(?:c(?:holas|olas)|kos|ls|ranjan|wat)|mm|or(?:bert|man))|o(?:badiah|l(?:eksa|iver)|mar|n(?:dro|ni)|penbible|s(?:kar|man|tap)|toya)|p(?:a(?:blo|ttara|ul|v(?:el|oque))|edro|i(?:erre|m|seth)|m[jk]|ra(?:bhat|deep|tham)|td)|quincy|r(?:a(?:dek|fiki|lph|mi|ul|vi)|dh|e(?:ed|my|za)|i(?:c(?:cardo|hard|ishaymax)|shi|zwan)|o(?:b(?:erto?|osoft)?|cko|drigo|ger|han|i|k|nnie)|u(?:d|slan)|y(?:an|hor))|s(?:a(?:gar|l(?:eh|man)|meera|ndro|rdor|speech)|e(?:an|bastian|rbski|va)|h(?:akir|elby)|pike|recko|te(?:f(?:an(?:os)?|fan)|inn)|urya|zabolcs)|t(?:a(?:d|im|l(?:esyntese|gat)|mas|otao|pani|qqiq|rik)|h(?:emba|i(?:erry|ha)|o(?:mas|rsten))|imofey|mg|o(?:lga|mas)|pd|ravis)|universalrobot|v(?:alluvar|enkatesh|i(?:ctor|ktor|taliy)|olodymyr|sevolod)|w(?:a(?:nlung|yne)|ill(?:em|iam))|xander|y(?:annick|lilammi|u(?:d|f|n(?:j(?:he|ian)|xia?|yang)|riy?))|z(?:denek|hiwei))$/
const GOOGLE_FEMALE =
  /^(?:australian english [13]|bahasa indonesia(?: [12])?|d(?:ansk [134]|eutsch(?: [12])?)|español (?:1|2|4|de estados unidos(?: [12])?)|français(?: [124])?|italiano(?: [12])?|magyar|n(?:ederlands [145]|orsk bokmål [124])|po(?:lski(?: [125])?|rtuguês d(?:e portugal(?: [14])?|o brasil(?: [13])?))|s(?:lovenčina|uomi|venska(?: [123])?)|t(?:iếng việt [124]|ürkçe [134])|u(?:k english (?:2|4|6|7|female)|s english(?: [12578])?)|čeština|ελληνικά|русский|українська|हिन्दी(?: [12])?|ไทย|國語（臺灣）|日本語(?: 1)?|普通话（中国大陆）|粤語（香港）|粵語 2|한국(?:어 [12]|의))$/
const GOOGLE_MALE =
  /^(?:australian english [245]|bahasa indonesia [34]|d(?:ansk 2|eutsch [34])|español(?: (?:3|5|de estados unidos [34]))?|français [35]|italiano [34]|n(?:ederlands(?: [23])?|orsk bokmål [35])|po(?:lski [34]|rtuguês d(?:e portugal [23]|o brasil 2))|svenska [45]|t(?:iếng việt [35]|ürkçe [25])|u(?:k english (?:1|3|5|male)|s english [346])|हिन्दी [45]|বাংলা|日本語 [34]|粵語 [135]|한국어 [34])$/
// </generated>

// Chrome desktop and ChromeOS voices are only numbered: "Google Deutsch",
// "Chrome OS Deutsch 1", "Google Deutsch 2 (Natural)" -> "deutsch 2"
export const GOOGLE_NAME = /^(?:chrome os|google) (.+?)(?: \(natural\))?$/

function clean(voice: string) {
  // Firefox appends the language to the voiceURI ("…speechd:mr_IN-…?mr"),
  // codes like "mr", "he" or "ms" must not be read as names
  voice = voice.replace(/\?\S*/g, '')
  try {
    // Firefox escapes spaces and non-ASCII in speechd URIs
    voice = decodeURIComponent(voice)
  } catch (e) {}
  // Chrome on macOS has names with non-breaking spaces
  return voice.replace(/\s+/g, ' ').trim()
}

/** The lower case words of a voice, as they are looked up in the name lists. */
export function voiceWords(name: string, voiceURI = '') {
  name = clean(name)
  voiceURI = clean(voiceURI)
  return (voiceURI && voiceURI !== name ? name + ' ' + voiceURI : name)
    .toLowerCase()
    .replace(/multilingual/g, ' ')
    .split(/[^a-zÀ-￿]+/)
}

/**
 * Detects the gender of a SpeechSynthesisVoice or of a voice name requested by
 * a course (e.g. "German Female").
 */
export function detectGender(name: string, voiceURI = ''): Gender {
  const words = voiceWords(name, voiceURI)
  const text = words.join(' ')

  // "Google UK English Female", "…#female", "German+female2"
  if (/female/.test(text)) return 'female'
  if (/male/.test(text)) return 'male'

  const match = clean(name).toLowerCase().match(GOOGLE_NAME)
  if (match) {
    if (GOOGLE_FEMALE.test(match[1])) return 'female'
    if (GOOGLE_MALE.test(match[1])) return 'male'
  }

  // a voice with names of both genders stays unknown
  let female = false
  let male = false
  for (const word of words) {
    if (NAMES_FEMALE.test(word)) female = true
    else if (NAMES_MALE.test(word)) male = true
  }
  if (female && male) return 'unknown'
  if (female) return 'female'
  if (male) return 'male'
  return 'unknown'
}
