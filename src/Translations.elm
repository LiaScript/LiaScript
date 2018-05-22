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

next: Lang -> String
next lang  =
  case lang of 
      De -> "weiter"
      En -> "next"

previous: Lang -> String
previous lang  =
  case lang of 
      De -> "zurück"
      En -> "previous"

decrease: Lang -> String
decrease lang  =
  case lang of 
      De -> "verkleinern"
      En -> "decrease"

increase: Lang -> String
increase lang  =
  case lang of 
      De -> "vergrößern"
      En -> "increase"

font: Lang -> String
font lang  =
  case lang of 
      De -> "Schrift"
      En -> "Font"

color: Lang -> String
color lang  =
  case lang of 
      De -> "Farbe"
      En -> "Color"

search: Lang -> String
search lang  =
  case lang of 
      De -> "Suche"
      En -> "Search"

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

author: Lang -> String
author lang  =
  case lang of 
      De -> "Autor: "
      En -> "Author: "

version: Lang -> String
version lang  =
  case lang of 
      De -> "Version: "
      En -> "Version: "

email: Lang -> String
email lang  =
  case lang of 
      De -> "e-Mail: "
      En -> "eMail: "

date: Lang -> String
date lang  =
  case lang of 
      De -> "Datum: "
      En -> "Date: "

no_translation: Lang -> String
no_translation lang  =
  case lang of 
      De -> "keine Übersetzungen vorhanden"
      En -> "no translation yet"

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

toc: Lang -> String
toc lang  =
  case lang of 
      De -> "Inhaltsverzeichnis (zeigen/verbergen)"
      En -> "Table of Contents (show/hide)"

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