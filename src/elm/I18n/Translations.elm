module I18n.Translations exposing (..)

{-| This file was automatically generated with elm-i18n-gen.
For more in information visit:

<https://github.com/ChristophP/elm-i18n-module-generator>

-}


type Lang
    = Am
    | Ar
    | Bg
    | Bn
    | Ca
    | Cs
    | Da
    | De
    | El
    | Es
    | Et
    | Eu
    | Fa
    | Fi
    | Fr
    | Ga
    | Hi
    | Hr
    | Hu
    | Hy
    | It
    | Ja
    | Ka
    | Ko
    | Lt
    | Lv
    | Nb
    | Nl
    | Pa
    | Pl
    | Pt
    | Ro
    | Ru
    | Sk
    | Sl
    | Sq
    | Sv
    | Sw
    | Tr
    | Tw
    | Uk
    | Ur
    | Zh
    | En


{-| Pass a language code that will return a Lang-type, if it exists.
Otherwise `Nothing` is returned.
-}
getLnFromCode : String -> Maybe Lang
getLnFromCode code =
    case String.toLower code of
        "am" ->
            Just Am

        "ar" ->
            Just Ar

        "bg" ->
            Just Bg

        "bn" ->
            Just Bn

        "ca" ->
            Just Ca

        "cs" ->
            Just Cs

        "da" ->
            Just Da

        "de" ->
            Just De

        "el" ->
            Just El

        "es" ->
            Just Es

        "et" ->
            Just Et

        "eu" ->
            Just Eu

        "fa" ->
            Just Fa

        "fi" ->
            Just Fi

        "fr" ->
            Just Fr

        "ga" ->
            Just Ga

        "hi" ->
            Just Hi

        "hr" ->
            Just Hr

        "hu" ->
            Just Hu

        "hy" ->
            Just Hy

        "it" ->
            Just It

        "ja" ->
            Just Ja

        "ka" ->
            Just Ka

        "ko" ->
            Just Ko

        "lt" ->
            Just Lt

        "lv" ->
            Just Lv

        "nb" ->
            Just Nb

        "nl" ->
            Just Nl

        "pa" ->
            Just Pa

        "pl" ->
            Just Pl

        "pt" ->
            Just Pt

        "ro" ->
            Just Ro

        "ru" ->
            Just Ru

        "sk" ->
            Just Sk

        "sl" ->
            Just Sl

        "sq" ->
            Just Sq

        "sv" ->
            Just Sv

        "sw" ->
            Just Sw

        "tr" ->
            Just Tr

        "tw" ->
            Just Tw

        "uk" ->
            Just Uk

        "ur" ->
            Just Ur

        "zh" ->
            Just Zh

        "en" ->
            Just En

        _ ->
            Nothing


{-| Return the lowerCase language code for the given Lang.
-}
getCodeFromLn : Lang -> String
getCodeFromLn lang =
    case lang of
        Am ->
            "am"

        Ar ->
            "ar"

        Bg ->
            "bg"

        Bn ->
            "bn"

        Ca ->
            "ca"

        Cs ->
            "cs"

        Da ->
            "da"

        De ->
            "de"

        El ->
            "el"

        Es ->
            "es"

        Et ->
            "et"

        Eu ->
            "eu"

        Fa ->
            "fa"

        Fi ->
            "fi"

        Fr ->
            "fr"

        Ga ->
            "ga"

        Hi ->
            "hi"

        Hr ->
            "hr"

        Hu ->
            "hu"

        Hy ->
            "hy"

        It ->
            "it"

        Ja ->
            "ja"

        Ka ->
            "ka"

        Ko ->
            "ko"

        Lt ->
            "lt"

        Lv ->
            "lv"

        Nb ->
            "nb"

        Nl ->
            "nl"

        Pa ->
            "pa"

        Pl ->
            "pl"

        Pt ->
            "pt"

        Ro ->
            "ro"

        Ru ->
            "ru"

        Sk ->
            "sk"

        Sl ->
            "sl"

        Sq ->
            "sq"

        Sv ->
            "sv"

        Sw ->
            "sw"

        Tr ->
            "tr"

        Tw ->
            "tw"

        Uk ->
            "uk"

        Ur ->
            "ur"

        Zh ->
            "zh"

        En ->
            "en"


home : Lang -> String
home lang =
    case lang of
        Am ->
            "ዋና ገጽ"

        Bn ->
            "হোম"

        Ca ->
            "Inici"

        Cs ->
            "Domů"

        Da ->
            "Hjem"

        De ->
            "Übersicht"

        El ->
            "Αρχική"

        Et ->
            "Avaleht"

        Eu ->
            "Hasiera"

        Fi ->
            "Etusivu"

        Fr ->
            "Vue d'ensemble"

        Ga ->
            "Baile"

        Hi ->
            "सिंहावलोकन"

        Hr ->
            "Početna"

        Hu ->
            "Kezdőlap"

        It ->
            "Home"

        Ja ->
            "ホーム"

        Ka ->
            "მთავარი"

        Ko ->
            "집"

        Lt ->
            "Pradžia"

        Lv ->
            "Sākums"

        Nb ->
            "Hjem"

        Pa ->
            "ਘਰ"

        Pl ->
            "Strona główna"

        Pt ->
            "Início"

        Ro ->
            "Acasă"

        Ru ->
            "нет войне"

        Sk ->
            "Domov"

        Sl ->
            "Domov"

        Sq ->
            "Kreu"

        Sv ->
            "Hem"

        Sw ->
            "Nyumbani"

        Tr ->
            "Ana sayfa"

        Ur ->
            "ہوم"

        _ ->
            "Home"


baseNext : Lang -> String
baseNext lang =
    case lang of
        Am ->
            "ቀጣይ"

        Ar ->
            "التالي"

        Bg ->
            "Следващ"

        Bn ->
            "পরবর্তী"

        Ca ->
            "següent"

        Cs ->
            "další"

        Da ->
            "næste"

        De ->
            "weiter"

        El ->
            "επόμενο"

        Es ->
            "siguente"

        Et ->
            "järgmine"

        Eu ->
            "hurrengoa"

        Fa ->
            "بعدی"

        Fi ->
            "seuraava"

        Fr ->
            "suivant"

        Ga ->
            "ar aghaidh"

        Hi ->
            "जारी रखें"

        Hr ->
            "sljedeće"

        Hu ->
            "következő"

        Hy ->
            "հաջորդը"

        It ->
            "prossimo"

        Ja ->
            "次へ"

        Ka ->
            "შემდეგი"

        Ko ->
            "다음"

        Lt ->
            "kitas"

        Lv ->
            "nākamais"

        Nb ->
            "neste"

        Nl ->
            "verder"

        Pa ->
            "ਅੱਗੇ"

        Pl ->
            "dalej"

        Pt ->
            "próximo"

        Ro ->
            "următorul"

        Ru ->
            "вперёд"

        Sk ->
            "ďalší"

        Sl ->
            "naslednje"

        Sq ->
            "tjetri"

        Sv ->
            "nästa"

        Sw ->
            "ijayo"

        Tr ->
            "sonraki"

        Tw ->
            "繼續"

        Uk ->
            "далі"

        Ur ->
            "اگلا"

        Zh ->
            "繼續"

        _ ->
            "next"


basePrev : Lang -> String
basePrev lang =
    case lang of
        Am ->
            "ተመለስ"

        Ar ->
            "السابق"

        Bg ->
            "Предишен"

        Bn ->
            "পূর্ববর্তী"

        Ca ->
            "anterior"

        Cs ->
            "předchozí"

        Da ->
            "forrige"

        De ->
            "zurück"

        El ->
            "προηγούμενο"

        Es ->
            "anterior"

        Et ->
            "eelmine"

        Eu ->
            "aurrekoa"

        Fa ->
            "قبلی"

        Fi ->
            "edellinen"

        Fr ->
            "précédent"

        Ga ->
            "siar"

        Hi ->
            "वापस"

        Hr ->
            "prethodno"

        Hu ->
            "előző"

        Hy ->
            "նախորդը"

        It ->
            "precedente"

        Ja ->
            "前へ"

        Ka ->
            "წინა"

        Ko ->
            "이전"

        Lt ->
            "ankstesnis"

        Lv ->
            "iepriekšējais"

        Nb ->
            "forrige"

        Nl ->
            "terug"

        Pa ->
            "ਪਿੱਛੇ"

        Pl ->
            "wstecz"

        Pt ->
            "anterior"

        Ro ->
            "anteriorul"

        Ru ->
            "назад"

        Sk ->
            "predchádzajúci"

        Sl ->
            "prejšnje"

        Sq ->
            "i mëparshmi"

        Sv ->
            "föregående"

        Sw ->
            "iliyopita"

        Tr ->
            "önceki"

        Tw ->
            "返回"

        Uk ->
            "назад"

        Ur ->
            "پچھلا"

        Zh ->
            "返回"

        _ ->
            "previous"


basePlay : Lang -> String
basePlay lang =
    case lang of
        Am ->
            "ጨርሰን"

        Ar ->
            "العب"

        Bg ->
            "играйте"

        Bn ->
            "প্লে"

        Ca ->
            "reprodueix"

        Cs ->
            "přehrát"

        Da ->
            "afspil"

        De ->
            "Wiedergabe"

        El ->
            "αναπαραγωγή"

        Es ->
            "jugar"

        Et ->
            "esita"

        Eu ->
            "erreproduzitu"

        Fa ->
            "بازی کن"

        Fi ->
            "toista"

        Fr ->
            "Lecture"

        Ga ->
            "seinn"

        Hi ->
            "प्लेबैक"

        Hr ->
            "reproduciraj"

        Hu ->
            "lejátszás"

        Hy ->
            "Խաղացեք"

        It ->
            "avvia"

        Ja ->
            "再生"

        Ka ->
            "დაწყება"

        Ko ->
            "재생"

        Lt ->
            "leisti"

        Lv ->
            "atskaņot"

        Nb ->
            "spill av"

        Nl ->
            "afspelen"

        Pa ->
            "ਚਲਾਓ"

        Pl ->
            "odtwórz"

        Pt ->
            "reproduzir"

        Ro ->
            "redă"

        Ru ->
            "играй"

        Sk ->
            "prehrať"

        Sl ->
            "predvajaj"

        Sq ->
            "luaj"

        Sv ->
            "spela upp"

        Sw ->
            "kucheza"

        Tr ->
            "oynat"

        Tw ->
            "播放"

        Uk ->
            "грати"

        Ur ->
            "چلائیں"

        Zh ->
            "播放"

        _ ->
            "play"


baseStop : Lang -> String
baseStop lang =
    case lang of
        Am ->
            "አቆጣጠር"

        Ar ->
            "توقف"

        Bg ->
            "спрете"

        Bn ->
            "স্টপ"

        Ca ->
            "atura"

        Cs ->
            "zastavit"

        Da ->
            "stop"

        De ->
            "Stopp"

        El ->
            "διακοπή"

        Es ->
            "parar"

        Et ->
            "peata"

        Eu ->
            "gelditu"

        Fa ->
            "بس کن"

        Fi ->
            "pysäytä"

        Fr ->
            "Arrêt"

        Ga ->
            "stop"

        Hi ->
            "बंद करो"

        Hr ->
            "zaustavi"

        Hu ->
            "leállítás"

        Hy ->
            "դադարեցրեք"

        It ->
            "ferma"

        Ja ->
            "停止"

        Ka ->
            "გაჩერება"

        Ko ->
            "정지"

        Lt ->
            "sustabdyti"

        Lv ->
            "apturēt"

        Nb ->
            "stopp"

        Nl ->
            "stoppen"

        Pa ->
            "ਬੰਦ ਕਰੋ"

        Pl ->
            "zatrzymaj"

        Pt ->
            "parar"

        Ro ->
            "oprește"

        Ru ->
            "остановись"

        Sk ->
            "zastaviť"

        Sl ->
            "ustavi"

        Sq ->
            "ndalo"

        Sv ->
            "stoppa"

        Sw ->
            "kuacha"

        Tr ->
            "durdur"

        Tw ->
            "停止"

        Uk ->
            "зупинятися"

        Ur ->
            "روکیں"

        Zh ->
            "停止"

        _ ->
            "stop"


baseAbc : Lang -> String
baseAbc lang =
    case lang of
        Am ->
            "አማ"

        Bn ->
            "এবিসি"

        Ca ->
            "Aa"

        Cs ->
            "Aa"

        Da ->
            "Aa"

        El ->
            "Aa"

        Et ->
            "Aa"

        Eu ->
            "Aa"

        Fi ->
            "Aa"

        Ga ->
            "Aa"

        Hr ->
            "Aa"

        Hu ->
            "Aa"

        It ->
            "Aa"

        Ja ->
            "Aa"

        Ka ->
            "Aa"

        Ko ->
            "가"

        Lt ->
            "Aa"

        Lv ->
            "Aa"

        Nb ->
            "Aa"

        Pa ->
            "ਏਬੀਸੀ"

        Pl ->
            "Aa"

        Pt ->
            "Aa"

        Ro ->
            "Aa"

        Sk ->
            "Aa"

        Sl ->
            "Aa"

        Sq ->
            "Aa"

        Sv ->
            "Aa"

        Sw ->
            "Aa"

        Tr ->
            "Aa"

        Ur ->
            "Aa"

        _ ->
            "Aa"


baseFont : Lang -> String -> String
baseFont lang str0 =
    case lang of
        Am ->
            "ፎንት መጠን: " ++ str0 ++ ""

        Ar ->
            " :حجم الخط " ++ str0 ++ ""

        Bg ->
            "Размер на шрифта: " ++ str0 ++ ""

        Bn ->
            "ফন্ট সাইজ: " ++ str0 ++ ""

        Ca ->
            "mida de la lletra: " ++ str0 ++ ""

        Cs ->
            "velikost písma: " ++ str0 ++ ""

        Da ->
            "skriftstørrelse: " ++ str0 ++ ""

        De ->
            "Schriftgröße: " ++ str0 ++ ""

        El ->
            "μέγεθος γραμματοσειράς: " ++ str0 ++ ""

        Es ->
            "Tamaño de fuente: " ++ str0 ++ ""

        Et ->
            "kirjasuurus: " ++ str0 ++ ""

        Eu ->
            "letra-tamaina: " ++ str0 ++ ""

        Fa ->
            "اندازه قلم: " ++ str0 ++ ""

        Fi ->
            "fonttikoko: " ++ str0 ++ ""

        Fr ->
            "Taille de police : " ++ str0 ++ ""

        Ga ->
            "clómhéid: " ++ str0 ++ ""

        Hi ->
            "फ़ॉन्ट आकार: " ++ str0 ++ ""

        Hr ->
            "veličina fonta: " ++ str0 ++ ""

        Hu ->
            "betűméret: " ++ str0 ++ ""

        Hy ->
            "Տառատեսակի չափը ՝ " ++ str0 ++ ""

        It ->
            "Dimensione carattere: " ++ str0 ++ ""

        Ja ->
            "フォントサイズ: " ++ str0 ++ ""

        Ka ->
            "შრიფტის ზომა: " ++ str0 ++ ""

        Ko ->
            "글꼴 크기: " ++ str0 ++ ""

        Lt ->
            "šrifto dydis: " ++ str0 ++ ""

        Lv ->
            "fonta lielums: " ++ str0 ++ ""

        Nb ->
            "skriftstørrelse: " ++ str0 ++ ""

        Nl ->
            "Lettergrootte: " ++ str0 ++ ""

        Pa ->
            "ਫੋਂਟ ਆਕਾਰ: " ++ str0 ++ ""

        Pl ->
            "rozmiar czcionki: " ++ str0 ++ ""

        Pt ->
            "tamanho da fonte: " ++ str0 ++ ""

        Ro ->
            "dimensiunea fontului: " ++ str0 ++ ""

        Ru ->
            "Размер шрифта: " ++ str0 ++ ""

        Sk ->
            "veľkosť písma: " ++ str0 ++ ""

        Sl ->
            "velikost pisave: " ++ str0 ++ ""

        Sq ->
            "madhësia e shkronjave: " ++ str0 ++ ""

        Sv ->
            "teckenstorlek: " ++ str0 ++ ""

        Sw ->
            "saizi ya fonti: " ++ str0 ++ ""

        Tr ->
            "yazı tipi boyutu: " ++ str0 ++ ""

        Tw ->
            "字体大小： " ++ str0 ++ ""

        Uk ->
            "Розмір шрифту: " ++ str0 ++ ""

        Ur ->
            "فونٹ کا سائز: " ++ str0 ++ ""

        Zh ->
            "字体大小： " ++ str0 ++ ""

        _ ->
            "font size: " ++ str0 ++ ""


baseSize1 : Lang -> String
baseSize1 lang =
    case lang of
        Am ->
            "ትንሽ"

        Ar ->
            "صغير"

        Bg ->
            "малък"

        Bn ->
            "ছোট"

        Ca ->
            "petita"

        Cs ->
            "malá"

        Da ->
            "lille"

        De ->
            "klein"

        El ->
            "μικρό"

        Es ->
            "pequeño"

        Et ->
            "väike"

        Eu ->
            "txikia"

        Fa ->
            "کوچک"

        Fi ->
            "pieni"

        Fr ->
            "petit"

        Ga ->
            "beag"

        Hi ->
            "छोटा"

        Hr ->
            "mala"

        Hu ->
            "kicsi"

        Hy ->
            "փոքր"

        It ->
            "piccolo"

        Ja ->
            "小"

        Ka ->
            "პატარა"

        Ko ->
            "작게"

        Lt ->
            "mažas"

        Lv ->
            "mazs"

        Nb ->
            "liten"

        Nl ->
            "klein"

        Pa ->
            "ਛੋਟਾ"

        Pl ->
            "mały"

        Pt ->
            "pequeno"

        Ro ->
            "mică"

        Ru ->
            "мелкий"

        Sk ->
            "malá"

        Sl ->
            "majhna"

        Sq ->
            "e vogël"

        Sv ->
            "liten"

        Sw ->
            "ndogo"

        Tr ->
            "küçük"

        Tw ->
            "小"

        Uk ->
            "маленький"

        Ur ->
            "چھوٹا"

        Zh ->
            "小"

        _ ->
            "small"


baseSize2 : Lang -> String
baseSize2 lang =
    case lang of
        Am ->
            "መልካም"

        Ar ->
            "متوسط"

        Bg ->
            "среден"

        Bn ->
            "মাঝারি"

        Ca ->
            "mitjana"

        Cs ->
            "střední"

        Da ->
            "mellem"

        De ->
            "mittel"

        El ->
            "μεσαίο"

        Es ->
            "mediano"

        Et ->
            "keskmine"

        Eu ->
            "ertaina"

        Fa ->
            "متوسط"

        Fi ->
            "keskikokoinen"

        Fr ->
            "moyen"

        Ga ->
            "meánach"

        Hi ->
            "मध्यम"

        Hr ->
            "srednja"

        Hu ->
            "közepes"

        Hy ->
            "միջին"

        It ->
            "medio"

        Ja ->
            "中"

        Ka ->
            "საშუალო"

        Ko ->
            "보통"

        Lt ->
            "vidutinis"

        Lv ->
            "vidējs"

        Nb ->
            "middels"

        Nl ->
            "medium"

        Pa ->
            "ਦਰਮਿਆਨਾ"

        Pl ->
            "średni"

        Pt ->
            "médio"

        Ro ->
            "medie"

        Ru ->
            "средний"

        Sk ->
            "stredná"

        Sl ->
            "srednja"

        Sq ->
            "mesatare"

        Sv ->
            "medelstor"

        Sw ->
            "kati"

        Tr ->
            "orta"

        Tw ->
            "中"

        Uk ->
            "середній"

        Ur ->
            "درمیانہ"

        Zh ->
            "中"

        _ ->
            "medium"


baseSize3 : Lang -> String
baseSize3 lang =
    case lang of
        Am ->
            "በጣም ስምንት"

        Ar ->
            "كبير"

        Bg ->
            "голям"

        Bn ->
            "বড়"

        Ca ->
            "gran"

        Cs ->
            "velká"

        Da ->
            "stor"

        De ->
            "groß"

        El ->
            "μεγάλο"

        Es ->
            "grande"

        Et ->
            "suur"

        Eu ->
            "handia"

        Fa ->
            "بزرگ"

        Fi ->
            "suuri"

        Fr ->
            "grand"

        Ga ->
            "mór"

        Hi ->
            "बड़ा"

        Hr ->
            "velika"

        Hu ->
            "nagy"

        Hy ->
            "մեծ"

        It ->
            "grande"

        Ja ->
            "大"

        Ka ->
            "დიდი"

        Ko ->
            "크게"

        Lt ->
            "didelis"

        Lv ->
            "liels"

        Nb ->
            "stor"

        Nl ->
            "groot"

        Pa ->
            "ਵੱਡਾ"

        Pl ->
            "duży"

        Pt ->
            "grande"

        Ro ->
            "mare"

        Ru ->
            "большой"

        Sk ->
            "veľká"

        Sl ->
            "velika"

        Sq ->
            "e madhe"

        Sv ->
            "stor"

        Sw ->
            "kubwa"

        Tr ->
            "büyük"

        Tw ->
            "大"

        Uk ->
            "великий"

        Ur ->
            "بڑا"

        Zh ->
            "大"

        _ ->
            "large"


baseSearch : Lang -> String
baseSearch lang =
    case lang of
        Am ->
            "ፈልግ"

        Ar ->
            "بحث"

        Bg ->
            "Търсене"

        Bn ->
            "অনুসন্ধান"

        Ca ->
            "Cerca"

        Cs ->
            "Hledat"

        Da ->
            "Søg"

        De ->
            "Suche"

        El ->
            "Αναζήτηση"

        Es ->
            "buscar"

        Et ->
            "Otsi"

        Eu ->
            "Bilatu"

        Fa ->
            "جستجو"

        Fi ->
            "Hae"

        Fr ->
            "Recherche"

        Ga ->
            "Cuardaigh"

        Hi ->
            "खोजें"

        Hr ->
            "Traži"

        Hu ->
            "Keresés"

        Hy ->
            "փնտրել"

        It ->
            "Cerca"

        Ja ->
            "検索"

        Ka ->
            "ძიება"

        Ko ->
            "찾기"

        Lt ->
            "Ieškoti"

        Lv ->
            "Meklēt"

        Nb ->
            "Søk"

        Nl ->
            "zoek"

        Pa ->
            "ਖੋਜ"

        Pl ->
            "Szukaj"

        Pt ->
            "Buscar"

        Ro ->
            "Caută"

        Ru ->
            "поиск"

        Sk ->
            "Hľadať"

        Sl ->
            "Išči"

        Sq ->
            "Kërko"

        Sv ->
            "Sök"

        Sw ->
            "Tafuta"

        Tr ->
            "Ara"

        Tw ->
            "搜尋"

        Uk ->
            "пошук"

        Ur ->
            "تلاش"

        Zh ->
            "搜尋"

        _ ->
            "Search"


baseDelete : Lang -> String
baseDelete lang =
    case lang of
        Am ->
            "ፈልግ ያድገት"

        Ar ->
            "إزالة البحث"

        Bg ->
            "търсене изтриване"

        Bn ->
            "অনুসন্ধান মুছে ফেলুন"

        Ca ->
            "esborra la cerca"

        Cs ->
            "vymazat hledání"

        Da ->
            "ryd søgning"

        De ->
            "Suche löschen"

        El ->
            "εκκαθάριση αναζήτησης"

        Es ->
            "eliminar búsqueda"

        Et ->
            "tühjenda otsing"

        Eu ->
            "garbitu bilaketa"

        Fa ->
            "جستجو را حذف کنید"

        Fi ->
            "tyhjennä haku"

        Fr ->
            "Effacer la recherche"

        Ga ->
            "glan an cuardach"

        Hi ->
            "खोज हटाएं"

        Hr ->
            "očisti pretragu"

        Hu ->
            "keresés törlése"

        Hy ->
            "ջնջել որոնումը"

        It ->
            "cancella ricerca"

        Ja ->
            "検索をクリア"

        Ka ->
            "ძიების გასუფთავება"

        Ko ->
            "입력 내용 지우기"

        Lt ->
            "išvalyti paiešką"

        Lv ->
            "notīrīt meklēšanu"

        Nb ->
            "tøm søk"

        Nl ->
            "Duidelijke zoek"

        Pa ->
            "ਖੋਜ ਹਟਾਓ"

        Pl ->
            "wyczyść wyszukiwanie"

        Pt ->
            "limpar busca"

        Ro ->
            "șterge căutarea"

        Ru ->
            "удалить поиск"

        Sk ->
            "vymazať vyhľadávanie"

        Sl ->
            "počisti iskanje"

        Sq ->
            "pastro kërkimin"

        Sv ->
            "rensa sökning"

        Sw ->
            "tafuta wazi"

        Tr ->
            "aramayı temizle"

        Tw ->
            "删除搜寻"

        Uk ->
            "видалити пошук"

        Ur ->
            "تلاش صاف کریں"

        Zh ->
            "删除搜寻"

        _ ->
            "clear search"


baseResults : Lang -> String
baseResults lang =
    case lang of
        Am ->
            "ውጤቶች"

        Ar ->
            "النتائج"

        Bg ->
            "Резултати"

        Bn ->
            "ফলাফল"

        Ca ->
            "resultats"

        Cs ->
            "výsledky"

        Da ->
            "resultater"

        De ->
            "Ergebnisse"

        El ->
            "αποτελέσματα"

        Es ->
            "Resultados"

        Et ->
            "tulemused"

        Eu ->
            "emaitzak"

        Fa ->
            "نتایج"

        Fi ->
            "tulokset"

        Fr ->
            "Résultats"

        Ga ->
            "torthaí"

        Hi ->
            "परिणाम"

        Hr ->
            "rezultati"

        Hu ->
            "találatok"

        Hy ->
            "արդյունքներ"

        It ->
            "risultati"

        Ja ->
            "結果"

        Ka ->
            "შედეგები"

        Ko ->
            "결과"

        Lt ->
            "rezultatai"

        Lv ->
            "rezultāti"

        Nb ->
            "resultater"

        Nl ->
            "Resultaten"

        Pa ->
            "ਨਤੀਜੇ"

        Pl ->
            "wyniki"

        Pt ->
            "resultados"

        Ro ->
            "rezultate"

        Ru ->
            "результаты"

        Sk ->
            "výsledky"

        Sl ->
            "rezultati"

        Sq ->
            "rezultate"

        Sv ->
            "resultat"

        Sw ->
            "matokeo"

        Tr ->
            "sonuçlar"

        Tw ->
            "结果"

        Uk ->
            "результати"

        Ur ->
            "نتائج"

        Zh ->
            "结果"

        _ ->
            "results"


baseOneResult : Lang -> String
baseOneResult lang =
    case lang of
        Am ->
            "አንድ ውጤት"

        Ar ->
            "نتيجة واحدة"

        Bg ->
            "един резултат"

        Bn ->
            "একটি ফলাফল"

        Ca ->
            "un resultat"

        Cs ->
            "jeden výsledek"

        Da ->
            "ét resultat"

        De ->
            "ein Ergebnis"

        El ->
            "ένα αποτέλεσμα"

        Es ->
            "un resultado"

        Et ->
            "üks tulemus"

        Eu ->
            "emaitza bat"

        Fa ->
            "یک نتیجه"

        Fi ->
            "yksi tulos"

        Fr ->
            "un résultat"

        Ga ->
            "toradh amháin"

        Hi ->
            "एक परिणाम"

        Hr ->
            "jedan rezultat"

        Hu ->
            "egy találat"

        Hy ->
            "մեկ արդյունք"

        It ->
            "un risultato"

        Ja ->
            "1件の結果"

        Ka ->
            "ერთი შედეგი"

        Ko ->
            "단일 결과"

        Lt ->
            "vienas rezultatas"

        Lv ->
            "viens rezultāts"

        Nb ->
            "ett resultat"

        Nl ->
            "een resultaat"

        Pa ->
            "ਇੱਕ ਨਤੀਜਾ"

        Pl ->
            "jeden wynik"

        Pt ->
            "um resultado"

        Ro ->
            "un rezultat"

        Ru ->
            "один результат"

        Sk ->
            "jeden výsledok"

        Sl ->
            "en rezultat"

        Sq ->
            "një rezultat"

        Sv ->
            "ett resultat"

        Sw ->
            "matokeo moja"

        Tr ->
            "bir sonuç"

        Tw ->
            "一个结果"

        Uk ->
            "один результат"

        Ur ->
            "ایک نتیجہ"

        Zh ->
            "一个结果"

        _ ->
            "one result"


baseNoResult : Lang -> String
baseNoResult lang =
    case lang of
        Am ->
            "ምንም ውጤት የሉም"

        Ar ->
            "ولا أي نتيجة"

        Bg ->
            "няма резултати"

        Bn ->
            "কোন ফলাফল নেই"

        Ca ->
            "cap resultat"

        Cs ->
            "žádné výsledky"

        Da ->
            "ingen resultater"

        De ->
            "kein Ergebnis"

        El ->
            "κανένα αποτέλεσμα"

        Es ->
            "No hay resultados"

        Et ->
            "tulemusi pole"

        Eu ->
            "emaitzarik ez"

        Fa ->
            "هیچ نتیجه ای"

        Fi ->
            "ei tuloksia"

        Fr ->
            "aucun résultat"

        Ga ->
            "gan torthaí"

        Hi ->
            "कोई परिणाम नहीं"

        Hr ->
            "nema rezultata"

        Hu ->
            "nincs találat"

        Hy ->
            "արդյունք չկա"

        It ->
            "non ci sono risultati"

        Ja ->
            "結果なし"

        Ka ->
            "შედეგები არ არის"

        Ko ->
            "결과 없음"

        Lt ->
            "rezultatų nėra"

        Lv ->
            "nav rezultātu"

        Nb ->
            "ingen resultater"

        Nl ->
            "Geen resultaten"

        Pa ->
            "ਕੋਈ ਨਤੀਜਾ ਨਹੀਂ"

        Pl ->
            "brak wyników"

        Pt ->
            "sem resultados"

        Ro ->
            "niciun rezultat"

        Ru ->
            "нет результатов"

        Sk ->
            "žiadne výsledky"

        Sl ->
            "ni rezultatov"

        Sq ->
            "asnjë rezultat"

        Sv ->
            "inga resultat"

        Sw ->
            "hakuna matokeo"

        Tr ->
            "sonuç yok"

        Tw ->
            "没有结果"

        Uk ->
            "немає результатів"

        Ur ->
            "کوئی نتیجہ نہیں"

        Zh ->
            "没有结果"

        _ ->
            "no results"


baseToc : Lang -> String
baseToc lang =
    case lang of
        Am ->
            "የዋጋ ዓረብ"

        Ar ->
            "جدول المحتويات"

        Bg ->
            "Съдържание"

        Bn ->
            "সূচী"

        Ca ->
            "Taula de continguts"

        Cs ->
            "Obsah"

        Da ->
            "Indholdsfortegnelse"

        De ->
            "Inhaltsverzeichnis"

        El ->
            "Πίνακας περιεχομένων"

        Es ->
            "índice"

        Et ->
            "Sisukord"

        Eu ->
            "Aurkibidea"

        Fa ->
            "فهرست مطالب"

        Fi ->
            "Sisällysluettelo"

        Fr ->
            "Table des matières"

        Ga ->
            "Clár na nÁbhar"

        Hi ->
            "सामग्री की तालिका"

        Hr ->
            "Sadržaj"

        Hu ->
            "Tartalomjegyzék"

        Hy ->
            "բովանդակություն"

        It ->
            "indice"

        Ja ->
            "目次"

        Ka ->
            "შინაარსის სია"

        Ko ->
            "목차"

        Lt ->
            "Turinys"

        Lv ->
            "Satura rādītājs"

        Nb ->
            "Innholdsfortegnelse"

        Nl ->
            "Inhoudsopgave"

        Pa ->
            "ਸਮੱਗਰੀ ਦੇ ਨਾਲ-ਨਾਲ"

        Pl ->
            "Spis treści"

        Pt ->
            "Sumário"

        Ro ->
            "Cuprins"

        Ru ->
            "оглавление"

        Sk ->
            "Obsah"

        Sl ->
            "Kazalo vsebine"

        Sq ->
            "Pasqyra e lëndës"

        Sv ->
            "Innehållsförteckning"

        Sw ->
            "Yaliyomo"

        Tr ->
            "İçindekiler"

        Tw ->
            "目錄"

        Uk ->
            "зміст"

        Ur ->
            "فہرست مشمولات"

        Zh ->
            "目錄"

        _ ->
            "Table of Contents"


baseShow : Lang -> String
baseShow lang =
    case lang of
        Am ->
            "አሳይ"

        Ar ->
            "إظهار"

        Bg ->
            "показване"

        Bn ->
            "দেখান"

        Ca ->
            "mostra"

        Cs ->
            "zobrazit"

        Da ->
            "vis"

        De ->
            "zeigen"

        El ->
            "εμφάνιση"

        Es ->
            "mostrar"

        Et ->
            "näita"

        Eu ->
            "erakutsi"

        Fa ->
            "نشان دادن"

        Fi ->
            "näytä"

        Fr ->
            "montrer"

        Ga ->
            "taispeáin"

        Hi ->
            "दिखाएँ"

        Hr ->
            "prikaži"

        Hu ->
            "megjelenítés"

        Hy ->
            "ցույց տալ"

        It ->
            "mostrare"

        Ja ->
            "表示"

        Ka ->
            "გამოჩვენე"

        Ko ->
            "보이기"

        Lt ->
            "rodyti"

        Lv ->
            "rādīt"

        Nb ->
            "vis"

        Nl ->
            "tonen"

        Pa ->
            "ਵੇਖਾਓ"

        Pl ->
            "pokaż"

        Pt ->
            "mostrar"

        Ro ->
            "afișează"

        Ru ->
            "показать"

        Sk ->
            "zobraziť"

        Sl ->
            "pokaži"

        Sq ->
            "shfaq"

        Sv ->
            "visa"

        Sw ->
            "show"

        Tr ->
            "göster"

        Tw ->
            "顯示"

        Uk ->
            "показати"

        Ur ->
            "دکھائیں"

        Zh ->
            "顯示"

        _ ->
            "show"


baseHide : Lang -> String
baseHide lang =
    case lang of
        Am ->
            "ደብቅ"

        Ar ->
            "إخفاء"

        Bg ->
            "скриване"

        Bn ->
            "লুকান"

        Ca ->
            "amaga"

        Cs ->
            "skrýt"

        Da ->
            "skjul"

        De ->
            "verberghen"

        El ->
            "απόκρυψη"

        Es ->
            "ocultar"

        Et ->
            "peida"

        Eu ->
            "ezkutatu"

        Fa ->
            "پنهان کردن"

        Fi ->
            "piilota"

        Fr ->
            "cacher"

        Ga ->
            "folaigh"

        Hi ->
            "छुपाएं"

        Hr ->
            "sakrij"

        Hu ->
            "elrejtés"

        Hy ->
            "թաքցնել"

        It ->
            "nascondere"

        Ja ->
            "非表示"

        Ka ->
            "დამალე"

        Ko ->
            "감추기"

        Lt ->
            "slėpti"

        Lv ->
            "paslēpt"

        Nb ->
            "skjul"

        Nl ->
            "verbergen"

        Pa ->
            "ਓਹਲੇ"

        Pl ->
            "ukryj"

        Pt ->
            "esconder"

        Ro ->
            "ascunde"

        Ru ->
            "скрыть"

        Sk ->
            "skryť"

        Sl ->
            "skrij"

        Sq ->
            "fshih"

        Sv ->
            "dölj"

        Sw ->
            "kujificha"

        Tr ->
            "gizle"

        Tw ->
            "隱藏"

        Uk ->
            "приховати"

        Ur ->
            "چھپائیں"

        Zh ->
            "隱藏"

        _ ->
            "hide"


baseEditor : Lang -> String
baseEditor lang =
    case lang of
        Am ->
            "ኤዲተር-ዘዴ"

        Ar ->
            "على غرار المحرر"

        Bg ->
            "редакторски стил"

        Bn ->
            "সম্পাদক-স্টাইল"

        Ca ->
            "Estil de l'editor"

        Cs ->
            "Styl editoru"

        Da ->
            "Editorstil"

        De ->
            "Editor-Stil"

        El ->
            "Στυλ επεξεργαστή"

        Es ->
            "estilo editor"

        Et ->
            "Redaktori stiil"

        Eu ->
            "Editorearen estiloa"

        Fa ->
            "به سبک ویرایشگر"

        Fi ->
            "Editorin tyyli"

        Fr ->
            "Style de l'éditeur"

        Ga ->
            "Stíl an eagarthóra"

        Hi ->
            "संपादक शैली"

        Hr ->
            "Stil uređivača"

        Hu ->
            "Szerkesztő stílusa"

        Hy ->
            "խմբագիր ոճով"

        It ->
            "stile editor"

        Ja ->
            "エディター・スタイル"

        Ka ->
            "რედაქტორის სტილი"

        Ko ->
            "에디터 스타일"

        Lt ->
            "Rengyklės stilius"

        Lv ->
            "Redaktora stils"

        Nb ->
            "Editorstil"

        Nl ->
            "editor-stijl"

        Pa ->
            "ਸੰਪਾਦਕ ਸਟਾਈਲ"

        Pl ->
            "Styl edytora"

        Pt ->
            "Estilo do editor"

        Ro ->
            "Stilul editorului"

        Ru ->
            "стиль редактора"

        Sk ->
            "Štýl editora"

        Sl ->
            "Slog urejevalnika"

        Sq ->
            "Stili i redaktuesit"

        Sv ->
            "Redigerarstil"

        Sw ->
            "Mtindo wa Mhariri"

        Tr ->
            "Düzenleyici stili"

        Tw ->
            "编辑风格"

        Uk ->
            "стиль редактора"

        Ur ->
            "ایڈیٹر اسٹائل"

        Zh ->
            "编辑风格"

        _ ->
            "Editor-Style"


baseLang : Lang -> String
baseLang lang =
    case lang of
        Am ->
            "አማርኛ"

        Ar ->
            "العربية"

        Bg ->
            "български"

        Bn ->
            "ইংরেজি"

        Ca ->
            "Català"

        Cs ->
            "Čeština"

        Da ->
            "Dansk"

        De ->
            "Deutsch"

        El ->
            "Ελληνικά"

        Es ->
            "Español"

        Et ->
            "Eesti"

        Eu ->
            "Euskara"

        Fa ->
            "فارسی"

        Fi ->
            "Suomi"

        Fr ->
            "Français"

        Ga ->
            "Gaeilge"

        Hi ->
            "जर्मन"

        Hr ->
            "Hrvatski"

        Hu ->
            "Magyar"

        Hy ->
            "հայերեն"

        It ->
            "Italiano"

        Ja ->
            "日本語"

        Ka ->
            "ინგლისური"

        Ko ->
            "한국어"

        Lt ->
            "Lietuvių"

        Lv ->
            "Latviešu"

        Nb ->
            "Norsk bokmål"

        Nl ->
            "Nederlands"

        Pa ->
            "ਪੰਜਾਬੀ"

        Pl ->
            "Polski"

        Pt ->
            "Português"

        Ro ->
            "Română"

        Ru ->
            "русский"

        Sk ->
            "Slovenčina"

        Sl ->
            "Slovenščina"

        Sq ->
            "Shqip"

        Sv ->
            "Svenska"

        Sw ->
            "Suaheli"

        Tr ->
            "Türkçe"

        Tw ->
            "中国人"

        Uk ->
            "Український"

        Ur ->
            "انگریزی"

        Zh ->
            "中国人"

        _ ->
            "English"


commentRate : Lang -> String
commentRate lang =
    case lang of
        Am ->
            "የድምጽ ፍጥነት ቀይር"

        Ar ->
            "تعديل سرعة التشغيل"

        Bg ->
            "Промяна на скоростта на възпроизвеждане"

        Bn ->
            "প্লেব্যাক গতি সংশোধন করুন"

        Ca ->
            "Ajusta la velocitat de reproducció"

        Cs ->
            "Upravit rychlost přehrávání"

        Da ->
            "Juster afspilningshastighed"

        De ->
            "Anpassung der Abspielgeschwindigkeit"

        El ->
            "Προσαρμογή ταχύτητας αναπαραγωγής"

        Es ->
            "ajustar velocidad de reproducción"

        Et ->
            "Muuda taasesituse kiirust"

        Eu ->
            "Doitu erreprodukzio-abiadura"

        Fa ->
            "تنظیم سرعت پخش"

        Fi ->
            "Säädä toistonopeutta"

        Fr ->
            "Ajuster la vitesse de lecture"

        Ga ->
            "Coigeartaigh luas na hathsheinnte"

        Hi ->
            "प्लेबैक गति सेट करें"

        Hr ->
            "Prilagodi brzinu reprodukcije"

        Hu ->
            "Lejátszási sebesség beállítása"

        Hy ->
            "ձայնագիրը կարգավորել"

        It ->
            "Regola la velocità di riproduzione"

        Ja ->
            "再生速度を変更"

        Ka ->
            "ჩათამაშების სიჩქარის რეგულირება"

        Ko ->
            "재생 속도 조절"

        Lt ->
            "Keisti atkūrimo greitį"

        Lv ->
            "Pielāgot atskaņošanas ātrumu"

        Nb ->
            "Juster avspillingshastighet"

        Nl ->
            "Afspeelsnelheid aanpassen"

        Pa ->
            "ਪਲੇਬੈਕ ਗਤੀ ਸੰਰਚਨਾ"

        Pl ->
            "Dostosuj prędkość odtwarzania"

        Pt ->
            "Ajustar velocidade de reprodução"

        Ro ->
            "Ajustează viteza de redare"

        Ru ->
            "настройка скорости воспроизведения"

        Sk ->
            "Upraviť rýchlosť prehrávania"

        Sl ->
            "Prilagodi hitrost predvajanja"

        Sq ->
            "Rregullo shpejtësinë e riprodhimit"

        Sv ->
            "Justera uppspelningshastighet"

        Sw ->
            "Badilisha kasi ya kucheza"

        Tr ->
            "Oynatma hızını ayarla"

        Tw ->
            "调整播放速度"

        Uk ->
            "налаштування швидкості відтворення"

        Ur ->
            "پلے بیک کی رفتار ایڈجسٹ کریں"

        Zh ->
            "调整播放速度"

        _ ->
            "Adjust playback speed"


commentPitch : Lang -> String
commentPitch lang =
    case lang of
        Am ->
            "የድምጽ አንድ ቀይር"

        Ar ->
            "تعديل الارتفاع"

        Bg ->
            "Промяна на тон"

        Bn ->
            "টোন সংশোধন করুন"

        Ca ->
            "Ajusta el to de la veu"

        Cs ->
            "Upravit výšku hlasu"

        Da ->
            "Juster tonehøjde"

        De ->
            "Anpassung der Tonhöhe"

        El ->
            "Προσαρμογή ύψους φωνής"

        Es ->
            "ajustar tono"

        Et ->
            "Muuda hääle kõrgust"

        Eu ->
            "Doitu ahotsaren tonua"

        Fa ->
            "تنظیم تغییر صدا"

        Fi ->
            "Säädä äänenkorkeutta"

        Fr ->
            "Ajuster la hauteur du son"

        Ga ->
            "Coigeartaigh tuinairde an ghutha"

        Hi ->
            "ध्वनि सेट करें"

        Hr ->
            "Prilagodi visinu glasa"

        Hu ->
            "Hangmagasság beállítása"

        Hy ->
            "ձայնահատկությունը կարգավորել"

        It ->
            "Regola l'altezza del tono"

        Ja ->
            "音程を変更"

        Ka ->
            "ტონის რეგულირება"

        Ko ->
            "음높이 조절"

        Lt ->
            "Keisti balso aukštį"

        Lv ->
            "Pielāgot balss augstumu"

        Nb ->
            "Juster tonehøyde"

        Nl ->
            "Toonhoogte aanpassen"

        Pa ->
            "ਧੁਨ ਸੰਰਚਨਾ"

        Pl ->
            "Dostosuj wysokość głosu"

        Pt ->
            "Ajustar tom"

        Ro ->
            "Ajustează înălțimea vocii"

        Ru ->
            "настройка высоты тона"

        Sk ->
            "Upraviť výšku hlasu"

        Sl ->
            "Prilagodi višino glasu"

        Sq ->
            "Rregullo lartësinë e zërit"

        Sv ->
            "Justera tonhöjd"

        Sw ->
            "Badilisha sauti"

        Tr ->
            "Ses perdesini ayarla"

        Tw ->
            "调整音高"

        Uk ->
            "налаштування висоти тону"

        Ur ->
            "آواز کی پچ ایڈجسٹ کریں"

        Zh ->
            "调整音高"

        _ ->
            "Adjust pitch"


commentHide : Lang -> String
commentHide lang =
    case lang of
        Am ->
            "የቪዲዮ አስተካክል ደብቅ"

        Ar ->
            "إخفاء تعليقات الفيديو"

        Bg ->
            "Скриване на видео коментари"

        Bn ->
            "ভিডিও মন্তব্য লুকান"

        Ca ->
            "Amaga els comentaris de vídeo"

        Cs ->
            "Skrýt videokomentáře"

        Da ->
            "Skjul videokommentarer"

        De ->
            "Videokommentare ausblenden"

        El ->
            "Απόκρυψη σχολίων βίντεο"

        Es ->
            "Ocultar los comentarios del video"

        Et ->
            "Peida videokommentaarid"

        Eu ->
            "Ezkutatu bideo-iruzkinak"

        Fa ->
            "مخفی کردن نظرات ویدیو"

        Fi ->
            "Piilota videokommentit"

        Fr ->
            "Masquer les commentaires vidéo"

        Ga ->
            "Folaigh nótaí tráchta físe"

        Hi ->
            "वीडियो टिप्पणियाँ छुपाएं"

        Hr ->
            "Sakrij videokomentare"

        Hu ->
            "Videós megjegyzések elrejtése"

        Hy ->
            "թաքցնել տեսանյութի մեջ մեկնաբանությունները"

        It ->
            "Nascondi i commenti video"

        Ja ->
            "動画のコメントを非表示にする"

        Ka ->
            "დამალე ვიდეო კომენტარები"

        Ko ->
            "비디오 댓글 숨기기"

        Lt ->
            "Slėpti vaizdo komentarus"

        Lv ->
            "Paslēpt video komentārus"

        Nb ->
            "Skjul videokommentarer"

        Nl ->
            "Hide video comments"

        Pa ->
            "ਵੀਡੀਓ ਟਿੱਪਣੀਆਂ ਛੁਪਾਓ"

        Pl ->
            "Ukryj komentarze wideo"

        Pt ->
            "Ocultar comentários do vídeo"

        Ro ->
            "Ascunde comentariile video"

        Ru ->
            "Скрыть комментарии к видео"

        Sk ->
            "Skryť videokomentáre"

        Sl ->
            "Skrij video komentarje"

        Sq ->
            "Fshih komentet me video"

        Sv ->
            "Dölj videokommentarer"

        Sw ->
            "Ficha maoni ya video"

        Tr ->
            "Video yorumlarını gizle"

        Tw ->
            "隱藏影片評論"

        Uk ->
            "Приховати коментарі до відео"

        Ur ->
            "ویڈیو تبصرے چھپائیں"

        Zh ->
            "隱藏影片評論"

        _ ->
            "Hide video comments"


no_translation : Lang -> String
no_translation lang =
    case lang of
        Am ->
            "በመሆን ላይ ምንም ተስተካክል የለም"

        Ar ->
            "لا يوجد ترجمة حتى الآن"

        Bg ->
            "Без превод"

        Bn ->
            "এখনও অনুবাদ নেই"

        Ca ->
            "encara no hi ha cap traducció"

        Cs ->
            "překlad zatím není k dispozici"

        Da ->
            "endnu ingen oversættelse"

        De ->
            "noch keine Übersetzungen vorhanden"

        El ->
            "δεν υπάρχει ακόμη μετάφραση"

        Es ->
            "aún sin traducción"

        Et ->
            "tõlge pole veel saadaval"

        Eu ->
            "oraindik ez dago itzulpenik"

        Fa ->
            "در دست ترجمه"

        Fi ->
            "käännöstä ei vielä ole"

        Fr ->
            "traductions non disponibles"

        Ga ->
            "níl aistriúchán ar fáil fós"

        Hi ->
            "अभी तक कोई अनुवाद उपलब्ध नहीं है"

        Hr ->
            "prijevod još nije dostupan"

        Hu ->
            "még nincs fordítás"

        Hy ->
            "դեռ թագմանություն չկա"

        It ->
            "ancora non tradotto"

        Ja ->
            "まだ翻訳されていません"

        Ka ->
            "ჯერ არ არის თარგმანი"

        Ko ->
            "번역되지 않음"

        Lt ->
            "vertimo dar nėra"

        Lv ->
            "tulkojums vēl nav pieejams"

        Nb ->
            "ingen oversettelse ennå"

        Nl ->
            "noch geen vertaling aanwezig"

        Pa ->
            "ਅਜੇ ਅਨੁਵਾਦ ਨਹੀਂ ਹੈ"

        Pl ->
            "brak tłumaczenia"

        Pt ->
            "ainda não traduzido"

        Ro ->
            "nu există încă o traducere"

        Ru ->
            "перевода пока нет"

        Sk ->
            "preklad zatiaľ nie je k dispozícii"

        Sl ->
            "prevod še ni na voljo"

        Sq ->
            "ende nuk ka përkthim"

        Sv ->
            "ingen översättning ännu"

        Sw ->
            "hakuna tafsiri bado"

        Tr ->
            "henüz çeviri yok"

        Tw ->
            "尚未翻譯"

        Uk ->
            "переклад відсутній"

        Ur ->
            "ابھی تک کوئی ترجمہ نہیں"

        Zh ->
            "尚未翻譯"

        _ ->
            "no translation yet"


translateWithGoogle : Lang -> String
translateWithGoogle lang =
    case lang of
        Am ->
            "በ Google ትርጉም (ምርጥ) ተመርጧል"

        Ar ->
            "ترجمة من جوجل (تجريبي)"

        Bg ->
            "Превод с Google (експериментално)"

        Bn ->
            "Google দিয়ে অনুবাদ করুন (প্রায়োগিক)"

        Ca ->
            "Tradueix amb Google (experimental)"

        Cs ->
            "Přeložit pomocí Googlu (experimentální)"

        Da ->
            "Oversæt med Google (eksperimentelt)"

        De ->
            "Mit Google übersetzen (experimentell)"

        El ->
            "Μετάφραση με το Google (πειραματικό)"

        Es ->
            "Traducir con Google (experimental)"

        Et ->
            "Tõlgi Google'iga (eksperimentaalne)"

        Eu ->
            "Itzuli Google-rekin (esperimentala)"

        Fa ->
            "ترجمه با Google (آزمایشی)"

        Fi ->
            "Käännä Googlella (kokeellinen)"

        Fr ->
            "Traduire avec Google (expérimental)"

        Ga ->
            "Aistrigh le Google (turgnamhach)"

        Hi ->
            "Google के साथ अनुवाद करें (प्रायोगिक)"

        Hr ->
            "Prevedi pomoću Googlea (eksperimentalno)"

        Hu ->
            "Fordítás a Google segítségével (kísérleti)"

        Hy ->
            "Թարգմանեք Google- ի միջոցով (փորձնական)"

        It ->
            "Tradurre con Google (sperimentale)"

        Ja ->
            "Google翻訳で翻訳する（実験的）"

        Ka ->
            "თარგმნა Google-ის დახმარებით (ექსპერიმენტული)"

        Ko ->
            "Google Translate로 번역하기 (실험적 기능)"

        Lt ->
            "Versti su „Google“ (eksperimentinė funkcija)"

        Lv ->
            "Tulkot ar Google (eksperimentāli)"

        Nb ->
            "Oversett med Google (eksperimentelt)"

        Nl ->
            "Vertalen met Google (experimenteel)"

        Pa ->
            "ਗੂਗਲ ਵਿੱਚ ਅਨੁਵਾਦ ਕਰੋ (ਪ੍ਰਯੋਗਾਤਮਕ)"

        Pl ->
            "Przetłumacz za pomocą Google (eksperymentalne)"

        Pt ->
            "Traduzir com Google (experimental)"

        Ro ->
            "Tradu cu Google (experimental)"

        Ru ->
            "Перевести с Google (экспериментально)"

        Sk ->
            "Preložiť pomocou Googlu (experimentálne)"

        Sl ->
            "Prevedi z Googlom (poskusno)"

        Sq ->
            "Përkthe me Google (eksperimentale)"

        Sv ->
            "Översätt med Google (experimentellt)"

        Sw ->
            "Tafsiri na Google (majaribio)"

        Tr ->
            "Google ile çevir (deneysel)"

        Tw ->
            "与Google进行翻译（实验性）"

        Uk ->
            "Перекласти за допомогою Google (експериментально)"

        Ur ->
            "گوگل کے ساتھ ترجمہ کریں (تجربی)"

        Zh ->
            "与Google进行翻译（实验性）"

        _ ->
            "Translate with Google (experimental)"


cColor : Lang -> String
cColor lang =
    case lang of
        Am ->
            "ቀለም"

        Ar ->
            "لون"

        Bg ->
            "Цвят"

        Bn ->
            "রঙ"

        Ca ->
            "Color"

        Cs ->
            "Barva"

        Da ->
            "Farve"

        De ->
            "Farbe"

        El ->
            "Χρώμα"

        Es ->
            "color"

        Et ->
            "Värv"

        Eu ->
            "Kolorea"

        Fa ->
            "رنگ"

        Fi ->
            "Väri"

        Fr ->
            "Couleur"

        Ga ->
            "Dath"

        Hi ->
            "रंग"

        Hr ->
            "Boja"

        Hu ->
            "Szín"

        Hy ->
            "գույն"

        It ->
            "colore"

        Ja ->
            "色"

        Ka ->
            "ფერი"

        Ko ->
            "색상"

        Lt ->
            "Spalva"

        Lv ->
            "Krāsa"

        Nb ->
            "Farge"

        Nl ->
            "kleur"

        Pa ->
            "ਰੰਗ"

        Pl ->
            "Kolor"

        Pt ->
            "Cor"

        Ro ->
            "Culoare"

        Ru ->
            "цвет"

        Sk ->
            "Farba"

        Sl ->
            "Barva"

        Sq ->
            "Ngjyra"

        Sv ->
            "Färg"

        Sw ->
            "Rangi"

        Tr ->
            "Renk"

        Tw ->
            "顏色"

        Uk ->
            "колір"

        Ur ->
            "رنگ"

        Zh ->
            "顏色"

        _ ->
            "Color"


cSchema : Lang -> String
cSchema lang =
    case lang of
        Am ->
            "ቀለም ሥነጽሑፍ"

        Ar ->
            "نظام الألوان"

        Bg ->
            "Цветова схема"

        Bn ->
            "রঙের স্কিম"

        Ca ->
            "Esquema de colors"

        Cs ->
            "Barevné schéma"

        Da ->
            "Farveskema"

        De ->
            "Farbschema"

        El ->
            "Συνδυασμός χρωμάτων"

        Es ->
            "Esquema de colores"

        Et ->
            "Värviskeem"

        Eu ->
            "Kolore-eskema"

        Fa ->
            "طرح رنگی"

        Fi ->
            "Värimalli"

        Fr ->
            "Schéma de couleurs"

        Ga ->
            "Scéim dathanna"

        Hi ->
            "रंग योजना"

        Hr ->
            "Shema boja"

        Hu ->
            "Színséma"

        Hy ->
            "Գունային սխեման"

        It ->
            "Schema di colori"

        Ja ->
            "カラースキーム"

        Ka ->
            "ფერის გეგმა"

        Ko ->
            "색상 스키마"

        Lt ->
            "Spalvų schema"

        Lv ->
            "Krāsu shēma"

        Nb ->
            "Fargevalg"

        Nl ->
            "Kleurenschema"

        Pa ->
            "ਰੰਗ ਸਕੀਮ"

        Pl ->
            "Schemat kolorów"

        Pt ->
            "Esquema de cores"

        Ro ->
            "Schemă de culori"

        Ru ->
            "Цветовая схема"

        Sk ->
            "Farebná schéma"

        Sl ->
            "Barvna shema"

        Sq ->
            "Skema e ngjyrave"

        Sv ->
            "Färgschema"

        Sw ->
            "Mpango wa rangi"

        Tr ->
            "Renk şeması"

        Tw ->
            "配色方案"

        Uk ->
            "Кольорова схема"

        Ur ->
            "رنگ سکیم"

        Zh ->
            "配色方案"

        _ ->
            "Color scheme"


cDark : Lang -> String
cDark lang =
    case lang of
        Am ->
            "እንቅስቃሴ"

        Ar ->
            "الوضع المظلم"

        Bg ->
            "тъмен режим"

        Bn ->
            "ডার্ক মোড"

        Ca ->
            "Mode fosc"

        Cs ->
            "Tmavý režim"

        Da ->
            "Mørk tilstand"

        De ->
            "Dunkelmodus"

        El ->
            "Σκοτεινή λειτουργία"

        Es ->
            "modo oscuro"

        Et ->
            "Tume režiim"

        Eu ->
            "Modu iluna"

        Fa ->
            "حالت تاریک"

        Fi ->
            "Tumma tila"

        Fr ->
            "Mode sombre"

        Ga ->
            "Mód dorcha"

        Hi ->
            "डार्क मोड"

        Hr ->
            "Tamni način"

        Hu ->
            "Sötét mód"

        Hy ->
            "մութ ռեժիմ"

        It ->
            "modo scuro"

        Ja ->
            "ダークモード"

        Ka ->
            "მუქი რეჟიმი"

        Ko ->
            "다크 모드"

        Lt ->
            "Tamsus režimas"

        Lv ->
            "Tumšais režīms"

        Nb ->
            "Mørk modus"

        Nl ->
            "donkere modus"

        Pa ->
            "ਡਾਰਕ ਮੋਡ"

        Pl ->
            "Tryb ciemny"

        Pt ->
            "Modo escuro"

        Ro ->
            "Mod întunecat"

        Ru ->
            "темный режим"

        Sk ->
            "Tmavý režim"

        Sl ->
            "Temni način"

        Sq ->
            "Modaliteti i errët"

        Sv ->
            "Mörkt läge"

        Sw ->
            "Hali ya Giza"

        Tr ->
            "Koyu mod"

        Tw ->
            "暗模式"

        Uk ->
            "темний режим"

        Ur ->
            "تاریک موڈ"

        Zh ->
            "暗模式"

        _ ->
            "Dark-Mode"


cBright : Lang -> String
cBright lang =
    case lang of
        Am ->
            "እንደዛሬ"

        Ar ->
            "وضع الإضاءة"

        Bg ->
            "светъл режим"

        Bn ->
            "লাইট মোড"

        Ca ->
            "Mode clar"

        Cs ->
            "Světlý režim"

        Da ->
            "Lys tilstand"

        De ->
            "Hellmodus"

        El ->
            "Φωτεινή λειτουργία"

        Es ->
            "modo claro"

        Et ->
            "Hele režiim"

        Eu ->
            "Modu argia"

        Fa ->
            "حالت روشن"

        Fi ->
            "Vaalea tila"

        Fr ->
            "Mode clair"

        Ga ->
            "Mód geal"

        Hi ->
            "लाइट मोड"

        Hr ->
            "Svijetli način"

        Hu ->
            "Világos mód"

        Hy ->
            "թեթև ռեժիմ"

        It ->
            "modo chiaro"

        Ja ->
            "ライトモード"

        Ka ->
            "ნათელი რეჟიმი"

        Ko ->
            "라이트 모드"

        Lt ->
            "Šviesus režimas"

        Lv ->
            "Gaišais režīms"

        Nb ->
            "Lys modus"

        Nl ->
            "lichte modus"

        Pa ->
            "ਚਮਕੀਲਾ ਮੋਡ"

        Pl ->
            "Tryb jasny"

        Pt ->
            "Modo claro"

        Ro ->
            "Mod luminos"

        Ru ->
            "светлый режим"

        Sk ->
            "Svetlý režim"

        Sl ->
            "Svetli način"

        Sq ->
            "Modaliteti i çelët"

        Sv ->
            "Ljust läge"

        Sw ->
            "Modi-Nuru"

        Tr ->
            "Açık mod"

        Tw ->
            "亮模式"

        Uk ->
            "світлий режим"

        Ur ->
            "روشن موڈ"

        Zh ->
            "亮模式"

        _ ->
            "Light-Mode"


cDefault : Lang -> String
cDefault lang =
    case lang of
        Am ->
            "ነባሪ"

        Ar ->
            "المعيار الافتراضي"

        Bg ->
            "Подразбиране"

        Bn ->
            "ডিফল্ট"

        Ca ->
            "Per defecte"

        Cs ->
            "Výchozí"

        Da ->
            "Standard"

        De ->
            "Standard"

        El ->
            "Προεπιλογή"

        Es ->
            "defecto"

        Et ->
            "Vaikimisi"

        Eu ->
            "Lehenetsia"

        Fa ->
            "پیشفرض"

        Fi ->
            "Oletus"

        Fr ->
            "Standard"

        Ga ->
            "Réamhshocrú"

        Hi ->
            "डिफ़ॉल्ट"

        Hr ->
            "Zadano"

        Hu ->
            "Alapértelmezett"

        Hy ->
            "կանխադրված"

        It ->
            "predefinito"

        Ja ->
            "デフォルト"

        Ka ->
            "ნაგულისხმევი"

        Ko ->
            "기본"

        Lt ->
            "Numatytoji"

        Lv ->
            "Noklusējuma"

        Nb ->
            "Standard"

        Nl ->
            "standaard"

        Pa ->
            "ਮੂਲ"

        Pl ->
            "Domyślny"

        Pt ->
            "Padrão"

        Ro ->
            "Implicit"

        Ru ->
            "стандарт по умолчанию"

        Sk ->
            "Predvolené"

        Sl ->
            "Privzeto"

        Sq ->
            "Parazgjedhja"

        Sv ->
            "Standard"

        Sw ->
            "Chaguomsingi"

        Tr ->
            "Varsayılan"

        Tw ->
            "預設"

        Uk ->
            "стандартний"

        Ur ->
            "پہلے سے طے شدہ"

        Zh ->
            "預設"

        _ ->
            "Default"


cBlue : Lang -> String
cBlue lang =
    case lang of
        Am ->
            "ሰማያዊ"

        Ar ->
            "أزرق"

        Bg ->
            "Синьо"

        Bn ->
            "নীল"

        Ca ->
            "Blau"

        Cs ->
            "Modrá"

        Da ->
            "Blå"

        De ->
            "Blau"

        El ->
            "Μπλε"

        Es ->
            "azul"

        Et ->
            "Sinine"

        Eu ->
            "Urdina"

        Fa ->
            "آبی"

        Fi ->
            "Sininen"

        Fr ->
            "Bleu"

        Ga ->
            "Gorm"

        Hi ->
            "नीला"

        Hr ->
            "Plava"

        Hu ->
            "Kék"

        Hy ->
            "կապույտ"

        It ->
            "blu"

        Ja ->
            "青"

        Ka ->
            "ლურჯი"

        Ko ->
            "파랑"

        Lt ->
            "Mėlyna"

        Lv ->
            "Zila"

        Nb ->
            "Blå"

        Nl ->
            "blauw"

        Pa ->
            "ਨੀਲਾ"

        Pl ->
            "Niebieski"

        Pt ->
            "Azul"

        Ro ->
            "Albastru"

        Ru ->
            "синий"

        Sk ->
            "Modrá"

        Sl ->
            "Modra"

        Sq ->
            "Blu"

        Sv ->
            "Blå"

        Sw ->
            "Bluu"

        Tr ->
            "Mavi"

        Tw ->
            "藍色"

        Uk ->
            "синій"

        Ur ->
            "نیلا"

        Zh ->
            "藍色"

        _ ->
            "Blue"


cRed : Lang -> String
cRed lang =
    case lang of
        Am ->
            "ቀይ"

        Ar ->
            "أحمر"

        Bg ->
            "червен"

        Bn ->
            "লাল"

        Ca ->
            "Vermell"

        Cs ->
            "Červená"

        Da ->
            "Rød"

        De ->
            "Rot"

        El ->
            "Κόκκινο"

        Es ->
            "rojo"

        Et ->
            "Punane"

        Eu ->
            "Gorria"

        Fa ->
            "قرمز"

        Fi ->
            "Punainen"

        Fr ->
            "Rouge"

        Ga ->
            "Dearg"

        Hi ->
            "लाल"

        Hr ->
            "Crvena"

        Hu ->
            "Piros"

        Hy ->
            "կարմիր"

        It ->
            "rosso"

        Ja ->
            "赤"

        Ka ->
            "წითელი"

        Ko ->
            "빨강"

        Lt ->
            "Raudona"

        Lv ->
            "Sarkana"

        Nb ->
            "Rød"

        Nl ->
            "rood"

        Pa ->
            "ਲਾਲ"

        Pl ->
            "Czerwony"

        Pt ->
            "Vermelho"

        Ro ->
            "Roșu"

        Ru ->
            "красный"

        Sk ->
            "Červená"

        Sl ->
            "Rdeča"

        Sq ->
            "E kuqe"

        Sv ->
            "Röd"

        Sw ->
            "nyekundu"

        Tr ->
            "Kırmızı"

        Tw ->
            "红色的"

        Uk ->
            "червоний"

        Ur ->
            "سرخ"

        Zh ->
            "红色的"

        _ ->
            "Red"


cYellow : Lang -> String
cYellow lang =
    case lang of
        Am ->
            "ቢጫ"

        Ar ->
            "أصفر"

        Bg ->
            "жълт"

        Bn ->
            "হলুদ"

        Ca ->
            "Groc"

        Cs ->
            "Žlutá"

        Da ->
            "Gul"

        De ->
            "Gelb"

        El ->
            "Κίτρινο"

        Es ->
            "amarillo"

        Et ->
            "Kollane"

        Eu ->
            "Horia"

        Fa ->
            "رنگ زرد"

        Fi ->
            "Keltainen"

        Fr ->
            "Jaune"

        Ga ->
            "Buí"

        Hi ->
            "पीला"

        Hr ->
            "Žuta"

        Hu ->
            "Sárga"

        Hy ->
            "դեղին"

        It ->
            "giallo"

        Ja ->
            "黄色"

        Ka ->
            "ყვითელი"

        Ko ->
            "노랑"

        Lt ->
            "Geltona"

        Lv ->
            "Dzeltena"

        Nb ->
            "Gul"

        Nl ->
            "geel"

        Pa ->
            "ਪੀਲਾ"

        Pl ->
            "Żółty"

        Pt ->
            "Amarelo"

        Ro ->
            "Galben"

        Ru ->
            "желтый"

        Sk ->
            "Žltá"

        Sl ->
            "Rumena"

        Sq ->
            "E verdhë"

        Sv ->
            "Gul"

        Sw ->
            "Njano"

        Tr ->
            "Sarı"

        Tw ->
            "黄色的"

        Uk ->
            "жовтий"

        Ur ->
            "پیلا"

        Zh ->
            "黄色的"

        _ ->
            "Yellow"


cTurquoise : Lang -> String
cTurquoise lang =
    case lang of
        Am ->
            "ዓሣደኝ"

        Ar ->
            "فيروزي"

        Bg ->
            "тюркоаз"

        Bn ->
            "টার্কোয়াজ"

        Ca ->
            "Turquesa"

        Cs ->
            "Tyrkysová"

        Da ->
            "Turkis"

        De ->
            "Türkis"

        El ->
            "Τιρκουάζ"

        Es ->
            "turquesa"

        Et ->
            "Türkiissinine"

        Eu ->
            "Turkesa"

        Fa ->
            "فیروزه"

        Fi ->
            "Turkoosi"

        Fr ->
            "Turquoise"

        Ga ->
            "Turcaid"

        Hi ->
            "फ़िरोज़ा"

        Hr ->
            "Tirkizna"

        Hu ->
            "Türkiz"

        Hy ->
            "փիրուզագույն"

        It ->
            "turchese"

        Ja ->
            "ターコイズ"

        Ka ->
            "თურქიზი"

        Ko ->
            "청록"

        Lt ->
            "Turkio"

        Lv ->
            "Tirkīza"

        Nb ->
            "Turkis"

        Nl ->
            "turkoois"

        Pa ->
            "ਫੀਰੋਜ਼ੀ"

        Pl ->
            "Turkusowy"

        Pt ->
            "Turquesa"

        Ro ->
            "Turcoaz"

        Ru ->
            "бирюзовый"

        Sk ->
            "Tyrkysová"

        Sl ->
            "Turkizna"

        Sq ->
            "Bruz"

        Sv ->
            "Turkos"

        Sw ->
            "Turquoise"

        Tr ->
            "Turkuaz"

        Tw ->
            "绿松石"

        Uk ->
            "бірюзовий"

        Ur ->
            "فیروزی"

        Zh ->
            "绿松石"

        _ ->
            "Turquoise"


fullscreenEnter : Lang -> String
fullscreenEnter lang =
    case lang of
        Am ->
            "ሙሉ ማስታወሻ"

        Ar ->
            "الدخول إلى وضع العرض الكامل"

        Bg ->
            "Влезте в цял екран"

        Bn ->
            "ফুলস্ক্রিনে ঢুকুন"

        Ca ->
            "Entra a pantalla completa"

        Cs ->
            "Přejít na celou obrazovku"

        Da ->
            "Aktivér fuld skærm"

        De ->
            "Vollbildmodus aktivieren"

        El ->
            "Είσοδος σε πλήρη οθόνη"

        Es ->
            "entrar en pantalla completa"

        Et ->
            "Ava täisekraan"

        Eu ->
            "Sartu pantaila osoko moduan"

        Fa ->
            "ورود به حالت تمام صفحه"

        Fi ->
            "Siirry koko näytön tilaan"

        Fr ->
            "Passer en plein écran"

        Ga ->
            "Téigh go lánscáileán"

        Hi ->
            "पूर्ण स्क्रीन में जाएं"

        Hr ->
            "Uključi prikaz preko cijelog zaslona"

        Hu ->
            "Teljes képernyő megnyitása"

        Hy ->
            "մոտեցնել լիավանդակային ռեժիմ"

        It ->
            "Entra a schermo intero"

        Ja ->
            "フルスクリーンに入る"

        Ka ->
            "სრულეკრანი"

        Ko ->
            "전체 화면으로"

        Lt ->
            "Įjungti viso ekrano režimą"

        Lv ->
            "Ieslēgt pilnekrāna režīmu"

        Nb ->
            "Åpne fullskjerm"

        Nl ->
            "Volledig scherm"

        Pa ->
            "ਪੂਰੀ ਸਕ੍ਰੀਨ"

        Pl ->
            "Włącz pełny ekran"

        Pt ->
            "Entrar em tela cheia"

        Ro ->
            "Intră în modul ecran complet"

        Ru ->
            "перейти в полноэкранный режим"

        Sk ->
            "Prejsť na celú obrazovku"

        Sl ->
            "Vklopi celozaslonski način"

        Sq ->
            "Hap ekranin e plotë"

        Sv ->
            "Aktivera helskärm"

        Sw ->
            "Ingia kwenye skrini kamili"

        Tr ->
            "Tam ekrana geç"

        Tw ->
            "進入全屏模式"

        Uk ->
            "увімкнути повноекранний режим"

        Ur ->
            "پوری سکرین"

        Zh ->
            "進入全屏模式"

        _ ->
            "Enter Fullscreen"


fullscreenExit : Lang -> String
fullscreenExit lang =
    case lang of
        Am ->
            "ሙሉ ማስታወሻ ያድርጉz6"

        Ar ->
            "الخروج من وضع العرض الكامل"

        Bg ->
            "Излезте от цял екран"

        Bn ->
            "ফুলস্ক্রিন থেকে বের হোন"

        Ca ->
            "Surt de pantalla completa"

        Cs ->
            "Ukončit režim celé obrazovky"

        Da ->
            "Afslut fuld skærm"

        De ->
            "Vollbildmodus beenden"

        El ->
            "Έξοδος από πλήρη οθόνη"

        Es ->
            "salir de pantalla completa"

        Et ->
            "Välju täisekraanist"

        Eu ->
            "Irten pantaila osoko modutik"

        Fa ->
            "خروج از حالت تمام صفحه"

        Fi ->
            "Poistu koko näytön tilasta"

        Fr ->
            "Quitter le plein écran"

        Ga ->
            "Scoir den lánscáileán"

        Hi ->
            "पूर्ण स्क्रीन से बाहर निकलें"

        Hr ->
            "Izađi iz prikaza preko cijelog zaslona"

        Hu ->
            "Kilépés a teljes képernyőből"

        Hy ->
            "դուրս գալ լիավանդակային ռեժիմից"

        It ->
            "Esci da schermo intero"

        Ja ->
            "フルスクリーンを終了する"

        Ka ->
            "გამოსვლა"

        Ko ->
            "전체 화면에서 나가기"

        Lt ->
            "Išjungti viso ekrano režimą"

        Lv ->
            "Iziet no pilnekrāna režīma"

        Nb ->
            "Avslutt fullskjerm"

        Nl ->
            "Volledig scherm verlaten"

        Pa ->
            "ਪੂਰੀ ਸਕ੍ਰੀਨ ਤੋਂ ਬਾਹਰ"

        Pl ->
            "Wyłącz pełny ekran"

        Pt ->
            "Sair da tela cheia"

        Ro ->
            "Ieși din modul ecran complet"

        Ru ->
            "выйти из полноэкранного режима"

        Sk ->
            "Ukončiť režim celej obrazovky"

        Sl ->
            "Izklopi celozaslonski način"

        Sq ->
            "Dil nga ekrani i plotë"

        Sv ->
            "Avsluta helskärm"

        Sw ->
            "Toka kwenye skrini kamili"

        Tr ->
            "Tam ekrandan çık"

        Tw ->
            "退出全屏模式"

        Uk ->
            "вийти з повноекранного режиму"

        Ur ->
            "پوری سکرین سے باہر"

        Zh ->
            "退出全屏模式"

        _ ->
            "Exit Fullscreen"


modeMode : Lang -> String
modeMode lang =
    case lang of
        Am ->
            "ዘመን ተዘጋጅ"

        Ar ->
            "وضع العرض"

        Bg ->
            "Режим на презентация"

        Bn ->
            "প্রস্তুতির মোড"

        Ca ->
            "Mode de presentació"

        Cs ->
            "Režim prezentace"

        Da ->
            "Præsentationstilstand"

        De ->
            "Präsentationsmodus"

        El ->
            "Λειτουργία παρουσίασης"

        Es ->
            "Modo presentación"

        Et ->
            "Esitusrežiim"

        Eu ->
            "Aurkezpen-modua"

        Fa ->
            "حالت ارائه"

        Fi ->
            "Esitystila"

        Fr ->
            "Mode de présentation"

        Ga ->
            "Mód cur i láthair"

        Hi ->
            "प्रेजेंटेशन मोड"

        Hr ->
            "Način prezentacije"

        Hu ->
            "Bemutató mód"

        Hy ->
            "Ներկայացման ռեժիմ"

        It ->
            "Modo presentazione"

        Ja ->
            "プレゼンテーションモード"

        Ka ->
            "პრეზენტაციის რეჟიმი"

        Ko ->
            "프레젠테이션 모드"

        Lt ->
            "Pateikimo režimas"

        Lv ->
            "Prezentācijas režīms"

        Nb ->
            "Presentasjonsmodus"

        Nl ->
            "Presentatiemodus"

        Pa ->
            "ਪ੍ਰਸਤੁਤੀ ਮੋਡ"

        Pl ->
            "Tryb prezentacji"

        Pt ->
            "Modo apresentação"

        Ro ->
            "Mod de prezentare"

        Ru ->
            "режим презентации"

        Sk ->
            "Režim prezentácie"

        Sl ->
            "Način predstavitve"

        Sq ->
            "Modaliteti i prezantimit"

        Sv ->
            "Presentationsläge"

        Sw ->
            "Hali ya uwasilishaji"

        Tr ->
            "Sunum modu"

        Tw ->
            "简报模式"

        Uk ->
            "режим презентації"

        Ur ->
            "پریزنٹیشن موڈ"

        Zh ->
            "简报模式"

        _ ->
            "Presentation mode"


modeTextbook : Lang -> String
modeTextbook lang =
    case lang of
        Am ->
            "ተማሪ መስመር"

        Ar ->
            "المقرر"

        Bg ->
            "Текст"

        Bn ->
            "টেক্সটবুক"

        Ca ->
            "Llibre de text"

        Cs ->
            "Učebnice"

        Da ->
            "Lærebog"

        De ->
            "Lehrbuch"

        El ->
            "Εγχειρίδιο"

        Es ->
            "Manual"

        Et ->
            "Õpik"

        Eu ->
            "Testuliburua"

        Fa ->
            "کتاب"

        Fi ->
            "Oppikirja"

        Fr ->
            "Manuel"

        Ga ->
            "Téacsleabhar"

        Hi ->
            "पाठ्यपुस्तक"

        Hr ->
            "Udžbenik"

        Hu ->
            "Tankönyv"

        Hy ->
            "գիրք"

        It ->
            "Manuale"

        Ja ->
            "教科書"

        Ka ->
            "ტექსტური"

        Ko ->
            "텍스트 북"

        Lt ->
            "Vadovėlis"

        Lv ->
            "Mācību grāmata"

        Nb ->
            "Lærebok"

        Nl ->
            "Studieboek"

        Pa ->
            "ਟੈਕਸਟਬੁੱਕ"

        Pl ->
            "Podręcznik"

        Pt ->
            "Livro-texto"

        Ro ->
            "Manual"

        Ru ->
            "чтения"

        Sk ->
            "Učebnica"

        Sl ->
            "Učbenik"

        Sq ->
            "Libër mësimor"

        Sv ->
            "Lärobok"

        Sw ->
            "Kitabu cha maandishi"

        Tr ->
            "Ders kitabı"

        Tw ->
            "教科書"

        Uk ->
            "навчальна книга"

        Ur ->
            "ٹیکسٹ بک"

        Zh ->
            "教科書"

        _ ->
            "Textbook"


modePresentation : Lang -> String
modePresentation lang =
    case lang of
        Am ->
            "እንቅስቃሴ"

        Ar ->
            "العرض"

        Bg ->
            "Презентация"

        Bn ->
            "প্রেজেন্টেশন"

        Ca ->
            "Presentació"

        Cs ->
            "Prezentace"

        Da ->
            "Præsentation"

        De ->
            "Präsentation"

        El ->
            "Παρουσίαση"

        Es ->
            "Presentación"

        Et ->
            "Esitlus"

        Eu ->
            "Aurkezpena"

        Fa ->
            "ارائه"

        Fi ->
            "Esitys"

        Fr ->
            "Présentation"

        Ga ->
            "Cur i láthair"

        Hi ->
            "प्रस्तुति"

        Hr ->
            "Prezentacija"

        Hu ->
            "Bemutató"

        Hy ->
            "ներկայացում"

        It ->
            "Presentazione"

        Ja ->
            "プレゼンテーション"

        Ka ->
            "პრეზენტაცია"

        Ko ->
            "프레젠테이션"

        Lt ->
            "Pristatymas"

        Lv ->
            "Prezentācija"

        Nb ->
            "Presentasjon"

        Nl ->
            "Presentatie"

        Pa ->
            "ਪ੍ਰਸਤੁਤੀ"

        Pl ->
            "Prezentacja"

        Pt ->
            "Apresentação"

        Ro ->
            "Prezentare"

        Ru ->
            "презентации"

        Sk ->
            "Prezentácia"

        Sl ->
            "Predstavitev"

        Sq ->
            "Prezantim"

        Sv ->
            "Presentation"

        Sw ->
            "Uwasilishaji"

        Tr ->
            "Sunum"

        Tw ->
            "報告"

        Uk ->
            "презентація"

        Ur ->
            "پریزنٹیشن"

        Zh ->
            "報告"

        _ ->
            "Presentation"


modeSlides : Lang -> String
modeSlides lang =
    case lang of
        Am ->
            "ስላይድስ"

        Ar ->
            "الشرائح"

        Bg ->
            "Слайдове"

        Bn ->
            "স্লাইড"

        Ca ->
            "Diapositives"

        Cs ->
            "Snímky"

        Da ->
            "Dias"

        De ->
            "Folien"

        El ->
            "Διαφάνειες"

        Es ->
            "Imagen"

        Et ->
            "Slaidid"

        Eu ->
            "Diapositibak"

        Fa ->
            "اسلایدها"

        Fi ->
            "Diat"

        Fr ->
            "Diapositives"

        Ga ->
            "Sleamhnáin"

        Hi ->
            "स्लाइड्स"

        Hr ->
            "Slajdovi"

        Hu ->
            "Diák"

        Hy ->
            "սլայդներ"

        It ->
            "Diapositive"

        Ja ->
            "スライド"

        Ka ->
            "სლაიდები"

        Ko ->
            "슬라이드"

        Lt ->
            "Skaidrės"

        Lv ->
            "Slaidi"

        Nb ->
            "Lysbilder"

        Nl ->
            "Folies"

        Pa ->
            "ਸਲਾਈਡ"

        Pl ->
            "Slajdy"

        Pt ->
            "Slides"

        Ro ->
            "Diapozitive"

        Ru ->
            "слайды"

        Sk ->
            "Snímky"

        Sl ->
            "Prosojnice"

        Sq ->
            "Diapozitiva"

        Sv ->
            "Bilder"

        Sw ->
            "Slaidi"

        Tr ->
            "Slaytlar"

        Tw ->
            "幻燈片"

        Uk ->
            "слайди"

        Ur ->
            "سلائیڈز"

        Zh ->
            "幻燈片"

        _ ->
            "Slides"


soundOn : Lang -> String
soundOn lang =
    case lang of
        Am ->
            "ድምጽ አብራ"

        Ar ->
            "الصوت مفعل"

        Bg ->
            "Звук изкл."

        Bn ->
            "শব্দ চালু"

        Ca ->
            "Activa el so"

        Cs ->
            "Zapnout zvuk"

        Da ->
            "Lyd til"

        De ->
            "Sprecher an"

        El ->
            "Ενεργοποίηση ήχου"

        Es ->
            "Sonido encendido"

        Et ->
            "Heli sisse"

        Eu ->
            "Aktibatu soinua"

        Fa ->
            "صدا روشن"

        Fi ->
            "Ääni päälle"

        Fr ->
            "Haut-parleur activé"

        Ga ->
            "Fuaim ar siúl"

        Hi ->
            "स्पीकर ऑन"

        Hr ->
            "Uključi zvuk"

        Hu ->
            "Hang bekapcsolása"

        Hy ->
            "ձայնով"

        It ->
            "Suono attivo"

        Ja ->
            "音声オン"

        Ka ->
            "ხმა ჩართული"

        Ko ->
            "소리 켬"

        Lt ->
            "Įjungti garsą"

        Lv ->
            "Ieslēgt skaņu"

        Nb ->
            "Lyd på"

        Nl ->
            "Luidspreker aan"

        Pa ->
            "ਸਾਊਂਡ ਚਾਲੂ"

        Pl ->
            "Włącz dźwięk"

        Pt ->
            "Som ligado"

        Ro ->
            "Activează sunetul"

        Ru ->
            "звук включён"

        Sk ->
            "Zapnúť zvuk"

        Sl ->
            "Vklopi zvok"

        Sq ->
            "Aktivizo zërin"

        Sv ->
            "Ljud på"

        Sw ->
            "Sauti imewashwa"

        Tr ->
            "Sesi aç"

        Tw ->
            "聲音開啟"

        Uk ->
            "увімкнений"

        Ur ->
            "آواز آن"

        Zh ->
            "聲音開啟"

        _ ->
            "Sound on"


soundOff : Lang -> String
soundOff lang =
    case lang of
        Am ->
            "ድምጽ ያልተጫኑ"

        Ar ->
            "الصوت مقفل"

        Bg ->
            "Звук вкл."

        Bn ->
            "শব্দ বন্ধ"

        Ca ->
            "Desactiva el so"

        Cs ->
            "Vypnout zvuk"

        Da ->
            "Lyd fra"

        De ->
            "Sprecher aus"

        El ->
            "Απενεργοποίηση ήχου"

        Es ->
            "Sonido apagado"

        Et ->
            "Heli välja"

        Eu ->
            "Desaktibatu soinua"

        Fa ->
            "صدا خاموش"

        Fi ->
            "Ääni pois"

        Fr ->
            "Haut-parleur désactivé"

        Ga ->
            "Fuaim múchta"

        Hi ->
            "स्पीकर बंद"

        Hr ->
            "Isključi zvuk"

        Hu ->
            "Hang kikapcsolása"

        Hy ->
            "առանց ձայն"

        It ->
            "Suono disattivato"

        Ja ->
            "音声オフ"

        Ka ->
            "ხმა გამორთული"

        Ko ->
            "소리 끔"

        Lt ->
            "Išjungti garsą"

        Lv ->
            "Izslēgt skaņu"

        Nb ->
            "Lyd av"

        Nl ->
            "Luidspreker uit"

        Pa ->
            "ਸਾਊਂਡ ਬੰਦ"

        Pl ->
            "Wyłącz dźwięk"

        Pt ->
            "Som desligado"

        Ro ->
            "Dezactivează sunetul"

        Ru ->
            "звук выключен"

        Sk ->
            "Vypnúť zvuk"

        Sl ->
            "Izklopi zvok"

        Sq ->
            "Çaktivizo zërin"

        Sv ->
            "Ljud av"

        Sw ->
            "Sauti imezimwa"

        Tr ->
            "Sesi kapat"

        Tw ->
            "聲音關閉"

        Uk ->
            "вимкнений"

        Ur ->
            "آواز بند"

        Zh ->
            "聲音關閉"

        _ ->
            "Sound off"


infoAuthor : Lang -> String
infoAuthor lang =
    case lang of
        Am ->
            "ሰላም ያለፈ: "

        Ar ->
            "مؤلف"

        Bg ->
            "Автор: "

        Bn ->
            "লেখক: "

        Ca ->
            "Autor: "

        Cs ->
            "Autor: "

        Da ->
            "Forfatter: "

        De ->
            "Autor: "

        El ->
            "Συγγραφέας: "

        Es ->
            "Autor"

        Et ->
            "Autor: "

        Eu ->
            "Egilea: "

        Fa ->
            "نویسنده: "

        Fi ->
            "Tekijä: "

        Fr ->
            "Auteur : "

        Ga ->
            "Údar: "

        Hi ->
            "लेखक:"

        Hr ->
            "Autor: "

        Hu ->
            "Szerző: "

        Hy ->
            "հեղինակ: "

        It ->
            "Autore: "

        Ja ->
            "著者："

        Ka ->
            "ავტორი: "

        Ko ->
            "저자: "

        Lt ->
            "Autorius: "

        Lv ->
            "Autors: "

        Nb ->
            "Forfatter: "

        Nl ->
            "Auteur: "

        Pa ->
            "ਲੇਖਕ: "

        Pl ->
            "Autor: "

        Pt ->
            "Autor: "

        Ro ->
            "Autor: "

        Ru ->
            "автор: "

        Sk ->
            "Autor: "

        Sl ->
            "Avtor: "

        Sq ->
            "Autori: "

        Sv ->
            "Författare: "

        Sw ->
            "Mwandishi: "

        Tr ->
            "Yazar: "

        Tw ->
            "作者: "

        Uk ->
            "автор: "

        Ur ->
            "مصنف: "

        Zh ->
            "作者: "

        _ ->
            "Author: "


infoAuthors : Lang -> String
infoAuthors lang =
    case lang of
        Am ->
            "ሰላም ያለፈውን: "

        Ar ->
            "المؤلفون"

        Bg ->
            "Автори: "

        Bn ->
            "লেখকবৃন্দ: "

        Ca ->
            "Autors: "

        Cs ->
            "Autoři: "

        Da ->
            "Forfattere: "

        De ->
            "Autoren: "

        El ->
            "Συγγραφείς: "

        Es ->
            "Autores"

        Et ->
            "Autorid: "

        Eu ->
            "Egileak: "

        Fa ->
            "نویسندگان: "

        Fi ->
            "Tekijät: "

        Fr ->
            "Auteurs : "

        Ga ->
            "Údair: "

        Hi ->
            "लेखकों:"

        Hr ->
            "Autori: "

        Hu ->
            "Szerzők: "

        Hy ->
            "հեղինակներ: "

        It ->
            "Autori: "

        Ja ->
            "著者："

        Ka ->
            "ავტორები: "

        Ko ->
            "저자: "

        Lt ->
            "Autoriai: "

        Lv ->
            "Autori: "

        Nb ->
            "Forfattere: "

        Nl ->
            "Auteurs: "

        Pa ->
            "ਲੇਖਕ: "

        Pl ->
            "Autorzy: "

        Pt ->
            "Autores: "

        Ro ->
            "Autori: "

        Ru ->
            "авторы: "

        Sk ->
            "Autori: "

        Sl ->
            "Avtorji: "

        Sq ->
            "Autorët: "

        Sv ->
            "Författare: "

        Sw ->
            "Waandishi: "

        Tr ->
            "Yazarlar: "

        Tw ->
            "作者: "

        Uk ->
            "автори: "

        Ur ->
            "مصنفین: "

        Zh ->
            "作者: "

        _ ->
            "Authors: "


infoDate : Lang -> String
infoDate lang =
    case lang of
        Am ->
            "ቀን: "

        Ar ->
            "التاريخ"

        Bg ->
            "Дата: "

        Bn ->
            "তারিখ: "

        Ca ->
            "Data: "

        Cs ->
            "Datum: "

        Da ->
            "Dato: "

        De ->
            "Datum: "

        El ->
            "Ημερομηνία: "

        Es ->
            "fecha"

        Et ->
            "Kuupäev: "

        Eu ->
            "Data: "

        Fa ->
            "تاریخ: "

        Fi ->
            "Päivämäärä: "

        Fr ->
            "Date : "

        Ga ->
            "Dáta: "

        Hi ->
            "तारीख:"

        Hr ->
            "Datum: "

        Hu ->
            "Dátum: "

        Hy ->
            "ամսաթիվ: "

        It ->
            "Data: "

        Ja ->
            "日付："

        Ka ->
            "თარიღი: "

        Ko ->
            "날짜: "

        Lt ->
            "Data: "

        Lv ->
            "Datums: "

        Nb ->
            "Dato: "

        Nl ->
            "Datum: "

        Pa ->
            "ਮਿਤੀ: "

        Pl ->
            "Data: "

        Pt ->
            "Data: "

        Ro ->
            "Data: "

        Ru ->
            "дата: "

        Sk ->
            "Dátum: "

        Sl ->
            "Datum: "

        Sq ->
            "Data: "

        Sv ->
            "Datum: "

        Sw ->
            "Tarehe: "

        Tr ->
            "Tarih: "

        Tw ->
            "日期: "

        Uk ->
            "дата: "

        Ur ->
            "تاریخ: "

        Zh ->
            "日期: "

        _ ->
            "Date: "


infoEmail : Lang -> String
infoEmail lang =
    case lang of
        Am ->
            "ኢሜል: "

        Ar ->
            "البريد الإلكتروني"

        Bg ->
            "Имейл: "

        Bn ->
            "ইমেইল: "

        Ca ->
            "Correu electrònic: "

        Cs ->
            "E-mail: "

        Da ->
            "E-mail: "

        De ->
            "E-Mail: "

        El ->
            "Email: "

        Es ->
            "email"

        Et ->
            "E-post: "

        Eu ->
            "Posta elektronikoa: "

        Fa ->
            "ایمیل: "

        Fi ->
            "Sähköposti: "

        Fr ->
            "Email : "

        Ga ->
            "Ríomhphost: "

        Hi ->
            "ईमेल:"

        Hr ->
            "E-pošta: "

        Hu ->
            "E-mail: "

        Hy ->
            "էլ. փոստ: "

        It ->
            "Email: "

        Ja ->
            "メール："

        Ka ->
            "იმეილი: "

        Ko ->
            "이메일: "

        Lt ->
            "El. paštas: "

        Lv ->
            "E-pasts: "

        Nb ->
            "E-post: "

        Nl ->
            "E-mail: "

        Pa ->
            "ਈਮੇਲ: "

        Pl ->
            "E-mail: "

        Pt ->
            "Email: "

        Ro ->
            "E-mail: "

        Ru ->
            "эл. почта: "

        Sk ->
            "E-mail: "

        Sl ->
            "E-pošta: "

        Sq ->
            "Email: "

        Sv ->
            "E-post: "

        Sw ->
            "Barua pepe: "

        Tr ->
            "E-posta: "

        Tw ->
            "電郵: "

        Uk ->
            "електронна пошта: "

        Ur ->
            "ای میل: "

        Zh ->
            "電郵: "

        _ ->
            "Email: "


infoVersion : Lang -> String
infoVersion lang =
    case lang of
        Am ->
            "ቅድሚያ: "

        Ar ->
            "الإصدار: "

        Bg ->
            "Версия: "

        Bn ->
            "সংস্করণ: "

        Ca ->
            "Versió: "

        Cs ->
            "Verze: "

        Da ->
            "Version: "

        De ->
            "Version: "

        El ->
            "Έκδοση: "

        Es ->
            "versión"

        Et ->
            "Versioon: "

        Eu ->
            "Bertsioa: "

        Fa ->
            "نسخه: "

        Fi ->
            "Versio: "

        Fr ->
            "Version : "

        Ga ->
            "Leagan: "

        Hi ->
            "संस्करण:"

        Hr ->
            "Verzija: "

        Hu ->
            "Verzió: "

        Hy ->
            "տարբերակ: "

        It ->
            "Versione:  "

        Ja ->
            "バージョン："

        Ka ->
            "ვერსია: "

        Ko ->
            "버전: "

        Lt ->
            "Versija: "

        Lv ->
            "Versija: "

        Nb ->
            "Versjon: "

        Nl ->
            "Versie: "

        Pa ->
            "ਵਰਜਨ"

        Pl ->
            "Wersja: "

        Pt ->
            "Versão: "

        Ro ->
            "Versiune: "

        Ru ->
            "версия: "

        Sk ->
            "Verzia: "

        Sl ->
            "Različica: "

        Sq ->
            "Versioni: "

        Sv ->
            "Version: "

        Sw ->
            "Toleo: "

        Tr ->
            "Sürüm: "

        Tw ->
            "版本: "

        Uk ->
            "версія: "

        Ur ->
            "ورژن: "

        Zh ->
            "版本: "

        _ ->
            "Version: "


confInformation : Lang -> String
confInformation lang =
    case lang of
        Am ->
            "መረጃ"

        Ar ->
            "معلومات"

        Bg ->
            "Информация"

        Bn ->
            "তথ্য"

        Ca ->
            "Informació"

        Cs ->
            "Informace"

        Da ->
            "Information"

        De ->
            "Informationen"

        El ->
            "Πληροφορίες"

        Es ->
            "informaciones"

        Et ->
            "Teave"

        Eu ->
            "Informazioa"

        Fa ->
            "اطلاعات"

        Fi ->
            "Tiedot"

        Fr ->
            "Informations"

        Ga ->
            "Eolas"

        Hi ->
            "सूचना"

        Hr ->
            "Informacije"

        Hu ->
            "Információk"

        Hy ->
            "ինֆորմացիա"

        It ->
            "Informazioni"

        Ja ->
            "情報"

        Ka ->
            "ინფორმაცია"

        Ko ->
            "정보"

        Lt ->
            "Informacija"

        Lv ->
            "Informācija"

        Nb ->
            "Informasjon"

        Nl ->
            "Informatie"

        Pa ->
            "ਜਾਣਕਾਰੀ"

        Pl ->
            "Informacje"

        Pt ->
            "Informação"

        Ro ->
            "Informații"

        Ru ->
            "информация"

        Sk ->
            "Informácie"

        Sl ->
            "Informacije"

        Sq ->
            "Informacion"

        Sv ->
            "Information"

        Sw ->
            "Taarifa"

        Tr ->
            "Bilgi"

        Tw ->
            "關於"

        Uk ->
            "інформація"

        Ur ->
            "معلومات"

        Zh ->
            "關於"

        _ ->
            "Information"


confSettings : Lang -> String
confSettings lang =
    case lang of
        Am ->
            "ማስተካከያዎች"

        Ar ->
            "اعدادات"

        Bg ->
            "Настройки"

        Bn ->
            "সেটিংস"

        Ca ->
            "Configuració"

        Cs ->
            "Nastavení"

        Da ->
            "Indstillinger"

        De ->
            "Einstellungen"

        El ->
            "Ρυθμίσεις"

        Es ->
            "configuración"

        Et ->
            "Seaded"

        Eu ->
            "Ezarpenak"

        Fa ->
            "تنظیمات"

        Fi ->
            "Asetukset"

        Fr ->
            "Paramètres"

        Ga ->
            "Socruithe"

        Hi ->
            "सेटिंग्स"

        Hr ->
            "Postavke"

        Hu ->
            "Beállítások"

        Hy ->
            "կարգավորումներ"

        It ->
            "Impostazioni"

        Ja ->
            "設定"

        Ka ->
            "პარამეტრები"

        Ko ->
            "설정"

        Lt ->
            "Nustatymai"

        Lv ->
            "Iestatījumi"

        Nb ->
            "Innstillinger"

        Nl ->
            "Instellingen"

        Pa ->
            "ਸੈਟਿੰਗ"

        Pl ->
            "Ustawienia"

        Pt ->
            "Configurações"

        Ro ->
            "Setări"

        Ru ->
            "настройки"

        Sk ->
            "Nastavenia"

        Sl ->
            "Nastavitve"

        Sq ->
            "Cilësimet"

        Sv ->
            "Inställningar"

        Sw ->
            "Mipangilio"

        Tr ->
            "Ayarlar"

        Tw ->
            "設定"

        Uk ->
            "налаштування"

        Ur ->
            "ترتیبات"

        Zh ->
            "設定"

        _ ->
            "Settings"


confShare : Lang -> String
confShare lang =
    case lang of
        Am ->
            "አገልግሎት"

        Ar ->
            "مشاركة"

        Bg ->
            "Споделяне"

        Bn ->
            "ভাগ করুন"

        Ca ->
            "Comparteix"

        Cs ->
            "Sdílet"

        Da ->
            "Del"

        De ->
            "Teilen"

        El ->
            "Κοινοποίηση"

        Es ->
            "compartir"

        Et ->
            "Jaga"

        Eu ->
            "Partekatu"

        Fa ->
            "اشتراک"

        Fi ->
            "Jaa"

        Fr ->
            "Partager"

        Ga ->
            "Comhroinn"

        Hi ->
            "शेयर करें"

        Hr ->
            "Podijeli"

        Hu ->
            "Megosztás"

        Hy ->
            "կիսվել"

        It ->
            "Condividi"

        Ja ->
            "共有"

        Ka ->
            "გაზიარება"

        Ko ->
            "공유"

        Lt ->
            "Bendrinti"

        Lv ->
            "Kopīgot"

        Nb ->
            "Del"

        Nl ->
            "Delen"

        Pa ->
            "ਸਾਂਝਾ ਕਰੋ"

        Pl ->
            "Udostępnij"

        Pt ->
            "Compartilhar"

        Ro ->
            "Distribuie"

        Ru ->
            "поделиться"

        Sk ->
            "Zdieľať"

        Sl ->
            "Deli"

        Sq ->
            "Ndaj"

        Sv ->
            "Dela"

        Sw ->
            "Shiriki"

        Tr ->
            "Paylaş"

        Tw ->
            "分享"

        Uk ->
            "поділитися"

        Ur ->
            "شیئر کریں"

        Zh ->
            "分享"

        _ ->
            "Share"


confShareVia : Lang -> String
confShareVia lang =
    case lang of
        Am ->
            "ከተጨማሪ ያግኙ ..."

        Ar ->
            "شارك عبر ..."

        Bg ->
            "споделете чрез ..."

        Bn ->
            "এর মাধ্যমে ভাগ করুন ..."

        Ca ->
            "comparteix mitjançant ..."

        Cs ->
            "sdílet přes ..."

        Da ->
            "del via ..."

        De ->
            "Teilen per ..."

        El ->
            "κοινοποίηση μέσω ..."

        Es ->
            "compartir via ..."

        Et ->
            "jaga ... kaudu"

        Eu ->
            "partekatu ... bidez"

        Fa ->
            "اشتراک گذاری از طریق ..."

        Fi ->
            "jaa palvelussa ..."

        Fr ->
            "Partager via ..."

        Ga ->
            "comhroinn trí ..."

        Hi ->
            "के माध्यम से साझा करें ..."

        Hr ->
            "podijeli putem ..."

        Hu ->
            "megosztás ezen keresztül: ..."

        Hy ->
            "տարածել միջոցով ..."

        It ->
            "Condividi via ..."

        Ja ->
            "共有方法..."

        Ka ->
            "გაზიარება მეშვეობით ..."

        Ko ->
            "공유하기"

        Lt ->
            "bendrinti per ..."

        Lv ->
            "kopīgot, izmantojot ..."

        Nb ->
            "del via ..."

        Nl ->
            "deel via ..."

        Pa ->
            "ਸਾਂਝਾ ਕਰੋ ਵਿਆ ..."

        Pl ->
            "udostępnij przez ..."

        Pt ->
            "compartilhar via ..."

        Ro ->
            "distribuie prin ..."

        Ru ->
            "Отправить по ..."

        Sk ->
            "zdieľať cez ..."

        Sl ->
            "deli prek ..."

        Sq ->
            "ndaj nëpërmjet ..."

        Sv ->
            "dela via ..."

        Sw ->
            "shiriki kupitia ..."

        Tr ->
            "... aracılığıyla paylaş"

        Tw ->
            "通过...分享"

        Uk ->
            "поділитися через ..."

        Ur ->
            "ذریعے شیئر کریں ..."

        Zh ->
            "通过...分享"

        _ ->
            "share via ..."


confTranslations : Lang -> String
confTranslations lang =
    case lang of
        Am ->
            "ትርጉም"

        Ar ->
            "ترجمة"

        Bg ->
            "Транслации"

        Bn ->
            "অনুবাদ"

        Ca ->
            "Traduccions"

        Cs ->
            "Překlady"

        Da ->
            "Oversættelser"

        De ->
            "Übersetzungen"

        El ->
            "Μεταφράσεις"

        Es ->
            "traducciones"

        Et ->
            "Tõlked"

        Eu ->
            "Itzulpenak"

        Fa ->
            "ترجمه ها"

        Fi ->
            "Käännökset"

        Fr ->
            "Traductions"

        Ga ->
            "Aistriúcháin"

        Hi ->
            "अनुवाद"

        Hr ->
            "Prijevodi"

        Hu ->
            "Fordítások"

        Hy ->
            "թարգմանություններ"

        It ->
            "Traduzioni"

        Ja ->
            "翻訳"

        Ka ->
            "თარგმნები"

        Ko ->
            "번역"

        Lt ->
            "Vertimai"

        Lv ->
            "Tulkojumi"

        Nb ->
            "Oversettelser"

        Nl ->
            "Vertalingen"

        Pa ->
            "ਅਨੁਵਾਦ"

        Pl ->
            "Tłumaczenia"

        Pt ->
            "Traduções"

        Ro ->
            "Traduceri"

        Ru ->
            "на других языках"

        Sk ->
            "Preklady"

        Sl ->
            "Prevodi"

        Sq ->
            "Përkthime"

        Sv ->
            "Översättningar"

        Sw ->
            "Tafsiri"

        Tr ->
            "Çeviriler"

        Tw ->
            "翻譯"

        Uk ->
            "переклади"

        Ur ->
            "ترجمے"

        Zh ->
            "翻譯"

        _ ->
            "Translations"


confTooltip : Lang -> String
confTooltip lang =
    case lang of
        Am ->
            "የማጣሪያ ጥቅል"

        Ar ->
            "تلميحات"

        Bg ->
            "Подсказки"

        Bn ->
            "টুল"

        Ca ->
            "Indicadors de funció"

        Cs ->
            "Popisky"

        Da ->
            "Værktøjstip"

        De ->
            "Tooltipps"

        El ->
            "Συμβουλές εργαλείων"

        Et ->
            "Kohtspikrid"

        Eu ->
            "Tresna-aholkuak"

        Fa ->
            "راهنمای ابزار"

        Fi ->
            "Työkaluvihjeet"

        Fr ->
            "Infobulles"

        Ga ->
            "Leideanna uirlisí"

        Hi ->
            "टूलटिप्स"

        Hr ->
            "Opisi alata"

        Hu ->
            "Eszköztippek"

        It ->
            "Suggerimento"

        Ja ->
            "ツールチップ"

        Ka ->
            "ინსტრუქციები"

        Ko ->
            "도구 설명"

        Lt ->
            "Paaiškinimai"

        Lv ->
            "Rīku padomi"

        Nb ->
            "Verktøytips"

        Pa ->
            "ਉਪਸਮਾਨ"

        Pl ->
            "Podpowiedzi"

        Pt ->
            "Dicas de ferramentas"

        Ro ->
            "Indicații"

        Ru ->
            "подсказки"

        Sk ->
            "Popisy nástrojov"

        Sl ->
            "Namigi za orodja"

        Sq ->
            "Këshilla për mjetet"

        Sv ->
            "Verktygstips"

        Sw ->
            "Vidokezo vya zana"

        Tr ->
            "Araç ipuçları"

        Tw ->
            "工具提示"

        Uk ->
            "підказки"

        Ur ->
            "ٹول ٹپس"

        Zh ->
            "工具提示"

        _ ->
            "Tooltips"


confEdit : Lang -> String
confEdit lang =
    case lang of
        Am ->
            "ኤዲተር ክፈት"

        Ar ->
            "فتح المحرر"

        Bg ->
            "Отвори редактор"

        Bn ->
            "সম্পাদক খুলুন"

        Ca ->
            "Obre l'editor"

        Cs ->
            "Otevřít editor"

        Da ->
            "Åbn editoren"

        De ->
            "Editor öffnen"

        El ->
            "Άνοιγμα επεξεργαστή"

        Es ->
            "Abrir editor"

        Et ->
            "Ava redaktor"

        Eu ->
            "Ireki editorea"

        Fa ->
            "باز کردن ویرایشگر"

        Fi ->
            "Avaa editori"

        Fr ->
            "Ouvrir l'éditeur"

        Ga ->
            "Oscail an t-eagarthóir"

        Hi ->
            "संपादक खोलें"

        Hr ->
            "Otvori uređivač"

        Hu ->
            "Szerkesztő megnyitása"

        Hy ->
            "Բացել խմբագրիչը"

        It ->
            "Apri l'editor"

        Ja ->
            "エディターを開く"

        Ka ->
            "რედაქტორის გახსნა"

        Ko ->
            "편집기 열기"

        Lt ->
            "Atverti rengyklę"

        Lv ->
            "Atvērt redaktoru"

        Nb ->
            "Åpne editoren"

        Nl ->
            "Editor openen"

        Pa ->
            "ਸੰਪਾਦਕ ਖੋਲ੍ਹੋ"

        Pl ->
            "Otwórz edytor"

        Pt ->
            "Abrir editor"

        Ro ->
            "Deschide editorul"

        Ru ->
            "открыть редактор"

        Sk ->
            "Otvoriť editor"

        Sl ->
            "Odpri urejevalnik"

        Sq ->
            "Hap redaktuesin"

        Sv ->
            "Öppna redigeraren"

        Sw ->
            "Fungua Kihariri"

        Tr ->
            "Düzenleyiciyi aç"

        Tw ->
            "開啟編輯器"

        Uk ->
            "відкрити редактор"

        Ur ->
            "ایڈیٹر کھولیں"

        Zh ->
            "打開編輯器"

        _ ->
            "Open editor"


ttsPreferBrowser : Lang -> String
ttsPreferBrowser lang =
    case lang of
        Am ->
            "የብሮውን ቴክስት-ተምረው መቀመጥ"

        Bg ->
            "Предпочитам TTS на браузъра"

        Bn ->
            "ব্রাউজার TTS পছন্দ করুন"

        Ca ->
            "Prefereix la síntesi de veu del navegador"

        Cs ->
            "Upřednostnit syntézu řeči prohlížeče"

        Da ->
            "Foretræk browserens talesyntese"

        De ->
            "Browser-TTS bevorzugen"

        El ->
            "Προτίμηση σύνθεσης ομιλίας του προγράμματος περιήγησης"

        Es ->
            "Preferir TTS del navegador"

        Et ->
            "Eelista brauseri kõnesünteesi"

        Eu ->
            "Lehenetsi nabigatzailearen hizketa-sintesia"

        Fi ->
            "Suosi selaimen puhesynteesiä"

        Fr ->
            "Préférer le TTS du navigateur"

        Ga ->
            "Tabhair tús áite do shintéis cainte an bhrabhsálaí"

        Hi ->
            "ब्राउज़र TTS को प्राथमिकता दें"

        Hr ->
            "Daj prednost sintezi govora preglednika"

        Hu ->
            "A böngésző beszédszintézisének előnyben részesítése"

        It ->
            "Preferisci la sintesi vocale del browser"

        Ja ->
            "ブラウザのTTSを優先する"

        Ka ->
            "აირჩიეთ ბრაუზერის TTS"

        Ko ->
            "브라우저 TTS 선호"

        Lt ->
            "Teikti pirmenybę naršyklės kalbos sintezei"

        Lv ->
            "Dot priekšroku pārlūkprogrammas runas sintēzei"

        Nb ->
            "Foretrekk nettleserens talesyntese"

        Nl ->
            "Voorkeur browser TTS"

        Pa ->
            "ਬਰਾਊਜ਼ਰ TTS ਦਾ ਪਸੰਦ ਦਿਓ"

        Pl ->
            "Preferuj syntezę mowy przeglądarki"

        Pt ->
            "Preferir TTS do navegador"

        Ro ->
            "Preferă sinteza vocală a browserului"

        Ru ->
            "Предпочитать браузерный TTS"

        Sk ->
            "Uprednostniť syntézu reči prehliadača"

        Sl ->
            "Prednostno uporabi sintezo govora v brskalniku"

        Sq ->
            "Prefero sintezën e të folurit të shfletuesit"

        Sv ->
            "Föredra webbläsarens talsyntes"

        Sw ->
            "Pendelea kivinjari TTS"

        Tr ->
            "Tarayıcının metin okuma özelliğini tercih et"

        Tw ->
            "首选浏览器 TTS"

        Uk ->
            "Надаю перевагу браузеру TTS"

        Ur ->
            "براؤزر TTS کو ترجیح دیں"

        Zh ->
            "首选浏览器 TTS"

        _ ->
            "Prefer browser TTS"


ttsUsingBrowser : Lang -> String
ttsUsingBrowser lang =
    case lang of
        Am ->
            "በብሮው ቴክስት-ተምረው መጫን ነው።"

        Bg ->
            "Използване на вътрешната машина за синтезиран говор на браузъра."

        Bn ->
            "ব্রাউজারের অভ্যন্তরীণ পাঠকন ইঞ্জিন ব্যবহার করা হচ্ছে।"

        Ca ->
            "S'utilitza el motor de síntesi de veu integrat del navegador."

        Cs ->
            "Používá se vestavěná syntéza řeči prohlížeče."

        Da ->
            "Browserens indbyggede talesyntese bruges."

        De ->
            "Verwendung der internen Text-zu-Speech-Engine des Browsers."

        El ->
            "Χρησιμοποιείται η ενσωματωμένη μηχανή σύνθεσης ομιλίας του προγράμματος περιήγησης."

        Es ->
            "Usando el motor interno de conversión de texto a voz del navegador."

        Et ->
            "Kasutatakse brauseri sisseehitatud kõnesünteesi."

        Eu ->
            "Nabigatzailearen hizketa-sintesi integratua erabiltzen ari da."

        Fi ->
            "Käytetään selaimen sisäänrakennettua puhesynteesiä."

        Fr ->
            "Utilisation du moteur de synthèse vocale intégré du navigateur."

        Ga ->
            "Tá sintéis cainte ionsuite an bhrabhsálaí in úsáid."

        Hi ->
            "ब्राउज़र के आंतरिक टेक्स्ट-टू-स्पीच इंजन का उपयोग करना।"

        Hr ->
            "Koristi se ugrađena sinteza govora preglednika."

        Hu ->
            "A böngésző beépített beszédszintetizátora van használatban."

        It ->
            "Sto utilizzando il motore interno di conversione del testo a voce del browser."

        Ja ->
            "ブラウザの内蔵テキスト読み上げエンジンを使用中"

        Ka ->
            "გამოიყენება ბრაუზერის შიდა ტექსტ-დან-ხმამდე სისტემა."

        Ko ->
            "브라우저의 내부 텍스트 음성 변환 엔진을 사용합니다."

        Lt ->
            "Naudojama naršyklėje integruota kalbos sintezė."

        Lv ->
            "Tiek izmantota pārlūkprogrammā iebūvētā runas sintēze."

        Nb ->
            "Nettleserens innebygde talesyntese brukes."

        Nl ->
            "De interne tekst-naar-spraak-engine van de browser gebruiken."

        Pa ->
            "ਬਰਾਊਜ਼ਰ ਦੇ ਅੰਦਰੂਨੀ ਟੈਕਸਟ-ਟੁ-ਸਪੀਚ ਇੰਜਨ ਦੀ ਵਰਤੋਂ ਕੀਤੀ ਜਾ ਰਹੀ ਹੈ।"

        Pl ->
            "Używana jest wbudowana synteza mowy przeglądarki."

        Pt ->
            "Usando o motor interno de Texto-para-Fala do navegador."

        Ro ->
            "Se utilizează motorul de sinteză vocală integrat în browser."

        Ru ->
            "Используя внутренний механизм преобразования текста в речь браузера."

        Sk ->
            "Používa sa vstavaná syntéza reči prehliadača."

        Sl ->
            "Uporablja se vgrajena sinteza govora v brskalniku."

        Sq ->
            "Po përdoret motori i integruar i sintezës së të folurit të shfletuesit."

        Sv ->
            "Webbläsarens inbyggda talsyntes används."

        Sw ->
            "Kwa kutumia injini ya ndani ya kivinjari ya Maandishi-hadi-Hotuba."

        Tr ->
            "Tarayıcının yerleşik metin okuma motoru kullanılıyor."

        Tw ->
            "使用浏览器的内部文本转语音引擎。"

        Uk ->
            "Використання внутрішньої системи синтезу мовлення у браузері."

        Ur ->
            "براؤزر کے اندرونی ٹیکسٹ ٹو اسپیچ انجن کا استعمال ہو رہا ہے۔"

        Zh ->
            "使用浏览器的内部文本转语音引擎。"

        _ ->
            "Using the browser's internal Text-to-Speech engine."


ttsUnsupported : Lang -> String
ttsUnsupported lang =
    case lang of
        Am ->
            "የምንጠቀመው ብሮዎች ሊያውቅ አይችልም፣ በሌላ ቦታ ያሳያል።"

        Bg ->
            "Вашият браузър не поддържа Text-to-Speech, опитайте друг."

        Bn ->
            "আপনার ব্রাউজার টেক্সট-টু-স্পিচ সমর্থন করে না, অন্য কোন ব্রাউজার চেষ্টা করুন।"

        Ca ->
            "El teu navegador no admet la síntesi de veu. Prova'n un altre."

        Cs ->
            "Tvůj prohlížeč nepodporuje syntézu řeči. Zkus jiný."

        Da ->
            "Din browser understøtter ikke talesyntese. Prøv en anden."

        De ->
            "Ihr Browser unterstützt kein Text-to-Speech, versuchen Sie es mit einem anderen."

        El ->
            "Το πρόγραμμα περιήγησής σου δεν υποστηρίζει σύνθεση ομιλίας. Δοκίμασε κάποιο άλλο."

        Es ->
            "Tu navegador no es compatible con Text-to-Speech, prueba con otro."

        Et ->
            "Sinu brauser ei toeta kõnesünteesi. Proovi mõnda teist brauserit."

        Eu ->
            "Zure nabigatzaileak ez du hizketa-sintesia onartzen. Probatu beste bat."

        Fi ->
            "Selaimesi ei tue puhesynteesiä. Kokeile toista selainta."

        Fr ->
            "Votre navigateur ne prend pas en charge le texte en discours, essayez-en un autre."

        Ga ->
            "Ní thacaíonn do bhrabhsálaí le sintéis cainte. Bain triail as brabhsálaí eile."

        Hi ->
            "आपका ब्राउज़र टेक्स्ट-टू-स्पीच का समर्थन नहीं करता है, एक अलग प्रयास करें।"

        Hr ->
            "Tvoj preglednik ne podržava sintezu govora. Isprobaj drugi."

        Hu ->
            "A böngésződ nem támogatja a beszédszintézist. Próbálj ki egy másikat."

        It ->
            "Il tuo browser non è compatibile con Text-to-Speech, provane un altro."

        Ja ->
            "このブラウザはテキスト読み上げに対応していません。他のブラウザをお試しください。"

        Ka ->
            "თქვენი ბრაუზერი არ მხარს უჭერს ტექსტ-დან-ხმამდე ფუნქციას, სცადეთ სხვა."

        Ko ->
            "당신의 브라우저는 Text-to-Speech를 지원하지 않습니다. 다른 것을 시도해 보세요."

        Lt ->
            "Tavo naršyklė nepalaiko kalbos sintezės. Išbandyk kitą."

        Lv ->
            "Tava pārlūkprogramma neatbalsta runas sintēzi. Izmēģini citu."

        Nb ->
            "Nettleseren din støtter ikke talesyntese. Prøv en annen."

        Nl ->
            "Uw browser ondersteunt tekst-naar-spraak niet, probeer een andere."

        Pa ->
            "ਤੁਸੀਂ ਟੈਕਸਟ-ਟੁ-ਸਪੀਚ ਦਾ ਸਮਰਥਨ ਨਹੀਂ ਕਰਦੇ, ਕੋਈ ਹੋਰ ਸਫ਼ਾਰੀ ਵਰਤੋ।"

        Pl ->
            "Twoja przeglądarka nie obsługuje syntezy mowy. Wypróbuj inną."

        Pt ->
            "Seu navegador não suporta Texto-para-Fala, tente outro."

        Ro ->
            "Browserul tău nu acceptă sinteza vocală. Încearcă alt browser."

        Ru ->
            "Ваш браузер не поддерживает преобразование текста в речь, попробуйте другой."

        Sk ->
            "Tvoj prehliadač nepodporuje syntézu reči. Skús iný."

        Sl ->
            "Tvoj brskalnik ne podpira sinteze govora. Poskusi drugega."

        Sq ->
            "Shfletuesi yt nuk e mbështet sintezën e të folurit. Provo një tjetër."

        Sv ->
            "Din webbläsare stöder inte talsyntes. Prova en annan."

        Sw ->
            "Kivinjari chako hakitumii Maandishi-hadi-Hotuba, jaribu nyingine."

        Tr ->
            "Tarayıcınız metin okumayı desteklemiyor. Başka bir tarayıcı deneyin."

        Tw ->
            "您的浏览器不支持文本转语音，请换一个浏览器。"

        Uk ->
            "Ваш браузер не підтримує синтез мовлення з тексту, спробуйте інший."

        Ur ->
            "آپ کا براؤزر ٹیکسٹ ٹو اسپیچ کی حمایت نہیں کرتا، کوئی دوسرا آزمائیں۔"

        Zh ->
            "您的浏览器不支持文本转语音，请换一个浏览器。"

        _ ->
            "Your browser does not support Text-to-Speech, try another one."


codeExecute : Lang -> String
codeExecute lang =
    case lang of
        Am ->
            "ተጠቃሚ ስጥ"

        Ar ->
            "تنفيذ"

        Bg ->
            "Изпълни"

        Bn ->
            "সম্পাদনা করুন"

        Ca ->
            "Executa"

        Cs ->
            "Spustit"

        Da ->
            "Kør"

        De ->
            "Ausführen"

        El ->
            "Εκτέλεση"

        Es ->
            "ejecutar"

        Et ->
            "Käivita"

        Eu ->
            "Exekutatu"

        Fa ->
            "اجرا"

        Fi ->
            "Suorita"

        Fr ->
            "Exécuter"

        Ga ->
            "Rith"

        Hi ->
            "भागो"

        Hr ->
            "Pokreni"

        Hu ->
            "Futtatás"

        Hy ->
            "իրականացնել"

        It ->
            "Esegui"

        Ja ->
            "実行"

        Ka ->
            "შესრულება"

        Ko ->
            "실행"

        Lt ->
            "Vykdyti"

        Lv ->
            "Izpildīt"

        Nb ->
            "Kjør"

        Nl ->
            "uitvoeren"

        Pa ->
            "ਚਲਾਓ"

        Pl ->
            "Uruchom"

        Pt ->
            "Executar"

        Ro ->
            "Execută"

        Ru ->
            "выполнить"

        Sk ->
            "Spustiť"

        Sl ->
            "Zaženi"

        Sq ->
            "Ekzekuto"

        Sv ->
            "Kör"

        Sw ->
            "Tekeleza"

        Tr ->
            "Çalıştır"

        Tw ->
            "開始執行"

        Uk ->
            "запустити"

        Ur ->
            "عملدرآمد کریں"

        Zh ->
            "開始執行"

        _ ->
            "Execute"


codeRunning : Lang -> String
codeRunning lang =
    case lang of
        Am ->
            "ተጠቃሚ ላይ ነው"

        Ar ->
            "إجراء"

        Bg ->
            "Работещ"

        Bn ->
            "চলছে"

        Ca ->
            "s'està executant"

        Cs ->
            "běží"

        Da ->
            "kører"

        De ->
            "wird ausgeführt"

        El ->
            "εκτελείται"

        Es ->
            "en funcionamiento"

        Et ->
            "töötab"

        Eu ->
            "exekutatzen ari da"

        Fa ->
            "در حال اجرا"

        Fi ->
            "käynnissä"

        Fr ->
            "en cours d'exécution"

        Ga ->
            "ag rith"

        Hi ->
            "चल रहा है"

        Hr ->
            "izvodi se"

        Hu ->
            "fut"

        Hy ->
            "ընթանում է"

        It ->
            "in funzione"

        Ja ->
            "実行中"

        Ka ->
            "მიმდინარეობს"

        Ko ->
            "실행 중"

        Lt ->
            "vykdoma"

        Lv ->
            "tiek izpildīts"

        Nb ->
            "kjører"

        Nl ->
            "wordt uitgevoerd"

        Pa ->
            "ਚੱਲ ਰਿਹਾ ਹੈ"

        Pl ->
            "działa"

        Pt ->
            "está sendo executado"

        Ro ->
            "se execută"

        Ru ->
            "выполняется"

        Sk ->
            "beží"

        Sl ->
            "se izvaja"

        Sq ->
            "po ekzekutohet"

        Sv ->
            "körs"

        Sw ->
            "inakimbia"

        Tr ->
            "çalışıyor"

        Tw ->
            "執行中"

        Uk ->
            "виконується"

        Ur ->
            "چل رہا ہے"

        Zh ->
            "執行中"

        _ ->
            "is running"


codePrev : Lang -> String
codePrev lang =
    case lang of
        Am ->
            "የመጀመሪያ ክፍሎች"

        Ar ->
            "الإصدار السابق"

        Bg ->
            "Предишна версия"

        Bn ->
            "পূর্ববর্তী সংস্করণ"

        Ca ->
            "versió anterior"

        Cs ->
            "předchozí verze"

        Da ->
            "forrige version"

        De ->
            "eine Version zurück"

        El ->
            "προηγούμενη έκδοση"

        Es ->
            "versión anterior"

        Et ->
            "eelmine versioon"

        Eu ->
            "aurreko bertsioa"

        Fa ->
            "نسخه قبلی"

        Fi ->
            "edellinen versio"

        Fr ->
            "version précédente"

        Ga ->
            "an leagan roimhe"

        Hi ->
            "एक संस्करण वापस"

        Hr ->
            "prethodna verzija"

        Hu ->
            "előző verzió"

        Hy ->
            "նախորդ տարբերակը"

        It ->
            "versione precedente"

        Ja ->
            "前のバージョン"

        Ka ->
            "წინა ვერსია"

        Ko ->
            "이전 버전"

        Lt ->
            "ankstesnė versija"

        Lv ->
            "iepriekšējā versija"

        Nb ->
            "forrige versjon"

        Nl ->
            "een versie terug"

        Pa ->
            "ਪਿਛਲਾ ਵਰਜਨ"

        Pl ->
            "poprzednia wersja"

        Pt ->
            "versão anterior"

        Ro ->
            "versiunea anterioară"

        Ru ->
            "предыдущая версия"

        Sk ->
            "predchádzajúca verzia"

        Sl ->
            "prejšnja različica"

        Sq ->
            "versioni i mëparshëm"

        Sv ->
            "föregående version"

        Sw ->
            "toleo la awali"

        Tr ->
            "önceki sürüm"

        Tw ->
            "上一版"

        Uk ->
            "попередня версія"

        Ur ->
            "پچھلا ورژن"

        Zh ->
            "上一版"

        _ ->
            "previous version"


codeNext : Lang -> String
codeNext lang =
    case lang of
        Am ->
            "የቀጣይ ክፍሎች"

        Ar ->
            "الإصدار التالي"

        Bg ->
            "следваща версия"

        Bn ->
            "পরবর্তী সংস্করণ"

        Ca ->
            "versió següent"

        Cs ->
            "další verze"

        Da ->
            "næste version"

        De ->
            "eine Version vor"

        El ->
            "επόμενη έκδοση"

        Es ->
            "versión siguiente"

        Et ->
            "järgmine versioon"

        Eu ->
            "hurrengo bertsioa"

        Fa ->
            "نسخه بعدی"

        Fi ->
            "seuraava versio"

        Fr ->
            "version suivante"

        Ga ->
            "an chéad leagan eile"

        Hi ->
            "एक संस्करण पहले"

        Hr ->
            "sljedeća verzija"

        Hu ->
            "következő verzió"

        Hy ->
            "հաջորդ տարբերակը"

        It ->
            "versione seguente"

        Ja ->
            "次のバージョン"

        Ka ->
            "შემდეგი ვერსია"

        Ko ->
            "다음 버전"

        Lt ->
            "kita versija"

        Lv ->
            "nākamā versija"

        Nb ->
            "neste versjon"

        Nl ->
            "een versie vooruit"

        Pa ->
            "ਅਗਲਾ ਵਰਜਨ"

        Pl ->
            "następna wersja"

        Pt ->
            "próxima versão"

        Ro ->
            "versiunea următoare"

        Ru ->
            "следующая версия"

        Sk ->
            "ďalšia verzia"

        Sl ->
            "naslednja različica"

        Sq ->
            "versioni tjetër"

        Sv ->
            "nästa version"

        Sw ->
            "toleo linalofuata"

        Tr ->
            "sonraki sürüm"

        Tw ->
            "下一版"

        Uk ->
            "наступна версія"

        Ur ->
            "اگلا ورژن"

        Zh ->
            "下一版"

        _ ->
            "next version"


codeFirst : Lang -> String
codeFirst lang =
    case lang of
        Am ->
            "የመጀመሪያ ክፍል"

        Ar ->
            "الإصدار الأول"

        Bg ->
            "Първа версия"

        Bn ->
            "প্রথম সংস্করণ"

        Ca ->
            "primera versió"

        Cs ->
            "první verze"

        Da ->
            "første version"

        De ->
            "erste Version"

        El ->
            "πρώτη έκδοση"

        Es ->
            "primera versión"

        Et ->
            "esimene versioon"

        Eu ->
            "lehen bertsioa"

        Fa ->
            "نسخه اولیه"

        Fi ->
            "ensimmäinen versio"

        Fr ->
            "première version"

        Ga ->
            "an chéad leagan"

        Hi ->
            "पहली रिलीज"

        Hr ->
            "prva verzija"

        Hu ->
            "első verzió"

        Hy ->
            "առաջին տարբերակը"

        It ->
            "prima versione"

        Ja ->
            "最初のバージョン"

        Ka ->
            "პირველი ვერსია"

        Ko ->
            "첫 버전"

        Lt ->
            "pirmoji versija"

        Lv ->
            "pirmā versija"

        Nb ->
            "første versjon"

        Nl ->
            "eerste versie"

        Pa ->
            "ਪਹਿਲਾਂ ਦਾ ਵਰਜਨ"

        Pl ->
            "pierwsza wersja"

        Pt ->
            "primeira versão"

        Ro ->
            "prima versiune"

        Ru ->
            "первая версия"

        Sk ->
            "prvá verzia"

        Sl ->
            "prva različica"

        Sq ->
            "versioni i parë"

        Sv ->
            "första versionen"

        Sw ->
            "toleo la kwanza"

        Tr ->
            "ilk sürüm"

        Tw ->
            "最初版"

        Uk ->
            "перша версія"

        Ur ->
            "پہلا ورژن"

        Zh ->
            "最初版"

        _ ->
            "first version"


codeLast : Lang -> String
codeLast lang =
    case lang of
        Am ->
            "የመጨረሻ ክፍል"

        Ar ->
            "أحدث إصدار"

        Bg ->
            "Последна версия"

        Bn ->
            "শেষ সংস্করণ"

        Ca ->
            "última versió"

        Cs ->
            "poslední verze"

        Da ->
            "seneste version"

        De ->
            "letzte Version"

        El ->
            "τελευταία έκδοση"

        Es ->
            "última versión"

        Et ->
            "viimane versioon"

        Eu ->
            "azken bertsioa"

        Fa ->
            "آخرین نسخه"

        Fi ->
            "viimeinen versio"

        Fr ->
            "dernière version"

        Ga ->
            "an leagan deireanach"

        Hi ->
            "अंतिम संस्करण"

        Hr ->
            "posljednja verzija"

        Hu ->
            "utolsó verzió"

        Hy ->
            "վերջին տարբերակը"

        It ->
            "ultima versione"

        Ja ->
            "最新のバージョン"

        Ka ->
            "ბოლო ვერსია"

        Ko ->
            "최신 버전"

        Lt ->
            "paskutinė versija"

        Lv ->
            "pēdējā versija"

        Nb ->
            "siste versjon"

        Nl ->
            "laatste versie"

        Pa ->
            "ਆਖੀਰੀ ਵਰਜਨ"

        Pl ->
            "ostatnia wersja"

        Pt ->
            "última versão"

        Ro ->
            "ultima versiune"

        Ru ->
            "последняя версия"

        Sk ->
            "posledná verzia"

        Sl ->
            "zadnja različica"

        Sq ->
            "versioni i fundit"

        Sv ->
            "senaste versionen"

        Sw ->
            "toleo la mwisho"

        Tr ->
            "son sürüm"

        Tw ->
            "最終版"

        Uk ->
            "остання версія"

        Ur ->
            "آخری ورژن"

        Zh ->
            "最終版"

        _ ->
            "last version"


codeMinimize : Lang -> String
codeMinimize lang =
    case lang of
        Am ->
            "ማሳወቅ ያድርጉ"

        Ar ->
            "تصغير"

        Bg ->
            "Минимизиране"

        Bn ->
            "সামঞ্জস্য কমান"

        Ca ->
            "minimitza la vista"

        Cs ->
            "minimalizovat zobrazení"

        Da ->
            "minimer visning"

        De ->
            "Darstellung minimieren"

        El ->
            "ελαχιστοποίηση προβολής"

        Es ->
            "minimizar vista"

        Et ->
            "minimeeri vaade"

        Eu ->
            "minimizatu ikuspegia"

        Fa ->
            "کوچک کردن پنجره"

        Fi ->
            "pienennä näkymä"

        Fr ->
            "Réduire l'affichage"

        Ga ->
            "íoslaghdaigh an t-amharc"

        Hi ->
            "प्रदर्शन को छोटा करें"

        Hr ->
            "minimiziraj prikaz"

        Hu ->
            "nézet kicsinyítése"

        Hy ->
            "նվազեցնել տեսքը"

        It ->
            "minimizzare la vista"

        Ja ->
            "最小化"

        Ka ->
            "მინიმიზაცია"

        Ko ->
            "뷰 최소화"

        Lt ->
            "sumažinti rodinį"

        Lv ->
            "minimizēt skatu"

        Nb ->
            "minimer visning"

        Nl ->
            "weergave verkleinen"

        Pa ->
            "ਨਿੱਚੇ ਕਰੋ ਝਲਕ"

        Pl ->
            "minimalizuj widok"

        Pt ->
            "minimizar visualização"

        Ro ->
            "minimizează vizualizarea"

        Ru ->
            "свернуть"

        Sk ->
            "minimalizovať zobrazenie"

        Sl ->
            "pomanjšaj pogled"

        Sq ->
            "minimizo pamjen"

        Sv ->
            "minimera vyn"

        Sw ->
            "punguza mtazamo"

        Tr ->
            "görünümü küçült"

        Tw ->
            "極小視窗"

        Uk ->
            "зображення зменшити"

        Ur ->
            "منظر کو کم کریں"

        Zh ->
            "極小視窗"

        _ ->
            "minimize view"


codeMaximize : Lang -> String
codeMaximize lang =
    case lang of
        Am ->
            "ማግኘት ያድርጉ"

        Ar ->
            "إظهار بالكامل"

        Bg ->
            "Максимизиране"

        Bn ->
            "সামঞ্জস্য বাড়ান"

        Ca ->
            "maximitza la vista"

        Cs ->
            "maximalizovat zobrazení"

        Da ->
            "maksimer visning"

        De ->
            "Darstellung maximieren"

        El ->
            "μεγιστοποίηση προβολής"

        Es ->
            "maximinzar vista"

        Et ->
            "maksimeeri vaade"

        Eu ->
            "maximizatu ikuspegia"

        Fa ->
            "بزرگ کردن پنجره"

        Fi ->
            "suurenna näkymä"

        Fr ->
            "Maximiser l'affichage"

        Ga ->
            "uasmhéadaigh an t-amharc"

        Hi ->
            "प्रदर्शन को अधिकतम करें"

        Hr ->
            "maksimiziraj prikaz"

        Hu ->
            "nézet nagyítása"

        Hy ->
            "բարձրագունել տեսքը"

        It ->
            "massimizzare la vista"

        Ja ->
            "最大化"

        Ka ->
            "მაქსიმიზაცია"

        Ko ->
            "뷰 최대화"

        Lt ->
            "padidinti rodinį"

        Lv ->
            "maksimizēt skatu"

        Nb ->
            "maksimer visning"

        Nl ->
            "weergave maximaliseren"

        Pa ->
            "ਵੱਧ ਕਰੋ ਝਲਕ"

        Pl ->
            "maksymalizuj widok"

        Pt ->
            "maximizar visualização"

        Ro ->
            "maximizează vizualizarea"

        Ru ->
            "показать полностью"

        Sk ->
            "maximalizovať zobrazenie"

        Sl ->
            "povečaj pogled"

        Sq ->
            "maksimizo pamjen"

        Sv ->
            "maximera vyn"

        Sw ->
            "kuongeza mtazamo"

        Tr ->
            "görünümü büyüt"

        Tw ->
            "極大視窗"

        Uk ->
            "зображення збільшити"

        Ur ->
            "منظر کو زیادہ کریں"

        Zh ->
            "極大視窗"

        _ ->
            "maximize view"


codeTerminal : Lang -> String
codeTerminal lang =
    case lang of
        Am ->
            "ቴርማው"

        Ar ->
            "طرفية"

        Bg ->
            "терминал"

        Bn ->
            "টার্মিনাল"

        Ca ->
            "terminal"

        Cs ->
            "terminál"

        Da ->
            "terminal"

        De ->
            "Terminal"

        El ->
            "τερματικό"

        Et ->
            "terminal"

        Eu ->
            "terminala"

        Fa ->
            "پایانه"

        Fi ->
            "pääte"

        Fr ->
            "Terminal"

        Ga ->
            "teirminéal"

        Hi ->
            "टर्मिनल"

        Hr ->
            "terminal"

        Hu ->
            "terminál"

        Hy ->
            "տերմինալ"

        Ja ->
            "ターミナル"

        Ka ->
            "ტერმინალი"

        Ko ->
            "단말기"

        Lt ->
            "terminalas"

        Lv ->
            "terminālis"

        Nb ->
            "terminal"

        Pa ->
            "ਟਰਮੀਨਲ"

        Pl ->
            "terminal"

        Pt ->
            "terminal"

        Ro ->
            "terminal"

        Ru ->
            "термина́л"

        Sk ->
            "terminál"

        Sl ->
            "terminal"

        Sq ->
            "terminal"

        Sv ->
            "terminal"

        Sw ->
            "terminal"

        Tr ->
            "terminal"

        Tw ->
            "终端"

        Uk ->
            "термінал"

        Ur ->
            "ٹرمینل"

        Zh ->
            "终端"

        _ ->
            "terminal"


codeCopy : Lang -> String
codeCopy lang =
    case lang of
        Am ->
            "ወደ ቅንጥብ ሰሌዳ ቅዳ"

        Ar ->
            "نسخ إلى الحافظة"

        Bg ->
            "Копирай в клипборда"

        Bn ->
            "ক্লিপবোর্ডে কপি করুন"

        Ca ->
            "copia al porta-retalls"

        Cs ->
            "zkopírovat do schránky"

        Da ->
            "kopiér til udklipsholder"

        De ->
            "in die Zwischenablage kopieren"

        El ->
            "αντιγραφή στο πρόχειρο"

        Es ->
            "copiar al portapapeles"

        Et ->
            "kopeeri lõikelauale"

        Eu ->
            "kopiatu arbelean"

        Fa ->
            "کپی در کلیپ بورد"

        Fi ->
            "kopioi leikepöydälle"

        Fr ->
            "Copier dans le presse-papiers"

        Ga ->
            "cóipeáil chuig an ngearrthaisce"

        Hi ->
            "क्लिपबोर्ड पर कॉपी करें"

        Hr ->
            "kopiraj u međuspremnik"

        Hu ->
            "másolás a vágólapra"

        Hy ->
            "Պատճենել սեղմատախտակին"

        It ->
            "copia negli appunti"

        Ja ->
            "クリップボードにコピー"

        Ka ->
            "დაკოპირე კლიპბორდზე"

        Ko ->
            "클립보드에 복사"

        Lt ->
            "kopijuoti į iškarpinę"

        Lv ->
            "kopēt starpliktuvē"

        Nb ->
            "kopier til utklippstavlen"

        Nl ->
            "kopiëren naar klembord"

        Pa ->
            "ਕਲਿੱਪਬੋਰਡ 'ਤੇ ਕਾਪੀ"

        Pl ->
            "kopiuj do schowka"

        Pt ->
            "copiar para a área de transferência"

        Ro ->
            "copiază în clipboard"

        Ru ->
            "скопировать в буфер обмена"

        Sk ->
            "kopírovať do schránky"

        Sl ->
            "kopiraj v odložišče"

        Sq ->
            "kopjo në kujtesën e përkohshme"

        Sv ->
            "kopiera till urklipp"

        Sw ->
            "nakili kwenye ubao wa kunakili"

        Tr ->
            "panoya kopyala"

        Tw ->
            "复制到剪贴板"

        Uk ->
            "копіювати в буфер обміну"

        Ur ->
            "کلپ بورڈ پر کاپی کریں"

        Zh ->
            "复制到剪贴板"

        _ ->
            "copy to clipboard"


quizCheck : Lang -> String
quizCheck lang =
    case lang of
        Am ->
            "መለየት"

        Ar ->
            "تحقق"

        Bg ->
            "Проверка"

        Bn ->
            "পরীক্ষা করুন"

        Ca ->
            "Comprova"

        Cs ->
            "Zkontrolovat"

        Da ->
            "Kontrollér"

        De ->
            "Prüfen"

        El ->
            "Έλεγχος"

        Es ->
            "verificar"

        Et ->
            "Kontrolli"

        Eu ->
            "Egiaztatu"

        Fa ->
            "بررسی"

        Fi ->
            "Tarkista"

        Fr ->
            "Vérifier"

        Ga ->
            "Seiceáil"

        Hi ->
            "चेक करें"

        Hr ->
            "Provjeri"

        Hu ->
            "Ellenőrzés"

        Hy ->
            "ստուգել"

        It ->
            "verifica"

        Ja ->
            "確認"

        Ka ->
            "შეამოწმეთ"

        Ko ->
            "확인"

        Lt ->
            "Tikrinti"

        Lv ->
            "Pārbaudīt"

        Nb ->
            "Kontroller"

        Nl ->
            "bekijk"

        Pa ->
            "ਜਾਂਚ ਕਰੋ"

        Pl ->
            "Sprawdź"

        Pt ->
            "Verificar"

        Ro ->
            "Verifică"

        Ru ->
            "проверить"

        Sk ->
            "Skontrolovať"

        Sl ->
            "Preveri"

        Sq ->
            "Kontrollo"

        Sv ->
            "Kontrollera"

        Sw ->
            "Angalia"

        Tr ->
            "Kontrol et"

        Tw ->
            "選取"

        Uk ->
            "перевірити"

        Ur ->
            "چیک کریں"

        Zh ->
            "選取"

        _ ->
            "Check"


quizSolution : Lang -> String
quizSolution lang =
    case lang of
        Am ->
            "አስገሳት አሳይ"

        Ar ->
            "إظهار الحل"

        Bg ->
            "Отговор"

        Bn ->
            "সমাধান প্রদর্শন করুন"

        Ca ->
            "mostra la solució"

        Cs ->
            "zobrazit řešení"

        Da ->
            "vis løsning"

        De ->
            "zeige Lösung"

        El ->
            "εμφάνιση λύσης"

        Es ->
            "mostrar solución"

        Et ->
            "näita lahendust"

        Eu ->
            "erakutsi ebazpena"

        Fa ->
            "نمایش راهکار"

        Fi ->
            "näytä ratkaisu"

        Fr ->
            "Afficher la solution"

        Ga ->
            "taispeáin an réiteach"

        Hi ->
            "समाधान दिखाएं"

        Hr ->
            "prikaži rješenje"

        Hu ->
            "megoldás megjelenítése"

        Hy ->
            "ցույց տալ լուծումը"

        It ->
            "mostra la soluzione"

        Ja ->
            "解答を表示"

        Ka ->
            "გადაჭრა გაჩვენე"

        Ko ->
            "정답 보기"

        Lt ->
            "rodyti sprendimą"

        Lv ->
            "rādīt risinājumu"

        Nb ->
            "vis løsning"

        Nl ->
            "toon oplossing"

        Pa ->
            "ਹੱਲ ਦਿਖਾਓ"

        Pl ->
            "pokaż rozwiązanie"

        Pt ->
            "mostrar solução"

        Ro ->
            "arată soluția"

        Ru ->
            "показать решение"

        Sk ->
            "zobraziť riešenie"

        Sl ->
            "pokaži rešitev"

        Sq ->
            "shfaq zgjidhjen"

        Sv ->
            "visa lösning"

        Sw ->
            "onyesha suluhisho"

        Tr ->
            "çözümü göster"

        Tw ->
            "顯示解答"

        Uk ->
            "показати розв'язок"

        Ur ->
            "حل دکھائیں"

        Zh ->
            "顯示解答"

        _ ->
            "show solution"


quizHint : Lang -> String
quizHint lang =
    case lang of
        Am ->
            "አስታዋሽ"

        Ar ->
            "تلميح"

        Bg ->
            "Подсказване"

        Bn ->
            "হিন্ট দেখান"

        Ca ->
            "mostra una pista"

        Cs ->
            "zobrazit nápovědu"

        Da ->
            "vis tip"

        De ->
            "Hinweis anzeigen"

        El ->
            "εμφάνιση υπόδειξης"

        Es ->
            "mostrar indicio"

        Et ->
            "näita vihjet"

        Eu ->
            "erakutsi pista"

        Fa ->
            "نمایش یادآوری"

        Fi ->
            "näytä vihje"

        Fr ->
            "Afficher l'indice"

        Ga ->
            "taispeáin leid"

        Hi ->
            "संकेत दिखाएं"

        Hr ->
            "prikaži savjet"

        Hu ->
            "tipp megjelenítése"

        Hy ->
            "ցուցադրել ակնարկ"

        It ->
            "mostra un indizio"

        Ja ->
            "ヒントを表示"

        Ka ->
            "რჩევა გაჩვენე"

        Ko ->
            "힌트 보기"

        Lt ->
            "rodyti užuominą"

        Lv ->
            "rādīt norādi"

        Nb ->
            "vis hint"

        Nl ->
            "toon hint"

        Pa ->
            "ਇੱਕ ਇੰਗਿਤ ਦਿਖਾਓ"

        Pl ->
            "pokaż wskazówkę"

        Pt ->
            "mostrar dica"

        Ro ->
            "arată indiciul"

        Ru ->
            "подсказка"

        Sk ->
            "zobraziť nápovedu"

        Sl ->
            "pokaži namig"

        Sq ->
            "shfaq ndihmën"

        Sv ->
            "visa ledtråd"

        Sw ->
            "onyesha kidokezo"

        Tr ->
            "ipucunu göster"

        Tw ->
            "暗示"

        Uk ->
            "показати підказку"

        Ur ->
            "اشارہ دکھائیں"

        Zh ->
            "暗示"

        _ ->
            "show hint"


quizSelection : Lang -> String
quizSelection lang =
    case lang of
        Am ->
            "ምረጡ"

        Ar ->
            "اختيار"

        Bg ->
            "избор"

        Bn ->
            "নির্বাচন"

        Ca ->
            "selecció"

        Cs ->
            "výběr"

        Da ->
            "valg"

        De ->
            "Auswahl"

        El ->
            "επιλογή"

        Es ->
            "selección"

        Et ->
            "valik"

        Eu ->
            "hautaketa"

        Fa ->
            "انتخاب"

        Fi ->
            "valinta"

        Fr ->
            "Sélection"

        Ga ->
            "roghnú"

        Hi ->
            "चयन"

        Hr ->
            "odabir"

        Hu ->
            "kiválasztás"

        Hy ->
            "ընտրություն"

        It ->
            "seleziona"

        Ja ->
            "選択"

        Ka ->
            "არჩევა"

        Ko ->
            "선택"

        Lt ->
            "pasirinkimas"

        Lv ->
            "izvēle"

        Nb ->
            "valg"

        Nl ->
            "selectie"

        Pa ->
            "ਚੋਣ"

        Pl ->
            "wybór"

        Pt ->
            "seleção"

        Ro ->
            "selecție"

        Ru ->
            "выбор"

        Sk ->
            "výber"

        Sl ->
            "izbira"

        Sq ->
            "përzgjedhje"

        Sv ->
            "val"

        Sw ->
            "uteuzi"

        Tr ->
            "seçim"

        Tw ->
            "选择"

        Uk ->
            "вибір"

        Ur ->
            "انتخاب"

        Zh ->
            "选择"

        _ ->
            "selection"


quizLabelCheck : Lang -> String
quizLabelCheck lang =
    case lang of
        Am ->
            "መረጃው ተመርጧል ወይም ቆይተው ይቀጥሉ"

        Ar ->
            "تحقق من الجواب. تم وضع علامة على الإجابة على أنها صحيحة أو غير صحيحة."

        Bg ->
            "Проверете отговора. Отговорът е маркиран като правилен или неправилен."

        Bn ->
            "উত্তরটি পরীক্ষা করুন। প্রতিক্রিয়াটি সঠিক বা ভুল হিসাবে চিহ্নিত করা হবে।"

        Ca ->
            "Comprova la resposta. La resposta es marcarà com a correcta o incorrecta."

        Cs ->
            "Zkontrolovat odpověď. Odpověď bude označena jako správná nebo nesprávná."

        Da ->
            "Kontrollér svaret. Svaret markeres som rigtigt eller forkert."

        De ->
            "Überprüfe die Antwort. Die Antwort wird als richtig oder falsch markiert."

        El ->
            "Έλεγχος της απάντησης. Η απάντηση θα επισημανθεί ως σωστή ή λανθασμένη."

        Es ->
            "Comprueba la respuesta. La respuesta está marcada como correcta o incorrecta."

        Et ->
            "Kontrolli vastust. Vastus märgitakse õigeks või valeks."

        Eu ->
            "Egiaztatu erantzuna. Erantzuna zuzen edo oker gisa markatuko da."

        Fa ->
            "پاسخ را بررسی کنید. پاسخ صحیح یا نادرست علامت گذاری شده است."

        Fi ->
            "Tarkista vastaus. Vastaus merkitään oikeaksi tai vääräksi."

        Fr ->
            "Vérifiez la réponse. La réponse sera marquée comme correcte ou incorrecte."

        Ga ->
            "Seiceáil an freagra. Marcálfar an freagra mar cheart nó mícheart."

        Hi ->
            "उत्तर की जाँच करें। उत्तर को सही या गलत के रूप में चिह्नित किया गया है।"

        Hr ->
            "Provjeri odgovor. Odgovor će biti označen kao točan ili netočan."

        Hu ->
            "A válasz ellenőrzése. A válasz helyesnek vagy helytelennek lesz jelölve."

        Hy ->
            "Ստուգեք պատասխանը: Պատասխանը նշվում է որպես ճիշտ կամ սխալ:"

        It ->
            "Controlla la risposta. La risposta è indicata come corretta o errata."

        Ja ->
            "答えを確認してください。回答は正解または不正解でマークされます。"

        Ka ->
            "შეამოწმეთ პასუხი. პასუხი ჩაინიშნება როგორც სწორი ან არასწორი."

        Ko ->
            "답을 확인하세요. 정답 또는 오답으로 표시됩니다."

        Lt ->
            "Patikrinti atsakymą. Atsakymas bus pažymėtas kaip teisingas arba neteisingas."

        Lv ->
            "Pārbaudīt atbildi. Atbilde tiks atzīmēta kā pareiza vai nepareiza."

        Nb ->
            "Kontroller svaret. Svaret markeres som riktig eller feil."

        Nl ->
            "Controleer het antwoord. Het antwoord wordt gemarkeerd als goed of fout."

        Pa ->
            "ਜਵਾਬ ਦੀ ਜਾਂਚ ਕਰੋ। ਜਵਾਬ ਸਹੀ ਜਾਂ ਗਲਤ ਨਿਸ਼ਾਨਾ ਲਗਾਇਆ ਜਾਵੇਗਾ।"

        Pl ->
            "Sprawdź odpowiedź. Odpowiedź zostanie oznaczona jako poprawna lub niepoprawna."

        Pt ->
            "Verifique a resposta. A resposta será marcada como correta ou incorreta."

        Ro ->
            "Verifică răspunsul. Răspunsul va fi marcat drept corect sau incorect."

        Ru ->
            "Проверьте ответ. Ответ отмечен как правильный или неправильный."

        Sk ->
            "Skontrolovať odpoveď. Odpoveď bude označená ako správna alebo nesprávna."

        Sl ->
            "Preveri odgovor. Odgovor bo označen kot pravilen ali napačen."

        Sq ->
            "Kontrollo përgjigjen. Përgjigjja do të shënohet si e saktë ose e pasaktë."

        Sv ->
            "Kontrollera svaret. Svaret markeras som rätt eller fel."

        Sw ->
            "Angalia jibu. Jibu litawekwa alama kuwa sahihi au si sahihi."

        Tr ->
            "Yanıtı kontrol et. Yanıt doğru veya yanlış olarak işaretlenecek."

        Tw ->
            "检查答案。答案被标记为正确或不正确。"

        Uk ->
            "Перевірте відповідь. Відповідь позначена як правильна чи неправильна."

        Ur ->
            "جواب چیک کریں۔ جواب کو درست یا غلط کے طور پر نشان زد کیا جائے گا۔"

        Zh ->
            "检查答案。答案被标记为正确或不正确。"

        _ ->
            "Check the answer. The response will be marked as correct or incorrect."


quizLabelSolution : Lang -> String
quizLabelSolution lang =
    case lang of
        Am ->
            "የይለፍ መረጃ ይሰራል"

        Ar ->
            "اعرض الحل. تم وضع علامة 'حل' الاختبار."

        Bg ->
            "Покажете решението. Тестът е означен като решен."

        Bn ->
            "সমাধান প্রদর্শন করুন। কুইজটি সমাধানিত হিসাবে চিহ্নিত করা হবে।"

        Ca ->
            "Mostra la solució. L'exercici es marcarà com a resolt."

        Cs ->
            "Zobrazit řešení. Úloha bude označena jako vyřešená."

        Da ->
            "Vis løsningen. Opgaven markeres som løst."

        De ->
            "Zeige die Lösung. Das Quiz wird als aufgelöst markiert."

        El ->
            "Εμφάνιση της λύσης. Η άσκηση θα επισημανθεί ως λυμένη."

        Es ->
            "Muestre la solución. El cuestionario se marca como resuelto."

        Et ->
            "Näita lahendust. Ülesanne märgitakse lahendatuks."

        Eu ->
            "Erakutsi ebazpena. Ariketa ebatzita dagoela markatuko da."

        Fa ->
            "راه حل را نشان دهید. مسابقه به عنوان حل شده علامت گذاری شده است."

        Fi ->
            "Näytä ratkaisu. Tehtävä merkitään ratkaistuksi."

        Fr ->
            "Affichez la solution. Le quiz sera marqué comme résolu."

        Ga ->
            "Taispeáin an réiteach. Marcálfar an cleachtadh mar réitithe."

        Hi ->
            "समाधान दिखाएं। प्रश्नोत्तरी को समाधान के रूप में चिह्नित किया जाएगा।"

        Hr ->
            "Prikaži rješenje. Zadatak će biti označen kao riješen."

        Hu ->
            "A megoldás megjelenítése. A feladat megoldottként lesz jelölve."

        Hy ->
            "Showույց տվեք լուծումը: Վիկտորինան նշվում է որպես լուծված:"

        It ->
            "Mostra la soluzione. Il questionario si registra come risolto."

        Ja ->
            "解答を表示します。クイズは解決済みとマークされます。"

        Ka ->
            "გაჩვენეთ გადაჭრა. კიზი ჩაინიშნება როგორც გადაჭრული."

        Ko ->
            "솔루션을 보여주세요. 퀴즈가 해결된 것으로 표시됩니다."

        Lt ->
            "Parodyti sprendimą. Užduotis bus pažymėta kaip išspręsta."

        Lv ->
            "Parādīt risinājumu. Uzdevums tiks atzīmēts kā atrisināts."

        Nb ->
            "Vis løsningen. Oppgaven markeres som løst."

        Nl ->
            "Laat de oplossing zien. De quiz is gemarkeerd als opgelost."

        Pa ->
            "ਹੱਲ ਦਿਖਾਓ। ਕਵਿਜ਼ ਹੱਲ ਕੀਤਾ ਜਾਵੇਗਾ।"

        Pl ->
            "Pokaż rozwiązanie. Zadanie zostanie oznaczone jako rozwiązane."

        Pt ->
            "Mostrar a solução. O quiz será marcado como resolvido."

        Ro ->
            "Arată soluția. Exercițiul va fi marcat ca rezolvat."

        Ru ->
            "Покажи решение. Викторина помечается как решенная."

        Sk ->
            "Zobraziť riešenie. Úloha bude označená ako vyriešená."

        Sl ->
            "Pokaži rešitev. Naloga bo označena kot rešena."

        Sq ->
            "Shfaq zgjidhjen. Ushtrimi do të shënohet si i zgjidhur."

        Sv ->
            "Visa lösningen. Uppgiften markeras som löst."

        Sw ->
            "Onyesha suluhisho. Maswali yatatiwa alama kuwa yametatuliwa."

        Tr ->
            "Çözümü göster. Soru çözülmüş olarak işaretlenecek."

        Tw ->
            "显示解决方案。测验被标记为已解决。"

        Uk ->
            "Покажіть рішення. Вікторина позначена як розв’язана."

        Ur ->
            "حل دکھائیں۔ کوئز کو حل شدہ کے طور پر نشان زد کیا جائے گا۔"

        Zh ->
            "显示解决方案。测验被标记为已解决。"

        _ ->
            "Show the solution. The quiz will be marked as resolved."


quizAnswerSuccess : Lang -> String
quizAnswerSuccess lang =
    case lang of
        Am ->
            "እንኳን ደስ አለዎት! ይህ ማሳወቅ ተመልከቱ"

        Ar ->
            "مبروك هذه كانت الإجابة الصحيحة"

        Bg ->
            "Поздравления, това беше правилният отговор"

        Bn ->
            "অভিনন্দন, সেটা সঠিক উত্তর ছিল"

        Ca ->
            "Enhorabona, aquesta era la resposta correcta"

        Cs ->
            "Gratulujeme, to byla správná odpověď"

        Da ->
            "Tillykke, det var det rigtige svar"

        De ->
            "Herzlichen Glückwunsch, das war die richtige Antwort"

        El ->
            "Συγχαρητήρια, αυτή ήταν η σωστή απάντηση"

        Es ->
            "Felicitaciones, esa fue la respuesta correcta"

        Et ->
            "Palju õnne, see oli õige vastus"

        Eu ->
            "Zorionak, hori zen erantzun zuzena"

        Fa ->
            "تبریک می گویم ، جواب صحیحی بود"

        Fi ->
            "Onnittelut, vastaus oli oikein"

        Fr ->
            "Félicitations, c'était la bonne réponse"

        Ga ->
            "Comhghairdeas, ba é sin an freagra ceart"

        Hi ->
            "बधाई हो, यह सही उत्तर था"

        Hr ->
            "Čestitamo, to je bio točan odgovor"

        Hu ->
            "Gratulálunk, ez volt a helyes válasz"

        Hy ->
            "Շնորհավորում եմ, դա ճիշտ պատասխանն էր"

        It ->
            "Congratulazioni, questa era la risposta corretta"

        Ja ->
            "おめでとうございます、正解です"

        Ka ->
            "გილოცავთ, ეს იყო სწორი პასუხი"

        Ko ->
            "축하합니다. 올바른 답을 선택했습니다"

        Lt ->
            "Sveikiname, tai buvo teisingas atsakymas"

        Lv ->
            "Apsveicam, tā bija pareizā atbilde"

        Nb ->
            "Gratulerer, det var riktig svar"

        Nl ->
            "Gefeliciteerd, dat was het juiste antwoord"

        Pa ->
            "ਬਧਾਈ ਹੋ, ਜਿਹਨਾਂ ਜਵਾਬ ਸਹੀ ਸੀ।"

        Pl ->
            "Gratulacje, to była poprawna odpowiedź"

        Pt ->
            "Parabéns, essa foi a resposta certa."

        Ro ->
            "Felicitări, acesta a fost răspunsul corect"

        Ru ->
            "Поздравляю, это был правильный ответ"

        Sk ->
            "Gratulujeme, to bola správna odpoveď"

        Sl ->
            "Čestitamo, to je bil pravilen odgovor"

        Sq ->
            "Urime, kjo ishte përgjigjja e saktë"

        Sv ->
            "Grattis, det var rätt svar"

        Sw ->
            "Hongera, hilo lilikuwa jibu sahihi"

        Tr ->
            "Tebrikler, doğru yanıt verdiniz"

        Tw ->
            "恭喜，那是正确的答案"

        Uk ->
            "Вітаю, це була правильна відповідь"

        Ur ->
            "مبارک ہو، یہ درست جواب تھا"

        Zh ->
            "恭喜，那是正确的答案"

        _ ->
            "Congratulations, that was the right answer"


quizAnswerError : Lang -> String
quizAnswerError lang =
    case lang of
        Am ->
            "የሚነካ መለያ መገለጫ በድጋሚ ነው"

        Ar ->
            "لم يتم إعطاء الإجابة الصحيحة بعد"

        Bg ->
            "Все още не е даден правилният отговор"

        Bn ->
            "সঠিক উত্তরটি এখনও দেওয়া হয়নি"

        Ca ->
            "Encara no s'ha donat la resposta correcta"

        Cs ->
            "Správná odpověď ještě nebyla zadána"

        Da ->
            "Det rigtige svar er endnu ikke angivet"

        De ->
            "Die richtige Antwort wurde noch nicht gegeben"

        El ->
            "Δεν έχει δοθεί ακόμη η σωστή απάντηση"

        Es ->
            "La respuesta correcta aún no ha sido dada"

        Et ->
            "Õiget vastust pole veel antud"

        Eu ->
            "Oraindik ez da erantzun zuzena eman"

        Fa ->
            "بله، این ترجمه فارسی است"

        Fi ->
            "Oikeaa vastausta ei ole vielä annettu"

        Fr ->
            "La réponse correcte n'a pas encore été donnée"

        Ga ->
            "Níor tugadh an freagra ceart fós"

        Hi ->
            "अभी तक सही उत्तर नहीं दिया गया है"

        Hr ->
            "Točan odgovor još nije dan"

        Hu ->
            "Még nem adtad meg a helyes választ"

        Hy ->
            "Ճիշտ պատասխանը դեռևս չի տրվել"

        It ->
            "La risposta corretta non è stata ancora fornita"

        Ja ->
            "正解がまだ与えられていません"

        Ka ->
            "სწორი პასუხი ჯერ არ არის მოწოდებული"

        Ko ->
            "정답이 아직 제시되지 않았습니다"

        Lt ->
            "Teisingas atsakymas dar nepateiktas"

        Lv ->
            "Pareizā atbilde vēl nav sniegta"

        Nb ->
            "Riktig svar er ikke gitt ennå"

        Nl ->
            "Het juiste antwoord is nog niet gegeven"

        Pa ->
            "ਸਹੀ ਜਵਾਬ ਹਾਲੇ ਨਹੀਂ ਦਿੱਤਾ ਗਿਆ ਹੈ।"

        Pl ->
            "Nie podano jeszcze poprawnej odpowiedzi"

        Pt ->
            "A resposta correta ainda não foi dada."

        Ro ->
            "Răspunsul corect nu a fost încă dat"

        Ru ->
            "Правильный ответ еще не дан"

        Sk ->
            "Správna odpoveď ešte nebola zadaná"

        Sl ->
            "Pravilen odgovor še ni bil podan"

        Sq ->
            "Përgjigjja e saktë nuk është dhënë ende"

        Sv ->
            "Rätt svar har ännu inte angetts"

        Sw ->
            "Jibu sahihi bado halijatolewa"

        Tr ->
            "Henüz doğru yanıt verilmedi"

        Tw ->
            "正確的答案還沒有被給出"

        Uk ->
            "Правильна відповідь ще не надана"

        Ur ->
            "صحیح جواب ابھی تک نہیں دیا گیا"

        Zh ->
            "正确的答案尚未给出"

        _ ->
            "The correct answer has not yet been given"


quizAnswerResolved : Lang -> String
quizAnswerResolved lang =
    case lang of
        Am ->
            "ተመርጧል"

        Ar ->
            "إجابة تم حلها"

        Bg ->
            "Решен отговор"

        Bn ->
            "সমাধানিত উত্তর"

        Ca ->
            "Resposta revelada"

        Cs ->
            "Odhalená odpověď"

        Da ->
            "Afsløret svar"

        De ->
            "Aufgelöste Antwort"

        El ->
            "Απάντηση που αποκαλύφθηκε"

        Es ->
            "Respuesta resuelta"

        Et ->
            "Lahendatud vastus"

        Eu ->
            "Agerian jarritako erantzuna"

        Fa ->
            "پاسخ حل شده"

        Fi ->
            "Paljastettu vastaus"

        Fr ->
            "Réponse résolue"

        Ga ->
            "Freagra nochta"

        Hi ->
            "हल की गई प्रतिक्रिया"

        Hr ->
            "Otkriveni odgovor"

        Hu ->
            "Felfedett válasz"

        Hy ->
            "Լուծված պատասխան"

        It ->
            "Risposta decisiva"

        Ja ->
            "解決済みの回答"

        Ka ->
            "გადაჭრული პასუხი"

        Ko ->
            "이미 푼 퀴즈입니다"

        Lt ->
            "Atskleistas atsakymas"

        Lv ->
            "Atklātā atbilde"

        Nb ->
            "Avslørt svar"

        Nl ->
            "Opgelost antwoord"

        Pa ->
            "ਹੱਲ ਕੀਤਾ ਗਿਆ ਜਵਾਬ"

        Pl ->
            "Ujawniona odpowiedź"

        Pt ->
            "Resposta resolvida."

        Ro ->
            "Răspuns dezvăluit"

        Ru ->
            "Решенный ответ"

        Sk ->
            "Odhalená odpoveď"

        Sl ->
            "Razkrit odgovor"

        Sq ->
            "Përgjigjja e zbuluar"

        Sv ->
            "Avslöjat svar"

        Sw ->
            "Jibu lililotatuliwa"

        Tr ->
            "Açıklanan yanıt"

        Tw ->
            "解决的答案"

        Uk ->
            "Вирішена відповідь"

        Ur ->
            "حل شدہ جواب"

        Zh ->
            "解决的答案"

        _ ->
            "Resolved answer"


surveySubmit : Lang -> String
surveySubmit lang =
    case lang of
        Am ->
            "አመድ"

        Ar ->
            "إرسال "

        Bg ->
            "Изпрати"

        Bn ->
            "জমা দিন"

        Ca ->
            "Envia"

        Cs ->
            "Odeslat"

        Da ->
            "Send"

        De ->
            "Abschicken"

        El ->
            "Υποβολή"

        Es ->
            "enviar"

        Et ->
            "Saada"

        Eu ->
            "Bidali"

        Fa ->
            "ارسال"

        Fi ->
            "Lähetä"

        Fr ->
            "Soumettre"

        Ga ->
            "Seol"

        Hi ->
            "सबमिट करें"

        Hr ->
            "Pošalji"

        Hu ->
            "Küldés"

        Hy ->
            "ներկայացնել"

        It ->
            "Invia"

        Ja ->
            "送信"

        Ka ->
            "გაგზავნა"

        Ko ->
            "제출"

        Lt ->
            "Pateikti"

        Lv ->
            "Iesniegt"

        Nb ->
            "Send"

        Nl ->
            "Verzenden"

        Pa ->
            "ਜਮਾ ਕਰੋ"

        Pl ->
            "Wyślij"

        Pt ->
            "Enviar"

        Ro ->
            "Trimite"

        Ru ->
            "отправить"

        Sk ->
            "Odoslať"

        Sl ->
            "Pošlji"

        Sq ->
            "Dërgo"

        Sv ->
            "Skicka"

        Sw ->
            "Wasilisha"

        Tr ->
            "Gönder"

        Tw ->
            "遞交"

        Uk ->
            "відіслати"

        Ur ->
            "جمع کریں"

        Zh ->
            "遞交"

        _ ->
            "Submit"


surveySubmitted : Lang -> String
surveySubmitted lang =
    case lang of
        Am ->
            "ለአስተያየትዎ እናመሰግናለን!"

        Ar ->
            "شكرًا على ملاحظاتك!"

        Bg ->
            "Благодарим за обратната връзка!"

        Bn ->
            "আপনার মতামতের জন্য ধন্যবাদ!"

        Ca ->
            "Gràcies pels teus comentaris!"

        Cs ->
            "Děkujeme za zpětnou vazbu!"

        Da ->
            "Tak for din feedback!"

        De ->
            "Vielen Dank für dein Feedback!"

        El ->
            "Ευχαριστούμε για τα σχόλιά σου!"

        Es ->
            "¡Gracias por tus comentarios!"

        Et ->
            "Täname tagasiside eest!"

        Eu ->
            "Eskerrik asko zure iritziagatik!"

        Fa ->
            "از بازخورد شما سپاسگزاریم!"

        Fi ->
            "Kiitos palautteestasi!"

        Fr ->
            "Merci pour vos commentaires !"

        Ga ->
            "Go raibh maith agat as d'aiseolas!"

        Hi ->
            "आपकी प्रतिक्रिया के लिए धन्यवाद!"

        Hr ->
            "Hvala na povratnim informacijama!"

        Hu ->
            "Köszönjük a visszajelzésedet!"

        Hy ->
            "Շնորհակալություն ձեր կարծիքի համար։"

        It ->
            "Grazie per il tuo feedback!"

        Ja ->
            "ご意見をお寄せいただきありがとうございます！"

        Ka ->
            "გმადლობთ გამოხმაურებისთვის!"

        Ko ->
            "의견을 보내 주셔서 감사합니다!"

        Lt ->
            "Dėkojame už atsiliepimą!"

        Lv ->
            "Paldies par atsauksmi!"

        Nb ->
            "Takk for tilbakemeldingen din!"

        Nl ->
            "Bedankt voor je feedback!"

        Pa ->
            "ਤੁਹਾਡੀ ਪ੍ਰਤੀਕਿਰਿਆ ਲਈ ਧੰਨਵਾਦ!"

        Pl ->
            "Dziękujemy za opinię!"

        Pt ->
            "Obrigado pelo seu feedback!"

        Ro ->
            "Îți mulțumim pentru feedback!"

        Ru ->
            "Спасибо за ваш отзыв!"

        Sk ->
            "Ďakujeme za spätnú väzbu!"

        Sl ->
            "Hvala za povratne informacije!"

        Sq ->
            "Faleminderit për mendimin tënd!"

        Sv ->
            "Tack för din feedback!"

        Sw ->
            "Asante kwa maoni yako!"

        Tr ->
            "Geri bildiriminiz için teşekkürler!"

        Tw ->
            "感謝您的回饋！"

        Uk ->
            "Дякуємо за ваш відгук!"

        Ur ->
            "آپ کی رائے کا شکریہ!"

        Zh ->
            "感谢您的反馈！"

        _ ->
            "Thank you for your feedback!"


surveyError : Lang -> String
surveyError lang =
    case lang of
        Am ->
            "ከመላኩ በፊት ጥያቄው መመለስ አለበት።"

        Ar ->
            "يجب الإجابة عن السؤال قبل الإرسال."

        Bg ->
            "Преди изпращане трябва да се отговори на въпроса."

        Bn ->
            "জমা দেওয়ার আগে প্রশ্নটির উত্তর দিতে হবে।"

        Ca ->
            "Cal respondre la pregunta abans de l'enviament."

        Cs ->
            "Před odesláním je nutné odpovědět na otázku."

        Da ->
            "Spørgsmålet skal besvares inden afsendelse."

        De ->
            "Die Frage muss vor dem Absenden beantwortet werden."

        El ->
            "Η ερώτηση πρέπει να απαντηθεί πριν από την υποβολή."

        Es ->
            "La pregunta debe responderse antes del envío."

        Et ->
            "Enne saatmist tuleb küsimusele vastata."

        Eu ->
            "Galderari erantzun behar zaio bidali aurretik."

        Fa ->
            "پیش از ارسال باید به پرسش پاسخ داده شود."

        Fi ->
            "Kysymykseen on vastattava ennen lähettämistä."

        Fr ->
            "Il faut répondre à la question avant l'envoi."

        Ga ->
            "Caithfear an cheist a fhreagairt roimh sheoladh."

        Hi ->
            "सबमिट करने से पहले प्रश्न का उत्तर दिया जाना चाहिए।"

        Hr ->
            "Prije slanja potrebno je odgovoriti na pitanje."

        Hu ->
            "Küldés előtt meg kell válaszolni a kérdést."

        Hy ->
            "Ուղարկելուց առաջ պետք է պատասխանել հարցին։"

        It ->
            "È necessario rispondere alla domanda prima dell'invio."

        Ja ->
            "送信する前に質問に回答する必要があります。"

        Ka ->
            "გაგზავნამდე აუცილებელია კითხვაზე პასუხის გაცემა."

        Ko ->
            "제출하기 전에 질문에 답해야 합니다."

        Lt ->
            "Prieš pateikiant būtina atsakyti į klausimą."

        Lv ->
            "Pirms iesniegšanas jāatbild uz jautājumu."

        Nb ->
            "Spørsmålet må besvares før innsending."

        Nl ->
            "De vraag moet vóór het verzenden worden beantwoord."

        Pa ->
            "ਜਮ੍ਹਾਂ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਸਵਾਲ ਦਾ ਜਵਾਬ ਦਿੱਤਾ ਜਾਣਾ ਲਾਜ਼ਮੀ ਹੈ।"

        Pl ->
            "Przed wysłaniem należy odpowiedzieć na pytanie."

        Pt ->
            "A pergunta deve ser respondida antes do envio."

        Ro ->
            "Înainte de trimitere trebuie să se răspundă la întrebare."

        Ru ->
            "Перед отправкой необходимо ответить на вопрос."

        Sk ->
            "Pred odoslaním je potrebné odpovedať na otázku."

        Sl ->
            "Pred pošiljanjem je treba odgovoriti na vprašanje."

        Sq ->
            "Para dërgimit duhet t'i jepet përgjigje pyetjes."

        Sv ->
            "Frågan måste besvaras före inskickning."

        Sw ->
            "Swali linapaswa kujibiwa kabla ya kuwasilisha."

        Tr ->
            "Göndermeden önce soru yanıtlanmalıdır."

        Tw ->
            "提交前必須回答此問題。"

        Uk ->
            "Перед надсиланням потрібно відповісти на запитання."

        Ur ->
            "جمع کرانے سے پہلے سوال کا جواب دیا جانا ضروری ہے۔"

        Zh ->
            "提交前必须回答此问题。"

        _ ->
            "This question must be answered before submitting."


surveyErrorMatrix : Lang -> String
surveyErrorMatrix lang =
    case lang of
        Am ->
            "ከመላኩ በፊት እያንዳንዱ ረድፍ መመለስ አለበት።"

        Ar ->
            "يجب الإجابة عن كل صف قبل الإرسال."

        Bg ->
            "Преди изпращане трябва да се отговори на всеки ред."

        Bn ->
            "জমা দেওয়ার আগে প্রতিটি সারির উত্তর দিতে হবে।"

        Ca ->
            "Cal respondre totes les files abans de l'enviament."

        Cs ->
            "Před odesláním je nutné odpovědět v každém řádku."

        Da ->
            "Alle rækker skal besvares inden afsendelse."

        De ->
            "Vor dem Absenden muss jede Zeile beantwortet werden."

        El ->
            "Κάθε γραμμή πρέπει να απαντηθεί πριν από την υποβολή."

        Es ->
            "Todas las filas deben responderse antes del envío."

        Et ->
            "Enne saatmist tuleb vastata igale reale."

        Eu ->
            "Errenkada guztiei erantzun behar zaie bidali aurretik."

        Fa ->
            "پیش از ارسال باید به همهٔ ردیف\u{200C}ها پاسخ داده شود."

        Fi ->
            "Jokaiseen riviin on vastattava ennen lähettämistä."

        Fr ->
            "Il faut répondre à chaque ligne avant l'envoi."

        Ga ->
            "Caithfear gach ró a fhreagairt roimh sheoladh."

        Hi ->
            "सबमिट करने से पहले हर पंक्ति का उत्तर दिया जाना चाहिए।"

        Hr ->
            "Prije slanja potrebno je odgovoriti na svaki redak."

        Hu ->
            "Küldés előtt minden sort meg kell válaszolni."

        Hy ->
            "Ուղարկելուց առաջ պետք է պատասխանել բոլոր տողերին։"

        It ->
            "È necessario rispondere a ogni riga prima dell'invio."

        Ja ->
            "送信する前にすべての行に回答する必要があります。"

        Ka ->
            "გაგზავნამდე აუცილებელია ყველა სტრიქონზე პასუხის გაცემა."

        Ko ->
            "제출하기 전에 모든 행에 답해야 합니다."

        Lt ->
            "Prieš pateikiant būtina atsakyti į kiekvieną eilutę."

        Lv ->
            "Pirms iesniegšanas jāatbild uz katru rindu."

        Nb ->
            "Alle radene må besvares før innsending."

        Nl ->
            "Elke rij moet vóór het verzenden worden beantwoord."

        Pa ->
            "ਜਮ੍ਹਾਂ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਹਰ ਕਤਾਰ ਦਾ ਜਵਾਬ ਦਿੱਤਾ ਜਾਣਾ ਲਾਜ਼ਮੀ ਹੈ।"

        Pl ->
            "Przed wysłaniem należy udzielić odpowiedzi w każdym wierszu."

        Pt ->
            "Todas as linhas devem ser respondidas antes do envio."

        Ro ->
            "Înainte de trimitere trebuie să se răspundă pe fiecare rând."

        Ru ->
            "Перед отправкой необходимо ответить в каждой строке."

        Sk ->
            "Pred odoslaním je potrebné odpovedať v každom riadku."

        Sl ->
            "Pred pošiljanjem je treba odgovoriti v vsaki vrstici."

        Sq ->
            "Para dërgimit duhet t'i jepet përgjigje çdo rreshti."

        Sv ->
            "Alla rader måste besvaras före inskickning."

        Sw ->
            "Kila safu inapaswa kujibiwa kabla ya kuwasilisha."

        Tr ->
            "Göndermeden önce her satır yanıtlanmalıdır."

        Tw ->
            "提交前必須回答每一列。"

        Uk ->
            "Перед надсиланням потрібно відповісти в кожному рядку."

        Ur ->
            "جمع کرانے سے پہلے ہر قطار کا جواب دیا جانا ضروری ہے۔"

        Zh ->
            "提交前必须回答每一行。"

        _ ->
            "Every row must be answered before submitting."


surveyText : Lang -> String
surveyText lang =
    case lang of
        Am ->
            "ግል ጽሑፍ ያስገቡ..."

        Ar ->
            "أدخل نص..."

        Bg ->
            "Въведете текст..."

        Bn ->
            "কিছু লিখুন..."

        Ca ->
            "Introdueix un text..."

        Cs ->
            "Zadej text..."

        Da ->
            "Indtast en tekst..."

        De ->
            "Texteingabe ..."

        El ->
            "Πληκτρολόγησε ένα κείμενο..."

        Es ->
            "introducir texto"

        Et ->
            "Sisesta tekst..."

        Eu ->
            "Idatzi testua..."

        Fa ->
            "لطفا متن وارد کنید"

        Fi ->
            "Kirjoita tekstiä..."

        Fr ->
            "Saisie de texte ..."

        Ga ->
            "Cuir téacs isteach..."

        Hi ->
            "टेक्स्ट इनपुट ..."

        Hr ->
            "Unesi tekst..."

        Hu ->
            "Írj be szöveget..."

        Hy ->
            "Մուտքագրեք որոշ տեքստ"

        It ->
            "Immetti del testo"

        Ja ->
            "テキストを入力してください..."

        Ka ->
            "შეიყვანეთ ტექსტი..."

        Ko ->
            "내용을 입력해주세요."

        Lt ->
            "Įvesk tekstą..."

        Lv ->
            "Ievadi tekstu..."

        Nb ->
            "Skriv inn tekst..."

        Nl ->
            "Tekstinvoer ..."

        Pa ->
            "ਕੁਝ ਟੈਕਸਟ ਦਿਓ..."

        Pl ->
            "Wpisz tekst..."

        Pt ->
            "Digite algum texto..."

        Ro ->
            "Introdu un text..."

        Ru ->
            "ввод текста"

        Sk ->
            "Zadaj text..."

        Sl ->
            "Vnesi besedilo..."

        Sq ->
            "Shkruaj një tekst..."

        Sv ->
            "Skriv en text..."

        Sw ->
            "Weka maandishi..."

        Tr ->
            "Bir metin girin..."

        Tw ->
            "輸入文字..."

        Uk ->
            "Ввід тексту ..."

        Ur ->
            "کچھ متن درج کریں..."

        Zh ->
            "輸入文字..."

        _ ->
            "Enter some text..."


surveyUpdate : Lang -> String
surveyUpdate lang =
    case lang of
        Am ->
            "አዘምን"

        Ar ->
            "تحديث"

        Bg ->
            "Актуализирай"

        Bn ->
            "হালনাগাদ করুন"

        Ca ->
            "Actualitza"

        Cs ->
            "Aktualizovat"

        Da ->
            "Opdater"

        De ->
            "Aktualisieren"

        El ->
            "Ενημέρωση"

        Es ->
            "Actualizar"

        Et ->
            "Uuenda"

        Eu ->
            "Eguneratu"

        Fa ->
            "به\u{200C}روزرسانی"

        Fi ->
            "Päivitä"

        Fr ->
            "Mettre à jour"

        Ga ->
            "Nuashonraigh"

        Hi ->
            "अपडेट करें"

        Hr ->
            "Ažuriraj"

        Hu ->
            "Frissítés"

        Hy ->
            "Թարմացնել"

        It ->
            "Aggiorna"

        Ja ->
            "更新"

        Ka ->
            "განახლება"

        Ko ->
            "업데이트"

        Lt ->
            "Atnaujinti"

        Lv ->
            "Atjaunināt"

        Nb ->
            "Oppdater"

        Nl ->
            "Bijwerken"

        Pa ->
            "ਅੱਪਡੇਟ ਕਰੋ"

        Pl ->
            "Aktualizuj"

        Pt ->
            "Atualizar"

        Ro ->
            "Actualizează"

        Ru ->
            "Обновить"

        Sk ->
            "Aktualizovať"

        Sl ->
            "Posodobi"

        Sq ->
            "Përditëso"

        Sv ->
            "Uppdatera"

        Sw ->
            "Sasisha"

        Tr ->
            "Güncelle"

        Tw ->
            "更新"

        Uk ->
            "Оновити"

        Ur ->
            "اپ ڈیٹ کریں"

        Zh ->
            "更新"

        _ ->
            "Update"


sortAsc : Lang -> String
sortAsc lang =
    case lang of
        Am ->
            "ቅደም አስቀድሞ"

        Ar ->
            "ترتيب تصاعدي"

        Bn ->
            "আরোহী ক্রমানুসারে সাজান"

        Ca ->
            "ordena de manera ascendent"

        Cs ->
            "řadit vzestupně"

        Da ->
            "sortér stigende"

        De ->
            "aufsteigend sortieren"

        El ->
            "αύξουσα ταξινόμηση"

        Es ->
            "orden ascendente"

        Et ->
            "sorteeri kasvavalt"

        Eu ->
            "ordenatu gorantz"

        Fi ->
            "lajittele nousevasti"

        Fr ->
            "trier par ordre croissant"

        Ga ->
            "sórtáil in ord ardaitheach"

        Hi ->
            "आरोही क्रमबद्ध करें"

        Hr ->
            "sortiraj uzlazno"

        Hu ->
            "növekvő rendezés"

        It ->
            "ordine crescente"

        Ja ->
            "昇順に並べ替え"

        Ka ->
            "ზრდადობით დალაგება"

        Ko ->
            "오름차순 정렬"

        Lt ->
            "rikiuoti didėjančiai"

        Lv ->
            "kārtot augošā secībā"

        Nb ->
            "sorter stigende"

        Nl ->
            "oplopend sorteren"

        Pa ->
            "ਚੜਦੀ ਕ੍ਰਮ ਵਿੱਚ"

        Pl ->
            "sortuj rosnąco"

        Pt ->
            "ordenar em ordem crescente"

        Ro ->
            "sortează crescător"

        Ru ->
            "сортировать по возрастанию"

        Sk ->
            "zoradiť vzostupne"

        Sl ->
            "razvrsti naraščajoče"

        Sq ->
            "rendit në rritje"

        Sv ->
            "sortera stigande"

        Sw ->
            "kupanga kupanda"

        Tr ->
            "artan sırada sırala"

        Uk ->
            "сортування за зростанням"

        Ur ->
            "صعودی ترتیب"

        _ ->
            "sort ascending"


sortDesc : Lang -> String
sortDesc lang =
    case lang of
        Am ->
            "ታሪክ አስቀድሞ"

        Ar ->
            "ترتيب تنازلي"

        Bn ->
            "অবরোহী ক্রমানুসারে সাজান"

        Ca ->
            "ordena de manera descendent"

        Cs ->
            "řadit sestupně"

        Da ->
            "sortér faldende"

        De ->
            "absteigend sortieren"

        El ->
            "φθίνουσα ταξινόμηση"

        Es ->
            "orden descendiente"

        Et ->
            "sorteeri kahanevalt"

        Eu ->
            "ordenatu beherantz"

        Fi ->
            "lajittele laskevasti"

        Fr ->
            "trier par ordre décroissant"

        Ga ->
            "sórtáil in ord íslitheach"

        Hi ->
            "अवरोही क्रमबद्ध करें"

        Hr ->
            "sortiraj silazno"

        Hu ->
            "csökkenő rendezés"

        It ->
            "ordine discendente"

        Ja ->
            "降順に並べ替え"

        Ka ->
            "კლებადობით დალაგება"

        Ko ->
            "내림차순 정렬"

        Lt ->
            "rikiuoti mažėjančiai"

        Lv ->
            "kārtot dilstošā secībā"

        Nb ->
            "sorter synkende"

        Nl ->
            "sorteer aflopend"

        Pa ->
            "ਡਿਸਕੰਡਿੰਗ ਕ੍ਰਮ ਵਿੱਚ"

        Pl ->
            "sortuj malejąco"

        Pt ->
            "ordenar em ordem decrescente"

        Ro ->
            "sortează descrescător"

        Ru ->
            "сортировка по убыванию"

        Sk ->
            "zoradiť zostupne"

        Sl ->
            "razvrsti padajoče"

        Sq ->
            "rendit në zbritje"

        Sv ->
            "sortera fallande"

        Sw ->
            "panga kushuka"

        Tr ->
            "azalan sırada sırala"

        Uk ->
            "сортувати за спаданням"

        Ur ->
            "نزولی ترتیب"

        _ ->
            "sort descending"


sortNot : Lang -> String
sortNot lang =
    case lang of
        Am ->
            "ተመርጧል"

        Ar ->
            "غير مرتب"

        Bn ->
            "বিন্যাসযোগ্য নয়"

        Ca ->
            "sense ordenar"

        Cs ->
            "neseřazeno"

        Da ->
            "ikke sorteret"

        De ->
            "nicht sortiert"

        El ->
            "χωρίς ταξινόμηση"

        Es ->
            "no ordenado"

        Et ->
            "sortimata"

        Eu ->
            "ordenatu gabe"

        Fi ->
            "ei lajiteltu"

        Fr ->
            "non trié"

        Ga ->
            "gan sórtáil"

        Hi ->
            "क्रमबद्ध नहीं"

        Hr ->
            "nije sortirano"

        Hu ->
            "rendezetlen"

        It ->
            "non ordinato"

        Ja ->
            "未並べ替え"

        Ka ->
            "არ არის დალაგებული"

        Ko ->
            "정렬 안 됨"

        Lt ->
            "nesurikiuota"

        Lv ->
            "nav sakārtots"

        Nb ->
            "ikke sortert"

        Nl ->
            "niet gesorteerd"

        Pa ->
            "ਨਾ ਸੋਰਟ"

        Pl ->
            "nieposortowane"

        Pt ->
            "não ordenado"

        Ro ->
            "nesortat"

        Ru ->
            "не отсортировано"

        Sk ->
            "nezoradené"

        Sl ->
            "nerazvrščeno"

        Sq ->
            "pa renditje"

        Sv ->
            "osorterat"

        Sw ->
            "haijapangwa"

        Tr ->
            "sıralanmamış"

        Uk ->
            "не сортується"

        Ur ->
            "ترتیب نہیں دی گئی"

        _ ->
            "not sorted"


chartPie : Lang -> String
chartPie lang =
    case lang of
        Am ->
            "ፒ ሾስትን ጫን ቦታ"

        Ar ->
            "مخطط دائري"

        Bn ->
            "পাই চার্ট"

        Ca ->
            "Gràfic de sectors"

        Cs ->
            "Výsečový graf"

        Da ->
            "Cirkeldiagram"

        De ->
            "Tortendiagramm"

        El ->
            "Κυκλικό διάγραμμα"

        Et ->
            "Sektordiagramm"

        Eu ->
            "Sektore-diagrama"

        Fi ->
            "Ympyräkaavio"

        Fr ->
            "Diagramme en secteurs"

        Ga ->
            "Píchairt"

        Hi ->
            "पाई चार्ट"

        Hr ->
            "Tortni grafikon"

        Hu ->
            "Kördiagram"

        It ->
            "Diagramma a torta"

        Ja ->
            "円グラフ"

        Ka ->
            "პაი დიაგრამა"

        Ko ->
            "파이 차트"

        Lt ->
            "Skritulinė diagrama"

        Lv ->
            "Sektoru diagramma"

        Nb ->
            "Sektordiagram"

        Pa ->
            "ਪਾਈ ਚਾਰਟ"

        Pl ->
            "Wykres kołowy"

        Pt ->
            "Gráfico de pizza"

        Ro ->
            "Diagramă circulară"

        Sk ->
            "Koláčový graf"

        Sl ->
            "Tortni grafikon"

        Sq ->
            "Diagram rrethor"

        Sv ->
            "Cirkeldiagram"

        Sw ->
            "chati ya pai"

        Tr ->
            "Pasta grafiği"

        Tw ->
            "饼图"

        Ur ->
            "پائی چارٹ"

        Zh ->
            "饼图"

        _ ->
            "Pie chart"


chartBar : Lang -> String
chartBar lang =
    case lang of
        Am ->
            "ባር ሾስትን ጫን ቦታ"

        Ar ->
            "مخطط شريطي"

        Bn ->
            "বার চার্ট"

        Ca ->
            "Gràfic de barres"

        Cs ->
            "Sloupcový graf"

        Da ->
            "Søjlediagram"

        De ->
            "Balkendiagramm"

        El ->
            "Ραβδόγραμμα"

        Et ->
            "Tulpdiagramm"

        Eu ->
            "Barra-diagrama"

        Fi ->
            "Pylväskaavio"

        Fr ->
            "Diagramme en bâtons"

        Ga ->
            "Barrachairt"

        Hi ->
            "बार चार्ट"

        Hr ->
            "Stupčasti grafikon"

        Hu ->
            "Oszlopdiagram"

        It ->
            "Diagramma a barre"

        Ja ->
            "棒グラフ"

        Ka ->
            "ბარი დიაგრამა"

        Ko ->
            "바 차트"

        Lt ->
            "Stulpelinė diagrama"

        Lv ->
            "Stabiņu diagramma"

        Nb ->
            "Stolpediagram"

        Pa ->
            "ਬਾਰ ਚਾਰਟ"

        Pl ->
            "Wykres słupkowy"

        Pt ->
            "Gráfico de barras"

        Ro ->
            "Diagramă cu bare"

        Sk ->
            "Stĺpcový graf"

        Sl ->
            "Stolpčni grafikon"

        Sq ->
            "Diagram me shtylla"

        Sv ->
            "Stapeldiagram"

        Sw ->
            "Chati ya paa"

        Tr ->
            "Çubuk grafiği"

        Tw ->
            "柱状图"

        Ur ->
            "بار چارٹ"

        Zh ->
            "柱状图"

        _ ->
            "Bar chart"


chartLine : Lang -> String
chartLine lang =
    case lang of
        Am ->
            "ስብስብ ሾስትን ጫን ቦታ"

        Ar ->
            "مخطط خطي"

        Bn ->
            "লাইন চার্ট"

        Ca ->
            "Gràfic de línies"

        Cs ->
            "Spojnicový graf"

        Da ->
            "Linjediagram"

        De ->
            "Liniendiagramm"

        El ->
            "Γραμμικό διάγραμμα"

        Et ->
            "Joondiagramm"

        Eu ->
            "Lerro-diagrama"

        Fi ->
            "Viivakaavio"

        Fr ->
            "Graphique linéaire"

        Ga ->
            "Línechairt"

        Hi ->
            "लाइन चार्ट"

        Hr ->
            "Linijski grafikon"

        Hu ->
            "Vonaldiagram"

        It ->
            "Diagramma a linee"

        Ja ->
            "折れ線グラフ"

        Ka ->
            "ხაზიანი დიაგრამა"

        Ko ->
            "라인 차트"

        Lt ->
            "Linijinė diagrama"

        Lv ->
            "Līniju diagramma"

        Nb ->
            "Linjediagram"

        Pa ->
            "ਰੇਖਾ ਚਾਰਟ"

        Pl ->
            "Wykres liniowy"

        Pt ->
            "Gráfico de linhas"

        Ro ->
            "Diagramă liniară"

        Sk ->
            "Čiarový graf"

        Sl ->
            "Črtni grafikon"

        Sq ->
            "Diagram vijor"

        Sv ->
            "Linjediagram"

        Sw ->
            "Chati ya mstari"

        Tr ->
            "Çizgi grafiği"

        Tw ->
            "折线图"

        Ur ->
            "لائن چارٹ"

        Zh ->
            "折线图"

        _ ->
            "Line chart"


chartScatter : Lang -> String
chartScatter lang =
    case lang of
        Am ->
            "መስመር ግርግር ስቀር ቦታ"

        Ar ->
            "مخطط مبعثر"

        Bn ->
            "স্ক্যাটার প্লট"

        Ca ->
            "Diagrama de dispersió"

        Cs ->
            "Bodový graf"

        Da ->
            "Punktdiagram"

        De ->
            "Streudiagramm"

        El ->
            "Διάγραμμα διασποράς"

        Et ->
            "Hajuvusdiagramm"

        Eu ->
            "Sakabanatze-diagrama"

        Fi ->
            "Hajontakaavio"

        Fr ->
            "Nuage de points"

        Ga ->
            "Scaipghraf"

        Hi ->
            "स्कैटरप्लॉट"

        Hr ->
            "Raspršeni grafikon"

        Hu ->
            "Szórásdiagram"

        It ->
            "Diagramma a dispersione"

        Ja ->
            "散布図"

        Ka ->
            "გადანაწილების დიაგრამა"

        Ko ->
            "분포도"

        Lt ->
            "Sklaidos diagrama"

        Lv ->
            "Izkliedes diagramma"

        Nb ->
            "Spredningsdiagram"

        Pa ->
            "ਸਿਆਨਾ ਚਿੰਨ੍ਹ ਚਾਰਟ"

        Pl ->
            "Wykres punktowy"

        Pt ->
            "Gráfico de dispersão"

        Ro ->
            "Diagramă de dispersie"

        Sk ->
            "Bodový graf"

        Sl ->
            "Raztreseni grafikon"

        Sq ->
            "Diagram shpërndarjeje"

        Sv ->
            "Spridningsdiagram"

        Sw ->
            "Kutawanya njama"

        Tr ->
            "Dağılım grafiği"

        Tw ->
            "散点图"

        Ur ->
            "اسکیٹر پلاٹ"

        Zh ->
            "散点图"

        _ ->
            "Scatter plot"


chartRadar : Lang -> String
chartRadar lang =
    case lang of
        Am ->
            "ራዳር ሾስት"

        Ar ->
            "مخطط نسيجي"

        Bn ->
            "রেডার চার্ট"

        Ca ->
            "Gràfic de radar"

        Cs ->
            "Paprskový graf"

        Da ->
            "Radardiagram"

        De ->
            "Radar-Karte"

        El ->
            "Διάγραμμα ραντάρ"

        Et ->
            "Radardiagramm"

        Eu ->
            "Radar-diagrama"

        Fi ->
            "Tutkakaavio"

        Fr ->
            "Graphique en radar"

        Ga ->
            "Cairt radair"

        Hi ->
            "रडार मैप"

        Hr ->
            "Radarski grafikon"

        Hu ->
            "Sugárdiagram"

        It ->
            "Diagramma Radar"

        Ja ->
            "レーダーチャート"

        Ka ->
            "რადარი დიაგრამა"

        Ko ->
            "레이더 차트"

        Lt ->
            "Radarinė diagrama"

        Lv ->
            "Radara diagramma"

        Nb ->
            "Radardiagram"

        Pa ->
            "ਰਾਡਾਰ ਚਾਰਟ"

        Pl ->
            "Wykres radarowy"

        Pt ->
            "Gráfico de radar"

        Ro ->
            "Diagramă radar"

        Sk ->
            "Radarový graf"

        Sl ->
            "Radarski grafikon"

        Sq ->
            "Diagram radar"

        Sv ->
            "Radardiagram"

        Sw ->
            "Chati ya rada"

        Tr ->
            "Radar grafiği"

        Tw ->
            "雷达图"

        Ur ->
            "ریڈار چارٹ"

        Zh ->
            "雷达图"

        _ ->
            "Radar chart"


chartBoxplot : Lang -> String
chartBoxplot lang =
    case lang of
        Am ->
            "ቦክስ ፕሎት"

        Bn ->
            "বক্স প্লট"

        Ca ->
            "Diagrama de caixa"

        Cs ->
            "Krabicový graf"

        Da ->
            "Boksplot"

        De ->
            "Boxplot"

        El ->
            "Θηκόγραμμα"

        Et ->
            "Karpdiagramm"

        Eu ->
            "Kutxa-diagrama"

        Fi ->
            "Laatikkokaavio"

        Fr ->
            "Boîte à moustaches"

        Ga ->
            "Boscaplot"

        Hi ->
            "बॉक्सप्लॉट"

        Hr ->
            "Kutijasti dijagram"

        Hu ->
            "Dobozdiagram"

        It ->
            "Diagramma a scatola"

        Ja ->
            "ボックスプロット"

        Ka ->
            "ყუთოვანი დიაგრამა"

        Ko ->
            "상자 그림"

        Lt ->
            "Stačiakampė diagrama"

        Lv ->
            "Kastveida diagramma"

        Nb ->
            "Boksplott"

        Pa ->
            "ਬਾਕਸਪਲਾਟ"

        Pl ->
            "Wykres pudełkowy"

        Pt ->
            "Diagrama de caixa"

        Ro ->
            "Diagramă cutie"

        Sk ->
            "Krabicový graf"

        Sl ->
            "Škatla z brki"

        Sq ->
            "Diagram kuti"

        Sv ->
            "Lådagram"

        Sw ->
            "Boxplot"

        Tr ->
            "Kutu grafiği"

        Tw ->
            "箱型图"

        Ur ->
            "باکس پلاٹ"

        Zh ->
            "箱型图"

        _ ->
            "Boxplot"


chartHeatmap : Lang -> String
chartHeatmap lang =
    case lang of
        Am ->
            "ሜይፕ ሾስት"

        Ar ->
            "خريطة التمثيل اللوني"

        Bn ->
            "হিটম্যাপ"

        Ca ->
            "Mapa de calor"

        Cs ->
            "Teplotní mapa"

        Da ->
            "Varmekort"

        De ->
            "Heatmap"

        El ->
            "Θερμικός χάρτης"

        Et ->
            "Soojuskaart"

        Eu ->
            "Bero-mapa"

        Fi ->
            "Lämpökartta"

        Fr ->
            "Carte de chaleur"

        Ga ->
            "Léarscáil teasa"

        Hi ->
            "हीटमैप"

        Hr ->
            "Toplinska karta"

        Hu ->
            "Hőtérkép"

        It ->
            "Mappa termica"

        Ja ->
            "ヒートマップ"

        Ka ->
            "თბილობის რუქა"

        Ko ->
            "히트 맵"

        Lt ->
            "Šilumos žemėlapis"

        Lv ->
            "Siltuma karte"

        Nb ->
            "Varmekart"

        Pa ->
            "ਹੀਟਮੈਪ"

        Pl ->
            "Mapa cieplna"

        Pt ->
            "Mapa de calor"

        Ro ->
            "Hartă termică"

        Sk ->
            "Teplotná mapa"

        Sl ->
            "Toplotni zemljevid"

        Sq ->
            "Hartë nxehtësie"

        Sv ->
            "Värmekarta"

        Sw ->
            "Ramani ya joto"

        Tr ->
            "Isı haritası"

        Tw ->
            "热力图"

        Ur ->
            "ہیٹ میپ"

        Zh ->
            "热力图"

        _ ->
            "Heat map"


chartMap : Lang -> String
chartMap lang =
    case lang of
        Am ->
            "ካርታ"

        Ar ->
            "خريطة"

        Bn ->
            "ম্যাপ"

        Ca ->
            "Mapa"

        Cs ->
            "Mapa"

        Da ->
            "Kort"

        De ->
            "Karte"

        El ->
            "Χάρτης"

        Et ->
            "Kaart"

        Eu ->
            "Mapa"

        Fi ->
            "Kartta"

        Fr ->
            "Carte"

        Ga ->
            "Léarscáil"

        Hi ->
            "मैप"

        Hr ->
            "Karta"

        Hu ->
            "Térkép"

        It ->
            "Mappa"

        Ja ->
            "地図"

        Ka ->
            "რუქა"

        Ko ->
            "맵"

        Lt ->
            "Žemėlapis"

        Lv ->
            "Karte"

        Nb ->
            "Kart"

        Pa ->
            "ਨਕਸ਼ਾ"

        Pl ->
            "Mapa"

        Pt ->
            "Mapa"

        Ro ->
            "Hartă"

        Sk ->
            "Mapa"

        Sl ->
            "Zemljevid"

        Sq ->
            "Hartë"

        Sv ->
            "Karta"

        Sw ->
            "ramani"

        Tr ->
            "Harita"

        Tw ->
            "地图"

        Ur ->
            "نقشہ"

        Zh ->
            "地图"

        _ ->
            "Map"


chartParallel : Lang -> String
chartParallel lang =
    case lang of
        Am ->
            "ፓራለል ኮይላርድን ቦታ"

        Ar ->
            "متوازي"

        Bn ->
            "প্যারালেল কো\u{0991}র্ডিনেট ম্যাপ"

        Ca ->
            "Gràfic de coordenades paral·leles"

        Cs ->
            "Graf paralelních souřadnic"

        Da ->
            "Diagram med parallelle koordinater"

        De ->
            "Parallele Koordinatenkarte"

        El ->
            "Διάγραμμα παράλληλων συντεταγμένων"

        Et ->
            "Paralleelkoordinaatide diagramm"

        Eu ->
            "Koordenatu paraleloen diagrama"

        Fi ->
            "Rinnakkaiskoordinaattikaavio"

        Fr ->
            "Carte de coordonnées parallèles"

        Ga ->
            "Cairt comhordanáidí comhthreomhara"

        Hi ->
            "समानांतर समन्वय मानचित्र"

        Hr ->
            "Dijagram paralelnih koordinata"

        Hu ->
            "Párhuzamos koordinátadiagram"

        It ->
            "Mappa a coordinate parallele"

        Ja ->
            "パラレル座標マップ"

        Ka ->
            "პარალელური კოორდინატების რუქა"

        Ko ->
            "평행 좌표 맵"

        Lt ->
            "Lygiagrečių koordinačių diagrama"

        Lv ->
            "Paralēlo koordinātu diagramma"

        Nb ->
            "Diagram med parallelle koordinater"

        Pl ->
            "Wykres współrzędnych równoległych"

        Pt ->
            "Mapa de coordenadas paralelas"

        Ro ->
            "Diagramă cu coordonate paralele"

        Sk ->
            "Graf paralelných súradníc"

        Sl ->
            "Grafikon vzporednih koordinat"

        Sq ->
            "Diagram me koordinata paralele"

        Sv ->
            "Diagram med parallella koordinater"

        Sw ->
            "Ramani ya kuratibu sambamba"

        Tr ->
            "Paralel koordinat grafiği"

        Tw ->
            "平行坐标图"

        Ur ->
            "متوازی کوآرڈینیٹ نقشہ"

        Zh ->
            "平行坐标图"

        _ ->
            "Parallel coordinate map"


chartLines : Lang -> String
chartLines lang =
    case lang of
        Am ->
            "ስብስቦች ሾስት"

        Ar ->
            "خطوط"

        Bn ->
            "লাইন গ্রাফ"

        Ca ->
            "Gràfic lineal"

        Cs ->
            "Čárový graf"

        Da ->
            "Linjegraf"

        De ->
            "Liniendiagramm"

        El ->
            "Γραμμικό γράφημα"

        Et ->
            "Joongraafik"

        Eu ->
            "Lerro-grafikoa"

        Fi ->
            "Viivakuvaaja"

        Fr ->
            "Graphe linéaire"

        Ga ->
            "Líneghraf"

        Hi ->
            "लाइन चार्ट"

        Hr ->
            "Linijski graf"

        Hu ->
            "Vonalgrafikon"

        It ->
            "Grafico a linee"

        Ja ->
            "折れ線グラフ"

        Ka ->
            "ხაზოვანი გრაფიკი"

        Ko ->
            "선 그래프"

        Lt ->
            "Linijinis grafikas"

        Lv ->
            "Līniju grafiks"

        Nb ->
            "Linjegraf"

        Pl ->
            "Wykres liniowy"

        Pt ->
            "Gráfico de linhas"

        Ro ->
            "Grafic liniar"

        Sk ->
            "Čiarový graf"

        Sl ->
            "Črtni graf"

        Sq ->
            "Grafik vijor"

        Sv ->
            "Linjegraf"

        Sw ->
            "Grafu ya mstari"

        Tr ->
            "Çizgi grafiği"

        Tw ->
            "线图"

        Ur ->
            "لائن گراف"

        Zh ->
            "线图"

        _ ->
            "Line graph"


chartGraph : Lang -> String
chartGraph lang =
    case lang of
        Am ->
            "ባህሪዎች ሾስት"

        Ar ->
            "رسم بياني"

        Bn ->
            "সম্পর্ক গ্রাফ"

        Ca ->
            "Graf de relacions"

        Cs ->
            "Graf vztahů"

        Da ->
            "Relationsgraf"

        De ->
            "Beziehungsgrafik"

        El ->
            "Γράφος σχέσεων"

        Et ->
            "Seoste graaf"

        Eu ->
            "Erlazio-grafoa"

        Fi ->
            "Suhdeverkko"

        Fr ->
            "Graphe de relations"

        Ga ->
            "Graf gaolmhaireachtaí"

        Hi ->
            "रिलेशनशिप ग्राफ"

        Hr ->
            "Graf odnosa"

        Hu ->
            "Kapcsolati gráf"

        It ->
            "Grafico delle relazioni"

        Ja ->
            "関係グラフ"

        Ka ->
            "კავშირების გრაფიკი"

        Ko ->
            "관계도"

        Lt ->
            "Ryšių grafas"

        Lv ->
            "Saistību grafs"

        Nb ->
            "Relasjonsgraf"

        Pl ->
            "Graf relacji"

        Pt ->
            "Gráfico de relacionamento"

        Ro ->
            "Graf de relații"

        Sk ->
            "Graf vzťahov"

        Sl ->
            "Graf povezav"

        Sq ->
            "Graf marrëdhëniesh"

        Sv ->
            "Relationsgraf"

        Sw ->
            "Grafu ya uhusiano"

        Tr ->
            "İlişki grafiği"

        Tw ->
            "关系图"

        Ur ->
            "رابطہ گراف"

        Zh ->
            "关系图"

        _ ->
            "Relationship graph"


chartSankey : Lang -> String
chartSankey lang =
    case lang of
        Am ->
            "ሳንኪ ዲዚግም"

        Ar ->
            "مخطط سانكي"

        Bn ->
            "স্যাঙ্কি ডায়াগ্রাম"

        Ca ->
            "Diagrama de Sankey"

        Cs ->
            "Sankeyův diagram"

        Da ->
            "Sankey-diagram"

        De ->
            "Sankey-Diagramm"

        El ->
            "Διάγραμμα Sankey"

        Et ->
            "Sankey diagramm"

        Eu ->
            "Sankey diagrama"

        Fi ->
            "Sankey-kaavio"

        Fr ->
            "Diagramme de Sankey"

        Ga ->
            "Léaráid Sankey"

        Hi ->
            "सैंके आरेख"

        Hr ->
            "Sankeyjev dijagram"

        Hu ->
            "Sankey-diagram"

        It ->
            "Diagramma di Sankey"

        Ja ->
            "サンキーダイアグラム"

        Ka ->
            "სანკის დიაგრამა"

        Ko ->
            "생키 다이어그램"

        Lt ->
            "Sankey diagrama"

        Lv ->
            "Sankey diagramma"

        Nb ->
            "Sankey-diagram"

        Pl ->
            "Diagram Sankeya"

        Pt ->
            "Diagrama de Sankey"

        Ro ->
            "Diagramă Sankey"

        Sk ->
            "Sankeyho diagram"

        Sl ->
            "Sankeyjev diagram"

        Sq ->
            "Diagram Sankey"

        Sv ->
            "Sankeydiagram"

        Sw ->
            "mchoro wa Sankey"

        Tr ->
            "Sankey diyagramı"

        Tw ->
            "桑基图"

        Ur ->
            "سنکی ڈایاگرام"

        Zh ->
            "桑基图"

        _ ->
            "Sankey diagram"


chartFunnel : Lang -> String
chartFunnel lang =
    case lang of
        Am ->
            "ፋንኤል ጫን ቦታ"

        Ar ->
            "مخطط قمعي"

        Bn ->
            "ফানেল চার্ট"

        Ca ->
            "Gràfic d'embut"

        Cs ->
            "Trychtýřový graf"

        Da ->
            "Tragtdiagram"

        De ->
            "Trichterdiagramm"

        El ->
            "Διάγραμμα χοάνης"

        Et ->
            "Lehterdiagramm"

        Eu ->
            "Inbutu-diagrama"

        Fi ->
            "Suppilokaavio"

        Fr ->
            "Entonnoir"

        Ga ->
            "Cairt tonnadóra"

        Hi ->
            "फ़नल चार्ट"

        Hr ->
            "Ljevkasti grafikon"

        Hu ->
            "Tölcsérdiagram"

        It ->
            "Grafico a imbuto"

        Ja ->
            "ファネルチャート"

        Ka ->
            "ფანელი დიაგრამა"

        Ko ->
            "퍼널 차트"

        Lt ->
            "Piltuvėlio diagrama"

        Lv ->
            "Piltuves diagramma"

        Nb ->
            "Traktdiagram"

        Pl ->
            "Wykres lejkowy"

        Pt ->
            "Gráfico de funil"

        Ro ->
            "Diagramă pâlnie"

        Sk ->
            "Lievikový graf"

        Sl ->
            "Lijakasti grafikon"

        Sq ->
            "Diagram hinkë"

        Sv ->
            "Trattdiagram"

        Sw ->
            "Chati ya faneli"

        Tr ->
            "Huni grafiği"

        Tw ->
            "漏斗图"

        Ur ->
            "فنل چارٹ"

        Zh ->
            "漏斗图"

        _ ->
            "Funnel chart"


qrCode : Lang -> String
qrCode lang =
    case lang of
        Am ->
            "QR ኮድ ለድረ ገጽ"

        Ar ->
            "رمز الاستجابة السريعة للموقع"

        Bg ->
            "QR код за уебсайт"

        Bn ->
            "ওয়েবসাইটের জন্য QR কোড"

        Ca ->
            "Codi QR del lloc web"

        Cs ->
            "QR kód webové stránky"

        Da ->
            "QR-kode til webstedet"

        De ->
            "QR-Code für Webseite"

        El ->
            "Κωδικός QR για τον ιστότοπο"

        Es ->
            "Código QR para sitio web"

        Et ->
            "Veebisaidi QR-kood"

        Eu ->
            "Webgunearen QR kodea"

        Fa ->
            "کد QR برای وب سایت"

        Fi ->
            "Verkkosivuston QR-koodi"

        Fr ->
            "Code QR pour site web"

        Ga ->
            "Cód QR don suíomh gréasáin"

        Hi ->
            "वेबसाइट के लिए क्यूआर कोड"

        Hr ->
            "QR kod za web-stranicu"

        Hu ->
            "A weboldal QR-kódja"

        Hy ->
            "Վեբ կայքի QR կոդ"

        It ->
            "Codice QR del sito web"

        Ja ->
            "ウェブサイト用 QR コード"

        Ka ->
            "ვებგვერდისთვის QR კოდი"

        Ko ->
            "웹 사이트용 QR 코드"

        Lt ->
            "Svetainės QR kodas"

        Lv ->
            "Vietnes QR kods"

        Nb ->
            "QR-kode for nettstedet"

        Nl ->
            "QR-code voor website"

        Pa ->
            "ਵੈੱਬਸਾਈਟ ਲਈ ਕੁਆਰ ਕੋਡ"

        Pl ->
            "Kod QR strony internetowej"

        Pt ->
            "Código QR para site"

        Ro ->
            "Cod QR pentru site"

        Ru ->
            "QR-код для сайта"

        Sk ->
            "QR kód webovej stránky"

        Sl ->
            "Koda QR za spletno mesto"

        Sq ->
            "Kodi QR për faqen e internetit"

        Sv ->
            "QR-kod för webbplatsen"

        Sw ->
            "Msimbo wa QR wa tovuti"

        Tr ->
            "Web sitesi için QR kodu"

        Tw ->
            "网站二维码"

        Uk ->
            "QR -код для веб -сайту"

        Ur ->
            "ویب سائٹ کے لیے QR کوڈ"

        Zh ->
            "网站二维码"

        _ ->
            "QR code for website"


qrErr : Lang -> String
qrErr lang =
    case lang of
        Am ->
            "ስህተት ያለባቸው በ QR ኮድ ወይም ትክክል አልተመለከተም"

        Ar ->
            "خطأ أثناء الترميز إلى رمز الاستجابة السريعة"

        Bg ->
            "Грешка при кодирането към QR код"

        Bn ->
            "QR কোডে এনকোডিং সমস্যা হয়েছে"

        Ca ->
            "Error en generar el codi QR"

        Cs ->
            "Chyba při vytváření QR kódu"

        Da ->
            "Fejl ved oprettelse af QR-kode"

        De ->
            "Fehler beim Codieren in QR-Code"

        El ->
            "Σφάλμα κατά τη δημιουργία κωδικού QR"

        Es ->
            "Error al codificar en código QR"

        Et ->
            "Viga QR-koodi loomisel"

        Eu ->
            "Errorea QR kodea sortzean"

        Fa ->
            "خطا هنگام رمزگذاری روی کد QR"

        Fi ->
            "Virhe QR-koodin luonnissa"

        Fr ->
            "Erreur lors de l'encodage en code QR"

        Ga ->
            "Earráid agus cód QR á chruthú"

        Hi ->
            "क्यूआर कोड को एनकोड करने में त्रुटि"

        Hr ->
            "Pogreška pri izradi QR koda"

        Hu ->
            "Hiba a QR-kód létrehozásakor"

        Hy ->
            "Սխալ QR կոդի կոդավորման ժամանակ"

        It ->
            "Errore nel codificare come codice QR"

        Ja ->
            "QR コードのエンコード中にエラーが発生しました"

        Ka ->
            "შეცდომა QR კოდში კოდირებისას"

        Ko ->
            "QR 코드를 만드는 도중 오류가 발생했습니다."

        Lt ->
            "Klaida kuriant QR kodą"

        Lv ->
            "Kļūda, veidojot QR kodu"

        Nb ->
            "Feil ved oppretting av QR-kode"

        Nl ->
            "Fout bij het coderen naar QR-code"

        Pa ->
            "ਕੁਆਰ ਕੋਡ ਨੂੰ ਏਨਕੋਡ ਕਰਨ ਦੌਰਾਨ ਗਲਤੀ ਆਈ ਹੈ"

        Pl ->
            "Błąd podczas tworzenia kodu QR"

        Pt ->
            "Erro durante a codificação para o código QR"

        Ro ->
            "Eroare la generarea codului QR"

        Ru ->
            "Ошибка при кодировании в QR-код"

        Sk ->
            "Chyba pri vytváraní QR kódu"

        Sl ->
            "Napaka pri ustvarjanju kode QR"

        Sq ->
            "Gabim gjatë krijimit të kodit QR"

        Sv ->
            "Fel när QR-koden skapades"

        Sw ->
            "Hitilafu wakati wa kusimba msimbo wa QR"

        Tr ->
            "QR kodu oluşturulurken hata oluştu"

        Tw ->
            "编码为二维码时出错"

        Uk ->
            "Помилка під час кодування в QR -код"

        Ur ->
            "QR کوڈ میں انکوڈ کرتے وقت خرابی"

        Zh ->
            "编码为二维码时出错"

        _ ->
            "Error while encoding to QR code"


chatOpen : Lang -> String
chatOpen lang =
    case lang of
        Am ->
            "ቀዳሚ ማድረግ"

        Ar ->
            "فتح الدردشة"

        Bg ->
            "Отвори чат"

        Bn ->
            "চ্যাট খুলুন"

        Ca ->
            "Obre el xat"

        Cs ->
            "Otevřít chat"

        Da ->
            "Åbn chatten"

        De ->
            "Chat öffnen"

        El ->
            "Άνοιγμα συνομιλίας"

        Es ->
            "Abrir chat"

        Et ->
            "Ava vestlus"

        Eu ->
            "Ireki txata"

        Fa ->
            "باز کردن گفتگو"

        Fi ->
            "Avaa keskustelu"

        Fr ->
            "Ouvrir le chat"

        Ga ->
            "Oscail an comhrá"

        Hi ->
            "चैट खोलें"

        Hr ->
            "Otvori razgovor"

        Hu ->
            "Csevegés megnyitása"

        Hy ->
            "Բացել խոսակցություն"

        It ->
            "Aprire la chat"

        Ja ->
            "チャットを開く"

        Ka ->
            "ჩატი გახსნა"

        Ko ->
            "채팅 열기"

        Lt ->
            "Atverti pokalbį"

        Lv ->
            "Atvērt tērzēšanu"

        Nb ->
            "Åpne chatten"

        Nl ->
            "Chat openen"

        Pa ->
            "ਚੈਟ ਖੋਲ੍ਹੋ"

        Pl ->
            "Otwórz czat"

        Pt ->
            "Abrir chat"

        Ro ->
            "Deschide conversația"

        Ru ->
            "Открыть чат"

        Sk ->
            "Otvoriť čet"

        Sl ->
            "Odpri klepet"

        Sq ->
            "Hap bisedën"

        Sv ->
            "Öppna chatten"

        Sw ->
            "Fungua gumzo"

        Tr ->
            "Sohbeti aç"

        Tw ->
            "開啟聊天室"

        Uk ->
            "Відкрити чат"

        Ur ->
            "چیٹ کھولیں"

        Zh ->
            "打开聊天"

        _ ->
            "Open chat"


chatClose : Lang -> String
chatClose lang =
    case lang of
        Am ->
            "ዝጋት ያድርጉ"

        Ar ->
            "إغلاق الدردشة"

        Bg ->
            "Затвори чат"

        Bn ->
            "চ্যাট বন্ধ করুন"

        Ca ->
            "Tanca el xat"

        Cs ->
            "Zavřít chat"

        Da ->
            "Luk chatten"

        De ->
            "Chat schließen"

        El ->
            "Κλείσιμο συνομιλίας"

        Es ->
            "Cerrar chat"

        Et ->
            "Sulge vestlus"

        Eu ->
            "Itxi txata"

        Fa ->
            "بستن گفتگو"

        Fi ->
            "Sulje keskustelu"

        Fr ->
            "Fermer le chat"

        Ga ->
            "Dún an comhrá"

        Hi ->
            "चैट बंद करें"

        Hr ->
            "Zatvori razgovor"

        Hu ->
            "Csevegés bezárása"

        Hy ->
            "Փակել խոսակցություն"

        It ->
            "Chiudere la chat"

        Ja ->
            "チャットを閉じる"

        Ka ->
            "ჩატი დახურვა"

        Ko ->
            "채팅 닫기"

        Lt ->
            "Užverti pokalbį"

        Lv ->
            "Aizvērt tērzēšanu"

        Nb ->
            "Lukk chatten"

        Nl ->
            "Chat sluiten"

        Pa ->
            "ਚੈਟ ਬੰਦ ਕਰੋ"

        Pl ->
            "Zamknij czat"

        Pt ->
            "Fechar chat"

        Ro ->
            "Închide conversația"

        Ru ->
            "Закрыть чат"

        Sk ->
            "Zavrieť čet"

        Sl ->
            "Zapri klepet"

        Sq ->
            "Mbyll bisedën"

        Sv ->
            "Stäng chatten"

        Sw ->
            "Funga gumzo"

        Tr ->
            "Sohbeti kapat"

        Tw ->
            "關閉聊天室"

        Uk ->
            "Закрити чат"

        Ur ->
            "چیٹ بند کریں"

        Zh ->
            "关闭聊天"

        _ ->
            "Close chat"


chatNew : Lang -> String
chatNew lang =
    case lang of
        Am ->
            "የተከፈሉ የቀዳሚ መልዕክቶች አልተመለከተም"

        Ar ->
            "لديك رسائل دردشة غير مقروءة"

        Bg ->
            "Имате непрочетени чат съобщения"

        Bn ->
            "আপনার অপঠিত চ্যাট বার্তাগুলি আছে"

        Ca ->
            "Tens missatges de xat sense llegir"

        Cs ->
            "Máš nepřečtené zprávy v chatu"

        Da ->
            "Du har ulæste chatbeskeder"

        De ->
            "Du hast ungelesene Chat-Nachrichten"

        El ->
            "Έχεις μη αναγνωσμένα μηνύματα συνομιλίας"

        Es ->
            "Tienes mensajes de chat no leídos"

        Et ->
            "Sul on lugemata vestlussõnumeid"

        Eu ->
            "Irakurri gabeko txat-mezuak dituzu"

        Fa ->
            "شما پیام\u{200C}های چت خوانده نشده دارید"

        Fi ->
            "Sinulla on lukemattomia keskusteluviestejä"

        Fr ->
            "Vous avez des messages de chat non lus"

        Ga ->
            "Tá teachtaireachtaí comhrá neamhléite agat"

        Hi ->
            "आपके पास अपठित चैट संदेश हैं"

        Hr ->
            "Imaš nepročitane poruke u razgovoru"

        Hu ->
            "Olvasatlan csevegőüzeneteid vannak"

        Hy ->
            "Դուք ունեք չկարդացված խոսածքներ խոսակցության մեջ"

        It ->
            "Ci sono messaggi di chat non letti"

        Ja ->
            "未読のチャットメッセージがあります"

        Ka ->
            "გაქვთ არაკითხული ჩატის შეტყობინებები"

        Ko ->
            "읽지 않은 채팅 메시지가 있습니다"

        Lt ->
            "Turi neskaitytų pokalbio žinučių"

        Lv ->
            "Tev ir nelasīti tērzēšanas ziņojumi"

        Nb ->
            "Du har uleste chatmeldinger"

        Nl ->
            "Je hebt ongelezen chatberichten"

        Pa ->
            "ਤੁਸੀਂ ਨਾ-ਪੜ੍ਹੇ ਚੈਟ ਸੁਨੇਹੇ ਹਨ"

        Pl ->
            "Masz nieprzeczytane wiadomości na czacie"

        Pt ->
            "Você tem mensagens de chat não lidas"

        Ro ->
            "Ai mesaje necitite în conversație"

        Ru ->
            "У вас есть непрочитанные сообщения в чате"

        Sk ->
            "Máš neprečítané správy v čete"

        Sl ->
            "Imaš neprebrana sporočila v klepetu"

        Sq ->
            "Ke mesazhe të palexuara në bisedë"

        Sv ->
            "Du har olästa chattmeddelanden"

        Sw ->
            "Una ujumbe wa gumzo usio soma"

        Tr ->
            "Okunmamış sohbet mesajlarınız var"

        Tw ->
            "你有未讀的聊天訊息"

        Uk ->
            "У вас є непрочитані повідомлення в чаті"

        Ur ->
            "آپ کے پاس ان پڑھی چیٹ پیغامات ہیں"

        Zh ->
            "你有未读的聊天消息"

        _ ->
            "You have unread chat messages"


chatSend : Lang -> String
chatSend lang =
    case lang of
        Am ->
            "መልእክት ላክ"

        Ar ->
            "إرسال الرسالة"

        Bg ->
            "Изпрати съобщение"

        Bn ->
            "বার্তা পাঠান"

        Ca ->
            "Envia un missatge"

        Cs ->
            "Odeslat zprávu"

        Da ->
            "Send besked"

        De ->
            "Nachricht senden"

        El ->
            "Αποστολή μηνύματος"

        Es ->
            "Enviar mensaje"

        Et ->
            "Saada sõnum"

        Eu ->
            "Bidali mezua"

        Fa ->
            "ارسال پیام"

        Fi ->
            "Lähetä viesti"

        Fr ->
            "Envoyer le message"

        Ga ->
            "Seol teachtaireacht"

        Hi ->
            "संदेश भेजें"

        Hr ->
            "Pošalji poruku"

        Hu ->
            "Üzenet küldése"

        Hy ->
            "Ուղարկել նամակ"

        It ->
            "Invia messaggio"

        Ja ->
            "メッセージを送信する"

        Ka ->
            "შეტყობინების გაგზავნა"

        Ko ->
            "메시지 보내기"

        Lt ->
            "Siųsti žinutę"

        Lv ->
            "Sūtīt ziņojumu"

        Nb ->
            "Send melding"

        Nl ->
            "Bericht versturen"

        Pa ->
            "ਸੁਨੇਹਾ ਭੇਜੋ"

        Pl ->
            "Wyślij wiadomość"

        Pt ->
            "Enviar mensagem"

        Ro ->
            "Trimite mesajul"

        Ru ->
            "Отправить сообщение"

        Sk ->
            "Odoslať správu"

        Sl ->
            "Pošlji sporočilo"

        Sq ->
            "Dërgo mesazh"

        Sv ->
            "Skicka meddelande"

        Sw ->
            "Tuma ujumbe"

        Tr ->
            "Mesaj gönder"

        Tw ->
            "發送訊息"

        Uk ->
            "Надіслати повідомлення"

        Ur ->
            "پیغام بھیجیں"

        Zh ->
            "发送消息"

        _ ->
            "Send message"
