module Translations exposing (..)

type Lang
  =  De
  |  En
  |  Fa
  |  Ua

getLnFromCode: String -> Lang
getLnFromCode code =
   case code of 
      "de" -> De
      "en" -> En
      "fa" -> Fa
      "ua" -> Ua
      _ -> En

baseNext: Lang -> String
baseNext lang  =
  case lang of 
      De -> "weiter"
      En -> "next"
      Fa -> "بعدی"
      Ua -> "далі"

basePrev: Lang -> String
basePrev lang  =
  case lang of 
      De -> "zurück"
      En -> "previous"
      Fa -> "قبلی"
      Ua -> "назад"

baseFont: Lang -> String
baseFont lang  =
  case lang of 
      De -> "Schrift"
      En -> "Font"
      Fa -> "فونت"
      Ua -> "шрифт"

baseDec: Lang -> String
baseDec lang  =
  case lang of 
      De -> "verkleinern"
      En -> "decrease"
      Fa -> "افزودن"
      Ua -> "зменшити"

baseInc: Lang -> String
baseInc lang  =
  case lang of 
      De -> "vergrößern"
      En -> "increase"
      Fa -> "کاستن"
      Ua -> "збільшити"

baseSearch: Lang -> String
baseSearch lang  =
  case lang of 
      De -> "Suche"
      En -> "Search"
      Fa -> "جستجو"
      Ua -> "пошук"

baseToc: Lang -> String
baseToc lang  =
  case lang of 
      De -> "Inhaltsverzeichnis (zeigen/verbergen)"
      En -> "Table of Contents (show/hide)"
      Fa -> "فهرست مطالب) نمایش/عدم نمایش)"
      Ua -> "зміст (показати/приховати)"

no_translation: Lang -> String
no_translation lang  =
  case lang of 
      De -> "noch keine Übersetzungen vorhanden"
      En -> "no translation yet"
      Fa -> "در دست ترجمه"
      Ua -> "переклад відсутній"

cColor: Lang -> String
cColor lang  =
  case lang of 
      De -> "Farbe"
      En -> "Color"
      Fa -> "رنگ"
      Ua -> "колір"

cDark: Lang -> String
cDark lang  =
  case lang of 
      De -> "Dunkel"
      En -> "Dark"
      Fa -> "تیره"
      Ua -> "темний"

cBright: Lang -> String
cBright lang  =
  case lang of 
      De -> "Hell"
      En -> "Bright"
      Fa -> "روشن"
      Ua -> "світлий"

cDefault: Lang -> String
cDefault lang  =
  case lang of 
      De -> "Standard"
      En -> "Default"
      Fa -> "پیشفرض"
      Ua -> "стандартний"

cAmber: Lang -> String
cAmber lang  =
  case lang of 
      De -> "Bernstein"
      En -> "Amber"
      Fa -> "کهربایی"
      Ua -> "бурштиновий"

cBlue: Lang -> String
cBlue lang  =
  case lang of 
      De -> "Blau"
      En -> "Blue"
      Fa -> "آبی"
      Ua -> "синій"

cGray: Lang -> String
cGray lang  =
  case lang of 
      De -> "Grau"
      En -> "Gray"
      Fa -> "خاکستری"
      Ua -> "сірий"

cGreen: Lang -> String
cGreen lang  =
  case lang of 
      De -> "Grün"
      En -> "Green"
      Fa -> "سبز"
      Ua -> "зелений"

cPurple: Lang -> String
cPurple lang  =
  case lang of 
      De -> "Violett"
      En -> "Purple"
      Fa -> "بنفش"
      Ua -> "фіолетовий"

modeTextbook: Lang -> String
modeTextbook lang  =
  case lang of 
      De -> "Modus: Lehrbuch"
      En -> "Mode: Textbook"
      Fa -> "سبک: کتاب"
      Ua -> "режим: навчальна книга"

modePresentation: Lang -> String
modePresentation lang  =
  case lang of 
      De -> "Modus: Präsentation"
      En -> "Mode: Presentation"
      Fa -> "سبک: ارائه"
      Ua -> "режим: презентація"

modeSlides: Lang -> String
modeSlides lang  =
  case lang of 
      De -> "Modus: Folien"
      En -> "Mode: Slides"
      Fa -> "سبک: اسلایدها"
      Ua -> "режим: слайди"

soundOn: Lang -> String
soundOn lang  =
  case lang of 
      De -> "Sprecher an"
      En -> "Sound on"
      Fa -> "صدا روشن"
      Ua -> "увімкнений"

soundOff: Lang -> String
soundOff lang  =
  case lang of 
      De -> "Sprecher aus"
      En -> "Sound off"
      Fa -> "صدا خاموش"
      Ua -> "вимкнений"

infoAuthor: Lang -> String
infoAuthor lang  =
  case lang of 
      De -> "Autor: "
      En -> "Author: "
      Fa -> "نویسنده: "
      Ua -> "автор: "

infoDate: Lang -> String
infoDate lang  =
  case lang of 
      De -> "Datum: "
      En -> "Date: "
      Fa -> "تاریخ: "
      Ua -> "дата: "

infoEmail: Lang -> String
infoEmail lang  =
  case lang of 
      De -> "e-Mail: "
      En -> "eMail: "
      Fa -> "ایمیل: "
      Ua -> "електронна пошта: "

infoVersion: Lang -> String
infoVersion lang  =
  case lang of 
      De -> "Version: "
      En -> "Version: "
      Fa -> "نسخه: "
      Ua -> "версія: "

confInformations: Lang -> String
confInformations lang  =
  case lang of 
      De -> "Informationen"
      En -> "Informations"
      Fa -> "اطلاعات"
      Ua -> "інформація"

confSettings: Lang -> String
confSettings lang  =
  case lang of 
      De -> "Einstellungen"
      En -> "Settings"
      Fa -> "تنظیمات"
      Ua -> "налаштування"

confShare: Lang -> String
confShare lang  =
  case lang of 
      De -> "Teilen"
      En -> "Share"
      Fa -> "اشتراک"
      Ua -> "поділитися"

confTranslations: Lang -> String
confTranslations lang  =
  case lang of 
      De -> "Übersetzungen"
      En -> "Translations"
      Fa -> "ترجمه ها"
      Ua -> "переклади"

codeExecute: Lang -> String
codeExecute lang  =
  case lang of 
      De -> "Ausführen"
      En -> "Execute"
      Fa -> "اجرا"
      Ua -> "запустити"

codeRunning: Lang -> String
codeRunning lang  =
  case lang of 
      De -> "wird ausgeführt"
      En -> "is running"
      Fa -> "در حال اجرا"
      Ua -> "виконується"

codePrev: Lang -> String
codePrev lang  =
  case lang of 
      De -> "eine Version zurück"
      En -> "previous version"
      Fa -> "نسخه قبلی"
      Ua -> "попередня версія"

codeNext: Lang -> String
codeNext lang  =
  case lang of 
      De -> "eine Version vor"
      En -> "next version"
      Fa -> "نسخه بعدی"
      Ua -> "наступна версія"

codeFirst: Lang -> String
codeFirst lang  =
  case lang of 
      De -> "erste Version"
      En -> "first version"
      Fa -> "نسخه اولیه"
      Ua -> "перша версія"

codeLast: Lang -> String
codeLast lang  =
  case lang of 
      De -> "letzte Version"
      En -> "last version"
      Fa -> "آخرین نسخه"
      Ua -> "остання версія"

codeMinimize: Lang -> String
codeMinimize lang  =
  case lang of 
      De -> "Darstellung minimieren"
      En -> "minimize view"
      Fa -> "کوچک کردن پنجره"
      Ua -> "зображення зменшити"

codeMaximize: Lang -> String
codeMaximize lang  =
  case lang of 
      De -> "Darstellung maximieren"
      En -> "maximize view"
      Fa -> "بزرگ کردن پنجره"
      Ua -> "зображення збільшити"

quizCheck: Lang -> String
quizCheck lang  =
  case lang of 
      De -> "Prüfen"
      En -> "Check"
      Fa -> "بررسی"
      Ua -> "перевірити"

quizChecked: Lang -> String
quizChecked lang  =
  case lang of 
      De -> "Gelöst"
      En -> "Checked"
      Fa -> "بررسی شده"
      Ua -> "перевірено"

quizSolution: Lang -> String
quizSolution lang  =
  case lang of 
      De -> "zeige Lösung"
      En -> "show solution"
      Fa -> "نمایش راهکار"
      Ua -> "показати розв'язок"

quizResolved: Lang -> String
quizResolved lang  =
  case lang of 
      De -> "Aufgelöst"
      En -> "Resolved"
      Fa -> "حل شده"
      Ua -> "розв'язано"

quizHint: Lang -> String
quizHint lang  =
  case lang of 
      De -> "zeige Hinweis"
      En -> "show hint"
      Fa -> "نمایش یادآوری"
      Ua -> "показати підказку"

surveySubmit: Lang -> String
surveySubmit lang  =
  case lang of 
      De -> "Abschicken"
      En -> "Submit"
      Fa -> "ارسال"
      Ua -> "відіслати"

surveySubmitted: Lang -> String
surveySubmitted lang  =
  case lang of 
      De -> "Dankeshön"
      En -> "Thanks"
      Fa -> "تشکر"
      Ua -> "дякую"

surveyText: Lang -> String
surveyText lang  =
  case lang of 
      De -> "Texteingabe ..."
      En -> "Enter some text..."
      Fa -> "لطفا متن وارد کنید"
      Ua -> "Ввід тексту ..."