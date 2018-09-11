module Translations exposing (..)

type Lang
  =  De
  |  En
  |  Ua

getLnFromCode: String -> Lang
getLnFromCode code =
   case code of 
      "de" -> De
      "en" -> En
      "ua" -> Ua
      _ -> En

baseNext: Lang -> String
baseNext lang  =
  case lang of 
      De -> "weiter"
      En -> "next"
      Ua -> "далі"

basePrev: Lang -> String
basePrev lang  =
  case lang of 
      De -> "zurück"
      En -> "previous"
      Ua -> "назад"

baseFont: Lang -> String
baseFont lang  =
  case lang of 
      De -> "Schrift"
      En -> "Font"
      Ua -> "шрифт"

baseDec: Lang -> String
baseDec lang  =
  case lang of 
      De -> "verkleinern"
      En -> "decrease"
      Ua -> "зменшити"

baseInc: Lang -> String
baseInc lang  =
  case lang of 
      De -> "vergrößern"
      En -> "increase"
      Ua -> "збільшити"

baseSearch: Lang -> String
baseSearch lang  =
  case lang of 
      De -> "Suche"
      En -> "Search"
      Ua -> "пошук"

baseToc: Lang -> String
baseToc lang  =
  case lang of 
      De -> "Inhaltsverzeichnis (zeigen/verbergen)"
      En -> "Table of Contents (show/hide)"
      Ua -> "зміст (показати/приховати)"

no_translation: Lang -> String
no_translation lang  =
  case lang of 
      De -> "noch keine Übersetzungen vorhanden"
      En -> "no translation yet"
      Ua -> "переклад відсутній"

cColor: Lang -> String
cColor lang  =
  case lang of 
      De -> "Farbe"
      En -> "Color"
      Ua -> "колір"

cDark: Lang -> String
cDark lang  =
  case lang of 
      De -> "Dunkel"
      En -> "Dark"
      Ua -> "темний"

cBright: Lang -> String
cBright lang  =
  case lang of 
      De -> "Hell"
      En -> "Bright"
      Ua -> "світлий"

cDefault: Lang -> String
cDefault lang  =
  case lang of 
      De -> "Standard"
      En -> "Default"
      Ua -> "стандартний"

cAmber: Lang -> String
cAmber lang  =
  case lang of 
      De -> "Bernstein"
      En -> "Amber"
      Ua -> "бурштиновий"

cBlue: Lang -> String
cBlue lang  =
  case lang of 
      De -> "Blau"
      En -> "Blue"
      Ua -> "синій"

cGray: Lang -> String
cGray lang  =
  case lang of 
      De -> "Grau"
      En -> "Gray"
      Ua -> "сірий"

cGreen: Lang -> String
cGreen lang  =
  case lang of 
      De -> "Grün"
      En -> "Green"
      Ua -> "зелений"

cPurple: Lang -> String
cPurple lang  =
  case lang of 
      De -> "Violett"
      En -> "Purple"
      Ua -> "фіолетовий"

modeTextbook: Lang -> String
modeTextbook lang  =
  case lang of 
      De -> "Modus: Lehrbuch"
      En -> "Mode: Textbook"
      Ua -> "режим: навчальна книга"

modePresentation: Lang -> String
modePresentation lang  =
  case lang of 
      De -> "Modus: Präsentation"
      En -> "Mode: Presentation"
      Ua -> "режим: презентація"

modeSlides: Lang -> String
modeSlides lang  =
  case lang of 
      De -> "Modus: Folien"
      En -> "Mode: Slides"
      Ua -> "режим: слайди"

soundOn: Lang -> String
soundOn lang  =
  case lang of 
      De -> "Sprecher an"
      En -> "Sound on"
      Ua -> "увімкнений"

soundOff: Lang -> String
soundOff lang  =
  case lang of 
      De -> "Sprecher aus"
      En -> "Sound off"
      Ua -> "вимкнений"

infoAuthor: Lang -> String
infoAuthor lang  =
  case lang of 
      De -> "Autor: "
      En -> "Author: "
      Ua -> "автор: "

infoDate: Lang -> String
infoDate lang  =
  case lang of 
      De -> "Datum: "
      En -> "Date: "
      Ua -> "дата: "

infoEmail: Lang -> String
infoEmail lang  =
  case lang of 
      De -> "e-Mail: "
      En -> "eMail: "
      Ua -> "електронна пошта: "

infoVersion: Lang -> String
infoVersion lang  =
  case lang of 
      De -> "Version: "
      En -> "Version: "
      Ua -> "версія: "

confInformations: Lang -> String
confInformations lang  =
  case lang of 
      De -> "Informationen"
      En -> "Informations"
      Ua -> "інформація"

confSettings: Lang -> String
confSettings lang  =
  case lang of 
      De -> "Einstellungen"
      En -> "Settings"
      Ua -> "налаштування"

confShare: Lang -> String
confShare lang  =
  case lang of 
      De -> "Teilen"
      En -> "Share"
      Ua -> "поділитися"

confTranslations: Lang -> String
confTranslations lang  =
  case lang of 
      De -> "Übersetzungen"
      En -> "Translations"
      Ua -> "переклади"

codeExecute: Lang -> String
codeExecute lang  =
  case lang of 
      De -> "Ausführen"
      En -> "Execute"
      Ua -> "запустити"

codeRunning: Lang -> String
codeRunning lang  =
  case lang of 
      De -> "wird ausgeführt"
      En -> "is running"
      Ua -> "виконується"

codePrev: Lang -> String
codePrev lang  =
  case lang of 
      De -> "eine Version zurück"
      En -> "previous version"
      Ua -> "попередня версія"

codeNext: Lang -> String
codeNext lang  =
  case lang of 
      De -> "eine Version vor"
      En -> "next version"
      Ua -> "наступна версія"

codeFirst: Lang -> String
codeFirst lang  =
  case lang of 
      De -> "erste Version"
      En -> "first version"
      Ua -> "перша версія"

codeLast: Lang -> String
codeLast lang  =
  case lang of 
      De -> "letzte Version"
      En -> "last version"
      Ua -> "остання версія"

codeMinimize: Lang -> String
codeMinimize lang  =
  case lang of 
      De -> "Darstellung minimieren"
      En -> "minimize view"
      Ua -> "зображення зменшити"

codeMaximize: Lang -> String
codeMaximize lang  =
  case lang of 
      De -> "Darstellung maximieren"
      En -> "maximize view"
      Ua -> "зображення збільшити"

quizCheck: Lang -> String
quizCheck lang  =
  case lang of 
      De -> "Prüfen"
      En -> "Check"
      Ua -> "перевірити"

quizChecked: Lang -> String
quizChecked lang  =
  case lang of 
      De -> "Gelöst"
      En -> "Checked"
      Ua -> "перевірено"

quizSolution: Lang -> String
quizSolution lang  =
  case lang of 
      De -> "zeige Lösung"
      En -> "show solution"
      Ua -> "показати розв'язок"

quizResolved: Lang -> String
quizResolved lang  =
  case lang of 
      De -> "Aufgelöst"
      En -> "Resolved"
      Ua -> "розв'язано"

quizHint: Lang -> String
quizHint lang  =
  case lang of 
      De -> "zeige Hinweis"
      En -> "show hint"
      Ua -> "показати підказку"

surveySubmit: Lang -> String
surveySubmit lang  =
  case lang of 
      De -> "Abschicken"
      En -> "Submit"
      Ua -> "відіслати"

surveySubmitted: Lang -> String
surveySubmitted lang  =
  case lang of 
      De -> "Dankeshön"
      En -> "Thanks"
      Ua -> "дякую"

surveyText: Lang -> String
surveyText lang  =
  case lang of 
      De -> "Texteingabe ..."
      En -> "Enter some text..."
      Ua -> "Ввід тексту ..."