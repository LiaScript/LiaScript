module Translations exposing (Lang(..), baseDec, baseFont, baseInc, baseNext, basePrev, baseSearch, baseToc, cAmber, cBlue, cBright, cColor, cDark, cDefault, cGray, cGreen, cPurple, codeExecute, codeFirst, codeLast, codeMaximize, codeMinimize, codeNext, codePrev, codeRunning, confInformations, confSettings, confShare, confTranslations, getLnFromCode, infoAuthor, infoDate, infoEmail, infoVersion, modePresentation, modeSlides, modeTextbook, no_translation, quizCheck, quizChecked, quizHint, quizResolved, quizSolution, soundOff, soundOn, surveySubmit, surveySubmitted, surveyText)


type Lang
    = Bg
    | De
    | En
    | Fa
    | Hy
    | Ua


getLnFromCode : String -> Lang
getLnFromCode code =
    case code of
        "bg" ->
            Bg

        "de" ->
            De

        "en" ->
            En

        "fa" ->
            Fa

        "hy" ->
            Hy

        "ua" ->
            Ua

        _ ->
            En


baseNext : Lang -> String
baseNext lang =
    case lang of
        Bg ->
            "Следващ"

        De ->
            "weiter"

        En ->
            "next"

        Fa ->
            "بعدی"

        Hy ->
            "հաջորդը"

        Ua ->
            "далі"


basePrev : Lang -> String
basePrev lang =
    case lang of
        Bg ->
            "Предишен"

        De ->
            "zurück"

        En ->
            "previous"

        Fa ->
            "قبلی"

        Hy ->
            "նախորդը"

        Ua ->
            "назад"


baseFont : Lang -> String
baseFont lang =
    case lang of
        Bg ->
            "Шрифт"

        De ->
            "Schrift"

        En ->
            "Font"

        Fa ->
            "فونت"

        Hy ->
            "տառատեսակ"

        Ua ->
            "шрифт"


baseDec : Lang -> String
baseDec lang =
    case lang of
        Bg ->
            "Увеличаване"

        De ->
            "verkleinern"

        En ->
            "decrease"

        Fa ->
            "افزودن"

        Hy ->
            "նվազել"

        Ua ->
            "зменшити"


baseInc : Lang -> String
baseInc lang =
    case lang of
        Bg ->
            "Намаляване"

        De ->
            "vergrößern"

        En ->
            "increase"

        Fa ->
            "کاستن"

        Hy ->
            "աճել"

        Ua ->
            "збільшити"


baseSearch : Lang -> String
baseSearch lang =
    case lang of
        Bg ->
            "Търсене"

        De ->
            "Suche"

        En ->
            "Search"

        Fa ->
            "جستجو"

        Hy ->
            "փնտրել"

        Ua ->
            "пошук"


baseToc : Lang -> String
baseToc lang =
    case lang of
        Bg ->
            "Съдържание (показване/скриване)"

        De ->
            "Inhaltsverzeichnis (zeigen/verbergen)"

        En ->
            "Table of Contents (show/hide)"

        Fa ->
            "فهرست مطالب) نمایش/عدم نمایش)"

        Hy ->
            "բովանդակություն (ցույց տալ / թաքցնել)"

        Ua ->
            "зміст (показати/приховати)"


no_translation : Lang -> String
no_translation lang =
    case lang of
        Bg ->
            "Без превод"

        De ->
            "noch keine Übersetzungen vorhanden"

        En ->
            "no translation yet"

        Fa ->
            "در دست ترجمه"

        Hy ->
            "դեռ թագմանություն չկա"

        Ua ->
            "переклад відсутній"


cColor : Lang -> String
cColor lang =
    case lang of
        Bg ->
            "Цвят"

        De ->
            "Farbe"

        En ->
            "Color"

        Fa ->
            "رنگ"

        Hy ->
            "գույն"

        Ua ->
            "колір"


cDark : Lang -> String
cDark lang =
    case lang of
        Bg ->
            "Тъмно"

        De ->
            "Dunkel"

        En ->
            "Dark"

        Fa ->
            "تیره"

        Hy ->
            "մուգ"

        Ua ->
            "темний"


cBright : Lang -> String
cBright lang =
    case lang of
        Bg ->
            "Светло"

        De ->
            "Hell"

        En ->
            "Bright"

        Fa ->
            "روشن"

        Hy ->
            "բաց"

        Ua ->
            "світлий"


cDefault : Lang -> String
cDefault lang =
    case lang of
        Bg ->
            "Подразбиране"

        De ->
            "Standard"

        En ->
            "Default"

        Fa ->
            "پیشفرض"

        Hy ->
            "կանխադրված"

        Ua ->
            "стандартний"


cAmber : Lang -> String
cAmber lang =
    case lang of
        Bg ->
            "Кехлибар"

        De ->
            "Bernstein"

        En ->
            "Amber"

        Fa ->
            "کهربایی"

        Hy ->
            "սաթագույն"

        Ua ->
            "бурштиновий"


cBlue : Lang -> String
cBlue lang =
    case lang of
        Bg ->
            "Синьо"

        De ->
            "Blau"

        En ->
            "Blue"

        Fa ->
            "آبی"

        Hy ->
            "կապույտ"

        Ua ->
            "синій"


cGray : Lang -> String
cGray lang =
    case lang of
        Bg ->
            "Сиво"

        De ->
            "Grau"

        En ->
            "Gray"

        Fa ->
            "خاکستری"

        Hy ->
            "մոխրագույն"

        Ua ->
            "сірий"


cGreen : Lang -> String
cGreen lang =
    case lang of
        Bg ->
            "Зелено"

        De ->
            "Grün"

        En ->
            "Green"

        Fa ->
            "سبز"

        Hy ->
            "կանաչ"

        Ua ->
            "зелений"


cPurple : Lang -> String
cPurple lang =
    case lang of
        Bg ->
            "Лилаво"

        De ->
            "Violett"

        En ->
            "Purple"

        Fa ->
            "بنفش"

        Hy ->
            "մանուշակագույն"

        Ua ->
            "фіолетовий"


modeTextbook : Lang -> String
modeTextbook lang =
    case lang of
        Bg ->
            "Режим: Текст"

        De ->
            "Modus: Lehrbuch"

        En ->
            "Mode: Textbook"

        Fa ->
            "سبک: کتاب"

        Hy ->
            "կերպ: գիրք"

        Ua ->
            "режим: навчальна книга"


modePresentation : Lang -> String
modePresentation lang =
    case lang of
        Bg ->
            "Режим: Презентация"

        De ->
            "Modus: Präsentation"

        En ->
            "Mode: Presentation"

        Fa ->
            "سبک: ارائه"

        Hy ->
            "կերպ: ներկայացում"

        Ua ->
            "режим: презентація"


modeSlides : Lang -> String
modeSlides lang =
    case lang of
        Bg ->
            "Режим: Слайдове"

        De ->
            "Modus: Folien"

        En ->
            "Mode: Slides"

        Fa ->
            "سبک: اسلایدها"

        Hy ->
            "կերպ: սլայդներ"

        Ua ->
            "режим: слайди"


soundOn : Lang -> String
soundOn lang =
    case lang of
        Bg ->
            "Звук изкл."

        De ->
            "Sprecher an"

        En ->
            "Sound on"

        Fa ->
            "صدا روشن"

        Hy ->
            "ձայնով"

        Ua ->
            "увімкнений"


soundOff : Lang -> String
soundOff lang =
    case lang of
        Bg ->
            "Звук вкл."

        De ->
            "Sprecher aus"

        En ->
            "Sound off"

        Fa ->
            "صدا خاموش"

        Hy ->
            "առանց ձայն"

        Ua ->
            "вимкнений"


infoAuthor : Lang -> String
infoAuthor lang =
    case lang of
        Bg ->
            "Автор: "

        De ->
            "Autor: "

        En ->
            "Author: "

        Fa ->
            "نویسنده: "

        Hy ->
            "հեղինակ: "

        Ua ->
            "автор: "


infoDate : Lang -> String
infoDate lang =
    case lang of
        Bg ->
            "Дата: "

        De ->
            "Datum: "

        En ->
            "Date: "

        Fa ->
            "تاریخ: "

        Hy ->
            "ամսաթիվ: "

        Ua ->
            "дата: "


infoEmail : Lang -> String
infoEmail lang =
    case lang of
        Bg ->
            "eMail: "

        De ->
            "e-Mail: "

        En ->
            "eMail: "

        Fa ->
            "ایمیل: "

        Hy ->
            "էլ․ փոստ: "

        Ua ->
            "електронна пошта: "


infoVersion : Lang -> String
infoVersion lang =
    case lang of
        Bg ->
            "Версия: "

        De ->
            "Version: "

        En ->
            "Version: "

        Fa ->
            "نسخه: "

        Hy ->
            "տարբերակ: "

        Ua ->
            "версія: "


confInformations : Lang -> String
confInformations lang =
    case lang of
        Bg ->
            "Информация"

        De ->
            "Informationen"

        En ->
            "Informations"

        Fa ->
            "اطلاعات"

        Hy ->
            "ինֆորմացիա"

        Ua ->
            "інформація"


confSettings : Lang -> String
confSettings lang =
    case lang of
        Bg ->
            "Настройки"

        De ->
            "Einstellungen"

        En ->
            "Settings"

        Fa ->
            "تنظیمات"

        Hy ->
            "կարգավորումներ"

        Ua ->
            "налаштування"


confShare : Lang -> String
confShare lang =
    case lang of
        Bg ->
            "Споделяне"

        De ->
            "Teilen"

        En ->
            "Share"

        Fa ->
            "اشتراک"

        Hy ->
            "կիսվել"

        Ua ->
            "поділитися"


confTranslations : Lang -> String
confTranslations lang =
    case lang of
        Bg ->
            "Транслации"

        De ->
            "Übersetzungen"

        En ->
            "Translations"

        Fa ->
            "ترجمه ها"

        Hy ->
            "թարգմանություններ"

        Ua ->
            "переклади"


codeExecute : Lang -> String
codeExecute lang =
    case lang of
        Bg ->
            "Изпълни"

        De ->
            "Ausführen"

        En ->
            "Execute"

        Fa ->
            "اجرا"

        Hy ->
            "իրականացնել"

        Ua ->
            "запустити"


codeRunning : Lang -> String
codeRunning lang =
    case lang of
        Bg ->
            "Работещ"

        De ->
            "wird ausgeführt"

        En ->
            "is running"

        Fa ->
            "در حال اجرا"

        Hy ->
            "ընթանում է"

        Ua ->
            "виконується"


codePrev : Lang -> String
codePrev lang =
    case lang of
        Bg ->
            "Предишна версия"

        De ->
            "eine Version zurück"

        En ->
            "previous version"

        Fa ->
            "نسخه قبلی"

        Hy ->
            "նախորդ տարբերակը"

        Ua ->
            "попередня версія"


codeNext : Lang -> String
codeNext lang =
    case lang of
        Bg ->
            "следваща версия"

        De ->
            "eine Version vor"

        En ->
            "next version"

        Fa ->
            "نسخه بعدی"

        Hy ->
            "հաջորդ տարբերակը"

        Ua ->
            "наступна версія"


codeFirst : Lang -> String
codeFirst lang =
    case lang of
        Bg ->
            "Първа версия"

        De ->
            "erste Version"

        En ->
            "first version"

        Fa ->
            "نسخه اولیه"

        Hy ->
            "առաջին տարբերակը"

        Ua ->
            "перша версія"


codeLast : Lang -> String
codeLast lang =
    case lang of
        Bg ->
            "Последна версия"

        De ->
            "letzte Version"

        En ->
            "last version"

        Fa ->
            "آخرین نسخه"

        Hy ->
            "վերջին տարբերակը"

        Ua ->
            "остання версія"


codeMinimize : Lang -> String
codeMinimize lang =
    case lang of
        Bg ->
            "Минимизиране"

        De ->
            "Darstellung minimieren"

        En ->
            "minimize view"

        Fa ->
            "کوچک کردن پنجره"

        Hy ->
            "նվազեցնել տեսքը"

        Ua ->
            "зображення зменшити"


codeMaximize : Lang -> String
codeMaximize lang =
    case lang of
        Bg ->
            "Максимизиране"

        De ->
            "Darstellung maximieren"

        En ->
            "maximize view"

        Fa ->
            "بزرگ کردن پنجره"

        Hy ->
            "բարձրագունել տեսքը"

        Ua ->
            "зображення збільшити"


quizCheck : Lang -> String
quizCheck lang =
    case lang of
        Bg ->
            "Проверка"

        De ->
            "Prüfen"

        En ->
            "Check"

        Fa ->
            "بررسی"

        Hy ->
            "ստուգել"

        Ua ->
            "перевірити"


quizChecked : Lang -> String
quizChecked lang =
    case lang of
        Bg ->
            "Проверено"

        De ->
            "Gelöst"

        En ->
            "Checked"

        Fa ->
            "بررسی شده"

        Hy ->
            "ստուգված"

        Ua ->
            "перевірено"


quizSolution : Lang -> String
quizSolution lang =
    case lang of
        Bg ->
            "Отговор"

        De ->
            "zeige Lösung"

        En ->
            "show solution"

        Fa ->
            "نمایش راهکار"

        Hy ->
            "ցույց տալ լուծումը"

        Ua ->
            "показати розв'язок"


quizResolved : Lang -> String
quizResolved lang =
    case lang of
        Bg ->
            "Решено"

        De ->
            "Aufgelöst"

        En ->
            "Resolved"

        Fa ->
            "حل شده"

        Hy ->
            "լուծված է "

        Ua ->
            "розв'язано"


quizHint : Lang -> String
quizHint lang =
    case lang of
        Bg ->
            "Подсказване"

        De ->
            "zeige Hinweis"

        En ->
            "show hint"

        Fa ->
            "نمایش یادآوری"

        Hy ->
            "ցուցադրել ակնարկ"

        Ua ->
            "показати підказку"


surveySubmit : Lang -> String
surveySubmit lang =
    case lang of
        Bg ->
            "Изпрати"

        De ->
            "Abschicken"

        En ->
            "Submit"

        Fa ->
            "ارسال"

        Hy ->
            "ներկայացնել"

        Ua ->
            "відіслати"


surveySubmitted : Lang -> String
surveySubmitted lang =
    case lang of
        Bg ->
            "Благодаря"

        De ->
            "Dankeshön"

        En ->
            "Thanks"

        Fa ->
            "تشکر"

        Hy ->
            "շնորհակալություն"

        Ua ->
            "дякую"


surveyText : Lang -> String
surveyText lang =
    case lang of
        Bg ->
            "Въведете текст..."

        De ->
            "Texteingabe ..."

        En ->
            "Enter some text..."

        Fa ->
            "لطفا متن وارد کنید"

        Hy ->
            "Մուտքագրեք որոշ տեքստ"

        Ua ->
            "Ввід тексту ..."
