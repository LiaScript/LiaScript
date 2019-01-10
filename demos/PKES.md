<!--
author:   André Dietrich

email:    andre.dietrich@ovgu.de

version:  0.0.1

language: de

narrator: Deutsch Female

comment:  Just a simple template for the eLab - CodeRunner api ...

script: https://cdnjs.cloudflare.com/ajax/libs/processing.js/1.6.6/processing.js


@compile_and_run
<script>
events.register("@0", e => {
		if (!e.exit)
    		send.lia("output", e.stdout);
		else
    		send.lia("eval",  "LIA: stop");
});

send.handle("input", (e) => {send.service("@0",  {input: e})});
send.handle("stop",  (e) => {send.service("@0",  {stop: ""})});


send.service("@0", {start: "CodeRunner", settings: null})
.receive("ok", e => {
		send.lia("output", e.message);

		send.service("@0", {files: @4})
		.receive("ok", e => {
				send.lia("output", e.message);

				send.service("@0",  {compile: @1, order: [@2]})
				.receive("ok", e => {
						send.lia("log", e.message, e.details, true);

						send.service("@0",  {execute: @3})
						.receive("ok", e => {
								send.lia("output", e.message);
								send.lia("eval", "LIA: terminal", [], false);
						})
						.receive("error", e => { send.lia("log", e.message, e.details, false); send.lia("eval", "LIA: stop"); });
				})
				.receive("error", e => { send.lia("log", e.message, e.details, false); send.lia("eval", "LIA: stop"); });
		})
		.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });
})
.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });

"LIA: wait";
</script>
@end




-->

# eLab das Projekt


* seit 2017 gefördertes BMBF Forschungsprojekt
* Kooperation zwischen der OVGU und Hochschule Magdeburg-Stendal
* Initiator => Prof. Dr. Sebastian Zug
{{1}}
* **Hauptziel**: _Infrastruktur für den Remotezugriff auf universitäre Hardware_


## Geschichtliches

!?[eLab Version 1](https://www.youtube.com/embed/bICfKRyKTwE)<!-- style="width:800px; height: 440px;"-->

## Zurzeit zwo Teile

```

                eLab
                 |
      ___________|___________
     |                       |
     |                       |
    LIA                   robµlab
     |
     |
 liascript

```

### robµlab

**Ursprüngliches Team:**
* Martin Koppehel
* Fin Christensen
* Leon Wehmeier

**Mit Firmenausgründung:** https://robulab.com

### LIA und liascript

!?[gource](https://www.youtube.com/embed/BDMGNLqc64o)<!-- style="width:800px; height: 440px;"-->

#### Infrastruktur (LIA)

```
  User <----->  LIA  <-----> liascript

                 ^  
                 |
                 |
                 v

              Sevices

                 |
                 |-   CodeRunner
                 |-   robulab
                 |-   database
                 |-   ...

```

#### OpenCourse Development (liascript)

Erweiterter {1}{**live**} Markdown-Parser/Interpreter:

http://LiaScript.github.io

     {{2}}
> Alle Kurse werden öffentlich auf Github.com gehostet und können von euch eingesehen, verbessert oder übersetzt werden.

##### Modi und Text2Speech
<!--
@Tanja: Russian Female
-->

            --{{1}}--
Wähle deine gewünschte Darstellung

{{1}} Präsentation (Sprache und Effekte)

{{2}} Folien (mit Untertiteln und Effekten)

{{3}} Textbuch (nur lesen)

                            --{{4 @Tanja}}--
Первоначально создан в 2004 году Джоном Грубером (англ. John Gruber) и Аароном
Шварцем. Многие идеи языка были позаимствованы из существующих соглашений по
разметке текста в электронных письмах. Реализации языка Markdown преобразуют
текст в формате Markdown в валидный, правильно построенный XHTML и заменяют
левые угловые скобки («<») и амперсанды («&») на соответствующие коды сущностей.

##### Quizze


Wie gefällt mir die Veranstaltung?

[[super]]

                  {{1-2}}
*******************************************
Wie sehr magst du Informatik?

[( )] gar nicht
[( )] es ist ganz okay ...
[(X)] sie ist meine einzig wahre Liebe
*******************************************


                   {{2}}
*******************************************
Muss ich immer alle Fragen beantworten?

[[X]] nein
[[X]] es wäre schöne
[[X]] es ist nur zur persönlichen Kontrolle
[[?]] Wir geben eventuell Hinweise
[[?]] ... vielleicht mehr als einen ...
**********************

Und auch Auflösungen.

**********************

********************************************

##### Surveys

Wir interessieren uns auch für eure Meinung:

War die Übung verständlich? Wo hattet ihr Probleme?

[[____ ____ ____]]


                  {{1-2}}
*******************************************
Wie gut hast du die Verfahren zur Analog-Digital-Wandulung verstanden?

[(1)] nur wenig
[(2)] ganz okay
[(3)] habe alles verstanden und freue mich auf die Prüfung
[(0)] gar nicht
*******************************************


##### Programmieren


``` cpp    -test/header.h
#define TEXT "hello world %d\n"

int test() {
	return 7;
}
```
``` cpp     main.c
#include <stdio.h>
#include "test/header.h"

int main (void) {
	int i = 0;

  for(i=0; i<10; i++)
  	printf (TEXT, i);

	return 0;
}
```
@compile_and_run(ex3, "gcc -Wall main.c -o a.out",`"test/header.h", "main.c"`, "./a.out",```{"main.c": `@input(1)`, "test/header.h": `@input(0)`}```)

##### Programmieren


``` cpp    -test/header.h
#define TEXT "hello world %d\n"

int test() {
	return 7;
}
```
``` cpp     main.c
#include <stdio.h>
#include "test/header.h"

int main (void) {
	int i = 0;

  for(i=0; i<10; i++)
  	printf (TEXT, i);

	return 0;
}
```
@compile_and_run(ex3, "gcc -Wall main.c -o a.out",`"test/header.h", "main.c"`, "./a.out",```{"main.c": `@input(1)`, "test/header.h": `@input(0)`}```)


##### Arduinoview

by Karl Fessel:

https://github.com/fesselk/Arduinoview

## Wie geht es weiter?

1. Eine kleine Einführung in die Oberfläche
2. Ein kleiner Test eurer Programmierfähigkeiten (Sarah Berndt)
