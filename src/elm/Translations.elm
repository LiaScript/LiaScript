module Translations exposing (..)

{-| This file was automatically generated with elm-i18n-gen.
For more in information visit:

<https://github.com/ChristophP/elm-i18n-module-generator>

-}


type Lang
    = Am
    | Ar
    | Bg
    | Bn
    | De
    | Es
    | Fa
    | Fr
    | Hi
    | Hy
    | It
    | Ja
    | Ko
    | Nl
    | Pa
    | Pt
    | Ru
    | Sw
    | Tw
    | Uk
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

        "de" ->
            Just De

        "es" ->
            Just Es

        "fa" ->
            Just Fa

        "fr" ->
            Just Fr

        "hi" ->
            Just Hi

        "hy" ->
            Just Hy

        "it" ->
            Just It

        "ja" ->
            Just Ja

        "ko" ->
            Just Ko

        "nl" ->
            Just Nl

        "pa" ->
            Just Pa

        "pt" ->
            Just Pt

        "ru" ->
            Just Ru

        "sw" ->
            Just Sw

        "tw" ->
            Just Tw

        "uk" ->
            Just Uk

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

        De ->
            "de"

        Es ->
            "es"

        Fa ->
            "fa"

        Fr ->
            "fr"

        Hi ->
            "hi"

        Hy ->
            "hy"

        It ->
            "it"

        Ja ->
            "ja"

        Ko ->
            "ko"

        Nl ->
            "nl"

        Pa ->
            "pa"

        Pt ->
            "pt"

        Ru ->
            "ru"

        Sw ->
            "sw"

        Tw ->
            "tw"

        Uk ->
            "uk"

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

        De ->
            "Übersicht"

        Fr ->
            "Vue d'ensemble"

        Hi ->
            "सिंहावलोकन"

        It ->
            "Home"

        Ja ->
            "ホーム"

        Ko ->
            "집"

        Pa ->
            "ਘਰ"

        Pt ->
            "Início"

        Ru ->
            "нет войне"

        Sw ->
            "Nyumbani"

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

        De ->
            "weiter"

        Es ->
            "siguente"

        Fa ->
            "بعدی"

        Fr ->
            "suivant"

        Hi ->
            "जारी रखें"

        Hy ->
            "հաջորդը"

        It ->
            "prossimo"

        Ja ->
            "次へ"

        Ko ->
            "다음"

        Nl ->
            "verder"

        Pa ->
            "ਅੱਗੇ"

        Pt ->
            "próximo"

        Ru ->
            "вперёд"

        Sw ->
            "ijayo"

        Tw ->
            "繼續"

        Uk ->
            "далі"

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

        De ->
            "zurück"

        Es ->
            "anterior"

        Fa ->
            "قبلی"

        Fr ->
            "précédent"

        Hi ->
            "वापस"

        Hy ->
            "նախորդը"

        It ->
            "precedente"

        Ja ->
            "前へ"

        Ko ->
            "이전"

        Nl ->
            "terug"

        Pa ->
            "ਪਿੱਛੇ"

        Pt ->
            "anterior"

        Ru ->
            "назад"

        Sw ->
            "iliyopita"

        Tw ->
            "返回"

        Uk ->
            "назад"

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

        De ->
            "Wiedergabe"

        Es ->
            "jugar"

        Fa ->
            "بازی کن"

        Fr ->
            "Lecture"

        Hi ->
            "प्लेबैक"

        Hy ->
            "Խաղացեք"

        It ->
            "avvia"

        Ja ->
            "再生"

        Ko ->
            "재생"

        Nl ->
            "afspelen"

        Pa ->
            "ਚਲਾਓ"

        Pt ->
            "reproduzir"

        Ru ->
            "играй"

        Sw ->
            "kucheza"

        Tw ->
            "播放"

        Uk ->
            "грати"

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

        De ->
            "Stopp"

        Es ->
            "parar"

        Fa ->
            "بس کن"

        Fr ->
            "Arrêt"

        Hi ->
            "बंद करो"

        Hy ->
            "դադարեցրեք"

        It ->
            "ferma"

        Ja ->
            "停止"

        Ko ->
            "정지"

        Nl ->
            "stoppen"

        Pa ->
            "ਬੰਦ ਕਰੋ"

        Pt ->
            "parar"

        Ru ->
            "остановись"

        Sw ->
            "kuacha"

        Tw ->
            "停止"

        Uk ->
            "зупинятися"

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

        It ->
            "Aa"

        Ja ->
            "Aa"

        Ko ->
            "가"

        Pa ->
            "ਏਬੀਸੀ"

        Pt ->
            "Aa"

        Sw ->
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

        De ->
            "Schriftgröße: " ++ str0 ++ ""

        Es ->
            "Tamaño de fuente: " ++ str0 ++ ""

        Fa ->
            "اندازه قلم: " ++ str0 ++ ""

        Fr ->
            "Taille de police : " ++ str0 ++ ""

        Hi ->
            "फ़ॉन्ट आकार: " ++ str0 ++ ""

        Hy ->
            "Տառատեսակի չափը ՝ " ++ str0 ++ ""

        It ->
            "Dimensione carattere: " ++ str0 ++ ""

        Ja ->
            "フォントサイズ: " ++ str0 ++ ""

        Ko ->
            "글꼴 크기: " ++ str0 ++ ""

        Nl ->
            "Lettergrootte: " ++ str0 ++ ""

        Pa ->
            "ਫੋਂਟ ਆਕਾਰ: " ++ str0 ++ ""

        Pt ->
            "tamanho da fonte: " ++ str0 ++ ""

        Ru ->
            "Размер шрифта: " ++ str0 ++ ""

        Sw ->
            "saizi ya fonti: " ++ str0 ++ ""

        Tw ->
            "字体大小： " ++ str0 ++ ""

        Uk ->
            "Розмір шрифту: " ++ str0 ++ ""

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

        De ->
            "klein"

        Es ->
            "pequeño"

        Fa ->
            "کوچک"

        Fr ->
            "petit"

        Hi ->
            "छोटा"

        Hy ->
            "փոքր"

        It ->
            "piccolo"

        Ja ->
            "小"

        Ko ->
            "작게"

        Nl ->
            "klein"

        Pa ->
            "ਛੋਟਾ"

        Pt ->
            "pequeno"

        Ru ->
            "мелкий"

        Sw ->
            "ndogo"

        Tw ->
            "小"

        Uk ->
            "маленький"

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

        De ->
            "mittel"

        Es ->
            "mediano"

        Fa ->
            "متوسط"

        Fr ->
            "moyen"

        Hi ->
            "मध्यम"

        Hy ->
            "միջին"

        It ->
            "medio"

        Ja ->
            "中"

        Ko ->
            "보통"

        Nl ->
            "medium"

        Pa ->
            "ਦਰਮਿਆਨਾ"

        Pt ->
            "médio"

        Ru ->
            "средний"

        Sw ->
            "kati"

        Tw ->
            "中"

        Uk ->
            "середній"

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

        De ->
            "groß"

        Es ->
            "grande"

        Fa ->
            "بزرگ"

        Fr ->
            "grand"

        Hi ->
            "बड़ा"

        Hy ->
            "մեծ"

        It ->
            "grande"

        Ja ->
            "大"

        Ko ->
            "크게"

        Nl ->
            "groot"

        Pa ->
            "ਵੱਡਾ"

        Pt ->
            "grande"

        Ru ->
            "большой"

        Sw ->
            "kubwa"

        Tw ->
            "大"

        Uk ->
            "великий"

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

        De ->
            "Suche"

        Es ->
            "buscar"

        Fa ->
            "جستجو"

        Fr ->
            "Recherche"

        Hi ->
            "खोजें"

        Hy ->
            "փնտրել"

        It ->
            "Cerca"

        Ja ->
            "検索"

        Ko ->
            "찾기"

        Nl ->
            "zoek"

        Pa ->
            "ਖੋਜ"

        Pt ->
            "Buscar"

        Ru ->
            "поиск"

        Sw ->
            "Tafuta"

        Tw ->
            "搜尋"

        Uk ->
            "пошук"

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

        De ->
            "Suche löschen"

        Es ->
            "eliminar búsqueda"

        Fa ->
            "جستجو را حذف کنید"

        Fr ->
            "Effacer la recherche"

        Hi ->
            "खोज हटाएं"

        Hy ->
            "ջնջել որոնումը"

        It ->
            "cancella ricerca"

        Ja ->
            "検索をクリア"

        Ko ->
            "입력 내용 지우기"

        Nl ->
            "Duidelijke zoek"

        Pa ->
            "ਖੋਜ ਹਟਾਓ"

        Pt ->
            "limpar busca"

        Ru ->
            "удалить поиск"

        Sw ->
            "tafuta wazi"

        Tw ->
            "删除搜寻"

        Uk ->
            "видалити пошук"

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

        De ->
            "Ergebnisse"

        Es ->
            "Resultados"

        Fa ->
            "نتایج"

        Fr ->
            "Résultats"

        Hi ->
            "परिणाम"

        Hy ->
            "արդյունքներ"

        It ->
            "risultati"

        Ja ->
            "結果"

        Ko ->
            "결과"

        Nl ->
            "Resultaten"

        Pa ->
            "ਨਤੀਜੇ"

        Pt ->
            "resultados"

        Ru ->
            "результаты"

        Sw ->
            "matokeo"

        Tw ->
            "结果"

        Uk ->
            "результати"

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

        De ->
            "ein Ergebnis"

        Es ->
            "un resultado"

        Fa ->
            "یک نتیجه"

        Fr ->
            "un résultat"

        Hi ->
            "एक परिणाम"

        Hy ->
            "մեկ արդյունք"

        It ->
            "un risultato"

        Ja ->
            "1件の結果"

        Ko ->
            "단일 결과"

        Nl ->
            "een resultaat"

        Pa ->
            "ਇੱਕ ਨਤੀਜਾ"

        Pt ->
            "um resultado"

        Ru ->
            "один результат"

        Sw ->
            "matokeo moja"

        Tw ->
            "一个结果"

        Uk ->
            "один результат"

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

        De ->
            "kein Ergebnis"

        Es ->
            "No hay resultados"

        Fa ->
            "هیچ نتیجه ای"

        Fr ->
            "aucun résultat"

        Hi ->
            "कोई परिणाम नहीं"

        Hy ->
            "արդյունք չկա"

        It ->
            "non ci sono risultati"

        Ja ->
            "結果なし"

        Ko ->
            "결과 없음"

        Nl ->
            "Geen resultaten"

        Pa ->
            "ਕੋਈ ਨਤੀਜਾ ਨਹੀਂ"

        Pt ->
            "sem resultados"

        Ru ->
            "нет результатов"

        Sw ->
            "hakuna matokeo"

        Tw ->
            "没有结果"

        Uk ->
            "немає результатів"

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

        De ->
            "Inhaltsverzeichnis"

        Es ->
            "índice"

        Fa ->
            "فهرست مطالب"

        Fr ->
            "Table des matières"

        Hi ->
            "सामग्री की तालिका"

        Hy ->
            "բովանդակություն"

        It ->
            "indice"

        Ja ->
            "目次"

        Ko ->
            "목차"

        Nl ->
            "Inhoudsopgave"

        Pa ->
            "ਸਮੱਗਰੀ ਦੇ ਨਾਲ-ਨਾਲ"

        Pt ->
            "Sumário"

        Ru ->
            "оглавление"

        Sw ->
            "Yaliyomo"

        Tw ->
            "目錄"

        Uk ->
            "зміст"

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

        De ->
            "zeigen"

        Es ->
            "mostrar"

        Fa ->
            "نشان دادن"

        Fr ->
            "montrer"

        Hi ->
            "दिखाएँ"

        Hy ->
            "ցույց տալ"

        It ->
            "mostrare"

        Ja ->
            "表示"

        Ko ->
            "보이기"

        Nl ->
            "tonen"

        Pa ->
            "ਵੇਖਾਓ"

        Pt ->
            "mostrar"

        Ru ->
            "показать"

        Sw ->
            "show"

        Tw ->
            "顯示"

        Uk ->
            "показати"

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

        De ->
            "verberghen"

        Es ->
            "ocultar"

        Fa ->
            "پنهان کردن"

        Fr ->
            "cacher"

        Hi ->
            "छुपाएं"

        Hy ->
            "թաքցնել"

        It ->
            "nascondere"

        Ja ->
            "非表示"

        Ko ->
            "감추기"

        Nl ->
            "verbergen"

        Pa ->
            "ਓਹਲੇ"

        Pt ->
            "esconder"

        Ru ->
            "скрыть"

        Sw ->
            "kujificha"

        Tw ->
            "隱藏"

        Uk ->
            "приховати"

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

        De ->
            "Editor-Stil"

        Es ->
            "estilo editor"

        Fa ->
            "به سبک ویرایشگر"

        Fr ->
            "Style de l'éditeur"

        Hi ->
            "संपादक शैली"

        Hy ->
            "խմբագիր ոճով"

        It ->
            "stile editor"

        Ja ->
            "エディター・スタイル"

        Ko ->
            "에디터 스타일"

        Nl ->
            "editor-stijl"

        Pa ->
            "ਸੰਪਾਦਕ ਸਟਾਈਲ"

        Pt ->
            "Estilo do editor"

        Ru ->
            "стиль редактора"

        Sw ->
            "Mtindo wa Mhariri"

        Tw ->
            "编辑风格"

        Uk ->
            "стиль редактора"

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

        De ->
            "Deutsch"

        Es ->
            "Español"

        Fa ->
            "فارسی"

        Fr ->
            "Français"

        Hi ->
            "जर्मन"

        Hy ->
            "հայերեն"

        It ->
            "Italiano"

        Ja ->
            "日本語"

        Ko ->
            "한국어"

        Nl ->
            "Nederlands"

        Pa ->
            "ਪੰਜਾਬੀ"

        Pt ->
            "Português"

        Ru ->
            "русский"

        Sw ->
            "Suaheli"

        Tw ->
            "中国人"

        Uk ->
            "Український"

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

        De ->
            "Anpassung der Abspielgeschwindigkeit"

        Es ->
            "ajustar velocidad de reproducción"

        Fa ->
            "تنظیم سرعت پخش"

        Fr ->
            "Ajuster la vitesse de lecture"

        Hi ->
            "प्लेबैक गति सेट करें"

        Hy ->
            "ձայնագիրը կարգավորել"

        It ->
            "Regola la velocità di riproduzione"

        Ja ->
            "再生速度を変更"

        Ko ->
            "재생 속도 조절"

        Nl ->
            "Afspeelsnelheid aanpassen"

        Pa ->
            "ਪਲੇਬੈਕ ਗਤੀ ਸੰਰਚਨਾ"

        Pt ->
            "Ajustar velocidade de reprodução"

        Ru ->
            "настройка скорости воспроизведения"

        Sw ->
            "Badilisha kasi ya kucheza"

        Tw ->
            "调整播放速度"

        Uk ->
            "налаштування швидкості відтворення"

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

        De ->
            "Anpassung der Tonhöhe"

        Es ->
            "ajustar tono"

        Fa ->
            "تنظیم تغییر صدا"

        Fr ->
            "Ajuster la hauteur du son"

        Hi ->
            "ध्वनि सेट करें"

        Hy ->
            "ձայնահատկությունը կարգավորել"

        It ->
            "Regola l'altezza del tono"

        Ja ->
            "音程を変更"

        Ko ->
            "음높이 조절"

        Nl ->
            "Toonhoogte aanpassen"

        Pa ->
            "ਧੁਨ ਸੰਰਚਨਾ"

        Pt ->
            "Ajustar tom"

        Ru ->
            "настройка высоты тона"

        Sw ->
            "Badilisha sauti"

        Tw ->
            "调整音高"

        Uk ->
            "налаштування висоти тону"

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

        De ->
            "Videokommentare ausblenden"

        Es ->
            "Ocultar los comentarios del video"

        Fa ->
            "مخفی کردن نظرات ویدیو"

        Fr ->
            "Masquer les commentaires vidéo"

        Hi ->
            "वीडियो टिप्पणियाँ छुपाएं"

        Hy ->
            "թաքցնել տեսանյութի մեջ մեկնաբանությունները"

        It ->
            "Nascondi i commenti video"

        Ja ->
            "動画のコメントを非表示にする"

        Ko ->
            "비디오 댓글 숨기기"

        Nl ->
            "Hide video comments"

        Pa ->
            "ਵੀਡੀਓ ਟਿੱਪਣੀਆਂ ਛੁਪਾਓ"

        Pt ->
            "Ocultar comentários do vídeo"

        Ru ->
            "Скрыть комментарии к видео"

        Sw ->
            "Ficha maoni ya video"

        Tw ->
            "隱藏影片評論"

        Uk ->
            "Приховати коментарі до відео"

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

        De ->
            "noch keine Übersetzungen vorhanden"

        Es ->
            "aún sin traducción"

        Fa ->
            "در دست ترجمه"

        Fr ->
            "traductions non disponibles"

        Hi ->
            "अभी तक कोई अनुवाद उपलब्ध नहीं है"

        Hy ->
            "դեռ թագմանություն չկա"

        It ->
            "ancora non tradotto"

        Ja ->
            "まだ翻訳されていません"

        Ko ->
            "번역되지 않음"

        Nl ->
            "noch geen vertaling aanwezig"

        Pa ->
            "ਅਜੇ ਅਨੁਵਾਦ ਨਹੀਂ ਹੈ"

        Pt ->
            "ainda não traduzido"

        Ru ->
            "перевода пока нет"

        Sw ->
            "hakuna tafsiri bado"

        Tw ->
            "尚未翻譯"

        Uk ->
            "переклад відсутній"

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

        De ->
            "Mit Google übersetzen (experimentell)"

        Es ->
            "Traducir con Google (experimental)"

        Fa ->
            "ترجمه با Google (آزمایشی)"

        Fr ->
            "Traduire avec Google (expérimental)"

        Hi ->
            "Google के साथ अनुवाद करें (प्रायोगिक)"

        Hy ->
            "Թարգմանեք Google- ի միջոցով (փորձնական)"

        It ->
            "Tradurre con Google (sperimentale)"

        Ja ->
            "Google翻訳で翻訳する（実験的）"

        Ko ->
            "Google Translate로 번역하기 (실험적 기능)"

        Nl ->
            "Vertalen met Google (experimenteel)"

        Pa ->
            "ਗੂਗਲ ਵਿੱਚ ਅਨੁਵਾਦ ਕਰੋ (ਪ੍ਰਯੋਗਾਤਮਕ)"

        Pt ->
            "Traduzir com Google (experimental)"

        Ru ->
            "Перевести с Google (экспериментально)"

        Sw ->
            "Tafsiri na Google (majaribio)"

        Tw ->
            "与Google进行翻译（实验性）"

        Uk ->
            "Перекласти за допомогою Google (експериментально)"

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

        De ->
            "Farbe"

        Es ->
            "color"

        Fa ->
            "رنگ"

        Fr ->
            "Couleur"

        Hi ->
            "रंग"

        Hy ->
            "գույն"

        It ->
            "colore"

        Ja ->
            "色"

        Ko ->
            "색상"

        Nl ->
            "kleur"

        Pa ->
            "ਰੰਗ"

        Pt ->
            "Cor"

        Ru ->
            "цвет"

        Sw ->
            "Rangi"

        Tw ->
            "顏色"

        Uk ->
            "колір"

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

        De ->
            "Farbschema"

        Es ->
            "Esquema de colores"

        Fa ->
            "طرح رنگی"

        Fr ->
            "Schéma de couleurs"

        Hi ->
            "रंग योजना"

        Hy ->
            "Գունային սխեման"

        It ->
            "Schema di colori"

        Ja ->
            "カラースキーム"

        Ko ->
            "색상 스키마"

        Nl ->
            "Kleurenschema"

        Pa ->
            "ਰੰਗ ਸਕੀਮ"

        Pt ->
            "Esquema de cores"

        Ru ->
            "Цветовая схема"

        Sw ->
            "Mpango wa rangi"

        Tw ->
            "配色方案"

        Uk ->
            "Кольорова схема"

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

        De ->
            "Dunkelmodus"

        Es ->
            "modo oscuro"

        Fa ->
            "حالت تاریک"

        Fr ->
            "Mode sombre"

        Hi ->
            "डार्क मोड"

        Hy ->
            "մութ ռեժիմ"

        It ->
            "modo scuro"

        Ja ->
            "ダークモード"

        Ko ->
            "다크 모드"

        Nl ->
            "donkere modus"

        Pa ->
            "ਡਾਰਕ ਮੋਡ"

        Pt ->
            "Modo escuro"

        Ru ->
            "темный режим"

        Sw ->
            "Hali ya Giza"

        Tw ->
            "暗模式"

        Uk ->
            "темний режим"

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

        De ->
            "Hellmodus"

        Es ->
            "modo claro"

        Fa ->
            "حالت روشن"

        Fr ->
            "Mode clair"

        Hi ->
            "लाइट मोड"

        Hy ->
            "թեթև ռեժիմ"

        It ->
            "modo chiaro"

        Ja ->
            "ライトモード"

        Ko ->
            "라이트 모드"

        Nl ->
            "lichte modus"

        Pa ->
            "ਚਮਕੀਲਾ ਮੋਡ"

        Pt ->
            "Modo claro"

        Ru ->
            "светлый режим"

        Sw ->
            "Modi-Nuru"

        Tw ->
            "亮模式"

        Uk ->
            "світлий режим"

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

        De ->
            "Standard"

        Es ->
            "defecto"

        Fa ->
            "پیشفرض"

        Fr ->
            "Standard"

        Hi ->
            "डिफ़ॉल्ट"

        Hy ->
            "կանխադրված"

        It ->
            "predefinito"

        Ja ->
            "デフォルト"

        Ko ->
            "기본"

        Nl ->
            "standaard"

        Pa ->
            "ਮੂਲ"

        Pt ->
            "Padrão"

        Ru ->
            "стандарт по умолчанию"

        Sw ->
            "Chaguomsingi"

        Tw ->
            "預設"

        Uk ->
            "стандартний"

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

        De ->
            "Blau"

        Es ->
            "azul"

        Fa ->
            "آبی"

        Fr ->
            "Bleu"

        Hi ->
            "नीला"

        Hy ->
            "կապույտ"

        It ->
            "blu"

        Ja ->
            "青"

        Ko ->
            "파랑"

        Nl ->
            "blauw"

        Pa ->
            "ਨੀਲਾ"

        Pt ->
            "Azul"

        Ru ->
            "синий"

        Sw ->
            "Bluu"

        Tw ->
            "藍色"

        Uk ->
            "синій"

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

        De ->
            "Rot"

        Es ->
            "rojo"

        Fa ->
            "قرمز"

        Fr ->
            "Rouge"

        Hi ->
            "लाल"

        Hy ->
            "կարմիր"

        It ->
            "rosso"

        Ja ->
            "赤"

        Ko ->
            "빨강"

        Nl ->
            "rood"

        Pa ->
            "ਲਾਲ"

        Pt ->
            "Vermelho"

        Ru ->
            "красный"

        Sw ->
            "nyekundu"

        Tw ->
            "红色的"

        Uk ->
            "червоний"

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

        De ->
            "Gelb"

        Es ->
            "amarillo"

        Fa ->
            "رنگ زرد"

        Fr ->
            "Jaune"

        Hi ->
            "पीला"

        Hy ->
            "դեղին"

        It ->
            "giallo"

        Ja ->
            "黄色"

        Ko ->
            "노랑"

        Nl ->
            "geel"

        Pa ->
            "ਪੀਲਾ"

        Pt ->
            "Amarelo"

        Ru ->
            "желтый"

        Sw ->
            "Njano"

        Tw ->
            "黄色的"

        Uk ->
            "жовтий"

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

        De ->
            "Türkis"

        Es ->
            "turquesa"

        Fa ->
            "فیروزه"

        Fr ->
            "Turquoise"

        Hi ->
            "फ़िरोज़ा"

        Hy ->
            "փիրուզագույն"

        It ->
            "turchese"

        Ja ->
            "ターコイズ"

        Ko ->
            "청록"

        Nl ->
            "turkoois"

        Pa ->
            "ਫੀਰੋਜ਼ੀ"

        Pt ->
            "Turquesa"

        Ru ->
            "бирюзовый"

        Sw ->
            "Turquoise"

        Tw ->
            "绿松石"

        Uk ->
            "бірюзовий"

        Zh ->
            "绿松石"

        _ ->
            "Turquoise"


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

        De ->
            "Präsentationsmodus"

        Es ->
            "Modo presentación"

        Fa ->
            "حالت ارائه"

        Fr ->
            "Mode de présentation"

        Hi ->
            "प्रेजेंटेशन मोड"

        Hy ->
            "Ներկայացման ռեժիմ"

        It ->
            "Modo presentazione"

        Ja ->
            "プレゼンテーションモード"

        Ko ->
            "프레젠테이션 모드"

        Nl ->
            "Presentatiemodus"

        Pa ->
            "ਪ੍ਰਸਤੁਤੀ ਮੋਡ"

        Pt ->
            "Modo apresentação"

        Ru ->
            "режим презентации"

        Sw ->
            "Hali ya uwasilishaji"

        Tw ->
            "简报模式"

        Uk ->
            "режим презентації"

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

        De ->
            "Lehrbuch"

        Es ->
            "Manual"

        Fa ->
            "کتاب"

        Fr ->
            "Manuel"

        Hi ->
            "पाठ्यपुस्तक"

        Hy ->
            "գիրք"

        It ->
            "Manuale"

        Ja ->
            "教科書"

        Ko ->
            "텍스트 북"

        Nl ->
            "Studieboek"

        Pa ->
            "ਟੈਕਸਟਬੁੱਕ"

        Pt ->
            "Livro-texto"

        Ru ->
            "чтения"

        Sw ->
            "Kitabu cha maandishi"

        Tw ->
            "教科書"

        Uk ->
            "навчальна книга"

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

        De ->
            "Präsentation"

        Es ->
            "Presentación"

        Fa ->
            "ارائه"

        Fr ->
            "Présentation"

        Hi ->
            "प्रस्तुति"

        Hy ->
            "ներկայացում"

        It ->
            "Presentazione"

        Ja ->
            "プレゼンテーション"

        Ko ->
            "프레젠테이션"

        Nl ->
            "Presentatie"

        Pa ->
            "ਪ੍ਰਸਤੁਤੀ"

        Pt ->
            "Apresentação"

        Ru ->
            "презентации"

        Sw ->
            "Uwasilishaji"

        Tw ->
            "報告"

        Uk ->
            "презентація"

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

        De ->
            "Folien"

        Es ->
            "Imagen"

        Fa ->
            "اسلایدها"

        Fr ->
            "Diapositives"

        Hi ->
            "स्लाइड्स"

        Hy ->
            "սլայդներ"

        It ->
            "Diapositive"

        Ja ->
            "スライド"

        Ko ->
            "슬라이드"

        Nl ->
            "Folies"

        Pa ->
            "ਸਲਾਈਡ"

        Pt ->
            "Slides"

        Ru ->
            "слайды"

        Sw ->
            "Slaidi"

        Tw ->
            "幻燈片"

        Uk ->
            "слайди"

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

        De ->
            "Sprecher an"

        Es ->
            "Sonido encendido"

        Fa ->
            "صدا روشن"

        Fr ->
            "Haut-parleur activé"

        Hi ->
            "स्पीकर ऑन"

        Hy ->
            "ձայնով"

        It ->
            "Suono attivo"

        Ja ->
            "音声オン"

        Ko ->
            "소리 켬"

        Nl ->
            "Luidspreker aan"

        Pa ->
            "ਸਾਊਂਡ ਚਾਲੂ"

        Pt ->
            "Som ligado"

        Ru ->
            "звук включён"

        Sw ->
            "Sauti imewashwa"

        Tw ->
            "聲音開啟"

        Uk ->
            "увімкнений"

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

        De ->
            "Sprecher aus"

        Es ->
            "Sonido apagado"

        Fa ->
            "صدا خاموش"

        Fr ->
            "Haut-parleur désactivé"

        Hi ->
            "स्पीकर बंद"

        Hy ->
            "առանց ձայն"

        It ->
            "Suono disattivato"

        Ja ->
            "音声オフ"

        Ko ->
            "소리 끔"

        Nl ->
            "Luidspreker uit"

        Pa ->
            "ਸਾਊਂਡ ਬੰਦ"

        Pt ->
            "Som desligado"

        Ru ->
            "звук выключен"

        Sw ->
            "Sauti imezimwa"

        Tw ->
            "聲音關閉"

        Uk ->
            "вимкнений"

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

        De ->
            "Autor: "

        Es ->
            "Autor"

        Fa ->
            "نویسنده: "

        Fr ->
            "Auteur : "

        Hi ->
            "लेखक:"

        Hy ->
            "հեղինակ: "

        It ->
            "Autore: "

        Ja ->
            "著者："

        Ko ->
            "저자: "

        Nl ->
            "Auteur: "

        Pa ->
            "ਲੇਖਕ: "

        Pt ->
            "Autor: "

        Ru ->
            "автор: "

        Sw ->
            "Mwandishi: "

        Tw ->
            "作者: "

        Uk ->
            "автор: "

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

        De ->
            "Autoren: "

        Es ->
            "Autores"

        Fa ->
            "نویسندگان: "

        Fr ->
            "Auteurs : "

        Hi ->
            "लेखकों:"

        Hy ->
            "հեղինակներ: "

        It ->
            "Autori: "

        Ja ->
            "著者："

        Ko ->
            "저자: "

        Nl ->
            "Auteurs: "

        Pa ->
            "ਲੇਖਕ: "

        Pt ->
            "Autores: "

        Ru ->
            "авторы: "

        Sw ->
            "Waandishi: "

        Tw ->
            "作者: "

        Uk ->
            "автори: "

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

        De ->
            "Datum: "

        Es ->
            "fecha"

        Fa ->
            "تاریخ: "

        Fr ->
            "Date : "

        Hi ->
            "तारीख:"

        Hy ->
            "ամսաթիվ: "

        It ->
            "Data: "

        Ja ->
            "日付："

        Ko ->
            "날짜: "

        Nl ->
            "Datum: "

        Pa ->
            "ਮਿਤੀ: "

        Pt ->
            "Data: "

        Ru ->
            "дата: "

        Sw ->
            "Tarehe: "

        Tw ->
            "日期: "

        Uk ->
            "дата: "

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

        De ->
            "E-Mail: "

        Es ->
            "email"

        Fa ->
            "ایمیل: "

        Fr ->
            "Email : "

        Hi ->
            "ईमेल:"

        Hy ->
            "էլ. փոստ: "

        It ->
            "Email: "

        Ja ->
            "メール："

        Ko ->
            "이메일: "

        Nl ->
            "E-mail: "

        Pa ->
            "ਈਮੇਲ: "

        Pt ->
            "Email: "

        Ru ->
            "эл. почта: "

        Sw ->
            "Barua pepe: "

        Tw ->
            "電郵: "

        Uk ->
            "електронна пошта: "

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

        De ->
            "Version: "

        Es ->
            "versión"

        Fa ->
            "نسخه: "

        Fr ->
            "Version : "

        Hi ->
            "संस्करण:"

        Hy ->
            "տարբերակ: "

        It ->
            "Versione:  "

        Ja ->
            "バージョン："

        Ko ->
            "버전: "

        Nl ->
            "Versie: "

        Pa ->
            "ਵਰਜਨ"

        Pt ->
            "Versão: "

        Ru ->
            "версия: "

        Sw ->
            "Toleo: "

        Tw ->
            "版本: "

        Uk ->
            "версія: "

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

        De ->
            "Informationen"

        Es ->
            "informaciones"

        Fa ->
            "اطلاعات"

        Fr ->
            "Informations"

        Hi ->
            "सूचना"

        Hy ->
            "ինֆորմացիա"

        It ->
            "Informazioni"

        Ja ->
            "情報"

        Ko ->
            "정보"

        Nl ->
            "Informatie"

        Pa ->
            "ਜਾਣਕਾਰੀ"

        Pt ->
            "Informação"

        Ru ->
            "информация"

        Sw ->
            "Taarifa"

        Tw ->
            "關於"

        Uk ->
            "інформація"

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

        De ->
            "Einstellungen"

        Es ->
            "configuración"

        Fa ->
            "تنظیمات"

        Fr ->
            "Paramètres"

        Hi ->
            "सेटिंग्स"

        Hy ->
            "կարգավորումներ"

        It ->
            "Impostazioni"

        Ja ->
            "設定"

        Ko ->
            "설정"

        Nl ->
            "Instellingen"

        Pa ->
            "ਸੈਟਿੰਗ"

        Pt ->
            "Configurações"

        Ru ->
            "настройки"

        Sw ->
            "Mipangilio"

        Tw ->
            "設定"

        Uk ->
            "налаштування"

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

        De ->
            "Teilen"

        Es ->
            "compartir"

        Fa ->
            "اشتراک"

        Fr ->
            "Partager"

        Hi ->
            "शेयर करें"

        Hy ->
            "կիսվել"

        It ->
            "Condividi"

        Ja ->
            "共有"

        Ko ->
            "공유"

        Nl ->
            "Delen"

        Pa ->
            "ਸਾਂਝਾ ਕਰੋ"

        Pt ->
            "Compartilhar"

        Ru ->
            "поделиться"

        Sw ->
            "Shiriki"

        Tw ->
            "分享"

        Uk ->
            "поділитися"

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

        De ->
            "Teilen per ..."

        Es ->
            "compartir via ..."

        Fa ->
            "اشتراک گذاری از طریق ..."

        Fr ->
            "Partager via ..."

        Hi ->
            "के माध्यम से साझा करें ..."

        Hy ->
            "տարածել միջոցով ..."

        It ->
            "Condividi via ..."

        Ja ->
            "共有方法..."

        Ko ->
            "공유하기"

        Nl ->
            "deel via ..."

        Pa ->
            "ਸਾਂਝਾ ਕਰੋ ਵਿਆ ..."

        Pt ->
            "compartilhar via ..."

        Ru ->
            "Отправить по ..."

        Sw ->
            "shiriki kupitia ..."

        Tw ->
            "通过...分享"

        Uk ->
            "поділитися через ..."

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

        De ->
            "Übersetzungen"

        Es ->
            "traducciones"

        Fa ->
            "ترجمه ها"

        Fr ->
            "Traductions"

        Hi ->
            "अनुवाद"

        Hy ->
            "թարգմանություններ"

        It ->
            "Traduzioni"

        Ja ->
            "翻訳"

        Ko ->
            "번역"

        Nl ->
            "Vertalingen"

        Pa ->
            "ਅਨੁਵਾਦ"

        Pt ->
            "Traduções"

        Ru ->
            "на других языках"

        Sw ->
            "Tafsiri"

        Tw ->
            "翻譯"

        Uk ->
            "переклади"

        Zh ->
            "翻譯"

        _ ->
            "Translations"


confTooltip : Lang -> String
confTooltip lang =
    case lang of 
        Am ->
            "የማጣሪያ ጥቅል"

        Bn ->
            "টুল"

        De ->
            "Tooltipps"

        Fr ->
            "Infobulles"

        Hi ->
            "टूलटिप्स"

        It ->
            "Tooltip"

        Ja ->
            "ツールチップ"

        Pa ->
            "ਉਪਸਮਾਨ"

        Pt ->
            "Dicas de ferramentas"

        Ru ->
            "подсказки"

        Sw ->
            "Vidokezo vya zana"

        Uk ->
            "підказки"

        _ ->
            "Tooltips"


ttsPreferBrowser : Lang -> String
ttsPreferBrowser lang =
    case lang of 
        Am ->
            "የብሮውን ቴክስት-ተምረው መቀመጥ"

        Bg ->
            "Предпочитам TTS на браузъра"

        Bn ->
            "ব্রাউজার TTS পছন্দ করুন"

        De ->
            "Browser-TTS bevorzugen"

        Es ->
            "Preferir TTS del navegador"

        Fr ->
            "Préférer le TTS du navigateur"

        Hi ->
            "ब्राउज़र TTS को प्राथमिकता दें"

        It ->
            "Preferir TTS del navegador"

        Ja ->
            "ブラウザのTTSを優先する"

        Ko ->
            "브라우저 TTS 선호"

        Nl ->
            "Voorkeur browser TTS"

        Pa ->
            "ਬਰਾਊਜ਼ਰ TTS ਦਾ ਪਸੰਦ ਦਿਓ"

        Pt ->
            "Preferir TTS do navegador"

        Ru ->
            "Предпочитать браузерный TTS"

        Sw ->
            "Pendelea kivinjari TTS"

        Tw ->
            "首选浏览器 TTS"

        Uk ->
            "Надаю перевагу браузеру TTS"

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

        De ->
            "Verwendung der internen Text-zu-Speech-Engine des Browsers."

        Es ->
            "Usando el motor interno de conversión de texto a voz del navegador."

        Fr ->
            "Utilisation du moteur de synthèse vocale intégré du navigateur."

        Hi ->
            "ब्राउज़र के आंतरिक टेक्स्ट-टू-स्पीच इंजन का उपयोग करना।"

        It ->
            "Sto utilizzando il motore interno di conversione del testo a voce del browser."

        Ja ->
            "ブラウザの内蔵テキスト読み上げエンジンを使用中"

        Ko ->
            "브라우저의 내부 텍스트 음성 변환 엔진을 사용합니다."

        Nl ->
            "De interne tekst-naar-spraak-engine van de browser gebruiken."

        Pa ->
            "ਬਰਾਊਜ਼ਰ ਦੇ ਅੰਦਰੂਨੀ ਟੈਕਸਟ-ਟੁ-ਸਪੀਚ ਇੰਜਨ ਦੀ ਵਰਤੋਂ ਕੀਤੀ ਜਾ ਰਹੀ ਹੈ।"

        Pt ->
            "Usando o motor interno de Texto-para-Fala do navegador."

        Ru ->
            "Используя внутренний механизм преобразования текста в речь браузера."

        Sw ->
            "Kwa kutumia injini ya ndani ya kivinjari ya Maandishi-hadi-Hotuba."

        Tw ->
            "使用浏览器的内部文本转语音引擎。"

        Uk ->
            "Використання внутрішньої системи синтезу мовлення у браузері."

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

        De ->
            "Ihr Browser unterstützt kein Text-to-Speech, versuchen Sie es mit einem anderen."

        Es ->
            "Tu navegador no es compatible con Text-to-Speech, prueba con otro."

        Fr ->
            "Votre navigateur ne prend pas en charge le texte en discours, essayez-en un autre."

        Hi ->
            "आपका ब्राउज़र टेक्स्ट-टू-स्पीच का समर्थन नहीं करता है, एक अलग प्रयास करें।"

        It ->
            "Il tuo browser non è compatibile con Text-to-Speech, provane un altro."

        Ja ->
            "このブラウザはテキスト読み上げに対応していません。他のブラウザをお試しください。"

        Ko ->
            "당신의 브라우저는 Text-to-Speech를 지원하지 않습니다. 다른 것을 시도해 보세요."

        Nl ->
            "Uw browser ondersteunt tekst-naar-spraak niet, probeer een andere."

        Pa ->
            "ਤੁਸੀਂ ਟੈਕਸਟ-ਟੁ-ਸਪੀਚ ਦਾ ਸਮਰਥਨ ਨਹੀਂ ਕਰਦੇ, ਕੋਈ ਹੋਰ ਸਫ਼ਾਰੀ ਵਰਤੋ।"

        Pt ->
            "Seu navegador não suporta Texto-para-Fala, tente outro."

        Ru ->
            "Ваш браузер не поддерживает преобразование текста в речь, попробуйте другой."

        Sw ->
            "Kivinjari chako hakitumii Maandishi-hadi-Hotuba, jaribu nyingine."

        Tw ->
            "您的浏览器不支持文本转语音，请换一个浏览器。"

        Uk ->
            "Ваш браузер не підтримує синтез мовлення з тексту, спробуйте інший."

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

        De ->
            "Ausführen"

        Es ->
            "ejecutar"

        Fa ->
            "اجرا"

        Fr ->
            "Exécuter"

        Hi ->
            "भागो"

        Hy ->
            "իրականացնել"

        It ->
            "Esegui"

        Ja ->
            "実行"

        Ko ->
            "실행"

        Nl ->
            "uitvoeren"

        Pa ->
            "ਚਲਾਓ"

        Pt ->
            "Executar"

        Ru ->
            "выполнить"

        Sw ->
            "Tekeleza"

        Tw ->
            "開始執行"

        Uk ->
            "запустити"

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

        De ->
            "wird ausgeführt"

        Es ->
            "en funcionamiento"

        Fa ->
            "در حال اجرا"

        Fr ->
            "en cours d'exécution"

        Hi ->
            "चल रहा है"

        Hy ->
            "ընթանում է"

        It ->
            "in funzione"

        Ja ->
            "実行中"

        Ko ->
            "실행 중"

        Nl ->
            "wordt uitgevoerd"

        Pa ->
            "ਚੱਲ ਰਿਹਾ ਹੈ"

        Pt ->
            "está sendo executado"

        Ru ->
            "выполняется"

        Sw ->
            "inakimbia"

        Tw ->
            "執行中"

        Uk ->
            "виконується"

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

        De ->
            "eine Version zurück"

        Es ->
            "versión anterior"

        Fa ->
            "نسخه قبلی"

        Fr ->
            "version précédente"

        Hi ->
            "एक संस्करण वापस"

        Hy ->
            "նախորդ տարբերակը"

        It ->
            "versione precedente"

        Ja ->
            "前のバージョン"

        Ko ->
            "이전 버전"

        Nl ->
            "een versie terug"

        Pa ->
            "ਪਿਛਲਾ ਵਰਜਨ"

        Pt ->
            "versão anterior"

        Ru ->
            "предыдущая версия"

        Sw ->
            "toleo la awali"

        Tw ->
            "上一版"

        Uk ->
            "попередня версія"

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

        De ->
            "eine Version vor"

        Es ->
            "versión siguiente"

        Fa ->
            "نسخه بعدی"

        Fr ->
            "version suivante"

        Hi ->
            "एक संस्करण पहले"

        Hy ->
            "հաջորդ տարբերակը"

        It ->
            "versione seguente"

        Ja ->
            "次のバージョン"

        Ko ->
            "다음 버전"

        Nl ->
            "een versie vooruit"

        Pa ->
            "ਅਗਲਾ ਵਰਜਨ"

        Pt ->
            "próxima versão"

        Ru ->
            "следующая версия"

        Sw ->
            "toleo linalofuata"

        Tw ->
            "下一版"

        Uk ->
            "наступна версія"

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

        De ->
            "erste Version"

        Es ->
            "primera versión"

        Fa ->
            "نسخه اولیه"

        Fr ->
            "première version"

        Hi ->
            "पहली रिलीज"

        Hy ->
            "առաջին տարբերակը"

        It ->
            "prima versione"

        Ja ->
            "最初のバージョン"

        Ko ->
            "첫 버전"

        Nl ->
            "eerste versie"

        Pa ->
            "ਪਹਿਲਾਂ ਦਾ ਵਰਜਨ"

        Pt ->
            "primeira versão"

        Ru ->
            "первая версия"

        Sw ->
            "toleo la kwanza"

        Tw ->
            "最初版"

        Uk ->
            "перша версія"

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

        De ->
            "letzte Version"

        Es ->
            "última versión"

        Fa ->
            "آخرین نسخه"

        Fr ->
            "dernière version"

        Hi ->
            "अंतिम संस्करण"

        Hy ->
            "վերջին տարբերակը"

        It ->
            "ultima versione"

        Ja ->
            "最新のバージョン"

        Ko ->
            "최신 버전"

        Nl ->
            "laatste versie"

        Pa ->
            "ਆਖੀਰੀ ਵਰਜਨ"

        Pt ->
            "última versão"

        Ru ->
            "последняя версия"

        Sw ->
            "toleo la mwisho"

        Tw ->
            "最終版"

        Uk ->
            "остання версія"

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

        De ->
            "Darstellung minimieren"

        Es ->
            "minimizar vista"

        Fa ->
            "کوچک کردن پنجره"

        Fr ->
            "Réduire l'affichage"

        Hi ->
            "प्रदर्शन को छोटा करें"

        Hy ->
            "նվազեցնել տեսքը"

        It ->
            "minimizare la vista"

        Ja ->
            "最小化"

        Ko ->
            "뷰 최소화"

        Nl ->
            "weergave verkleinen"

        Pa ->
            "ਨਿੱਚੇ ਕਰੋ ਝਲਕ"

        Pt ->
            "minimizar visualização"

        Ru ->
            "свернуть"

        Sw ->
            "punguza mtazamo"

        Tw ->
            "極小視窗"

        Uk ->
            "зображення зменшити"

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

        De ->
            "Darstellung maximieren"

        Es ->
            "maximinzar vista"

        Fa ->
            "بزرگ کردن پنجره"

        Fr ->
            "Maximiser l'affichage"

        Hi ->
            "प्रदर्शन को अधिकतम करें"

        Hy ->
            "բարձրագունել տեսքը"

        It ->
            "massimizzare la vista"

        Ja ->
            "最大化"

        Ko ->
            "뷰 최대화"

        Nl ->
            "weergave maximaliseren"

        Pa ->
            "ਵੱਧ ਕਰੋ ਝਲਕ"

        Pt ->
            "maximizar visualização"

        Ru ->
            "показать полностью"

        Sw ->
            "kuongeza mtazamo"

        Tw ->
            "極大視窗"

        Uk ->
            "зображення збільшити"

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

        De ->
            "Terminal"

        Fa ->
            "پایانه"

        Fr ->
            "Terminal"

        Hi ->
            "टर्मिनल"

        Hy ->
            "տերմինալ"

        Ja ->
            "ターミナル"

        Ko ->
            "단말기"

        Pa ->
            "ਟਰਮੀਨਲ"

        Pt ->
            "terminal"

        Ru ->
            "термина́л"

        Sw ->
            "terminal"

        Tw ->
            "终端"

        Uk ->
            "термінал"

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

        De ->
            "in die Zwischenablage kopieren"

        Es ->
            "copiar al portapapeles"

        Fa ->
            "کپی در کلیپ بورد"

        Fr ->
            "Copier dans le presse-papiers"

        Hi ->
            "क्लिपबोर्ड पर कॉपी करें"

        Hy ->
            "Պատճենել սեղմատախտակին"

        It ->
            "copia negli appunti"

        Ja ->
            "クリップボードにコピー"

        Ko ->
            "클립보드에 복사"

        Nl ->
            "kopiëren naar klembord"

        Pa ->
            "ਕਲਿੱਪਬੋਰਡ 'ਤੇ ਕਾਪੀ"

        Pt ->
            "copiar para a área de transferência"

        Ru ->
            "скопировать в буфер обмена"

        Sw ->
            "nakili kwenye ubao wa kunakili"

        Tw ->
            "复制到剪贴板"

        Uk ->
            "копіювати в буфер обміну"

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

        De ->
            "Prüfen"

        Es ->
            "verificar"

        Fa ->
            "بررسی"

        Fr ->
            "Vérifier"

        Hi ->
            "चेक करें"

        Hy ->
            "ստուգել"

        It ->
            "verifica"

        Ja ->
            "確認"

        Ko ->
            "확인"

        Nl ->
            "bekijk"

        Pa ->
            "ਜਾਂਚ ਕਰੋ"

        Pt ->
            "Verificar"

        Ru ->
            "проверить"

        Sw ->
            "Angalia"

        Tw ->
            "選取"

        Uk ->
            "перевірити"

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

        De ->
            "zeige Lösung"

        Es ->
            "mostrar solución"

        Fa ->
            "نمایش راهکار"

        Fr ->
            "Afficher la solution"

        Hi ->
            "समाधान दिखाएं"

        Hy ->
            "ցույց տալ լուծումը"

        It ->
            "mostra la soluzione"

        Ja ->
            "解答を表示"

        Ko ->
            "정답 보기"

        Nl ->
            "toon oplossing"

        Pa ->
            "ਹੱਲ ਦਿਖਾਓ"

        Pt ->
            "mostrar solução"

        Ru ->
            "показать решение"

        Sw ->
            "onyesha suluhisho"

        Tw ->
            "顯示解答"

        Uk ->
            "показати розв'язок"

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

        De ->
            "Hinweis anzeigen"

        Es ->
            "mostrar indicio"

        Fa ->
            "نمایش یادآوری"

        Fr ->
            "Afficher l'indice"

        Hi ->
            "संकेत दिखाएं"

        Hy ->
            "ցուցադրել ակնարկ"

        It ->
            "mosta un indizio"

        Ja ->
            "ヒントを表示"

        Ko ->
            "힌트 보기"

        Nl ->
            "toon hint"

        Pa ->
            "ਇੱਕ ਇੰਗਿਤ ਦਿਖਾਓ"

        Pt ->
            "mostrar dica"

        Ru ->
            "подсказка"

        Sw ->
            "onyesha kidokezo"

        Tw ->
            "暗示"

        Uk ->
            "показати підказку"

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

        De ->
            "Auswahl"

        Es ->
            "selección"

        Fa ->
            "انتخاب"

        Fr ->
            "Sélection"

        Hi ->
            "चयन"

        Hy ->
            "ընտրություն"

        It ->
            "seleziona"

        Ja ->
            "選択"

        Ko ->
            "선택"

        Nl ->
            "selectie"

        Pa ->
            "ਚੋਣ"

        Pt ->
            "seleção"

        Ru ->
            "выбор"

        Sw ->
            "uteuzi"

        Tw ->
            "选择"

        Uk ->
            "вибір"

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

        De ->
            "Überprüfe die Antwort. Die Antwort wird als richtig oder falsch markiert."

        Es ->
            "Comprueba la respuesta. La respuesta está marcada como correcta o incorrecta."

        Fa ->
            "پاسخ را بررسی کنید. پاسخ صحیح یا نادرست علامت گذاری شده است."

        Fr ->
            "Vérifiez la réponse. La réponse sera marquée comme correcte ou incorrecte."

        Hi ->
            "उत्तर की जाँच करें। उत्तर को सही या गलत के रूप में चिह्नित किया गया है।"

        Hy ->
            "Ստուգեք պատասխանը: Պատասխանը նշվում է որպես ճիշտ կամ սխալ:"

        It ->
            "Controlla la risposta. La risposta è indicata come corretta o errata."

        Ja ->
            "答えを確認してください。回答は正解または不正解でマークされます。"

        Ko ->
            "답을 확인하세요. 정답 또는 오답으로 표시됩니다."

        Nl ->
            "Controleer het antwoord. Het antwoord wordt gemarkeerd als goed of fout."

        Pa ->
            "ਜਵਾਬ ਦੀ ਜਾਂਚ ਕਰੋ। ਜਵਾਬ ਸਹੀ ਜਾਂ ਗਲਤ ਨਿਸ਼ਾਨਾ ਲਗਾਇਆ ਜਾਵੇਗਾ।"

        Pt ->
            "Verifique a resposta. A resposta será marcada como correta ou incorreta."

        Ru ->
            "Проверьте ответ. Ответ отмечен как правильный или неправильный."

        Sw ->
            "Angalia jibu. Jibu litawekwa alama kuwa sahihi au si sahihi."

        Tw ->
            "检查答案。答案被标记为正确或不正确。"

        Uk ->
            "Перевірте відповідь. Відповідь позначена як правильна чи неправильна."

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

        De ->
            "Zeige die Lösung. Das Quiz wird als aufgelöst markiert."

        Es ->
            "Muestre la solución. El cuestionario se marca como resuelto."

        Fa ->
            "راه حل را نشان دهید. مسابقه به عنوان حل شده علامت گذاری شده است."

        Fr ->
            "Affichez la solution. Le quiz sera marqué comme résolu."

        Hi ->
            "समाधान दिखाएं। प्रश्नोत्तरी को समाधान के रूप में चिह्नित किया जाएगा।"

        Hy ->
            "Showույց տվեք լուծումը: Վիկտորինան նշվում է որպես լուծված:"

        It ->
            "Mostra la soluzione. Il questionario si registra come risolto."

        Ja ->
            "解答を表示します。クイズは解決済みとマークされます。"

        Ko ->
            "솔루션을 보여주세요. 퀴즈가 해결된 것으로 표시됩니다."

        Nl ->
            "Laat de oplossing zien. De quiz is gemarkeerd als opgelost."

        Pa ->
            "ਹੱਲ ਦਿਖਾਓ। ਕਵਿਜ਼ ਹੱਲ ਕੀਤਾ ਜਾਵੇਗਾ।"

        Pt ->
            "Mostrar a solução. O quiz será marcado como resolvido."

        Ru ->
            "Покажи решение. Викторина помечается как решенная."

        Sw ->
            "Onyesha suluhisho. Maswali yatatiwa alama kuwa yametatuliwa."

        Tw ->
            "显示解决方案。测验被标记为已解决。"

        Uk ->
            "Покажіть рішення. Вікторина позначена як розв’язана."

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

        De ->
            "Herzlichen Glückwunsch, das war die richtige Antwort"

        Es ->
            "Felicitaciones, esa fue la respuesta correcta"

        Fa ->
            "تبریک می گویم ، جواب صحیحی بود"

        Fr ->
            "Félicitations, c'était la bonne réponse"

        Hi ->
            "बधाई हो, यह सही उत्तर था"

        Hy ->
            "Շնորհավորում եմ, դա ճիշտ պատասխանն էր"

        It ->
            "Congratulazioni, questa era la risposta corretta"

        Ja ->
            "おめでとうございます、正解です"

        Ko ->
            "축하합니다. 올바른 답을 선택했습니다"

        Nl ->
            "Gefeliciteerd, dat was het juiste antwoord"

        Pa ->
            "ਬਧਾਈ ਹੋ, ਜਿਹਨਾਂ ਜਵਾਬ ਸਹੀ ਸੀ।"

        Pt ->
            "Parabéns, essa foi a resposta certa."

        Ru ->
            "Поздравляю, это был правильный ответ"

        Sw ->
            "Hongera, hilo lilikuwa jibu sahihi"

        Tw ->
            "恭喜，那是正确的答案"

        Uk ->
            "Вітаю, це була правильна відповідь"

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

        De ->
            "Die richtige Antwort wurde noch nicht gegeben"

        Es ->
            "La respuesta correcta aún no ha sido dada"

        Fa ->
            "بله، این ترجمه فارسی است"

        Fr ->
            "La réponse correcte n'a pas encore été donnée"

        Hi ->
            "अभी तक सही उत्तर नहीं दिया गया है"

        Hy ->
            "Ճիշտ պատասխանը դեռևս չի տրվել"

        It ->
            "La risposta corretta non è stata ancora fornita"

        Ja ->
            "正解がまだ与えられていません"

        Ko ->
            "정답이 아직 제시되지 않았습니다"

        Nl ->
            "Het juiste antwoord is nog niet gegeven"

        Pa ->
            "ਸਹੀ ਜਵਾਬ ਹਾਲੇ ਨਹੀਂ ਦਿੱਤਾ ਗਿਆ ਹੈ।"

        Pt ->
            "A resposta correta ainda não foi dada."

        Ru ->
            "Правильный ответ еще не дан"

        Sw ->
            "Jibu sahihi bado halijatolewa"

        Tw ->
            "正確的答案還沒有被給出"

        Uk ->
            "Правильна відповідь ще не надана"

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

        De ->
            "Aufgelöste Antwort"

        Es ->
            "Respuesta resuelta"

        Fa ->
            "پاسخ حل شده"

        Fr ->
            "Réponse résolue"

        Hi ->
            "हल की गई प्रतिक्रिया"

        Hy ->
            "Լուծված պատասխան"

        It ->
            "Risposta decisiva"

        Ja ->
            "解決済みの回答"

        Ko ->
            "이미 푼 퀴즈입니다"

        Nl ->
            "Opgelost antwoord"

        Pa ->
            "ਹੱਲ ਕੀਤਾ ਗਿਆ ਜਵਾਬ"

        Pt ->
            "Resposta resolvida."

        Ru ->
            "Решенный ответ"

        Sw ->
            "Jibu lililotatuliwa"

        Tw ->
            "解决的答案"

        Uk ->
            "Вирішена відповідь"

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

        De ->
            "Abschicken"

        Es ->
            "enviar"

        Fa ->
            "ارسال"

        Fr ->
            "Soumettre"

        Hi ->
            "सबमिट करें"

        Hy ->
            "ներկայացնել"

        It ->
            "Invia"

        Ja ->
            "送信"

        Ko ->
            "제출"

        Nl ->
            "Verzenden"

        Pa ->
            "ਜਮਾ ਕਰੋ"

        Pt ->
            "Enviar"

        Ru ->
            "отправить"

        Sw ->
            "Wasilisha"

        Tw ->
            "遞交"

        Uk ->
            "відіслати"

        Zh ->
            "遞交"

        _ ->
            "Submit"


surveySubmitted : Lang -> String
surveySubmitted lang =
    case lang of 
        Am ->
            "እናመሰግናለን"

        Ar ->
            "تم الإرسال"

        Bg ->
            "Благодаря"

        Bn ->
            "ধন্যবাদ"

        De ->
            "Dankeschön"

        Es ->
            "enviado"

        Fa ->
            "تشکر"

        Fr ->
            "Merci"

        Hi ->
            "धन्यवाद"

        Hy ->
            "շնորհակալություն"

        It ->
            "Inviato"

        Ja ->
            "ありがとうございます"

        Ko ->
            "감사합니다"

        Nl ->
            "Vriendelijk bedankt"

        Pa ->
            "ਧੰਨਵਾਦ"

        Pt ->
            "Obrigado"

        Ru ->
            "отправлено"

        Sw ->
            "Asante"

        Tw ->
            "感謝"

        Uk ->
            "дякую"

        Zh ->
            "感謝"

        _ ->
            "Thanks"


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

        De ->
            "Texteingabe ..."

        Es ->
            "introducir texto"

        Fa ->
            "لطفا متن وارد کنید"

        Fr ->
            "Saisie de texte ..."

        Hi ->
            "टेक्स्ट इनपुट ..."

        Hy ->
            "Մուտքագրեք որոշ տեքստ"

        It ->
            "Immetti del testo"

        Ja ->
            "テキストを入力してください..."

        Ko ->
            "내용을 입력해주세요."

        Nl ->
            "Tekstinvoer ..."

        Pa ->
            "ਕੁਝ ਟੈਕਸਟ ਦਿਓ..."

        Pt ->
            "Digite algum texto..."

        Ru ->
            "ввод текста"

        Sw ->
            "Weka maandishi..."

        Tw ->
            "輸入文字..."

        Uk ->
            "Ввід тексту ..."

        Zh ->
            "輸入文字..."

        _ ->
            "Enter some text..."


sortAsc : Lang -> String
sortAsc lang =
    case lang of 
        Am ->
            "ቅደም አስቀድሞ"

        Ar ->
            "ترتيب تصاعدي"

        Bn ->
            "আরোহী ক্রমানুসারে সাজান"

        De ->
            "aufsteigend sortieren"

        Es ->
            "orden ascendente"

        Fr ->
            "trier par ordre croissant"

        Hi ->
            "आरोही क्रमबद्ध करें"

        It ->
            "ordine crescente"

        Ja ->
            "昇順に並べ替え"

        Ko ->
            "오름차순 정렬"

        Nl ->
            "oplopend sorteren"

        Pa ->
            "ਚੜਦੀ ਕ੍ਰਮ ਵਿੱਚ"

        Pt ->
            "ordenar em ordem crescente"

        Ru ->
            "сортировать по возрастанию"

        Sw ->
            "kupanga kupanda"

        Uk ->
            "сортування за зростанням"

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

        De ->
            "absteigend sortieren"

        Es ->
            "orden descendiente"

        Fr ->
            "trier par ordre décroissant"

        Hi ->
            "अवरोही क्रमबद्ध करें"

        It ->
            "ordine discendente"

        Ja ->
            "降順に並べ替え"

        Ko ->
            "내림차순 정렬"

        Nl ->
            "sorteer aflopend"

        Pa ->
            "ਡਿਸਕੰਡਿੰਗ ਕ੍ਰਮ ਵਿੱਚ"

        Pt ->
            "ordenar em ordem decrescente"

        Ru ->
            "сортировка по убыванию"

        Sw ->
            "panga kushuka"

        Uk ->
            "сортувати за спаданням"

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

        De ->
            "nicht sortiert"

        Es ->
            "no ordenado"

        Fr ->
            "non trié"

        Hi ->
            "क्रमबद्ध नहीं"

        It ->
            "non ordinato"

        Ja ->
            "未並べ替え"

        Ko ->
            "정렬 안 됨"

        Nl ->
            "niet gesorteerd"

        Pa ->
            "ਨਾ ਸੋਰਟ"

        Pt ->
            "não ordenado"

        Ru ->
            "не отсортировано"

        Sw ->
            "haijapangwa"

        Uk ->
            "не сортується"

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

        De ->
            "Tortendiagramm"

        Fr ->
            "Diagramme en secteurs"

        Hi ->
            "पाई चार्ट"

        It ->
            "Diagramma a torta"

        Ja ->
            "円グラフ"

        Ko ->
            "파이 차트"

        Pa ->
            "ਪਾਈ ਚਾਰਟ"

        Pt ->
            "Gráfico de pizza"

        Sw ->
            "chati ya pai"

        Tw ->
            "饼图"

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

        De ->
            "Balkendiagramm"

        Fr ->
            "Diagramme en bâtons"

        Hi ->
            "बार चार्ट"

        It ->
            "Diagramma a barre"

        Ja ->
            "棒グラフ"

        Ko ->
            "바 차트"

        Pa ->
            "ਬਾਰ ਚਾਰਟ"

        Pt ->
            "Gráfico de barras"

        Sw ->
            "Chati ya paa"

        Tw ->
            "柱状图"

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

        De ->
            "Liniendiagramm"

        Fr ->
            "Graphique linéaire"

        Hi ->
            "लाइन चार्ट"

        It ->
            "Diagramma a linee"

        Ja ->
            "折れ線グラフ"

        Ko ->
            "라인 차트"

        Pa ->
            "ਰੇਖਾ ਚਾਰਟ"

        Pt ->
            "Gráfico de linhas"

        Sw ->
            "Chati ya mstari"

        Tw ->
            "折线图"

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

        De ->
            "Streudiagramm"

        Fr ->
            "Nuage de points"

        Hi ->
            "स्कैटरप्लॉट"

        It ->
            "Diagramma a dispersione"

        Ja ->
            "散布図"

        Ko ->
            "분포도"

        Pa ->
            "ਸਿਆਨਾ ਚਿੰਨ੍ਹ ਚਾਰਟ"

        Pt ->
            "Gráfico de dispersão"

        Sw ->
            "Kutawanya njama"

        Tw ->
            "散点图"

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

        De ->
            "Radar-Karte"

        Fr ->
            "Graphique en radar"

        Hi ->
            "रडार मैप"

        It ->
            "Diagramma Radar"

        Ja ->
            "レーダーチャート"

        Ko ->
            "레이더 차트"

        Pa ->
            "ਰਾਡਾਰ ਚਾਰਟ"

        Pt ->
            "Gráfico de radar"

        Sw ->
            "Chati ya rada"

        Tw ->
            "雷达图"

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

        De ->
            "Boxplot"

        Fr ->
            "Boîte à moustaches"

        Hi ->
            "बॉक्सप्लॉट"

        It ->
            "Boxplot"

        Ja ->
            "ボックスプロット"

        Ko ->
            "상자 그림"

        Pa ->
            "ਬਾਕਸਪਲਾਟ"

        Pt ->
            "Diagrama de caixa"

        Sw ->
            "Boxplot"

        Tw ->
            "箱型图"

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

        De ->
            "Heatmap"

        Fr ->
            "Carte de chaleur"

        Hi ->
            "हीटमैप"

        It ->
            "Heat map"

        Ja ->
            "ヒートマップ"

        Ko ->
            "히트 맵"

        Pa ->
            "ਹੀਟਮੈਪ"

        Pt ->
            "Mapa de calor"

        Sw ->
            "Ramani ya joto"

        Tw ->
            "热力图"

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

        De ->
            "Karte"

        Fr ->
            "Carte"

        Hi ->
            "मैप"

        It ->
            "Map"

        Ja ->
            "地図"

        Ko ->
            "맵"

        Pa ->
            "ਨਕਸ਼ਾ"

        Pt ->
            "Mapa"

        Sw ->
            "ramani"

        Tw ->
            "地图"

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
            "প্যারালেল কো঑র্ডিনেট ম্যাপ"

        De ->
            "Parallele Koordinatenkarte"

        Fr ->
            "Carte de coordonnées parallèles"

        Hi ->
            "समानांतर समन्वय मानचित्र"

        It ->
            "Parallel coordinate map"

        Ja ->
            "パラレル座標マップ"

        Ko ->
            "평행 좌표 맵"

        Pt ->
            "Mapa de coordenadas paralelas"

        Sw ->
            "Ramani ya kuratibu sambamba"

        Tw ->
            "平行坐标图"

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

        De ->
            "Liniendiagramm"

        Fr ->
            "Graphe linéaire"

        Hi ->
            "लाइन चार्ट"

        It ->
            "Line graph"

        Ja ->
            "折れ線グラフ"

        Ko ->
            "선 그래프"

        Pt ->
            "Gráfico de linhas"

        Sw ->
            "Grafu ya mstari"

        Tw ->
            "线图"

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

        De ->
            "Beziehungsgrafik"

        Fr ->
            "Graphe de relations"

        Hi ->
            "रिलेशनशिप ग्राफ"

        It ->
            "Relationship graph"

        Ja ->
            "関係グラフ"

        Ko ->
            "관계도"

        Pt ->
            "Gráfico de relacionamento"

        Sw ->
            "Grafu ya uhusiano"

        Tw ->
            "关系图"

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

        De ->
            "Sankey-Diagramm"

        Fr ->
            "Diagramme de Sankey"

        Hi ->
            "सैंके आरेख"

        It ->
            "Sankey diagram"

        Ja ->
            "サンキーダイアグラム"

        Ko ->
            "생키 다이어그램"

        Pt ->
            "Diagrama de Sankey"

        Sw ->
            "mchoro wa Sankey"

        Tw ->
            "桑基图"

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

        De ->
            "Trichterdiagramm"

        Fr ->
            "Entonnoir"

        Hi ->
            "फ़नल चार्ट"

        It ->
            "Funnel chart"

        Ja ->
            "ファネルチャート"

        Ko ->
            "퍼널 차트"

        Pt ->
            "Gráfico de funil"

        Sw ->
            "Chati ya faneli"

        Tw ->
            "漏斗图"

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

        De ->
            "QR-Code für Webseite"

        Es ->
            "Código QR para sitio web"

        Fa ->
            "کد QR برای وب سایت"

        Fr ->
            "Code QR pour site web"

        Hi ->
            "वेबसाइट के लिए क्यूआर कोड"

        Hy ->
            "Վեբ կայքի QR կոդ"

        It ->
            "Codice QR del sito web"

        Ja ->
            "ウェブサイト用 QR コード"

        Ko ->
            "웹 사이트용 QR 코드"

        Nl ->
            "QR-code voor website"

        Pa ->
            "ਵੈੱਬਸਾਈਟ ਲਈ ਕੁਆਰ ਕੋਡ"

        Pt ->
            "Código QR para site"

        Ru ->
            "QR-код для сайта"

        Sw ->
            "Msimbo wa QR wa tovuti"

        Tw ->
            "网站二维码"

        Uk ->
            "QR -код для веб -сайту"

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

        De ->
            "Fehler beim Codieren in QR-Code"

        Es ->
            "Error al codificar en código QR"

        Fa ->
            "خطا هنگام رمزگذاری روی کد QR"

        Fr ->
            "Erreur lors de l'encodage en code QR"

        Hi ->
            "क्यूआर कोड को एनकोड करने में त्रुटि"

        Hy ->
            "Սխալ QR կոդի կոդավորման ժամանակ"

        It ->
            "Errore nel codificare come codice QR"

        Ja ->
            "QR コードのエンコード中にエラーが発生しました"

        Ko ->
            "QR 코드를 만드는 도중 오류가 발생했습니다."

        Nl ->
            "Fout bij het coderen naar QR-code"

        Pa ->
            "ਕੁਆਰ ਕੋਡ ਨੂੰ ਏਨਕੋਡ ਕਰਨ ਦੌਰਾਨ ਗਲਤੀ ਆਈ ਹੈ"

        Pt ->
            "Erro durante a codificação para o código QR"

        Ru ->
            "Ошибка при кодировании в QR-код"

        Sw ->
            "Hitilafu wakati wa kusimba msimbo wa QR"

        Tw ->
            "编码为二维码时出错"

        Uk ->
            "Помилка під час кодування в QR -код"

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

        De ->
            "Chat öffnen"

        Es ->
            "Abrir chat"

        Fa ->
            "باز کردن گفتگو"

        Fr ->
            "Ouvrir le chat"

        Hi ->
            "चैट खोलें"

        Hy ->
            "Բացել խոսակցություն"

        It ->
            "Aprire la chat"

        Ja ->
            "チャットを開く"

        Ko ->
            "채팅 열기"

        Nl ->
            "Chat openen"

        Pa ->
            "ਚੈਟ ਖੋਲ੍ਹੋ"

        Pt ->
            "Abrir chat"

        Ru ->
            "Открыть чат"

        Sw ->
            "Fungua gumzo"

        Tw ->
            "開啟聊天室"

        Uk ->
            "Відкрити чат"

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

        De ->
            "Chat schließen"

        Es ->
            "Cerrar chat"

        Fa ->
            "بستن گفتگو"

        Fr ->
            "Fermer le chat"

        Hi ->
            "चैट बंद करें"

        Hy ->
            "Փակել խոսակցություն"

        It ->
            "Chiudere la chat"

        Ja ->
            "チャットを閉じる"

        Ko ->
            "채팅 닫기"

        Nl ->
            "Chat sluiten"

        Pa ->
            "ਚੈਟ ਬੰਦ ਕਰੋ"

        Pt ->
            "Fechar chat"

        Ru ->
            "Закрыть чат"

        Sw ->
            "Funga gumzo"

        Tw ->
            "關閉聊天室"

        Uk ->
            "Закрити чат"

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

        De ->
            "Du hast ungelesene Chat-Nachrichten"

        Es ->
            "Tienes mensajes de chat no leídos"

        Fa ->
            "شما پیام‌های چت خوانده نشده دارید"

        Fr ->
            "Vous avez des messages de chat non lus"

        Hi ->
            "आपके पास अपठित चैट संदेश हैं"

        Hy ->
            "Դուք ունեք չկարդացված խոսածքներ խոսակցության մեջ"

        It ->
            "Ci sono messaggi di chat non letti"

        Ja ->
            "未読のチャットメッセージがあります"

        Ko ->
            "읽지 않은 채팅 메시지가 있습니다"

        Nl ->
            "Je hebt ongelezen chatberichten"

        Pa ->
            "ਤੁਸੀਂ ਨਾ-ਪੜ੍ਹੇ ਚੈਟ ਸੁਨੇਹੇ ਹਨ"

        Pt ->
            "Você tem mensagens de chat não lidas"

        Ru ->
            "У вас есть непрочитанные сообщения в чате"

        Sw ->
            "Una ujumbe wa gumzo usio soma"

        Tw ->
            "你有未讀的聊天訊息"

        Uk ->
            "У вас є непрочитані повідомлення в чаті"

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

        De ->
            "Nachricht senden"

        Es ->
            "Enviar mensaje"

        Fa ->
            "ارسال پیام"

        Fr ->
            "Envoyer le message"

        Hi ->
            "संदेश भेजें"

        Hy ->
            "Ուղարկել նամակ"

        It ->
            "Invia messaggio"

        Ja ->
            "メッセージを送信する"

        Ko ->
            "메시지 보내기"

        Nl ->
            "Bericht versturen"

        Pa ->
            "ਸੁਨੇਹਾ ਭੇਜੋ"

        Pt ->
            "Enviar mensagem"

        Ru ->
            "Отправить сообщение"

        Sw ->
            "Tuma ujumbe"

        Tw ->
            "發送訊息"

        Uk ->
            "Надіслати повідомлення"

        Zh ->
            "发送消息"

        _ ->
            "Send message"

