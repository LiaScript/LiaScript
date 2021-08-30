module Translations exposing (..)

{-| This file was automatically generated with elm-i18n-gen.
For more in information visit:

<https://github.com/ChristophP/elm-i18n-module-generator>

-}


type Lang
    = Ar
    | Bg
    | De
    | Es
    | Fa
    | Hy
    | Ko
    | Nl
    | Ru
    | Tw
    | Ua
    | Zh
    | En


{-| Pass a language code that will return a Lang-type, if it exists.
Otherwise `Nothing` is returned.
-}
getLnFromCode : String -> Maybe Lang
getLnFromCode code =
    case String.toLower code of 
        "ar" ->
            Just Ar

        "bg" ->
            Just Bg

        "de" ->
            Just De

        "es" ->
            Just Es

        "fa" ->
            Just Fa

        "hy" ->
            Just Hy

        "ko" ->
            Just Ko

        "nl" ->
            Just Nl

        "ru" ->
            Just Ru

        "tw" ->
            Just Tw

        "ua" ->
            Just Ua

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
        Ar ->
            "ar"

        Bg ->
            "bg"

        De ->
            "de"

        Es ->
            "es"

        Fa ->
            "fa"

        Hy ->
            "hy"

        Ko ->
            "ko"

        Nl ->
            "nl"

        Ru ->
            "ru"

        Tw ->
            "tw"

        Ua ->
            "ua"

        Zh ->
            "zh"

        En ->
            "en"


baseNext : Lang -> String
baseNext lang =
    case lang of 
        Ar ->
            "التالي"

        Bg ->
            "Следващ"

        De ->
            "weiter"

        Es ->
            "siguente"

        Fa ->
            "بعدی"

        Hy ->
            "հաջորդը"

        Ko ->
            "다음"

        Nl ->
            "verder"

        Ru ->
            "вперёд"

        Tw ->
            "繼續"

        Ua ->
            "далі"

        Zh ->
            "繼續"

        _ ->
            "next"


basePrev : Lang -> String
basePrev lang =
    case lang of 
        Ar ->
            "السابق"

        Bg ->
            "Предишен"

        De ->
            "zurück"

        Es ->
            "anterior"

        Fa ->
            "قبلی"

        Hy ->
            "նախորդը"

        Ko ->
            "이전"

        Nl ->
            "terug"

        Ru ->
            "назад"

        Tw ->
            "返回"

        Ua ->
            "назад"

        Zh ->
            "返回"

        _ ->
            "previous"


basePlay : Lang -> String
basePlay lang =
    case lang of 
        Ar ->
            "العب"

        Bg ->
            "играйте"

        De ->
            "Wiedergabe"

        Es ->
            "jugar"

        Fa ->
            "بازی کن"

        Hy ->
            "Խաղացեք"

        Ko ->
            "play"

        Nl ->
            "afspelen"

        Ru ->
            "играй"

        Tw ->
            "播放"

        Ua ->
            "грати"

        Zh ->
            "播放"

        _ ->
            "play"


baseStop : Lang -> String
baseStop lang =
    case lang of 
        Ar ->
            "توقف"

        Bg ->
            "спрете"

        De ->
            "Stopp"

        Es ->
            "parar"

        Fa ->
            "بس کن"

        Hy ->
            "դադարեցրեք"

        Ko ->
            "stop"

        Nl ->
            "stoppen"

        Ru ->
            "остановись"

        Tw ->
            "停止"

        Ua ->
            "зупинятися"

        Zh ->
            "停止"

        _ ->
            "stop"


baseFont : Lang -> String -> String
baseFont lang str0 =
    case lang of 
        Ar ->
            " :حجم الخط " ++ str0 ++ ""

        Bg ->
            "Размер на шрифта: " ++ str0 ++ ""

        De ->
            "Schriftgröße: " ++ str0 ++ ""

        Es ->
            "Tamaño de fuente: " ++ str0 ++ ""

        Fa ->
            "اندازه قلم: " ++ str0 ++ ""

        Hy ->
            "Տառատեսակի չափը ՝ " ++ str0 ++ ""

        Ko ->
            "글꼴 크기: " ++ str0 ++ ""

        Nl ->
            "Lettergrootte: " ++ str0 ++ ""

        Ru ->
            "Размер шрифта: " ++ str0 ++ ""

        Tw ->
            "字体大小： " ++ str0 ++ ""

        Ua ->
            "Розмір шрифту: " ++ str0 ++ ""

        Zh ->
            "字体大小： " ++ str0 ++ ""

        _ ->
            "font size: " ++ str0 ++ ""


baseSize1 : Lang -> String
baseSize1 lang =
    case lang of 
        Ar ->
            "صغير"

        Bg ->
            "малък"

        De ->
            "klein"

        Es ->
            "pequeño"

        Fa ->
            "کوچک"

        Hy ->
            "փոքր"

        Ko ->
            "작게"

        Nl ->
            "klein"

        Ru ->
            "мелкий"

        Tw ->
            "小"

        Ua ->
            "маленький"

        Zh ->
            "小"

        _ ->
            "small"


baseSize2 : Lang -> String
baseSize2 lang =
    case lang of 
        Ar ->
            "متوسط"

        Bg ->
            "среден"

        De ->
            "mittel"

        Es ->
            "mediano"

        Fa ->
            "متوسط"

        Hy ->
            "միջին"

        Ko ->
            "보통"

        Nl ->
            "medium"

        Ru ->
            "средний"

        Tw ->
            "中"

        Ua ->
            "середній"

        Zh ->
            "中"

        _ ->
            "medium"


baseSize3 : Lang -> String
baseSize3 lang =
    case lang of 
        Ar ->
            "كبير"

        Bg ->
            "голям"

        De ->
            "groß"

        Es ->
            "grande"

        Fa ->
            "بزرگ"

        Hy ->
            "մեծ"

        Ko ->
            "크게"

        Nl ->
            "groot"

        Ru ->
            "большой"

        Tw ->
            "大"

        Ua ->
            "великий"

        Zh ->
            "大"

        _ ->
            "large"


baseSearch : Lang -> String
baseSearch lang =
    case lang of 
        Ar ->
            "بحث"

        Bg ->
            "Търсене"

        De ->
            "Suche"

        Es ->
            "buscar"

        Fa ->
            "جستجو"

        Hy ->
            "փնտրել"

        Ko ->
            "찾기"

        Nl ->
            "zoek"

        Ru ->
            "поиск"

        Tw ->
            "搜尋"

        Ua ->
            "пошук"

        Zh ->
            "搜尋"

        _ ->
            "Search"


baseDelete : Lang -> String
baseDelete lang =
    case lang of 
        Ar ->
            "إزالة البحث"

        Bg ->
            "търсене изтриване"

        De ->
            "Suche löschen"

        Es ->
            "eliminar búsqueda"

        Fa ->
            "جستجو را حذف کنید"

        Hy ->
            "ջնջել որոնումը"

        Ko ->
            "입력 내용 지우기"

        Nl ->
            "Duidelijke zoek"

        Ru ->
            "удалить поиск"

        Tw ->
            "删除搜寻"

        Ua ->
            "видалити пошук"

        Zh ->
            "删除搜寻"

        _ ->
            "clear search"


baseResults : Lang -> String
baseResults lang =
    case lang of 
        Ar ->
            "النتائج"

        Bg ->
            "Резултати"

        De ->
            "Ergebnisse"

        Es ->
            "Resultados"

        Fa ->
            "نتایج"

        Hy ->
            "արդյունքներ"

        Ko ->
            "결과"

        Nl ->
            "Resultaten"

        Ru ->
            "результаты"

        Tw ->
            "结果"

        Ua ->
            "результати"

        Zh ->
            "结果"

        _ ->
            "results"


baseOneResult : Lang -> String
baseOneResult lang =
    case lang of 
        Ar ->
            "نتيجة واحدة"

        Bg ->
            "един резултат"

        De ->
            "ein Ergebnis"

        Es ->
            "un resultado"

        Fa ->
            "یک نتیجه"

        Hy ->
            "մեկ արդյունք"

        Ko ->
            "단일 결과"

        Nl ->
            "een resultaat"

        Ru ->
            "один результат"

        Tw ->
            "一个结果"

        Ua ->
            "один результат"

        Zh ->
            "一个结果"

        _ ->
            "one result"


baseNoResult : Lang -> String
baseNoResult lang =
    case lang of 
        Ar ->
            "ولا أي نتيجة"

        Bg ->
            "няма резултати"

        De ->
            "kein Ergebnis"

        Es ->
            "No hay resultados"

        Fa ->
            "هیچ نتیجه ای"

        Hy ->
            "արդյունք չկա"

        Ko ->
            "결과 없음"

        Nl ->
            "Geen resultaten"

        Ru ->
            "нет результатов"

        Tw ->
            "没有结果"

        Ua ->
            "немає результатів"

        Zh ->
            "没有结果"

        _ ->
            "no results"


baseToc : Lang -> String
baseToc lang =
    case lang of 
        Ar ->
            "جدول المحتويات"

        Bg ->
            "Съдържание"

        De ->
            "Inhaltsverzeichnis"

        Es ->
            "índice"

        Fa ->
            "فهرست مطالب"

        Hy ->
            "բովանդակություն"

        Ko ->
            "목차"

        Nl ->
            "Inhoudsopgave"

        Ru ->
            "оглавление"

        Tw ->
            "目錄"

        Ua ->
            "зміст"

        Zh ->
            "目錄"

        _ ->
            "Table of Contents"


baseShow : Lang -> String
baseShow lang =
    case lang of 
        Ar ->
            "إظهار"

        Bg ->
            "показване"

        De ->
            "zeigen"

        Es ->
            "mostrar"

        Fa ->
            "نشان دادن"

        Hy ->
            "ցույց տալ"

        Ko ->
            "보이기"

        Nl ->
            "tonen"

        Ru ->
            "показать"

        Tw ->
            "顯示"

        Ua ->
            "показати"

        Zh ->
            "顯示"

        _ ->
            "show"


baseHide : Lang -> String
baseHide lang =
    case lang of 
        Ar ->
            "إخفاء"

        Bg ->
            "скриване"

        De ->
            "verberghen"

        Es ->
            "ocultar"

        Fa ->
            "پنهان کردن"

        Hy ->
            "թաքցնել"

        Ko ->
            "감추기"

        Nl ->
            "verbergen"

        Ru ->
            "скрыть"

        Tw ->
            "隱藏"

        Ua ->
            "приховати"

        Zh ->
            "隱藏"

        _ ->
            "hide"


baseEditor : Lang -> String
baseEditor lang =
    case lang of 
        Ar ->
            "على غرار المحرر"

        Bg ->
            "редакторски стил"

        De ->
            "Editor-Stil"

        Es ->
            "estilo editor"

        Fa ->
            "به سبک ویرایشگر"

        Hy ->
            "խմբագիր ոճով"

        Ko ->
            "Editor-Style"

        Nl ->
            "editor-stijl"

        Ru ->
            "стиль редактора"

        Tw ->
            "编辑风格"

        Ua ->
            "стиль редактора"

        Zh ->
            "编辑风格"

        _ ->
            "Editor-Style"


baseLang : Lang -> String
baseLang lang =
    case lang of 
        Ar ->
            "العربية"

        Bg ->
            "български"

        De ->
            "Deutsch"

        Es ->
            "Español"

        Fa ->
            "فارسی"

        Hy ->
            "հայերեն"

        Ko ->
            "한국어"

        Nl ->
            "Nederlands"

        Ru ->
            "русский"

        Tw ->
            "中国人"

        Ua ->
            "Український"

        Zh ->
            "中国人"

        _ ->
            "English"


no_translation : Lang -> String
no_translation lang =
    case lang of 
        Ar ->
            "لا يوجد ترجمة حتى الآن"

        Bg ->
            "Без превод"

        De ->
            "noch keine Übersetzungen vorhanden"

        Es ->
            "aún sin traducción"

        Fa ->
            "در دست ترجمه"

        Hy ->
            "դեռ թագմանություն չկա"

        Ko ->
            "번역되지 않음"

        Nl ->
            "noch geen vertaling aanwezig"

        Ru ->
            "перевода пока нет"

        Tw ->
            "尚未翻譯"

        Ua ->
            "переклад відсутній"

        Zh ->
            "尚未翻譯"

        _ ->
            "no translation yet"


translateWithGoogle : Lang -> String
translateWithGoogle lang =
    case lang of 
        Ar ->
            "ترجمة من جوجل (تجريبي)"

        Bg ->
            "Превод с Google (експериментално)"

        De ->
            "Mit Google übersetzen (experimentell)"

        Es ->
            "Traducir con Google (experimental)"

        Fa ->
            "ترجمه با Google (آزمایشی)"

        Hy ->
            "Թարգմանեք Google- ի միջոցով (փորձնական)"

        Ko ->
            "Google 번역을 사용한 번역 결과 (실험적 기능)"

        Nl ->
            "Vertalen met Google (experimenteel)"

        Ru ->
            "Перевести с Google (экспериментально)"

        Tw ->
            "与Google进行翻译（实验性）"

        Ua ->
            "Перекласти за допомогою Google (експериментально)"

        Zh ->
            "与Google进行翻译（实验性）"

        _ ->
            "Translate with Google (experimental)"


cColor : Lang -> String
cColor lang =
    case lang of 
        Ar ->
            "لون"

        Bg ->
            "Цвят"

        De ->
            "Farbe"

        Es ->
            "color"

        Fa ->
            "رنگ"

        Hy ->
            "գույն"

        Ko ->
            "색상"

        Nl ->
            "kleur"

        Ru ->
            "цвет"

        Tw ->
            "顏色"

        Ua ->
            "колір"

        Zh ->
            "顏色"

        _ ->
            "Color"


cSchema : Lang -> String
cSchema lang =
    case lang of 
        Ar ->
            "نظام الألوان"

        Bg ->
            "Цветова схема"

        De ->
            "Farbschema"

        Es ->
            "Esquema de colores"

        Fa ->
            "طرح رنگی"

        Hy ->
            "Գունային սխեման"

        Ko ->
            "색상 스키마"

        Nl ->
            "Kleurenschema"

        Ru ->
            "Цветовая схема"

        Tw ->
            "配色方案"

        Ua ->
            "Кольорова схема"

        Zh ->
            "配色方案"

        _ ->
            "Color scheme"


cDark : Lang -> String
cDark lang =
    case lang of 
        Ar ->
            "الوضع المظلم"

        Bg ->
            "тъмен режим"

        De ->
            "Dunkelmodus"

        Es ->
            "modo oscuro"

        Fa ->
            "حالت تاریک"

        Hy ->
            "մութ ռեժիմ"

        Ko ->
            "어두움"

        Nl ->
            "donkere modus"

        Ru ->
            "темный режим"

        Tw ->
            "暗模式"

        Ua ->
            "темний режим"

        Zh ->
            "暗模式"

        _ ->
            "Dark-Mode"


cBright : Lang -> String
cBright lang =
    case lang of 
        Ar ->
            "وضع الإضاءة"

        Bg ->
            "светъл режим"

        De ->
            "Hellmodus"

        Es ->
            "modo claro"

        Fa ->
            "حالت روشن"

        Hy ->
            "թեթև ռեժիմ"

        Ko ->
            "밝음"

        Nl ->
            "lichte modus"

        Ru ->
            "светлый режим"

        Tw ->
            "亮模式"

        Ua ->
            "світлий режим"

        Zh ->
            "亮模式"

        _ ->
            "Light-Mode"


cDefault : Lang -> String
cDefault lang =
    case lang of 
        Ar ->
            "المعيار الافتراضي"

        Bg ->
            "Подразбиране"

        De ->
            "Standard"

        Es ->
            "defecto"

        Fa ->
            "پیشفرض"

        Hy ->
            "կանխադրված"

        Ko ->
            "기본"

        Nl ->
            "standaard"

        Ru ->
            "стандарт по умолчанию"

        Tw ->
            "預設"

        Ua ->
            "стандартний"

        Zh ->
            "預設"

        _ ->
            "Default"


cBlue : Lang -> String
cBlue lang =
    case lang of 
        Ar ->
            "أزرق"

        Bg ->
            "Синьо"

        De ->
            "Blau"

        Es ->
            "azul"

        Fa ->
            "آبی"

        Hy ->
            "կապույտ"

        Ko ->
            "파랑"

        Nl ->
            "blauw"

        Ru ->
            "синий"

        Tw ->
            "藍色"

        Ua ->
            "синій"

        Zh ->
            "藍色"

        _ ->
            "Blue"


cRed : Lang -> String
cRed lang =
    case lang of 
        Ar ->
            "أحمر"

        Bg ->
            "червен"

        De ->
            "Rot"

        Es ->
            "rojo"

        Fa ->
            "قرمز"

        Hy ->
            "կարմիր"

        Ko ->
            "빨강"

        Nl ->
            "rood"

        Ru ->
            "красный"

        Tw ->
            "红色的"

        Ua ->
            "червоний"

        Zh ->
            "红色的"

        _ ->
            "Red"


cYellow : Lang -> String
cYellow lang =
    case lang of 
        Ar ->
            "أصفر"

        Bg ->
            "жълт"

        De ->
            "Gelb"

        Es ->
            "amarillo"

        Fa ->
            "رنگ زرد"

        Hy ->
            "դեղին"

        Ko ->
            "노랑"

        Nl ->
            "geel"

        Ru ->
            "желтый"

        Tw ->
            "黄色的"

        Ua ->
            "жовтий"

        Zh ->
            "黄色的"

        _ ->
            "Yellow"


cTurquoise : Lang -> String
cTurquoise lang =
    case lang of 
        Ar ->
            "فيروزي"

        Bg ->
            "тюркоаз"

        De ->
            "Türkis"

        Es ->
            "turquesa"

        Fa ->
            "فیروزه"

        Hy ->
            "փիրուզագույն"

        Ko ->
            "청록"

        Nl ->
            "turkoois"

        Ru ->
            "бирюзовый"

        Tw ->
            "绿松石"

        Ua ->
            "бірюзовий"

        Zh ->
            "绿松石"

        _ ->
            "Turquoise"


modeMode : Lang -> String
modeMode lang =
    case lang of 
        Ar ->
            "وضع العرض"

        Bg ->
            "Режим на презентация"

        De ->
            "Präsentationsmodus"

        Es ->
            "Modo presentación"

        Fa ->
            "حالت ارائه"

        Hy ->
            "Ներկայացման ռեժիմ"

        Ko ->
            "프레젠테이션 모드"

        Nl ->
            "Presentatiemodus"

        Ru ->
            "режим презентации"

        Tw ->
            "简报模式"

        Ua ->
            "режим презентації"

        Zh ->
            "简报模式"

        _ ->
            "Presentation mode"


modeTextbook : Lang -> String
modeTextbook lang =
    case lang of 
        Ar ->
            "المقرر"

        Bg ->
            "Текст"

        De ->
            "Lehrbuch"

        Es ->
            "Manual"

        Fa ->
            "کتاب"

        Hy ->
            "գիրք"

        Ko ->
            "텍스트 북"

        Nl ->
            "Studieboek"

        Ru ->
            "чтения"

        Tw ->
            "教科書"

        Ua ->
            "навчальна книга"

        Zh ->
            "教科書"

        _ ->
            "Textbook"


modePresentation : Lang -> String
modePresentation lang =
    case lang of 
        Ar ->
            "العرض"

        Bg ->
            "Презентация"

        De ->
            "Präsentation"

        Es ->
            "Presentación"

        Fa ->
            "ارائه"

        Hy ->
            "ներկայացում"

        Ko ->
            "프레젠테이션"

        Nl ->
            "Presentatie"

        Ru ->
            "презентации"

        Tw ->
            "報告"

        Ua ->
            "презентація"

        Zh ->
            "報告"

        _ ->
            "Presentation"


modeSlides : Lang -> String
modeSlides lang =
    case lang of 
        Ar ->
            "الشرائح"

        Bg ->
            "Слайдове"

        De ->
            "Folien"

        Es ->
            "Imagen"

        Fa ->
            "اسلایدها"

        Hy ->
            "սլայդներ"

        Ko ->
            "슬라이드"

        Nl ->
            "Folies"

        Ru ->
            "слайды"

        Tw ->
            "幻燈片"

        Ua ->
            "слайди"

        Zh ->
            "幻燈片"

        _ ->
            "Slides"


soundOn : Lang -> String
soundOn lang =
    case lang of 
        Ar ->
            "الصوت مفعل"

        Bg ->
            "Звук изкл."

        De ->
            "Sprecher an"

        Es ->
            "Sonido encendido"

        Fa ->
            "صدا روشن"

        Hy ->
            "ձայնով"

        Ko ->
            "소리 켬"

        Nl ->
            "Luidspreker aan"

        Ru ->
            "звук включён"

        Tw ->
            "聲音開啟"

        Ua ->
            "увімкнений"

        Zh ->
            "聲音開啟"

        _ ->
            "Sound on"


soundOff : Lang -> String
soundOff lang =
    case lang of 
        Ar ->
            "الصوت مقفل"

        Bg ->
            "Звук вкл."

        De ->
            "Sprecher aus"

        Es ->
            "Sonido apagado"

        Fa ->
            "صدا خاموش"

        Hy ->
            "առանց ձայն"

        Ko ->
            "소리 끔"

        Nl ->
            "Luidspreker uit"

        Ru ->
            "звук выключен"

        Tw ->
            "聲音關閉"

        Ua ->
            "вимкнений"

        Zh ->
            "聲音關閉"

        _ ->
            "Sound off"


infoAuthor : Lang -> String
infoAuthor lang =
    case lang of 
        Ar ->
            "مؤلف"

        Bg ->
            "Автор: "

        De ->
            "Autor: "

        Es ->
            "Autor"

        Fa ->
            "نویسنده: "

        Hy ->
            "հեղինակ: "

        Ko ->
            "저자: "

        Nl ->
            "Auteur: "

        Ru ->
            "автор: "

        Tw ->
            "作者: "

        Ua ->
            "автор: "

        Zh ->
            "作者: "

        _ ->
            "Author: "


infoDate : Lang -> String
infoDate lang =
    case lang of 
        Ar ->
            "التاريخ"

        Bg ->
            "Дата: "

        De ->
            "Datum: "

        Es ->
            "fecha"

        Fa ->
            "تاریخ: "

        Hy ->
            "ամսաթիվ: "

        Ko ->
            "날짜: "

        Nl ->
            "Datum: "

        Ru ->
            "дата: "

        Tw ->
            "日期: "

        Ua ->
            "дата: "

        Zh ->
            "日期: "

        _ ->
            "Date: "


infoEmail : Lang -> String
infoEmail lang =
    case lang of 
        Ar ->
            "البريد الإلكتروني"

        Bg ->
            "eMail: "

        De ->
            "e-Mail: "

        Es ->
            "email"

        Fa ->
            "ایمیل: "

        Hy ->
            "էլ․ փոստ: "

        Ko ->
            "메일: "

        Nl ->
            "e-email: "

        Ru ->
            "эл. почта: "

        Tw ->
            "電郵: "

        Ua ->
            "електронна пошта: "

        Zh ->
            "電郵: "

        _ ->
            "eMail: "


infoVersion : Lang -> String
infoVersion lang =
    case lang of 
        Ar ->
            "الإصدار: "

        Bg ->
            "Версия: "

        De ->
            "Version: "

        Es ->
            "versión"

        Fa ->
            "نسخه: "

        Hy ->
            "տարբերակ: "

        Ko ->
            "버전: "

        Nl ->
            "Versie: "

        Ru ->
            "версия: "

        Tw ->
            "版本: "

        Ua ->
            "версія: "

        Zh ->
            "版本: "

        _ ->
            "Version: "


confInformation : Lang -> String
confInformation lang =
    case lang of 
        Ar ->
            "معلومات"

        Bg ->
            "Информация"

        De ->
            "Informationen"

        Es ->
            "informaciones"

        Fa ->
            "اطلاعات"

        Hy ->
            "ինֆորմացիա"

        Ko ->
            "정보"

        Nl ->
            "Informatie"

        Ru ->
            "информация"

        Tw ->
            "關於"

        Ua ->
            "інформація"

        Zh ->
            "關於"

        _ ->
            "Information"


confSettings : Lang -> String
confSettings lang =
    case lang of 
        Ar ->
            "اعدادات"

        Bg ->
            "Настройки"

        De ->
            "Einstellungen"

        Es ->
            "configuración"

        Fa ->
            "تنظیمات"

        Hy ->
            "կարգավորումներ"

        Ko ->
            "설정"

        Nl ->
            "Instellingen"

        Ru ->
            "настройки"

        Tw ->
            "設定"

        Ua ->
            "налаштування"

        Zh ->
            "設定"

        _ ->
            "Settings"


confShare : Lang -> String
confShare lang =
    case lang of 
        Ar ->
            "مشاركة"

        Bg ->
            "Споделяне"

        De ->
            "Teilen"

        Es ->
            "compartir"

        Fa ->
            "اشتراک"

        Hy ->
            "կիսվել"

        Ko ->
            "공유"

        Nl ->
            "Delen"

        Ru ->
            "поделиться"

        Tw ->
            "分享"

        Ua ->
            "поділитися"

        Zh ->
            "分享"

        _ ->
            "Share"


confTranslations : Lang -> String
confTranslations lang =
    case lang of 
        Ar ->
            "ترجمة"

        Bg ->
            "Транслации"

        De ->
            "Übersetzungen"

        Es ->
            "traducciones"

        Fa ->
            "ترجمه ها"

        Hy ->
            "թարգմանություններ"

        Ko ->
            "번역"

        Nl ->
            "Vertalingen"

        Ru ->
            "на других языках"

        Tw ->
            "翻譯"

        Ua ->
            "переклади"

        Zh ->
            "翻譯"

        _ ->
            "Translations"


codeExecute : Lang -> String
codeExecute lang =
    case lang of 
        Ar ->
            "تنفيذ"

        Bg ->
            "Изпълни"

        De ->
            "Ausführen"

        Es ->
            "ejecutar"

        Fa ->
            "اجرا"

        Hy ->
            "իրականացնել"

        Ko ->
            "실행"

        Nl ->
            "uitvoeren"

        Ru ->
            "выполнить"

        Tw ->
            "開始執行"

        Ua ->
            "запустити"

        Zh ->
            "開始執行"

        _ ->
            "Execute"


codeRunning : Lang -> String
codeRunning lang =
    case lang of 
        Ar ->
            "إجراء"

        Bg ->
            "Работещ"

        De ->
            "wird ausgeführt"

        Es ->
            "en funcionamiento"

        Fa ->
            "در حال اجرا"

        Hy ->
            "ընթանում է"

        Ko ->
            "실행 중"

        Nl ->
            "wordt uitgevoerd"

        Ru ->
            "выполняется"

        Tw ->
            "執行中"

        Ua ->
            "виконується"

        Zh ->
            "執行中"

        _ ->
            "is running"


codePrev : Lang -> String
codePrev lang =
    case lang of 
        Ar ->
            "الإصدار السابق"

        Bg ->
            "Предишна версия"

        De ->
            "eine Version zurück"

        Es ->
            "versión anterior"

        Fa ->
            "نسخه قبلی"

        Hy ->
            "նախորդ տարբերակը"

        Ko ->
            "이전 버전"

        Nl ->
            "een versie terug"

        Ru ->
            "предыдущая версия"

        Tw ->
            "上一版"

        Ua ->
            "попередня версія"

        Zh ->
            "上一版"

        _ ->
            "previous version"


codeNext : Lang -> String
codeNext lang =
    case lang of 
        Ar ->
            "الإصدار التالي"

        Bg ->
            "следваща версия"

        De ->
            "eine Version vor"

        Es ->
            "versión siguiente"

        Fa ->
            "نسخه بعدی"

        Hy ->
            "հաջորդ տարբերակը"

        Ko ->
            "다음 버전"

        Nl ->
            "een versie vooruit"

        Ru ->
            "следующая версия"

        Tw ->
            "下一版"

        Ua ->
            "наступна версія"

        Zh ->
            "下一版"

        _ ->
            "next version"


codeFirst : Lang -> String
codeFirst lang =
    case lang of 
        Ar ->
            "الإصدار الأول"

        Bg ->
            "Първа версия"

        De ->
            "erste Version"

        Es ->
            "primera versión"

        Fa ->
            "نسخه اولیه"

        Hy ->
            "առաջին տարբերակը"

        Ko ->
            "첫 버전"

        Nl ->
            "eerste versie"

        Ru ->
            "первая версия"

        Tw ->
            "最初版"

        Ua ->
            "перша версія"

        Zh ->
            "最初版"

        _ ->
            "first version"


codeLast : Lang -> String
codeLast lang =
    case lang of 
        Ar ->
            "أحدث إصدار"

        Bg ->
            "Последна версия"

        De ->
            "letzte Version"

        Es ->
            "última versión"

        Fa ->
            "آخرین نسخه"

        Hy ->
            "վերջին տարբերակը"

        Ko ->
            "최신 버전"

        Nl ->
            "laatste versie"

        Ru ->
            "последняя версия"

        Tw ->
            "最終版"

        Ua ->
            "остання версія"

        Zh ->
            "最終版"

        _ ->
            "last version"


codeMinimize : Lang -> String
codeMinimize lang =
    case lang of 
        Ar ->
            "تصغير"

        Bg ->
            "Минимизиране"

        De ->
            "Darstellung minimieren"

        Es ->
            "minimizar vista"

        Fa ->
            "کوچک کردن پنجره"

        Hy ->
            "նվազեցնել տեսքը"

        Ko ->
            "뷰 최소화"

        Nl ->
            "weergave verkleinen"

        Ru ->
            "свернуть"

        Tw ->
            "極小視窗"

        Ua ->
            "зображення зменшити"

        Zh ->
            "極小視窗"

        _ ->
            "minimize view"


codeMaximize : Lang -> String
codeMaximize lang =
    case lang of 
        Ar ->
            "إظهار بالكامل"

        Bg ->
            "Максимизиране"

        De ->
            "Darstellung maximieren"

        Es ->
            "maximinzar vista"

        Fa ->
            "بزرگ کردن پنجره"

        Hy ->
            "բարձրագունել տեսքը"

        Ko ->
            "뷰 최대화"

        Nl ->
            "weergave maximaliseren"

        Ru ->
            "показать полностью"

        Tw ->
            "極大視窗"

        Ua ->
            "зображення збільшити"

        Zh ->
            "極大視窗"

        _ ->
            "maximize view"


codeTerminal : Lang -> String
codeTerminal lang =
    case lang of 
        Ar ->
            "طرفية"

        Bg ->
            "терминал"

        De ->
            "Terminal"

        Fa ->
            "پایانه"

        Hy ->
            "տերմինալ"

        Ko ->
            "terminal"

        Ru ->
            "термина́л"

        Tw ->
            "终端"

        Ua ->
            "термінал"

        Zh ->
            "终端"

        _ ->
            "terminal"


quizCheck : Lang -> String
quizCheck lang =
    case lang of 
        Ar ->
            "تحقق"

        Bg ->
            "Проверка"

        De ->
            "Prüfen"

        Es ->
            "verificar"

        Fa ->
            "بررسی"

        Hy ->
            "ստուգել"

        Ko ->
            "확인"

        Nl ->
            "bekijk"

        Ru ->
            "проверить"

        Tw ->
            "選取"

        Ua ->
            "перевірити"

        Zh ->
            "選取"

        _ ->
            "Check"


quizSolution : Lang -> String
quizSolution lang =
    case lang of 
        Ar ->
            "إظهار الحل"

        Bg ->
            "Отговор"

        De ->
            "zeige Lösung"

        Es ->
            "mostrar solución"

        Fa ->
            "نمایش راهکار"

        Hy ->
            "ցույց տալ լուծումը"

        Ko ->
            "정답 보기"

        Nl ->
            "toon oplossing"

        Ru ->
            "показать решение"

        Tw ->
            "顯示解答"

        Ua ->
            "показати розв'язок"

        Zh ->
            "顯示解答"

        _ ->
            "show solution"


quizHint : Lang -> String
quizHint lang =
    case lang of 
        Ar ->
            "تلميح"

        Bg ->
            "Подсказване"

        De ->
            "Hinweis anzeigen"

        Es ->
            "mostrar indicio"

        Fa ->
            "نمایش یادآوری"

        Hy ->
            "ցուցադրել ակնարկ"

        Ko ->
            "힌트 보기"

        Nl ->
            "toon hint"

        Ru ->
            "подсказка"

        Tw ->
            "暗示"

        Ua ->
            "показати підказку"

        Zh ->
            "暗示"

        _ ->
            "show hint"


quizSelection : Lang -> String
quizSelection lang =
    case lang of 
        Ar ->
            "اختيار"

        Bg ->
            "избор"

        De ->
            "Auswahl"

        Es ->
            "selección"

        Fa ->
            "انتخاب"

        Hy ->
            "ընտրություն"

        Ko ->
            "selection"

        Nl ->
            "selectie"

        Ru ->
            "выбор"

        Tw ->
            "选择"

        Ua ->
            "вибір"

        Zh ->
            "选择"

        _ ->
            "selection"


quizAnswerSuccess : Lang -> String
quizAnswerSuccess lang =
    case lang of 
        Ar ->
            "مبروك هذه كانت الإجابة الصحيحة"

        Bg ->
            "Поздравления, това беше правилният отговор"

        De ->
            "Herzlichen Glückwunsch, das war die richtige Antwort"

        Es ->
            "Felicitaciones, esa fue la respuesta correcta"

        Fa ->
            "تبریک می گویم ، جواب صحیحی بود"

        Hy ->
            "Շնորհավորում եմ, դա ճիշտ պատասխանն էր"

        Ko ->
            "축하합니다. 올바른 답을 선택했습니다."

        Nl ->
            "Gefeliciteerd, dat was het juiste antwoord"

        Ru ->
            "Поздравляю, это был правильный ответ"

        Tw ->
            "恭喜，那是正确的答案"

        Ua ->
            "Вітаю, це була правильна відповідь"

        Zh ->
            "恭喜，那是正确的答案"

        _ ->
            "Congratiulations, that was the right answer"


quizAnswerError : Lang -> String
quizAnswerError lang =
    case lang of 
        Ar ->
            "هذه ليست الإجابة الصحيحة"

        Bg ->
            "Това не е верният отговор"

        De ->
            "Das ist nicht die richtige Antwort"

        Es ->
            "Esa no es la respuesta correcta"

        Fa ->
            "پاسخ درستی نیست"

        Hy ->
            "Դա ճիշտ պատասխան չէ"

        Ko ->
            "선택한 답은 올바르지 않습니다."

        Nl ->
            "Dat is niet het juiste antwoord"

        Ru ->
            "Это не правильный ответ"

        Tw ->
            "那不是正确的答案"

        Ua ->
            "Це не правильна відповідь"

        Zh ->
            "那不是正确的答案"

        _ ->
            "That's not the right answer"


quizAnswerResolved : Lang -> String
quizAnswerResolved lang =
    case lang of 
        Ar ->
            "إجابة تم حلها"

        Bg ->
            "Решен отговор"

        De ->
            "Aufgelöste Antwort"

        Es ->
            "Respuesta resuelta"

        Fa ->
            "پاسخ حل شده"

        Hy ->
            "Լուծված պատասխան"

        Ko ->
            "이미 푼 퀴즈입니다."

        Nl ->
            "Opgelost antwoord"

        Ru ->
            "Решенный ответ"

        Tw ->
            "解决的答案"

        Ua ->
            "Вирішена відповідь"

        Zh ->
            "解决的答案"

        _ ->
            "Resolved answer"


surveySubmit : Lang -> String
surveySubmit lang =
    case lang of 
        Ar ->
            "إرسال "

        Bg ->
            "Изпрати"

        De ->
            "Abschicken"

        Es ->
            "enviar"

        Fa ->
            "ارسال"

        Hy ->
            "ներկայացնել"

        Ko ->
            "제출"

        Nl ->
            "Verzenden"

        Ru ->
            "отправить"

        Tw ->
            "遞交"

        Ua ->
            "відіслати"

        Zh ->
            "遞交"

        _ ->
            "Submit"


surveySubmitted : Lang -> String
surveySubmitted lang =
    case lang of 
        Ar ->
            "تم الإرسال"

        Bg ->
            "Благодаря"

        De ->
            "Dankeshön"

        Es ->
            "enviado"

        Fa ->
            "تشکر"

        Hy ->
            "շնորհակալություն"

        Ko ->
            "감사합니다"

        Nl ->
            "Vriendelijk bedankt"

        Ru ->
            "отправлено"

        Tw ->
            "感謝"

        Ua ->
            "дякую"

        Zh ->
            "感謝"

        _ ->
            "Thanks"


surveyText : Lang -> String
surveyText lang =
    case lang of 
        Ar ->
            "أدخل نص..."

        Bg ->
            "Въведете текст..."

        De ->
            "Texteingabe ..."

        Es ->
            "introducir texto"

        Fa ->
            "لطفا متن وارد کنید"

        Hy ->
            "Մուտքագրեք որոշ տեքստ"

        Ko ->
            "내용을 입력해주세요."

        Nl ->
            "Tekstinvoer ..."

        Ru ->
            "ввод текста"

        Tw ->
            "輸入文字..."

        Ua ->
            "Ввід тексту ..."

        Zh ->
            "輸入文字..."

        _ ->
            "Enter some text..."


sortAsc : Lang -> String
sortAsc lang =
    case lang of 
        Ar ->
            "ترتيب تصاعدي"

        De ->
            "aufsteigend sortieren"

        Es ->
            "orden ascendente"

        Ko ->
            "오름차순 정렬"

        Nl ->
            "oplopend sorteren"

        Ru ->
            "сортировать по возрастанию"

        Ua ->
            "сортування за зростанням"

        _ ->
            "sort ascending"


sortDesc : Lang -> String
sortDesc lang =
    case lang of 
        Ar ->
            "ترتيب تنازلي"

        De ->
            "absteigend sortieren"

        Es ->
            "orden descendiente"

        Ko ->
            "내림차순 정렬"

        Nl ->
            "sorteer aflopend"

        Ru ->
            "сортировка по убыванию"

        Ua ->
            "сортувати за спаданням"

        _ ->
            "sort descending"


sortNot : Lang -> String
sortNot lang =
    case lang of 
        Ar ->
            "غير مرتب"

        De ->
            "nicht sortiert"

        Es ->
            "no ordenado"

        Ko ->
            "정렬 안 됨"

        Nl ->
            "niet gesorteerd"

        Ru ->
            "не отсортировано"

        Ua ->
            "не сортується"

        _ ->
            "not sorted"


chartPie : Lang -> String
chartPie lang =
    case lang of 
        Ar ->
            "مخطط دائري"

        De ->
            "Tortendiagramm"

        Ko ->
            "파이 차트"

        Tw ->
            "饼图"

        Zh ->
            "饼图"

        _ ->
            "Pie chart"


chartBar : Lang -> String
chartBar lang =
    case lang of 
        Ar ->
            "مخطط شريطي"

        De ->
            "Balkendiagramm"

        Ko ->
            "바 차트"

        Tw ->
            "柱状图"

        Zh ->
            "柱状图"

        _ ->
            "Bar chart"


chartLine : Lang -> String
chartLine lang =
    case lang of 
        Ar ->
            "مخطط خطي"

        De ->
            "Liniendiagramm"

        Ko ->
            "라인 차트"

        Tw ->
            "折线图"

        Zh ->
            "折线图"

        _ ->
            "Line chart"


chartScatter : Lang -> String
chartScatter lang =
    case lang of 
        Ar ->
            "مخطط مبعثر"

        De ->
            "Streudiagramm"

        Ko ->
            "분포도"

        Tw ->
            "散点图"

        Zh ->
            "散点图"

        _ ->
            "Scatter plot"


chartEffectScatter : Lang -> String
chartEffectScatter lang =
    case lang of 
        Ar ->
            "مخطط تبعثر تموج"

        De ->
            "Welligkeits-Streudiagramm"

        Ko ->
            "리플 분포도"

        Tw ->
            "涟漪散点图"

        Zh ->
            "涟漪散点图"

        _ ->
            "Ripple scatter plot"


chartRadar : Lang -> String
chartRadar lang =
    case lang of 
        Ar ->
            "مخطط نسيجي"

        De ->
            "Radar-Karte"

        Ko ->
            "레이더 차트"

        Tw ->
            "雷达图"

        Zh ->
            "雷达图"

        _ ->
            "Radar chart"


chartTree : Lang -> String
chartTree lang =
    case lang of 
        Ar ->
            "الشجرة"

        De ->
            "Baum"

        Ko ->
            "트리"

        Tw ->
            "树图"

        Zh ->
            "树图"

        _ ->
            "Tree"


chartTreemap : Lang -> String
chartTreemap lang =
    case lang of 
        Ar ->
            "خريطة الشجرة"

        De ->
            "Baumkarte"

        Ko ->
            "트리맵"

        Tw ->
            "矩形树图"

        Zh ->
            "矩形树图"

        _ ->
            "Treemap"


chartK : Lang -> String
chartK lang =
    case lang of 
        Ar ->
            "مخطط خطي"

        De ->
            "K Liniendiagramm"

        Ko ->
            "K 라인 차트"

        Tw ->
            "K线图"

        Zh ->
            "K线图"

        _ ->
            "K line chart"


chartHeatmap : Lang -> String
chartHeatmap lang =
    case lang of 
        Ar ->
            "خريطة التمثيل اللوني"

        De ->
            "Heatmap"

        Ko ->
            "히트 맵"

        Tw ->
            "热力图"

        Zh ->
            "热力图"

        _ ->
            "Heat map"


chartMap : Lang -> String
chartMap lang =
    case lang of 
        Ar ->
            "خريطة"

        De ->
            "Karte"

        Ko ->
            "맵"

        Tw ->
            "地图"

        Zh ->
            "地图"

        _ ->
            "Map"


chartParallel : Lang -> String
chartParallel lang =
    case lang of 
        Ar ->
            "متوازي"

        De ->
            "Parallele Koordinatenkarte"

        Ko ->
            "평행 좌표 맵"

        Tw ->
            "平行坐标图"

        Zh ->
            "平行坐标图"

        _ ->
            "Parallel coordinate map"


chartLines : Lang -> String
chartLines lang =
    case lang of 
        Ar ->
            "خطوط"

        De ->
            "Liniendiagramm"

        Ko ->
            "선 그래프"

        Tw ->
            "线图"

        Zh ->
            "线图"

        _ ->
            "Line graph"


chartGraph : Lang -> String
chartGraph lang =
    case lang of 
        Ar ->
            "رسم بياني"

        De ->
            "Beziehungsgrafik"

        Ko ->
            "관계도"

        Tw ->
            "关系图"

        Zh ->
            "关系图"

        _ ->
            "Relationship graph"


chartSankey : Lang -> String
chartSankey lang =
    case lang of 
        Ar ->
            "مخطط سانكي"

        De ->
            "Sankey-Diagramm"

        Ko ->
            "생키 다이어그램"

        Tw ->
            "桑基图"

        Zh ->
            "桑基图"

        _ ->
            "Sankey diagram"


chartFunnel : Lang -> String
chartFunnel lang =
    case lang of 
        Ar ->
            "مخطط قمعي"

        De ->
            "Trichterdiagramm"

        Ko ->
            "퍼널 차트"

        Tw ->
            "漏斗图"

        Zh ->
            "漏斗图"

        _ ->
            "Funnel chart"


chartPictorialBar : Lang -> String
chartPictorialBar lang =
    case lang of 
        Ar ->
            "شريط مصور"

        De ->
            "Bildlicher Balken"

        Ko ->
            "픽토리얼 바"

        Tw ->
            "象形柱图"

        Zh ->
            "象形柱图"

        _ ->
            "Pictorial bar"


qrCode : Lang -> String
qrCode lang =
    case lang of 
        Ar ->
            "رمز الاستجابة السريعة للموقع"

        Bg ->
            "QR код за уебсайт"

        De ->
            "QR-Code für Webseite"

        Es ->
            "Código QR para sitio web"

        Fa ->
            "کد QR برای وب سایت"

        Hy ->
            "Վեբ կայքի QR կոդ"

        Ko ->
            "QR code for website"

        Nl ->
            "QR-code voor website"

        Ru ->
            "QR-код для сайта"

        Tw ->
            "网站二维码"

        Ua ->
            "QR -код для веб -сайту"

        Zh ->
            "网站二维码"

        _ ->
            "QR code for website"


qrErr : Lang -> String
qrErr lang =
    case lang of 
        Ar ->
            "خطأ أثناء الترميز إلى رمز الاستجابة السريعة"

        Bg ->
            "Грешка при кодирането към QR код"

        De ->
            "Fehler beim Codieren in QR-Code"

        Es ->
            "Error al codificar en código QR"

        Fa ->
            "خطا هنگام رمزگذاری روی کد QR"

        Hy ->
            "Սխալ QR կոդի կոդավորման ժամանակ"

        Ko ->
            "Error while encoding to QR code"

        Nl ->
            "Fout bij het coderen naar QR-code"

        Ru ->
            "Ошибка при кодировании в QR-код"

        Tw ->
            "编码为二维码时出错"

        Ua ->
            "Помилка під час кодування в QR -код"

        Zh ->
            "编码为二维码时出错"

        _ ->
            "Error while encoding to QR code"


home : Lang -> String
home lang =
    case lang of 
        De ->
            "Übersicht"

        Ko ->
            "Home"

        _ ->
            "Home"


chartBoxplot : Lang -> String
chartBoxplot lang =
    case lang of 
        De ->
            "Boxplot"

        Ko ->
            "상자 그림"

        Tw ->
            "箱型图"

        Zh ->
            "箱型图"

        _ ->
            "Boxplot"


chartCandlestick : Lang -> String
chartCandlestick lang =
    case lang of 
        De ->
            "Kerzenständer"

        Ko ->
            "캔들스틱 차트"

        Tw ->
            "K线图"

        Zh ->
            "K线图"

        _ ->
            "Candlestick"


chartGauge : Lang -> String
chartGauge lang =
    case lang of 
        De ->
            "Meßanzeige"

        Ko ->
            "게이지"

        Tw ->
            "仪表盘图"

        Zh ->
            "仪表盘图"

        _ ->
            "Guage"


chartThemeRiver : Lang -> String
chartThemeRiver lang =
    case lang of 
        De ->
            "Thematische Flusskarte"

        Ko ->
            "테마 리버 맵"

        Tw ->
            "主题河流图"

        Zh ->
            "主题河流图"

        _ ->
            "Theme River Map"


chartSunburst : Lang -> String
chartSunburst lang =
    case lang of 
        De ->
            "Sonnenausbruch"

        Ko ->
            "선버스트 차트"

        Tw ->
            "旭日图"

        Zh ->
            "旭日图"

        _ ->
            "Sunburst"


baseAbc : Lang -> String
baseAbc lang =
    case lang of 
        _ ->
            "Aa"

