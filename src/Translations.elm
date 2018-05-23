module Translations exposing (..)

type Lang
  =  De
  |  En

getLnFromCode: String -> Lang
getLnFromCode code =
   case code of 
      "de" -> De
      "en" -> En
      _ -> En

baseNext: Lang -> String
baseNext lang  =
  case lang of 
      De -> "weiter"
      En -> "next"

basePrev: Lang -> String
basePrev lang  =
  case lang of 
      De -> "zurück"
      En -> "previous"

baseFont: Lang -> String
baseFont lang  =
  case lang of 
      De -> "Schrift"
      En -> "Font"

baseDec: Lang -> String
baseDec lang  =
  case lang of 
      De -> "verkleinern"
      En -> "decrease"

baseInc: Lang -> String
baseInc lang  =
  case lang of 
      De -> "vergrößern"
      En -> "increase"

baseSearch: Lang -> String
baseSearch lang  =
  case lang of 
      De -> "Suche"
      En -> "Search"

baseToc: Lang -> String
baseToc lang  =
  case lang of 
      De -> "Inhaltsverzeichnis (zeigen/verbergen)"
      En -> "Table of Contents (show/hide)"

no_translation: Lang -> String
no_translation lang  =
  case lang of 
      De -> "noch keine Übersetzungen vorhanden"
      En -> "no translation yet"

cColor: Lang -> String
cColor lang  =
  case lang of 
      De -> "Farbe"
      En -> "Color"

cDark: Lang -> String
cDark lang  =
  case lang of 
      De -> "Dunkel"
      En -> "Dark"

cBright: Lang -> String
cBright lang  =
  case lang of 
      De -> "Hell"
      En -> "Bright"

cDefault: Lang -> String
cDefault lang  =
  case lang of 
      De -> "Standard"
      En -> "Default"

cAmber: Lang -> String
cAmber lang  =
  case lang of 
      De -> "Bernstein"
      En -> "Amber"

cBlue: Lang -> String
cBlue lang  =
  case lang of 
      De -> "Blau"
      En -> "Blue"

cGray: Lang -> String
cGray lang  =
  case lang of 
      De -> "Grau"
      En -> "Gray"

cGreen: Lang -> String
cGreen lang  =
  case lang of 
      De -> "Grün"
      En -> "Green"

cPurple: Lang -> String
cPurple lang  =
  case lang of 
      De -> "Violett"
      En -> "Purple"

modeTextbook: Lang -> String
modeTextbook lang  =
  case lang of 
      De -> "Modus: Lehrbuch"
      En -> "Mode: Textbook"

modePresentation: Lang -> String
modePresentation lang  =
  case lang of 
      De -> "Modus: Präsentation"
      En -> "Mode: Presentation"

modeSlides: Lang -> String
modeSlides lang  =
  case lang of 
      De -> "Modus: Folien"
      En -> "Mode: Slides"

soundOn: Lang -> String
soundOn lang  =
  case lang of 
      De -> "Sprecher an"
      En -> "Sound on"

soundOff: Lang -> String
soundOff lang  =
  case lang of 
      De -> "Sprecher aus"
      En -> "Sound off"

infoAuthor: Lang -> String
infoAuthor lang  =
  case lang of 
      De -> "Autor: "
      En -> "Author: "

infoDate: Lang -> String
infoDate lang  =
  case lang of 
      De -> "Datum: "
      En -> "Date: "

infoEmail: Lang -> String
infoEmail lang  =
  case lang of 
      De -> "e-Mail: "
      En -> "eMail: "

infoVersion: Lang -> String
infoVersion lang  =
  case lang of 
      De -> "Version: "
      En -> "Version: "

confInformations: Lang -> String
confInformations lang  =
  case lang of 
      De -> "Informationen"
      En -> "Informations"

confSettings: Lang -> String
confSettings lang  =
  case lang of 
      De -> "Einstellungen"
      En -> "Settings"

confShare: Lang -> String
confShare lang  =
  case lang of 
      De -> "Teilen"
      En -> "Share"

confTranslations: Lang -> String
confTranslations lang  =
  case lang of 
      De -> "Übersetzungen"
      En -> "Translations"

codeExecute: Lang -> String
codeExecute lang  =
  case lang of 
      De -> "Ausführen"
      En -> "Execute"

codeRunning: Lang -> String
codeRunning lang  =
  case lang of 
      De -> "wird ausgeführt"
      En -> "is running"

codePrev: Lang -> String
codePrev lang  =
  case lang of 
      De -> "eine Version zurück"
      En -> "previous version"

codeNext: Lang -> String
codeNext lang  =
  case lang of 
      De -> "eine Version vor"
      En -> "next version"

quizCheck: Lang -> String
quizCheck lang  =
  case lang of 
      De -> "Prüfen"
      En -> "Check"

quizChecked: Lang -> String
quizChecked lang  =
  case lang of 
      De -> "Gelöst"
      En -> "Checked"

quizSolution: Lang -> String
quizSolution lang  =
  case lang of 
      De -> "zeige Lösung"
      En -> "show solution"

quizResolved: Lang -> String
quizResolved lang  =
  case lang of 
      De -> "Aufgelöst"
      En -> "Resolved"

quizHint: Lang -> String
quizHint lang  =
  case lang of 
      De -> "zeige Hinweis"
      En -> "show hint"

surveySubmit: Lang -> String
surveySubmit lang  =
  case lang of 
      De -> "Abschicken"
      En -> "Submit"

surveySubmitted: Lang -> String
surveySubmitted lang  =
  case lang of 
      De -> "Dankeshön"
      En -> "Thanks"

surveyText: Lang -> String
surveyText lang  =
  case lang of 
      De -> "Texteingabe ..."
      En -> "Enter some text..."