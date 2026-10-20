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

        Ar ->
            "الرئيسية"

        Bg ->
            "Начало"

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

        Es ->
            "Inicio"

        Et ->
            "Avaleht"

        Eu ->
            "Hasiera"

        Fa ->
            "خانه"

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

        Hy ->
            "Գլխավոր"

        It ->
            "Home"

        Ja ->
            "ホーム"

        Ka ->
            "მთავარი"

        Ko ->
            "홈"

        Lt ->
            "Pradžia"

        Lv ->
            "Sākums"

        Nb ->
            "Hjem"

        Nl ->
            "Start"

        Pa ->
            "ਮੁੱਖ ਪੰਨਾ"

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

        Tw ->
            "首頁"

        Uk ->
            "Головна"

        Ur ->
            "ہوم"

        Zh ->
            "首页"

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
            "siguiente"

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
            "下一个"

        _ ->
            "next"


basePrev : Lang -> String
basePrev lang =
    case lang of
        Am ->
            "ቀዳሚ"

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
            "上一个"

        _ ->
            "previous"


basePlay : Lang -> String
basePlay lang =
    case lang of
        Am ->
            "አጫውት"

        Ar ->
            "تشغيل"

        Bg ->
            "Възпроизвеждане"

        Bn ->
            "চালান"

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
            "reproducir"

        Et ->
            "esita"

        Eu ->
            "erreproduzitu"

        Fa ->
            "پخش"

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
            "նվագարկել"

        It ->
            "avvia"

        Ja ->
            "再生"

        Ka ->
            "დაკვრა"

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
            "воспроизвести"

        Sk ->
            "prehrať"

        Sl ->
            "predvajaj"

        Sq ->
            "luaj"

        Sv ->
            "spela upp"

        Sw ->
            "cheza"

        Tr ->
            "oynat"

        Tw ->
            "播放"

        Uk ->
            "відтворити"

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
            "አቁም"

        Ar ->
            "توقف"

        Bg ->
            "Спиране"

        Bn ->
            "থামান"

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
            "توقف"

        Fi ->
            "pysäytä"

        Fr ->
            "Arrêt"

        Ga ->
            "stop"

        Hi ->
            "रोकें"

        Hr ->
            "zaustavi"

        Hu ->
            "leállítás"

        Hy ->
            "կանգնեցնել"

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
            "остановить"

        Sk ->
            "zastaviť"

        Sl ->
            "ustavi"

        Sq ->
            "ndalo"

        Sv ->
            "stoppa"

        Sw ->
            "simamisha"

        Tr ->
            "durdur"

        Tw ->
            "停止"

        Uk ->
            "зупинити"

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
            "የፊደል መጠን: " ++ str0 ++ ""

        Ar ->
            "حجم الخط: " ++ str0 ++ ""

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
            "Տառաչափ՝ " ++ str0 ++ ""

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
            "ukubwa wa fonti: " ++ str0 ++ ""

        Tr ->
            "yazı tipi boyutu: " ++ str0 ++ ""

        Tw ->
            "字體大小： " ++ str0 ++ ""

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
            "መካከለኛ"

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
            "ya kati"

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
            "ትልቅ"

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
            "որոնել"

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
            "Zoeken"

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
            "搜索"

        _ ->
            "Search"


baseDelete : Lang -> String
baseDelete lang =
    case lang of
        Am ->
            "ፍለጋውን አጽዳ"

        Ar ->
            "إزالة البحث"

        Bg ->
            "Изчистване на търсенето"

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
            "մաքրել որոնումը"

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
            "Zoekopdracht wissen"

        Pa ->
            "ਖੋਜ ਹਟਾਓ"

        Pl ->
            "wyczyść wyszukiwanie"

        Pt ->
            "limpar busca"

        Ro ->
            "șterge căutarea"

        Ru ->
            "очистить поиск"

        Sk ->
            "vymazať vyhľadávanie"

        Sl ->
            "počisti iskanje"

        Sq ->
            "pastro kërkimin"

        Sv ->
            "rensa sökning"

        Sw ->
            "futa utafutaji"

        Tr ->
            "aramayı temizle"

        Tw ->
            "清除搜尋"

        Uk ->
            "видалити пошук"

        Ur ->
            "تلاش صاف کریں"

        Zh ->
            "清除搜索"

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
            "結果"

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
            "결과 1개"

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
            "tokeo moja"

        Tr ->
            "bir sonuç"

        Tw ->
            "一個結果"

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
            "ምንም ውጤት የለም"

        Ar ->
            "لا توجد نتائج"

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
            "沒有結果"

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
            "ማውጫ"

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
            "विषय सूची"

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
            "სარჩევი"

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
            "ਵਿਸ਼ਾ ਸੂਚੀ"

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
            "目录"

        _ ->
            "Table of Contents"


baseSkipNav : Lang -> String
baseSkipNav lang =
    case lang of
        Am ->
            "ዳሰሳን ዝለል"

        Ar ->
            "تخطي التنقل"

        Bg ->
            "Пропусни навигацията"

        Bn ->
            "নেভিগেশন এড়িয়ে যান"

        Ca ->
            "Salta la navegació"

        Cs ->
            "Přeskočit navigaci"

        Da ->
            "Spring navigation over"

        De ->
            "Navigation überspringen"

        El ->
            "Παράλειψη πλοήγησης"

        Es ->
            "Saltar navegación"

        Et ->
            "Jäta navigeerimine vahele"

        Eu ->
            "Saltatu nabigazioa"

        Fa ->
            "رد شدن از پیمایش"

        Fi ->
            "Ohita navigointi"

        Fr ->
            "Passer la navigation"

        Ga ->
            "Léim thar an nascleanúint"

        Hi ->
            "नेविगेशन छोड़ें"

        Hr ->
            "Preskoči navigaciju"

        Hu ->
            "Navigáció átugrása"

        Hy ->
            "Բաց թողնել նավիգացիան"

        It ->
            "Salta la navigazione"

        Ja ->
            "ナビゲーションをスキップ"

        Ka ->
            "ნავიგაციის გამოტოვება"

        Ko ->
            "탐색 건너뛰기"

        Lt ->
            "Praleisti naršymą"

        Lv ->
            "Izlaist navigāciju"

        Nb ->
            "Hopp over navigasjonen"

        Nl ->
            "Navigatie overslaan"

        Pa ->
            "ਨੈਵੀਗੇਸ਼ਨ ਛੱਡੋ"

        Pl ->
            "Pomiń nawigację"

        Pt ->
            "Pular navegação"

        Ro ->
            "Sari peste navigare"

        Ru ->
            "Пропустить навигацию"

        Sk ->
            "Preskočiť navigáciu"

        Sl ->
            "Preskoči navigacijo"

        Sq ->
            "Kapërce navigimin"

        Sv ->
            "Hoppa över navigeringen"

        Sw ->
            "Ruka urambazaji"

        Tr ->
            "Gezintiyi atla"

        Tw ->
            "跳過導覽"

        Uk ->
            "Пропустити навігацію"

        Ur ->
            "نیویگیشن چھوڑیں"

        Zh ->
            "跳过导航"

        _ ->
            "Skip navigation"


baseCloseDialog : Lang -> String
baseCloseDialog lang =
    case lang of
        Am ->
            "የንግግር ሳጥን ዝጋ"

        Ar ->
            "إغلاق مربع الحوار"

        Bg ->
            "Затвори диалога"

        Bn ->
            "ডায়ালগ বন্ধ করুন"

        Ca ->
            "Tanca el diàleg"

        Cs ->
            "Zavřít dialog"

        Da ->
            "Luk dialogboks"

        De ->
            "Dialog schließen"

        El ->
            "Κλείσιμο διαλόγου"

        Es ->
            "Cerrar diálogo"

        Et ->
            "Sulge dialoog"

        Eu ->
            "Itxi elkarrizketa-koadroa"

        Fa ->
            "بستن کادر محاوره"

        Fi ->
            "Sulje valintaikkuna"

        Fr ->
            "Fermer la boîte de dialogue"

        Ga ->
            "Dún an bosca dialóige"

        Hi ->
            "डायलॉग बंद करें"

        Hr ->
            "Zatvori dijalog"

        Hu ->
            "Párbeszédablak bezárása"

        Hy ->
            "Փակել երկխոսության պատուհանը"

        It ->
            "Chiudi la finestra di dialogo"

        Ja ->
            "ダイアログを閉じる"

        Ka ->
            "დიალოგის დახურვა"

        Ko ->
            "대화 상자 닫기"

        Lt ->
            "Užverti dialogo langą"

        Lv ->
            "Aizvērt dialoglodziņu"

        Nb ->
            "Lukk dialogen"

        Nl ->
            "Dialoogvenster sluiten"

        Pa ->
            "ਡਾਇਲਾਗ ਬੰਦ ਕਰੋ"

        Pl ->
            "Zamknij okno dialogowe"

        Pt ->
            "Fechar diálogo"

        Ro ->
            "Închide dialogul"

        Ru ->
            "Закрыть диалог"

        Sk ->
            "Zavrieť dialóg"

        Sl ->
            "Zapri pogovorno okno"

        Sq ->
            "Mbyll dialogun"

        Sv ->
            "Stäng dialogrutan"

        Sw ->
            "Funga kidirisha"

        Tr ->
            "İletişim kutusunu kapat"

        Tw ->
            "關閉對話方塊"

        Uk ->
            "Закрити діалог"

        Ur ->
            "ڈائیلاگ بند کریں"

        Zh ->
            "关闭对话框"

        _ ->
            "Close dialog"


baseNewTab : Lang -> String
baseNewTab lang =
    case lang of
        Am ->
            "በአዲስ ትር ውስጥ ይከፈታል"

        Ar ->
            "يفتح في علامة تبويب جديدة"

        Bg ->
            "отваря се в нов раздел"

        Bn ->
            "নতুন ট্যাবে খোলে"

        Ca ->
            "s'obre en una pestanya nova"

        Cs ->
            "otevře se na nové kartě"

        Da ->
            "åbner i en ny fane"

        De ->
            "öffnet in neuem Tab"

        El ->
            "ανοίγει σε νέα καρτέλα"

        Es ->
            "se abre en una pestaña nueva"

        Et ->
            "avaneb uuel vahekaardil"

        Eu ->
            "fitxa berri batean irekitzen da"

        Fa ->
            "در زبانه جدید باز می‌شود"

        Fi ->
            "avautuu uudelle välilehdelle"

        Fr ->
            "s'ouvre dans un nouvel onglet"

        Ga ->
            "osclaítear i gcluaisín nua é"

        Hi ->
            "नए टैब में खुलता है"

        Hr ->
            "otvara se u novoj kartici"

        Hu ->
            "új lapon nyílik meg"

        Hy ->
            "բացվում է նոր ներդիրում"

        It ->
            "si apre in una nuova scheda"

        Ja ->
            "新しいタブで開きます"

        Ka ->
            "იხსნება ახალ ჩანართში"

        Ko ->
            "새 탭에서 열림"

        Lt ->
            "atsidaro naujame skirtuke"

        Lv ->
            "atveras jaunā cilnē"

        Nb ->
            "åpnes i en ny fane"

        Nl ->
            "opent in een nieuw tabblad"

        Pa ->
            "ਨਵੀਂ ਟੈਬ ਵਿੱਚ ਖੁੱਲ੍ਹਦਾ ਹੈ"

        Pl ->
            "otwiera się w nowej karcie"

        Pt ->
            "abre em uma nova aba"

        Ro ->
            "se deschide într-o filă nouă"

        Ru ->
            "открывается в новой вкладке"

        Sk ->
            "otvorí sa na novej karte"

        Sl ->
            "odpre se v novem zavihku"

        Sq ->
            "hapet në një skedë të re"

        Sv ->
            "öppnas i en ny flik"

        Sw ->
            "hufunguka kwenye kichupo kipya"

        Tr ->
            "yeni sekmede açılır"

        Tw ->
            "在新分頁中開啟"

        Uk ->
            "відкривається в новій вкладці"

        Ur ->
            "نئے ٹیب میں کھلتا ہے"

        Zh ->
            "在新标签页中打开"

        _ ->
            "opens in a new tab"


baseZoom : Lang -> String
baseZoom lang =
    case lang of
        Am ->
            "አስፋ"

        Ar ->
            "تكبير"

        Bg ->
            "Увеличи"

        Bn ->
            "বড় করুন"

        Ca ->
            "Amplia"

        Cs ->
            "Zvětšit"

        Da ->
            "Forstør"

        De ->
            "Vergrößern"

        El ->
            "Μεγέθυνση"

        Es ->
            "Ampliar"

        Et ->
            "Suurenda"

        Eu ->
            "Handitu"

        Fa ->
            "بزرگ‌نمایی"

        Fi ->
            "Suurenna"

        Fr ->
            "Agrandir"

        Ga ->
            "Méadaigh"

        Hi ->
            "बड़ा करें"

        Hr ->
            "Povećaj"

        Hu ->
            "Nagyítás"

        Hy ->
            "Մեծացնել"

        It ->
            "Ingrandisci"

        Ja ->
            "拡大"

        Ka ->
            "გადიდება"

        Ko ->
            "확대"

        Lt ->
            "Padidinti"

        Lv ->
            "Palielināt"

        Nb ->
            "Forstørr"

        Nl ->
            "Vergroten"

        Pa ->
            "ਵੱਡਾ ਕਰੋ"

        Pl ->
            "Powiększ"

        Pt ->
            "Ampliar"

        Ro ->
            "Mărește"

        Ru ->
            "Увеличить"

        Sk ->
            "Zväčšiť"

        Sl ->
            "Povečaj"

        Sq ->
            "Zmadho"

        Sv ->
            "Förstora"

        Sw ->
            "Kuza"

        Tr ->
            "Büyüt"

        Tw ->
            "放大"

        Uk ->
            "Збільшити"

        Ur ->
            "بڑا کریں"

        Zh ->
            "放大"

        _ ->
            "Enlarge"


baseSlide : Lang -> String
baseSlide lang =
    case lang of
        Am ->
            "ስላይድ"

        Ar ->
            "شريحة"

        Bg ->
            "Слайд"

        Bn ->
            "স্লাইড"

        Ca ->
            "Diapositiva"

        Cs ->
            "Snímek"

        Da ->
            "Dias"

        De ->
            "Folie"

        El ->
            "Διαφάνεια"

        Es ->
            "Diapositiva"

        Et ->
            "Slaid"

        Eu ->
            "Diapositiba"

        Fa ->
            "اسلاید"

        Fi ->
            "Dia"

        Fr ->
            "Diapositive"

        Ga ->
            "Sleamhnán"

        Hi ->
            "स्लाइड"

        Hr ->
            "Slajd"

        Hu ->
            "Dia"

        Hy ->
            "Սլայդ"

        It ->
            "Diapositiva"

        Ja ->
            "スライド"

        Ka ->
            "სლაიდი"

        Ko ->
            "슬라이드"

        Lt ->
            "Skaidrė"

        Lv ->
            "Slaids"

        Nb ->
            "Lysbilde"

        Nl ->
            "Dia"

        Pa ->
            "ਸਲਾਈਡ"

        Pl ->
            "Slajd"

        Pt ->
            "Slide"

        Ro ->
            "Diapozitiv"

        Ru ->
            "Слайд"

        Sk ->
            "Snímka"

        Sl ->
            "Prosojnica"

        Sq ->
            "Diapozitivi"

        Sv ->
            "Bild"

        Sw ->
            "Slaidi"

        Tr ->
            "Slayt"

        Tw ->
            "投影片"

        Uk ->
            "Слайд"

        Ur ->
            "سلائیڈ"

        Zh ->
            "幻灯片"

        _ ->
            "Slide"


baseStep : Lang -> String
baseStep lang =
    case lang of
        Am ->
            "ደረጃ"

        Ar ->
            "خطوة"

        Bg ->
            "Стъпка"

        Bn ->
            "ধাপ"

        Ca ->
            "Pas"

        Cs ->
            "Krok"

        Da ->
            "Trin"

        De ->
            "Schritt"

        El ->
            "Βήμα"

        Es ->
            "Paso"

        Et ->
            "Samm"

        Eu ->
            "Urratsa"

        Fa ->
            "مرحله"

        Fi ->
            "Vaihe"

        Fr ->
            "Étape"

        Ga ->
            "Céim"

        Hi ->
            "चरण"

        Hr ->
            "Korak"

        Hu ->
            "Lépés"

        Hy ->
            "Քայլ"

        It ->
            "Passo"

        Ja ->
            "ステップ"

        Ka ->
            "ნაბიჯი"

        Ko ->
            "단계"

        Lt ->
            "Žingsnis"

        Lv ->
            "Solis"

        Nb ->
            "Trinn"

        Nl ->
            "Stap"

        Pa ->
            "ਕਦਮ"

        Pl ->
            "Krok"

        Pt ->
            "Passo"

        Ro ->
            "Pas"

        Ru ->
            "Шаг"

        Sk ->
            "Krok"

        Sl ->
            "Korak"

        Sq ->
            "Hapi"

        Sv ->
            "Steg"

        Sw ->
            "Hatua"

        Tr ->
            "Adım"

        Tw ->
            "步驟"

        Uk ->
            "Крок"

        Ur ->
            "مرحلہ"

        Zh ->
            "步骤"

        _ ->
            "Step"


baseSlideNavigation : Lang -> String
baseSlideNavigation lang =
    case lang of
        Am ->
            "የስላይድ ዳሰሳ"

        Ar ->
            "التنقل بين الشرائح"

        Bg ->
            "Навигация по слайдовете"

        Bn ->
            "স্লাইড নেভিগেশন"

        Ca ->
            "Navegació per les diapositives"

        Cs ->
            "Navigace mezi snímky"

        Da ->
            "Diasnavigation"

        De ->
            "Folien-Navigation"

        El ->
            "Πλοήγηση διαφανειών"

        Es ->
            "Navegación de diapositivas"

        Et ->
            "Slaidide navigeerimine"

        Eu ->
            "Diapositiben nabigazioa"

        Fa ->
            "پیمایش اسلایدها"

        Fi ->
            "Dianavigointi"

        Fr ->
            "Navigation entre les diapositives"

        Ga ->
            "Nascleanúint sleamhnán"

        Hi ->
            "स्लाइड नेविगेशन"

        Hr ->
            "Navigacija slajdova"

        Hu ->
            "Dianavigáció"

        Hy ->
            "Սլայդների նավիգացիա"

        It ->
            "Navigazione diapositive"

        Ja ->
            "スライドナビゲーション"

        Ka ->
            "სლაიდების ნავიგაცია"

        Ko ->
            "슬라이드 탐색"

        Lt ->
            "Skaidrių naršymas"

        Lv ->
            "Slaidu navigācija"

        Nb ->
            "Lysbildenavigasjon"

        Nl ->
            "Dianavigatie"

        Pa ->
            "ਸਲਾਈਡ ਨੈਵੀਗੇਸ਼ਨ"

        Pl ->
            "Nawigacja slajdów"

        Pt ->
            "Navegação dos slides"

        Ro ->
            "Navigare între diapozitive"

        Ru ->
            "Навигация по слайдам"

        Sk ->
            "Navigácia snímok"

        Sl ->
            "Navigacija po prosojnicah"

        Sq ->
            "Navigimi i diapozitivave"

        Sv ->
            "Bildnavigering"

        Sw ->
            "Urambazaji wa slaidi"

        Tr ->
            "Slayt gezintisi"

        Tw ->
            "投影片導覽"

        Uk ->
            "Навігація слайдами"

        Ur ->
            "سلائیڈ نیویگیشن"

        Zh ->
            "幻灯片导航"

        _ ->
            "Slide navigation"


baseFootnote : Lang -> String
baseFootnote lang =
    case lang of
        Am ->
            "የግርጌ ማስታወሻ"

        Ar ->
            "حاشية"

        Bg ->
            "Бележка под линия"

        Bn ->
            "পাদটীকা"

        Ca ->
            "Nota al peu"

        Cs ->
            "Poznámka pod čarou"

        Da ->
            "Fodnote"

        De ->
            "Fußnote"

        El ->
            "Υποσημείωση"

        Es ->
            "Nota al pie"

        Et ->
            "Joonealune märkus"

        Eu ->
            "Oin-oharra"

        Fa ->
            "پانویس"

        Fi ->
            "Alaviite"

        Fr ->
            "Note de bas de page"

        Ga ->
            "Fonóta"

        Hi ->
            "फ़ुटनोट"

        Hr ->
            "Fusnota"

        Hu ->
            "Lábjegyzet"

        Hy ->
            "Ծանոթագրություն"

        It ->
            "Nota"

        Ja ->
            "脚注"

        Ka ->
            "სქოლიო"

        Ko ->
            "각주"

        Lt ->
            "Išnaša"

        Lv ->
            "Vēre"

        Nb ->
            "Fotnote"

        Nl ->
            "Voetnoot"

        Pa ->
            "ਫੁਟਨੋਟ"

        Pl ->
            "Przypis"

        Pt ->
            "Nota de rodapé"

        Ro ->
            "Notă de subsol"

        Ru ->
            "Сноска"

        Sk ->
            "Poznámka pod čiarou"

        Sl ->
            "Opomba"

        Sq ->
            "Shënim në fund të faqes"

        Sv ->
            "Fotnot"

        Sw ->
            "Tanbihi"

        Tr ->
            "Dipnot"

        Tw ->
            "註腳"

        Uk ->
            "Виноска"

        Ur ->
            "حاشیہ"

        Zh ->
            "脚注"

        _ ->
            "Footnote"


baseFootnotes : Lang -> String
baseFootnotes lang =
    case lang of
        Am ->
            "የግርጌ ማስታወሻዎች"

        Ar ->
            "الحواشي"

        Bg ->
            "Бележки под линия"

        Bn ->
            "পাদটীকাসমূহ"

        Ca ->
            "Notes al peu"

        Cs ->
            "Poznámky pod čarou"

        Da ->
            "Fodnoter"

        De ->
            "Fußnoten"

        El ->
            "Υποσημειώσεις"

        Es ->
            "Notas al pie"

        Et ->
            "Joonealused märkused"

        Eu ->
            "Oin-oharrak"

        Fa ->
            "پانویس‌ها"

        Fi ->
            "Alaviitteet"

        Fr ->
            "Notes de bas de page"

        Ga ->
            "Fonótaí"

        Hi ->
            "फ़ुटनोट्स"

        Hr ->
            "Fusnote"

        Hu ->
            "Lábjegyzetek"

        Hy ->
            "Ծանոթագրություններ"

        It ->
            "Note"

        Ja ->
            "脚注一覧"

        Ka ->
            "სქოლიოები"

        Ko ->
            "각주"

        Lt ->
            "Išnašos"

        Lv ->
            "Vēres"

        Nb ->
            "Fotnoter"

        Nl ->
            "Voetnoten"

        Pa ->
            "ਫੁਟਨੋਟ"

        Pl ->
            "Przypisy"

        Pt ->
            "Notas de rodapé"

        Ro ->
            "Note de subsol"

        Ru ->
            "Сноски"

        Sk ->
            "Poznámky pod čiarou"

        Sl ->
            "Opombe"

        Sq ->
            "Shënimet në fund të faqes"

        Sv ->
            "Fotnoter"

        Sw ->
            "Tanbihi"

        Tr ->
            "Dipnotlar"

        Tw ->
            "註腳"

        Uk ->
            "Виноски"

        Ur ->
            "حواشی"

        Zh ->
            "脚注"

        _ ->
            "Footnotes"


baseResize : Lang -> String
baseResize lang =
    case lang of
        Am ->
            "የክፍሎችን መጠን ቀይር"

        Ar ->
            "تغيير حجم الأجزاء"

        Bg ->
            "Преоразмеряване на панелите"

        Bn ->
            "প্যানেলের আকার পরিবর্তন করুন"

        Ca ->
            "Redimensiona els panells"

        Cs ->
            "Změnit velikost panelů"

        Da ->
            "Tilpas panelernes størrelse"

        De ->
            "Größe der Bereiche ändern"

        El ->
            "Αλλαγή μεγέθους περιοχών"

        Es ->
            "Cambiar el tamaño de los paneles"

        Et ->
            "Muuda paanide suurust"

        Eu ->
            "Aldatu panelen tamaina"

        Fa ->
            "تغییر اندازهٔ بخش‌ها"

        Fi ->
            "Muuta ruutujen kokoa"

        Fr ->
            "Redimensionner les volets"

        Ga ->
            "Athraigh méid na bpainéal"

        Hi ->
            "पैनल का आकार बदलें"

        Hr ->
            "Promijeni veličinu okna"

        Hu ->
            "Panelek átméretezése"

        Hy ->
            "Փոխել վահանակների չափը"

        It ->
            "Ridimensiona i riquadri"

        Ja ->
            "パネルのサイズを変更"

        Ka ->
            "არეების ზომის შეცვლა"

        Ko ->
            "영역 크기 조절"

        Lt ->
            "Keisti sričių dydį"

        Lv ->
            "Mainīt apgabalu izmēru"

        Nb ->
            "Endre størrelse på panelene"

        Nl ->
            "Grootte van deelvensters wijzigen"

        Pa ->
            "ਭਾਗਾਂ ਦਾ ਆਕਾਰ ਬਦਲੋ"

        Pl ->
            "Zmień rozmiar paneli"

        Pt ->
            "Redimensionar painéis"

        Ro ->
            "Redimensionează panourile"

        Ru ->
            "Изменить размер панелей"

        Sk ->
            "Zmeniť veľkosť panelov"

        Sl ->
            "Spremeni velikost podoken"

        Sq ->
            "Ndrysho madhësinë e paneleve"

        Sv ->
            "Ändra storlek på panelerna"

        Sw ->
            "Badilisha ukubwa wa vidirisha"

        Tr ->
            "Bölmeleri yeniden boyutlandır"

        Tw ->
            "調整窗格大小"

        Uk ->
            "Змінити розмір панелей"

        Ur ->
            "پینلز کا سائز تبدیل کریں"

        Zh ->
            "调整窗格大小"

        _ ->
            "Resize panes"


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
            "ჩვენება"

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
            "ਦਿਖਾਓ"

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
            "onyesha"

        Tr ->
            "göster"

        Tw ->
            "顯示"

        Uk ->
            "показати"

        Ur ->
            "دکھائیں"

        Zh ->
            "显示"

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
            "დამალვა"

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
            "ਛੁਪਾਓ"

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
            "ficha"

        Tr ->
            "gizle"

        Tw ->
            "隱藏"

        Uk ->
            "приховати"

        Ur ->
            "چھپائیں"

        Zh ->
            "隐藏"

        _ ->
            "hide"


baseEditor : Lang -> String
baseEditor lang =
    case lang of
        Am ->
            "የአርታኢ ዘይቤ"

        Ar ->
            "نمط المحرر"

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
            "Խմբագրիչի ոճ"

        It ->
            "stile editor"

        Ja ->
            "エディター・スタイル"

        Ka ->
            "რედაქტორის სტილი"

        Ko ->
            "편집기 스타일"

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
            "Mtindo wa Kihariri"

        Tr ->
            "Düzenleyici stili"

        Tw ->
            "編輯器樣式"

        Uk ->
            "стиль редактора"

        Ur ->
            "ایڈیٹر اسٹائل"

        Zh ->
            "编辑器样式"

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
            "বাংলা"

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
            "हिन्दी"

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
            "ქართული"

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
            "Kiswahili"

        Tr ->
            "Türkçe"

        Tw ->
            "繁體中文"

        Uk ->
            "Українська"

        Ur ->
            "اردو"

        Zh ->
            "简体中文"

        _ ->
            "English"


commentRate : Lang -> String
commentRate lang =
    case lang of
        Am ->
            "የማጫወቻ ፍጥነት አስተካክል"

        Ar ->
            "تعديل سرعة التشغيل"

        Bg ->
            "Промяна на скоростта на възпроизвеждане"

        Bn ->
            "প্লেব্যাকের গতি সামঞ্জস্য করুন"

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
            "Կարգավորել նվագարկման արագությունը"

        It ->
            "Regola la velocità di riproduzione"

        Ja ->
            "再生速度を変更"

        Ka ->
            "დაკვრის სიჩქარის რეგულირება"

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
            "調整播放速度"

        Uk ->
            "налаштування швидкості відтворення"

        Ur ->
            "پلے بیک کی رفتار ایڈجسٹ کریں"

        Zh ->
            "调整播放速度"

        _ ->
            "Adjust playback speed"


commentRateLabel : Lang -> String
commentRateLabel lang =
    case lang of
        Am ->
            "ፍጥነት"

        Ar ->
            "السرعة"

        Bg ->
            "Скорост"

        Bn ->
            "গতি"

        Ca ->
            "Velocitat"

        Cs ->
            "Rychlost"

        Da ->
            "Tempo"

        De ->
            "Tempo"

        El ->
            "Ταχύτητα"

        Es ->
            "Velocidad"

        Et ->
            "Kiirus"

        Eu ->
            "Abiadura"

        Fa ->
            "سرعت"

        Fi ->
            "Nopeus"

        Fr ->
            "Vitesse"

        Ga ->
            "Luas"

        Hi ->
            "गति"

        Hr ->
            "Brzina"

        Hu ->
            "Tempó"

        Hy ->
            "Արագություն"

        It ->
            "Velocità"

        Ja ->
            "速度"

        Ka ->
            "სიჩქარე"

        Ko ->
            "속도"

        Lt ->
            "Greitis"

        Lv ->
            "Ātrums"

        Nb ->
            "Tempo"

        Nl ->
            "Tempo"

        Pa ->
            "ਗਤੀ"

        Pl ->
            "Tempo"

        Pt ->
            "Ritmo"

        Ro ->
            "Viteză"

        Ru ->
            "Скорость"

        Sk ->
            "Rýchlosť"

        Sl ->
            "Hitrost"

        Sq ->
            "Ritmi"

        Sv ->
            "Tempo"

        Sw ->
            "Kasi"

        Tr ->
            "Hız"

        Tw ->
            "速度"

        Uk ->
            "Темп"

        Ur ->
            "رفتار"

        Zh ->
            "速度"

        _ ->
            "Speed"


commentPitch : Lang -> String
commentPitch lang =
    case lang of
        Am ->
            "የድምጽ ከፍታ አስተካክል"

        Ar ->
            "تعديل طبقة الصوت"

        Bg ->
            "Промяна на тон"

        Bn ->
            "স্বরের উচ্চতা সামঞ্জস্য করুন"

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
            "تنظیم زیر و بمی صدا"

        Fi ->
            "Säädä äänenkorkeutta"

        Fr ->
            "Ajuster la hauteur du son"

        Ga ->
            "Coigeartaigh tuinairde an ghutha"

        Hi ->
            "पिच सेट करें"

        Hr ->
            "Prilagodi visinu glasa"

        Hu ->
            "Hangmagasság beállítása"

        Hy ->
            "Կարգավորել ձայնի տոնը"

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
            "ਸੁਰ ਸੰਰਚਨਾ"

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
            "Badilisha kiwango cha sauti"

        Tr ->
            "Ses perdesini ayarla"

        Tw ->
            "調整音高"

        Uk ->
            "налаштування висоти тону"

        Ur ->
            "آواز کی پچ ایڈجسٹ کریں"

        Zh ->
            "调整音高"

        _ ->
            "Adjust pitch"


commentPitchLabel : Lang -> String
commentPitchLabel lang =
    case lang of
        Am ->
            "ከፍታ"

        Ar ->
            "الطبقة"

        Bg ->
            "Тон"

        Bn ->
            "স্বর"

        Ca ->
            "To"

        Cs ->
            "Výška"

        Da ->
            "Tonehøjde"

        De ->
            "Tonhöhe"

        El ->
            "Τόνος"

        Es ->
            "Tono"

        Et ->
            "Kõrgus"

        Eu ->
            "Tonua"

        Fa ->
            "زیر و بمی"

        Fi ->
            "Korkeus"

        Fr ->
            "Hauteur"

        Ga ->
            "Tuinairde"

        Hi ->
            "पिच"

        Hr ->
            "Visina"

        Hu ->
            "Magasság"

        Hy ->
            "Տոն"

        It ->
            "Tono"

        Ja ->
            "音程"

        Ka ->
            "ტონი"

        Ko ->
            "음높이"

        Lt ->
            "Aukštis"

        Lv ->
            "Augstums"

        Nb ->
            "Tone"

        Nl ->
            "Toon"

        Pa ->
            "ਸੁਰ"

        Pl ->
            "Wysokość"

        Pt ->
            "Tom"

        Ro ->
            "Ton"

        Ru ->
            "Тон"

        Sk ->
            "Výška"

        Sl ->
            "Višina"

        Sq ->
            "Toni"

        Sv ->
            "Tonhöjd"

        Sw ->
            "Kiwango"

        Tr ->
            "Perde"

        Tw ->
            "音高"

        Uk ->
            "Тон"

        Ur ->
            "پچ"

        Zh ->
            "音高"

        _ ->
            "Pitch"


commentHide : Lang -> String
commentHide lang =
    case lang of
        Am ->
            "የቪዲዮ እና የአቫታር አስተያየቶችን ደብቅ"

        Ar ->
            "إخفاء تعليقات الفيديو والصورة الرمزية"

        Bg ->
            "Скриване на коментарите с видео и аватар"

        Bn ->
            "ভিডিও ও অবতার মন্তব্য লুকান"

        Ca ->
            "Amaga els comentaris de vídeo i d'avatar"

        Cs ->
            "Skrýt komentáře videa a avatara"

        Da ->
            "Skjul video- og avatarkommentarer"

        De ->
            "Video- & Avatar-Kommentare ausblenden"

        El ->
            "Απόκρυψη σχολίων βίντεο και άβαταρ"

        Es ->
            "Ocultar los comentarios de video y avatar"

        Et ->
            "Peida video- ja avatarikommentaarid"

        Eu ->
            "Ezkutatu bideo- eta avatar-iruzkinak"

        Fa ->
            "پنهان کردن توضیحات ویدیو و آواتار"

        Fi ->
            "Piilota video- ja avatarikommentit"

        Fr ->
            "Masquer les commentaires vidéo et avatar"

        Ga ->
            "Folaigh nótaí tráchta físe agus abhatáir"

        Hi ->
            "वीडियो और अवतार टिप्पणियाँ छुपाएं"

        Hr ->
            "Sakrij komentare videa i avatara"

        Hu ->
            "Videós és avatar-megjegyzések elrejtése"

        Hy ->
            "Թաքցնել տեսանյութի և ավատարի մեկնաբանությունները"

        It ->
            "Nascondi i commenti video e avatar"

        Ja ->
            "動画とアバターのコメントを非表示にする"

        Ka ->
            "ვიდეოსა და ავატარის კომენტარების დამალვა"

        Ko ->
            "비디오 및 아바타 해설 숨기기"

        Lt ->
            "Slėpti vaizdo ir avataro komentarus"

        Lv ->
            "Paslēpt video un avatāra komentārus"

        Nb ->
            "Skjul video- og avatarkommentarer"

        Nl ->
            "Video- en avatarcommentaar verbergen"

        Pa ->
            "ਵੀਡੀਓ ਅਤੇ ਅਵਤਾਰ ਟਿੱਪਣੀਆਂ ਛੁਪਾਓ"

        Pl ->
            "Ukryj komentarze wideo i awatara"

        Pt ->
            "Ocultar comentários de vídeo e avatar"

        Ro ->
            "Ascunde comentariile video și de avatar"

        Ru ->
            "Скрыть комментарии видео и аватара"

        Sk ->
            "Skryť komentáre videa a avatara"

        Sl ->
            "Skrij komentarje videa in avatarja"

        Sq ->
            "Fshih komentet me video dhe avatar"

        Sv ->
            "Dölj video- och avatarkommentarer"

        Sw ->
            "Ficha maoni ya video na avatar"

        Tr ->
            "Video ve avatar yorumlarını gizle"

        Tw ->
            "隱藏影片與虛擬形象評論"

        Uk ->
            "Приховати коментарі до відео та аватара"

        Ur ->
            "ویڈیو اور اوتار تبصرے چھپائیں"

        Zh ->
            "隐藏视频和虚拟形象讲解"

        _ ->
            "Hide video & avatar comments"


commentSidebar : Lang -> String
commentSidebar lang =
    case lang of
        Am ->
            "አስተያየቶች"

        Ar ->
            "التعليقات"

        Bg ->
            "Коментари"

        Bn ->
            "মন্তব্য"

        Ca ->
            "Comentaris"

        Cs ->
            "Komentáře"

        Da ->
            "Kommentarer"

        De ->
            "Kommentare"

        El ->
            "Σχόλια"

        Es ->
            "Comentarios"

        Et ->
            "Kommentaarid"

        Eu ->
            "Iruzkinak"

        Fa ->
            "توضیحات"

        Fi ->
            "Kommentit"

        Fr ->
            "Commentaires"

        Ga ->
            "Nótaí tráchta"

        Hi ->
            "टिप्पणियाँ"

        Hr ->
            "Komentari"

        Hu ->
            "Megjegyzések"

        Hy ->
            "Մեկնաբանություններ"

        It ->
            "Commenti"

        Ja ->
            "コメント"

        Ka ->
            "კომენტარები"

        Ko ->
            "해설"

        Lt ->
            "Komentarai"

        Lv ->
            "Komentāri"

        Nb ->
            "Kommentarer"

        Nl ->
            "Commentaar"

        Pa ->
            "ਟਿੱਪਣੀਆਂ"

        Pl ->
            "Komentarze"

        Pt ->
            "Comentários"

        Ro ->
            "Comentarii"

        Ru ->
            "Комментарии"

        Sk ->
            "Komentáre"

        Sl ->
            "Komentarji"

        Sq ->
            "Komentet"

        Sv ->
            "Kommentarer"

        Sw ->
            "Maoni"

        Tr ->
            "Yorumlar"

        Tw ->
            "評論"

        Uk ->
            "Коментарі"

        Ur ->
            "تبصرے"

        Zh ->
            "讲解"

        _ ->
            "Comments"


no_translation : Lang -> String
no_translation lang =
    case lang of
        Am ->
            "እስካሁን ምንም ትርጉም የለም"

        Ar ->
            "لا توجد ترجمة حتى الآن"

        Bg ->
            "Все още няма превод"

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
            "هنوز ترجمه‌ای وجود ندارد"

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
            "Թարգմանություն դեռ չկա"

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
            "nog geen vertaling beschikbaar"

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
            "尚未翻译"

        _ ->
            "no translation yet"


translateWithGoogle : Lang -> String
translateWithGoogle lang =
    case lang of
        Am ->
            "በGoogle ተርጉም (የሙከራ)"

        Ar ->
            "ترجمة من جوجل (تجريبي)"

        Bg ->
            "Превод с Google (експериментално)"

        Bn ->
            "Google দিয়ে অনুবাদ করুন (পরীক্ষামূলক)"

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
            "Թարգմանել Google-ի միջոցով (փորձնական)"

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
            "ਗੂਗਲ ਨਾਲ ਅਨੁਵਾਦ ਕਰੋ (ਪ੍ਰਯੋਗਾਤਮਕ)"

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
            "使用 Google 翻譯（實驗性）"

        Uk ->
            "Перекласти за допомогою Google (експериментально)"

        Ur ->
            "گوگل کے ساتھ ترجمہ کریں (تجرباتی)"

        Zh ->
            "使用 Google 翻译（实验性）"

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
            "颜色"

        _ ->
            "Color"


cSchema : Lang -> String
cSchema lang =
    case lang of
        Am ->
            "የቀለም ገጽታ"

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
            "Գունային սխեմա"

        It ->
            "Schema di colori"

        Ja ->
            "カラースキーム"

        Ka ->
            "ფერთა სქემა"

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
            "ጨለማ ሁነታ"

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
            "Մուգ ռեժիմ"

        It ->
            "modalità scura"

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
            "深色模式"

        _ ->
            "Dark-Mode"


cBright : Lang -> String
cBright lang =
    case lang of
        Am ->
            "ብሩህ ሁነታ"

        Ar ->
            "الوضع الفاتح"

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
            "Բաց ռեժիմ"

        It ->
            "modalità chiara"

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
            "ਲਾਈਟ ਮੋਡ"

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
            "Hali ya Mwanga"

        Tr ->
            "Açık mod"

        Tw ->
            "亮模式"

        Uk ->
            "світлий режим"

        Ur ->
            "روشن موڈ"

        Zh ->
            "浅色模式"

        _ ->
            "Light-Mode"


cDefault : Lang -> String
cDefault lang =
    case lang of
        Am ->
            "ነባሪ"

        Ar ->
            "الافتراضي"

        Bg ->
            "По подразбиране"

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
            "predeterminado"

        Et ->
            "Vaikimisi"

        Eu ->
            "Lehenetsia"

        Fa ->
            "پیش‌فرض"

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
            "по умолчанию"

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
            "默认"

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
            "蓝色"

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
            "Червено"

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
            "Nyekundu"

        Tr ->
            "Kırmızı"

        Tw ->
            "紅色"

        Uk ->
            "червоний"

        Ur ->
            "سرخ"

        Zh ->
            "红色"

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
            "Жълто"

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
            "زرد"

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
            "黃色"

        Uk ->
            "жовтий"

        Ur ->
            "پیلا"

        Zh ->
            "黄色"

        _ ->
            "Yellow"


cTurquoise : Lang -> String
cTurquoise lang =
    case lang of
        Am ->
            "ቱርኩዝ"

        Ar ->
            "فيروزي"

        Bg ->
            "Тюркоазено"

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
            "فیروزه‌ای"

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
            "ფირუზისფერი"

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
            "Feruzi"

        Tr ->
            "Turkuaz"

        Tw ->
            "綠松石色"

        Uk ->
            "бірюзовий"

        Ur ->
            "فیروزی"

        Zh ->
            "绿松石色"

        _ ->
            "Turquoise"


fullscreenEnter : Lang -> String
fullscreenEnter lang =
    case lang of
        Am ->
            "ወደ ሙሉ ማያ ገጽ ግባ"

        Ar ->
            "الدخول إلى وضع ملء الشاشة"

        Bg ->
            "Цял екран"

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
            "Անցնել լիաէկրան ռեժիմի"

        It ->
            "Entra a schermo intero"

        Ja ->
            "フルスクリーン表示"

        Ka ->
            "სრულ ეკრანზე გადასვლა"

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
            "進入全螢幕模式"

        Uk ->
            "увімкнути повноекранний режим"

        Ur ->
            "پوری سکرین"

        Zh ->
            "进入全屏模式"

        _ ->
            "Enter Fullscreen"


fullscreenExit : Lang -> String
fullscreenExit lang =
    case lang of
        Am ->
            "ከሙሉ ማያ ገጽ ውጣ"

        Ar ->
            "الخروج من وضع ملء الشاشة"

        Bg ->
            "Изход от цял екран"

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
            "Դուրս գալ լիաէկրան ռեժիմից"

        It ->
            "Esci da schermo intero"

        Ja ->
            "フルスクリーンを終了する"

        Ka ->
            "სრული ეკრანიდან გამოსვლა"

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
            "退出全螢幕模式"

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
            "የአቀራረብ ሁነታ"

        Ar ->
            "وضع العرض"

        Bg ->
            "Режим на презентация"

        Bn ->
            "প্রেজেন্টেশন মোড"

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
            "Esitlusrežiim"

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
            "Modalità presentazione"

        Ja ->
            "プレゼンテーションモード"

        Ka ->
            "პრეზენტაციის რეჟიმი"

        Ko ->
            "프레젠테이션 모드"

        Lt ->
            "Pristatymo režimas"

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
            "簡報模式"

        Uk ->
            "режим презентації"

        Ur ->
            "پریزنٹیشن موڈ"

        Zh ->
            "演示模式"

        _ ->
            "Presentation mode"


modeTextbook : Lang -> String
modeTextbook lang =
    case lang of
        Am ->
            "መማሪያ መጽሐፍ"

        Ar ->
            "الكتاب المدرسي"

        Bg ->
            "Учебник"

        Bn ->
            "পাঠ্যবই"

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
            "کتاب درسی"

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
            "դասագիրք"

        It ->
            "Manuale"

        Ja ->
            "教科書"

        Ka ->
            "სახელმძღვანელო"

        Ko ->
            "교과서"

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
            "учебник"

        Sk ->
            "Učebnica"

        Sl ->
            "Učbenik"

        Sq ->
            "Libër mësimor"

        Sv ->
            "Lärobok"

        Sw ->
            "Kitabu cha kiada"

        Tr ->
            "Ders kitabı"

        Tw ->
            "教科書"

        Uk ->
            "підручник"

        Ur ->
            "ٹیکسٹ بک"

        Zh ->
            "教科书"

        _ ->
            "Textbook"


modePresentation : Lang -> String
modePresentation lang =
    case lang of
        Am ->
            "አቀራረብ"

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
            "презентация"

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
            "簡報"

        Uk ->
            "презентація"

        Ur ->
            "پریزنٹیشن"

        Zh ->
            "演示"

        _ ->
            "Presentation"


modeSlides : Lang -> String
modeSlides lang =
    case lang of
        Am ->
            "ስላይዶች"

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
            "Diapositivas"

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
            "Dia's"

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
            "投影片"

        Uk ->
            "слайди"

        Ur ->
            "سلائیڈز"

        Zh ->
            "幻灯片"

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
            "Звук вкл."

        Bn ->
            "শব্দ চালু"

        Ca ->
            "So activat"

        Cs ->
            "Zvuk zapnut"

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
            "Geluid aan"

        Pa ->
            "ਆਵਾਜ਼ ਚਾਲੂ"

        Pl ->
            "Włącz dźwięk"

        Pt ->
            "Som ligado"

        Ro ->
            "Activează sunetul"

        Ru ->
            "звук включён"

        Sk ->
            "Zvuk zapnutý"

        Sl ->
            "Zvok vklopljen"

        Sq ->
            "Zëri i aktivizuar"

        Sv ->
            "Ljud på"

        Sw ->
            "Sauti imewashwa"

        Tr ->
            "Sesi aç"

        Tw ->
            "聲音開啟"

        Uk ->
            "Звук увімкнено"

        Ur ->
            "آواز آن"

        Zh ->
            "声音开启"

        _ ->
            "Sound on"


soundOff : Lang -> String
soundOff lang =
    case lang of
        Am ->
            "ድምጽ አጥፋ"

        Ar ->
            "الصوت معطل"

        Bg ->
            "Звук изкл."

        Bn ->
            "শব্দ বন্ধ"

        Ca ->
            "So desactivat"

        Cs ->
            "Zvuk vypnut"

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
            "առանց ձայնի"

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
            "Geluid uit"

        Pa ->
            "ਆਵਾਜ਼ ਬੰਦ"

        Pl ->
            "Wyłącz dźwięk"

        Pt ->
            "Som desligado"

        Ro ->
            "Dezactivează sunetul"

        Ru ->
            "звук выключен"

        Sk ->
            "Zvuk vypnutý"

        Sl ->
            "Zvok izklopljen"

        Sq ->
            "Zëri i çaktivizuar"

        Sv ->
            "Ljud av"

        Sw ->
            "Sauti imezimwa"

        Tr ->
            "Sesi kapat"

        Tw ->
            "聲音關閉"

        Uk ->
            "Звук вимкнено"

        Ur ->
            "آواز بند"

        Zh ->
            "声音关闭"

        _ ->
            "Sound off"


infoAuthor : Lang -> String
infoAuthor lang =
    case lang of
        Am ->
            "ደራሲ: "

        Ar ->
            "المؤلف: "

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
            "Autor: "

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
            "लेखक: "

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
            "作者："

        _ ->
            "Author: "


infoAuthors : Lang -> String
infoAuthors lang =
    case lang of
        Am ->
            "ደራሲዎች: "

        Ar ->
            "المؤلفون: "

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
            "Autores: "

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
            "लेखक: "

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
            "作者："

        _ ->
            "Authors: "


infoDate : Lang -> String
infoDate lang =
    case lang of
        Am ->
            "ቀን: "

        Ar ->
            "التاريخ: "

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
            "Fecha: "

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
            "तारीख: "

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
            "日期："

        _ ->
            "Date: "


infoEmail : Lang -> String
infoEmail lang =
    case lang of
        Am ->
            "ኢሜል: "

        Ar ->
            "البريد الإلكتروني: "

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
            "Correo electrónico: "

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
            "ईमेल: "

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
            "ელფოსტა: "

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
            "电子邮件："

        _ ->
            "Email: "


infoVersion : Lang -> String
infoVersion lang =
    case lang of
        Am ->
            "ስሪት: "

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
            "Versión: "

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
            "संस्करण: "

        Hr ->
            "Verzija: "

        Hu ->
            "Verzió: "

        Hy ->
            "տարբերակ: "

        It ->
            "Versione: "

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
            "ਵਰਜਨ: "

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
            "版本："

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
            "información"

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
            "տեղեկություններ"

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
            "信息"

        _ ->
            "Information"


confSettings : Lang -> String
confSettings lang =
    case lang of
        Am ->
            "ማስተካከያዎች"

        Ar ->
            "الإعدادات"

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
            "ਸੈਟਿੰਗਾਂ"

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
            "设置"

        _ ->
            "Settings"


confShare : Lang -> String
confShare lang =
    case lang of
        Am ->
            "አጋራ"

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
            "اشتراک‌گذاری"

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
            "በ... በኩል አጋራ"

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
            "compartir vía ..."

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
            "կիսվել հետևյալ միջոցով ..."

        It ->
            "Condividi via ..."

        Ja ->
            "共有方法..."

        Ka ->
            "გაზიარება ..."

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
            "ਇਸ ਰਾਹੀਂ ਸਾਂਝਾ ਕਰੋ ..."

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
            "透過...分享"

        Uk ->
            "поділитися через ..."

        Ur ->
            "... کے ذریعے شیئر کریں"

        Zh ->
            "通过……分享"

        _ ->
            "share via ..."


confTranslations : Lang -> String
confTranslations lang =
    case lang of
        Am ->
            "ትርጉሞች"

        Ar ->
            "الترجمات"

        Bg ->
            "Преводи"

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
            "თარგმანები"

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
            "翻译"

        _ ->
            "Translations"


confTooltip : Lang -> String
confTooltip lang =
    case lang of
        Am ->
            "የመሣሪያ ጥቆማዎች"

        Ar ->
            "تلميحات"

        Bg ->
            "Подсказки"

        Bn ->
            "টুলটিপ"

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

        Es ->
            "Descripciones emergentes"

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

        Hy ->
            "Հուշումներ"

        It ->
            "Suggerimenti"

        Ja ->
            "ツールチップ"

        Ka ->
            "ამომხტარი მინიშნებები"

        Ko ->
            "도구 설명"

        Lt ->
            "Paaiškinimai"

        Lv ->
            "Rīku padomi"

        Nb ->
            "Verktøytips"

        Nl ->
            "Tooltips"

        Pa ->
            "ਟੂਲਟਿੱਪ"

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


confDecals : Lang -> String
confDecals lang =
    case lang of
        Am ->
            "በቀለም ብቻ አትመካ"

        Ar ->
            "عدم الاعتماد على الألوان وحدها"

        Bg ->
            "Не разчитайте само на цвета"

        Bn ->
            "শুধু রঙের উপর নির্ভর করবেন না"

        Ca ->
            "No dependre només del color"

        Cs ->
            "Nespoléhat jen na barvy"

        Da ->
            "Brug ikke kun farver"

        De ->
            "Nicht nur Farben verwenden"

        El ->
            "Όχι μόνο με χρώματα"

        Es ->
            "No depender solo del color"

        Et ->
            "Ära tugine ainult värvidele"

        Eu ->
            "Ez erabili koloreak soilik"

        Fa ->
            "عدم اتکا تنها به رنگ"

        Fi ->
            "Älä luota pelkkiin väreihin"

        Fr ->
            "Ne pas se fier uniquement aux couleurs"

        Ga ->
            "Ná bí ag brath ar dhath amháin"

        Hi ->
            "केवल रंग पर निर्भर न रहें"

        Hr ->
            "Ne oslanjaj se samo na boju"

        Hu ->
            "Ne csak a színekre hagyatkozz"

        Hy ->
            "Չհենվել միայն գույնի վրա"

        It ->
            "Non affidarti solo ai colori"

        Ja ->
            "色だけに頼らない"

        Ka ->
            "მხოლოდ ფერებზე არ დაყრდნობა"

        Ko ->
            "색상에만 의존하지 않기"

        Lt ->
            "Nesiremti vien spalvomis"

        Lv ->
            "Nepaļauties tikai uz krāsām"

        Nb ->
            "Ikke stol på farger alene"

        Nl ->
            "Niet alleen op kleur vertrouwen"

        Pa ->
            "ਸਿਰਫ਼ ਰੰਗਾਂ 'ਤੇ ਨਿਰਭਰ ਨਾ ਕਰੋ"

        Pl ->
            "Nie polegaj tylko na kolorze"

        Pt ->
            "Não depender apenas de cores"

        Ro ->
            "Nu te baza doar pe culori"

        Ru ->
            "Не полагаться только на цвет"

        Sk ->
            "Nespoliehať sa len na farby"

        Sl ->
            "Ne zanašaj se le na barve"

        Sq ->
            "Mos u mbështet vetëm te ngjyrat"

        Sv ->
            "Använd inte enbart färger"

        Sw ->
            "Usitegemee rangi pekee"

        Tr ->
            "Yalnızca renge güvenme"

        Tw ->
            "不只依賴顏色"

        Uk ->
            "Не покладатися лише на колір"

        Ur ->
            "صرف رنگوں پر انحصار نہ کریں"

        Zh ->
            "不仅依靠颜色区分"

        _ ->
            "Do not rely on color alone"


confEdit : Lang -> String
confEdit lang =
    case lang of
        Am ->
            "አርታኢ ክፈት"

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
            "打开编辑器"

        _ ->
            "Open editor"


ttsPosition : Lang -> String
ttsPosition lang =
    case lang of
        Am ->
            "የማጫወቻ ቦታ"

        Ar ->
            "موضع التشغيل"

        Bg ->
            "Позиция на възпроизвеждане"

        Bn ->
            "প্লেব্যাকের অবস্থান"

        Ca ->
            "Posició de reproducció"

        Cs ->
            "Pozice přehrávání"

        Da ->
            "Afspilningsposition"

        De ->
            "Wiedergabeposition"

        El ->
            "Θέση αναπαραγωγής"

        Es ->
            "Posición de reproducción"

        Et ->
            "Taasesituse asukoht"

        Eu ->
            "Erreprodukzio-posizioa"

        Fa ->
            "موقعیت پخش"

        Fi ->
            "Toistokohta"

        Fr ->
            "Position de lecture"

        Ga ->
            "Suíomh athsheinnte"

        Hi ->
            "प्लेबैक स्थिति"

        Hr ->
            "Položaj reprodukcije"

        Hu ->
            "Lejátszási pozíció"

        Hy ->
            "Նվագարկման դիրքը"

        It ->
            "Posizione di riproduzione"

        Ja ->
            "再生位置"

        Ka ->
            "დაკვრის პოზიცია"

        Ko ->
            "재생 위치"

        Lt ->
            "Atkūrimo padėtis"

        Lv ->
            "Atskaņošanas pozīcija"

        Nb ->
            "Avspillingsposisjon"

        Nl ->
            "Afspeelpositie"

        Pa ->
            "ਪਲੇਬੈਕ ਸਥਿਤੀ"

        Pl ->
            "Pozycja odtwarzania"

        Pt ->
            "Posição de reprodução"

        Ro ->
            "Poziția redării"

        Ru ->
            "Позиция воспроизведения"

        Sk ->
            "Pozícia prehrávania"

        Sl ->
            "Položaj predvajanja"

        Sq ->
            "Pozicioni i riprodhimit"

        Sv ->
            "Uppspelningsposition"

        Sw ->
            "Nafasi ya uchezaji"

        Tr ->
            "Oynatma konumu"

        Tw ->
            "播放位置"

        Uk ->
            "Позиція відтворення"

        Ur ->
            "پلے بیک کی پوزیشن"

        Zh ->
            "播放位置"

        _ ->
            "Playback position"


ttsOf : Lang -> String
ttsOf lang =
    case lang of
        Am ->
            "ከ"

        Ar ->
            "من"

        Bg ->
            "от"

        Bn ->
            "/"

        Ca ->
            "de"

        Cs ->
            "z"

        Da ->
            "af"

        De ->
            "von"

        El ->
            "από"

        Es ->
            "de"

        Et ->
            "/"

        Eu ->
            "/"

        Fa ->
            "از"

        Fi ->
            "/"

        Fr ->
            "sur"

        Ga ->
            "as"

        Hi ->
            "/"

        Hr ->
            "od"

        Hu ->
            "/"

        Hy ->
            "/"

        It ->
            "di"

        Ja ->
            "/"

        Ka ->
            "/"

        Ko ->
            "/"

        Lt ->
            "iš"

        Lv ->
            "no"

        Nb ->
            "av"

        Nl ->
            "van"

        Pa ->
            "/"

        Pl ->
            "z"

        Pt ->
            "de"

        Ro ->
            "din"

        Ru ->
            "из"

        Sk ->
            "z"

        Sl ->
            "od"

        Sq ->
            "nga"

        Sv ->
            "av"

        Sw ->
            "kati ya"

        Tr ->
            "/"

        Tw ->
            "/"

        Uk ->
            "з"

        Ur ->
            "/"

        Zh ->
            "/"

        _ ->
            "of"


ttsPause : Lang -> String
ttsPause lang =
    case lang of
        Am ->
            "ለአፍታ አቁም"

        Ar ->
            "إيقاف مؤقت"

        Bg ->
            "Пауза"

        Bn ->
            "বিরতি"

        Ca ->
            "Pausa"

        Cs ->
            "Pozastavit"

        Da ->
            "Pause"

        De ->
            "Pausieren"

        El ->
            "Παύση"

        Es ->
            "Pausar"

        Et ->
            "Paus"

        Eu ->
            "Pausatu"

        Fa ->
            "مکث"

        Fi ->
            "Tauko"

        Fr ->
            "Pause"

        Ga ->
            "Sos"

        Hi ->
            "विराम"

        Hr ->
            "Pauziraj"

        Hu ->
            "Szünet"

        Hy ->
            "Դադար"

        It ->
            "Pausa"

        Ja ->
            "一時停止"

        Ka ->
            "პაუზა"

        Ko ->
            "일시 정지"

        Lt ->
            "Pristabdyti"

        Lv ->
            "Pauzēt"

        Nb ->
            "Pause"

        Nl ->
            "Pauzeren"

        Pa ->
            "ਵਿਰਾਮ"

        Pl ->
            "Wstrzymaj"

        Pt ->
            "Pausar"

        Ro ->
            "Întrerupe"

        Ru ->
            "Пауза"

        Sk ->
            "Pozastaviť"

        Sl ->
            "Začasno ustavi"

        Sq ->
            "Pauzë"

        Sv ->
            "Pausa"

        Sw ->
            "Sitisha"

        Tr ->
            "Duraklat"

        Tw ->
            "暫停"

        Uk ->
            "Пауза"

        Ur ->
            "توقف"

        Zh ->
            "暂停"

        _ ->
            "Pause"


ttsResume : Lang -> String
ttsResume lang =
    case lang of
        Am ->
            "ቀጥል"

        Ar ->
            "استئناف"

        Bg ->
            "Продължи"

        Bn ->
            "চালিয়ে যান"

        Ca ->
            "Reprèn"

        Cs ->
            "Pokračovat"

        Da ->
            "Genoptag"

        De ->
            "Fortsetzen"

        El ->
            "Συνέχεια"

        Es ->
            "Reanudar"

        Et ->
            "Jätka"

        Eu ->
            "Jarraitu"

        Fa ->
            "ادامه"

        Fi ->
            "Jatka"

        Fr ->
            "Reprendre"

        Ga ->
            "Atosaigh"

        Hi ->
            "फिर से शुरू करें"

        Hr ->
            "Nastavi"

        Hu ->
            "Folytatás"

        Hy ->
            "Շարունակել"

        It ->
            "Riprendi"

        Ja ->
            "再開"

        Ka ->
            "გაგრძელება"

        Ko ->
            "재개"

        Lt ->
            "Tęsti"

        Lv ->
            "Turpināt"

        Nb ->
            "Fortsett"

        Nl ->
            "Hervatten"

        Pa ->
            "ਜਾਰੀ ਰੱਖੋ"

        Pl ->
            "Wznów"

        Pt ->
            "Retomar"

        Ro ->
            "Reia"

        Ru ->
            "Продолжить"

        Sk ->
            "Pokračovať"

        Sl ->
            "Nadaljuj"

        Sq ->
            "Vazhdo"

        Sv ->
            "Fortsätt"

        Sw ->
            "Endelea"

        Tr ->
            "Devam et"

        Tw ->
            "繼續"

        Uk ->
            "Продовжити"

        Ur ->
            "جاری رکھیں"

        Zh ->
            "继续"

        _ ->
            "Resume"


ttsPreferBrowser : Lang -> String
ttsPreferBrowser lang =
    case lang of
        Am ->
            "የአሳሹን ጽሑፍ-ወደ-ንግግር ተመራጭ አድርግ"

        Ar ->
            "تفضيل تحويل النص إلى كلام في المتصفح"

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

        Fa ->
            "ترجیح تبدیل متن به گفتار مرورگر"

        Fi ->
            "Suosi selaimen puhesynteesiä"

        Fr ->
            "Préférer la synthèse vocale du navigateur"

        Ga ->
            "Tabhair tús áite do shintéis cainte an bhrabhsálaí"

        Hi ->
            "ब्राउज़र के टेक्स्ट-टू-स्पीच को प्राथमिकता दें"

        Hr ->
            "Daj prednost sintezi govora preglednika"

        Hu ->
            "A böngésző beszédszintézisének előnyben részesítése"

        Hy ->
            "Նախընտրել դիտարկիչի խոսքի սինթեզը"

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
            "Voorkeur voor browser-TTS"

        Pa ->
            "ਬਰਾਊਜ਼ਰ TTS ਨੂੰ ਤਰਜੀਹ ਦਿਓ"

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
            "Pendelea TTS ya kivinjari"

        Tr ->
            "Tarayıcının metin okuma özelliğini tercih et"

        Tw ->
            "優先使用瀏覽器 TTS"

        Uk ->
            "Надавати перевагу TTS браузера"

        Ur ->
            "براؤزر TTS کو ترجیح دیں"

        Zh ->
            "优先使用浏览器的文本转语音"

        _ ->
            "Prefer browser TTS"


ttsUsingBrowser : Lang -> String
ttsUsingBrowser lang =
    case lang of
        Am ->
            "የአሳሹ ውስጣዊ ጽሑፍ-ወደ-ንግግር ሞተር ጥቅም ላይ እየዋለ ነው።"

        Ar ->
            "يتم استخدام محرك تحويل النص إلى كلام المدمج في المتصفح."

        Bg ->
            "Използване на вътрешната машина за синтезиран говор на браузъра."

        Bn ->
            "ব্রাউজারের অভ্যন্তরীণ টেক্সট-টু-স্পিচ ইঞ্জিন ব্যবহার করা হচ্ছে।"

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

        Fa ->
            "استفاده از موتور داخلی تبدیل متن به گفتار مرورگر."

        Fi ->
            "Käytetään selaimen sisäänrakennettua puhesynteesiä."

        Fr ->
            "Utilisation du moteur de synthèse vocale intégré du navigateur."

        Ga ->
            "Tá sintéis cainte ionsuite an bhrabhsálaí in úsáid."

        Hi ->
            "ब्राउज़र के आंतरिक टेक्स्ट-टू-स्पीच इंजन का उपयोग किया जा रहा है।"

        Hr ->
            "Koristi se ugrađena sinteza govora preglednika."

        Hu ->
            "A böngésző beépített beszédszintetizátora van használatban."

        Hy ->
            "Օգտագործվում է դիտարկիչի ներկառուցված խոսքի սինթեզը։"

        It ->
            "Viene utilizzata la sintesi vocale integrata del browser."

        Ja ->
            "ブラウザの内蔵テキスト読み上げエンジンを使用中"

        Ka ->
            "გამოიყენება ბრაუზერის ჩაშენებული მეტყველების სინთეზი."

        Ko ->
            "브라우저의 내부 텍스트 음성 변환 엔진을 사용합니다."

        Lt ->
            "Naudojama naršyklėje integruota kalbos sintezė."

        Lv ->
            "Tiek izmantota pārlūkprogrammā iebūvētā runas sintēze."

        Nb ->
            "Nettleserens innebygde talesyntese brukes."

        Nl ->
            "De interne tekst-naar-spraak-engine van de browser wordt gebruikt."

        Pa ->
            "ਬਰਾਊਜ਼ਰ ਦੇ ਅੰਦਰੂਨੀ ਟੈਕਸਟ-ਟੁ-ਸਪੀਚ ਇੰਜਨ ਦੀ ਵਰਤੋਂ ਕੀਤੀ ਜਾ ਰਹੀ ਹੈ।"

        Pl ->
            "Używana jest wbudowana synteza mowy przeglądarki."

        Pt ->
            "Usando o motor interno de Texto-para-Fala do navegador."

        Ro ->
            "Se utilizează motorul de sinteză vocală integrat în browser."

        Ru ->
            "Используется встроенный в браузер механизм преобразования текста в речь."

        Sk ->
            "Používa sa vstavaná syntéza reči prehliadača."

        Sl ->
            "Uporablja se vgrajena sinteza govora v brskalniku."

        Sq ->
            "Po përdoret motori i integruar i sintezës së të folurit të shfletuesit."

        Sv ->
            "Webbläsarens inbyggda talsyntes används."

        Sw ->
            "Inatumia injini ya ndani ya kivinjari ya Maandishi-hadi-Hotuba."

        Tr ->
            "Tarayıcının yerleşik metin okuma motoru kullanılıyor."

        Tw ->
            "正在使用瀏覽器內建的文字轉語音引擎。"

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
            "አሳሽዎ ጽሑፍ-ወደ-ንግግርን አይደግፍም፤ እባክዎ ሌላ አሳሽ ይሞክሩ።"

        Ar ->
            "متصفحك لا يدعم تحويل النص إلى كلام، جرّب متصفحًا آخر."

        Bg ->
            "Вашият браузър не поддържа синтез на говор, опитайте с друг."

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
            "Tu navegador no es compatible con la conversión de texto a voz, prueba con otro."

        Et ->
            "Sinu brauser ei toeta kõnesünteesi. Proovi mõnda teist brauserit."

        Eu ->
            "Zure nabigatzaileak ez du hizketa-sintesia onartzen. Probatu beste bat."

        Fa ->
            "مرورگر شما از تبدیل متن به گفتار پشتیبانی نمی‌کند، مرورگر دیگری را امتحان کنید."

        Fi ->
            "Selaimesi ei tue puhesynteesiä. Kokeile toista selainta."

        Fr ->
            "Votre navigateur ne prend pas en charge la synthèse vocale, essayez-en un autre."

        Ga ->
            "Ní thacaíonn do bhrabhsálaí le sintéis cainte. Bain triail as brabhsálaí eile."

        Hi ->
            "आपका ब्राउज़र टेक्स्ट-टू-स्पीच का समर्थन नहीं करता है, कोई दूसरा ब्राउज़र आज़माएँ।"

        Hr ->
            "Tvoj preglednik ne podržava sintezu govora. Isprobaj drugi."

        Hu ->
            "A böngésződ nem támogatja a beszédszintézist. Próbálj ki egy másikat."

        Hy ->
            "Ձեր դիտարկիչը չի աջակցում խոսքի սինթեզ, փորձեք մեկ ուրիշը։"

        It ->
            "Il tuo browser non supporta la sintesi vocale, provane un altro."

        Ja ->
            "このブラウザはテキスト読み上げに対応していません。他のブラウザをお試しください。"

        Ka ->
            "თქვენი ბრაუზერი მხარს არ უჭერს მეტყველების სინთეზს, სცადეთ სხვა."

        Ko ->
            "이 브라우저는 텍스트 음성 변환을 지원하지 않습니다. 다른 브라우저를 사용해 보세요."

        Lt ->
            "Tavo naršyklė nepalaiko kalbos sintezės. Išbandyk kitą."

        Lv ->
            "Tava pārlūkprogramma neatbalsta runas sintēzi. Izmēģini citu."

        Nb ->
            "Nettleseren din støtter ikke talesyntese. Prøv en annen."

        Nl ->
            "Je browser ondersteunt geen tekst-naar-spraak, probeer een andere."

        Pa ->
            "ਤੁਹਾਡਾ ਬਰਾਊਜ਼ਰ ਟੈਕਸਟ-ਟੁ-ਸਪੀਚ ਦਾ ਸਮਰਥਨ ਨਹੀਂ ਕਰਦਾ, ਕੋਈ ਹੋਰ ਬਰਾਊਜ਼ਰ ਵਰਤੋ।"

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
            "Kivinjari chako hakiauni Maandishi-hadi-Hotuba, jaribu kingine."

        Tr ->
            "Tarayıcınız metin okumayı desteklemiyor. Başka bir tarayıcı deneyin."

        Tw ->
            "您的瀏覽器不支援文字轉語音，請換一個瀏覽器。"

        Uk ->
            "Ваш браузер не підтримує синтез мовлення з тексту, спробуйте інший."

        Ur ->
            "آپ کا براؤزر ٹیکسٹ ٹو اسپیچ کی حمایت نہیں کرتا، کوئی دوسرا آزمائیں۔"

        Zh ->
            "您的浏览器不支持文本转语音，请换一个浏览器。"

        _ ->
            "Your browser does not support Text-to-Speech, try another one."


codeEditor : Lang -> String
codeEditor lang =
    case lang of
        Am ->
            "የኮድ አርታኢ"

        Ar ->
            "محرر الشيفرة"

        Bg ->
            "Редактор на код"

        Bn ->
            "কোড এডিটর"

        Ca ->
            "Editor de codi"

        Cs ->
            "Editor kódu"

        Da ->
            "Kodeeditor"

        De ->
            "Code-Editor"

        El ->
            "Επεξεργαστής κώδικα"

        Es ->
            "Editor de código"

        Et ->
            "Koodiredaktor"

        Eu ->
            "Kode-editorea"

        Fa ->
            "ویرایشگر کد"

        Fi ->
            "Koodieditori"

        Fr ->
            "Éditeur de code"

        Ga ->
            "Eagarthóir cóid"

        Hi ->
            "कोड संपादक"

        Hr ->
            "Uređivač koda"

        Hu ->
            "Kódszerkesztő"

        Hy ->
            "Կոդի խմբագրիչ"

        It ->
            "Editor di codice"

        Ja ->
            "コードエディター"

        Ka ->
            "კოდის რედაქტორი"

        Ko ->
            "코드 편집기"

        Lt ->
            "Kodo rengyklė"

        Lv ->
            "Koda redaktors"

        Nb ->
            "Kodeeditor"

        Nl ->
            "Code-editor"

        Pa ->
            "ਕੋਡ ਸੰਪਾਦਕ"

        Pl ->
            "Edytor kodu"

        Pt ->
            "Editor de código"

        Ro ->
            "Editor de cod"

        Ru ->
            "Редактор кода"

        Sk ->
            "Editor kódu"

        Sl ->
            "Urejevalnik kode"

        Sq ->
            "Redaktuesi i kodit"

        Sv ->
            "Kodredigerare"

        Sw ->
            "Kihariri cha msimbo"

        Tr ->
            "Kod düzenleyici"

        Tw ->
            "程式碼編輯器"

        Uk ->
            "Редактор коду"

        Ur ->
            "کوڈ ایڈیٹر"

        Zh ->
            "代码编辑器"

        _ ->
            "Code editor"


codeBlock : Lang -> String
codeBlock lang =
    case lang of
        Am ->
            "የኮድ ብሎክ"

        Ar ->
            "كتلة شيفرة"

        Bg ->
            "Блок с код"

        Bn ->
            "কোড ব্লক"

        Ca ->
            "Bloc de codi"

        Cs ->
            "Blok kódu"

        Da ->
            "Kodeblok"

        De ->
            "Codeblock"

        El ->
            "Μπλοκ κώδικα"

        Es ->
            "Bloque de código"

        Et ->
            "Koodiplokk"

        Eu ->
            "Kode-blokea"

        Fa ->
            "بلوک کد"

        Fi ->
            "Koodilohko"

        Fr ->
            "Bloc de code"

        Ga ->
            "Bloc cóid"

        Hi ->
            "कोड ब्लॉक"

        Hr ->
            "Blok koda"

        Hu ->
            "Kódblokk"

        Hy ->
            "Կոդի բլոկ"

        It ->
            "Blocco di codice"

        Ja ->
            "コードブロック"

        Ka ->
            "კოდის ბლოკი"

        Ko ->
            "코드 블록"

        Lt ->
            "Kodo blokas"

        Lv ->
            "Koda bloks"

        Nb ->
            "Kodeblokk"

        Nl ->
            "Codeblok"

        Pa ->
            "ਕੋਡ ਬਲਾਕ"

        Pl ->
            "Blok kodu"

        Pt ->
            "Bloco de código"

        Ro ->
            "Bloc de cod"

        Ru ->
            "Блок кода"

        Sk ->
            "Blok kódu"

        Sl ->
            "Blok kode"

        Sq ->
            "Blloku i kodit"

        Sv ->
            "Kodblock"

        Sw ->
            "Kipande cha msimbo"

        Tr ->
            "Kod bloğu"

        Tw ->
            "程式碼區塊"

        Uk ->
            "Блок коду"

        Ur ->
            "کوڈ بلاک"

        Zh ->
            "代码块"

        _ ->
            "Code block"


codeExecute : Lang -> String
codeExecute lang =
    case lang of
        Am ->
            "አሂድ"

        Ar ->
            "تنفيذ"

        Bg ->
            "Изпълни"

        Bn ->
            "চালান"

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
            "चलाएँ"

        Hr ->
            "Pokreni"

        Hu ->
            "Futtatás"

        Hy ->
            "գործարկել"

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
            "چلائیں"

        Zh ->
            "运行"

        _ ->
            "Execute"


codeRunning : Lang -> String
codeRunning lang =
    case lang of
        Am ->
            "እየሄደ ነው"

        Ar ->
            "قيد التشغيل"

        Bg ->
            "се изпълнява"

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
            "գործարկվում է"

        It ->
            "in esecuzione"

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
            "inaendeshwa"

        Tr ->
            "çalışıyor"

        Tw ->
            "執行中"

        Uk ->
            "виконується"

        Ur ->
            "چل رہا ہے"

        Zh ->
            "正在运行"

        _ ->
            "is running"


codePrev : Lang -> String
codePrev lang =
    case lang of
        Am ->
            "ቀዳሚ ስሪት"

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
            "पिछला संस्करण"

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
            "上一版本"

        _ ->
            "previous version"


codeNext : Lang -> String
codeNext lang =
    case lang of
        Am ->
            "ቀጣይ ስሪት"

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
            "अगला संस्करण"

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
            "下一版本"

        _ ->
            "next version"


codeFirst : Lang -> String
codeFirst lang =
    case lang of
        Am ->
            "የመጀመሪያ ስሪት"

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
            "पहला संस्करण"

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
            "ਪਹਿਲਾ ਵਰਜਨ"

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
            "第一个版本"

        _ ->
            "first version"


codeLast : Lang -> String
codeLast lang =
    case lang of
        Am ->
            "የመጨረሻ ስሪት"

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
            "ਆਖਰੀ ਵਰਜਨ"

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
            "最后一个版本"

        _ ->
            "last version"


codeMinimize : Lang -> String
codeMinimize lang =
    case lang of
        Am ->
            "እይታውን አሳንስ"

        Ar ->
            "تصغير"

        Bg ->
            "Минимизиране"

        Bn ->
            "দৃশ্য ছোট করুন"

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
            "փոքրացնել տեսքը"

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
            "ਝਲਕ ਛੋਟੀ ਕਰੋ"

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
            "最小化顯示"

        Uk ->
            "зменшити вигляд"

        Ur ->
            "منظر کو چھوٹا کریں"

        Zh ->
            "最小化视图"

        _ ->
            "minimize view"


codeMaximize : Lang -> String
codeMaximize lang =
    case lang of
        Am ->
            "እይታውን አስፋ"

        Ar ->
            "إظهار بالكامل"

        Bg ->
            "Максимизиране"

        Bn ->
            "দৃশ্য বড় করুন"

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
            "maximizar vista"

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
            "մեծացնել տեսքը"

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
            "ਝਲਕ ਵੱਡੀ ਕਰੋ"

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
            "ongeza mtazamo"

        Tr ->
            "görünümü büyüt"

        Tw ->
            "最大化顯示"

        Uk ->
            "збільшити вигляд"

        Ur ->
            "منظر کو بڑا کریں"

        Zh ->
            "最大化视图"

        _ ->
            "maximize view"


codeTerminal : Lang -> String
codeTerminal lang =
    case lang of
        Am ->
            "ተርሚናል"

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

        Es ->
            "terminal"

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

        It ->
            "terminale"

        Ja ->
            "ターミナル"

        Ka ->
            "ტერმინალი"

        Ko ->
            "터미널"

        Lt ->
            "terminalas"

        Lv ->
            "terminālis"

        Nb ->
            "terminal"

        Nl ->
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
            "терминал"

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
            "終端機"

        Uk ->
            "термінал"

        Ur ->
            "ٹرمینل"

        Zh ->
            "终端"

        _ ->
            "terminal"


codeSendTerminal : Lang -> String
codeSendTerminal lang =
    case lang of
        Am ->
            "ወደ ተርሚናል ላክ"

        Ar ->
            "إرسال إلى الطرفية"

        Bg ->
            "Изпрати към терминала"

        Bn ->
            "টার্মিনালে পাঠান"

        Ca ->
            "Envia al terminal"

        Cs ->
            "Odeslat do terminálu"

        Da ->
            "Send til terminal"

        De ->
            "An das Terminal senden"

        El ->
            "Αποστολή στο τερματικό"

        Es ->
            "Enviar al terminal"

        Et ->
            "Saada terminali"

        Eu ->
            "Bidali terminalera"

        Fa ->
            "ارسال به پایانه"

        Fi ->
            "Lähetä päätteeseen"

        Fr ->
            "Envoyer au terminal"

        Ga ->
            "Seol chuig an teirminéal"

        Hi ->
            "टर्मिनल पर भेजें"

        Hr ->
            "Pošalji u terminal"

        Hu ->
            "Küldés a terminálba"

        Hy ->
            "Ուղարկել տերմինալ"

        It ->
            "Invia al terminale"

        Ja ->
            "ターミナルに送信"

        Ka ->
            "ტერმინალში გაგზავნა"

        Ko ->
            "터미널로 보내기"

        Lt ->
            "Siųsti į terminalą"

        Lv ->
            "Sūtīt uz termināli"

        Nb ->
            "Send til terminalen"

        Nl ->
            "Naar terminal sturen"

        Pa ->
            "ਟਰਮੀਨਲ ਨੂੰ ਭੇਜੋ"

        Pl ->
            "Wyślij do terminala"

        Pt ->
            "Enviar ao terminal"

        Ro ->
            "Trimite la terminal"

        Ru ->
            "Отправить в терминал"

        Sk ->
            "Odoslať do terminálu"

        Sl ->
            "Pošlji v terminal"

        Sq ->
            "Dërgo në terminal"

        Sv ->
            "Skicka till terminalen"

        Sw ->
            "Tuma kwenye terminal"

        Tr ->
            "Terminale gönder"

        Tw ->
            "傳送至終端機"

        Uk ->
            "Надіслати в термінал"

        Ur ->
            "ٹرمینل کو بھیجیں"

        Zh ->
            "发送到终端"

        _ ->
            "Send to terminal"


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
            "ბუფერში კოპირება"

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
            "複製到剪貼簿"

        Uk ->
            "копіювати в буфер обміну"

        Ur ->
            "کلپ بورڈ پر کاپی کریں"

        Zh ->
            "复制到剪贴板"

        _ ->
            "copy to clipboard"


codeCopied : Lang -> String
codeCopied lang =
    case lang of
        Am ->
            "ወደ ቅንጥብ ሰሌዳ ተቀድቷል"

        Ar ->
            "تم النسخ إلى الحافظة"

        Bg ->
            "Копирано в клипборда"

        Bn ->
            "ক্লিপবোর্ডে কপি করা হয়েছে"

        Ca ->
            "copiat al porta-retalls"

        Cs ->
            "zkopírováno do schránky"

        Da ->
            "kopieret til udklipsholder"

        De ->
            "in die Zwischenablage kopiert"

        El ->
            "αντιγράφηκε στο πρόχειρο"

        Es ->
            "copiado al portapapeles"

        Et ->
            "kopeeritud lõikelauale"

        Eu ->
            "arbelean kopiatuta"

        Fa ->
            "در کلیپ بورد کپی شد"

        Fi ->
            "kopioitu leikepöydälle"

        Fr ->
            "Copié dans le presse-papiers"

        Ga ->
            "cóipeáilte chuig an ngearrthaisce"

        Hi ->
            "क्लिपबोर्ड पर कॉपी हो गया"

        Hr ->
            "kopirano u međuspremnik"

        Hu ->
            "vágólapra másolva"

        Hy ->
            "Պատճենվել է սեղմատախտակին"

        It ->
            "copiato negli appunti"

        Ja ->
            "クリップボードにコピーしました"

        Ka ->
            "ბუფერში დაკოპირდა"

        Ko ->
            "클립보드에 복사됨"

        Lt ->
            "nukopijuota į iškarpinę"

        Lv ->
            "nokopēts starpliktuvē"

        Nb ->
            "kopiert til utklippstavlen"

        Nl ->
            "gekopieerd naar klembord"

        Pa ->
            "ਕਲਿੱਪਬੋਰਡ 'ਤੇ ਕਾਪੀ ਹੋ ਗਿਆ"

        Pl ->
            "skopiowano do schowka"

        Pt ->
            "copiado para a área de transferência"

        Ro ->
            "copiat în clipboard"

        Ru ->
            "скопировано в буфер обмена"

        Sk ->
            "skopírované do schránky"

        Sl ->
            "kopirano v odložišče"

        Sq ->
            "u kopjua në kujtesën e përkohshme"

        Sv ->
            "kopierat till urklipp"

        Sw ->
            "imenakiliwa kwenye ubao wa kunakili"

        Tr ->
            "panoya kopyalandı"

        Tw ->
            "已複製到剪貼簿"

        Uk ->
            "скопійовано в буфер обміну"

        Ur ->
            "کلپ بورڈ پر کاپی ہو گیا"

        Zh ->
            "已复制到剪贴板"

        _ ->
            "copied to clipboard"


codeReset : Lang -> String
codeReset lang =
    case lang of
        Am ->
            "ግቤቱን ዳግም አስጀምር"

        Ar ->
            "إعادة تعيين الإدخال"

        Bg ->
            "нулиране на въведеното"

        Bn ->
            "ইনপুট রিসেট করুন"

        Ca ->
            "restableix l'entrada"

        Cs ->
            "obnovit vstup"

        Da ->
            "nulstil input"

        De ->
            "Eingabe zurücksetzen"

        El ->
            "επαναφορά εισόδου"

        Es ->
            "restablecer entrada"

        Et ->
            "lähtesta sisend"

        Eu ->
            "berrezarri sarrera"

        Fa ->
            "بازنشانی ورودی"

        Fi ->
            "palauta syöte"

        Fr ->
            "réinitialiser la saisie"

        Ga ->
            "athshocraigh an t-ionchur"

        Hi ->
            "इनपुट रीसेट करें"

        Hr ->
            "poništi unos"

        Hu ->
            "bevitel visszaállítása"

        Hy ->
            "վերակայել մուտքագրումը"

        It ->
            "ripristina l'input"

        Ja ->
            "入力をリセット"

        Ka ->
            "შეყვანის გადაყენება"

        Ko ->
            "입력 초기화"

        Lt ->
            "atkurti pradinę įvestį"

        Lv ->
            "atiestatīt ievadi"

        Nb ->
            "tilbakestill inndata"

        Nl ->
            "invoer herstellen"

        Pa ->
            "ਇਨਪੁਟ ਰੀਸੈੱਟ ਕਰੋ"

        Pl ->
            "resetuj dane wejściowe"

        Pt ->
            "redefinir entrada"

        Ro ->
            "resetează valoarea introdusă"

        Ru ->
            "сбросить ввод"

        Sk ->
            "obnoviť vstup"

        Sl ->
            "ponastavi vnos"

        Sq ->
            "rivendos hyrjen"

        Sv ->
            "återställ inmatning"

        Sw ->
            "weka upya ingizo"

        Tr ->
            "girişi sıfırla"

        Tw ->
            "重設輸入"

        Uk ->
            "скинути введення"

        Ur ->
            "ان پٹ ری سیٹ کریں"

        Zh ->
            "重置输入"

        _ ->
            "reset input"


quizCheck : Lang -> String
quizCheck lang =
    case lang of
        Am ->
            "አረጋግጥ"

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
            "Controleren"

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
            "檢查"

        Uk ->
            "перевірити"

        Ur ->
            "چیک کریں"

        Zh ->
            "检查"

        _ ->
            "Check"


quizSolution : Lang -> String
quizSolution lang =
    case lang of
        Am ->
            "መፍትሔ አሳይ"

        Ar ->
            "إظهار الحل"

        Bg ->
            "Покажи решението"

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
            "نمایش راه‌حل"

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
            "ამოხსნის ჩვენება"

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
            "显示解答"

        _ ->
            "show solution"


quizHint : Lang -> String
quizHint lang =
    case lang of
        Am ->
            "ፍንጭ አሳይ"

        Ar ->
            "إظهار تلميح"

        Bg ->
            "Покажи подсказка"

        Bn ->
            "ইঙ্গিত দেখান"

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
            "mostrar pista"

        Et ->
            "näita vihjet"

        Eu ->
            "erakutsi pista"

        Fa ->
            "نمایش راهنمایی"

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
            "ցույց տալ հուշումը"

        It ->
            "mostra un indizio"

        Ja ->
            "ヒントを表示"

        Ka ->
            "მინიშნების ჩვენება"

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
            "ਸੰਕੇਤ ਦਿਖਾਓ"

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
            "顯示提示"

        Uk ->
            "показати підказку"

        Ur ->
            "اشارہ دکھائیں"

        Zh ->
            "显示提示"

        _ ->
            "show hint"


quizSelection : Lang -> String
quizSelection lang =
    case lang of
        Am ->
            "ምርጫ"

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
            "選擇"

        Uk ->
            "вибір"

        Ur ->
            "انتخاب"

        Zh ->
            "选择"

        _ ->
            "selection"


quizInput : Lang -> String
quizInput lang =
    case lang of
        Am ->
            "መልስ"

        Ar ->
            "الإجابة"

        Bg ->
            "Отговор"

        Bn ->
            "উত্তর"

        Ca ->
            "Resposta"

        Cs ->
            "Odpověď"

        Da ->
            "Svar"

        De ->
            "Antwort"

        El ->
            "Απάντηση"

        Es ->
            "Respuesta"

        Et ->
            "Vastus"

        Eu ->
            "Erantzuna"

        Fa ->
            "پاسخ"

        Fi ->
            "Vastaus"

        Fr ->
            "Réponse"

        Ga ->
            "Freagra"

        Hi ->
            "उत्तर"

        Hr ->
            "Odgovor"

        Hu ->
            "Válasz"

        Hy ->
            "Պատասխան"

        It ->
            "Risposta"

        Ja ->
            "回答"

        Ka ->
            "პასუხი"

        Ko ->
            "답"

        Lt ->
            "Atsakymas"

        Lv ->
            "Atbilde"

        Nb ->
            "Svar"

        Nl ->
            "Antwoord"

        Pa ->
            "ਜਵਾਬ"

        Pl ->
            "Odpowiedź"

        Pt ->
            "Resposta"

        Ro ->
            "Răspuns"

        Ru ->
            "Ответ"

        Sk ->
            "Odpoveď"

        Sl ->
            "Odgovor"

        Sq ->
            "Përgjigjja"

        Sv ->
            "Svar"

        Sw ->
            "Jibu"

        Tr ->
            "Yanıt"

        Tw ->
            "答案"

        Uk ->
            "Відповідь"

        Ur ->
            "جواب"

        Zh ->
            "答案"

        _ ->
            "Answer"


quizGap : Lang -> String
quizGap lang =
    case lang of
        Am ->
            "ክፍት ቦታ"

        Ar ->
            "فراغ"

        Bg ->
            "Празно място"

        Bn ->
            "শূন্যস্থান"

        Ca ->
            "Buit"

        Cs ->
            "Mezera"

        Da ->
            "Hul"

        De ->
            "Lücke"

        El ->
            "Κενό"

        Es ->
            "Hueco"

        Et ->
            "Lünk"

        Eu ->
            "Hutsunea"

        Fa ->
            "جای خالی"

        Fi ->
            "Aukko"

        Fr ->
            "Trou"

        Ga ->
            "Bearna"

        Hi ->
            "रिक्त स्थान"

        Hr ->
            "Praznina"

        Hu ->
            "Kitöltendő hely"

        Hy ->
            "Բացթողում"

        It ->
            "Lacuna"

        Ja ->
            "空欄"

        Ka ->
            "გამოტოვებული ადგილი"

        Ko ->
            "빈칸"

        Lt ->
            "Spraga"

        Lv ->
            "Aizpildāmā vieta"

        Nb ->
            "Luke"

        Nl ->
            "Invulveld"

        Pa ->
            "ਖਾਲੀ ਥਾਂ"

        Pl ->
            "Luka"

        Pt ->
            "Lacuna"

        Ro ->
            "Spațiu liber"

        Ru ->
            "Пропуск"

        Sk ->
            "Medzera"

        Sl ->
            "Vrzel"

        Sq ->
            "Boshllëku"

        Sv ->
            "Lucka"

        Sw ->
            "Pengo"

        Tr ->
            "Boşluk"

        Tw ->
            "填空"

        Uk ->
            "Пропуск"

        Ur ->
            "خالی جگہ"

        Zh ->
            "填空"

        _ ->
            "Gap"


quizDropZone : Lang -> String
quizDropZone lang =
    case lang of
        Am ->
            "ማስቀመጫ ቦታ"

        Ar ->
            "منطقة الإفلات"

        Bg ->
            "Зона за пускане"

        Bn ->
            "ড্রপ জোন"

        Ca ->
            "Zona per deixar anar"

        Cs ->
            "Cílové pole"

        Da ->
            "Slipfelt"

        De ->
            "Ablagefeld"

        El ->
            "Περιοχή απόθεσης"

        Es ->
            "Zona de destino"

        Et ->
            "Sihtala"

        Eu ->
            "Jaregite-eremua"

        Fa ->
            "ناحیهٔ رهاسازی"

        Fi ->
            "Pudotusalue"

        Fr ->
            "Zone de dépôt"

        Ga ->
            "Limistéar scaoilte"

        Hi ->
            "ड्रॉप ज़ोन"

        Hr ->
            "Polje za ispuštanje"

        Hu ->
            "Célterület"

        Hy ->
            "Տեղադրման դաշտ"

        It ->
            "Area di rilascio"

        Ja ->
            "ドロップ領域"

        Ka ->
            "ჩასაგდები არე"

        Ko ->
            "드롭 영역"

        Lt ->
            "Numetimo sritis"

        Lv ->
            "Nomešanas zona"

        Nb ->
            "Slippsone"

        Nl ->
            "Neerzetzone"

        Pa ->
            "ਰੱਖਣ ਵਾਲਾ ਖੇਤਰ"

        Pl ->
            "Pole upuszczania"

        Pt ->
            "Área de soltar"

        Ro ->
            "Zonă de plasare"

        Ru ->
            "Область размещения"

        Sk ->
            "Cieľové pole"

        Sl ->
            "Ciljno polje"

        Sq ->
            "Zona e lëshimit"

        Sv ->
            "Släppyta"

        Sw ->
            "Eneo la kudondoshea"

        Tr ->
            "Bırakma alanı"

        Tw ->
            "放置區"

        Uk ->
            "Зона розміщення"

        Ur ->
            "ڈراپ زون"

        Zh ->
            "放置区"

        _ ->
            "Drop zone"


quizEmpty : Lang -> String
quizEmpty lang =
    case lang of
        Am ->
            "ባዶ"

        Ar ->
            "فارغة"

        Bg ->
            "празна"

        Bn ->
            "খালি"

        Ca ->
            "buida"

        Cs ->
            "prázdné"

        Da ->
            "tomt"

        De ->
            "leer"

        El ->
            "κενή"

        Es ->
            "vacía"

        Et ->
            "tühi"

        Eu ->
            "hutsik"

        Fa ->
            "خالی"

        Fi ->
            "tyhjä"

        Fr ->
            "vide"

        Ga ->
            "folamh"

        Hi ->
            "खाली"

        Hr ->
            "prazno"

        Hu ->
            "üres"

        Hy ->
            "դատարկ"

        It ->
            "vuota"

        Ja ->
            "空"

        Ka ->
            "ცარიელი"

        Ko ->
            "비어 있음"

        Lt ->
            "tuščia"

        Lv ->
            "tukša"

        Nb ->
            "tom"

        Nl ->
            "leeg"

        Pa ->
            "ਖਾਲੀ"

        Pl ->
            "puste"

        Pt ->
            "vazia"

        Ro ->
            "goală"

        Ru ->
            "пустая"

        Sk ->
            "prázdne"

        Sl ->
            "prazno"

        Sq ->
            "bosh"

        Sv ->
            "tom"

        Sw ->
            "tupu"

        Tr ->
            "boş"

        Tw ->
            "空"

        Uk ->
            "порожня"

        Ur ->
            "خالی"

        Zh ->
            "空"

        _ ->
            "empty"


quizDragHint : Lang -> String
quizDragHint lang =
    case lang of
        Am ->
            "ማስቀመጫ ቦታን ለመምረጥ በላዩ ላይ Enter ይጫኑ፣ ከዚያም ካርዱን እዚያ ለማስቀመጥ በካርዱ ላይ Enter ይጫኑ"

        Ar ->
            "اضغط Enter على منطقة إفلات لتحديدها، ثم Enter على بطاقة لوضعها فيها"

        Bg ->
            "Натиснете Enter върху зона за пускане, за да я изберете, след това Enter върху карта, за да я поставите там"

        Bn ->
            "একটি ড্রপ জোন নির্বাচন করতে তাতে Enter চাপুন, তারপর একটি কার্ড সেখানে রাখতে কার্ডটিতে Enter চাপুন"

        Ca ->
            "Prem Retorn en una zona per seleccionar-la i després Retorn en una targeta per col·locar-la-hi"

        Cs ->
            "Klávesou Enter vyber cílové pole, pak klávesou Enter na kartě ji do něj umísti"

        Da ->
            "Tryk Enter på et slipfelt for at vælge det, og derefter Enter på et kort for at placere det der"

        De ->
            "Mit Enter ein Ablagefeld wählen, dann mit Enter eine Karte darauf ablegen"

        El ->
            "Πάτησε Enter σε μια περιοχή απόθεσης για να την επιλέξεις και μετά Enter σε μια κάρτα για να την τοποθετήσεις εκεί"

        Es ->
            "Pulsa Enter en una zona de destino para seleccionarla y luego Enter en una tarjeta para colocarla allí"

        Et ->
            "Vajuta sihtalal Enterit, et see valida, seejärel vajuta kaardil Enterit, et see sinna paigutada"

        Eu ->
            "Sakatu Enter jaregite-eremu batean hura hautatzeko, eta gero Enter txartel batean bertan kokatzeko"

        Fa ->
            "روی یک ناحیهٔ رهاسازی Enter را بزنید تا انتخاب شود، سپس روی یک کارت Enter را بزنید تا در آنجا قرار گیرد"

        Fi ->
            "Valitse pudotusalue painamalla siinä Enteriä ja paina sitten kortissa Enteriä sijoittaaksesi sen sinne"

        Fr ->
            "Appuyez sur Entrée sur une zone de dépôt pour la sélectionner, puis sur Entrée sur une carte pour l'y placer"

        Ga ->
            "Brúigh Enter ar limistéar scaoilte chun é a roghnú, ansin Enter ar chárta chun é a chur ann"

        Hi ->
            "ड्रॉप ज़ोन चुनने के लिए उस पर Enter दबाएँ, फिर किसी कार्ड को वहाँ रखने के लिए उस पर Enter दबाएँ"

        Hr ->
            "Pritisni Enter na polju za ispuštanje da ga odabereš, zatim Enter na kartici da je postaviš ondje"

        Hu ->
            "Nyomj Entert egy célterületen a kiválasztásához, majd Entert egy kártyán, hogy oda helyezd"

        Hy ->
            "Սեղմեք Enter տեղադրման դաշտի վրա՝ այն ընտրելու համար, ապա Enter քարտի վրա՝ այն այնտեղ տեղադրելու համար"

        It ->
            "Premi Invio su un'area di rilascio per selezionarla, poi Invio su una scheda per posizionarla lì"

        Ja ->
            "ドロップ領域でEnterを押して選択し、次にカードでEnterを押してそこに配置します"

        Ka ->
            "დააჭირეთ Enter-ს ჩასაგდებ არეზე მის ასარჩევად, შემდეგ Enter-ს ბარათზე, რომ იქ მოათავსოთ"

        Ko ->
            "드롭 영역에서 Enter 키를 눌러 선택한 다음, 카드에서 Enter 키를 눌러 그곳에 놓으세요"

        Lt ->
            "Paspausk Enter ant numetimo srities, kad ją pasirinktum, tada Enter ant kortelės, kad ją ten padėtum"

        Lv ->
            "Nospied Enter uz nomešanas zonas, lai to izvēlētos, tad Enter uz kartītes, lai to tur novietotu"

        Nb ->
            "Trykk Enter på en slippsone for å velge den, og deretter Enter på et kort for å plassere det der"

        Nl ->
            "Druk op Enter bij een neerzetzone om die te selecteren en daarna op Enter bij een kaart om die daar te plaatsen"

        Pa ->
            "ਰੱਖਣ ਵਾਲੇ ਖੇਤਰ ਨੂੰ ਚੁਣਨ ਲਈ ਉਸ 'ਤੇ Enter ਦਬਾਓ, ਫਿਰ ਕਾਰਡ ਨੂੰ ਉੱਥੇ ਰੱਖਣ ਲਈ ਕਾਰਡ 'ਤੇ Enter ਦਬਾਓ"

        Pl ->
            "Naciśnij Enter na polu upuszczania, aby je wybrać, a następnie Enter na karcie, aby ją tam umieścić"

        Pt ->
            "Pressione Enter em uma área de soltar para selecioná-la e, em seguida, Enter em um cartão para colocá-lo nela"

        Ro ->
            "Apasă Enter pe o zonă de plasare pentru a o selecta, apoi Enter pe un card pentru a-l plasa acolo"

        Ru ->
            "Нажмите Enter на области размещения, чтобы выбрать её, затем Enter на карточке, чтобы поместить её туда"

        Sk ->
            "Stlačením Enter vyber cieľové pole, potom stlačením Enter na karte ju tam vlož"

        Sl ->
            "Pritisni Enter na ciljnem polju, da ga izbereš, nato Enter na kartici, da jo postaviš tja"

        Sq ->
            "Shtyp Enter mbi një zonë lëshimi për ta zgjedhur, pastaj Enter mbi një kartë për ta vendosur atje"

        Sv ->
            "Tryck Enter på en släppyta för att välja den och sedan Enter på ett kort för att placera det där"

        Sw ->
            "Bonyeza Enter kwenye eneo la kudondoshea ili kulichagua, kisha Enter kwenye kadi ili kuiweka hapo"

        Tr ->
            "Seçmek için bir bırakma alanında Enter'a, ardından oraya yerleştirmek için bir kartta Enter'a basın"

        Tw ->
            "在放置區按 Enter 以選取，再在卡片上按 Enter 將其放到該處"

        Uk ->
            "Натисніть Enter на зоні розміщення, щоб вибрати її, потім Enter на картці, щоб розмістити її там"

        Ur ->
            "منتخب کرنے کے لیے کسی ڈراپ زون پر Enter دبائیں، پھر کسی کارڈ پر Enter دبا کر اسے وہاں رکھیں"

        Zh ->
            "在放置区上按 Enter 键将其选中，然后在卡片上按 Enter 键将卡片放到那里"

        _ ->
            "Press Enter on a drop zone to select it, then Enter on a card to place it there"


quizLabelCheck : Lang -> String
quizLabelCheck lang =
    case lang of
        Am ->
            "መልሱን አረጋግጥ። መልሱ ትክክል ወይም ስህተት ተብሎ ምልክት ይደረግበታል።"

        Ar ->
            "تحقق من الإجابة. سيتم وضع علامة على الإجابة بأنها صحيحة أو غير صحيحة."

        Bg ->
            "Проверете отговора. Отговорът ще бъде маркиран като правилен или неправилен."

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
            "Comprueba la respuesta. Se marcará como correcta o incorrecta."

        Et ->
            "Kontrolli vastust. Vastus märgitakse õigeks või valeks."

        Eu ->
            "Egiaztatu erantzuna. Erantzuna zuzen edo oker gisa markatuko da."

        Fa ->
            "پاسخ را بررسی کنید. پاسخ به‌عنوان درست یا نادرست علامت‌گذاری می‌شود."

        Fi ->
            "Tarkista vastaus. Vastaus merkitään oikeaksi tai vääräksi."

        Fr ->
            "Vérifiez la réponse. La réponse sera marquée comme correcte ou incorrecte."

        Ga ->
            "Seiceáil an freagra. Marcálfar an freagra mar cheart nó mícheart."

        Hi ->
            "उत्तर की जाँच करें। उत्तर को सही या गलत के रूप में चिह्नित किया जाएगा।"

        Hr ->
            "Provjeri odgovor. Odgovor će biti označen kao točan ili netočan."

        Hu ->
            "A válasz ellenőrzése. A válasz helyesnek vagy helytelennek lesz jelölve."

        Hy ->
            "Ստուգեք պատասխանը։ Այն կնշվի որպես ճիշտ կամ սխալ։"

        It ->
            "Controlla la risposta. La risposta è indicata come corretta o errata."

        Ja ->
            "答えを確認してください。回答は正解または不正解でマークされます。"

        Ka ->
            "შეამოწმეთ პასუხი. პასუხი მოინიშნება როგორც სწორი ან არასწორი."

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
            "ਜਵਾਬ ਦੀ ਜਾਂਚ ਕਰੋ। ਜਵਾਬ ਨੂੰ ਸਹੀ ਜਾਂ ਗਲਤ ਵਜੋਂ ਨਿਸ਼ਾਨਬੱਧ ਕੀਤਾ ਜਾਵੇਗਾ।"

        Pl ->
            "Sprawdź odpowiedź. Odpowiedź zostanie oznaczona jako poprawna lub niepoprawna."

        Pt ->
            "Verifique a resposta. A resposta será marcada como correta ou incorreta."

        Ro ->
            "Verifică răspunsul. Răspunsul va fi marcat drept corect sau incorect."

        Ru ->
            "Проверьте ответ. Ответ будет отмечен как правильный или неправильный."

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
            "檢查答案。答案將被標記為正確或錯誤。"

        Uk ->
            "Перевірте відповідь. Відповідь буде позначено як правильну чи неправильну."

        Ur ->
            "جواب چیک کریں۔ جواب کو درست یا غلط کے طور پر نشان زد کیا جائے گا۔"

        Zh ->
            "检查答案。答案将被标记为正确或错误。"

        _ ->
            "Check the answer. The response will be marked as correct or incorrect."


quizLabelSolution : Lang -> String
quizLabelSolution lang =
    case lang of
        Am ->
            "መፍትሔውን አሳይ። ጥያቄው እንደተፈታ ምልክት ይደረግበታል።"

        Ar ->
            "اعرض الحل. سيتم وضع علامة على الاختبار بأنه محلول."

        Bg ->
            "Покажете решението. Тестът ще бъде отбелязан като решен."

        Bn ->
            "সমাধান প্রদর্শন করুন। কুইজটি সমাধানকৃত হিসাবে চিহ্নিত করা হবে।"

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
            "Muestra la solución. El cuestionario se marcará como resuelto."

        Et ->
            "Näita lahendust. Ülesanne märgitakse lahendatuks."

        Eu ->
            "Erakutsi ebazpena. Ariketa ebatzita dagoela markatuko da."

        Fa ->
            "راه‌حل را نشان دهید. آزمون به‌عنوان حل‌شده علامت‌گذاری می‌شود."

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
            "Ցույց տվեք լուծումը։ Առաջադրանքը կնշվի որպես լուծված։"

        It ->
            "Mostra la soluzione. Il quiz verrà contrassegnato come risolto."

        Ja ->
            "解答を表示します。クイズは解決済みとマークされます。"

        Ka ->
            "ამოხსნის ჩვენება. ქვიზი მოინიშნება როგორც ამოხსნილი."

        Ko ->
            "정답을 보여 줍니다. 퀴즈가 해결된 것으로 표시됩니다."

        Lt ->
            "Parodyti sprendimą. Užduotis bus pažymėta kaip išspręsta."

        Lv ->
            "Parādīt risinājumu. Uzdevums tiks atzīmēts kā atrisināts."

        Nb ->
            "Vis løsningen. Oppgaven markeres som løst."

        Nl ->
            "Laat de oplossing zien. De quiz wordt gemarkeerd als opgelost."

        Pa ->
            "ਹੱਲ ਦਿਖਾਓ। ਕਵਿਜ਼ ਨੂੰ ਹੱਲ ਕੀਤਾ ਵਜੋਂ ਨਿਸ਼ਾਨਬੱਧ ਕੀਤਾ ਜਾਵੇਗਾ।"

        Pl ->
            "Pokaż rozwiązanie. Zadanie zostanie oznaczone jako rozwiązane."

        Pt ->
            "Mostrar a solução. O quiz será marcado como resolvido."

        Ro ->
            "Arată soluția. Exercițiul va fi marcat ca rezolvat."

        Ru ->
            "Показать решение. Задание будет отмечено как решённое."

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
            "顯示解答。測驗將被標記為已解答。"

        Uk ->
            "Покажіть розв’язок. Вікторину буде позначено як розв’язану."

        Ur ->
            "حل دکھائیں۔ کوئز کو حل شدہ کے طور پر نشان زد کیا جائے گا۔"

        Zh ->
            "显示解答。测验将被标记为已解答。"

        _ ->
            "Show the solution. The quiz will be marked as resolved."


quizAnswerSuccess : Lang -> String
quizAnswerSuccess lang =
    case lang of
        Am ->
            "እንኳን ደስ አለዎት፣ ይህ ትክክለኛው መልስ ነው"

        Ar ->
            "مبروك، هذه كانت الإجابة الصحيحة"

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
            "تبریک می‌گویم، پاسخ درست بود"

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
            "축하합니다. 정답입니다"

        Lt ->
            "Sveikiname, tai buvo teisingas atsakymas"

        Lv ->
            "Apsveicam, tā bija pareizā atbilde"

        Nb ->
            "Gratulerer, det var riktig svar"

        Nl ->
            "Gefeliciteerd, dat was het juiste antwoord"

        Pa ->
            "ਵਧਾਈ ਹੋ, ਇਹ ਸਹੀ ਜਵਾਬ ਸੀ।"

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
            "恭喜，這是正確答案"

        Uk ->
            "Вітаю, це була правильна відповідь"

        Ur ->
            "مبارک ہو، یہ درست جواب تھا"

        Zh ->
            "恭喜，这是正确答案"

        _ ->
            "Congratulations, that was the right answer"


quizAnswerError : Lang -> String
quizAnswerError lang =
    case lang of
        Am ->
            "ትክክለኛው መልስ ገና አልተሰጠም"

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
            "پاسخ درست هنوز داده نشده است"

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
            "まだ正解ではありません"

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
            "尚未给出正确答案"

        _ ->
            "The correct answer has not yet been given"


quizAnswerResolved : Lang -> String
quizAnswerResolved lang =
    case lang of
        Am ->
            "የተፈታ መልስ"

        Ar ->
            "إجابة تم حلها"

        Bg ->
            "Решен отговор"

        Bn ->
            "সমাধানকৃত উত্তর"

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
            "हल किया गया उत्तर"

        Hr ->
            "Otkriveni odgovor"

        Hu ->
            "Felfedett válasz"

        Hy ->
            "Լուծված պատասխան"

        It ->
            "Risposta rivelata"

        Ja ->
            "解決済みの回答"

        Ka ->
            "ამოხსნილი პასუხი"

        Ko ->
            "정답 공개됨"

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
            "Resposta revelada"

        Ro ->
            "Răspuns dezvăluit"

        Ru ->
            "Раскрытый ответ"

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
            "已顯示解答"

        Uk ->
            "Вирішена відповідь"

        Ur ->
            "حل شدہ جواب"

        Zh ->
            "已显示解答"

        _ ->
            "Resolved answer"


surveySubmit : Lang -> String
surveySubmit lang =
    case lang of
        Am ->
            "ላክ"

        Ar ->
            "إرسال"

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
            "Ուղարկել"

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
            "ਜਮ੍ਹਾਂ ਕਰੋ"

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
            "提交"

        Uk ->
            "Надіслати"

        Ur ->
            "جمع کریں"

        Zh ->
            "提交"

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
            "پیش از ارسال باید به همهٔ ردیف‌ها پاسخ داده شود."

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
            "ጽሑፍ ያስገቡ..."

        Ar ->
            "أدخل نصًا..."

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
            "Մուտքագրեք տեքստ..."

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
            "Введення тексту ..."

        Ur ->
            "کچھ متن درج کریں..."

        Zh ->
            "请输入文本……"

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
            "به‌روزرسانی"

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
            "ሽቅብ ደርድር"

        Ar ->
            "ترتيب تصاعدي"

        Bg ->
            "сортиране във възходящ ред"

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

        Fa ->
            "مرتب‌سازی صعودی"

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

        Hy ->
            "դասավորել աճման կարգով"

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
            "ਵਧਦੇ ਕ੍ਰਮ ਵਿੱਚ ਕ੍ਰਮਬੱਧ ਕਰੋ"

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
            "panga kwa kupanda"

        Tr ->
            "artan sırada sırala"

        Tw ->
            "遞增排序"

        Uk ->
            "сортувати за зростанням"

        Ur ->
            "صعودی ترتیب"

        Zh ->
            "升序排序"

        _ ->
            "sort ascending"


sortDesc : Lang -> String
sortDesc lang =
    case lang of
        Am ->
            "ቁልቁል ደርድር"

        Ar ->
            "ترتيب تنازلي"

        Bg ->
            "сортиране в низходящ ред"

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
            "orden descendente"

        Et ->
            "sorteeri kahanevalt"

        Eu ->
            "ordenatu beherantz"

        Fa ->
            "مرتب‌سازی نزولی"

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

        Hy ->
            "դասավորել նվազման կարգով"

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
            "aflopend sorteren"

        Pa ->
            "ਘਟਦੇ ਕ੍ਰਮ ਵਿੱਚ ਕ੍ਰਮਬੱਧ ਕਰੋ"

        Pl ->
            "sortuj malejąco"

        Pt ->
            "ordenar em ordem decrescente"

        Ro ->
            "sortează descrescător"

        Ru ->
            "сортировать по убыванию"

        Sk ->
            "zoradiť zostupne"

        Sl ->
            "razvrsti padajoče"

        Sq ->
            "rendit në zbritje"

        Sv ->
            "sortera fallande"

        Sw ->
            "panga kwa kushuka"

        Tr ->
            "azalan sırada sırala"

        Tw ->
            "遞減排序"

        Uk ->
            "сортувати за спаданням"

        Ur ->
            "نزولی ترتیب"

        Zh ->
            "降序排序"

        _ ->
            "sort descending"


sortNot : Lang -> String
sortNot lang =
    case lang of
        Am ->
            "ያልተደረደረ"

        Ar ->
            "غير مرتب"

        Bg ->
            "несортирано"

        Bn ->
            "সাজানো নয়"

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

        Fa ->
            "مرتب‌نشده"

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

        Hy ->
            "դասավորված չէ"

        It ->
            "non ordinato"

        Ja ->
            "並べ替えなし"

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
            "ਕ੍ਰਮਬੱਧ ਨਹੀਂ"

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

        Tw ->
            "未排序"

        Uk ->
            "не відсортовано"

        Ur ->
            "ترتیب نہیں دی گئی"

        Zh ->
            "未排序"

        _ ->
            "not sorted"


chartDefault : Lang -> String
chartDefault lang =
    case lang of
        Am ->
            "ገበታ"

        Ar ->
            "مخطط"

        Bg ->
            "Диаграма"

        Bn ->
            "চার্ট"

        Ca ->
            "Gràfic"

        Cs ->
            "Graf"

        Da ->
            "Diagram"

        De ->
            "Diagramm"

        El ->
            "Διάγραμμα"

        Es ->
            "Gráfico"

        Et ->
            "Diagramm"

        Eu ->
            "Diagrama"

        Fa ->
            "نمودار"

        Fi ->
            "Kaavio"

        Fr ->
            "Graphique"

        Ga ->
            "Cairt"

        Hi ->
            "चार्ट"

        Hr ->
            "Grafikon"

        Hu ->
            "Diagram"

        Hy ->
            "Գծապատկեր"

        It ->
            "Grafico"

        Ja ->
            "グラフ"

        Ka ->
            "დიაგრამა"

        Ko ->
            "차트"

        Lt ->
            "Diagrama"

        Lv ->
            "Diagramma"

        Nb ->
            "Diagram"

        Nl ->
            "Grafiek"

        Pa ->
            "ਚਾਰਟ"

        Pl ->
            "Wykres"

        Pt ->
            "Gráfico"

        Ro ->
            "Diagramă"

        Ru ->
            "Диаграмма"

        Sk ->
            "Graf"

        Sl ->
            "Grafikon"

        Sq ->
            "Diagram"

        Sv ->
            "Diagram"

        Sw ->
            "Chati"

        Tr ->
            "Grafik"

        Tw ->
            "圖表"

        Uk ->
            "Діаграма"

        Ur ->
            "چارٹ"

        Zh ->
            "图表"

        _ ->
            "Chart"


chartTable : Lang -> String
chartTable lang =
    case lang of
        Am ->
            "ሰንጠረዥ"

        Ar ->
            "جدول"

        Bg ->
            "Таблица"

        Bn ->
            "টেবিল"

        Ca ->
            "Taula"

        Cs ->
            "Tabulka"

        Da ->
            "Tabel"

        De ->
            "Tabelle"

        El ->
            "Πίνακας"

        Es ->
            "Tabla"

        Et ->
            "Tabel"

        Eu ->
            "Taula"

        Fa ->
            "جدول"

        Fi ->
            "Taulukko"

        Fr ->
            "Tableau"

        Ga ->
            "Tábla"

        Hi ->
            "तालिका"

        Hr ->
            "Tablica"

        Hu ->
            "Táblázat"

        Hy ->
            "Աղյուսակ"

        It ->
            "Tabella"

        Ja ->
            "表"

        Ka ->
            "ცხრილი"

        Ko ->
            "표"

        Lt ->
            "Lentelė"

        Lv ->
            "Tabula"

        Nb ->
            "Tabell"

        Nl ->
            "Tabel"

        Pa ->
            "ਸਾਰਣੀ"

        Pl ->
            "Tabela"

        Pt ->
            "Tabela"

        Ro ->
            "Tabel"

        Ru ->
            "Таблица"

        Sk ->
            "Tabuľka"

        Sl ->
            "Tabela"

        Sq ->
            "Tabela"

        Sv ->
            "Tabell"

        Sw ->
            "Jedwali"

        Tr ->
            "Tablo"

        Tw ->
            "表格"

        Uk ->
            "Таблиця"

        Ur ->
            "جدول"

        Zh ->
            "表格"

        _ ->
            "Table"


chartPie : Lang -> String
chartPie lang =
    case lang of
        Am ->
            "የፓይ ገበታ"

        Ar ->
            "مخطط دائري"

        Bg ->
            "Кръгова диаграма"

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

        Es ->
            "Gráfico circular"

        Et ->
            "Sektordiagramm"

        Eu ->
            "Sektore-diagrama"

        Fa ->
            "نمودار دایره‌ای"

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

        Hy ->
            "Շրջանաձև գծապատկեր"

        It ->
            "Diagramma a torta"

        Ja ->
            "円グラフ"

        Ka ->
            "წრიული დიაგრამა"

        Ko ->
            "파이 차트"

        Lt ->
            "Skritulinė diagrama"

        Lv ->
            "Sektoru diagramma"

        Nb ->
            "Sektordiagram"

        Nl ->
            "Cirkeldiagram"

        Pa ->
            "ਪਾਈ ਚਾਰਟ"

        Pl ->
            "Wykres kołowy"

        Pt ->
            "Gráfico de pizza"

        Ro ->
            "Diagramă circulară"

        Ru ->
            "Круговая диаграмма"

        Sk ->
            "Koláčový graf"

        Sl ->
            "Tortni grafikon"

        Sq ->
            "Diagram rrethor"

        Sv ->
            "Cirkeldiagram"

        Sw ->
            "Chati ya pai"

        Tr ->
            "Pasta grafiği"

        Tw ->
            "圓餅圖"

        Uk ->
            "Кругова діаграма"

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
            "የአሞሌ ገበታ"

        Ar ->
            "مخطط شريطي"

        Bg ->
            "Стълбовидна диаграма"

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

        Es ->
            "Gráfico de barras"

        Et ->
            "Tulpdiagramm"

        Eu ->
            "Barra-diagrama"

        Fa ->
            "نمودار میله‌ای"

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

        Hy ->
            "Սյունակային գծապատկեր"

        It ->
            "Diagramma a barre"

        Ja ->
            "棒グラフ"

        Ka ->
            "სვეტოვანი დიაგრამა"

        Ko ->
            "막대 차트"

        Lt ->
            "Stulpelinė diagrama"

        Lv ->
            "Stabiņu diagramma"

        Nb ->
            "Stolpediagram"

        Nl ->
            "Staafdiagram"

        Pa ->
            "ਬਾਰ ਚਾਰਟ"

        Pl ->
            "Wykres słupkowy"

        Pt ->
            "Gráfico de barras"

        Ro ->
            "Diagramă cu bare"

        Ru ->
            "Столбчатая диаграмма"

        Sk ->
            "Stĺpcový graf"

        Sl ->
            "Stolpčni grafikon"

        Sq ->
            "Diagram me shtylla"

        Sv ->
            "Stapeldiagram"

        Sw ->
            "Chati ya pau"

        Tr ->
            "Çubuk grafiği"

        Tw ->
            "長條圖"

        Uk ->
            "Стовпчикова діаграма"

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
            "የመስመር ገበታ"

        Ar ->
            "مخطط خطي"

        Bg ->
            "Линейна диаграма"

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

        Es ->
            "Gráfico de líneas"

        Et ->
            "Joondiagramm"

        Eu ->
            "Lerro-diagrama"

        Fa ->
            "نمودار خطی"

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

        Hy ->
            "Գծային գծապատկեր"

        It ->
            "Diagramma a linee"

        Ja ->
            "折れ線グラフ"

        Ka ->
            "ხაზოვანი დიაგრამა"

        Ko ->
            "라인 차트"

        Lt ->
            "Linijinė diagrama"

        Lv ->
            "Līniju diagramma"

        Nb ->
            "Linjediagram"

        Nl ->
            "Lijndiagram"

        Pa ->
            "ਰੇਖਾ ਚਾਰਟ"

        Pl ->
            "Wykres liniowy"

        Pt ->
            "Gráfico de linhas"

        Ro ->
            "Diagramă liniară"

        Ru ->
            "Линейная диаграмма"

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
            "折線圖"

        Uk ->
            "Лінійна діаграма"

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
            "የብተና ገበታ"

        Ar ->
            "مخطط مبعثر"

        Bg ->
            "Точкова диаграма"

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

        Es ->
            "Diagrama de dispersión"

        Et ->
            "Hajuvusdiagramm"

        Eu ->
            "Sakabanatze-diagrama"

        Fa ->
            "نمودار پراکندگی"

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

        Hy ->
            "Ցրման գծապատկեր"

        It ->
            "Diagramma a dispersione"

        Ja ->
            "散布図"

        Ka ->
            "წერტილოვანი დიაგრამა"

        Ko ->
            "산점도"

        Lt ->
            "Sklaidos diagrama"

        Lv ->
            "Izkliedes diagramma"

        Nb ->
            "Spredningsdiagram"

        Nl ->
            "Spreidingsdiagram"

        Pa ->
            "ਸਕੈਟਰ ਪਲਾਟ"

        Pl ->
            "Wykres punktowy"

        Pt ->
            "Gráfico de dispersão"

        Ro ->
            "Diagramă de dispersie"

        Ru ->
            "Точечная диаграмма"

        Sk ->
            "Bodový graf"

        Sl ->
            "Raztreseni grafikon"

        Sq ->
            "Diagram shpërndarjeje"

        Sv ->
            "Spridningsdiagram"

        Sw ->
            "Chati ya mtawanyiko"

        Tr ->
            "Dağılım grafiği"

        Tw ->
            "散佈圖"

        Uk ->
            "Точкова діаграма"

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
            "የራዳር ገበታ"

        Ar ->
            "مخطط نسيجي"

        Bg ->
            "Радарна диаграма"

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

        Es ->
            "Gráfico de radar"

        Et ->
            "Radardiagramm"

        Eu ->
            "Radar-diagrama"

        Fa ->
            "نمودار راداری"

        Fi ->
            "Tutkakaavio"

        Fr ->
            "Graphique en radar"

        Ga ->
            "Cairt radair"

        Hi ->
            "रडार चार्ट"

        Hr ->
            "Radarski grafikon"

        Hu ->
            "Sugárdiagram"

        Hy ->
            "Ռադարային գծապատկեր"

        It ->
            "Diagramma Radar"

        Ja ->
            "レーダーチャート"

        Ka ->
            "რადარული დიაგრამა"

        Ko ->
            "레이더 차트"

        Lt ->
            "Radarinė diagrama"

        Lv ->
            "Radara diagramma"

        Nb ->
            "Radardiagram"

        Nl ->
            "Radardiagram"

        Pa ->
            "ਰਾਡਾਰ ਚਾਰਟ"

        Pl ->
            "Wykres radarowy"

        Pt ->
            "Gráfico de radar"

        Ro ->
            "Diagramă radar"

        Ru ->
            "Лепестковая диаграмма"

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
            "雷達圖"

        Uk ->
            "Радарна діаграма"

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
            "የሳጥን ገበታ"

        Ar ->
            "مخطط صندوقي"

        Bg ->
            "Диаграма „кутия с мустаци“"

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

        Es ->
            "Diagrama de caja"

        Et ->
            "Karpdiagramm"

        Eu ->
            "Kutxa-diagrama"

        Fa ->
            "نمودار جعبه‌ای"

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

        Hy ->
            "Արկղային գծապատկեր"

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

        Nl ->
            "Boxplot"

        Pa ->
            "ਬਾਕਸਪਲਾਟ"

        Pl ->
            "Wykres pudełkowy"

        Pt ->
            "Diagrama de caixa"

        Ro ->
            "Diagramă cutie"

        Ru ->
            "Диаграмма размаха"

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
            "箱形圖"

        Uk ->
            "Діаграма розмаху"

        Ur ->
            "باکس پلاٹ"

        Zh ->
            "箱线图"

        _ ->
            "Boxplot"


chartHeatmap : Lang -> String
chartHeatmap lang =
    case lang of
        Am ->
            "የሙቀት ካርታ"

        Ar ->
            "خريطة التمثيل اللوني"

        Bg ->
            "Топлинна карта"

        Bn ->
            "হিটম্যাপ"

        Ca ->
            "Mapa de calor"

        Cs ->
            "Tepelná mapa"

        Da ->
            "Varmekort"

        De ->
            "Heatmap"

        El ->
            "Θερμικός χάρτης"

        Es ->
            "Mapa de calor"

        Et ->
            "Soojuskaart"

        Eu ->
            "Bero-mapa"

        Fa ->
            "نقشهٔ حرارتی"

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

        Hy ->
            "Ջերմային քարտեզ"

        It ->
            "Mappa termica"

        Ja ->
            "ヒートマップ"

        Ka ->
            "სითბური რუქა"

        Ko ->
            "히트 맵"

        Lt ->
            "Šilumos žemėlapis"

        Lv ->
            "Siltuma karte"

        Nb ->
            "Varmekart"

        Nl ->
            "Heatmap"

        Pa ->
            "ਹੀਟਮੈਪ"

        Pl ->
            "Mapa cieplna"

        Pt ->
            "Mapa de calor"

        Ro ->
            "Hartă termică"

        Ru ->
            "Тепловая карта"

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
            "熱度圖"

        Uk ->
            "Теплова карта"

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

        Bg ->
            "Карта"

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

        Es ->
            "Mapa"

        Et ->
            "Kaart"

        Eu ->
            "Mapa"

        Fa ->
            "نقشه"

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

        Hy ->
            "Քարտեզ"

        It ->
            "Mappa"

        Ja ->
            "地図"

        Ka ->
            "რუქა"

        Ko ->
            "지도"

        Lt ->
            "Žemėlapis"

        Lv ->
            "Karte"

        Nb ->
            "Kart"

        Nl ->
            "Kaart"

        Pa ->
            "ਨਕਸ਼ਾ"

        Pl ->
            "Mapa"

        Pt ->
            "Mapa"

        Ro ->
            "Hartă"

        Ru ->
            "Карта"

        Sk ->
            "Mapa"

        Sl ->
            "Zemljevid"

        Sq ->
            "Hartë"

        Sv ->
            "Karta"

        Sw ->
            "Ramani"

        Tr ->
            "Harita"

        Tw ->
            "地圖"

        Uk ->
            "Карта"

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
            "የትይዩ መጋጠሚያዎች ገበታ"

        Ar ->
            "مخطط الإحداثيات المتوازية"

        Bg ->
            "Диаграма с паралелни координати"

        Bn ->
            "প্যারালেল কোঅর্ডিনেট ম্যাপ"

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

        Es ->
            "Gráfico de coordenadas paralelas"

        Et ->
            "Paralleelkoordinaatide diagramm"

        Eu ->
            "Koordenatu paraleloen diagrama"

        Fa ->
            "نمودار مختصات موازی"

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

        Hy ->
            "Զուգահեռ կոորդինատների գծապատկեր"

        It ->
            "Mappa a coordinate parallele"

        Ja ->
            "パラレル座標マップ"

        Ka ->
            "პარალელური კოორდინატების რუქა"

        Ko ->
            "평행 좌표 그래프"

        Lt ->
            "Lygiagrečių koordinačių diagrama"

        Lv ->
            "Paralēlo koordinātu diagramma"

        Nb ->
            "Diagram med parallelle koordinater"

        Nl ->
            "Diagram met parallelle coördinaten"

        Pa ->
            "ਸਮਾਂਤਰ ਕੋਆਰਡੀਨੇਟ ਚਾਰਟ"

        Pl ->
            "Wykres współrzędnych równoległych"

        Pt ->
            "Mapa de coordenadas paralelas"

        Ro ->
            "Diagramă cu coordonate paralele"

        Ru ->
            "Диаграмма параллельных координат"

        Sk ->
            "Graf paralelných súradníc"

        Sl ->
            "Grafikon vzporednih koordinat"

        Sq ->
            "Diagram me koordinata paralele"

        Sv ->
            "Diagram med parallella koordinater"

        Sw ->
            "Chati ya viwianishi sambamba"

        Tr ->
            "Paralel koordinat grafiği"

        Tw ->
            "平行座標圖"

        Uk ->
            "Діаграма паралельних координат"

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
            "የመስመሮች ገበታ"

        Ar ->
            "رسم بياني خطي"

        Bg ->
            "Линейна графика"

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

        Es ->
            "Gráfico lineal"

        Et ->
            "Joongraafik"

        Eu ->
            "Lerro-grafikoa"

        Fa ->
            "گراف خطی"

        Fi ->
            "Viivakuvaaja"

        Fr ->
            "Graphe linéaire"

        Ga ->
            "Líneghraf"

        Hi ->
            "लाइन ग्राफ"

        Hr ->
            "Linijski graf"

        Hu ->
            "Vonalgrafikon"

        Hy ->
            "Գծային գրաֆիկ"

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

        Nl ->
            "Lijngrafiek"

        Pa ->
            "ਰੇਖਾ ਗ੍ਰਾਫ਼"

        Pl ->
            "Wykres liniowy"

        Pt ->
            "Gráfico de linhas"

        Ro ->
            "Grafic liniar"

        Ru ->
            "Линейный график"

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
            "線圖"

        Uk ->
            "Лінійний графік"

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
            "የግንኙነት ገበታ"

        Ar ->
            "مخطط العلاقات"

        Bg ->
            "Граф на връзките"

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

        Es ->
            "Grafo de relaciones"

        Et ->
            "Seoste graaf"

        Eu ->
            "Erlazio-grafoa"

        Fa ->
            "گراف روابط"

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

        Hy ->
            "Կապերի գրաֆ"

        It ->
            "Grafico delle relazioni"

        Ja ->
            "関係グラフ"

        Ka ->
            "კავშირების გრაფი"

        Ko ->
            "관계도"

        Lt ->
            "Ryšių grafas"

        Lv ->
            "Saistību grafs"

        Nb ->
            "Relasjonsgraf"

        Nl ->
            "Relatiegrafiek"

        Pa ->
            "ਸੰਬੰਧ ਗ੍ਰਾਫ਼"

        Pl ->
            "Graf relacji"

        Pt ->
            "Gráfico de relacionamento"

        Ro ->
            "Graf de relații"

        Ru ->
            "Граф связей"

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
            "關係圖"

        Uk ->
            "Граф зв'язків"

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
            "የሳንኪ ገበታ"

        Ar ->
            "مخطط سانكي"

        Bg ->
            "Диаграма на Санки"

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

        Es ->
            "Diagrama de Sankey"

        Et ->
            "Sankey diagramm"

        Eu ->
            "Sankey diagrama"

        Fa ->
            "نمودار سنکی"

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

        Hy ->
            "Սանկիի դիագրամ"

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

        Nl ->
            "Sankeydiagram"

        Pa ->
            "ਸੈਂਕੀ ਡਾਇਗ੍ਰਾਮ"

        Pl ->
            "Diagram Sankeya"

        Pt ->
            "Diagrama de Sankey"

        Ro ->
            "Diagramă Sankey"

        Ru ->
            "Диаграмма Санкея"

        Sk ->
            "Sankeyho diagram"

        Sl ->
            "Sankeyjev diagram"

        Sq ->
            "Diagram Sankey"

        Sv ->
            "Sankeydiagram"

        Sw ->
            "Mchoro wa Sankey"

        Tr ->
            "Sankey diyagramı"

        Tw ->
            "桑基圖"

        Uk ->
            "Діаграма Санкі"

        Ur ->
            "سینکی ڈایاگرام"

        Zh ->
            "桑基图"

        _ ->
            "Sankey diagram"


chartFunnel : Lang -> String
chartFunnel lang =
    case lang of
        Am ->
            "የማንቆርቆሪያ ገበታ"

        Ar ->
            "مخطط قمعي"

        Bg ->
            "Фунийна диаграма"

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

        Es ->
            "Gráfico de embudo"

        Et ->
            "Lehterdiagramm"

        Eu ->
            "Inbutu-diagrama"

        Fa ->
            "نمودار قیفی"

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

        Hy ->
            "Ձագարաձև գծապատկեր"

        It ->
            "Grafico a imbuto"

        Ja ->
            "ファネルチャート"

        Ka ->
            "ძაბრისებრი დიაგრამა"

        Ko ->
            "퍼널 차트"

        Lt ->
            "Piltuvėlio diagrama"

        Lv ->
            "Piltuves diagramma"

        Nb ->
            "Traktdiagram"

        Nl ->
            "Trechterdiagram"

        Pa ->
            "ਫਨਲ ਚਾਰਟ"

        Pl ->
            "Wykres lejkowy"

        Pt ->
            "Gráfico de funil"

        Ro ->
            "Diagramă pâlnie"

        Ru ->
            "Диаграмма-воронка"

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
            "漏斗圖"

        Uk ->
            "Воронкова діаграма"

        Ur ->
            "فنل چارٹ"

        Zh ->
            "漏斗图"

        _ ->
            "Funnel chart"


chartWordcloud : Lang -> String
chartWordcloud lang =
    case lang of
        Am ->
            "የቃላት ደመና"

        Ar ->
            "سحابة كلمات"

        Bg ->
            "Облак от думи"

        Bn ->
            "ওয়ার্ড ক্লাউড"

        Ca ->
            "Núvol de paraules"

        Cs ->
            "Slovní mrak"

        Da ->
            "Ordsky"

        De ->
            "Wortwolke"

        El ->
            "Σύννεφο λέξεων"

        Es ->
            "Nube de palabras"

        Et ->
            "Sõnapilv"

        Eu ->
            "Hitz-hodeia"

        Fa ->
            "ابر واژگان"

        Fi ->
            "Sanapilvi"

        Fr ->
            "Nuage de mots"

        Ga ->
            "Scamall focal"

        Hi ->
            "वर्ड क्लाउड"

        Hr ->
            "Oblak riječi"

        Hu ->
            "Szófelhő"

        Hy ->
            "Բառերի ամպ"

        It ->
            "Nuvola di parole"

        Ja ->
            "ワードクラウド"

        Ka ->
            "სიტყვების ღრუბელი"

        Ko ->
            "워드 클라우드"

        Lt ->
            "Žodžių debesis"

        Lv ->
            "Vārdu mākonis"

        Nb ->
            "Ordsky"

        Nl ->
            "Woordwolk"

        Pa ->
            "ਸ਼ਬਦ ਬੱਦਲ"

        Pl ->
            "Chmura słów"

        Pt ->
            "Nuvem de palavras"

        Ro ->
            "Nor de cuvinte"

        Ru ->
            "Облако слов"

        Sk ->
            "Oblak slov"

        Sl ->
            "Oblak besed"

        Sq ->
            "Re fjalësh"

        Sv ->
            "Ordmoln"

        Sw ->
            "Wingu la maneno"

        Tr ->
            "Kelime bulutu"

        Tw ->
            "文字雲"

        Uk ->
            "Хмара слів"

        Ur ->
            "ورڈ کلاؤڈ"

        Zh ->
            "词云"

        _ ->
            "Word cloud"


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
            "ਵੈੱਬਸਾਈਟ ਲਈ QR ਕੋਡ"

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
            "網站 QR 碼"

        Uk ->
            "QR-код для вебсайту"

        Ur ->
            "ویب سائٹ کے لیے QR کوڈ"

        Zh ->
            "网站二维码"

        _ ->
            "QR code for website"


qrEnlarge : Lang -> String
qrEnlarge lang =
    case lang of
        Am ->
            "QR ኮድ አስፋ"

        Ar ->
            "تكبير رمز الاستجابة السريعة"

        Bg ->
            "Увеличи QR кода"

        Bn ->
            "QR কোড বড় করুন"

        Ca ->
            "Amplia el codi QR"

        Cs ->
            "Zvětšit QR kód"

        Da ->
            "Forstør QR-kode"

        De ->
            "QR-Code vergrößern"

        El ->
            "Μεγέθυνση κωδικού QR"

        Es ->
            "Ampliar código QR"

        Et ->
            "Suurenda QR-koodi"

        Eu ->
            "Handitu QR kodea"

        Fa ->
            "بزرگ‌نمایی کد QR"

        Fi ->
            "Suurenna QR-koodi"

        Fr ->
            "Agrandir le code QR"

        Ga ->
            "Méadaigh an cód QR"

        Hi ->
            "क्यूआर कोड बड़ा करें"

        Hr ->
            "Povećaj QR kod"

        Hu ->
            "QR-kód nagyítása"

        Hy ->
            "Մեծացնել QR կոդը"

        It ->
            "Ingrandisci il codice QR"

        Ja ->
            "QR コードを拡大"

        Ka ->
            "QR კოდის გადიდება"

        Ko ->
            "QR 코드 확대"

        Lt ->
            "Padidinti QR kodą"

        Lv ->
            "Palielināt QR kodu"

        Nb ->
            "Forstørr QR-koden"

        Nl ->
            "QR-code vergroten"

        Pa ->
            "QR ਕੋਡ ਵੱਡਾ ਕਰੋ"

        Pl ->
            "Powiększ kod QR"

        Pt ->
            "Ampliar código QR"

        Ro ->
            "Mărește codul QR"

        Ru ->
            "Увеличить QR-код"

        Sk ->
            "Zväčšiť QR kód"

        Sl ->
            "Povečaj kodo QR"

        Sq ->
            "Zmadho kodin QR"

        Sv ->
            "Förstora QR-koden"

        Sw ->
            "Kuza msimbo wa QR"

        Tr ->
            "QR kodunu büyüt"

        Tw ->
            "放大 QR 碼"

        Uk ->
            "Збільшити QR-код"

        Ur ->
            "QR کوڈ بڑا کریں"

        Zh ->
            "放大二维码"

        _ ->
            "Enlarge QR code"


qrErr : Lang -> String
qrErr lang =
    case lang of
        Am ->
            "ወደ QR ኮድ በመቀየር ላይ ስህተት ተፈጥሯል"

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
            "QR ਕੋਡ ਨੂੰ ਏਨਕੋਡ ਕਰਨ ਦੌਰਾਨ ਗਲਤੀ ਆਈ ਹੈ"

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
            "編碼為 QR 碼時出錯"

        Uk ->
            "Помилка під час кодування в QR-код"

        Ur ->
            "QR کوڈ میں انکوڈ کرتے وقت خرابی"

        Zh ->
            "编码为二维码时出错"

        _ ->
            "Error while encoding to QR code"


chatMessage : Lang -> String
chatMessage lang =
    case lang of
        Am ->
            "የውይይት መልእክት"

        Ar ->
            "رسالة دردشة"

        Bg ->
            "Съобщение в чата"

        Bn ->
            "চ্যাট বার্তা"

        Ca ->
            "Missatge de xat"

        Cs ->
            "Zpráva do chatu"

        Da ->
            "Chatbesked"

        De ->
            "Chat-Nachricht"

        El ->
            "Μήνυμα συνομιλίας"

        Es ->
            "Mensaje de chat"

        Et ->
            "Vestlussõnum"

        Eu ->
            "Txat-mezua"

        Fa ->
            "پیام گفتگو"

        Fi ->
            "Keskusteluviesti"

        Fr ->
            "Message de chat"

        Ga ->
            "Teachtaireacht chomhrá"

        Hi ->
            "चैट संदेश"

        Hr ->
            "Poruka u razgovoru"

        Hu ->
            "Csevegőüzenet"

        Hy ->
            "Զրույցի հաղորդագրություն"

        It ->
            "Messaggio della chat"

        Ja ->
            "チャットメッセージ"

        Ka ->
            "ჩატის შეტყობინება"

        Ko ->
            "채팅 메시지"

        Lt ->
            "Pokalbio žinutė"

        Lv ->
            "Tērzēšanas ziņojums"

        Nb ->
            "Chatmelding"

        Nl ->
            "Chatbericht"

        Pa ->
            "ਚੈਟ ਸੁਨੇਹਾ"

        Pl ->
            "Wiadomość czatu"

        Pt ->
            "Mensagem de chat"

        Ro ->
            "Mesaj în conversație"

        Ru ->
            "Сообщение чата"

        Sk ->
            "Správa v čete"

        Sl ->
            "Sporočilo v klepetu"

        Sq ->
            "Mesazh bisede"

        Sv ->
            "Chattmeddelande"

        Sw ->
            "Ujumbe wa gumzo"

        Tr ->
            "Sohbet mesajı"

        Tw ->
            "聊天訊息"

        Uk ->
            "Повідомлення чату"

        Ur ->
            "چیٹ پیغام"

        Zh ->
            "聊天消息"

        _ ->
            "Chat message"


chatUnverified : Lang -> String
chatUnverified lang =
    case lang of
        Am ->
            "ያልተረጋገጠ ላኪ"

        Ar ->
            "مرسل غير موثّق"

        Bg ->
            "Непотвърден подател"

        Bn ->
            "অযাচাইকৃত প্রেরক"

        Ca ->
            "Remitent no verificat"

        Cs ->
            "Neověřený odesílatel"

        Da ->
            "Ubekræftet afsender"

        De ->
            "Unbestätigter Absender"

        El ->
            "Μη επαληθευμένος αποστολέας"

        Es ->
            "Remitente no verificado"

        Et ->
            "Kinnitamata saatja"

        Eu ->
            "Egiaztatu gabeko igorlea"

        Fa ->
            "فرستندهٔ تأییدنشده"

        Fi ->
            "Vahvistamaton lähettäjä"

        Fr ->
            "Expéditeur non vérifié"

        Ga ->
            "Seoltóir neamhfhíoraithe"

        Hi ->
            "असत्यापित प्रेषक"

        Hr ->
            "Neprovjereni pošiljatelj"

        Hu ->
            "Nem ellenőrzött feladó"

        Hy ->
            "Չհաստատված ուղարկող"

        It ->
            "Mittente non verificato"

        Ja ->
            "未確認の送信者"

        Ka ->
            "დაუდასტურებელი გამგზავნი"

        Ko ->
            "확인되지 않은 보낸 사람"

        Lt ->
            "Nepatvirtintas siuntėjas"

        Lv ->
            "Nepārbaudīts sūtītājs"

        Nb ->
            "Ubekreftet avsender"

        Nl ->
            "Niet-geverifieerde afzender"

        Pa ->
            "ਅਪ੍ਰਮਾਣਿਤ ਭੇਜਣ ਵਾਲਾ"

        Pl ->
            "Niezweryfikowany nadawca"

        Pt ->
            "Remetente não verificado"

        Ro ->
            "Expeditor neverificat"

        Ru ->
            "Неподтверждённый отправитель"

        Sk ->
            "Neoverený odosielateľ"

        Sl ->
            "Nepreverjen pošiljatelj"

        Sq ->
            "Dërgues i paverifikuar"

        Sv ->
            "Overifierad avsändare"

        Sw ->
            "Mtumaji asiyethibitishwa"

        Tr ->
            "Doğrulanmamış gönderen"

        Tw ->
            "未驗證的傳送者"

        Uk ->
            "Неперевірений відправник"

        Ur ->
            "غیر تصدیق شدہ بھیجنے والا"

        Zh ->
            "未验证的发送者"

        _ ->
            "Unverified sender"


chatOpen : Lang -> String
chatOpen lang =
    case lang of
        Am ->
            "ውይይት ክፈት"

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
            "Բացել զրույցը"

        It ->
            "Aprire la chat"

        Ja ->
            "チャットを開く"

        Ka ->
            "ჩატის გახსნა"

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
            "ውይይት ዝጋ"

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
            "Փակել զրույցը"

        It ->
            "Chiudere la chat"

        Ja ->
            "チャットを閉じる"

        Ka ->
            "ჩატის დახურვა"

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
            "ያልተነበቡ የውይይት መልእክቶች አሉዎት"

        Ar ->
            "لديك رسائل دردشة غير مقروءة"

        Bg ->
            "Имате непрочетени чат съобщения"

        Bn ->
            "আপনার অপঠিত চ্যাট বার্তা আছে"

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
            "پیام‌های گفتگوی خوانده‌نشده دارید"

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
            "Դուք ունեք չկարդացված հաղորդագրություններ զրույցում"

        It ->
            "Ci sono messaggi di chat non letti"

        Ja ->
            "未読のチャットメッセージがあります"

        Ka ->
            "გაქვთ წაუკითხავი ჩატის შეტყობინებები"

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
            "ਤੁਹਾਡੇ ਕੋਲ ਨਾ-ਪੜ੍ਹੇ ਚੈਟ ਸੁਨੇਹੇ ਹਨ"

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
            "Una ujumbe wa gumzo ambao haujasomwa"

        Tr ->
            "Okunmamış sohbet mesajlarınız var"

        Tw ->
            "您有未讀的聊天訊息"

        Uk ->
            "У вас є непрочитані повідомлення в чаті"

        Ur ->
            "آپ کے پاس ان پڑھے چیٹ پیغامات ہیں"

        Zh ->
            "您有未读的聊天消息"

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
            "Ուղարկել հաղորդագրությունը"

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

