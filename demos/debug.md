<!--
author:   André Dietrich

version:  0.0.1

language: de

narrator: Deutsch Female

script:   https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js

@eval
<script>
//var result = null;
var error  = false;

console.log = function(e){ send.lia("log", JSON.stringify(e), [], true); };

function grep_error(output) {
  let errors = output.match(/:(\d+):(\d+): error: (.+)/g);

  let i = 0;
  for(i = 0; i < errors.length; i++) {
      let e = errors[i].match(/:(\d+):(\d+): error: (.+)/i);

      errors[i] = { row : e[1]-1, column : e[2], text : e[3], type : "error"};
  }
  return errors;
}

function grep_warning(output) {
  let errors = output.match(/:(\d+):(\d+): warning: (.+)/g);

  let i = 0;
  for(i = 0; i < errors.length; i++) {
      let e = errors[i].match(/:(\d+):(\d+): warning: (.+)/i);

      errors[i] = { row: e[1]-1, column : e[2], text : e[3], type : "warning"};
  }
  return errors;
}


$.ajax ({
    url: "https://rextester.com/rundotnet/api",
    type: "POST",
    timeout: 10000,
    data: { LanguageChoice: @0,
            Program: `@input`,
            Input: `@1`,
            CompilerArgs : @2}
    }).done(function(data) {
        if (data.Errors == null) {

/*
            let warnigs = [];

            if(data.Warnings)
              warnings = [grep_warning(data.Warnings)];

            send.lia("log", data.Result+"\n-------------------\n"+data.Stats.replace(/, /g, "\n"), warnings, true);
            send.lia("eval", "LIA: stop");  
*/
            send.lia("eval", data.Result+"\n-------------------\n"+data.Stats.replace(/, /g, "\n"));
        } else {
            let errors = grep_error(data.Errors);

            send.lia("log",
                     data.Errors+"\n-------------------\n"+data.Stats.replace(/, /g, "\n"),
                     [errors], false);

            send.lia("eval", "LIA: stop");
        }
    }).fail(function(data, err) {
        send.lia("log", err, [], false);
        send.lia("eval", "LIA: stop");
    });

"LIA: wait"
</script>
@end

@run: @eval(6, ,"-Wall -std=gnu99 -O2 -o a.out source_file.c")

@run_stdin: @eval(6,`@input(1)`,"-Wall -std=gnu99 -O2 -o a.out source_file.c")

-->




# C-Programmierung

Dies ist eine Portierung des Wikibuches
[C-Programmierung](https://de.wikibooks.org/wiki/C-Programmierung) nach
[LiaScript](https://LiaScript.github.io), eine erweiterte Markdown-Notation für
zur Erstellung von freien online-Kursen. Aber warum sollte man sowas tun? Ein
freies Buch in ein anderes freies Format zu übersetzen ...


Die Antwort ist ganz einfach, jeder kann diesen Kurs forken und verändern und
seine eigene Version davon erstellen und das coolste ist ... viele der Beispiele
können im Browser ausgeführt und verändert werden. Siehe hier:

https://liascript.github.io/course/?https://raw.githubusercontent.com/andre-dietrich/C-Programmierung/master/README.md

Um die Beispielprogramme in diesem Buch ausführbar zu gestalten, wird auf die
kostenlose und nicht kommerzielle API von https://rextester.com zurückgegriffen.

Wenn jemand dieses Projekt gut findet, dann kann er hier dafür spenden:

https://rextester.com/main

## Vorwort

Dieses Buch hat sich zum Ziel gesetzt, den Anwendern eine Einführung in C zu
bieten, die noch keine oder eine geringe Programmiererfahrung haben. Es werden
lediglich die grundlegenden Kenntnisse im Umgang mit dem Betriebssystem
gefordert.

Allerdings soll auch nicht verschwiegen werden, dass das Lernen von C und auch
das Programmieren in C viel Disziplin fordert. Die Sprache C wurde in den frühen
70er Jahren entwickelt, um das Betriebssystem UNIX nicht mehr in der
fehleranfälligen Assemblersprache schreiben zu müssen. Die ersten Programmierer
von C kannten sich sehr gut mit den Maschinen aus, auf denen sie programmierten.
Deshalb, und aus Geschwindigkeitsgründen, verzichteten sie auf so manche
Sprachmittel, mit denen Programmierfehler leichter erkannt werden können. Selbst
die mehr als 30 Jahre, die seitdem vergangen sind, konnten viele dieser Fehler
nicht ausbügeln, und so ist C mittlerweile eine recht komplizierte,
fehleranfällige Programmiersprache. Trotzdem wird sie in sehr vielen Projekten
eingesetzt, und vielleicht ist gerade das ja auch der Grund, warum Sie diese
Sprache lernen möchten.

Wenn Sie wenig oder keine Programmiererfahrung haben, ist es sehr
wahrscheinlich, dass Sie nicht alles auf Anhieb verstehen. Es ist sehr schwer,
die Sprache C so zu erklären, dass nicht irgendwo vorgegriffen werden muss.
Kehren Sie also hin und wieder zurück und versuchen Sie nicht, alles auf Anhieb
zu verstehen. Wenn Sie am Ball bleiben, wird Ihnen im Laufe der Zeit vieles
klarer werden.

Außerdem sei an dieser Stelle auf das Literatur- und Webverzeichnis hingewiesen.
Hier finden Sie weitere Informationen, die zum Nachschlagen, aber auch als
weitere Einstiegshilfe gedacht sind.

Das besondere an diesem Buch ist aber zweifellos, dass es nach dem Wikiprinzip
erstellt wurde. Das heißt, jeder kann Verbesserungen an diesem Buch vornehmen.
Momentan finden fast jeden Tag irgendwelche Änderungen statt. Es lohnt sich
also, hin und wieder vorbeizuschauen und nachzusehen, ob etwas verbessert wurde.

Auch Sie als Anfänger können dazu beitragen, dass das Buch immer weiter
verbessert wird. Auf den Diskussionsseiten können Sie Verbesserungsvorschläge
unterbreiten. Wenn Sie bereits ein Kenner von C sind, können Sie Änderungen oder
Ergänzungen vornehmen. Mehr über das Wikiprinzip und Wikibooks erfahren sie im
Wikibooks-Lehrbuch.

## Über dieses Buch

### Formatierung

In diesem Dokument werden folgende Formatierungen unterschieden. Der Quelltext
wird auf die folgende Weise dargestellt:

``` c
#include <stdio.h>
#include <stdlib.h>

int main()
{
        int * ptr;

        ptr = malloc(sizeof * ptr);

        if (!ptr) {
                printf("Speicher kann nicht bereitgestellt werden\n");
        } else {
                printf("Speicher bereitgestellt\n");
                * ptr = 70;
                free(ptr);
        }

        return EXIT_SUCCESS;
}
```
@run

Bitte beachten Sie, dass die Zeilennummern nicht zum Programm dazugehören,
sondern lediglich zur einfacheren Programmbesprechung dienen. Momentan gibt es
noch keine Möglichkeit, die Beispielprogramme herunterzuladen. Wenn möglich,
soll sich dies aber in Zukunft ändern.

Ausgaben eines Programms auf dem Bildschirm werden wie folgt dargestellt:

```
Speicher bereitgestellt
```

Neue wichtige Begriffe werden durch _kursive Schrift_ hervorgehoben

### Was benötige ich, um dieses Buch zu lesen?

Vorkenntnisse im Programmieren sind nicht erforderlich. Allerdings sollten Sie
den Umgang mit Ihrem Betriebssystem sicher beherrschen. Es wird beispielsweise
nicht mehr erklärt, was ein Editor ist und wie er funktioniert. Außerdem sollten
Sie sich schon etwas mit der Hardware des Computers beschäftigt haben.
Beispielsweise wird in diesem Buch nicht mehr erklärt, was eine Binärzahl
(Dualzahl) ist oder was man unter dem Arbeitsspeicher versteht. Sie werden
allerdings feststellen, dass die Anforderungen an Ihre Vorkenntnisse relativ
niedrig gehalten werden.

Außerdem benötigen Sie natürlich einen Compiler, um die Beispiele zu übersetzen
und selbst zu üben. Im Anhang finden Sie eine Liste von C-Compilern. Für die
meisten Betriebssysteme finden Sie dort auch kostenlose Open-Source- oder
Freeware-Software.

Auch die meisten C++-Compiler können C-Programme übersetzen. Allerdings
unterscheiden sich C++ und C in einigen Punkten. Wir werden versuchen, auf diese
Unterschiede einzugehen. Es kann jedoch sein, dass dies nicht vollständig
geschieht. Unter Umständen wird das Erlernen von C erschwert, wenn der von Ihnen
verwendete Compiler ein anderes Verhalten zeigt als das hier beschriebene.

Der C-Standard unterscheidet außerdem zwischen hosted environment und
freestanding environment. Ein Programm, das in einem Freestanding Environment
läuft, muss nicht von einem Betriebssystem aufgerufen werden, und der Startpunkt
des Programms ist nicht festgelegt. (Wie wir im nächsten Kapitel noch sehen
werden ist der Startpunkt in einem Hosted Environment immer `main.`) Außerdem
ist es implementierungsabhängig, welche Funktionen der Standardbibliothek
verfügbar sind. Freestanding Environments sind beispielsweise Embedded Systems
oder das Betriebssystem selbst. Da diese Umgebungen kaum geeignet sind, um das
Programmieren mit C zu erlernen, werden wir in diesem Buch nur auf Hosted
Environments eingehen und auch die Unterschiede nicht weiter erörtern. Wir
wollen an dieser Stelle lediglich aufzeigen, dass es einen Unterschied gibt,
falls Sie im Zusammenhang mit C auf diesen Begriff stoßen.

### Verwendete Begriffe in diesem Buch

Viele Begriffe lassen sich ins Deutsche unterschiedlich übersetzen. Andere
Begriffe werden überhaupt nicht übersetzt, weil das englische Wort auch in der
deutschen Sprache gebräuchlich ist. In diesem Buch werden wir uns weitestgehend
an die deutschsprachige zweite Auflage von "The C Programming Language" von
Brian Kernighan und Dennis Ritchie halten, übersetzen jedoch einige Begriffe
nicht, wenn diese auch in der deutschen Sprache verbreitet sind. Hier ist eine
(unvollständige) Liste der in diesem Buch verwendeten Begriffe und eine kurze
Begründung, warum diese verwendet worden sind:

* Compiler: In der deutschsprachigen zweiten Auflage von "The C Programming
  Language" wurde der Begriff "Übersetzer" verwendet. "Compiler" wird in diesem
  Zusammenhang allerdings wesentlich häufiger gebraucht und eine Übersetzung des
  Begriffs erscheint eher künstlich.
* Deklaration und Definition: Beide Begriffe werden streng unterschieden.
* Vereinbarung: Wird wie in der deutschsprachigen Auflage von "The C Programming
  Language" als Überbegriff von Deklaration und Definition verwendet
* Array: Die gebräuchlichsten Worte hierfür sind Feld, Vektor und Array. Wir
  verwenden den Begriff Array, da er im ANSI-C-Standard so verwendet wird und
  auch in der deutschen Sprache ebenfalls gebräuchlich ist.
* Vorrang: Momentan wird noch der Begriff Rangfolge verwendet. Dies soll aber
  geändert werden, um in Zukunft der deutschsprachigen Ausgabe von "The C
  Programming Language" zu entsprechen.
* Umwandlungszeichen: Für das `i` bzw. `f` in `%i` bzw. `%f` usw. wird das Wort
  Umwandlungszeichen wie in der deutschsprachigen Ausgabe von K&R benutzt. Der
  Standard spricht von einem conversion modifier was wörtlich übersetzt
  Konvertierungsmodifikator heißen würde, sich im Deutschen aber seltsam anhört.

Alle hier aufgelisteten Begriffe werden natürlich noch im Folgenden erklärt.
Diese Liste soll nur aufzeigen, warum bestimmte Begriffe hier so und nicht
anders verwendet worden sind.

### Zusammenfassung des Projekts

* Zielgruppe: Das Buch richtet sich an Programmieranfänger. Erklärungen sollen
  deshalb möglichst leicht verständlich sein.
* Projektumfang: Dieses Buch beschäftigt sich ausschließlich mit ANSI-C.
  Erweiterungen von C für ein bestimmtes Betriebssystem sollen hier keine
  Berücksichtigung finden, sondern vielmehr in einem eigenen Buch behandelt
  werden.
* Themenbeschreibung: Einführung in ANSI-C.
* Lernziele: Programmieren mit ANSI-C zu erlernen.
* Abgrenzung zu anderen Wikibooks:
  * Das Buch ist keine Beschreibung des C-Standards. Dies ist Aufgabe des Buchs
    C-Sprachbeschreibung.
  * Außerdem sollen Algorithmen und Datenstrukturen nicht ausführlicher
    beschrieben werden. Diese Aufgabe übernimmt das Buch Algorithmen und
    Datenstrukturen in C, das auf die Grundlagen aufbaut, die in diesem Buch
    geschaffen wurden.


* Policies:
  * Kommentare und Anregungen sind erwünscht. Diese sollten dann aber konkrete
    Verbesserungsvorschläge erhalten.
  * Auch Verständnisfragen von Anfängern zu diesem Buch sind erwünscht. Diese
    bitte auf die Diskussionsseite der entsprechenden Seite stellen.


* Aufbau des Buches: Siehe Inhaltsverzeichnis. Allerdings kann das eine oder
  andere Kapitel noch hinzukommen oder später wieder wegfallen

## Grundlagen

### Historisches

1964 begannen das Massachusetts Institute of Technology (MIT), General
Electrics, Bell Laboratories und AT&T ein neues Betriebssystem mit der
Bezeichnung Multics (Multiplexed Information and Computing Service) zu
entwickeln. Multics sollte ganz neue Fähigkeiten wie beispielsweise Timesharing
und die Verwendung von virtuellem Speicher besitzen. 1969 kamen die Bell Labs
allerdings zu dem Schluss, dass das System zu teuer und die Entwicklungszeit zu
lang wäre und stiegen aus dem Projekt aus.

Eine Gruppe unter der Leitung von Ken Thompson suchte nach einer Alternative.
Zunächst entschied man sich dazu, das neue Betriebssystem auf einem PDP-7 von
DEC (Digital Equipment Corporation) zu entwickeln. Multics wurde in PL/1
implementiert, was die Gruppe allerdings nicht als geeignet empfand, und deshalb
das System in Assembler entwickelte.

Assembler hat jedoch einige Nachteile: Die damit erstellten Programme sind z. B.
nur auf einer Rechnerarchitektur lauffähig, die Entwicklung und vor allem die
Wartung (also das Beheben von Programmfehlern und das Hinzufügen von neuen
Funktionen) sind sehr aufwendig.

Deshalb suchte man für das System eine neue Sprache zur Systemprogrammierung.
Zunächst entschied man sich für Fortran, entwickelte dann aber doch eine eigene
Sprache mit dem Namen B, die stark beeinflusst von BCPL (Basic Combined
Programming Language) war. Aus der Sprache B entstand dann die Sprache C. Die
Sprache C unterschied sich von ihrer Vorgängersprache hauptsächlich darin, dass
sie typisiert war. Später wurde auch der Kernel von Unix in C umgeschrieben.
Auch heute noch sind die meisten Betriebssystemkerne, wie Windows oder Linux, in
C geschrieben.

1978 schufen Dennis Ritchie und Brian Kernighan mit dem Buch The C Programming
Language zunächst einen Quasi-Standard (auch als K&R-Standard bezeichnet). 1988
ist C erstmals durch das ANSI–Komitee standardisiert worden (als ANSI-C oder
C-89 bezeichnet). Beim Standardisierungsprozess wurden viele Elemente der
ursprünglichen Definition von K&R übernommen, aber auch einige neue Elemente
hinzugefügt. Insbesondere Neuerungen der objektorientierten Sprache C++, die auf
C aufbaut, flossen in den Standard ein.

Der Standard wurde 1999 überarbeitet und ergänzt (C99-Standard). Im Gegensatz
zum C89-Standard, den praktisch alle verfügbaren Compiler beherrschen, setzt
sich der C99-Standard nur langsam durch. Es gibt momentan noch kaum einen
Compiler, der den neuen Standard vollständig unterstützt. Die meisten Neuerungen
des C99-Standards sind im GNU-C-Compiler implementiert. Microsoft und Borland,
die zu den wichtigsten Compilerherstellern zählen, unterstützen den neuen
Standard allerdings bisher nicht, und es ist fraglich ob sie dies in Zukunft tun
werden.

### Was war / ist das Besondere an C

Die Entwickler der Programmiersprache legten größten Wert auf eine einfache
Sprache mit maximaler Flexibilität und leichter Portierbarkeit auf andere
Rechner. Dies wurde durch die Aufspaltung in den eigentlichen Sprachkern und die
Programmbibliotheken (engl.: libraries) erreicht.

Daher müssen, je nach Bedarf, weitere Programmbibliotheken zusätzlich
eingebunden werden. Diese kann man natürlich auch selbst erstellen um z. B.
große Teile des eigenen Quellcodes thematisch zusammenzufassen, wodurch die
Wiederverwendung des Programmcodes erleichtert wird.

Wegen der Nähe der Sprache C zur Hardware, einer vormals wichtigen Eigenschaft,
um Unix leichter portierbar zu machen, ist C von Programmierern häufig auch als
ein "Hochsprachen-Assembler" bezeichnet worden.

C selbst bietet in seiner Standardbibliothek nur rudimentäre Funktionen an. Die
Standardbibliothek bietet hauptsächlich Funktionen für die Ein-/Ausgabe,
Dateihandling, Zeichenkettenverarbeitung, Mathematik, Speicherreservierung und
einiges mehr. Sämtliche Funktionen sind auf allen C-Compilern verfügbar. Jeder
Compilerhersteller kann aber weitere Programmbibliotheken hinzufügen. Programme,
die diese benutzen, sind dann allerdings nicht mehr portabel.

### Der Compiler

Bevor ein Programm ausgeführt werden kann, muss es von einem Programm – dem
Compiler – in Maschinensprache übersetzt werden. Dieser Vorgang wird als
Kompilieren, oder schlicht als Übersetzen, bezeichnet. Die Maschinensprache
besteht aus Befehlen (Folge von Binärzahlen), die vom Prozessor direkt
verarbeitet werden können.

Neben dem Compiler werden für das Übersetzen des Quelltextes die folgenden
Programme benötigt:

* Präprozessor
* Linker

Umgangssprachlich wird oft nicht nur der Compiler selbst als Compiler
bezeichnet, sondern die Gesamtheit dieser Programme. Oft übernimmt tatsächlich
nur ein Programm diese Aufgaben oder delegiert sie an die entsprechenden
Spezialprogramme.

Vor der eigentlichen Übersetzung des Quelltextes wird dieser vom Präprozessor
verarbeitet, dessen Resultat anschließend dem Compiler übergeben wird. Der
Präprozessor ist im wesentlichen ein einfacher Textersetzer welcher
Makroanweisungen auswertet und ersetzt (diese beginnen mit #), und es auch durch
Schalter erlaubt, nur bestimmte Teile des Quelltextes zu kompilieren.

Anschließend wird das Programm durch den Compiler in Maschinensprache übersetzt.
Eine Objektdatei wird als Vorstufe eines ausführbaren Programms erzeugt. Einige
Compiler - wie beispielsweise der GCC - rufen vor der Erstellung der Objektdatei
zusätzlich noch einen externen Assembler auf. (Im Falle des GCC wird man davon
aber nichts mitbekommen, da dies im Hintergrund geschieht.)

Der Linker (im deutschen Sprachraum auch häufig als Binder bezeichnet) verbindet
schließlich noch die einzelnen Programmmodule miteinander. Als Ergebnis erhält
man die ausführbare Datei. Unter Windows erkennt man diese an der Datei-Endung
.exe.

Viele Compiler sind Bestandteil integrierter Entwicklungsumgebungen (IDEs, vom
Englischen Integrated Design Environment oder Integrated Development
Environment), die neben dem Compiler unter anderem über einen integrierten
Editor verfügen. Wenn Sie ein Textverarbeitungsprogramm anstelle eines Editors
verwenden, müssen Sie allerdings darauf achten, dass Sie den Quellcode im
Textformat ohne Steuerzeichen abspeichern. Es empfiehlt sich, die Dateiendung .c
zu verwenden, auch wenn dies bei den meisten Compilern nicht zwingend
vorausgesetzt wird.

Wie Sie das Programm mit ihrem Compiler übersetzen, können Sie in der Referenz
nachlesen.


### Hello World

Inzwischen ist es in der Literatur zur Programmierung schon fast Tradition, ein
Hello World als einführendes Beispiel zu präsentieren. Es macht nichts anderes,
als "Hello World" auf dem Bildschirm auszugeben, ist aber ein gutes Beispiel für
die Syntax (Grammatik) der Sprache:

``` cpp
/* Das Hello-World-Programm */

#include <stdio.h>

int main()
{
  printf("Hello World!\n");

  return 0;
}
```
@run


Dieses einfache Programm dient aber auch dazu, Sie mit der Compilerumgebung
vertraut zu machen. Sie lernen

* Editieren einer Quelltextdatei
* Abspeichern des Quelltextes
* Aufrufen des Compilers und gegebenenfalls des Linkers
* Starten des compilierten Programms

Darüber hinaus kann man bei einem neu installierten Compiler überprüfen, ob die
Installation korrekt war, und auch alle notwendigen Bibliotheken am richtigen
Platz sind.

* In der ersten Zeile ist ein Kommentar zwischen den Zeichen `/*` und `*/`
  eingeschlossen. Alles, was sich zwischen diesen Zeichen befindet, wird vom
  Compiler nicht beachtet. Kommentare können sich über mehrere Zeilen erstrecken,
  dürfen aber nicht geschachtelt werden (obwohl einige Compiler dies zulassen).

* In der nächsten Zeile befindet sich die Präprozessor-Anweisung `#include`. Der
  Präprozessor bearbeitet den Quellcode noch vor der Compilierung. An der Stelle
  der Include-Anweisung fügt er die (Header-)Datei `stdio.h` ein. Sie enthält
  wichtige Definitionen und Deklarationen für die Ein- und Ausgabeanweisungen.

* Das eigentliche Programm beginnt mit der Hauptfunktion `main`. Die Funktion `main`
  muss sich in jedem C-Programm befinden. Das Beispielprogramm besteht nur aus
  einer Funktion, Programme können aber in C auch aus mehreren Funktionen
  bestehen. In den runden Klammern können Parameter übergeben werden (später
  werden Sie noch mehr über Funktionen erfahren).

* Die Funktion `main()` ist der Einstiegspunkt des C-Programms. `main()` wird
  immer sofort nach dem Programmstart aufgerufen.

* Die geschweiften Klammern kennzeichnen Beginn und Ende eines Blocks. Man nennt
  sie deshalb Blockklammern. Die Blockklammern dienen zur Untergliederung des
  Programms. Sie müssen auch immer um den Rumpf (Anweisungsteil) einer Funktion
  gesetzt werden, selbst wenn er leer ist.

* Zur Ausgabe von Texten wird die Funktion `printf` verwendet. Sie ist kein
  Bestandteil der Sprache C, sondern der Standard-C-Bibliothek `stdio.h`, aus der
  sie beim Linken in das Programm eingebunden wird.

* Der auszugebende Text steht nach `printf` in Klammern. Die " zeigen an, dass es
  sich um reinen Text, und nicht um z. B. Programmieranweisungen handelt.

* In den Klammern steht auch noch ein `\n`. Das bedeutet einen Zeilenumbruch. Wann
  immer sie dieses Zeichen innerhalb einer Ausgabeanweisung schreiben, wird der
  Cursor beim Ausführen des Programms in eine neue Zeile springen.

* Über die Anweisung `return` wird ein Wert zurückgegeben. In diesem Fall geben wir
  einen Wert an das Betriebssystem zurück. Der Wert 0 teilt dem Betriebssystem
  mit, dass das Programm fehlerfrei ausgeführt worden ist.

* C hat noch eine weitere Besonderheit: Klein- und Großbuchstaben werden
  unterschieden. Man bezeichnet eine solche Sprache auch als case sensitive. Die
  Anweisung `printf` darf also nicht als `Printf` geschrieben werden.

* Hinweis: Wenn Sie von diesem Programm noch nicht viel verstehen, ist dies nicht
  weiter schlimm. Alle (wirklich alle) Elemente dieses Programms werden im Verlauf
  dieses Buches nochmals besprochen werden.


### Ein zweites Beispiel: Rechnen in C

Wir wollen nun ein zweites Programm entwickeln, das einige einfache Berechnungen
durchführt, und an dem wir einige Grundbegriffe lernen werden, auf die wir in
diesem Buch immer wieder stoßen werden:

``` cpp
#include <stdio.h>

int main()
{
  printf("3 + 2 * 8 = %i\n", 3 + 2 * 8);
  printf("(3 + 2) * 8 = %i\n",(3 + 2) * 8);
  return 0;
}
```
@run

Zunächst aber zur Erklärung des Programms: In Zeile 5 berechnet das Programm den
Ausdruck `3 + 2 * 8`. Da C die Punkt-vor-Strich-Regel beachtet, ist die Ausgabe
`19`. Natürlich ist es auch möglich, mit Klammern zu rechnen, was in Zeile 6
geschieht. Das Ergebnis ist diesmal 40.

Das Programm besteht nun neben Funktionsaufrufen und der Präprozessoranweisung
`#include` auch aus Operatoren und Operanden: Als Operator bezeichnet man
Symbole, mit denen eine bestimmte Aktion durchgeführt wird, wie etwa das
Addieren zweier Zahlen. Die Objekte, die mit den Operatoren verknüpft werden,
bezeichnet man als Operanden. Bei der Berechnung von `(3 + 2) * 8` sind `+`, `*`
und `( )` die Operatoren und 3, 2 und 8 sind die Operanden. (`%i` ist eine
Formatierungsanweisung die sagt, wie das Ergebnis als Zahl angezeigt werden
soll, und ist nicht der nachfolgend erklärte Modulo-Operator.)

Keine Operatoren hingegen sind `{`, `}`, `"`, `;`, `<` und `>`. (Wobei `<` und `>`
nur bei Verwendung in einem `#include` keine Operatoren sind. Außerhalb einer
`#include`-Anweisung werden sie als Vergleichsoperatoren verwendet.) Mit den
öffnenden und schließenden Klammern wird ein Block eingeführt und wieder
geschlossen, innerhalb der Anführungszeichen befindet sich eine Zeichenkette,
mit dem Semikolon wird eine Anweisung abgeschlossen, und in den spitzen Klammern
wird die Headerdatei angegeben.

Für die Grundrechenarten benutzt C die folgenden Operatoren:

| Rechenart       | Operator |
|:----------------|:--------:|
| Addition        |    `+`   |
| Subtraktion     |    `-`   |
| Multiplikation  |    `*`   |
| Division        |    `/`   |
| Modulo          |    `%`   |

Für weitere Rechenoperationen, wie beispielsweise Wurzel oder Winkelfunktionen,
stellt C keine Funktionen zur Verfügung - sie werden aus Bibliotheken
(Libraries) hinzugebunden. Diese werden wir aber erst später behandeln. Wichtig
für Umsteiger: In C gibt es zwar den Operator `^`, dieser stellt jedoch nicht
den Potenzierungsoperator dar, sondern den bitweisen XOR-Operator! Für die
Potenzierung muss deshalb ebenfalls auf eine Funktion der Standardbibliothek
zurückgegriffen werden.

Häufig genutzt in der Programmierung wird auch der Modulo-Operator (`%`). Er
ermittelt den Rest einer Division. Beispiel:

``` cpp
printf("Der Rest von 5 durch 3 ist: %i\n", 5 % 3);
```

Wie zu erwarten war, wird das Ergebnis 2 ausgegeben.

Wenn ein Operand durch 0 geteilt wird oder der Rest einer Division durch 0
ermittelt werden soll, so ist das Verhalten undefiniert. Das heißt, der
ANSI-Standard legt das Verhalten nicht fest.

Ist das Verhalten nicht festgelegt, unterscheidet der Standard zwischen
implementierungsabhängigem, unspezifiziertem und undefiniertem Verhalten:

* Implementierungsabhängiges Verhalten (engl. implementation defined behavior)
  bedeutet, dass das Ergebnis sich von Compiler zu Compiler unterscheidet.
  Allerdings ist das Verhalten nicht dem Zufall überlassen, sondern muss vom
  Compilerhersteller festgelegt und auch dokumentiert werden.

* Auch bei einem unspezifizierten Verhalten (engl. unspecified behavior) muss sich
  der Compilerhersteller für ein bestimmtes Verhalten entscheiden, im Unterschied
  zum implementierungsabhängigen Verhalten muss dieses aber nicht dokumentiert
  werden.

* Ist das Verhalten undefiniert (engl. undefined behaviour), bedeutet dies, dass
  sich nicht voraussagen lässt, welches Resultat eintritt. Das Programm kann bspw.
  die Division durch 0 ignorieren und ein nicht definiertes Resultat liefern, aber
  es ist genauso gut möglich, dass das Programm oder sogar der Rechner abstürzt
  oder Daten gelöscht werden.

Soll das Programm portabel sein, so muss man sich keine Gedanken darüber machen,
unter welche Kategorie ein bestimmtes Verhalten fällt. Der C-Standard zwingt
allerdings niemanden dazu, portable Programme zu schreiben, und es ist genauso
möglich, Programme zu entwickeln, die nur auf einer Implementierung laufen.
Undefiniertes Verhalten ist in jedem der Fälle zu vermeiden, es ist dabei nicht
garantiert, dass derselbe Compiler im selben Programm bei jedem Programmaufruf
dasselbe Verhalten zeigt.

Kommentare in C

In C werden Kommentare in `/*` und `*/` eingeschlossen. Ein Kommentar darf sich
über mehrere Zeilen erstrecken. Eine Schachtelung von Kommentaren ist nicht
erlaubt.

In neuen C-Compilern, die den C99-Standard beherrschen, aber auch als
Erweiterung in vielen C90-Compilern, sind auch einzeilige Kommentare, beginnend
mit // zugelassen. Er wird mit dem Ende der Zeile abgeschlossen. Dieser
Kommentartyp wurde mit C++ eingeführt und ist deshalb in der Regel auch auf
allen Compilern verfügbar, die sowohl C als auch C++ beherrschen.

Beispiel für Kommentare:

``` cpp
/* Dieser Kommentar
   erstreckt sich
   über mehrere
   Zeilen */

#include <stdio.h>  // Dieser Kommentar endet am Zeilenende

int main()
{
  printf("Beispiel für Kommentare\n");
  //printf("Diese Zeile wird niemals ausgegeben\n");

  return 0;

}
```
@run

> Hinweis: Tipps zum sinnvollen Einsatz von Kommentaren finden Sie im Kapitel
> Programmierstil. Um die Lesbarkeit zu verbessern, wird in diesem Wikibook
> häufig auf die Kommentierung verzichtet.

## Variablen und Konstanten

### Was sind Variablen?

Als nächstes wollen wir ein Programm entwickeln, das die Oberfläche $A$ eines Quaders ermittelt. Bezeichnet man die Länge des Quaders mit $a$, die Breite mit $b$ und die Höhe mit $c$, so gilt die Formel

$$ A = 2 * ( a * b + a * c + b * c )$$

Eine einmal eingeführte Variable, hier also $a$, $b$ und auch $c$, ist in der
Mathematik im weiteren Gang der Argumentation fest: sie ändert weder ihren Wert
noch ihre Bedeutung.

Auch bei der Programmierung gibt es Variablen, diese werden dort allerdings
anders verwendet als in der Mathematik: Eine Variable repräsentiert eine
Speicherstelle, deren Inhalt während der gesamten Lebensdauer der Variable
jederzeit verändert werden kann. Es ist so beispielsweise möglich, beliebig
viele Quader nacheinander zu berechnen, ohne jedesmal neue Variablen einführen
zu müssen.

Eine Variable kann bei der Programmierung also ihren Wert ändern. Jedoch zeugt
es von schlechtem Programmierstil, im Verlauf des Quelltextes die Bedeutung
einer Variablen zu ändern. Hat man also in einem Programm zur Kreisberechnung
beispielsweise eine Variable namens radius, in der der Radius eines Kreises
abgespeichert ist, so hüte man sich davor, in ihr etwa den Flächeninhalt
desselben Kreises oder etwas völlig Anderes abzulegen. Der Quelltext würde
dadurch erheblich weniger verständlich.

Weiteres zur Benennung von Variablen lese man im Abschnitt Namensgebung nach.

Das Programm zur Berechnung einer Quaderoberfläche könnte etwa wie folgt
aussehen:

```cpp
#include <stdio.h>

int main(void)
{
  int a,b,c;

  printf("Bitte Länge des Quaders eingeben:\n");
  scanf("%d",&a);
  printf("Bitte Breite des Quaders eingeben:\n");
  scanf("%d",&b);
  printf("Bitte Höhe des Quaders eingeben:\n");
  scanf("%d",&c);
  printf("Quaderoberfläche:\n%d\n", 2 * (a * b + a * c + b * c));
  return 0;
}
```
``` bash stdin
2
3
4
```
@run_stdin

* Bevor eine Variable in C benutzt werden kann, muss sie definiert werden (Zeile
  5). Das bedeutet, Bezeichner (Name der Variable) und (Daten-)Typ (hier `int`)
  müssen vom Programmierer festgelegt werden, dann kann der Computer
  entsprechenden Speicherplatz vergeben und die Variable auch adressieren (siehe
  später: C-Programmierung: Zeiger). Im Beispielprogramm werden die Variablen
  `a`, `b`, und `c` als Integer (Ganzzahl) definiert.

* Mit der Bibliotheksfunktion `scanf` können wir einen Wert von der Tastatur
  einlesen und in einer Variable speichern (mehr zur Anweisung `scanf` im
  nächsten Kapitel).

* Dieses Programm enthält keinen Code zur Fehlererkennung; d. h., wenn man hier
  statt der ganzen Zahlen etwas anderes oder auch gar nichts eingibt, passieren
  sehr komische Dinge. Hier geht es zunächst nur darum, die Funktionen zur Ein-
  und Ausgabe kennenzulernen. Wenn Sie eigene Programme schreiben, sollten Sie
  darauf achten, solche Fehler zu behandeln.

### Deklaration, Definition und Initialisierung von Variablen

Bekanntlich werden im Arbeitsspeicher alle Daten über Adressen angesprochen. Man
kann sich dies wie Hausnummern vorstellen: Jede Speicherzelle hat eine
eindeutige Nummer, die zum Auffinden von gespeicherten Daten dient. Ein Programm
wäre jedoch sehr unübersichtlich, wenn jede Variable mit der Adresse
angesprochen werden würde. Deshalb werden anstelle von Adressen Bezeichner
(Namen) verwendet. Der Compiler wandelt diese dann in die jeweilige Adresse um.

Neben dem Bezeichner einer Variable, muss der Typ mit angegeben werden. Über den
Typ kann der Compiler ermitteln, wieviel Speicher eine Variable im
Arbeitsspeicher benötigt.

Der Typ sagt dem Compiler auch, wie er einen Wert im Speicher interpretieren
muss. Bspw. unterscheidet sich in der Regel die interne Darstellung von
Fließkommazahlen (Zahlen mit Nachkommastellen) und Ganzzahlen (Zahlen ohne
Nachkommastellen), auch wenn der ANSI-C-Standard nichts darüber aussagt, wie
diese implementiert sein müssen. Werden allerdings zwei Zahlen beispielsweise
addiert, so unterscheidet sich dieser Vorgang bei Fließkommazahlen und
Ganzzahlen aufgrund der unterschiedlichen internen Darstellung.

Bevor eine Variable benutzt werden kann, müssen dem Compiler der Typ und der
Bezeichner mitgeteilt werden. Diesen Vorgang bezeichnet man als Deklaration.

Darüber hinaus muss Speicherplatz für die Variablen reserviert werden. Dies
geschieht bei der Definition der Variable. Es werden dabei sowohl die
Eigenschaften definiert als auch Speicherplatz reserviert. Während eine
Deklaration mehrmals im Code vorkommen kann, darf eine Definition nur einmal im
ganzen Programm vorkommen.

> **Merke**
>
> * Deklaration ist nur die Vergabe eines Namens und eines Typs für die Variable.
>
> * Definition ist die Reservierung des Speicherplatzes.
>
> * Initialisierung ist die Zuweisung eines ersten Wertes.


Die Literatur unterscheidet häufig nicht zwischen den Begriffen Definition und
Deklaration und bezeichnet beides als Deklaration. Dies ist insofern richtig, da
jede Definition gleichzeitig eine Deklaration ist (umgekehrt trifft dies
allerdings nicht zu). Beispiel:

``` cpp
int i;
```

Damit wird eine Variable mit dem Bezeichner `i` und dem Typ `int` (Integer)
definiert. Es wird eine Variable des Typs Integer und dem Bezeichner `i`
vereinbart sowie Speicherplatz reserviert (da jede Definition gleichzeitig eine
Deklaration ist, handelt es sich hierbei auch um eine Deklaration). Mit

``` cpp
extern char a;
```

wird eine Variable deklariert. Das Schlüsselwort `extern` in obigem Beispiel
besagt, dass die Definition der Variablen a irgendwo in einem anderen Modul des
Programms liegt. So deklariert man Variablen, die später beim Binden (Linken)
aufgelöst werden. Da in diesem Fall kein Speicherplatz reserviert wurde, handelt
es sich um keine Definition. Der Speicherplatz wird erst über

``` cpp
char a;
```

reserviert, was in irgendeinem anderen Quelltextmodul erfolgen muss.

Noch ein Hinweis: Die Trennung von Definition und Deklaration wird hauptsächlich
dazu verwendet, Quellcode in verschiedene Module unterzubringen. Bei Programmen,
die nur aus einer Quelldatei bestehen, ist es in der Regel nicht erforderlich,
Definition und Deklaration voneinander zu trennen. Vielmehr werden die Variablen
einmalig vor Gebrauch definiert, wie Sie es im Beispiel aus dem letzten Kapitel
gesehen haben.

Für die Vereinbarung von Variablen müssen Sie folgende Regeln beachten:
Variablen mit unterschiedlichen Namen, aber gleichen Typs können in derselben
Zeile deklariert werden. Beispiel:

``` cpp
int a,b,c;
```

Definiert die Variablen `int a`, `int b` und `int c`.

Nicht erlaubt ist aber die Vereinbarung von Variablen unterschiedlichen Typs und
Namens in einer Anweisung wie etwa im folgenden:

``` cpp
float a, int b; /* Falsch */
```

Diese Beispieldefinition erzeugt einen Fehler. Richtig dagegen ist, die
Definitionen von `float` und `int` mit einem Semikolon zu trennen, wobei man
jedoch zur besseren Lesbarkeit für jeden Typen eine neue Zeile nehmen sollte:

``` cpp
float a;
int b;
```

Auch bei Bezeichnern unterscheidet C zwischen Groß- und Kleinschreibung. So
können die Bezeichner name, Name und NAME für unterschiedliche Variablen oder
Funktionen stehen. Üblicherweise werden Variablenbezeichner klein geschrieben,
woran sich auch dieses Wikibuch hält.

Für vom Programmierer vereinbarte Bezeichner gelten außerdem folgende Regeln:

* Sie müssen mit einem Buchstaben oder einem Unterstrich beginnen; falsch wäre
  z. B. 1_Breite .

* Sie dürfen nur Buchstaben des englischen Alphabets (also keine Umlaute oder
  'ß'), Zahlen und den Unterstrich enthalten.

* Sie dürfen nicht einem C-Schlüsselwort wie z. B. `int` oder `extern`
  entsprechen.

Nachdem eine Variable definiert wurde, hat sie keinen bestimmten Wert (außer bei
globalen Variablen oder Variablen mit Speicherklasse `static`), sondern besitzt
lediglich den Inhalt, der sich zufällig in der Speicherzelle befunden hat (auch
als "Speichermüll" bezeichnet). Einen Wert erhält sie erst, wenn dieser ihr
zugewiesen wird, z. B: mit der Eingabeanweisung `scanf`. Man kann der Variablen
auch direkt einen Wert zuweisen. Beispiel:

``` cpp
a = 'b';
```

oder

``` cpp
summe = summe + zahl;
```

Verwechseln Sie nicht den Zuweisungsoperator in C mit dem Gleichheitszeichen in
der Mathematik. Das Gleichheitszeichen sagt aus, dass auf der rechten Seite das
Gleiche steht wie auf der linken Seite. Der Zuweisungsoperator dient hingegen
dazu, der linksstehenden Variablen den Wert des rechtsstehenden Ausdrucks
zuzuweisen.

Die zweite Zuweisung kann auch wesentlich kürzer wie folgt geschrieben werden:

``` cpp
summe += zahl;
```

Diese Schreibweise lässt sich auch auf die Subtraktion (`-=`), die
Multiplikation (`*=`), die Division (`/=`) und den Modulooperator (`%=`) und
weitere Operatoren übertragen.

Einer Variablen kann aber auch unmittelbar bei ihrer Definition ein Wert
zugewiesen werden. Man bezeichnet dies als Initialisierung. Im folgenden
Beispiel wird eine Variable mit dem Bezeichner a des Typs `char` (character)
deklariert und ihr der Wert `'b'` zugewiesen:

``` cpp
char a = 'b';
```

### Ganzzahlen

Ganzzahlen sind Zahlen ohne Nachkommastellen. In C gibt es folgende Typen für
Ganzzahlen:

* `char` (character): 1 Byte [^1] bzw. 1 Zeichen (kann zur Darstellung von
  Ganzzahlen oder Zeichen genutzt werden)
* `short int` (integer): ganzzahliger Wert
* `int` (integer): ganzzahliger Wert
* `long int` (integer): ganzzahliger Wert
* `long long int` (integer): ganzzahliger Wert, ab C99

Ist ein Typ-Spezifizierer (long oder short) vorhanden, ist die `int` Typangabe
redundant, d.h.

``` cpp
short int a;
long int b;
```

ist äquivalent zu

``` cpp
short a;
long b;
```

Bei der Vereinbarung wird auch festgelegt, ob eine ganzzahlige Variable
vorzeichenbehaftet sein soll. Wenn eine Variable ohne Vorzeichen vereinbart
werden soll, so muss ihr das Schlüsselwort unsigned vorangestellt werden.
Beispielsweise wird über

``` cpp
unsigned short int a;
```

eine vorzeichenlose Variable des Typs `unsigned short int` definiert. Der Typ
`signed short int` liefert Werte von mindestens -32.768 bis 32.767. Variablen
des Typs `unsigned short int` können nur nicht-negative Werte speichern. Der
Wertebereich wird natürlich nicht größer, vielmehr verschiebt er sich und liegt
im Bereich von 0 bis 65.535. [^2]

Wenn eine Integervariable nicht explizit als vorzeichenbehaftet oder
vorzeichenlos vereinbart wurde, ist sie immer vorzeichenbehaftet. So entspricht
beispielsweise

``` cpp
int a;
```

der Definition

``` cpp
signed int a;
```

Leider ist die Vorzeichenregel beim Datentyp `char` etwas komplizierter:

* Wird `char` dazu verwendet einen numerischen Wert zu speichern und die
  Variable nicht explizit als vorzeichenbehaftet oder vorzeichenlos vereinbart,
  dann ist es implementierungsabhängig, ob `char` vorzeichenbehaftet ist oder
  nicht.
* Wenn ein Zeichen gespeichert wird, so garantiert der Standard, dass der
  gespeicherte Wert der nichtnegativen Codierung im Zeichensatz entspricht.

Was versteht man unter dem letzten Punkt? Ein Zeichensatz hat die Aufgabe, einem
Zeichen einen bestimmten Wert zuzuordnen, da der Rechner selbst nur in der Lage
ist, Dualzahlen zu speichern. Im ASCII-Zeichensatz wird beispielsweise das
Zeichen `'M'` als 77 Dezimal bzw. 1001101 Dual gespeichert. Man könnte nun auch
auf die Idee kommen, anstelle von

``` cpp
char c = 'M';
```

besser

``` cpp
char c = 77;
```

zu benutzen. Allerdings sagt der C-Standard nichts über den verwendeten
Zeichensatz aus. Wird nun beispielsweise der EBCDIC-Zeichensatz verwendet, so
wird aus 'M' auf einmal eine öffnende Klammer (siehe Ausschnitt aus der ASCII-
und EBCDIC-Zeichensatztabelle rechts).


| ASCII | EBCDIC | Dezimal |   Binär |
|:------|:------:|--------:|--------:|
| L     |   <    |      76 | 1001100 |
| M     |   (    |      77 | 1001101 |
| N     |   +    |      78 | 1001110 |
| ...   |  ...   |     ... |  ...    |

Man mag dem entgegnen, dass heute hauptsächlich der ASCII-Zeichensatz verwendet
wird. Allerdings werden es die meisten Programmierer dennoch als schlechten Stil
ansehen, den codierten Wert anstelle des Zeichens der Variable zuzuweisen, da
nicht erkennbar ist, um welches Zeichen es sich handelt, und man vermutet, dass
im nachfolgenden Programm mit der Variablen c gerechnet werden soll.

Für Berechnungen werden Variablen des Typs Character sowieso nur selten benutzt,
da dieser nur einen sehr kleinen Wertebereich besitzt: Er kann nur Werte
zwischen -128 und +127 (vorzeichenbehaftet) bzw. 0 bis 255 (vorzeichenlos)
annehmen (auf einigen Implementierungen aber auch größere Werte). Für die
Speicherung von Ganzzahlen wird deshalb der Typ Integer (zu deutsch: Ganzzahl)
verwendet. Es existieren zwei Varianten dieses Typs: Der Typ `short int` ist
mindestens 16 Bit breit, der Typ `long int` mindestens 32 Bit. Eine Variable
kann auch als `int` (also ohne ein vorangestelltes short oder long ) deklariert
werden. In diesem Fall schreibt der Standard vor, dass der Typ `int` eine
"natürliche Größe" besitzen soll. Eine solche natürliche Größe ist
beispielsweise bei einem IA-32 PC (Intel-Architektur mit 32 Bit) mit Windows XP
oder Linux 32 Bit. Auf einem 16-Bit-Betriebssystem wie etwa MS-DOS beträgt die
Größe 16 Bit. Auf anderen Systemen kann `int` aber auch eine andere Größe
annehmen. Das Stichwort hierzu lautet Wortbreite.

Mit dem C99-Standard wurde außerdem der Typ `long long int` eingeführt. Er ist
mindestens 64 Bit breit. Allerdings wird er noch nicht von allen Compilern
unterstützt.

Eine Übersicht der Datentypen befindet sich in: C-Programmierung: Datentypen


[^1]: Der C-Standard legt die Breite eines Bytes über die Konstante `CHAR_BIT`
      als implementierungsabhängig fest, die die Anzahl der Bits festlegt.
      Vorgeschrieben sind `>= 8`, üblich ist `CHAR_BIT == 8`. Allerdings ist
      dies nur von Interesse, wenn Sie Programme entwickeln wollen, die wirklich
      auf jedem auch noch so exotischen Rechner laufen sollen.

[^2]: Wenn Sie nachgerechnet haben, ist Ihnen vermutlich aufgefallen, dass
      32.768 + 32.767 nur 65.534 ergibt, und nicht 65.535, wie man vielleicht
      vermuten könnte. Das liegt daran, dass der Standard nichts darüber
      aussagt, wie negative Zahlen intern im Rechner dargestellt werden. Werden
      negative Zahlen beispielsweise im Einerkomplement gespeichert, gibt es
      zwei Möglichkeiten, die 0 darzustellen, und der Wertebereich verringert
      sich damit um eins. Verwendet die Maschine (etwa der PC) das
      Zweierkomplement zur Darstellung von negativen Zahlen, liegt der
      Wertebereich zwischen –32.768 und +32.767.


### Erweiterte Zeichensätze

Wie man sich leicht vorstellen kann, ist der "Platz" für verschiedene Zeichen
mit einem einzelnen Byte sehr begrenzt, wenn man bedenkt, dass sich die
Zeichensätze verschiedener Sprachen unterscheiden. Reicht der Platz für die
europäischen Schriftarten noch aus, gibt es für asiatische Schriften wie
Chinesisch oder Japanisch keine Möglichkeit mehr, die vielen Zeichen mit einem
Byte darzustellen. Bei der Überarbeitung des C-Standards 1994 wurde deshalb das
Konzept eines breiten Zeichens (engl. wide character) eingeführt, das auch
Zeichensätze aufnehmen kann, die mehr als 1 Byte für die Codierung eines Zeichen
benötigen (beispielsweise Unicode-Zeichen). Ein solches "breites Zeichen" wird
in einer Variable des Typs `wchar_t` gespeichert.

Soll ein Zeichen oder eine Zeichenkette (mit denen wir uns später noch
intensiver beschäftigen werden) einer Variablen vom Typ `char` zugewiesen
werden, so sieht dies wie folgt aus:

``` cpp
char c = 'M';
char s[] = "Eine kurze Zeichenkette";
```

Wenn wir allerdings ein Zeichen oder eine Zeichenkette zuweisen oder
initialisieren wollen, die aus breiten Zeichen besteht, so müssen wir dies dem
Compiler mitteilen, indem wir das Präfix `L` benutzen:

``` cpp
wchar_t c = L'M';
wchar_t s[] = L"Eine kurze Zeichenkette" ;
```

Leider hat die Benutzung von `wchar_t` noch einen weiteren Haken: Alle
Bibliotheksfunktionen, die mit Zeichenketten arbeiten, können nicht mehr
weiterverwendet werden. Allerdings besitzt die Standardbibliothek für jede
Zeichenkettenfunktion entsprechende äquivalente Funktionen, die mit `wchar_t`
zusammenarbeiten: Im Fall von `printf` ist dies beispielsweise `wprintf`.

### Kodierung von Zeichenketten

Eine Zeichenkette kann mit normalen ASCII-Zeichen des Editors gefüllt werden.
Z.B.: `char s []="Hallo Welt";`. Häufig möchte man Zeichen in die Zeichenkette
einfügen, die nicht mit dem Editor darstellbar sind. Am häufigsten ist das wohl
die Nächste Zeile (engl. linefeed) und der Wagenrücklauf (engl. carriage
return). Für diese Zeichen gibt es keine Buchstaben, wohl aber ASCII-Codes.
Hierfür gibt es bei C-Compilern spezielle Schreibweisen:

**ESCAPE-Sequencen**

| Schreibweise | ASCII-Nr. | Beschreibung                              |
|:-------------|----------:|-------------------------------------------|
| `\n`         |        10 | Zeilenvorschub (new line)                 |
| `\r`         |        13 | Wagenrücklauf (carriage return)           |
| `\t`         |        09 | Tabulator                                 |
| `\b`         |        08 | Backspace                                 |
| `\a`         |        07 | Alarmton                                  |
| `\'`         |        39 | Apostroph                                 |
| `\"`         |        34 | Anführungszeichen                         |
| `\\`         |        92 | Backslash-Zeichen                         |
| `\nnn`       |      1..3 | Zeichen mit Oktalcode (0..7)              |
| `\xhh`       |      1..2 | Zeichen im Hexadezimalcode mit (0..9A..F) |


### Fließkommazahlen

Fließkommazahlen (auch als Gleitkomma- oder Gleitpunktzahlen bezeichnet) sind
Zahlen mit Nachkommastellen. Der C-Standard kennt die folgenden drei
Fließkommatypen:

* Den Typ `float` für Zahlen mit einfacher Genauigkeit.
* Den Typ `double` für Fließkommazahlen mit doppelter Genauigkeit.
* Den Typ `long double` für zusätzliche Genauigkeit.

Wie die Fließkommazahlen intern im Rechner dargestellt werden, darüber sagt der
C-Standard nichts aus. Welchen Wertebereich ein Fließkommazahltyp auf einer
Implementierung einnimmt, kann allerdings über die Headerdatei `float.h`
ermittelt werden.

Im Gegensatz zu Ganzzahlen gibt es bei den Fließkommazahlen keinen Unterschied
zwischen vorzeichenbehafteten und vorzeichenlosen Zahlen. Alle Fließkommazahlen
sind in C immer vorzeichenbehaftet.

Beachten Sie, dass Zahlen mit Nachkommastellen in US-amerikanischer Schreibweise
dargestellt werden müssen. So muss beispielsweise für die Zahl `5,353` die
Schreibweise `5.353` benutzt werden.

### Speicherbedarf einer Variable ermitteln

Mit dem `sizeof`-Operator kann die Länge eines Typs auf einem System ermittelt
werden. Im folgenden Beispiel soll der Speicherbedarf in Byte des Typs `int`
ausgegeben werden:

```cpp
#include <stdio.h>

int main(void)
{
  int x;

  printf("Der Typ int hat auf diesem System die Größe %lu Byte.\n", (unsigned long)sizeof(int));

  printf("Die Variable x hat auf diesem System die Größe %lu Byte.\n", (unsigned long)sizeof x);

  return 0;
}
```
@run

Nach dem Ausführen des Programms erhält man die folgende Ausgabe:

``` bash
Der Typ int hat auf diesem System die Größe 4 Byte.
Die Variable x hat auf diesem System die Größe 4 Byte.
```

Die Ausgabe kann sich auf einem anderen System unterscheiden, je nachdem, wie
breit der Typ `int` ist. In diesem Fall ist der Typ 4 Byte lang. Wie viel
Speicherplatz ein Variablentyp besitzt, ist implementierungsabhängig. Der
Standard legt nur fest, dass `sizeof(char)` immer den Wert 1 ergeben muss.

Beachten Sie, dass es sich bei `sizeof` um keine Funktion, sondern tatsächlich
um einen Operator handelt. Dies hat unter anderem zur Folge, dass keine
Headerdatei eingebunden werden muss, wie dies bei einer Funktion der Fall wäre.
Die in das Beispielprogramm eingebundene Headerdatei `<stdio.h>` wird nur für
die Bibliotheksfunktion `printf` benötigt.

Der `sizeof`-Operator wird häufig dazu verwendet, um Programme zu schreiben, die
auf andere Plattformen portierbar sind. Beispiele werden Sie im Rahmen dieses
Wikibuches noch kennenlernen.

Das Ergebnis des `sizeof`-Operators ist ein Wert vom Datentyp `size_t`. Es
handelt sich um einen vorzeichenlosen Ganzzahl-Datentyp, seine Bitbreite ist
implementierungsabhängig. Der C-Standard schreibt keine feste Zuordnung zu
`unsigned`, `unsigned long` oder einem anderen Datentyp vor.

Will man einen `size_t`-Wert mit einer Funktion der `printf`-Familie ausgeben,
sollte man den Wert explizit in den vorzeichenlosen Ganzzahl-Datentyp
konvertieren, der dem verwendeten Platzhalter entspricht.

### Konstanten

#### Symbolische Konstanten

Im Gegensatz zu Variablen, können sich konstante Werte während ihrer gesamten
Lebensdauer nicht ändern. Dies kann etwa dann sinnvoll sein, wenn Konstanten am
Anfang des Programms definiert werden, um sie dann nur an einer Stelle im
Quellcode anpassen zu müssen.

Ein Beispiel hierfür ist etwa die Mehrwertsteuer. Wird sie erhöht oder gesenkt,
so muss sie nur an einer Stelle des Programms geändert werden. Um einen
bewussten oder unbewussten Fehler des Programmierers zu vermeiden, verhindert
der Compiler, dass der Konstante ein neuer Wert zugewiesen werden kann.

In der ursprünglichen Sprachdefinition von Dennis Ritchie und Brian Kernighan
(K&R) gab es nur die Möglichkeit, mit Hilfe des Präprozessors symbolische
Konstanten zu definieren. Dazu dient die Präprozessoranweisung `#define`. Sie
hat die folgende Syntax:

``` cpp
#define IDENTIFIER token-sequence
```

Bitte beachten Sie, dass Präprozessoranweisungen nicht mit einem Semikolon
abgeschlossen werden.

Durch die Anweisung

``` c
#define MWST 19
```

wird jede vorkommende Zeichenkette `MWST` durch die Zahl 19 ersetzt. Eine
Ausnahme besteht lediglich bei Zeichenketten, die durch Anführungszeichen oder
Hochkommata eingeschlossen sind, wie etwa der Ausdruck

``` c
"Die aktuelle MWST"
```

Hierbei wird die Zeichenkette `MWST` nicht ersetzt.

Die Großschreibung ist nicht vom Standard vorgeschrieben. Es ist kein Fehler,
anstelle von `MWST` die Konstante `MwSt` oder `mwst` zu benennen. Allerdings
benutzen die meisten Programmierer Großbuchstaben für symbolische Konstanten.
Dieses Wikibuch hält sich ebenfalls an diese Konvention (auch die symbolischen
Konstanten der Standardbibliothek werden in Großbuchstaben geschrieben).

**ACHTUNG:** Das Arbeiten mit `define` kann auch fehlschlagen: Da `define`
lediglich ein einfaches Suchen-und-Ersetzen durch den Präprozessor bewirkt, wird
folgender Code nicht das gewünschte Ergebnis liefern:

``` c
#include <stdio.h>

#define quadrat(x)  x*x // fehlerhaftes Quadrat implementiert

int main (int argc, char *argv [])
{
  printf ("Das Quadrat von 2+3 ist %d\n", quadrat(2+3));

  return 0;
}
```
@run

Wenn Sie dieses Programm laufen lassen, wird es Ihnen sagen, dass das Quadrat
von `2+3 = 11` sei. Die Ursache dafür liegt darin, dass der Präprozessor
`quadrat(2+3)` durch `2+3 * 2+3` ersetzt.

Da sich der Compiler an die Regel Punkt-vor-Strich-Rechnung hält, ist das
Ergebnis falsch. In diesen Fall kann man das Programm wie folgt modifizieren
damit es richtig rechnet:


``` c
#include <stdio.h>

#define quadrat(x) ((x) * (x)) // richtige Quadrat-Implementierung

int main(int argc,char *argv[])
{
  printf("Das Quadrat von 2+3 ist %d\n",quadrat(2+3));

  return 0;
}
```
@run

#### Konstanten mit `const` definieren

Der Nachteil der Definition von Konstanten mit `define` ist, dass dem Compiler
der Typ der Konstante nicht bekannt ist. Dies kann zu Fehlern führen, die erst
zur Laufzeit des Programms entdeckt werden. Mit dem ANSI-Standard wurde deshalb
die Möglichkeit von C++ übernommen, eine Konstante mit dem Schlüsselwort `const`
zu deklarieren. Im Unterschied zu einer Konstanten, die über `define` definiert
wurde, kann eine Konstante, die mit `const` deklariert wurde, bei älteren
Compilern Speicherplatz wie Variablen auch verbrauchen. Bei neueren Compilern
wie GCC 4.3 ist die Variante mit `const` immer vorzuziehen, da sie dem Compiler
ein besseres Optimieren des Codes erlaubt und die Kompiliergeschwindigkeit
erhöht. Beispiel:

``` c
#include <stdio.h>

int main()
{
  const double pi = 3.14159;
  double d;

  printf("Bitte geben Sie den Durchmesser ein:\n");
  scanf("%lf", &d);
  printf("Umfang des Kreises: %lf\n", d * pi);
  pi = 5; // Fehler!
  return 0;
}
```
``` bash stdin
12.34
```
@run_stdin

In Zeile 5 wird die Konstante pi deklariert. Ihr muss sofort ein Wert zugewiesen
werden, ansonsten gibt der Compiler eine Fehlermeldung aus.

Damit das Programm richtig übersetzt wird, muss Zeile 11 entfernt werden, da
dort versucht wird, der Konstanten einen neuen Wert zuzuweisen. Durch das
Schlüsselwort `const` wird allerdings der Compiler damit beauftragt, genau dies zu
verhindern.


### Sichtbarkeit und Lebensdauer von Variablen

In früheren Standards von C musste eine Variable immer am Anfang eines
Anweisungsblocks vereinbart werden. Seit dem C99-Standard ist dies nicht mehr
unbedingt notwendig: Es reicht aus, die Variable unmittelbar vor der ersten
Benutzung zu vereinbaren.[^3]

Ein Anweisungsblock kann eine Funktion, eine Schleife oder einfach nur ein durch
geschwungene Klammern begrenzter Block von Anweisungen sein. Eine Variable lebt
immer bis zum Ende des Anweisungsblocks, in dem sie deklariert wurde.

Wird eine Variable/Konstante z. B. im Kopf einer Schleife vereinbart, gehört sie
laut C99-Standard zu dem Block, in dem auch der Code der Schleife steht.
Folgender Codeausschnitt soll das verdeutlichen:


``` c
for (int i = 0; i < 10; i++)
{
  printf("i: %d\n", i); // Ausgabe von lokal deklarierter Schleifenvariable
}

printf("i: %d\n", i); // Compilerfehler: hier ist i nicht mehr gültig!
```

Existiert in einem Block eine Variable mit einem Namen, der auch im umgebenden
Block verwendet wird, so greift man im inneren Block über den Namen auf die
Variable des inneren Blocks zu, die äußere wird überdeckt.

``` c
#include <stdio.h>

int main()
{
  int v = 1;
  int w = 5;
  {
    int v;
    v = 2;

    printf("%d\n", v);
    printf("%d\n", w);
  }

  printf("%d\n", v);
  return 0;
}
```
@run

Nach der Kompilierung und Ausführung des Programms erhält man die folgende
Ausgabe:

```
2
5
1
```

Erklärung: Am Anfang des neuen Anweisungsblocks in Zeile 8, wird eine neue
Variable v definiert und ihr der Wert 2 zugewiesen. Die innere Variable v
"überdeckt" nun den Wert der Variable v des äußeren Blocks. Aus diesem Grund
wird in Zeile 10 auch der Wert 2 ausgegeben. Nachdem der Gültigkeitsbereich der
inneren Variable v in Zeile 12 verlassen wurde, existiert sie nicht mehr, so
dass sie nicht mehr die äußere Variable überdecken kann. In Zeile 13 wird
deshalb der Wert 1 ausgeben.

Sollte es in geschachtelten Anweisungblöcken nicht zu solchen Überschneidungen
von Namen kommen, kann in einem inneren Block auf die Variablen des äußeren
zugegriffen werden. In Zeile 11 kann deshalb die in Zeile 6 definierte Zahl w
ausgegeben werden.

[^3]:  Beim verbreiteten Compiler GCC muss man hierfür explizit Parameter
       -std=c99 übergeben


## `static` & Co.

Manchmal reichen einfache Variablen, wie sie im vergangenen Kapitel behandelt
werden, nicht aus, um ein Problem zu lösen. Deshalb stellt der C-Standard einige
Operatoren zur Verfügung, mit denen man das Verhalten einer Variablen weiter
präzisieren kann.

### `static`

Das Schlüsselwort static hat in C eine Doppelbedeutung. Im Kontext einer
Variablendeklaration innerhalb einer Funktion bewirkt dieses Schlüsselwort, dass
die Variable auf einer festen Speicheradresse gespeichert wird. Abgesehen vom
ersten Aufruf der Funktion, werden die Informationen erneut genutzt, die in der
Variablen gespeichert wurden (wie in einem Gedächtnis). Siehe dazu folgendes
Codebeispiel:

``` c
int next_number()
{
   static int number = 0; // erzeugen einer static-Variablen mit Anfangswert 0
   return ++number;       // inkrementiert die Zahl und gibt das Ergebnis zurück
}
```

Beim ersten Aufruf wird 1 zurückgegeben, beim zweiten Aufruf 2, beim dritten 3,
etc. Statische Variablen werden nur einmal initialisiert, und zwar vom Compiler.
Der Compiler erzeugt eine ausführbare Datei, in der an der Speicherstelle für
die statische Variable bereits der Initialisierungswert eingetragen ist. Ohne
static würde number bei jedem Aufruf mit 0 initialisiert auf den Stack gelegt
werden und die Funktion würde immer 1 zurückgeben.

Auch vor Funktionen sowie Variablen außerhalb von Funktionen kann das
Schlüsselwort static stehen.

Das bewirkt, dass auf die Funktion bzw. Variable nur in der Datei, in der sie
steht, zugegriffen werden kann.

``` c
static int is_small_letter(char l)
{
   return l >= 'a' && l <= 'z';
}
```

Bei diesem Quelltext wäre die Funktion `is_small_letter` nur in der Datei
sichtbar, in der sie definiert wurde.

### `volatile`

Der Operator `volatile` sagt dem Compiler, dass der Inhalt einer Variablen sich
außerhalb des normalen Programmflusses ändern kann. Das kann zum Beispiel dann
passieren, wenn ein Programm aus einer Interrupt-Service-Routine einen Wert
erwartet und dann über diesen Wert einfach pollt (kein schönes Verhalten, aber
gut zum Erklären von `volatile`). Siehe folgendes Beispiel

``` c
char keyPressed;

int count=0;

while (keyPressed != 'x') {
   count++;
}
```

Viele Compiler werden aus der `while`-Schleife ein `while(1)` machen, da sich
der Wert von `keyPressed` aus ihrer Sicht nirgendwo ändert. Der Compiler könnte
annehmen, dass der Ausdruck `keyPressed != 'x'` niemals unwahr werden kann.
Achtung: Nur selten geben Compiler hier eine Warnung aus. Wenn Sie jetzt aber
eine Systemfunktion geschrieben haben, die in die Adresse von `keyPressed` die
jeweilige gedrückte Taste schreibt, kann das oben Geschriebene sinnvoll sein. In
diesem Fall müssten Sie vor der Deklaration von `keyPressed` die Erweiterung
`volatile` schreiben, damit der Compiler von seiner vermeintlichen Optimierung
absieht. Siehe richtiges Beispiel:

``` c
volatile char keyPressed;

int count=0;

while (keyPressed != 'x') {
   count++;
}
```

Das Keyword `volatile` sollte sparsam verwendet werden, da es dem Compiler
jegliches Optimieren verbietet.

### `register`

Dieses Schlüsselwort ist ein Optimierungshinweis an den Compiler. Zweck von
`register` ist es, dem Compiler mitzuteilen, dass man die so gekennzeichnete
Variable häufig nutzt und dass es besser wäre, sie direkt in ein Register des
Prozessors abzubilden. Ohne Compileroptimierung werden Variablen auf dem Stapel
(engl. stack) abgelegt. Register können jedoch wesentlich schneller gelesen und
beschrieben werden als der Arbeitsspeicher (oder Prozessor-Cache), der den Stack
enthält.

Bei der Verwendung dieses Schlüsselworts sollte man folgendes bedenken:

* Register haben eine begrenzte Anzahl und Größe (zB. 32 Bit).
* register Variablen können nicht dereferenziert werden, unabhängig davon, ob
  der Compiler die Variable tatsächlich nicht auf den Stack legt.
* Das Schlüsselwort ist ein Hinweis, d.h. der Compiler kann schließlich dennoch
  die Variable auf den Stack legen.
* Unter normalen Umständen sollte `register` nicht verwendet werden, moderne
  Compiler entscheiden automatisch, ob es effizient ist, ein `register` für die
  Variable zu reservieren. [1].

In der Compiler-Dokumentation kann eingesehen werden, wie der Compiler
`register` oder andere Optimierungen behandelt oder behandeln soll.

## Einfache Ein- und Ausgabe

Wohl kein Programm kommt ohne Ein- und Ausgabe aus. In C ist die Ein-/Ausgabe
allerdings kein Bestandteil der Sprache selbst. Vielmehr liegen Ein- und Ausgabe
als eigenständige Funktionen vor, die dann durch den Linker eingebunden werden.
Die wichtigsten Ein- und Ausgabefunktionen werden Sie in diesem Kapitel
kennenlernen.

### `printf`

Die Funktion `printf` haben wir bereits in unseren bisherigen Programmen
benutzt. Zeit also, sie genauer unter die Lupe zu nehmen. Die Funktion `printf`
hat die folgende Syntax:

``` c
 int printf (const char *format, ...);
```

Bevor wir aber `printf` diskutieren, sehen wir uns noch einige Grundbegriffe von
Funktionen an. In einem späteren Kapitel werden Sie dann lernen, wie Sie eine
Funktion selbst schreiben können.

In den beiden runden Klammern befinden sich die Parameter. In unserem Beispiel
ist der Parameter `const char *format`. Die drei Punkte dahinter zeigen an, dass
die Funktion noch weitere Parameter erhalten kann. Die Werte, die der Funktion
übergeben werden, bezeichnet man als Argumente. In unserem „Hallo Welt“-Programm
haben wir der Funktion `printf` beispielsweise das Argument "Hallo Welt"
übergeben.

Außerdem kann eine Funktion einen Rückgabewert besitzen. In diesem Fall ist der
Typ des Rückgabewertes `int`. Den Typ der Rückgabe erkennt man am Schlüsselwort,
das vor der Funktion steht. Eine Funktion, die keinen Wert zurückgibt, erkennen
Sie an dem Schlüsselwort `void`.

Die Bibliotheksfunktion `printf` dient dazu, eine Zeichenkette (engl. String)
auf der Standardausgabe auszugeben. In der Regel ist die Standardausgabe der
Bildschirm. Als Übergabeparameter besitzt die Funktion einen Zeiger auf einen
konstanten String. Was es mit Zeigern auf sich hat, werden wir später noch
sehen. Das `const` bedeutet hier, dass die Funktion den String nicht verändert.
Über den Rückgabewert liefert `printf` die Anzahl der ausgegebenen Zeichen. Wenn
bei der Ausgabe ein Fehler aufgetreten ist, wird ein negativer Wert
zurückgegeben.

Als erstes Argument von `printf` sind nur Strings erlaubt. Bei folgender Zeile
gibt der Compiler beim Übersetzen deshalb eine Warnung oder einen Fehler aus:

``` c
printf(55); // falsch
```

Da die Anführungszeichen fehlen, nimmt der Compiler an, dass es sich bei 55 um
einen Zahlenwert handelt. Geben Sie dagegen 55 in Anführungszeichen an,
interpretiert der Compiler dies als Text. Bei der folgenden Zeile gibt der
Compiler deshalb keinen Fehler aus:

``` c
printf("55"); // richtig
```

#### Formatelemente von `printf`

Die `printf`-Funktion kann auch mehrere Parameter verarbeiten, diese müssen dann
durch Kommata voneinander getrennt werden.

Beispiel:

``` c
#include <stdio.h>

int main()
{
  printf("%i plus %i ist gleich %s.\n", 3, 2, "Fünf");
  return 0;
}
```
@run

Ausgabe:

```
3 plus 2 ist gleich Fünf.
```

Die mit dem `%`-Zeichen eingeleiteten Formatelemente greifen nacheinander auf
die durch Komma getrennten Parameter zu (das erste `%i` auf 3, das zweite `%i`
auf 2 und `%s` auf den String `"Fünf"`).

Innerhalb von format werden Umwandlungszeichen (engl. conversion modifier) für
die weiteren Parameter eingesetzt. Hierbei muss der richtige Typ verwendet
werden. Die wichtigsten Umwandlungszeichen sind:

| Zeichen        | Umwandlung                                           |
|----------------|------------------------------------------------------|
| `%d` oder `%i` | `int`                                                |
| `%c`           | einzelnes Zeichen                                    |
| `%e` oder `%E` | `double`  im Format [-]d.ddd e±dd bzw. [-]d.ddd E±dd |
| `%f`           | `double`  im Format [-]ddd.ddd                       |
| `%o`           | `int` als Oktalzahl ausgeben                         |
| `%p`           | die Adresse eines Zeigers                            |
| `%s`           | Zeichenkette ausgeben                                |
| `%u`           | `unsigned int`                                       |
| `%x` oder `%X` | `int` als Hexadezimalzahl ausgeben                   |
| `%%`           | Prozentzeichen                                       |

Weitere Formate und genauere Erläuterungen finden Sie in der Referenz dieses
Buches.

Beispiel:

``` c
#include <stdio.h>

int main()
{
  printf("Integer: %d\n", 42);
  printf("Double: %.6f\n", 3.141);
  printf("Zeichen: %c\n", 'z');
  printf("Zeichenkette: %s\n", "abc");
  printf("43 Dezimal ist in Oktal: %o\n", 43);
  printf("43 Dezimal ist in Hexadezimal: %x\n", 43);
  printf("Und zum Schluss geben wir noch das Prozentzeichen aus: %%\n");
  return 0;
}
```
@run

Nachdem Sie das Programm übersetzt und ausgeführt haben, erhalten Sie die
folgende Ausgabe:

```
Integer: 42
Double: 3.141000
Zeichen: z
Zeichenkette: abc
43 Dezimal ist in Oktal: 53
43 Dezimal ist in Hexadezimal: 2b
Und zum Schluss geben wir noch das Prozentzeichen aus: %
```

Neben dem Umwandlungszeichen kann eine Umwandlungsangabe weitere Elemente zur
Formatierung erhalten. Dies sind maximal:

* ein **Flag**
* die **Feldbreite**
* durch einen Punkt getrennt die Anzahl der **Nachkommstellen** (Längenangabe)
* und an letzter Stelle schließlich das Umwandlungszeichen selbst


#### Flags

Unmittelbar nach dem Prozentzeichen werden die Flags (dt. Kennzeichnung)
angegeben. Sie haben die folgende Bedeutung:

* `-` (Minus): Der Text wird links ausgerichtet.
* `+` (Plus): Es wird auch bei einem positiven Wert ein Vorzeichen ausgegeben.
* Leerzeichen: Ein Leerzeichen wird ausgegeben, wenn der Wert positiv ist.
* `#`: Welche Wirkung das Kennzeichen `#` hat, ist abhängig vom verwendeten
  Format: Wenn ein Wert über `%x` als Hexadezimal ausgegeben wird, so wird jedem
  Wert ein `0x` vorangestellt (außer der Wert ist 0).
* `0`: Die Auffüllung erfolgt mit Nullen anstelle von Leerzeichen, wenn die
  Feldbreite verändert wird.

Im folgenden ein Beispiel, das die Anwendung der Flags zeigt:

``` c
#include <stdio.h>

int main()
{
   printf("Zahl 67:%+i\n", 67);
   printf("Zahl 67:% i\n", 67);
   printf("Zahl 67:%#x\n", 67);
   printf("Zahl 0:%0x\n", 0);
   return 0;
}
```
@run

Wenn das Programm übersetzt und ausgeführt wird, erhalten wir die folgende
Ausgabe:

```
Zahl 67:+67  
Zahl 67: 67
Zahl 67:0x43
Zahl 0:0
```

#### Feldbreite

Hinter dem Flag kann die Feldbreite (engl. field width) festgelegt werden. Das
bedeutet, dass die Ausgabe mit der entsprechenden Anzahl von Zeichen aufgefüllt
wird. Beispiel:

``` c
int main()
{
  printf("Zahlen rechtsbündig ausgeben: %5d, %5d, %5d\n",34, 343, 3343);
  printf("Zahlen rechtsbündig ausgeben, links mit 0 aufgefüllt: %05d, %05d, %05d\n",34, 343, 3343);
  printf("Zahlen linksbündig ausgeben: %-5d, %-5d, %-5d\n",34, 343, 3343);
  return 0;
}
```
@run

Wenn das Programm übersetzt und ausgeführt wird, erhalten wir die folgende
Ausgabe:

```
Zahlen rechtsbündig ausgeben:    34,   343,  3343
Zahlen rechtsbündig ausgeben, links mit 0 aufgefüllt: 00034, 00343, 03343
Zahlen linksbündig ausgeben: 34   , 343  , 3343
```

In Zeile 4 haben wir anstelle der Leerzeichen eine 0 verwendet, so dass nun die
Feldbreite mit Nullen aufgefüllt wird.

Standardmäßig erfolgt die Ausgabe rechtsbündig. Durch Voranstellen des
Minuszeichens kann die Ausgabe aber auch linksbündig erfolgen, wie in Zeile 5 zu
sehen ist.

#### Nachkommastellen

Nach der Feldbreite folgt, durch einen Punkt getrennt, die Genauigkeit. Bei `%f`
werden ansonsten standardmäßig 6 Nachkommastellen ausgegeben. Diese Angaben sind
natürlich auch nur bei den Gleitkommatypen `float` und `double` sinnvoll, weil
alle anderen Typen keine Nachkommastellen besitzen.

Beispiel:

``` c
#include <stdio.h>

int main()
{
  double betrag1 = 0.5634323;
  double betrag2 = 0.2432422;
  printf("Summe: %.3f\n", betrag1 + betrag2);

  return 0;
}
```
@run

Wenn das Programm übersetzt und ausgeführt wurde, erscheint die folgende Ausgabe
auf dem Bildschirm:

```
Summe: 0.807
```

### `scanf`

Auch die Funktion `scanf` haben Sie bereits kennengelernt. Sie hat eine
vergleichbare Syntax wie `printf`:

``` c
int scanf (const char *format, ...);
```

Die Funktion `scanf` liest einen Wert ein und speichert diesen in den
angegebenen Variablen ab. Doch Vorsicht: Die Funktion `scanf` erwartet die
Adresse der Variablen. Deshalb führt der folgende Funktionsaufruf zu einem
Fehler:

``` c
scanf("%i", x); /* Fehler */
```

Richtig dagegen ist:

``` c
scanf("%i",&x);
```

Mit dem Adressoperator `&` erhält man die Adresse einer Variablen. Diese kann
man sich auch ausgeben lassen:

``` c
#include <stdio.h>

int main(void)
{
  int x = 5;

  printf("Adresse von x: %p\n", &x);
  printf("Inhalt der Speicherzelle: %d\n", x);

  return 0;
}
```
@run

Kompiliert man das Programm und führt es aus, erhält man z.B. die folgende
Ausgabe:

```
Adresse von x: 0022FF74
Inhalt der Speicherzelle: 5
```

Die Ausgabe der Adresse kann bei Ihnen variieren. Es ist sogar möglich, dass
sich diese Angabe bei jedem Neustart des Programms ändert. Dies hängt davon ab,
wo das Programm (vom Betriebssystem) in den Speicher geladen wird.

Mit Adressen werden wir uns im Kapitel Zeiger noch einmal näher beschäftigen.

Für `scanf` können die folgenden Platzhalter verwendet werden, die dafür sorgen,
dass der eingegebene Wert in das "richtige" Format umgewandelt wird:

| Zeichen          | Umwandlung                                                            |
|------------------|-----------------------------------------------------------------------|
| `%d` 	           | vorzeichenbehafteter Integer als Dezimalwert                          |
| `%i`             | vorzeichenbehafteter Integer als Dezimal-, Hexadezimal oder Oktalwert |
| `%e`, `%f`, `%g` | Fließkommazahl                                                        |
| `%o`             | `int` als Oktalzahl einlesen                                          |
| `%s`             | Zeichenkette einlesen                                                 |
| `%x`             | Hexadezimalwert                                                       |
| `%%`             | erkennt das Prozentzeichen                                            |

### `getchar` und `putchar`

Die Funktion `getchar` liefert das nächste Zeichen vom Standard-Eingabestrom.
Ein Strom (engl. stream) ist eine geordnete Folge von Zeichen, die als Ziel oder
Quelle ein Gerät hat. Im Falle von `getchar` ist dieses Gerät die
Standardeingabe -- in der Regel also die Tastatur. Der Strom kann aber auch
andere Quellen oder Ziele haben: Wenn wir uns später noch mit dem Speichern und
Laden von Dateien beschäftigen, dann ist das Ziel und die Quelle des Stroms eine
Datei.

Das folgende Beispiel liest ein Zeichen von der Standardeingabe und gibt es aus.
Eventuell müssen Sie nach der Eingabe des Zeichens `<Enter>` drücken, damit
überhaupt etwas passiert. Das liegt daran, dass die Standardeingabe
üblicherweise zeilenweise und nicht zeichenweise eingelesen wird.

``` c
int c;
c = getchar();
putchar(c);
```

Geben wir über die Tastatur `"hallo"` ein, so erhalten wir durch den Aufruf von
`getchar` zunächst das erste Zeichen (also das `"h"`). Durch einen erneuten
Aufruf von `getchar` erhalten wir das nächste Zeichen, usw. Die Funktion
`putchar(c)` ist quasi die Umkehrung von `getchar`: Sie gibt ein einzelnes
Zeichen c auf der Standardausgabe aus. In der Regel ist die Standardausgabe der
Monitor.

Zugegeben, die Benutzung von `getchar` hat hier wenig Sinn, außer man hat vor,
nur das erste Zeichen einer Eingabe einzulesen. Häufig wird `getchar` mit
Schleifen benutzt. Ein Beispiel dafür werden wir noch später kennenlernen.
Escape-Sequenzen


#### Escape-Sequenzen

Eine spezielle Darstellung kommt in C den Steuerzeichen zugute. Steuerzeichen
sind Zeichen, die nicht direkt auf dem Bildschirm sichtbar werden, sondern eine
bestimmte Aufgabe erfüllen, wie etwa das Beginnen einer neuen Zeile, das
Darstellen des Tabulatorzeichens oder das Ausgeben eines Warnsignals. So führt
beispielsweise

``` c
printf("Dies ist ein Text ");
printf("ohne Zeilenumbruch");
```

nicht etwa zu dem Ergebnis, dass nach dem Wort „Text“ eine neue Zeile begonnen
wird, sondern das Programm gibt nach der Kompilierung aus:

Dies ist ein Text ohne Zeilenumbruch

Eine neue Zeile wird also nur begonnen, wenn an der entsprechenden Stelle ein \n
steht. Die folgende Auflistung zeigt alle in C vorhandenen Escape-Sequenzen:

* `\n` (new line) = bewegt den Cursor auf die Anfangsposition der nächsten Zeile.
* `\t` (horizontal tab) = Setzt den Tabulator auf die nächste horizontale
  Tabulatorposition. Wenn der Cursor bereits die letzte Tabulatorposition
  erreicht hat, dann ist das Verhalten unspezifiziert (vorausgesetzt eine letzte
  Tabulatorposition existiert).
* `\a` (alert) = gibt einen hör- oder sichtbaren Alarm aus, ohne die Position des
  Cursors zu ändern
* `\b` (backspace) = Setzt den Cursor ein Zeichen zurück. Wenn sich der Cursor
  bereits am Zeilenanfang befindet, dann ist das Verhalten unspezifiziert.
* `\r` (carriage return, dt. Wagenrücklauf) = Setzt den Cursor an den Zeilenanfang
* `\f` (form feed) = Setzt den Cursor auf die Startposition der nächsten Seite.
* `\v` (vertical tab) = Setzt den Cursor auf die nächste vertikale
  Tabulatorposition. Wenn der Cursor bereits die letzte Tabulatorposition
  erreicht hat, dann ist das Verhalten unspezifiziert (wenn eine solche
  existiert).
* `\"` " wird ausgegeben
* `\'` ' wird ausgegeben
* `\?` ? wird ausgegeben
* `\\` \ wird ausgegeben
* `\0` ist die Endmarkierung einer Zeichenkette


Jede Escape-Sequenz symbolisiert ein Zeichen auf einer Implementierung und kann
in einer Variablen des Typs `char` gespeichert werden.

Beispiel:

``` c
#include <stdio.h>

int main(void)
{
  printf("Der Zeilenumbruch erfolgt\n");
  printf("durch die Escape-Sequenz \\n\n\n");
  printf("Im Folgenden wird ein Wagenrücklauf (carriage return) mit \\r erzeugt:\r");
  printf("Satzanfang\n\n");
  printf("Folgende Ausgabe demonstriert die Funktion von \\b\n");
  printf("12\b34\b56\b78\b9\n");
  printf("Dies ist lesbar\n\0und dies nicht mehr."); // erzeugt ggf. eine Compiler-Warnung

  return 0;
}
```
@run

Erzeugt auf dem Bildschirm folgende Ausgabe:

```
Der Zeilenumbruch erfolgt
durch die Escape-Sequenz \n

Satzanfangen wird ein Wagenrücklauf (carriage return) mit \r erzeugt:

Folgende Ausgabe demonstriert die Funktion von \b
13579
Dies ist lesbar
```

## Operatoren

### Grundbegriffe

Bevor wir uns mit den Operatoren näher beschäftigen, wollen wir uns noch einige
Grundbegriffe ansehen:

````
 unärer Operator:                binärer Operator:

   _______ Operand                __________ Operand
  |                              |   |

 &a                              a / b

 |________ Operator                |________ Operator

````

Man unterscheidet in der Sprache C unäre, binäre und ternäre Operatoren. Unäre
Operatoren besitzen nur einen Operanden, binäre Operatoren besitzen zwei
Operanden und ternäre drei. Ein unärer Operator ist beispielsweise der
`&`-Operator, ein binärer Operator der Geteilt-Operator (`/`). Es gibt auch
Operatoren, die, je nachdem wo sie stehen, entweder unär oder binär sind. Ein
Beispiel hierfür sind Plus (`+`) und Minus (`-`). Sie können als Vorzeichen
vorkommen und sind dann unäre Operatoren oder als Rechenzeichen und sind dann
binäre Operatoren. Der einzige ternäre Operator in C ist der Bedingungsoperator,
der weiter unten behandelt wird.

Sehr häufig kommen im Zusammenhang mit binären Operatoren auch die Begriffe L-
und R-Wert vor. Diese Begriffe stammen ursprünglich von Zuweisungen. Der Operand
links des Zuweisungsoperators wird als L-Wert (engl. L value) bezeichnet, der
Operand rechts als R-Wert (engl. R value). Verallgemeinert gesprochen sind
L-Werte Operanden, denen man einen Wert zuweisen kann, R-Werten kann kein Wert
zugewiesen werden. Alle beschreibbaren Variablen sind also L-Werte. Konstanten,
Literale und konstante Zeichenketten (String Literalen) hingegen sind R-Werte.
Je nach Operator dürfen bestimmte Operanden nur L-Werte sein. Beim
Zuweisungsoperator muss beispielsweise der erste Operand ein L-Wert sein.

``` c
 a = 35;
```

In der Zuweisung ist der erste Operand die Variable a (ein L-Wert), der zweite
Operand das Literal 35 (ein R-Wert). Nicht erlaubt hingegen ist die Zuweisung

``` c
 35 = a; /* Fehler */
```

da einem Literal kein Wert zugewiesen werden darf. Anders ausgedrückt: Ein
Literal ist kein L-Wert und darf deshalb beim Zuweisungsoperator nicht als
erster Operand verwendet werden. Auch bei anderen Operatoren sind nur L-Werte
als Operand erlaubt. Ein Beispiel hierfür ist der Adressoperator. So ist
beispielsweise auch der folgende Ausdruck falsch:

``` c
 &35; /* Fehler */
```

Der Compiler wird eine Fehlermeldung ausgeben, in welcher er vermutlich darauf
hinweisen wird, dass hinter dem `&`-Operator ein L-Wert folgen muss.

### Inkrement- und Dekrement-Operator

Mit den `++` - und `--` -Operatoren kann ein L-Wert um eins erhöht bzw. um eins
vermindert werden. Man bezeichnet die Erhöhung um eins auch als Inkrement, die
Verminderung um eins als Dekrement. Ein Inkrement einer Variable `x` entspricht
`x = x + 1`, ein Dekrement einer Variable `x` entspricht `x = x - 1`.

Der Operator kann sowohl vor als auch nach dem Operanden stehen. Steht der
Operator vor dem Operand, spricht man von einem Präfix, steht er hinter dem
Operand bezeichnet man ihn als Postfix. Je nach Kontext unterscheiden sich die
beiden Varianten, wie das folgende Beispiel zeigt:

``` c
 x = 10;
  ergebnis = ++x;
```

Die zweite Zeile kann gelesen werden als: "Erhöhe zunächst x um eins, und weise
dann den Wert der Variablen zu". Nach der Zuweisung besitzt sowohl die Variable
ergebnis wie auch die Variable `x` den Wert 11.

``` c
 x = 10;
  ergebnis = x++;
```

Die zweite Zeile kann nun gelesen werden als: "Weise der Variablen `ergebnis`
den Wert `x` zu und erhöhe anschließend `x` um eins." Nach der Zuweisung hat die
Variable ergebnis deshalb den Wert 10, die Variable `x` den Wert 11.

Der `++`- bzw. `--`-Operator sollte, wann immer es möglich ist, präfix verwendet
werden, da schlechte und ältere Compiler den Wert des Ausdruckes sonst
(unnötigerweise) zuerst kopieren, dann erhöhen und dann in die Variable
zurückschreiben. So wird aus `i++` schnell

``` c
int j = i;
j = j + 1;
i = j;
```

wobei der Mehraufwand hier deutlich ersichtlich ist. Auch wenn man später zu C++
wechseln will, sollte man sich von Anfang an den Präfixoperator angewöhnen, da
die beiden Anwendungsweisen dort fundamental anders sein können. Rangfolge und
Assoziativität

Wie Sie bereits im ersten Kapitel gesehen haben, besitzen der Mal- und der
Geteilt-Operator eine höhere Rangfolge (auch als Priorität bezeichnet) als der
Plus- und der Minus-Operator. Diese Regel ist Ihnen sicher noch aus der Schule
als "Punkt vor Strich" bekannt.

Was ist mit einem Ausdruck wie beispielsweise:

``` c
 c = sizeof(x) + ++a / 3;
```

In C hat jeder Operator eine Rangfolge, nach der der Compiler einen Ausdruck
auswertet. Diese Rangfolge finden Sie in der Referenz dieses Buches.

Der `sizeof()` - sowie der Präfix-Operator haben die Priorität 14, `+` die
Priorität 12 und `/` die Priorität 13 [^1].

Folglich wird der Ausdruck wie folgt ausgewertet:

``` c
 c = (sizeof(x)) + ((++a) / 3);
```


Neben der Priorität ist bei Operatoren mit der gleichen Priorität auch die
Reihenfolge (auch als Assoziativität bezeichnet) der Auswertung von Bedeutung.
So muss beispielsweise der Ausdruck

``` c
 4 / 2 / 2
```

von links nach rechts ausgewertet werden:

``` c
 (4 / 2) / 2   // ergibt 1
```

Wird die Reihenfolge dieser Auswertung geändert, so ist das Ergebnis falsch:

``` c
 4 / (2 / 2)   // ergibt 4
```

In diesem Beispiel ist die Auswertungsreihenfolge

``` c
 (4 / 2) / 2
```

, also linksassoziativ.

Nicht alle Ausdrücke werden aber von links nach rechts ausgewertet, wie das
folgende Beispiel zeigt:

``` c
 a = b = c = d;
```

Durch Klammerschreibweise verdeutlicht, wird dieser Ausdruck vom Compiler von
rechts nach links ausgewertet:

``` c
 a = (b = (c = d));
```

Der Ausdruck ist also rechtsassoziativ.

Dagegen lässt sich auf das folgende Beispiel die Assoziativitätsregel nicht
anwenden:

``` c
 5 + 4 * 8 + 2
```

Sicher sieht man bei diesem Beispiel sofort, dass es wegen "Punkt vor Strich"
keinen Sinn macht, eine bestimmte Bewertungsreihenfolge festzulegen. Uns
interessiert hier allerdings die Begründung die C hierfür liefert: Diese besagt,
wie wir bereits wissen, dass die Assoziativitätsregel nur auf Operatoren mit
gleicher Priorität anwendbar ist. Der Plusoperator hat allerdings eine geringere
Priorität als der Multiplikationsoperator.

Diese Assoziativität von jedem Operator finden Sie in der Referenz dieses
Buches.

Durch unsere bisherigen Beispiele könnte der Anschein erweckt werden, dass alle
Ausdrücke ein definiertes Ergebnis besitzen. Leider ist dies nicht der Fall.

Fast alle C-Programme besitzen sogenannte Nebenwirkungen (engl. side effect;
teilweise auch mit Seiteneffekt übersetzt). Als Nebenwirkungen bezeichnet man
die Veränderung des Zustandes des Rechnersystems durch das Programm. Typische
Beispiele hierfür sind Ausgabe, Eingabe und die Veränderung von Variablen.
Beispielsweise führt i++ zu einer Nebenwirkung - die Variable wird um eins
erhöht.

Der C-Standard legt im Programm bestimmte Punkte fest, bis zu denen
Nebenwirkungen ausgewertet sein müssen. Solche Punkte werden als Sequenzpunkte
(engl. sequence point) bezeichnet. In welcher Reihenfolge die Nebenwirkungen vor
dem Sequenzpunkt auftreten und welche Auswirkungen dies hat, ist nicht
definiert.

Die folgenden Beispiele sollten dies verdeutlichen:

``` c
 i = 3;
 a = i + i++;
```

Da der zweite Operand der Addition ein Postfix-Inkrement-Operator ist, wird
dieser zu 3 ausgewertet. Je nachdem, ob der erste Operand vor oder nach
Einsetzen der Nebenwirkung ausgewertet wird (also ob `i` noch 3 oder schon 4
ist), ergibt die Addition 6 oder 7. Da sich der Sequenzpunkt aber am Ende der
Zeile befindet, ist beides möglich und C-konform. Um es nochmals hervorzuheben:
Nach dem Sequenzpunkt besitzt `i` in jedem Fall den Wert 4. Es ist allerdings
nicht definiert, wann `i` inkrementiert wird. Dies kann vor oder nach der
Addition geschehen.

Ein weiterer Sequenzpunkt befindet sich vor dem Eintritt in eine Funktion.
Hierzu zwei Beispiele:

``` c
 a = 5;
 printf("Ausgabe: %d %d",a += 5,a *= 2);
```

Die Ausgabe kann entweder 10 20, 15 10 oder 15 15 sein, je nachdem ob die
Nebenwirkung von `a += 5` oder `a *= 2` zuerst ausgeführt wird oder ob beide
Berechnungen vor der Ausgabe erfolgen.

Zweites Beispiel:

``` c
 x = a() + b() – c();
```

Wie wir oben gesehen haben, ist festgelegt, dass der Ausdruck von links nach
rechts ausgewertet wird (`(a() + b()) - c()`), da der Ausdruck linksassoziativ
ist. Allerdings steht damit nicht fest, welche der Funktionen als erstes
aufgerufen wird. Der Aufruf kann in den Kombinationen `a`, `b`, `c` oder `a`,
`c`, `b` oder `b`, `a`, `c` oder `b`, `c`, `a` oder `c`, `a`, `b` oder `c`, `b`,
`a` erfolgen. Welche Auswirkungen dies auf die Programmausführung hat, ist
undefiniert.

Weitere wichtige Sequenzpunkte sind die Operatoren `&&`, `||` sowie `?:` und
Komma. Auf die Bedeutung dieser Operatoren werden wir noch im nächsten Kapitel
näher eingehen.

Es sei nochmals darauf hingewiesen, dass dies nicht wie im Fall eines
implementierungsabhängigen oder unspezifizierten Verhalten zu Programmen führt,
die nicht portabel sind. Vielmehr sollten Programme erst gar kein undefiniertes
Verhalten liefern. Fast alle Compiler geben hierbei keine Warnung aus. Ein
undefiniertes Verhalten kann allerdings buchstäblich zu allem führen. So ist es
genauso gut möglich, dass der Compiler ein ganz anderes Ergebnis liefert als das
Oben beschriebene, oder sogar zu anderen unvorhergesehenen Ereignissen wie
beispielsweise dem Absturz des Programms.


[^1]: Die Rangfolge der Operatoren ist im Standard nicht in Form einer Tabelle
      festgelegt, sondern ergibt sich aus der Grammatik der Sprache C. Deshalb
      können sich die Werte für die Rangfolge in anderen Büchern unterscheiden,
      wenn eine andere Zählweise verwendet wurde, andere Bücher verzichten
      wiederum vollständig auf die Durchnummerierung der Rangfolge.

### Der Shift-Operator

Die Operatoren `<<` und `>>` dienen dazu, den Inhalt einer Variablen bitweise um
1 nach links bzw. um 1 nach rechts zu verschieben (siehe Abbildung 1).

Beispiel:

``` c
#include <stdio.h>

int main()
{
  unsigned short int a = 350;
  printf("%u\n", a << 1);

  return 0;
}
```
@run

Nach dem Kompilieren und Übersetzen wird beim Ausführen des Programms die Zahl
700 ausgegeben. Die Zahl hinter dem Leftshiftoperator `<<` gibt an, um wie viele
Bitstellen die Variable verschoben werden soll (in diesem Beispiel wird die Zahl
nur ein einziges Mal nach links verschoben).

````
  _______________________________________________________________________
 |                                                                       |
 |                         Leftshift eines unsigned short int            |
 |_______________________________________________________________________|
 |           |                                                           |
 | 350       | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 0 | 1 | 1 | 1 | 1 | 0 |
 |___________|____/___/___/___/___/___/___/___/___/___/___/___/___/___/__|
 |           |  /   /   /   /   /   /   /   /   /   /   /   /   /   /    |
 | Leftshift | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 0 | 1 | 1 | 1 | 1 | 0 | 0 |
 |___________|___________________________________________________________|
````

Vielleicht fragen Sie sich jetzt, für was der Shift–Operator gut sein soll?
Schauen Sie sich das Ergebnis nochmals genau an. Fällt Ihnen etwas auf? Richtig!
Bei jedem Linksshift findet eine Multiplikation mit 2 statt. Umgekehrt findet
beim Rechtsshift eine Division durch 2 statt. (Dies natürlich nur unter der
Bedingung, dass die 1 nicht herausgeschoben wird und die Zahl positiv ist. Wenn
der zu verschiebende Wert negativ ist, ist das Ergebnis
implementierungsabhängig.)

Es stellt sich nun noch die Frage, weshalb man den Shift-Operator benutzen soll,
wenn eine Multiplikation mit zwei doch ebenso gut mit dem `*`-Operator machbar
wäre? Die Antwort lautet: Bei den meisten Prozessoren wird die Verschiebung der
Bits wesentlich schneller ausgeführt als eine Multiplikation. Deshalb kann es
bei laufzeitkritischen Anwendungen vorteilhaft sein, den Shift-Operator anstelle
der Multiplikation zu verwenden. Eine weitere praktische Einsatzmöglichkeit des
Shift Operators findet sich zudem in der Programmierung von Mikroprozessoren.
Durch einen Leftshift können digitale Eingänge einfacher und schneller
geschaltet werden. Man erspart sich hierbei mehrere Taktzyklen des Prozessors.

Anmerkung: Heutige Compiler optimieren dies schon selbst. Der Lesbarkeit halber
sollte man also besser x * 2 schreiben, wenn eine Multiplikation durchgeführt
werden soll. Will man ein Byte als Bitmaske verwenden, d.h. wenn die einzelnen
gesetzten Bits interessieren, dann sollte man mit Shift arbeiten, um seine
Absicht im Code besser auszudrücken.

### Ein wenig Logik ...

Kern der Logik sind Aussagen. Solche Aussagen sind beispielsweise:

* Stuttgart liegt in Baden-Württemberg.
* Der Himmel ist grün.
* 6 durch 3 ist 2.
* Felipe Massa wird in der nächsten Saison Weltmeister.

Aussagen können wahr oder falsch sein. Die erste Aussage ist wahr, die zweite
dagegen falsch, die dritte Aussage dagegen ist wiederum wahr. Auch die letzte
Aussage ist wahr oder falsch – allerdings wissen wir dies zum jetzigen Zeitpunkt
noch nicht. In der Logik werden wahre Aussagen mit einer 1, falsche Aussagen mit
einer 0 belegt. Was aber hat dies mit C zu tun? Uns interessieren hier Ausdrücke
wie:

* `5 < 2` (fünf ist kleiner als zwei)
* `4 == 4` (gleich)
* `5 >= 2` (wird gelesen als: fünf ist größer oder gleich zwei)
* `x > y` (x ist größer als y)

Auch diese Ausdrücke können wahr oder falsch sein. Mit solchen sehr einfachen
Ausdrücken kann der Programmfluss gesteuert werden. So kann der Programmierer
festlegen, dass bestimmte Anweisungen nur dann ausgeführt werden, wenn
beispielsweise `x > y` ist oder ein Programmabschnitt so lange ausgeführt wird
wie `a != b` ist (in C bedeutet das Zeichen != immer ungleich).

Beispiel: Die Variable x hat den Wert 5 und die Variable y den Wert 7. Dann ist
der Ausdruck `x < y` wahr und liefert eine 1 zurück. Der Ausdruck `x > y`
dagegen ist falsch und liefert deshalb eine 0 zurück.

Für den Vergleich zweier Werte kennt C die folgenden Vergleichsoperatoren:

| Operator | Bedeutung           |
|:--------:|---------------------|
| `<`      | kleiner als         |
| `>`      | größer als          |
| `<=`     | kleiner oder gleich |
| `>=`     | größer oder gleich  |
| `!=`     | ungleich            |
| `==`     | gleich              |

Wichtig: Verwechseln Sie nicht den Zuweisungsoperator = mit dem
Vergleichsoperator `==`. Diese haben vollkommen verschiedene Bedeutungen.
Während der erste Operator einer Variablen einen Wert zuweist, vergleicht
letzterer zwei Werte miteinander. Da die Verwechslung der beiden Operatoren
allerdings ebenfalls einen gültigen Ausdruck liefert, gibt der Compiler weder
eine Fehlermeldung noch eine Warnung zurück. Dies macht es schwierig, den Fehler
aufzufinden. Aus diesem Grund schreiben viele Programmierer grundsätzlich bei
Vergleichen die Variablen auf die rechte Seite, also zum Beispiel `5 == a`.
Vergißt man mal ein `=`, wird der Compiler eine Fehlermeldung liefern.

Anders als in der Logik wird in C der boolsche Wert [^2] true als Werte ungleich
0 definiert. Dies schließt auch beispielsweise die Zahl 5 ein, die in C
ebenfalls als true interpretiert wird. Die Ursache hierfür ist, dass es in der
ursprünglichen Sprachdefinition keinen Datentyp zur Darstellung der boolschen
Werte true und false gab, so dass andere Datentypen zur Speicherung von
boolschen Werten benutzt werden mussten. So schreibt beispielsweise der
C-Standard vor, dass die Vergleichsoperatoren einen Wert vom Typ `int` liefern.
Erst mit dem C99-Standard wurde ein neuer Datentyp Bool eingeführt, der nur die
Werte 0 und 1 aufnehmen kann. ... und noch etwas Logik


[^2]: Der Begriff boolsche Werte ist nach dem englischen Mathematiker George
      Boole benannt, der sich mit algebraischen Strukturen beschäftigte, die nur
      die Zustände 0 und 1 bzw. false und true kennt.


### ... und noch etwas Logik

Wir betrachten die folgende Aussage:

Wenn ich morgen vor sechs Uhr Feierabend habe und das Wetter schön ist, dann
gehe ich an den Strand.

Auch dies ist eine Aussage, die wahr oder die falsch sein kann. Im Unterschied
zu den Beispielen aus dem vorhergegangen Kapitel, hängt die Aussage "gehe ich an
den Strand" von den beiden vorhergehenden ab. Gehen wir die verschiedenen
möglichen Fälle durch:

* Wir stellen am nächsten Tag fest, dass die Aussage, dass wir vor sechs
  Feierabend haben und dass das Wetter schön ist, falsch ist, dann ist auch die
  Aussage, dass wir an den Strand gehen, falsch.
* Wir stellen am nächsten Tag fest, die Aussage, dass wir vor sechs Feierabend
  haben, ist falsch, und die Aussage, dass das Wetter schön ist, ist wahr.
  Dennoch bleibt die Aussage, dass wir an den Strand gehen, falsch.
* Wir stellten nun fest, dass wir vor sechs Uhr Feierabend haben, also die
  Aussage wahr ist, aber dass die Aussage, dass das Wetter schön ist falsch ist.
  Auch in diesem Fall ist die Aussage, dass wir an den Strand gehen, falsch.
* Nun stellen wir fest, dass sowohl die Aussage, dass wir vor sechs Uhr
  Feierabend haben wie auch die Aussage, dass das Wetter schön ist wahr sind. In
  diesem Fall ist auch die Aussage, dass das wir an den Strand gehen, wahr.

Dies halten wir nun in einer Tabelle fest:

| Eingabe 1 | Eingabe 2 | Ergebnis |
|-----------|-----------|----------|
| falsch    | falsch    | falsch   |
| falsch    | wahr      | falsch   |
| wahr      | falsch    | falsch   |
| wahr      | wahr      | wahr     |

In der Informatik nennt man dies eine Wahrheitstabelle -- in diesem Fall der
UND- bzw. AND-Verknüpfung.

Eine UND-Verknüpfung in C wird durch den `&`-Operator repräsentiert. Beispiel:

``` c
 int a;
 a = 45 & 35
```

Bitte berücksichtigen Sie, dass bei boolschen Operatoren beide Operanden vom Typ
Integer sein müssen.

Eine weitere Verknüpfung ist die Oder-Verknüpfung. Auch diese wollen wir uns an
einem Beispiel klar machen:

Wenn wir eine Pizzeria oder ein griechisches Lokal finden, kehren wir ein.

Auch hier können wir wieder alle Fälle durchgehen. Wir erhalten dann die
folgende Tabelle (der Leser möge sich anhand des Beispiels selbst davon
überzeugen):

| Eingabe 1 | Eingabe 2 | Ergebnis |
|-----------|-----------|----------|
| falsch    | falsch    | falsch   |
| falsch    | wahr      | wahr     |
| wahr      | falsch    | wahr     |
| wahr      | wahr      | wahr     |

Eine ODER-Verknüpfung in C wird durch den `|`-Operator repräsentiert.

Beispiel:

``` c
 int a;
 a = 45 | 35
```

Eine weitere Verknüpfung ist XOR bzw. XODER (exklusives Oder), die auch als
Antivalenz bezeichnet wird. Eine Antivalenzbedingung ist genau dann wahr, wenn
die Bedingungen antivalent sind, das heißt, wenn A und B unterschiedliche
Wahrheitswerte besitzen (siehe dazu untenstehende Wahrheitstabelle).

Man kann sich die XOR-Verknüpfung auch an folgendem Beispiel klar machen:

Entweder heute oder morgen gehe ich einkaufen

Hier lässt sich auf die gleiche Weise wie oben die Wahrheitstabelle herleiten:

| Eingabe 1 | Eingabe 2 | Ergebnis |
|-----------|-----------|----------|
| falsch    | falsch    | falsch   |
| falsch    | wahr      | wahr     |
| wahr      | falsch    | wahr     |
| wahr      | wahr      | falsch   |

Ein XOR–Verknüpfung in C wird durch den `^`-Operator repräsentiert. Beispiel:

``` c
 int a;
 a = a ^ 35 // in Kurzschreibweise: a ^= 35
```

Es gibt insgesamt 24=16 mögliche Verknüpfungen. Dies entspricht der Anzahl der
möglichen Kombinationen der Spalte c in der Wahrheitstabelle. Ein Beispiel für
eine solche Verknüpfung, die C nicht kennt, ist die Äquivalenzverknüpfung. Will
man diese Verknüpfung erhalten, so muss man entweder eine Funktion schreiben,
oder auf die boolsche Algebra zurückgreifen. Dies würde aber den Rahmen dieses
Buches sprengen und soll deshalb hier nicht erläutert werden.

Eine weitere Möglichkeit, die einzelnen Bits zu beeinflussen, ist der
Komplement-Operator. Mit ihm wird der Wahrheitswert aller Bits umgedreht:

| Eingabe | Ergebnis |
|---------|----------|
| falsch  | wahr     |
| wahr    | falsch   |

Das Komplement wird in C durch den `~`-Operator repräsentiert. Beispiel:

``` c
 int a;
 a = ~45
```

Wie beim Rechnen mit den Grundrechenarten gibt es auch bei den boolschen
Operatoren einen Vorrang. Den höchsten Vorrang hat der Komplement-Operator,
gefolgt vom UND-Operator und dem XOR-Operator und schließlich dem ODER-Operator.
So entspricht beispielsweise

``` c
 a | b & ~c
```

der geklammerten Fassung

``` c
 a | (b & (~c))
```

Es fragt sich nun, wofür solche Verknüpfungen gut sein sollen. Dies wollen wir
an zwei Beispielen zeigen (wobei wir in diesem Beispiel von einem Integer mit 16
Bit ausgehen). Bei den Zahlen 0010 1001 0010 1001 und 0111 0101 1001 1100 wollen
wir Bit zwei setzen (Hinweis: Normalerweise wird ganz rechts mit 0 beginnend
gezählt). Alle anderen Bits sollen unberührt von der Veränderung bleiben. Wie
erreichen wir das? Ganz einfach: Wir verknüpfen die Zahlen jeweils durch eine
Oder-Verknüpfung mit 0000 0000 0000 0100. Wie Sie im folgenden sehen, erhalten
wird dadurch tatsächlich das richtige Ergebnis:

```
 0010 1001 0010 1001
 0000 0000 0000 0100
 0010 1001 0010 1101
```

Prüfen Sie das Ergebnis anhand der Oder-Wahrheitstabelle nach! Tatsächlich
bleiben alle anderen Bits unverändert. Und was, wenn das zweite Bit bereits
gesetzt ist? Sehen wir es uns an:

```
 0111 0101 1001 1100
 0000 0000 0000 0100
 0111 0101 1001 1100
```

Auch hier klappt alles wie erwartet, so dass wir annehmen dürfen, dass dies auch
bei jeder anderen Zahl funktioniert.

Wir stellen uns nun die Frage, ob Bit fünf gesetzt ist oder nicht. Für uns ist
dies sehr einfach, da wir nur ablesen müssen. Die Rechnerhardware hat diese
Fähigkeit aber leider nicht. Wir müssen deshalb auch in diesem Fall zu einer
Verknüpfung greifen: Wenn wir eine beliebige Zahl durch eine Und–Verknüpfung mit
0000 0000 0010 0000 verknüpfen, so muss das Ergebnis, wenn Bit fünf gesetzt ist,
einen Wert ungleich null ergeben, andernfalls muss das Ergebnis gleich null
sein.

Wir nehmen nochmals die Zahlen 0010 1001 0010 1001 und 0111 0101 1001 1100 für
unser Beispiel:

```
 0010 1001 0010 1001
 0000 0000 0010 0000
 0000 0000 0010 0000
```

Da das Ergebnis ungleich null ist, können wir darauf schließen, dass das Bit
gesetzt ist. Sehen wir uns nun das zweite Beispiel an, in dem das fünfte Bit
nicht gesetzt ist:

```
 0111 0101 1001 1100
 0000 0000 0010 0000
 0000 0000 0000 0000
```

Das Ergebnis ist nun gleich null, daher wissen wir, dass das fünfte Bit nicht
gesetzt sein kann. Über eine Abfrage, wie wir sie im nächsten Kapitel
kennenlernen werden, könnten wir das Ergebnis für unseren Programmablauf
benutzen. Bedingungsoperator

Der Bedingungsoperator liefert abhängig von einer Bedingung einen von zwei
möglichen Ergebniswerten. Er hat drei Operanden: Die Bedingung, den Wert für den
Fall, dass die Bedingung zutrifft und den Wert für den Fall dass sie nicht
zutrifft. Die Syntax ist

``` c
 bedingung ? wert_wenn_wahr : wert_wenn_falsch
```

Für eine einfache `if`-Anweisung wie die folgende:

``` c
 /* Falls a größer als b ist, wird a zurückgegeben, ansonsten b. */
 if (a > b)
    return a;
  else
    return b;
```

kann daher kürzer geschrieben werden

``` c
 return (a > b) ? a : b;
 /* Falls a größer als b ist, wird a zurückgegeben, ansonsten b. */
```

Der Bedingungsoperator ist nicht, wie oft angenommen, eine verkürzte
Schreibweise für `if`-`else`. Die wichtigsten Unterschiede sind:

* Der Bedingungsoperator hat im Gegensatz zu `if`-`else` einen Ergebniswert und kann
  daher z.B. in Formeln und Funktionsaufrufen verwendet werden
* Bei `if`-Anweisungen kann der `else`-Teil entfallen, der Bedingungsoperator
  verlangt stets eine Angabe von beiden Ergebniswerten

Selbstverständlich können Ausdrücke mit diesem Operator beliebig geschachtelt
werden. Das Maximum von drei Zahlen erhalten wir beispielsweise so:

``` c
 return a > b ? (a > c ? a : c) : (b > c ? b : c);
```

An diesem Beispiel sehen wir auch sofort einen Nachteil des Bedingungsoperators:
Es ist sehr unübersichtlich, verschachtelten Code mit ihm zu schreiben.

## Kontrollstrukturen

Bisher haben unsere Programme einen streng linearen Ablauf gehabt. In diesem
Kapitel werden Sie lernen, wie Sie den Programmfluss steuern können.

### Bedingungen

Um auf Ereignisse zu reagieren, die erst bei der Programmausführung bekannt
sind, werden Bedingungsanweisungen eingesetzt. Eine Bedingungsanweisung wird
beispielsweise verwendet, um auf Eingaben des Benutzers reagieren zu können. Je
nachdem, was der Benutzer eingibt, ändert sich der Programmablauf.

#### `if`

Beginnen wir mit der `if`-Anweisung. Sie hat die folgende Syntax:

``` c
 if(expression) statement;
```

Optional kann eine alternative Anweisung angegeben werden, wenn die Bedingung
expression nicht erfüllt wird:

``` c
 if(expression)
   statement;
 else
   statement;
```

Mehrere Fälle müssen verschachtelt abgefragt werden:

``` c
 if(expression1)
   statement;
 else
   if(expression2)
     statement;
   else
     statement;
```

Hinweis: `else if` - und `else` -Anweisungen sind optional.

Wenn der Ausdruck (engl. expression) nach seiner Auswertung wahr ist, d.h. von
Null(0) verschieden, so wird die folgende Anweisung bzw. der folgende
Anweisungsblock ausgeführt (statement). Ist der Ausdruck gleich Null und somit
die Bedingungen nicht erfüllt, wird der `else` -Zweig ausgeführt, sofern
vorhanden.

Klingt kompliziert, deshalb werden wir uns dies nochmals an zwei Beispielen
ansehen:

``` c
#include <stdio.h>

int main(void)
{
  int zahl;
  printf("Bitte eine Zahl >5 eingeben: ");
  scanf("%i", &zahl);

  if(zahl > 5)
    printf("Die Zahl ist größer als 5\n");

  printf("Tschüß! Bis zum nächsten Mal\n");

  return 0;
}
```
``` bash stdin
666
```
@run_stdin

Wir nehmen zunächst einmal an, dass der Benutzer die Zahl 7 eingibt. In diesem
Fall ist der Ausdruck `zahl > 5` true (wahr) und liefert eine 1 zurück. Da dies
ein Wert ungleich 0 ist, wird die auf `if` folgende Zeile ausgeführt und "Die
Zahl ist größer als 5" ausgegeben. Anschließend wird die Bearbeitung mit der
Anweisung `printf("Tschüß! Bis zum nächsten Mal\n")` fortgesetzt .

Wenn wir annehmen, dass der Benutzer eine 3 eingegeben hat, so ist der Ausdruck
`zahl > 5` false (falsch) und liefert eine 0 zurück. Deshalb wird
`printf("Die Zahl ist größer als 5")` nicht ausgeführt und nur
`"Tschüß! Bis zum nächsten mal"` ausgegeben.

Wir können die `if`-Anweisung auch einfach lesen als: "Wenn zahl größer als 5
ist, dann gib "Die Zahl ist größer als 5" aus". In der Praxis wird man sich
keine Gedanken machen, welches Resultat der Ausdruck `zahl > 5` hat.

Das zweite Beispiel, das wir uns ansehen, besitzt neben `if` auch ein `else if`
und ein `else` :

``` c
#include <stdio.h>

int main(void)
{
  int zahl;
  printf("Bitte geben Sie eine Zahl ein: ");
  scanf("%d", &zahl);

  if(zahl > 0)
    printf("Positive Zahl\n");
  else if(zahl < 0)
    printf("Negative Zahl\n");
  else
    printf("Zahl gleich Null\n");

  return 0;
}
```
``` bash stdin
666
```
@run_stdin

Nehmen wir an, dass der Benutzer die Zahl -5 eingibt. Der Ausdruck `zahl > 0`
ist in diesem Fall falsch, weshalb der Ausdruck ein false liefert (was einer 0
entspricht). Deshalb wird die darauffolgende Anweisung nicht ausgeführt. Der
Ausdruck `zahl < 0` ist dagegen erfüllt, was wiederum bedeutet, dass der
Ausdruck wahr ist (und damit eine 1 liefert) und so die folgende Anweisung
ausgeführt wird.

Nehmen wir nun einmal an, der Benutzer gibt eine 0 ein. Sowohl der Ausdruck
`zahl > 0` als auch der Ausdruck `zahl < 0` sind dann nicht erfüllt. Der `if` -
und der `if` - `else` -Block werden deshalb nicht ausgeführt. Der Compiler
trifft anschließend allerdings auf die `else` -Anweisung. Da keine vorherige
Bedingung zutraf, wird die anschließende Anweisung ausgeführt.

Wir können die `if` - `else if` - `else` –Anweisung auch lesen als: "Wenn zahl
größer ist als 0, gib "Positive Zahl" aus, ist zahl kleiner als 0, gib "Negative
Zahl" aus, ansonsten gib "Zahl gleich Null" aus."

Fassen wir also nochmals zusammen: Ist der Ausdruck in der `if` oder `if` -
`else` -Anweisung erfüllt (wahr), so wird die nächste Anweisung bzw. der nächste
Anweisungsblock ausgeführt. Trifft keiner der Ausdrücke zu, so wird die
Anweisung bzw. der Anweisungsblock, die `else` folgen, ausgeführt.

Es wird im Allgemeinen als ein guter Stil angesehen, jede Verzweigung einzeln zu
klammern. So sollte man der Übersichtlichkeit halber das obere Beispiel so
schreiben:

``` c
#include <stdio.h>

int main(void)
{
  int zahl;
  printf("Bitte geben Sie eine Zahl ein: ");
  scanf("%d", &zahl);

  if(zahl > 0) {
    printf("Positive Zahl\n");
  } else if(zahl < 0) {
    printf("Negative Zahl\n");
  } else {
    printf("Zahl gleich Null\n");
  }

  return 0;
}
```
``` bash stdin
-66
```
@run_stdin

Versehentliche Fehler wie

``` c
int a;

if(zahl > 0)
  a = berechne_a(); printf("Der Wert von a ist %d\n", a);
```

was so verstanden werden würde

``` c
int a;

if(zahl > 0) {
  a = berechne_a();
}

printf("Der Wert von a ist %d\n", a);
```

werden so vermieden.

#### Bedingter Ausdruck

Mit dem bedingten Ausdruck kann man eine `if`-`else`-Anweisung wesentlich kürzer
formulieren. Sie hat die Syntax

``` c
exp1 ? exp2 : exp3
```

Zunächst wird das Ergebnis von exp1 ermittelt. Liefert dies einen Wert ungleich
0 und ist somit true, dann ist der Ausdruck exp2 das Resultat der bedingten
Anweisung, andernfalls ist exp3 das Resultat.

Beispiel:

``` c
 int x = 20;
 x = (x >= 10) ? 100 : 200;
```

Der Ausdruck x >= 10 ist wahr und liefert deshalb eine 1. Da dies ein Wert
ungleich 0 ist, ist das Resultat des bedingten Ausdrucks 100.

Der obige bedingte Ausdruck entspricht

``` c
 if(x >= 10)
   x = 100;
 else
   x = 200;
```

Die Klammern in unserem Beispiel sind nicht unbedingt notwendig, da
Vergleichsoperatoren einen höheren Vorrang haben als der `?:`-Operator.
Allerdings werden sie von vielen Programmierern verwendet, da sie die Lesbarkeit
verbessern.

Der bedingte Ausdruck wird häufig, aufgrund seines Aufbaus, ternärer bzw.
dreiwertiger Operator genannt.

#### `switch`

Eine weitere Auswahlanweisung ist die `switch`-Anweisung. Sie wird in der Regel
verwendet, wenn eine unter vielen Bedingungen ausgewählt werden soll. Sie hat
die folgende Syntax:

``` c
  switch(expression)
  {
    case const-expr: statements
    case const-expr: statements
    ...
    default: statements
  }
```

In den runden Klammern der `switch`-Anweisung steht der Ausdruck, welcher mit
den Konstanten (`const`-expr) verglichen wird, die den `case`-Anweisungen direkt
folgen. War ein Vergleich positiv, wird zur entsprechenden `case`-Anweisung
gesprungen und sämtlicher darauffolgender Code ausgeführt (eventuelle weitere
`case`-Anweisungen darin sind wirkungslos). Eine `break`-Anweisung beendet die
`switch`-Verzweigung und setzt bei der Anweisung nach der schließenden
geschweiften Klammer fort. Optional kann eine `default`-Anweisung angegeben
werden, zu der gesprungen wird, falls keiner der Vergleichswerte passt.

Vorsicht: Im Gegensatz zu anderen Programmiersprachen bricht die
`switch`-Anweisung nicht ab, wenn eine `case`-Bedingung erfüllt ist. Eine
`break`-Anweisung ist zwingend erforderlich, wenn die nachfolgenen `case`-Blöcke
nicht bearbeitet werden sollen.

Sehen wir uns dies an einem textbasierenden Rechner an, bei dem der Benutzer
durch die Eingabe eines Zeichens eine der Grundrechenarten auswählen kann:

``` c
#include <stdio.h>

int main(void)
{
  double zahl1, zahl2;
  char auswahl;
  printf("\nMini-Taschenrechner\n");
  printf("-----------------\n\n");

  do
  {
     printf("\nBitte geben Sie die erste Zahl ein: ");
     scanf("%lf", &zahl1);
     printf("Bitte geben Sie die zweite Zahl ein: ");
     scanf("%lf", &zahl2);
     printf("\nZahl (a) addieren, (s) subtrahieren, (d) dividieren oder (m) multiplizieren?");
     printf("\nZum Beenden wählen Sie (b) ");
     scanf(" %c",&auswahl);

     switch(auswahl)
     {
       case 'a' :
       case 'A' :
         printf("Ergebnis: %f", zahl1 + zahl2);
         break;
       case 's' :
       case 'S' :
         printf("Ergebnis: %f", zahl1 - zahl2);
         break;
       case 'D' :
       case 'd' :
         if(zahl2 == 0)
           printf("Division durch 0 nicht möglich!");
         else
           printf("Ergebnis: %f", zahl1 / zahl2);
         break;
       case 'M' :
       case 'm' :
         printf("Ergebnis: %f", zahl1 * zahl2);
         break;
       case 'B' :
       case 'b' :
         break;
       default:
         printf("Fehler: Diese Eingabe ist nicht möglich!");
         break;
     }
   }

   while(auswahl != 'B' && auswahl != 'b');

   return 0;
}
```
``` bash stdin
3
4
A
3
4
b
```
@run_stdin

Mit der `do-while`-Schleife wollen wir uns erst später beschäftigen. Nur so
viel: Sie dient dazu, dass der in den Blockklammern eingeschlossene Teil nur
solange ausgeführt wird, bis der Benutzer b oder B zum Beenden eingegeben hat.

Die Variable auswahl erhält die Entscheidung des Benutzers für eine der vier
Grundrechenarten oder den Abbruch des Programms. Gibt der Anwender
beispielsweise ein kleines `'s'` ein, fährt das Programm bei der Anweisung
`case('s')` fort und es werden solange alle folgenden Anweisungen bearbeitet,
bis das Programm auf ein `break` stößt. Wenn keine der `case` Anweisungen
zutrifft, wird die `default`-Anweisung ausgeführt und eine Fehlermeldung
ausgegeben.

Etwas verwirrend mögen die Anweisungen `case('B')` und `case('b')` sein, denen
unmittelbar `break` folgt. Sie sind notwendig, damit bei der Eingabe von B oder
b nicht die `default`-Anweisung ausgeführt wird.

### Schleifen

Schleifen werden verwendet, um einen Programmabschnitt mehrmals zu wiederholen.
Sie kommen in praktisch jedem größeren Programm vor.

#### `for`-Schleife

Die `for`-Schleife wird in der Regel dann verwendet, wenn von vornherein bekannt
ist, wie oft die Schleife durchlaufen werden soll. Die `for`-Schleife hat die
folgende Syntax:

``` c
for (expressionopt; expressionopt; expressionopt)
 statement
```

In der Regel besitzen `for`-Schleifen einen Schleifenzähler. Dies ist eine
Variable, zu der bei jedem Durchgang ein Wert addiert oder subtrahiert wird
(oder die durch andere Rechenoperationen verändert wird). Der Schleifenzähler
wird über den ersten Ausdruck initialisiert. Mit dem zweiten Ausdruck wird
überprüft, ob die Schleife fortgesetzt oder abgebrochen werden soll. Letzterer
Fall tritt ein, wenn dieser den Wert 0 annimmt – also der Ausdruck false
(falsch) ist. Der letzte Ausdruck dient schließlich dazu, den Schleifenzähler zu
verändern.

Mit einem Beispiel sollte dies verständlicher werden. Das folgende Programm
zählt von 1 bis 5:

``` c
#include <stdio.h>

int main()
{
   int i;

   for(i = 1; i <= 5; ++i)
     printf("%d  ", i);

   return 0;
}
```
@run

Die Schleife beginnt mit dem Wert 1 (`i = 1`) und erhöht den Schleifenzähler `i`
bei jedem Durchgang um 1 (`++i`). Solange der Wert `i` kleiner oder gleich 5 ist
(`i <= 5`), wird die Schleife durchlaufen. Ist `i` gleich 6 und daher die
Aussage `i <= 5` falsch, wird der Wert 0 zurückgegeben und die Schleife
abgebrochen. Insgesamt wird also die Schleife 5mal durchlaufen.

Wenn das Programm kompiliert und ausgeführt wird, erscheint die folgende Ausgabe
auf dem Monitor:

```
1  2  3  4  5
```

Anstelle des Präfixoperators hätte man auch den Postfixoperator `i++` benutzen
und `for(i = 1; i <= 5; i++)` schreiben können. Diese Variante unterscheidet
sich nicht von der oben verwendeten. Eine weitere Möglichkeit wäre,
`for(i = 1; i <= 5; i = i + 1)` oder `for(i = 1; i <= 5; i += 1)` zu schreiben.
Die meisten Programmierer benutzen eine der ersten beiden Varianten, da sie der
Meinung sind, dass schneller ersichtlich wird, dass `i` um eins erhöht wird und
dass durch den Inkrementoperator Tipparbeit gespart werden kann.

Damit die `for`-Schleife noch etwas klarer wird, wollen wir uns noch ein paar
Beispiele ansehen:

```c
 for(i = 0;  i < 7; i += 1.5)
```

Der einzige Unterschied zum letzten Beispiel besteht darin, dass die Schleife
nun in 1,5er Schritten durchlaufen wird. Der nachfolgende Befehl oder
Anweisungsblock wird insgesamt 5mal durchlaufen. Dabei nimmt der Schleifenzähler
`i` die Werte 0, 1.5, 3, 4.5 und 6 an (Die Variable `i` muss hier natürlich
einen Gleitkommadatentyp haben).

``` c
 for(i = 20; i > 5; i -= 5)
```

Diesmal zählt die Schleife rückwärts. Sie wird dreimal durchlaufen. Der
Schleifenzähler nimmt dabei die Werte 20, 15 und 10 an. Und noch ein letztes
Beispiel:

``` c
 for(i=1; i<20; i*=2)
```

Prinzipiell lassen sich für die Schleife alle Rechenoperationen benutzen. In
diesem Fall wird in der Schleife die Multiplikation benutzt. Sie wird 5mal
durchlaufen. Dabei nimmt der Schleifenzähler die Werte 1, 2, 4, 8 und 16 an.

Wie Sie aus der Syntax unschwer erkennen können, sind die Ausdrücke in den
runden Klammern optional. So ist beispielsweise

``` c
  for(;;)
```

korrekt. Da nun der zweite Ausdruck immer wahr ist, und damit der Schleifenkopf
niemals den Wert 0 annehmen kann, wird die Schleife unendlich oft durchlaufen.
Eine solche Schleife wird auch als Endlosschleife bezeichnet, da sie niemals
endet (in den meisten Betriebssystemen gibt es eine Möglichkeit das dadurch
"stillstehende" Programm mit einer Tastenkombination abzubrechen).
Endlosschleifen können beabsichtigt (siehe dazu auch weiter unten die
`break`-Anweisung) oder unbeabsichtigte Programmierfehler sein.

Mehrere Befehle hinter einer `for`-Anweisung müssen immer in Blockklammern
eingeschlossen werden:

``` c
 for(i = 1; i < 5; i++)
 {
   printf("\nEine Schleife: ");
   printf("%d ", i);
 }
```

Schleifen lassen sich auch schachteln, das heißt, innerhalb einer Schleife
dürfen sich eine oder mehrere weitere Schleifen befinden. Beispiel:

``` c
#include <stdio.h>

int main()
{
   int i, j, Zahl = 1;

   for (i = 1; i <= 11; i++)
   {
      for (j = 1; j <= 10; j++)
      {
         printf ("%4i", Zahl++);
      }
      printf ("\n");
   }

   return 0;
}
```
@run

Nach der Kompilierung und Übersetzung des Programms erscheint die folgende
Ausgabe:

```
   1   2   3   4   5   6   7   8   9  10
  11  12  13  14  15  16  17  18  19  20
  21  22  23  24  25  26  27  28  29  30
  31  32  33  34  35  36  37  38  39  40
  41  42  43  44  45  46  47  48  49  50
  51  52  53  54  55  56  57  58  59  60
  61  62  63  64  65  66  67  68  69  70
  71  72  73  74  75  76  77  78  79  80
  81  82  83  84  85  86  87  88  89  90
  91  92  93  94  95  96  97  98  99 100
 101 102 103 104 105 106 107 108 109 110
```

Damit bei der Ausgabe alle 10 Einträge eine neue Zeile beginnt, wird die innere
Schleife nach 10 Durchläufen beendet. Anschließend wird ein Zeilenumbruch
ausgegeben und die innere Schleife von der äußeren Schleife wiederum insgesamt
11-mal aufgerufen.


#### `while`-Schleife

Häufig kommt es vor, dass eine Schleife, beispielsweise bei einem bestimmten
Ereignis, abgebrochen werden soll. Ein solches Ereignis kann z.B. die Eingabe
eines bestimmen Wertes sein. Hierfür verwendet man meist die `while`-Schleife,
welche die folgende Syntax hat:

``` c
 while (expression)
   statement
```

Im folgenden Beispiel wird ein Text solange von der Tastatur eingelesen, bis der
Benutzer die Eingabe abschließt (In der Microsoft-Welt geschieht dies durch
`<Strg>-<Z>`, in der UNIX-Welt über die Tastenkombination `<Strg>-<D>`). Als
Ergebnis liefert das Programm die Anzahl der Leerzeichen:

``` c
#include <stdio.h>

int main()
{
  int c;
  int zaehler = 0;

  printf("Leerzeichenzähler - zum Beenden STRG + D / STRG + Z\n");

  while((c = getchar()) != EOF)
  {
    if(c == ' ')
      zaehler++;
  }

  printf("Anzahl der Leerzeichen: %d\n", zaehler);

  return 0;
}
```
@run

Die Schleife wird abgebrochen, wenn der Benutzer die Eingabe (mit `<Strg>-<Z>`
oder `<Strg>-<D>`) abschließt und somit das nächste zu liefernde Zeichen das
EOF-Zeichen ist. In diesem Fall ist der Ausdruck (`(c = getchar()) != EOF`)
nicht mehr wahr, liefert 0 zurück, und die Schleife wird beendet.

Bitte beachten Sie, dass die Klammer um `c = getchar()` nötig ist, da der
Ungleichheitsoperator eine höhere Priorität hat als der Zuweisungsoperator `=`.
Neben den Zuweisungsoperatoren besitzen auch die logischen Operatoren Und (`&`),
Oder (`|`) sowie XOR (`^`) eine niedrigere Priorität.

Noch eine Anmerkung zu diesem Programm: Wie Sie vielleicht bereits festgestellt
haben, wird das Zeichen, das `getchar()` zurückliefert, in einer Variable des
Typs Integer gespeichert. Für die Speicherung eines Zeichenwertes genügt, wie
wir bereits gesehen haben, eine Variable vom Typ Character. Der Grund dafür,
dass wir dies hier nicht können, liegt im ominösen `EOF`-Zeichen. Es dient
normalerweise dazu, das Ende einer Datei zu markieren - auf Englisch das End of
File - oder kurz `EOF`. Allerdings ist `EOF` ein negativer Wert vom Typ `int` ,
so dass kein "Platz" mehr in einer Variable vom Typ `char` ist. Viele
Implementierungen benutzen -1 um das `EOF`-Zeichen darzustellen, was der
ANSI-C-Standard allerdings nicht vorschreibt (der tatsächliche Wert ist in der
Headerdatei `<stdio.h>` abgelegt).

##### Ersetzen einer `for`-Schleife

Eine `for`-Schleife kann immer durch eine `while`-Schleife ersetzt werden. So
ist beispielsweise unser `for`-Schleifenbeispiel aus dem ersten Abschnitt mit
der folgenden `while`-Schleife äquivalent:

``` c
#include <stdio.h>

int main()
{
  int x = 1;

  while(x <= 5)
  {
    printf("%d  ", x);
    ++x;
  }

  return 0;
}
```
@run

Ob man `while` oder `for` benutzt, hängt letztlich von der Vorliebe des
Programmierers ab. In diesem Fall würde man aber vermutlich eher eine
`for`-Schleife verwenden, da diese Schleife eine Zählervariable enthält, die bei
jedem Schleifendurchgang um eins erhöht wird.

#### `do-while`-Schleife

Im Gegensatz zur `while`-Schleife findet bei der `do-while`-Schleife die
Überprüfung der Wiederholungsbedingung am Schleifenende statt. So kann
garantiert werden, dass die Schleife mindestens einmal durchlaufen wird. Sie hat
die folgende Syntax:

``` c
 do
   statement
 while (expression);
```

Das folgende Programm addiert solange Zahlen auf, bis der Anwender eine 0
eingibt:

``` c
#include <stdio.h>

int main(void)
{
 float zahl;
 float ergebnis = 0;

 do
 {
   printf ("Bitte Zahl zum Addieren eingeben (0 zum Beenden):");
   scanf("%f",&zahl);
   ergebnis += zahl;
 }
 while (zahl != 0);

 printf("Das Ergebnis ist %f \n", ergebnis);

 return 0;
}
```
``` bash stdin
12.12
3
-5
0
```
@run_stdin

Die Überprüfung, ob die Schleife fortgesetzt werden soll, findet in Zeile 14
statt. Mit do in Zeile 8 wird die Schleife begonnen, eine Prüfung findet dort
nicht statt, weshalb der Block von Zeile 9 bis 13 in jedem Fall mindestens
einmal ausgeführt wird.

Wichtig: Beachten Sie, dass das `while` mit einem Semikolon abgeschlossen werden
muss, sonst wird das Programm nicht korrekt ausgeführt!

#### Schleifen abbrechen


##### `continue`

Eine continue-Anweisung beendet den aktuellen Schleifendurchlauf und setzt,
sofern die Schleifen-Bedingung noch erfüllt ist, beim nächsten Durchlauf fort.

``` c
#include <stdio.h>

int main(void)
{
  double i;

  for(i = -10; i <= 10; i++)
  {
    if(i == 0)
     continue;

    printf("%lf \n", 1/i);
  }

  return 0;
}
```
@run

Das Programm berechnet in ganzzahligen Schritten die Werte für 1/i im Intervall
`[-10, 10]`. Da die Division durch Null nicht erlaubt ist, springen wir mit
Hilfe der `if`-Bedingung wieder zum Schleifenkopf.

##### `break`

Die `break`-Anweisung beendet eine Schleife und setzt bei der ersten Anweisung
nach der Schleife fort. Nur innerhalb einer Wiederholungsanweisung, wie in
`for`-, `while`-, `do-while`-Schleifen oder innerhalb einer `switch`-Anweisung
ist eine `break`-Anweisung funktionsfähig. Sehen wir uns dies an folgendem
Beispiel an:

``` c
#include <stdio.h>

int eingabe;
int passwort = 2323;

int main(void) {
    while (1) {
        printf("Geben Sie bitte das Zahlen-Passwort ein: ");
        scanf("%d", &eingabe);

        if (passwort == eingabe) {
            printf("Passwort korrekt\n");
            break;
        } else {
            printf("Das Passwort ist nicht korrekt.\n");
        }

        printf("Bitte versuchen Sie es nochmal!\n");
    }
    printf("Programm beendet\n");

    return 0;
}
```
``` bash stdin
1211
000
2323
```
@run_stdin


Wie Sie sehen ist die `while`-Schleife als Endlosschleife konzipiert. Hat man
das richtige Passwort eingegeben, so wird die `printf`-Anweisung ausgegeben, und
anschließend wird diese Endlosschleife durch die `break`-Anweisung verlassen.
Die nächste Anweisung, die dann ausgeführt wird, ist die `printf`-Anweisung
unmittelbar nach der Schleife. Ist das Passwort aber inkorrekt, so wird der
`else`-Block mit den weiteren `printf`-Anweisungen in der `while`-Schleife
ausgeführt. Anschließend wird die `while`-Schleife wieder ausgeführt.

##### Tastaturpuffer leeren

Es ist wichtig, den Tastaturpuffer zu leeren, damit Tastendrücke nicht eine
unbeabsichtigte Aktion auslösen (Es besteht außerdem noch die Gefahr eines
Puffer-Überlaufs). In ANSI-C-Compilern bzw. deren Laufzeitbibliothek ist die
Vollpufferung die Standardeinstellung; diese ist auch sinnvoller als keine
Pufferung, da dadurch weniger Schreib- und Leseoperationen stattfinden. Die
Puffergröße ist abhängig vom Compiler. Weiteres zu Pufferung und
`setbuf()`/`setvbuf()` wird in den weiterführenden Kapiteln behandelt.

Sehen wir uns dies an einem kleinen Spiel an: Der Computer ermittelt eine
Zufallszahl zwischen 1 und 100, die der Nutzer dann erraten soll. Dabei gibt es
immer einen Hinweis, ob die Zahl kleiner oder größer als die eingegebene Zahl
ist.

``` c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(void)
{
  int zufallszahl,  eingabe;
  int durchgaenge;
  char auswahl;
  srand(time(0));

  printf("\nLustiges Zahlenraten");
  printf("\n--------------------");
  printf("\nErraten Sie die Zufallszahl in moeglichst wenigen Schritten!");
  printf("\nDie Zahl kann zwischen 1 und 100 liegen");

  do
  {
    zufallszahl = (rand() % 100 + 1);
    durchgaenge = 1;

    while(1)
    {
      printf("\nBitte geben Sie eine Zahl ein: ");
      scanf("%d", &eingabe);

      if(eingabe > zufallszahl)
      {
        printf("Leider falsch! Die zu erratende Zahl ist kleiner");
        durchgaenge++;
      }
      else if(eingabe < zufallszahl)
      {
        printf("Leider falsch! Die zu erratende Zahl ist größer");
        durchgaenge++;
      }
      else
      {
        printf("Glückwunsch! Sie haben die Zahl in %d", durchgaenge);
        printf(" Schritten erraten.");
        break;
      }
    }

    printf("\nNoch ein Spiel? (J/j für weiteres Spiel)");

    // Rest vom letzten scanf aus dem Tastaturpuffer löschen
    while((auswahl = getchar()) != '\n' && auswahl != EOF);

    auswahl = getchar();
  } while(auswahl == 'j' || auswahl == 'J');

  return 0;
}
```
``` bash -stdin
0
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99

```
@run_stdin

Wie Sie sehen, ist die innere `while`-Schleife als Endlosschleife konzipiert.
Hat der Spieler die richtige Zahl erraten, so wird der `else`-Block ausgeführt.
In diesem wird die Endlosschleife schließlich mit `break` abgebrochen. Die
nächste Anweisung, die dann ausgeführt wird, ist die `printf` -Anweisung
unmittelbar nach der Schleife.

Die äußere `while`-Schleife in Zeile 52 wird solange wiederholt, bis der Benutzer
nicht mehr mit einem kleinen oder großen j antwortet. Beachten Sie, dass im
Gegensatz zu den Operatoren `&` und `|` die Operatoren `&&` und `||` streng von
links nach rechts bewertet werden.

In diesem Beispiel hat dies keine Auswirkungen. Allerdings schreibt der Standard
für den `||`-Operator auch vor, dass, wenn der erste Operand des Ausdrucks
verschieden von 0 (wahr) ist, der Rest nicht mehr ausgewertet wird. Die Folgen
soll dieses Beispiel verdeutlichen:

``` c
 int c, a = 5;

 while (a == 5 || (c = getchar()) != EOF)
```

Da der Ausdruck `a == 5` true ist, liefert er also einen von 0 verschiedenen
Wert zurück. Der Ausdruck `c = getchar()` wird deshalb erst gar nicht mehr
ausgewertet, da bereits nach der Auswertung des ersten Operanden feststeht, dass
die ODER-Verknüpfung den Wahrheitswert true besitzen muss (Wenn Ihnen dies nicht
klar geworden ist, sehen Sie sich nochmals die Wahrheitstabelle der
ODER-Verknüpfung an). Dies hat zur Folge, dass `getchar()` nicht mehr ausgeführt
und deshalb kein Zeichen eingelesen wird. Wenn wir wollen, dass `getchar()`
aufgerufen wird, so müssen wir die Reihenfolge der Operanden umdrehen.

Dasselbe gilt natürlich auch für den `&&`-Operator, nur dass in diesem Fall der
zweite Operand nicht mehr ausgewertet wird, wenn der erste Operand bereits 0
ist.

Beim `||` und `&&` -Operator handelt es sich um einen Sequenzpunkt: Wie wir
gesehen haben, ist dies ein Punkt, bis zu dem alle Nebenwirkungen vom Compiler
ausgewertet sein müssen. Auch hierzu ein Beispiel:

``` c
  i = 7;
  if(i++ == 5 || (i += 3) == 4)
```

Zunächst wird der erste Operand ausgewertet (`i++ == 5`) - es wird `i` mit dem
Wert 5 verglichen und dann um eins erhöht (Post-Inkrement!). Wie wir gerade
gesehen haben, wird der zweite Operand (`(i += 3) == 4`) nur dann ausgewertet,
wenn feststeht, dass der erste Operand 0 liefert (bzw. keinen nicht von 0
verschiedenen Wert). Da der erste Operand keine wahre Aussage darstellt (7 wird
auf Gleichheit mit 5 überprüft und gibt "falsch" zurück, da 7 nicht gleich 5
ist) wird der zweite ausgewertet. Hierbei wird zunächst 8 um 3 erhöht, das
Ergebnis der Zuweisung (11) mit 4 verglichen. Es wird also der gesamte Ausdruck
ausgewertet (er ergibt insgesamt übrigens "falsch", da weder der erste noch der
zweite Operand "wahr" ergeben; 8 ist ungleich 5, und 11 ist ungleich 4).

Die Auswertung findet auf jeden Fall in dieser Reihenfolge statt, nicht
umgekehrt. Es ist also nicht möglich, dass zu `i` zuerst die 3 addiert wird und
so den Wert 10 annimmt, um anschließend um 1 erhöht zu werden. Diese Tatsache
ändert in diesem Beispiel nichts an der Falschheit des gesamten Ausdruckes, kann
aber zu unbedachten Resultaten führen, wenn im zweiten Operator eine Funktion
aufgerufen wird, die Nebenwirkungen hat (beispielsweise das Anlegen einer
Datei). Ergibt der erste Operand einen Wert ungleich 0 (also wahr), so wird der
zweite (rechts vom `||`-Operator) nicht mehr aufgerufen und die Datei nicht mehr
angelegt.

Bevor wir uns weiter mit Kontrollstrukturen beschäftigen, lassen Sie uns aber
noch einen Blick auf den Zufallsgenerator werfen, da er eine interessante
Anwendung für den Modulo–Operator darstellt. Damit der Zufallsgenerator nicht
immer die gleichen Zahlen ermittelt, muss zunächst der Zufallsgenerator über
`srand(time(0))` mit der Systemzeit initialisiert werden (wenn Sie diese
Bibliotheksfunktionen in Ihrem Programm benutzen wollen, beachten Sie, dass Sie
für die Funktion `time(0)` die Headerdatei `<time.h>` und für die Benutzung des
Zufallsgenerators die Headerdatei `<stdlib.h>` einbinden müssen). Aber wozu
braucht man nun den Modulo-Operator? Die Funktion `rand()` liefert einen Wert
zwischen 0 und mindestens 32767. Um nun einen Zufallswert zwischen 1 und 100 zu
erhalten, führen wir eine Moduloberechnung mit hundert durch und addieren 1. Den
Rest, der ja nun zwischen eins und hundert liegen muss, verwenden wir als
Zufallszahl.

Bitte beachten Sie, dass `rand()` in der Regel keine sehr gute Streuung liefert.
Für statistische Zwecke sollten Sie deshalb nicht auf die Standardbibliothek
zurückgreifen.

### Sonstiges

#### `goto`

Mit einer `goto`-Anweisung setzt man die Ausführung des Programms an einer
anderen Stelle des Programms fort. Diese Stelle im Programmcode wird mit einem
sogenannten Label definiert:

``` c
 LabelName:
```

Zu einem Label springt man mit

``` c
 goto LabelName;
```

In der Anfangszeit der Programmierung wurde `goto` anstelle der eben
vorgestellten Kontrollstrukturen verwendet. Das Ergebnis war eine sehr
unübersichtliche Programmstruktur, die auch häufig als Spaghetticode bezeichnet
wurde. Bis auf wenige Ausnahmen ist es möglich, auf die `goto`-Anweisung zu
verzichten (neuere Sprachen wie Java kennen sogar überhaupt kein `goto` mehr).
Einige der wenigen Anwendungsgebiete von `goto` werden Sie im Kapitel
Programmierstil finden, darüber hinaus werden Sie aber keine weiteren Beispiele
in diesem Buch finden.

## Funktionen

Eine wichtige Forderung der strukturierten Programmierung ist die Vermeidung von
Sprüngen innerhalb des Programms. Wie wir gesehen haben, ist dies in allen
Fällen mit Kontrollstrukturen möglich.

Die zweite Forderung der strukturierten Programmierung ist die Modularisierung.
Dabei wird ein Programm in mehrere Programmabschnitte, die Module, zerlegt. In C
werden solche Module auch als Funktionen bezeichnet. Andere Programmiersprachen
bezeichnen Module als Unterprogramme oder unterscheiden zwischen Funktionen
(Module mit Rückgabewert) und Prozeduren (Module ohne Rückgabewert). Trotz
dieser unterschiedlichen Bezeichnungen ist aber dasselbe gemeint.

Objektorientierte Programmiersprachen gehen noch einen Schritt weiter und
verwenden Klassen zur Modularisierung. Vereinfacht gesagt bestehen Klassen aus
Methoden (vergleichbar mit Funktionen) und Attributen (Variablen). C selbst
unterstützt keine Objektorientierte Programmierung, im Gegensatz zu C++, das auf
C aufbaut.

Die Modularisierung hat eine Reihe von Vorteilen:

**Bessere Lesbarkeit**

Der Quellcode eines Programms kann schnell mehrere tausend Zeilen umfassen. Beim
Linux Kernel sind es sogar über 15 Millionen Zeilen und Windows, das ebenfalls
zum Großteil in C geschrieben wurde, umfasst schätzungsweise auch mehrere
Millionen Zeilen. Um dennoch die Lesbarkeit des Programms zu gewährleisten, ist
die Modularisierung unerlässlich.

**Wiederverwendbarkeit**

In fast jedem Programm tauchen die gleichen Problemstellungen mehrmals auf. Oft
gilt dies auch für unterschiedliche Applikationen. Da nur Parameter und
Rückgabetyp für die Benutzung einer Funktion bekannt sein müssen, erleichtert
dies die Wiederverwendbarkeit. Um die Implementierungsdetails muss sich der
Entwickler dann nicht mehr kümmern.

**Wartbarkeit**

Fehler lassen sich durch die Modularisierung leichter finden und beheben.
Darüber hinaus ist es leichter, weitere Funktionalitäten hinzuzufügen oder zu
ändern.

### Funktionsdefinition

Im Kapitel Was sind Variablen haben wir die Quaderoberfläche berechnet. Nun
wollen wir eine Funktion schreiben, die die Oberfläche eines Zylinders
berechnet. Dazu schauen wir uns zunächst die Syntax einer Funktion an:

``` c
Rückgabetyp Funktionsname(Parameterliste)
{
	Anweisungen
}
```

Die Anweisungen werden als Funktionsrumpf bezeichnet, die erste Zeile als
Funktionskopf.

Ein Programm mit einer Funktion zur Zylinderoberflächenberechnung sieht z.B. wie
folgt aus:

``` c
#include <stdio.h>

#define PI 3.1415926535898f

float zylinder_oberflaeche(float h, float r)
{
	float o;
	o = 2 * PI * r * (r + h);
	return o;
}

int main()
{
	float r, h;
	printf("Programm zur Berechnung einer Zylinderoberfläche\n\n");
	printf("Höhe des Zylinders: ");
	if (scanf("%f", &h) != 1) {
		printf("Die Höhe sollte eine Zahl sein!\n");
		return -1;
	}
	printf("Radius des Zylinders: ");

	if (scanf("%f", &r) != 1) {
		printf("Der Radius sollte eine Zahl sein!\n");
		return -1;
	}
	printf("Oberfläche: %f \n", zylinder_oberflaeche(h, r));

	return 0;
}
```
``` bash stdin
12
44
```
@run_stdin

* In Zeile 3 beginnt die Funktionsdefinition. Das `float`  ganz am Anfang der
  Funktion, der sogenannte Funktionstyp, sagt dem Compiler, dass ein Wert mit
  dem Typ `float`  zurückgegeben wird. In Klammern werden die Übergabeparameter
  `h` und `r` deklariert, die der Funktion übergeben werden.
* Mit `return` wird die Funktion beendet und ein Wert an die aufrufende Funktion
  zurückgegeben (hier: `main`). In unserem Beispiel geben wir den Wert von `o`
  zurück, also das Ergebnis unserer Berechnung. Der Datentyp des Ausdrucks
  sollte mit dem Typ des Rückgabewertes des Funktionskopfs übereinstimmen.
* Soll der aufrufenden Funktion kein Wert zurückgegeben werden, muss als Typ der
  Rückgabewert `void` angegeben werden. Eine Funktion, die lediglich einen Text
  ausgibt hat beispielsweise den Rückgabetyp `void` , da sie keinen Wert
  zurückgibt.
* In Zeile 26 wird die Funktion `zylinder_oberflaeche` aufgerufen. Hier werden
  die beiden Parameter `h` und `r` übergeben. Der zurückgegebene Wert wird
  ausgegeben. Es wäre aber genauso denkbar, dass der Wert einer Variable
  zugewiesen, mit einem anderen Wert verglichen oder mit dem Rückgabewert
  weitergerechnet wird.
* Der Rückgabewert muss aber nicht ausgewertet werden. Es ist kein Fehler, wenn
  der Rückgabewert unberücksichtigt bleibt. Man kann allerdings einer Funktion
  ein sogenanntes Attribut zuweisen, das bewirkt, dass der Compiler eine Warnung
  ausgibt, wenn der Rückgabewert ignoriert wird, was z.B. bei `scanf` der Fall
  ist.

Auch die Funktion `main` hat einen Rückgabewert. Ist der Wert 0, so bedeutet
dies, dass das Programm ordnungsgemäß beendet wurde, ist der Wert -1, so
bedeutet dies, dass ein Fehler aufgetreten ist.


#### Beispiele fehlerhafter Funktionen

``` c
void foo()
{
	// Code
	return 5; // Fehler
}
```

Eine Funktion, die als `void` deklariert wurde, darf keinen Rückgabetyp
erhalten. Der Compiler sollte hier eine Warnung oder sogar eine Fehlermeldung
ausgeben.

``` c
#include <stdio.h>

int foo()
{
	// Code
	return 5;
	printf("Diese Zeile wird nie ausgeführt");
}
```

Bei diesem Beispiel wird der Compiler weder eine Warnung noch eine Fehlermeldung
ausgeben. Allerdings wird die `printf` Funktion niemals ausgeführt, da `return`
nicht nur einen Wert zurückgibt sondern die Funktion `foo()` auch beendet.

#### Sonstiges

In der ursprünglichen Sprachdefinition von K&R wurde nicht gefordert, dass jede
Funktion einen Rückgabetyp besitzen muss. Wenn der Rückgabetyp fehlte, wurde
standardmäßig `int` angenommen. Dies ist aber inzwischen nicht mehr erlaubt.
Jede Funktion muss einen Rückgabetyp explizit angeben.

Wenn eine Funktion mit einem Rückgabewert, der nicht `void` ist, nichts mittels
`return` zurückgibt, gibt der Compiler eine Warnung aus und der zurückgegebene
Wert bei der Ausführung ist nicht definiert.

### Prototypen

Auch bei Funktionen unterscheidet man wie bei Variablen zwischen **Definition**
und **Deklaration**. Mit

``` c
float  zylinder_oberflaeche(float h, float r)
{
	float o;
	o = 2 * PI * r * (r + h);
	return o;
}
```

wird die Funktion `zylinder_oberflaeche` (siehe oben) definiert.

Bei einer Funktionsdeklaration wird nur der Funktionskopf gefolgt von einem
Semikolon angeben. Die Funktion `zylinder_oberflaeche` beispielsweise wird wie
folgt deklariert:

``` c
float zylinder_oberflaeche(float h, float r);
```

Dies ist identisch mit

``` c
extern float zylinder_oberflaeche(float h, float r);
```

Die Meinungen, welche Variante benutzt werden soll, gehen hier auseinander:
Einige Entwickler sind der Meinung, dass das Schlüsselwort `extern` die
Lesbarkeit verbessert, andere wiederum nicht. Wir werden im Folgenden das
Schlüsselwort `extern` in diesem Zusammenhang nicht verwenden.

Eine Trennung von Definition und Deklaration ist notwendig, wenn die Definition
der Funktion erst nach der Benutzung erfolgen soll. Eine Deklaration einer
Funktion wird auch als Prototyp oder Funktionskopf bezeichnet. Damit kann der
Compiler überprüfen, ob die Funktion überhaupt existiert und Rückgabetyp und Typ
der Argumente korrekt sind. Stimmen Prototyp und Funktionsdefinition nicht
überein oder wird eine Funktion aufgerufen, die noch nicht definiert wurde oder
keinen Prototyp besitzt, so ist dies ein Fehler.

Das folgende Programm ist eine weitere Abwandlung des Programms zur Berechnung
der Zylinderoberfläche. Die Funktion `zylinder_oberflaeche` wurde dabei
verwendet, bevor sie definiert wurde:

``` c
#include <stdio.h>

#define PI 3.1415926535898f

float zylinder_oberflaeche(float h, float r);

int main()
{
	float r, h;
	printf("Programm zur Berechnung einer Zylinderoberfläche\n\n");
	printf("Höhe des Zylinders: ");
	if (scanf("%f", &h) != 1) {
		printf("Die Höhe sollte eine Zahl sein!\n");
		return -1;
	}
	printf("Radius des Zylinders: ");
	if (scanf("%f", &r) != 1) {
		printf("Der Radius sollte eine Zahl sein!\n");
		return -1;
	}
	printf("Oberfläche: %f \n", zylinder_oberflaeche(h, r));
	return 0;
}

float zylinder_oberflaeche(float h, float r)
{
	float o;
	o = 2 * PI * r * (r + h);
	return o;
}
```
``` bash stdin
3.1
4.2
```
@run_stdin

Der Prototyp wird in Zeile 5 deklariert, damit die Funktion in Zeile 21
verwendet werden kann. An dieser Stelle kann der Compiler auch prüfen, ob der
Typ und die Anzahl der übergebenen Parameter richtig ist (dies könnte er nicht,
hätten wir keinen Funktionsprototyp deklariert). Ab Zeile 25 wird die Funktion
`zylinder_oberflaeche` definiert.

Die Bezeichner der Parameter müssen im Prototyp und der Funktionsdefinition
nicht übereinstimmen. Sie können sogar ganz weggelassen werden. So kann Zeile 5
auch ersetzt werden durch:

``` c
float zylinder_oberflaeche(float, float);
```

Wichtig: Bei Prototypen unterscheidet C zwischen einer leeren Parameterliste und
einer Parameterliste mit `void`. Ist die Parameterliste leer, so bedeutet dies,
dass die Funktion eine nicht definierte Anzahl an Parametern besitzt. Das
Schlüsselwort `void` gibt an, dass der Funktion keine Werte übergeben werden
dürfen. Beispiel:

``` c
int foo1();
int foo2(void);

int main()
{
  foo1(1, 2, 3); // kein Fehler
  foo2(1, 2, 3); // Fehler
  return 0;
}
```
@run

Bei Aufruf der Funktion `foo2` in Zeile 7 gibt der Compiler eine Fehlermeldung
aus, bei Aufruf der Funktion `foo1` in Zeile 6 nicht.

Diese Aussage gilt übrigens nur für Prototypen: Laut C Standard bedeutet eine
leere Liste bei Funktionsdeklarationen, die Teil einer Definition sind, dass die
Funktion keine Parameter hat. Im Gegensatz dazu bedeutet eine leere Liste in
einer Funktionsdeklaration, die nicht Teil einer Definition sind (also
Prototypen), dass keine Informationen über die Anzahl oder Typen der Parameter
vorliegt - so wie wir das eben am Beispiel der Funktion foo1 gesehen haben.

Wenn das Programm mit einem C++ Compiler übersetzt wird, wird auch im Fall von
foo1 eine Fehlermeldung ausgegeben, da dort auch eine leere Parameterliste
bedeutet, dass der Funktion keine Parameter übergeben werden können.

Bibliotheksfunktionen wie `printf` oder `scanf` haben einen Prototyp, der sich
üblicherweise in der Headerdatei `stdio.h` oder anderen Headerdateien befindet.
Damit kann der Compiler überprüfen, ob die Anweisungen die richtige Syntax
haben. Der Prototyp der `printf` Anweisung hat beispielsweise die folgende Form
(oder ähnlich) in der `stdio.h`:

``` c
extern int printf (const char *__restrict __format, ...); //__
```

Findet der Compiler nun beispielsweise die folgende Zeile im Programm, gibt er
einen Fehler aus:

``` c
printf(45);
```

Der Compiler vergleicht den Typ des Parameters mit dem des Prototypen in der
Headerdatei `stdio.h` und findet dort keine Übereinstimmung. Nun "weiß" er, dass
der Anweisung ein falscher Parameter übergeben wurde und gibt eine Fehlermeldung
aus.

Das Konzept der Prototypen wurde als erstes in C++ eingeführt und war in der
ursprünglichen Sprachdefinition von Kernighan und Ritchie noch nicht vorhanden.
Deshalb kam auch beispielsweise das `"Hello World"` Programm in der ersten
Auflage von "The C Programming Language" ohne `include` Anweisung aus. Erst mit
der Einführung des ANSI Standards wurden auch in C Prototypen eingeführt.

### Inline-Funktionen

Neu im C99-Standard sind Inline-Funktionen. Sie werden definiert, indem das
Schlüsselwort `inline` vorangestellt wird. Beispiel:

``` c
inline float zylinder_oberflaeche(float h, float r)
{
  float o;
  o = 2 * 3.141 * r * (r + h);
  return(o);
}
```

Eine Funktion, die als `inline` definiert ist, soll gemäß dem C-Standard so
schnell wie möglich aufgerufen werden. Die genaue Umsetzung ist der
Implementierung überlassen. Beispielsweise kann der Funktionsaufruf dadurch
beschleunigt werden, dass die Funktion nicht mehr als eigenständiger Code
vorliegt, sondern an der Stelle des Funktionsaufrufs eingefügt wird. Dadurch
entfällt eine Sprunganweisung in die Funktion und wieder zurück. Allerdings muss
der Compiler das Schlüsselwort `inline` nicht beachten, wenn der Compiler keinen
Optimierungsbedarf feststellt. Viele Compiler ignorieren deshalb dieses
Schlüsselwort vollständig und setzen auf Heuristiken, wann eine Funktion
`inline` sein sollte. Globale und lokale Variablen


### Globale und lokale Variablen

Alle bisherigen Beispielprogramme verwendeten lokale Variablen. Sie wurden am
Beginn einer Funktion deklariert und galten nur innerhalb dieser Funktion.
Sobald die Funktion verlassen wird verliert sie ihre Gültigkeit. Eine Globale
Variable dagegen wird außerhalb einer Funktion deklariert (in der Regel am
Anfang des Programms) und behält bis zum Beenden des Programms ihre Gültigkeit
und dementsprechend einen Wert.

``` c
#include <stdio.h>

int GLOBAL_A = 43;
int GLOBAL_B = 12;

void funktion1( );
void funktion2( );

int main( void )
{
    printf( "Beispiele für lokale und globale Variablen: \n\n" );
    funktion1( );
    funktion2( );
    return 0;
}

void funktion1( )
{
    int lokal_a = 18;
    int lokal_b = 65;
    printf( "\nGlobale Variable A: %i", GLOBAL_A );
    printf( "\nGlobale Variable B: %i", GLOBAL_B );
    printf( "\nLokale Variable a: %i", lokal_a );
    printf( "\nLokale Variable b: %i", lokal_b );
}

void funktion2( )
{
    int lokal_a = 45;
    int lokal_b = 32;
    printf( "\n\nGlobale Variable A: %i", GLOBAL_A );
    printf( "\nGlobale Variable B: %i", GLOBAL_B );
    printf( "\nLokale Variable a: %i", lokal_a );
    printf( "\nLokale Variable b: %i \n", lokal_b );
}
```
@run

Die Variablen `GLOBAL_A` und `GLOBAL_B` sind zu Beginn des Programms und
außerhalb der Funktion deklariert worden und gelten deshalb im ganzen Programm.
Sie können innerhalb jeder Funktion benutzt werden. Lokale Variablen wie
`lokal_a` und `lokal_b` dagegen gelten nur innerhalb der Funktion, in der sie
deklariert wurden. Sie verlieren außerhalb dieser Funktion ihre Gültigkeit.

Globale Variablen unterscheiden sich in einem weiteren Punkt von den lokalen
Variablen: Sie werden automatisch mit dem Wert 0 initialisiert wenn ihnen kein
Wert zugewiesen wird. Lokale Variablen dagegen erhalten immer den (zufälligen)
Wert, der sich gerade an der vom Compiler reservierten Speicherstelle befindet
(Speichermüll). Diesen Umstand macht das folgende Programm deutlich:

``` c
#include <stdio.h>

int ZAHL_GLOBAL;

int main( void )
{
    int zahl_lokal;
    printf( "Lokale Variable: %i", zahl_lokal );
    printf( "\nGlobale Variable: %i \n", ZAHL_GLOBAL );
    return 0;
}
```
@run

Das Ergebnis:

```
Lokale Variable: 296
Globale Variable: 0
```

#### Verdeckung

Sind zwei Variablen mit demselben Namen als globale und lokale Variable
definiert, wird immer die lokale Variable bevorzugt. Das nächste Beispiel zeigt
eine solche "Doppeldeklaration":

``` c
#include <stdio.h>

int zahl = 5;
void func( );

int main( void )
{
    int zahl = 3;
    printf( "Ist die Zahl %i als eine lokale oder globale Variable deklariert?", zahl );
    func( );
    return 0;
}

void func( )
{
    printf( "\nGlobale Variable: %i \n", zahl );
}
```
@run

Neben der globalen Variable `zahl` wird in der Hauptfunktion `main` eine weitere
Variable mit dem Namen zahl deklariert. Die globale Variable wird durch die
lokale verdeckt. Da nun zwei Variablen mit demselben Namen existieren, gibt die
`printf` Anweisung die lokale Variable mit dem Wert 3 aus. Die Funktion `func`
soll lediglich verdeutlichen, dass die globale Variable `zahl` nicht von der
lokalen Variablendeklaration gelöscht oder überschrieben wurde.

Man sollte niemals Variablen durch andere verdecken, da dies das intuitive
Verständnis behindert und ein Zugriff auf die globale Variable im
Wirkungsbereich der lokalen Variable nicht möglich ist. Gute Compiler können so
eingestellt werden, dass sie eine Warnung ausgeben, wenn Variablen verdeckt
werden.

Ein weiteres (gültiges) Beispiel für Verdeckung ist

``` c
#include <stdio.h>


int main( void )
{
    int i;
    for( i = 0; i<10; i++ )
    {
        int i;
        for( i = 0; i<10; i++ )
        {
            int i;
            for( i = 0; i<10; i++ )
            {
                printf( "i = %d \n", i );
            }
        }
    }
    return 0;
}
```
@run

Hier werden 3 verschiedene Variablen mit dem Namen `i` angelegt, aber nur das
innerste `i` ist für das `printf` von Belang. Dieses Beispiel ist intuitiv
schwer verständlich und sollte auch nur ein Negativbeispiel sein.

### `exit()``


Mit der Bibliotheksfunktion `exit()` kann ein Programm an einer beliebigen
Stelle beendet werden. In Klammern muss ein Wert übergeben werden, der an die
Umgebung - also in der Regel das Betriebssystem - zurückgegeben wird. Der Wert 0
wird dafür verwendet, um zu signalisieren, dass das Programm korrekt beendet
wurde. Ist der Wert ungleich 0, so ist es implementierungsabhängig, welche
Bedeutung der Rückgabewert hat. Beispiel:

``` c
  exit(2);
```

Beendet das Programm und gibt den Wert 2 an das Betriebssystem zurück.
Alternativ dazu können auch die Makros `EXIT_SUCCESS` und `EXIT_FAILURE`
verwendet werden, um eine erfolgreiche bzw. fehlerhafte Beendigung des Programms
zurückzuliefern.

Anmerkung: Unter DOS kann dieser Rückgabewert beispielsweise mittels IF
ERRORLEVEL in einer Batchdatei ausgewertet werden, unter Unix/Linux enthält die
spezielle Variable `$?` den Rückgabewert des letzten aufgerufenen Programms.
Andere Betriebssysteme haben ähnliche Möglichkeiten; damit sind eigene
Miniprogramme möglich, welche bestimmte Begrenzungen (von z.B. Batch- oder
anderen Scriptsprachen) umgehen können. Sie sollten daher immer Fehlercodes
verwenden, um das Ergebnis auch anderen Programmen zugänglich zu machen.

## Eigene Header

Eigene Module mit den entsprechenden eigenen Headern sind sinnvoll, um ein
Programm in Teilmodule zu zerlegen oder bei Funktionen und Konstanten, die in
mehreren Programmen verwendet werden sollen. Eine Headerdatei – kurz: Header –
hat die Form `myheader.h`. Sie sollte ausschließlich enthalten:

* Funktionsdeklarationen (Prototypen)
* Variablen-Deklarationen (`extern`)
* globale Konstanten (`#define`, `const`)
* eigene Typ-Definitionen (`typedef struct`, `union`, `enum`)

``` c
#ifndef MYHEADER_H
#define MYHEADER_H

#define PI (3.1416)

extern int meineVariable;

extern int meineFunktion1(int);
extern int meineFunktion2(char);

#endif /* MYHEADER_H */
```

Anmerkung: Die Präprozessor-Direktiven `#ifndef`, `#define` und `#endif` werden
detailliert im Kapitel Präprozessor erklärt.

In der ersten Zeile dieses kleinen Beispiels wird ein Include-Guard verwendet,
dabei überprüft der Präprozessor, ob im Kontext des Programms das Makro
`MYHEADER_H` schon definiert ist. Wenn ja, ist auch der Header dem Programm
schon bekannt und wird nicht weiter abgearbeitet. Dies ist nötig, weil es auch
vorkommen kann, dass ein Header die Funktionalität eines andern braucht und
diesen mit einbindet, oder weil im Header Definitionen wie Typdefinitionen mit
`typedef` stehen, die bei Mehrfach-Includes zu Compilerfehlern führen würden.

Wenn das Makro `MYHEADER_H` dem Präprozessor noch nicht bekannt ist, dann
beginnt er ab der zweiten Zeile mit der Abarbeitung der Direktiven im
`if`-Block. Die zweite Zeile gibt dem Präprozessor die Anweisung, das Makro
`MYHEADER_H` zu definieren. Damit wird gemerkt, dass dieser Header schon
eingebunden wurde. Dieser Makroname ist frei wählbar, muss im Projekt jedoch
eindeutig sein. Es hat sich die Konvention etabliert, den Namen dieses Makros
zur Verbesserung der Lesbarkeit an den Dateinamen des Headers anzulehnen und ihn
als `MYHEADER_H` oder `__MYHEADER_H__` zu wählen. Dann wird der Code von Zeile 3
bis 10 in die Quelldatei, welche die `#include`-Direktive enthält, eingefügt.
Zeile 11 kommt bei der Headerdatei immer am Ende und teilt dem Präprozessor das
Ende des `if`-Zweigs (siehe Kapitel Präprozessor) mit.

Variablen allgemein verfügbar zu machen stellt ein besonderes Problem dar, das
besonders für Anfänger schwer verständlich ist. Grundsätzlich sollte man den
Variablen in Header-Dateien das Schlüsselwort `extern` voranstellen. Damit
erklärt man dem Compiler, dass es die Variable meineVariable gibt, diese jedoch
an anderer Stelle definiert ist.

Würde eine Variable in einer Header-Datei definiert werden, würde für jede
C-Datei, die die Header-Datei einbindet, eine eigene Variable mit eigenem
Speicher erstellt. Jede C-Datei hätte also ein eigenes Exemplar, ohne dass sich
deren Bearbeitung auf die Variablen, die die anderen C-Dateien kennen, auswirkt.
Eine Verwendung solcher Variablen sollte vermieden werden, da sie vor allem in
der hardwarenahen Programmierung der Ressourcenschonung dient. Stattdessen
sollte man Funktionen der Art `int getMeineVariable()` benutzen.

Nachdem die Headerdatei geschrieben wurde, ist es noch nötig, eine C-Datei
`myheader.c` zu schreiben. In dieser Datei werden die in den Headerzeilen 8 und
9 deklarierten Funktionen implementiert. Damit der Compiler weiß, dass diese
Datei die Funktionalität des Headers ausprägt, wird als erstes der Header
inkludiert; danach werden einfach wie gewohnt die Funktionen geschrieben.

``` c
#include "myheader.h"

int meineVariable = 0;

int meineFunktion1 (int i)
{
  return (i+1);
}

int meineFunktion2 (char c)
{
  if (c == 'A')
    return 1;
  return 0;
}
```

Die Datei `myheader.c` wird jetzt kompiliert und eine so genannte Objektdatei
erzeugt. Diese hat typischerweise die Form `myheader.obj` oder `myheader.o`.
Zuletzt muss dem eigentlichen Programm die Funktionalität des Headers bekannt
gemacht werden, wie es durch ein `#include "myheader.h"` geschieht, und dem
Linker muss beim Erstellen des Programms gesagt werden, dass er die Objektdatei
`myheader.obj` bzw. `myheader.o` mit einbinden soll.

Damit der im Header verwiesenen Variable auch eine real existierende
gegenübersteht, muss in `myheader.c` eine Variable vom selben Typ und mit
demselben Namen definiert werden.

## Zeiger

Eine Variable wurde bisher immer direkt über ihren Namen angesprochen. Um zwei
Zahlen zu addieren, wurde beispielsweise der Wert einem Variablennamen
zugewiesen:

``` c
 summe = 5 + 7;
```

Eine Variable wird intern im Rechner allerdings immer über eine Adresse
angesprochen (außer die Variable befindet sich bereits in einem
Prozessorregister). Alle Speicherzellen innerhalb des Arbeitsspeichers erhalten
eine eindeutige Adresse. Immer wenn der Prozessor einen Wert aus dem RAM liest
oder schreibt, schickt er diese über den Systembus an den Arbeitsspeicher.

Eine Variable kann in C auch indirekt über die Adresse angesprochen werden. Die
(Beginn)-Adresse einer Variablen oder allgemeiner - eines Speicherbereiches -
liefert der `&`-Operator (auch als Adressoperator bezeichnet). Diesen
Adressoperator kennen Sie bereits von der `scanf`-Anweisung:

``` c
 scanf("%i", &a);
```

Wo diese Variable abgelegt wurde, lässt sich mit einer `printf` Anweisung
herausfinden:

``` c
 printf("%p\n", (void*)&a);
```

Der Wert kann sich je nach Betriebssystem, Plattform und sogar von Aufruf zu
Aufruf unterscheiden. Der Platzhalter `%p` steht für das Wort Zeiger (engl.:
pointer).

Eine Zeigervariable dient dazu, ein Objekt (z.B. eine Variable) über seine
Adresse anzusprechen. Eine Zeigervariable verhält sich genau wie eine "normale"
Variable, deren Wert wird jedoch als Adresse interpretiert. Demzufolge besitzt
auch jede Zeigervariable wiederum eine Adresse.

### Beispiel

Im folgenden Programm wird die Zeigervariable `a` definiert:

``` c
#include <stdio.h>

int main()
{
  int * a, b;

  b = 17;
  a = &b;
  printf("Inhalt der Variablen b:    %i\n", b);
  printf("Inhalt des Speichers der Adresse auf die a zeigt:    %i\n", * a);
  printf("Adresse der Variablen b:   %p\n", (void*)&b);
  printf("Adresse auf die die Zeigervariable a verweist:   %p\n", (void*)a);
  // Aber
  printf("Adresse der Zeigervariable a: %p\n", &a);
  return 0;
}
```
@run

Abb. 1 - Das (vereinfachte) Schema zeigt wie das Beispielprogramm arbeitet. Der
Zeiger a zeigt auf die Variable `b`. Die Speicherstelle des Zeigers a besitzt
lediglich die Adresse von `b` (im Beispiel 1462). Hinweis: Die Adressen für die
Speicherzellen sind erfunden und dienen lediglich der besseren Illustration.

In Zeile 5 wird die Zeigervariable `a` definiert und eine Variable `b` vom Typ
`int`.

Nach der Definition hat die Zeigervariable a einen nicht definierten Inhalt. Die
Anweisung `a=&b` in Zeile 8 weist `a` deshalb eine neue Adresse zu. Damit zeigt
die Variable a nun auf die Variable `b`. Die `printf`-Anweisung gibt den Wert
der Variable aus, auf die der Zeiger verweist. Da ihr die Adresse von `b`
zugewiesen wurde, wird die Zahl 17 ausgegeben.

Ob Sie auf den Inhalt der Adresse, auf den die Zeigervariable verweist, oder auf
die Adresse, auf den die Zeigervariable verweist, zugreifen, hängt vom
`*`-Operator (dem Inhalts- oder Dereferenzierungs-Operator) ab: `*a` greift auf
den Inhalt der Zeigervariable zu. Will man aber die Adresse der Zeigervariable
selbst haben, so muss man den `&`-Operator wählen, also `&a`.

Ein Zeiger darf nur auf eine Variable verweisen, die denselben oder einen
kompatiblen Datentyp hat. Ein Zeiger vom Typ `int` kann also nicht auf eine
Variable mit dem Typ `float` verweisen. Den Grund hierfür werden Sie im nächsten
Kapitel kennen lernen. Nur so viel vorab: Der Variablentyp hat nichts mit der
Breite der Adresse zu tun. Diese ist systemabhängig immer gleich. Bei einer 16
Bit CPU ist die Adresse 2 Byte, bei einer 32 Bit CPU 4 Byte und bei einer 64 Bit
CPU 8 Byte breit - unabhängig davon, ob die Zeigervariable als `char`, `int`,
`float` oder `double` deklariert wurde.

### Zeigerarithmetik

Es ist möglich, Zeiger zu erhöhen und damit einen anderen Speicherbereich
anzusprechen, z. B.:

``` c
#include <stdio.h>

int main()
{
  int x = 5;
  int * i = &x;
  printf("Speicheradresse %p enthält %i\n", (void * )i, * i);
  i++; // nächste Adresse lesen, äquivalent zu: i = (void * )i + sizeof(* i);
  printf("Speicheradresse %p enthält %i\n", (void * )i, * i);  
  return 0;
}
```
@run

`i++` erhöht hier nicht den Inhalt (`*i`), sondern die Adresse des Zeigers
(`i`). Man sieht aufgrund der Ausgabe auch leicht, wie groß ein `int` auf dem
System ist, auf dem das Programm kompiliert wurde. Im folgenden handelt es sich
um ein 32-bit-System (Differenz der beiden Speicheradressen 4 Byte = 32 Bit):

```
Speicheradresse 134524936 enthält 5
Speicheradresse 134524940 enthält 0
```

Um nun den Wert im Speicher, nicht den Zeiger, zu erhöhen, wird `*i++` nichts
nützen. Das ist so, weil der Dereferenzierungsoperator `*` die niedrigere
Priorität hat als das Postinkrement (`i++`). Um den beabsichtigten Effekt zu
erzielen, schreibt man `(*i)++`, oder auch `++*i`. Im Zweifelsfall und auch um
die Les- und Wartbarkeit zu erhöhen sind Klammern eine gute Wahl.

### Zeiger auf Funktionen

Zeiger können nicht nur auf Variablen, sondern auch auf Funktionen verweisen, da
Funktionen nichts anderes als Code im Speicher sind. Ein Zeiger auf eine
Funktion erhält also die Adresse des Codes.

Mit dem folgenden Ausdruck wird ein Zeiger auf eine Funktion definiert:

``` c
 int (* f)(float);
```

Diese Schreibweise erscheint zunächst etwas ungewöhnlich. Bei genauem Hinsehen
gibt es aber nur einen Unterschied zwischen einer normalen Funktionsdefinition
und der Zeigerschreibweise: Anstelle des Namens der Funktion tritt der Zeiger.
Der Variablentyp `int` ist der Rückgabetyp und `float` der an die Funktion
übergebene Parameter. Die Klammer um den Zeiger darf nicht entfernt werden, da
der Klammeroperator `()` eine höhere Priorität als der Dereferenzierungsoperator `*`
hat.

Wie bei einer Zeigervariable kann ein Zeiger auf eine Funktion nur eine Adresse
aufnehmen. Wir müssen dem Zeiger also noch eine Adresse zuweisen:

``` c
 int (* f)(float);
 int func(float);
 f = func;
```

Diese Schreibweise `f = func` ist gleich mit `f = &func`, da die Adresse der
Funktion im Funktionsnamen steht. Der Lesbarkeit halber sollte man im
Allgemeinen nicht auf den Adressoperator `&` verzichten.

Die Funktion können wir über den Zeiger nun wie gewohnt aufrufen:

``` c
 (* f)(35.925);
```

oder

``` c
 f(35.925);
```

Hier ein vollständiges Beispielprogramm:

``` c
#include <stdio.h>

int zfunc()
{
    printf("zfunc ausgeführt!\n");
    return 0;
}

int main()
{
    int (*f)();

    f = &zfunc;

    printf("Rufe f, den pointer auf zfunc, auf:\n");
    f();

    return 0;
}
```
@run


### `void`-Zeiger

Der `void *`-Zeiger ist zu jedem anderen Daten-Zeiger kompatibel (Achtung,
anders als in C++), d.h. in C Programmen wird kein Cast in den Ziel-Zeigertyp
benötigt, in C++ ist er zwingend. Man spricht hierbei auch von einem
untypisierten oder generischen Zeiger. Das geht so weit, dass man einen `void`
Zeiger in jeden anderen Zeiger umwandeln kann, und zurück, ohne dass die
Repräsentation des Zeigers Eigenschaften verliert. Ein solcher Zeiger wird
beispielsweise bei der Bibliotheksfunktion `malloc` benutzt. Diese Funktion wird
verwendet um eine bestimmte Menge an Speicher bereitzustellen, zurückgegeben
wird die Anfangsadresse des allozierten Bereichs. Danach kann der Programmierer
Daten beliebigen Typs dorthin schreiben und lesen. Daher ist Pointer-Typisierung
irrelevant. Der Prototyp von `malloc` ist also folgender:

``` c
 void *malloc(size_t size);

 int *ptrint = malloc(100); // der Cast in  " ptrint = (int *) malloc(100); "  ist NICHT notwendig
```

Der Rückgabetyp `void *` ist hier notwendig, da ja nicht bekannt ist, welcher
Zeigertyp (`char*`, `int*` usw.) zurückgegeben werden soll.

Der einzige Unterschied zu einem typisierten ("normalen") Zeiger ist, dass die
Zeigerarithmetik schwer zu bewältigen ist, da dem Compiler der
Speicherplatzverbrauch pro Variable nicht bekannt ist (wir werden darauf im
nächsten Kapitel noch zu sprechen kommen) und man sich in diesem Fall selber
darum kümmern muss, dass der `void *`-Pointer auf der richtigen Adresse zum
Liegen kommt. Zum Beispiel mit Hilfe des `sizeof`-Operators.

``` c
 int *intP;
 void *voidP;
 voidP = intP;         /* beide zeigen jetzt auf das gleiche Element */
 intP++;               /* zeigt nun auf das nächste Element */
 voidP += sizeof(int); /* Fehler! nicht standardkonform, void* Zeiger ermöglichen keine Arithmetik */
```

### Call by Value

Eine Funktion dient dazu, eine bestimmte Aufgabe zu erfüllen. Dazu können ihr
Variablen übergeben werden oder sie kann einen Wert zurückgeben. Der Compiler
übergibt diese Variable aber nicht direkt der Funktion, sondern fertigt eine
Kopie davon an. Diese Art der Übergabe von Variablen wird als Call by Value
bezeichnet.

Da nur eine Kopie angefertigt wird, gelten die übergebenen Werte nur innerhalb
der Funktion selbst. Sobald die Funktion wieder verlassen wird, gehen alle diese
Werte verloren. Das folgende Beispiel verdeutlicht dies:

``` c
#include <stdio.h>

void func(int wert)
{
  wert += 5;
  printf("%i\n", wert);
}

int main()
{
  int zahl = 10;
  printf("%i\n", zahl);
  func(zahl);
  printf("%i\n", zahl);
  return 0;
}
```
@run

Das Programm erzeugt nach der Kompilierung die folgende Ausgabe auf dem
Bildschirm:

```
10
15
10
```

Dies kommt dadurch zustande, dass die Funktion `func` nur eine Kopie der
Variable wert erhält. Zu dieser Kopie addiert dann die Funktion `func` die Zahl
5. Nach dem Verlassen der Funktion geht der Inhalt der Variable wert verloren.
Die letzte `printf` Anweisung in `main` gibt deshalb wieder die Zahl 10 aus.

Eine Lösung wurde bereits im Kapitel Funktionen angesprochen: Die Rückgabe über
die Anweisung `return` . Diese hat allerdings den Nachteil, dass jeweils nur ein
Wert zurückgegeben werden kann.

Ein gutes Beispiel dafür ist die `swap()` Funktion. Sie soll dazu dienen, zwei
Variablen zu vertauschen. Die Funktion müsste in etwa folgendermaßen aussehen:

``` c
 void swap(int x, int y)
 {
   int tmp;
   tmp = x;
   x = y;
   y = tmp;
 }
```

Die Funktion ist zwar prinzipiell richtig, kann aber das Ergebnis nicht an die
Hauptfunktion zurückgeben, da swap nur mit Kopien der Variablen `x` und `y`
arbeitet.

Das Problem lässt sich lösen, indem nicht die Variable direkt, sondern - Sie
ahnen es sicher schon - ein Zeiger auf die Variable der Funktion übergeben wird.
Das richtige Programm sieht dann folgendermaßen aus:

``` c
#include <stdio.h>

void swap(int *x, int *y)
{
  int tmp;
  tmp = * x;
  * x = * y;
  * y = tmp;
}

int main()
{
  int x = 2, y = 5;
  printf("Variable x: %i, Variable y: %i\n", x, y);
  swap(&x, &y);
  printf("Variable x: %i, Variable y: %i\n", x, y);
  return 0;
}
```
@run

In diesem Fall ist das Ergebnis richtig:

```
Variable x: 2, Variable y: 5
Variable x: 5, Variable y: 2
```

Das Programm ist nun richtig, da die Funktion `swap` nun nicht mit den Kopien
der Variable x und y arbeitet, sondern mit den Originalen. In vielen Büchern
wird ein solcher Aufruf auch als Call By Reference bezeichnet. Diese Bezeichnung
ist aber nicht unproblematisch. Tatsächlich liegt auch hier ein Call By Value
vor, allerdings wird nicht der Wert der Variablen sondern deren Adresse
übergeben. C++ und auch einige andere Sprachen unterstützen ein echtes Call By
Reference, C hingegen nicht.

### Verwendung

Sie stellen sich nun möglicherweise die Frage, welchen Nutzen man aus Zeigern
zieht. Es macht den Anschein, dass wir, abgesehen vom Aufruf einer Funktion mit
Call by Reference, bisher ganz gut ohne Zeiger auskamen. Andere
Programmiersprachen scheinen sogar ganz auf Zeiger verzichten zu können. Dies
ist aber ein Trugschluss: Häufig sind Zeiger nur gut versteckt, so dass nicht
auf den ersten Blick erkennbar ist, dass sie verwendet werden. Beispielsweise
arbeitet der Rechner bei Zeichenketten intern mit Zeigern, wie wir noch sehen
werden. Auch das Kopieren, Durchsuchen oder Verändern von Datenfeldern ist ohne
Zeiger nicht möglich. Bei typsicheren Programmiersprachen gibt es i.d.R. keine
Zeiger, die nach belieben benutzt werden können.

Es gibt Anwendungsgebiete, die ohne Zeiger überhaupt nicht auskommen: Ein
Beispiel hierfür sind Datenstrukturen wie beispielsweise verkettete Listen, die
wir später noch kurz kennen lernen. Bei verketteten Listen werden die Daten in
einem sogenannten Knoten gespeichert. Diese Knoten sind untereinander jeweils
mit Zeigern verbunden. Dies hat den Vorteil, dass die Anzahl der Knoten und
damit die Anzahl der zu speichernden Elemente dynamisch wachsen kann. Soll ein
neues Element in die Liste eingefügt werden, so wird einfach ein neuer Knoten
erzeugt und durch einen Zeiger mit der restlichen verketteten Liste verbunden.
Es wäre zwar möglich, auch für verkettete Listen eine zeigerlose Variante zu
implementieren, dadurch würde aber viel an Flexibilität verloren gehen. Auch bei
vielen anderen Datenstrukturen und Algorithmen kommt man ohne Zeiger nicht aus.
Einige Algorithmen lassen sich darüber hinaus mithilfe von Zeigern auch
effizienter implementieren, so dass deren Ausführungszeit schneller als die
Implementierung des selben Algorithmus ohne Zeiger ist.

Bei Zeigern können Fehler passieren, z.B.:

``` c
#include <stdio.h>

int main()
{
	int start_value = 0;
	int * pointa = &start_value;
	for (int i = 0; i < 5; ++i) {
		printf("pointa points to %p with the value %d\n", pointa, * pointa);
		int new_value = 1;
		new_value += * pointa;
		pointa = &new_value;
	}
	return 0;
}
```
@run

Bei diesem Programm zeigt ein Pointer auf eine Variable, die aus dem
Gültigkeitsbereich fällt. Der Wert, auf den der Pointer zeigt, ist dann nicht
definiert. Wenn das Programm mit gcc ohne Optimierung übersetzt wurde, sieht die
Ausgabe beispielsweise so aus:

```
pointa points to 0x7fffdfe01d44 with the value 0
pointa points to 0x7fffdfe01d48 with the value 1
pointa points to 0x7fffdfe01d48 with the value 2
pointa points to 0x7fffdfe01d48 with the value 2
pointa points to 0x7fffdfe01d48 with the value 2
```

Die Adresse ist unterschiedlich bei erneuter Programmausführung.

Wenn das Programm für Debugging-Optimierung übersetzt wurde (`-Og` Parameter),
steht beim Wert statt 2 eine 1.

Wenn das Programm mit einer anderen Optimierung übersetzt wurde, ist auch der
Wert (abgesehen vom Startwert) bei erneuter Programmausführung unterschiedlich,
Bsp:

```
pointa points to 0x7ffd880e3c60 with the value 0
pointa points to 0x7ffd880e3c64 with the value 21848
pointa points to 0x7ffd880e3c64 with the value 21848
pointa points to 0x7ffd880e3c64 with the value 21848
pointa points to 0x7ffd880e3c64 with the value 21848
```


## Arrays

### Eindimensionale Arrays

Nehmen Sie einmal rein fiktiv an, Sie wollten ein Programm für Ihre kleine Firma
schreiben, das die Summe sowie den höchsten und den niedrigsten aller Umsätze
einer Woche ermittelt. Es wäre natürlich sehr ungeschickt, wenn Sie die Variable
umsatz1 bis umsatz7 deklarieren müssten. Noch umständlicher wäre die Addition
der Werte und das Ermitteln des höchsten bzw. niedrigsten Umsatzes.

Für die Lösung des Problems werden stattdessen Arrays (auch als Felder oder
Vektoren bezeichnet) benutzt. Arrays unterscheiden sich von normalen Variablen
lediglich darin, dass sie einen Index besitzen. Statt umsatz1 bis umsatz7 zu
deklarieren, reicht eine einmalige Deklaration aus:

``` c
float umsatz[7];
```

Visuelle Darstellung:

```
Index: | [0] | [1] | [2] | [3] | [4] | [5] | [6] | ...
Werte: | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | ...
```

Damit deklarieren Sie in einem Rutsch die Variablen `umsatz[0]` bis `umsatz[6]`.
Beachten Sie unbedingt, dass auf ein Array immer mit dem Index 0 beginnend
zugegriffen wird! Beispielsweise wird der fünfte Wert mit dem Index 4
(`umsatz[4]`) angesprochen! Dies wird nicht nur von Anfängern gerne vergessen und
führt auch bei erfahreneren Programmierern häufig zu „Um-eins-daneben-Fehlern“.

Die Addition der Werte erfolgt in einer Schleife. Der Index muss dafür in jedem
Durchlauf erhöht werden. In dieser Schleife testen wir gleichzeitig jeweils beim
Durchlauf, ob wir einen niedrigeren oder einen höheren Umsatz als den bisherigen
Umsatz haben:

``` c
#include <stdio.h>

int main( void )
{
    float umsatz[7];
    float summe, hoechsterWert, niedrigsterWert;
    int i;

    for( i = 0; i < 7; i++ )
    {
        printf( "Bitte die Umsaetze der letzten Woche eingeben: \n" );
        scanf( "%f", &umsatz[i] );
    }

    summe = 0;
    hoechsterWert = umsatz[0];
    niedrigsterWert = umsatz[0];

    for( i = 0; i < 7; i++ )
    {
        summe += umsatz[ i ];
        if( hoechsterWert < umsatz[i] )
            hoechsterWert = umsatz[i];
        //
        if( niedrigsterWert > umsatz[i] )
            niedrigsterWert = umsatz[i];
    }

    printf( "Gesamter Wochengewinn: %f \n", summe );
    printf( "Hoechster Umsatz: %f \n", hoechsterWert );
    printf( "Niedrigster Umsatz: %f \n", niedrigsterWert );
    return 0;
}
```
``` bash stdin
10
11
33
123
123
12
12
```
@run_stdin

ACHTUNG: Bei einer Zuweisung von Arrays wird nicht geprüft, ob eine
Feldüberschreitung vorliegt. So führt beispielsweise

``` c
  umsatz[10] = 5.0;
```

nicht zu einer Fehlermeldung, obwohl das Array nur 7 Elemente besitzt. Der
Compiler gibt weder eine Fehlermeldung noch eine Warnung aus! Der Programmierer
ist selbst dafür verantwortlich, dass die Grenzen des Arrays nicht überschritten
werden. Ein Zugriff auf ein nicht vorhandenes Arrayelement kann zum Absturz des
Programms oder anderen unvorhergesehenen Ereignissen führen! Des Weiteren kann
dies ein sehr hohes Sicherheitsrisiko darstellen. Denn ein Angreifer kann dann
über das Array eigene Befehle in den Arbeitsspeicher schreiben und vom Programm
ausführen lassen. (Siehe  Bufferoverflow)

### Mehrdimensionale Arrays

Ein Array kann auch aus mehreren Dimensionen bestehen. Das heißt, es wird wie
eine Matrix dargestellt. Im Folgenden wird beispielsweise ein Array mit zwei
Dimensionen definiert:

<!-- style="max-height: 400px" -->
````
  _____
 |     |
 |  8  |   [1][3]
 |_____|
 |     |
 |  7  |   [1][2]
 |_____|
 |     |
 |  6  |   [1][1]
 |_____|
 |     |
 |  5  |   [1][0]
 |_____|
 |     |
 |  4  |   [0][3]
 |_____|
 |     |
 |  3  |   [0][2]
 |_____|
 |     |
 |  2  |   [0][1]
 |_____|
 |     |
 |  1  |   [0][0]
 |_____|

````

````
int vararray[6][5]

Visuelle Darstellung:
   ___________________________________________   _____________
  /        /        /        /        /      /  /  /         /|
 /--------/--------/--------/--------/-------\  \-/-------- / |
| [0][0] | [0][1] | [0][2] | [0][3] | [0][4] /  / |        | /|
|--------|--------|--------|--------|--------\  \-|--------|/ |
| [1][0] | [1][1] | [1][2] | [1][3] | [1][4] /  / |        | /|
|--------|--------|--------|--------|--------\  \-|--------|/ |
| [2][0] | [2][1] | [2][2] | [2][3] | [2][4] /  / |        | /|
|--------|--------|--------|--------|--------\  \-|--------|/ |
| [3][0] | [3][1] | [3][2] | [3][3] | [3][4] /  / |        | /|
|--------|--------|--------|--------|--------\  \-|--------|/ |
| [4][0] | [4][1] | [4][2] | [4][3] | [4][4] /  / |        | /|
|--------|--------|--------|--------|--------\  \-|--------|/ |
| [5][0] | [5][1] | [5][2] | [5][3] | [5][4] /  / |        | /|
|--------|--------|--------|--------|--------\  \-|--------|/ |
|   __   |__    __|   __   |__    __|   __   /  / | __    _| /
\__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/ |//|
    __    __    __    __    __    __    __    __    __    _ / |
|__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/ | /|
|--------|--------|--------|--------|-------------|--------|/ |
|        |        |        |        |                      | /|
|--------|--------|--------|--------|-------------|--------|/ |
|        |        |        |        |                      | /
|--------|--------|--------|--------|-------------|--------|/
````

Wie aus der Abbildung 1 ersichtlich, entspricht das mehrdimensionale Array im
Speicher im Prinzip einem eindimensionalen Array. Dies muss nicht verwundern, da
der Speicher ja selbst eindimensional aufgebaut ist.

Ein mehrdimensionales Array wird aber dennoch häufig verwendet, etwa wenn es
darum geht, eine Tabelle, Matrix oder Raumkoordinaten zu speichern.

#### Mehrdimensionales Array genauer betrachtet

````

int Ary[2][3][3][5];                               4D
                                           ----------------->
 _________________________________________________    ________________________________________________
|4D-erste                                         |  |4D-zweite                                       |
|                                                 |  |                                                |
|    ____________________________________________ |  |  ____________________________________________  |
| 3D|3D-erste              1D                    ||  | |3D-erste             1D                     | |
|  ||                  --------->                ||  | |                  --------->                | |
|  ||    ______________________________________  ||  | |    ______________________________________  | |
|  || 2D|      ||      ||      ||      ||      | ||  | | 2D|      ||      ||      ||      ||      | | |
|  ||  ||2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | ||  | |  ||2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | | |
|  ||  ||______||______||______||______||______| ||  | |  ||______||______||______||______||______| | |
|  ||  | ______________________________________  ||  | |  | ______________________________________  | |
|  ||  V|      ||      ||      ||      ||      | ||  | |  V|      ||      ||      ||      ||      | | |
|  ||   |2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | ||  | |   |2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | | |
|  ||   |______||______||______||______||______| ||  | |   |______||______||______||______||______| | |
|  ||    ______________________________________  ||  | |    ______________________________________  | |
|  ||   |      ||      ||      ||      ||      | ||  | |   |      ||      ||      ||      ||      | | |
|  ||   |2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | ||  | |   |2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | | |
|  ||   |______||______||______||______||______| ||  | |   |______||______||______||______||______| | |
|  ||____________________________________________||  | |____________________________________________| |
|  | ____________________________________________ |  |  ____________________________________________  |
|  ||3D-zweite             1D                    ||  | |3D-zweite            1D                     | |
|  ||                  --------->                ||  | |                  --------->                | |
|  ||    ______________________________________  ||  | |    ______________________________________  | |
|  || 2D|      ||      ||      ||      ||      | ||  | | 2D|      ||      ||      ||      ||      | | |
|  ||  ||2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | ||  | |  ||2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | | |
|  ||  ||______||______||______||______||______| ||  | |  ||______||______||______||______||______| | |
|  ||  | ______________________________________  ||  | |  | ______________________________________  | |
|  V|  V|      ||      ||      ||      ||      | ||  | |  V|      ||      ||      ||      ||      | | |
|   |   |2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | ||  | |   |2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | | |
|   |   |______||______||______||______||______| ||  | |   |______||______||______||______||______| | |
|   |    ______________________________________  ||  | |    ______________________________________  | |
|   |   |      ||      ||      ||      ||      | ||  | |   |      ||      ||      ||      ||      | | |
|   |   |2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | ||  | |   |2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | | |
|   |   |______||______||______||______||______| ||  | |   |______||______||______||______||______| | |
|   |____________________________________________||  | |____________________________________________| |
|    ____________________________________________ |  |  ____________________________________________  |
|   |3D-dritte            1D                     ||  | |3D-dritte             1D                    | |
|   |                  --------->                ||  | |                  --------->                | |
|   |    ______________________________________  ||  | |    ______________________________________  | |
|   | 2D|      ||      ||      ||      ||      | ||  | | 2D|      ||      ||      ||      ||      | | |
|   |  ||2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | ||  | |  ||2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | | |  
|   |  ||______||______||______||______||______| ||  | |  ||______||______||______||______||______| | |
|   |  | ______________________________________  ||  | |  | ______________________________________  | |
|   |  V|      ||      ||      ||      ||      | ||  | |  V|      ||      ||      ||      ||      | | |
|   |   |2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | ||  | |   |2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | | |   
|   |   |______||______||______||______||______| ||  | |   |______||______||______||______||______| | |
|   |    ______________________________________  ||  | |    ______________________________________  | |
|   |   |      ||      ||      ||      ||      | ||  | |   |      ||      ||      ||      ||      | | |
|   |   |2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | ||  | |   |2D|1D ||2D|1D ||2D|1D ||2D|1D ||2D|1D | | |   
|   |   |______||______||______||______||______| ||  | |   |______||______||______||______||______| | |
|   |____________________________________________||  | |____________________________________________| |
|_________________________________________________|  |________________________________________________|   

````

Der erste Index des Arrays steht für die vierte Dimension, der zweite Index für
die dritte Dimension, der dritte Index für die zweite Dimension und der letzte
Index für die erste Dimension. Dies soll veranschaulichen, wie man sich ein
mehrdimensionales Array vorstellen muss.

#### Veranschaulichung

Weil die Vorstellung von Objekten als mehrdimensionale Arrays abseits von 3
Dimensionen (Würfel) schwierig ist, sollte man sich Arrays lieber als doppelte
Fortschrittsbalken (wie bei einem Brennprogramm oft üblich) oder als Maßeinheit
(z. B. Längenangaben) vorstellen. Um es an einem dieser genannten Beispiele zu
veranschaulichen:

Man stellt sich einen Millimeter als erstes Array-Element (Feld) vor.

```
1 Feld = 1 mm

int Array[10];
#10 mm = 1 cm
#Array[Eine-Dimension (10 Felder)] = 1 cm
```

Natürlich könnte man mehr Felder für die erste Dimension verwenden, doch sollte
man es zu Gunsten der Übersichtlichkeit nicht übertreiben.

```
int Array[10][10];
#10 mm x 10 = 1 dm
#Array[Zwei Dimensionen (Zehn Zeilen (eine Zeile mit je 10 Feldern)] = 1 dm
```

Die Anzahl der weiteren Feldblöcke (oder der gesamten Felder) wird durch die
angegebene Zeilenanzahl bestimmt.

```
int Array[10][10][10]
#10 mm x 10 x 10 = 1 m
#Array[Drei-Dimensionen (Zehn mal _2D-Blöcke_ (die mit je 10 Feld-Blöcken, die wiederum mit je 10 Feldern)) ] = 1 m
```

Insgesamt enthält dieses Array somit 1000 Felder, in denen man genau so viele
Werte speichern könnte wie Felder vorhanden. Die Dimensionen verlaufen von der
kleinsten (1D) außen rechts zur größten (hier 3D) nach außen links.

Ab der dritten Dimension folgt es immer dem gleichem Muster.


Hier noch ein Beispielprogramm zum Verständnis:

``` c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define WARY1  10
#define WARY2  10
#define WARY3  10

int main( void )
{
    srand( time( 0 ) );

    int a, b, c;
    int ZAry[WARY1][WARY2][WARY3];
    //
    for( a = 0; a < WARY1; ++a )
    {
        for( b = 0; b < WARY2; ++b )
        {
            for( c = 0; c < WARY3; ++c )
            {
                ZAry[a][b][c] = rand( );
            }
        }
    }
    //
    for( a = 0; a < WARY1; ++a )
    {
        for( b = 0; b < WARY2; ++b )
        {
            for( c = 0; c < WARY3; ++c )
            {
                printf( "Inhalt von Z-Ary[%d][%d][%d] ", a, b, c );
                printf( "ist: %d \n", ZAry[a][b][c] );
            }
            printf( "Weiter mit Eingabetaste && Verlassen mit STRG-C. \n" );
            getchar( );
        }
    }
    //
    return 0;
}
```
``` bash stdin





```
@run_stdin

### Arrays initialisieren

Es gibt zwei Schreibstile für die Initialisierung eines Arrays. Entweder die
Werte gruppiert untereinander schreiben:

``` c
int Ary[2][4] = {
                    {1, 2, 3, 4},
                    {5, 6, 7, 8},
                };
```

oder alles hintereinander schreiben:

``` c
int Ary[2][4] = { 1, 2, 3, 4, 5, 6, 7, 8 };
```

Grundsätzlich ist es ratsam, ein Array immer zu initialisieren, damit man beim
späterem Ausführen des Programms nicht durch unerwartete Ergebnisse überrascht
wird. Denn ohne eine Initialisierung weiß man nie, welchen Wert die einzelnen
Array-Elemente beinhalten.


Beispiel für eine Initialisierung mit 0:

``` c
int a[5] = { 0 };  /* alle 5 Array-Elemente besitzen den Wert 0 */
```

Für `char`-Arrays gibt es eine zusätzliche Initialisierungsmöglichkeit mit einem
Stringliteral:

``` c
char a[5] = "";  /* alle 5 Array-Elemente besitzen den Wert 0 */
```

Werden bei der Initialisierung eines Arrays weniger Werte als vorhandene
Elemente angegeben, werden alle endenden Elemente automatisch mit 0 vorbelegt.

``` c
int  a[5] = { 1, 2 };  /* a[0]=1, a[1]=2, a[2]=0, a[3]=0, a[4]=0 */
char a[5] = "ab";      /* a[0]='a', a[1]='b', a[2]='\0', a[3]='\0', a[4]='\0' */
```

Dieses Verfahren empfiehlt sich insbesondere bei großen Arrays, denn viele
hundert Einzelwerte anzugeben ist sehr unübersichtlich und fehlerträchtig.

Sind Array global oder mittels Speicherklasse `static` definiert, sind automatisch
alle Elemente mit 0 vorbelegt, auch ohne Angabe von Initialisierungswerten
(`{0}`). Es empfiehlt sich wegen der Lesbarkeit des Codes aber trotzdem, hier
die 0-Werte anzugeben. Identische Definitionen eines Arrays:

``` c
static int a[5];
static int a[5] = { 0 };
static int a[5] = { 0, 0 };
static int a[5] = { 0, 0, 0, 0, 0 };
```

### Syntax der Initialisierung

Es gibt zwei Möglichkeiten, ein Array zu initialisieren: entweder eine teilweise
oder eine vollständige Initialisierung. Bei einer Initialisierung steht ein
Zuweisungsoperator nach dem deklarierten Array, gefolgt von einer in
geschweiften Klammern stehenden Liste von Werten, die durch Kommata getrennt
werden. Diese Liste wird der Reihenfolge nach ab dem Index 0 den Array-Elementen
zugewiesen.

### Eindimensionales Array vollständig initialisiert

```
int Ary[5] = { 10, 20, 30, 40, 50 };

Index  | Inhalt
----------------
Ary[0] = 10
Ary[1] = 20
Ary[2] = 30
Ary[3] = 40
Ary[4] = 50
```

**Fehlende Größenangabe bei vollständig initialisierten eindimensionalen Arrays**

Wenn die Größe eines vollständig initialisierten eindimensionalen Arrays nicht
angegeben wurde, erzeugt der Compiler ein Array, das gerade groß genug ist, um
die Werte aus der Initialisierung aufzunehmen. Deshalb ist:

``` c
int Ary[5] = { 10, 20, 30, 40, 50 };
```

das gleiche wie:

``` c
int Ary[ ] = { 10, 20, 30, 40, 50 };
```

Ob man die Größe angibt oder weglässt ist jedem selbst überlassen, jedoch ist es
zu empfehlen, sie anzugeben.


### Eindimensionales Array teilweise initialisiert

``` c
int Ary[5] = { 10, 20, 30 };

Index  | Inhalt
----------------
Ary[0] = 10
Ary[1] = 20
Ary[2] = 30
Ary[3] = 0
Ary[4] = 0
```

Wie man in diesem Beispiel deutlich erkennt, werden nur die ersten drei
Array-Elemente mit den Indizes 0, 1 und 2 initialisiert. Die beiden letzten
Array-Elemente mit den Indizes 3 und 4 sind hingegen leer geblieben. Diese
werden bei solchen nur teilweise initialisierten Arrays vom Compiler mit dem
Wert 0 gefüllt, um den Speicherplatz zu reservieren.


**Fehlende Größenangabe bei teilweise initialisierten eindimensionalen Arrays**

Bei einem teilweise initialisierten eindimensionalen Array führt eine fehlende
Größenangabe dazu, dass die Größe des Arrays womöglich nicht ausreichend ist,
weil nur so viele Array-Elemente vom Compiler erstellt werden, um die Werte aus
der Liste aufzunehmen. Deshalb sollte man immer die Größe angeben!

### Mehrdimensionales Array vollständig initialisiert

``` c
int Ary[4][5] = {
		    { 10, 11, 12, 13, 14 },
		    { 24, 25, 26, 27, 28 },
		    { 30, 31, 32, 33, 34 },
		    { 44, 45, 46, 47, 48 },
		}

Visuelle Darstellung:
---------------------
Index	  | Inhalt
--------------------
Ary[0][0] = 10
Ary[0][1] = 11
Ary[0][2] = 12
Ary[0][3] = 13
Ary[0][4] = 14

Ary[1][0] = 24
Ary[1][1] = 25
Ary[1][2] = 26
Ary[1][3] = 27
Ary[1][4] = 28

Ary[2][0] = 30
Ary[2][1] = 31
Ary[2][2] = 32
Ary[2][3] = 33
Ary[2][4] = 34

Ary[3][0] = 44
Ary[3][1] = 45
Ary[3][2] = 46
Ary[3][3] = 47
Ary[3][4] = 48
```

**Fehlende Größenangabe bei vollständig initialisierten mehrdimensionalen Arrays**

Bei vollständig initalisierten mehrdimensionalen Array sieht es mit dem
Weglassen der Größenangabe etwas anders aus als bei vollständig initialisierten
eindimensionalen Arrays. Denn wenn ein Array mehr als eine Dimension besitzt,
darf man nicht alle Größenangaben weg lassen. Grundsätzlich sollte man nie auf
die Größenangaben verzichten. Notfalls ist es gestattet, die erste (und nur
diese) weg zu lassen. Mit „erste“ ist immer die linke gemeint, die direkt an den
Array Variablennamen angrenzt.


Wenn also eine Größenangabe (die erste) des Arrays nicht angegeben wurde,
erzeugt der Compiler ein Array das gerade groß genug ist, um die Werte aus der
Initialisierung aufzunehmen. Deshalb ist:

``` c
int Ary[4][5] = {
		    { 10, 11, 12, 13, 14 },
		    { 24, 25, 26, 27, 28 },
		    { 30, 31, 32, 33, 34 },
		    { 44, 45, 46, 47, 48 },
		};
```

das gleiche wie:

``` c
int Ary[ ][5] = {
		    { 10, 11, 12, 13, 14 },
		    { 24, 25, 26, 27, 28 },
		    { 30, 31, 32, 33, 34 },
		    { 44, 45, 46, 47, 48 },
		};
```

Ob man die Größe angibt oder weglässt ist jedem selbst überlassen, jedoch ist es
zu empfehlen, sie anzugeben.


Falsch hingegen wären:

``` c
int Ary[5][ ] = {
		    { 10, 11, 12, 13, 14 },
		    { 24, 25, 26, 27, 28 },
		    { 30, 31, 32, 33, 34 },
		    { 44, 45, 46, 47, 48 },
		};
```

oder:

``` c
int Ary[ ][ ] = {
		    { 10, 11, 12, 13, 14 },
		    { 24, 25, 26, 27, 28 },
		    { 30, 31, 32, 33, 34 },
		    { 44, 45, 46, 47, 48 },
		};
```

genau wie:

``` c
int Ary[ ][4][ ] = {
		    { 10, 11, 12, 13, 14 },
		    { 24, 25, 26, 27, 28 },
		    { 30, 31, 32, 33, 34 },
		    { 44, 45, 46, 47, 48 },
		};
```

und:

``` c
int Ary[ ][ ][5] = {
		    { 10, 11, 12, 13, 14 },
		    { 24, 25, 26, 27, 28 },
		    { 30, 31, 32, 33, 34 },
		    { 44, 45, 46, 47, 48 },
		};
```

### Mehrdimensionales Array teilweise initialisiert

``` c
int Ary[4][5] = {
		    { 10, 11, 12, 13, 14 },
		    { 24, 25, 26, 27, 28 },
		    { 30, 31, 32 },
		}

Index	  | Inhalt
--------------------
Ary[0][0] = 10
Ary[0][1] = 11
Ary[0][2] = 12
Ary[0][3] = 13
Ary[0][4] = 14

Ary[1][0] = 24
Ary[1][1] = 25
Ary[1][2] = 26
Ary[1][3] = 27
Ary[1][4] = 28

Ary[2][0] = 30
Ary[2][1] = 31
Ary[2][2] = 32
Ary[2][3] = 0
Ary[2][4] = 0

Ary[3][0] = 0
Ary[3][1] = 0
Ary[3][2] = 0
Ary[3][3] = 0
Ary[3][4] = 0
```

Das teilweise Initalisieren eines mehrdimensionalen Arrays folgt genau dem
selben Muster wie auch schon beim teilweise initalisierten eindimensionalen
Array. Hier werden auch nur die ersten 13 Felder mit dem Index `[0|0]` bis
`[2|2]` gefüllt. Die restlichen werden vom Compiler mit 0 gefüllt.

Es ist wichtig nicht zu vergessen, dass die Werte aus der Liste den
Array-Elementen ab dem Index Nummer Null übergeben werden und nicht erst ab dem
Index Nummer Eins! Außerdem kann man auch keine Felder überspringen, um den
ersten Wert aus der Liste beispielsweise erst dem fünften oder siebten
Array-Element zu übergeben!

**Fehlende Größenangabe bei teilweise initialisierten Mehrdimensionalen Arrays**

Die Verwendung von teilweise initialisierte mehrdimensionale Arrays mit
fehlender Größenangabe macht genauso wenig Sinn wie auch bei teilweise
initialiserten Eindimensionalen Array. Denn eine fehlende Größenangabe führt in
solch einem Fall dazu, dass die Größe des Arrays womöglich nicht ausreichend
ist, weil nur genug Array-Elemente vom Compiler erstellt wurden um die Werte aus
der Liste auf zu nehmen. Deshalb sollte man bei solchen niemals vergessen die
Größe mit anzugeben.

### Arrays und deren Speicherplatz

Die Elementgröße eines Arrays hängt zum einen vom verwendeten Betriebssystem und
zum anderen vom angegebenen Datentyp ab, mit dem das Array deklariert wurde.

``` c
#include <stdio.h>
#include <stdlib.h>

signed char siAry1[200];
signed short siAry2[200];
signed int siAry3[200];
signed long int siAry4[200];
signed long long int siAry5[200];

unsigned char unAry1[200];
unsigned short unAry2[200];
unsigned int unAry3[200];
unsigned long int unAry4[200];
unsigned long long int unAry5[200];

float Ary6[200];
double Ary7[200];
long double Ary8[200];


int main( void )
{
    printf( "Datentyp des Elements | Byte (Elementgröße) \n" );
    printf( "Signed: \n" );
    printf( "signed char        =    %d Byte \n", sizeof(signed char) );
    printf( "signed short        =    %d Byte \n", sizeof(signed short) );
    printf( "signed int        =    %d Byte \n", sizeof(signed int) );
    printf( "signed long int        =    %d Byte \n", sizeof(signed long int) );
    printf( "signed long long int    =    %d Byte \n\n", sizeof(signed long long int) );
    //
    printf( "Unsigned: \n" );
    printf( "unsigned char        =    %d Byte \n", sizeof(unsigned char) );
    printf( "unsigned short        =    %d Byte \n", sizeof(unsigned short) );
    printf( "unsigned int        =    %d Byte \n", sizeof(unsigned int) );
    printf( "unsigned long int    =    %d Byte \n", sizeof(unsigned long int) );
    printf( "unsigned long long int    =    %d Byte \n\n", sizeof(unsigned long long int) );
    //
    printf( "Signed ohne prefix \n" );
    printf( "float            =    %d Byte \n", sizeof(float) );
    printf( "double            =    %d Byte \n", sizeof(double) );
    printf( "long double        =    %d Byte \n\n\n", sizeof(long double) );

    printf( "Groeße, mit verschiedenen Datentyp, eines arrays mit 200Feldern \n" );
    printf( "Signed: \n" );
    printf( "Groeße von siAry als signed char = %d Byte \n", sizeof(siAry1) );
    printf( "Groeße von siAry als signed short = %d Byte \n", sizeof(siAry2) );
    printf( "Groeße von siAry als signed int = %d Byte \n", sizeof(siAry3) );
    printf( "Groeße von siAry als signed long int = %d Byte \n", sizeof(siAry4) );
    printf( "Groeße von siAry als signed long long int = %d Byte \n\n", sizeof(siAry5) );
    //
    printf( "Unsigned: \n" );
    printf( "Groeße von unAry als unsigned char = %d Byte \n", sizeof(unAry1) );
    printf( "Groeße von unAry als unsigned short = %d Byte \n", sizeof(unAry2) );
    printf( "Groeße von unAry als unsigned int = %d Byte \n", sizeof(unAry3) );
    printf( "Groeße von unAry als unsigned long int = %d Byte \n", sizeof(unAry4) );
    printf( "Groeße von unAry als unsigned long long int = %d Byte \n\n", sizeof(unAry5) );
    //
    printf( "Signed ohne prefix \n" );
    printf( "Groeße von Ary als float = %d Byte \n", sizeof(Ary6) );
    printf( "Groeße von Ary als double = %d Byte \n", sizeof(Ary7) );
    printf( "Groeße von Ary als long double = %d Byte \n\n", sizeof(Ary8) );

    return 0;
}
```
@run

Die Speicherplatzgröße eines gesamten Arrays hängt vom verwendeten Datentyp bei
der deklaration und von der Anzahl der Elemente die es beinhaltet ab.


Die maximale Größe eines Array wird nur durch den verfügbaren Speicher
limitiert.

```
Den Array-Speicherpaltz ermitteln:

Array Größe 	 	 =	[ (Anzahl der Elemente) x (Datentyp) ]
----------------------------------------------------------------------------
char Ary[500]            |    [ 500(Elemente) x 1(Typ.Größe) ] =  500 Byte
short Ary[500]           |    [ 500(Elemente) x 2(Typ.Größe) ] = 1000 Byte
int Ary[500]             |    [ 500(Elemente) x 4(Typ.Größe) ] = 2000 Byte
long int Ary[500]        |    [ 500(Elemente) x 4(Typ.Größe) ] = 2000 Byte
long long int Ary[500]   |    [ 500(Elemente) x 8(Typ.Größe) ] = 4000 Byte

float Ary[500]           |    [ 500(Elemente) x 4(Typ.Größe) ] = 2000 Byte
double Ary[500]          |    [ 500(Elemente) x 8(Typ.Größe) ] = 4000 Byte
long double Ary[500]     |    [ 500(Elemente) x 12(Typ.Größe)] = 6000 Byte
____________________________________________________________________________
```

_Anmerkung: Bei einem 64bit System unterscheiden sich die Werte._

### Übergabe eines Arrays an eine Funktion

Bei der Übergabe von Arrays an Funktionen wird nicht wie bei Variablen eine
Kopie übergeben, sondern immer ein Zeiger auf das erste Element des Arrays.

Das folgende Beispielprogramm zeigt die Übergabe eines Arrays an eine Funktion:

``` c
#include <stdio.h>

void function( int feld[ ] )
{
    feld[1] = 10;
    feld[3] = 444555666;
    feld[8] = 25;
}

int main( void )
{
    int feld[9] = { 1, 2, 3, 4, 5, 6 };
    printf( "Der Inhalt des fuenften array Feldes ist: %d \n", feld[4] );
    printf( "Der Inhalt des sechsten array Feldes ist: %d \n\n", feld[5] );

    function( feld );
    printf( "Der Inhalt des ersten array Feldes ist: %d \n", feld[0]);
    printf( "Der Inhalt des zweiten array Feldes ist: %d \n", feld[1] );
    printf( "Der Inhalt des dritten array Feldes ist: %d \n", feld[2]);
    printf( "Der Inhalt des vierte array Feldes ist: %d \n", feld[3]);
    printf( "Der Inhalt des fuenften array Feldes ist: %d \n", feld[4] );
    printf( "Der Inhalt des neunten array Feldes ist: %d \n\n", feld[8] );

    return 0;
}
```
@run

Nach dem Ausführen erhalten Sie als Ausgabe:

```
Der Inhalt des fuenften array Feldes ist: 5
Der Inhalt des sechsten array Feldes ist: 6

Der Inhalt des ersten array Feldes ist: 1
Der Inhalt des zweiten array Feldes ist: 10
Der Inhalt des dritten array Feldes ist: 3
Der Inhalt des vierte array Feldes ist: 444555666
Der Inhalt des fuenften array Feldes ist: 5
Der Inhalt des neunten array Feldes ist: 25
```

Mit dem Funktionsaufruf `function( feld )` wird ein Zeiger auf das erste Element
des Arrays an das Unterprogramm übergeben. Ausgehend von der Adresse des ersten
Elements können die Adressen der nächsten Elemente berechnet werden und somit
auf die Werte der Elemente zugegriffen werden.

Hier zwei gleichbedeutende Schreibweisen:

``` c
void function( int feld[] )
void function( int *feld )
```

Die alternative Darstellungsform ließe sich also wie folgt realisieren:

``` c
#include <stdio.h>

void function( int *feld )
{
    feld[1] = 10;
    feld[3] = 444555666;
    feld[8] = 25;
}

int main( void )
{
    int feld[9] = { 1, 2, 3, 4, 5, 6 };
    printf( "Der Inhalt des fuenften array Feldes ist: %d \n", feld[4] );
    printf( "Der Inhalt des sechsten array Feldes ist: %d \n\n", feld[5] );

    function( feld );
    printf( "Der Inhalt des ersten array Feldes ist: %d \n", feld[0]);
    printf( "Der Inhalt des zweiten array Feldes ist: %d \n", feld[1] );
    printf( "Der Inhalt des dritten array Feldes ist: %d \n", feld[2]);
    printf( "Der Inhalt des vierte array Feldes ist: %d \n", feld[3]);
    printf( "Der Inhalt des fuenften array Feldes ist: %d \n", feld[4] );
    printf( "Der Inhalt des neunten array Feldes ist: %d \n\n", feld[8] );

    return 0;
}
```
@run

Mehrdimensionale Arrays übergeben Sie entsprechend der Dimensionszahl wie
eindimensionale. `[]` und `*` lassen sich auch hier in geradezu abstrusen
Möglichkeiten vermischen, doch dabei entsteht unleserlicher Programmcode. Hier
eine korrekte Möglichkeit, ein zweidimensionales Feld an eine Funktion zu
übergeben:

``` c
#include <stdio.h>

void function( int feld[2][5] )
{
    feld[1][2] = 55;
}

int main( void )
{
    int feld[2][5] = {
                        { 10, 11, 12, 13, 14 },
                        { 20, 21, 22, 23, 24 }
                     };

    printf( "%d \n", feld[1][2] );

    function( feld );
    printf( "%d \n", feld[1][2] );

    return 0;
}
```
@run

### Zeigerarithmetik

Auf Zeiger können Additions-, Subtraktions- sowie Vergleichsoperatoren
angewendet werden. Die Verwendung anderer Operatoren, wie beispielsweise des
Multiplikations- oder Divisionsoperators, ist dagegen nicht erlaubt.

Die Operatoren können verwendet werden, um innerhalb eines Arrays auf
verschiedene Elemente zuzugreifen, oder die Position innerhalb des Arrays zu
vergleichen. Hier ein kurzes Beispiel um es zu verdeutlichen:

``` c
#include <stdio.h>

int main( void )
{
    int * ptr;
    int a[5] = { 1, 2, 3, 5, 7 };

    ptr = &a[0];
    printf( "a) Die Variable enthält den Wert: %d \n", * ptr );
    //
    ptr += 2;
    printf( "b) Nach der Addition enthält die Variable den Wert: %d \n", * ptr );
    //
    ptr -= 1;
    printf( "c) Nach der Subtraktion enthält die Variable den Wert: %d \n", * ptr );
    //
    ptr += 3;
    printf( "d) Nach der Addition enthält die Variable den Wert: %d \n", * ptr );
    //
    ptr -= 1;
    printf( "e) Nach der Subtraktion enthält die Variable den Wert: %d \n", * ptr );
    return 0;
}
```
@run

Wir deklarieren einen Zeiger sowie ein Array und weisen dem Zeiger die Adresse
des ersten Elementes zu (Abb. 2). Da der Zeiger der auf das erste Element im
Array gerichtet ist äquivalent zum Namen des Array ist, kann man diesen auch
kürzen. Deshalb ist: Abb. 2

``` c
ptr = &a[0];
```

das gleiche wie:

``` c
ptr = a;
```

Auf den Zeiger `ptr` kann nun beispielsweise der Additionsoperator angewendet
werden. Mit dem Ausdruck Abb. 3

``` c
ptr += 2
```

wird allerdings nicht etwa `a[0]` erhöht, sondern `ptr` zeigt nun auf `a[2]`
(Abb. 3).

Wenn `ptr` auf ein Element des Arrays zeigt, dann zeigt `ptr += 1` auf das
nächste Element, `ptr += 2` auf das übernächste Element usw. Wendet man auf
einen Zeiger den Dereferenzierungsoperator (`*`) an, so erhält man den Inhalt
des Elements, auf das der Zeiger gerade zeigt. Wenn beispielsweise `ptr` auf
`a[2]` zeigt, so entspricht `*ptr` dem Wert des dritten Elements des Arrays.

Auch Inkrement- und Dekrementoperator können auf Zeiger auf Vektoren angewendet
werden. Wenn `ptr` auf `a[2]` zeigt, so erhält man über `ptr++` die Adresse des
Nachfolgeelements `a[3]`. Hier ein weiteres Beispiel um es zu veranschaulichen:

``` c
#include <stdio.h>

int main( void )
{
    int * ptr;
    int a[5] = { 1, 2, 3, 5, 7 };

    ptr = &a[0];
    printf( "a) Die Variable enthält den Wert: %d \n", * ptr );
        //
        ptr += 2;
    printf( "b) Nach der Addition enthält die Variable den Wert: %d \n", * ptr );
        //
        ptr -= 1;
    printf( "c) Nach der Subtraktion enthält die Variable den Wert: %d \n", * ptr );
        //
        ptr += 3;
    printf( "d) Nach der Addition enthält die Variable den Wert: %d \n", * ptr );
        //
        ptr -= 1;
    printf( "e) Nach der Subtraktion enthält die Variable den Wert: %d \n", * ptr );

    ptr--;
    printf( "a) Nach der Subtraktion enthält die Variable den Wert: %d \n", * ptr );
    //    
    --ptr;
    printf( "b) Nach der Subtraktion enthält die Variable den Wert: %d \n", * ptr );
    //
    ptr++;
    printf( "c) Nach der Addition enthält die Variable den Wert: %d \n", * ptr );
    //
    ++ptr;
    printf( "d) Nach der Addition enthält die Variable den Wert: %d \n", * ptr );
    return 0;
}
```
@run

Um die neue Adresse berechnen zu können, muss der Compiler die Größe des
Zeigertyps kennen. Deshalb ist es nicht möglich, die Zeigerarithmetik auf den
Typ `void*` anzuwenden.

Grundsätzlich ist zu anzumerken, dass sich der `[]`-Operator in C aus den
Zeigeroperationen heraus definiert. Daraus ergeben sich recht kuriose
Möglichkeiten: So ist `a[b]` als `*(a+b)` definiert, was wiederum
gleichbedeutend mit `*(b+a)` und somit `b[a]` ist. So kommt es, dass `4[a]` das
gleiche Ergebnis liefert, wie `a[4]` – nämlich das 5. Element vom Array `a`. Das
Beispiel sollte man allerdings nur zur Verdeutlichung der Bedeutung des
`[]`-Operators verwenden und nicht wirklich anwenden. Zeigerarithmetik auf
`char`-Arrays

Die Zeigerarithmetik bietet natürlich auch eine Möglichkeit, `char`-Arrays zu
verarbeiten. Ein Beispiel aus der Kryptografie verdeutlicht das Prinzip:

``` c
#include <stdio.h>
#include <string.h>

int main(void)
{
    char satz[1024];
    char * p_satz;
    int satzlaenge;
    char neuersatz[1024];
    char * p_neuersatz;

    fgets( satz, 1024, stdin );
    p_neuersatz = neuersatz;

    for( p_satz = satz; p_satz < satz + ( strlen(satz)-1 ); p_satz += 2 )
    {
        * p_neuersatz = * p_satz;
        ++p_neuersatz;
    }

    for( p_satz = satz+1; p_satz < satz + ( strlen(satz)-1 ); p_satz += 2 )
    {
        * p_neuersatz = * p_satz;
        ++p_neuersatz;
    }

    * p_neuersatz = '\0';

    printf( "Original Satz: %s \n", satz );
    printf( "Verschluesselter Satz: %s \n", neuersatz );
    printf( "Der String ist %d Zeichen lang \n", strlen(satz)-1 );

    return 0;
}
```
``` bash stdin
Dies ist ein Beispielsatz.
```
@run_stdin

Sehen wir uns dieses Beispiel etwas genauer an:

Als erstes wird der zusätzliche Header `string.h` eingebunden, um die Funktion
`strlen()` zum Messen der Länge von Zeichenketten nutzen zu können. Vorsicht:
`strlen()` ist – im Unterschied zu `sizeof()` – eben kein Operator, sondern eine
Funktion.

In Zeile 12 wird mit der Funktion `fgets()` über die Standardeingabe (`stdin`)
eine Zeichenkette von maximal 1024 Zeichen entgegengenommen und diese im Array
`satz[]` abgelegt. Anschließend wird der Zeiger `*p_neuersatz` noch auf das
erste Element des Arrays `neuersatz[]` gesetzt. Zur Erinnerung:

``` c
p_neuersatz = neuersatz;
```

entspricht

``` c
p_neuersatz = &neuersatz[0];
```

In den folgenden Schleife wird der Zeiger `*p_satz` zuerst auf das erste bzw.
zweite Element des Arrays `satz[]` gerichtet und dann pro Schleifendurchlauf um
zwei erhöht, so lange der Wert von `p_satz` kleiner ist als die Länge der
Zeichenkette. Zugleich wird pro Durchlauf das Array-Element, auf das der
`p_satz`-Zeiger gerichtet ist, an die Zeigervariable `p_neuersatz` (und damit
ans jeweilige `neuersatz[]`-Element) übergeben und diese anschließend erhöht, um
im folgenden Durchlauf auf das nächste Array-Element zugreifen zu können.

Mit der ersten Schleife werden also zuerst alle geraden Elemente (also
`satz[0]`, `satz[2]`, etc.) in das `char`-Array `neuersatz[]` geschrieben, mit
der zweiten Schleife dann alle ungeraden Elemente (also `satz[1]`, `satz[3]`,
etc.). `Hello World!` würde also beispielsweise zu `HloWrdel ol!`. Strings

C besitzt im Gegensatz zu vielen anderen Sprachen keinen Datentyp für Strings
(Zeichenketten). Stattdessen werden für Zeichenketten `char`-Arrays verwendet.
Das Ende des Strings ist immer durch das sogenannte String-Terminierungszeichen
`\0` gekennzeichnet. Beispielsweise wird mit

``` c
char text[5]="Wort";
```

beziehungsweise

``` c
char text[]="Wort";
```

ein String definiert. Das `char`-Array hat fünf (nicht vier!) Elemente – das
fünfte Element ist `\0`. Ausführlich geschrieben entsprechen diese Definitionen

``` c
char text[5] = {'W','o','r','t','\0'};
```

beziehungsweise

``` c
char text[]  = {'W','o','r','t','\0'};
```

oder auch

``` c
char text[5];
text[0]='W';
text[1]='o';
text[2]='r';
text[3]='t';
text[4]='\0';
```

Zu beachten ist dabei, dass einzelne Zeichen mit Hochkommata (`'`)
eingeschlossen werden müssen. Strings dagegen werden immer mit
Anführungszeichen (`"`) markiert. Im Gegensatz zu 'W' in Hochkommata entspricht
`"W"` dem Zeichen `'W'` und zusätzlich dem Terminierungszeichen `'\0'`.

## Zeichenkettenfunktionen

Für die Bearbeitung von Strings stellt C eine Reihe von Bibliotheksfunktionen
zur Verfügung. Um sie verwenden zu können, muss mit der Präprozessor-Anweisung
`#include` die Headerdatei `string.h` eingebunden werden.

### `strcpy`

``` c
char* strcpy(char* Ziel, const char* Quelle);
```

Kopiert einen String in einen anderen (Quelle nach Ziel) und liefert Zeiger auf
Ziel als Funktionswert. Bitte beachten Sie, dass eine Anweisung `text2 = text1`
für ein Array nicht möglich ist. Für eine Kopie eines Strings in einen anderen
ist immer die Anweisung `strcpy` nötig, da eine Zeichenkette immer zeichenweise
kopiert werden muss.

Beispiel:

``` c
#include <stdio.h>
#include <string.h>

int main(void)
{
  char text[20];

  strcpy(text, "Hallo!");
  printf("%s\n", text);
  strcpy(text, "Ja Du!");
  printf("%s\n", text);
  return 0;
}
```
@run

Ausgabe:

```
Hallo!
Ja Du!
```

### `strncpy`

``` c
char* strncpy(char* Ziel, const char* Quelle, size_t num);
```

Kopiert `num`-Zeichen von Quelle zu Ziel. Wenn das Ende des Quelle C-String
(welches ein null-Character (`'\0'`) signalisiert) gefunden wird, bevor
`num`-Zeichen kopiert sind, wird Ziel mit `'\0'`-Zeichen aufgefüllt bis die
komplette Anzahl von num-Zeichen in Ziel geschrieben ist.

Wichtig: `strncpy()` fügt selbst keinen null-Character (`'\0'`) an das Ende von
Ziel. Soll heißen: Ziel wird nur null-terminiert wenn die Länge des C-Strings
Quelle kleiner ist als `num`.

Beispiel:

``` c
#include <stdio.h>
#include <string.h>

int main ()
{
    char strA[] = "Hallo!";
    char strB[6];

    strncpy(strB, strA, 5);

    // Nimm die Anzahl von Bytes in strB (6), ziehe 1 ab (= 5) um auf den letzten index zu kommen,
    //dann füge dort einen null-Terminierer ein.
    strB[sizeof(strB)-1] = '\0';

    puts(strB);

    return 0;
}
```
@run

Vorsicht: Benutzen Sie` sizeof()` in diesem Zusammenhang nur bei
Character-Arrays. `sizeof()` gibt die Anzahl der reservierten Bytes zurück. In
diesem Fall: `6` (Größe von `strB`) `* 1 Byte` (Character) `= 6`.

Ausgabe:

```
Hallo
```

### `strcat`

``` c
char* strcat(char* s1, const char* s2);
```

Verbindet zwei Zeichenketten miteinander. Das Stringende-Zeichen `'\0'` von `s1`
wird überschrieben. Voraussetzung ist, dass der für `s1` reservierte
Speicherbereich ausreichend groß zur Aufnahme von `s2` ist. Andernfalls ergibt
sich undefiniertes Verhalten.

Beispiel:

``` c
#include <stdio.h>
#include <string.h>

int main(void)
{
  char text[20];
  strcpy(text, "Hallo!");
  printf("%s\n", text);
  strcat(text, "Ja, du!");
  printf("%s\n", text);
  return 0;
}
```
@run

Ausgabe:

```
Hallo!
Hallo!Ja, du!
```

Wie Sie sehen wird der String in Zeile 9 diesmal nicht überschrieben, sondern am
Ende angehängt.

### `strncat`

``` c
char* strncat(char* s1, const char* s2, size_t n);
```

Verbindet – so wie `strcat()` – zwei Zeichenketten miteinander, wobei aber nur n
Elemente von `s2` an `s1` angehängt werden. An das Ende der
Resultat-Zeichenfolge wird in jedem Fall ein `'\0'`-Zeichen angehängt. Für
überlappende Bereiche ist das Ergebnis – soweit nicht anders angegeben – nicht
definiert.

Mit dieser Funktion kann beispielsweise sichergestellt werden, dass nicht in
einen undefinierten Speicherbereich geschrieben wird. Dafür wäre `n` so zu
wählen, dass der für `s1` reservierte Speicherbereich nicht überschritten wird.

Beispiel:

``` c
#include <stdio.h>
#include <string.h>

int main(void)
{
  char text[40];
  strcpy(text, "Es werden nur zehn Zeichen ");
  printf("%s\n", text);
  strncat(text, "angehaengt, der Rest nicht.", 10);
  printf("%s\n", text);
  return 0;
}
```
@run

Ausgabe:

```
Es werden nur zehn Zeichen
Es werden nur zehn Zeichen angehaengt
```

### `strtok`

``` c
char *strtok( char *s1, const char *s2 );
```

Diese Funktion zerlegt einen String `s1` mit Hilfe des bzw. der in `s2`
gegebenen Trennzeichen (token) in einzelne Teil-Strings. `s2` kann also eines
oder auch mehrere Trennzeichen enthalten, das heißt

``` c
char s2[] = " ,\n.";
```

würde beispielsweise auf eine Trennung bei Space, Komma, New-Line oder Punkt hinauslaufen.

Anmerkung: Durch `strtok()` wird der ursprüngliche String zerstört, dieser darf
demzufolge niemals konstant (`const`) sein. Weiters ist die Funktion wegen der
internen Verwendung von statischem Speicher nicht multithread-fähig und nicht
wiedereintrittsfähig (nicht reentrant).

Beispiel:

``` c
#include <stdio.h>
#include <string.h>

int main(void) {
    char text[] = "Das ist ein Beispiel!";
    char trennzeichen[] = " ";
    char * wort;
    int i=1;
    wort = strtok(text, trennzeichen);

    while(wort != NULL) {
        printf("Token %d: %s\n", i++, wort);
        wort = strtok(NULL, trennzeichen);
        //Jeder Aufruf gibt das Token zurück. Das Trennzeichen wird mit '\0' überschrieben.
        //Die Schleife läuft durch bis strtok() den NULL-Zeiger zurückliefert.
    }
    return 0;
}
```
@run

Ausgabe:

```
Token1: Das
Token2: ist
Token3: ein
Token4: Beispiel!
```

### `strcspn`

``` c
int strcspn(const char *string1, const char *string2);
```

Diese Funktion gibt die Anzahl der Zeichen am Anfang von `string1` zurück, die
nicht in `string2` enthalten sind.

Beispiel:

``` c
#include <stdio.h>
#include <string.h>

int main(void){
    char s1[] = "Das ist ein Text";
    char s2[] = "tbc";

    int cnt = strcspn(s1,s2);
    printf("Anzahl der Zeichen am Anfang von '%s', die nicht in '%s' vorkommen: %d\n", s1, s2, cnt);

    return 0;
}
```
@run

Ausgabe:

```
Anzahl der Zeichen am Anfang von 'Das ist ein Text', die nicht in 'tbc' vorkommen: 6
```
### `strpbrk`

``` c
char *strpbrk(const char *string1, const char *string2);
```

Gibt einen Zeiger auf das erste Zeichen in `string1` zurück, das auch in
`string2` enthalten ist. Es wird also – wie auch bei Funktion `strcspn()` –
nicht nach einer Zeichenkette, sondern nach einem einzelnen Zeichen aus einer
Zeichenmenge gesucht. War die Suche erfolglos, wird `NULL` zurückgegeben.

Beispiel:

``` c
#include <stdio.h>
#include <string.h>

int main()
{
   char string1[]="Schwein gehabt!";
   char string2[]="aeiou";
   printf("%s\n", strpbrk(string1, string2));
   return 0;
}
```
@run

Ausgabe:

```
ein gehabt!
```

### `strchr`

``` c
char* strchr(char *string, int zeichen);
```

Diese Funktion sucht nach dem ersten Auftreten eines Zeichens `zeichen` in einer
Zeichenkette `string` und gibt einen Zeiger auf dieses zurück. War die Suche
erfolglos, wird `NULL` zurückgegeben.

Beispiel 1:

``` c
#include <stdio.h>
#include <string.h>

int main()
{
  char string[] = "Ein Teststring mit Worten";
  printf("%s\n",strchr(string, (int)'W'));
  printf("%s\n",strchr(string, (int)'T'));
  return 0;
}
```
@run

Ausgabe:

```
Worten
Teststring mit Worten
```

Beispiel 2:

``` c
#include <stdio.h>
#include <string.h>

int main()
{
  char string[]="Dies ist wichtig. Dies nicht.";
  char * stelle;

  stelle=strchr(string, (int)'.');
  * (stelle+1)='\0'; /*Durch *(stelle+1) wird nicht der Punkt,
                      sondern das Leerzeichen (das Zeichen danach)
                      durch das Determinierungszeichen ersetzt*/

  printf("%s", string);

  return 0;
}
```
@run

Ausgabe:

```
Dies ist wichtig.
```


### `strrchr`

``` c
char *strrchr(const char *s, int ch);
```

Diese Funktion sucht im Unterschied zu `strchr()` nicht nach dem ersten, sondern
nach dem letzten Auftreten eines Zeichens `ch` in einer Zeichenkette `s` und
gibt einen Zeiger auf dieses Zeichen zurück. War die Suche erfolglos, wird
`NULL` zurückgegeben.

Beispiel 1:

Hier nutzen wir `fgets()`, um eine Zeichenkette von der Standard-Eingabe
(`stdin`) einzulesen. Wenn die Eingabe nun aber weniger Zeichen umfasst als die
angegebene maximale Anzahl der einzulesenden Zeichen (im Beispiel unten wären es
20), endet die resultierende Zeichenkette mit einem New-Line-Zeichen (`\n`). Um
einen nullterminierten String zu erhalten, suchen wir daher mit einem Zeiger
nach diesem und ersetzen es gegebenenfalls durch `\0`.

``` c
#include <stdio.h>
#include <string.h>

int main()
{
   char string[20];
   char * ptr;
   printf("Eingabe machen:\n");
   fgets(string, 20 , stdin);
   // man setzt den zeiger auf das New-Line-Zeichen
   ptr = strrchr(string, '\n');
   if( ptr != NULL )
   {
     // \n-Zeichen mit \0 überschreiben
     * ptr = '\0';
   }

   printf("%s\n",string);
   return 0;

}
```
``` bash stdin
Das ist ein test
```
@run_stdin


Beispiel 2:

``` c
#include <stdio.h>
#include <string.h>

int main()
{
   char string[] = "Dies ist wichtig. Dies ist nicht wichtig";
   char * ptr;

   // suche Trennzeichen '.' vom Ende der Zeichenkette aus
   ptr = strrchr (string, '.');

   // wenn Trennzeichen im Text nicht vorhanden,
   // dann ist der Pointer NULL, d.h. NULL muss abgefangen werden.
   if (ptr != NULL) {
       * ptr = '\0';
   }

   printf ("%s\n", string);
   return 0;
}
```
@run

Der Pointer `ptr` zeigt nach `strrchr()` genau auf die Speicherstelle des
Strings, in der das erste Trennzeichen von hinten steht. Wenn man nun an diese
Speicherstelle das Zeichenketteendezeichen `\0` schreibt, dann ist der String
für alle Stringfunktionen an dieser Stelle beendet. `printf()` gibt den String
`string` nur bis zum Zeichenketteendezeichen aus.

Ausgabe:

```
Dies ist wichtig
```

### `strcmp`

``` c
int strcmp(char* s1, char* s2);
```

Diese Funktion vergleicht zwei Zeichenketten miteinander, wobei Zeichen für
Zeichen deren jeweilige ASCII-Codes verglichen werden. Wenn die beiden Strings
identisch sind, gibt die Funktion den Wert 0 zurück. Sind sie unterschiedlich,
liefert die Funktion einen Rückgabewert entweder größer oder kleiner 0: Ein
Rückgabewert größer / kleiner 0 bedeutet, dass der ASCII-Code des ersten
ungleichen Zeichens in `s1` größer / kleiner ist als der des entsprechenden
Zeichens in `s2`.

Beispiel:

``` c
#include <stdio.h>
#include <string.h>

int main()
{
  const char string1[] = "Hello";
  const char string2[] = "World";
  const char string3[] = "Hello";

  if (strcmp(string1,string2) == 0)
  {
    printf("Die beiden Zeichenketten %s und %s sind identisch.\n",string1,string2);
  }
  else
  {
    printf("Die beiden Zeichenketten %s und %s sind unterschiedlich.\n",string1,string2);
  }

  if (strcmp(string1,string3) == 0)
  {
    printf("Die beiden Zeichenketten %s und %s sind identisch.\n",string1,string3);
  }
  else
  {
    printf("Die beiden Zeichenketten %s und %s sind unterschiedlich.\n",string1,string3);
  }

  return 0;
}
```
@run

Ausgabe:

```
Die beiden Zeichenketten Hello und World sind unterschiedlich.
Die beiden Zeichenketten Hello und Hello sind identisch.
```

### `strncmp`

``` c
int strncmp(const char *x, const char *y, size_t n);
```

Diese Funktion arbeitet so wie `strcmp()` – mit dem einzigen Unterschied, dass
nur die ersten `n` Zeichen der beiden Strings miteinander verglichen werden.
Auch der Rückgabewert entspricht dem von `strcmp()`.

Beispiel:

``` c
#include <stdio.h>
#include <string.h>

int main()
{
   const char x[] = "aaaa";
   const char y[] = "aabb";
   int i;

   for(i = strlen(x); i > 0; --i)
      {
         if(strncmp( x, y, i) != 0)
            printf("Die ersten %d Zeichen der beiden Strings "\
                   "sind nicht gleich\n", i);
         else
            {
               printf("Die ersten %d Zeichen der beiden Strings "\
                      "sind gleich\n", i);
               break;
            }
      }
   return 0;
}
```
@run

Ausgabe:

```
Die ersten 4 Zeichen der beiden Strings sind nicht gleich
Die ersten 3 Zeichen der beiden Strings sind nicht gleich
Die ersten 2 Zeichen der beiden Strings sind gleich
```

### `strspn`

``` c
int strspn(const char *string1, const char *string2);
```

Diese Funktion gibt die Anzahl der Zeichen am Anfang von `string1` zurück, die
in `string2` enthalten sind.

Beispiel:

``` c
#include <stdio.h>
#include <string.h>

int main()
{
   const char string[] = "7501234-123";
   int cnt = strspn(string, "0123456789");

   printf("Anzahl der Ziffern am Anfang von '%s': %d\n", string, cnt);

   return 0;
}
```
@run

Ausgabe:

```
Anzahl der Ziffern am Anfang von '7501234-123': 7
```

### `strlen`

``` c
size_t strlen(const char *string1);
```

Diese Funktion gibt die Länge eines Strings `string1` (ohne dem abschließenden
Nullzeichen) zurück.

Beispiel:

``` c
#include <stdio.h>
#include <string.h>

int main()
{
  char string1[] = "Das ist ein Test";
  size_t length;

  length = strlen(string1);
  printf("Der String \"%s\" hat %d Zeichen\n", string1, length);

  return 0;
}
```
@run

Ausgabe:

```
Der String "Das ist ein Test" hat 16 Zeichen
```

### `strstr`

``` c
char *strstr(const char *s1, const char *s2);
```

Sucht nach dem ersten Vorkommen der Zeichenfolge `s2` (ohne dem abschließenden
Nullzeichen) in der Zeichenfolge `s1` und gibt einen Zeiger auf die gefundene
Zeichenfolge (innerhalb `s1`) zurück. Ist die Länge der Zeichenfolge `s2` 0, so
wird der Zeiger auf `s1` geliefert; war die Suche erfolglos, wird `NULL`
zurückgegeben.

``` c
#include <stdio.h>
#include <string.h>

int main ()
{
  char str[] = "Dies ist ein simpler string";
  char * ptr;
  // setzt den Pointer ptr an die Textstelle "simpler"
  ptr = strstr (str, "simpler");
  // ersetzt den Text an der Stelle des Pointers mit "Beispiel"
  strncpy (ptr, "Beispiel", 8);
  puts (str);
  return 0;
}
```
@run

Ausgabe:

```
Dies ist ein Beispielstring
```

### Gefahren

Bei der Verarbeitung von Strings muss man aufpassen, nicht über das Ende eines
Speicherbereiches hinauszuschreiben oder zu -lesen. Generell sind Funktionen wie
`strcpy()` und `sprintf()` zu vermeiden und stattdessen `strncpy()` und
`snprintf()` zu verwenden, weil dort die Größe des jeweiligen Speicherbereiches
angegeben werden kann.

Beispiel:

``` c
#include <string.h>
#include <stdio.h>

int main(void)
{
  char text[20];

  strcpy(text, "Dies ist kein feiner Programmtest"); // Absturzgefahr, da Zeichenkette zu lang

  strncpy(text, "Dies ist ein feiner Programmtest", sizeof(text));
  printf("Die Laenge ist %u\n", strlen(text)); // Absturzgefahr, da Zeichenkette 'text' nicht terminiert

  // also vorsichtshalber mit \0 abschliessen.
  text[sizeof(text)-1] = '\0';
  printf("Die Laenge von '%s' ist %u \n", text, strlen(text));

  return 0;
}
```
@run

Die beiden Zeilen 8 und 11 bringen das Programm möglicherweise zum Absturz:

* Zeile 8: `strcpy()` versucht mehr Zeichen zu schreiben, als in der Variable
  vorhanden sind, was möglicherweise zu einem Speicherzugriffsfehler führt.
* Zeile 11: Falls das Programm in Zeile 8 noch nicht abstürzt, geschieht das
  eventuell jetzt. In Zeile 10 werden genau 20 Zeichen kopiert, was prinzipiell
  in Ordnung ist. Weil aber der Platz nicht ausreicht, wird die abschließende
  `\0` ausgespart, die Zeichenkette ist also nicht terminiert. Die Funktion
  `strlen()` benötigt aber genau diese `\0`, um die Länge zu bestimmen. Tritt
  dieses Zeichen nicht auf, kann es zu einem Speicherzugriffsfehler kommen.

Entfernt man die beiden Zeilen 8 und 11 ergibt sich folgende Ausgabe:

```
Die Laenge von 'Dies ist ein feiner' ist 19
```

Es ist klar, dass sich hier als Länge 19 ergibt, denn ein Zeichen wird eben für
das Nullzeichen verbraucht. Man muss also immer daran denken, ein zusätzliches
Byte dafür einzurechnen.

### Iterieren durch eine Zeichenkette

Die folgende Funktion `replace_character()` ersetzt in einem String ein Zeichen
durch ein anderes, ihr Rückgabewert ist die Anzahl der Ersetzungen.

``` c
#include <string.h>
#include <stdio.h>

unsigned replace_character(char* string, char from, char to)
{
  unsigned result = 0;

  if (!string) return 0;

  while (*string != '\0')
  {
    if (*string == from)
    {
      * string = to;
      result++;
    }
    string++;
  }
  return result;
}

int main(void)
{
  char text[50] = "Dies ist ein feiner Programmtest";
  unsigned result;

  result = replace_character(text, 'e', ' ');
  printf("%u Ersetzungen: %s\n", result, text);

  result = replace_character(text, ' ', '#');
  printf("%u Ersetzungen: %s\n", result, text);

  return 0;
}
```
@run

Der Vergleich der einzelnen Zeichen von `char *string` mit `char from` wird mit
einer Schleife bewerkstelligt. Der Zeiger `string` (diese Schreibweise
entspricht ja `&string[]`) verweist anfangs auf die Adresse des ersten Zeichens –
durch die Dereferenzierung (`*string`) erhält man also dieses Zeichen selbst. Am
Ende jedes Schleifendurchlaufes wird dieser Zeiger um eins erhöht, also auf das
nächste Zeichen gesetzt. Falls die beiden verglichenen Zeichen identisch sind,
wird das jeweiligen Zeichen `*string` durch `to` ersetzt.

Ausgabe:

```
5 Ersetzungen: Di s ist  in f in r Programmt st
9 Ersetzungen: Di#s#ist##in#f#in#r#Programmt#st
```

### Die Bibliothek `ctype.h`

Wie wir bereits im Kapitel Variablen und Konstanten gesehen haben, sagt der
C-Standard nichts über den verwendeten Zeichensatz aus. Nehmen wir
beispielsweise an, wir wollen testen, ob in der Variable c ein Buchstabe
gespeichert ist. Wir verwenden dazu die Bedingung

``` c
  if ('A' <= c && c <= 'Z' || 'a' <= c && c <= 'z')
```

Unglücklicherweise funktioniert diese Bedingung zwar mit dem ASCII-, nicht aber
dem EBCDIC-Zeichensatz. Der Grund dafür ist, dass die Buchstaben beim
EBCDIC-Zeichensatz nicht hintereinander stehen.

Wer eine plattformunabhängige Lösung sucht, kann deshalb auf Funktionen der
Standardbibliothek zurückgreifen, deren Prototypen alle in der Headerdatei
`ctype.h` definiert sind. Für den Test auf Buchstaben können wir beispielsweise
die Funktion `int isalpha(int c)` benutzen. Alle Funktionen, die in der
Headerdatei `ctype.h` deklariert sind, liefern einen Wert ungleich 0 zurück wenn
die entsprechende Bedingung erfüllt ist, andernfalls liefern sie 0 zurück.

Weitere Funktionen von `ctype.h` sind:

* `int isalnum(int c)` testet auf alphanumerisches Zeichen (a-z, A-Z, 0-9)
* `int isalpha(int c)` testet auf Buchstabe (a-z, A-Z)
* `int iscntrl(int c)` testet auf Steuerzeichen (`'\f'`, `'\n'`, `'\t'` ...)
* `int isdigit(int c)` testet auf Dezimalziffer (0-9)
* `int isgraph(int c)` testet auf druckbare Zeichen
* `int islower(int c)` testet auf Kleinbuchstaben (a-z)
* `int isprint(int c)` testet auf druckbare Zeichen ohne Leerzeichen
* `int ispunct(int c)` testet auf druckbare Interpunktionszeichen
* `int isspace(int c)` testet auf Zwischenraumzeichen (engl. whitespace)
  (`' '`, `'\f'`, `'\n'`, `'\r'`, `'\t'`, `'\v'`)
* `int isupper(int c)` testet auf Großbuchstaben (A-Z)
* `int isxdigit(int c)` testet auf hexadezimale Ziffern (0-9, a-f, A-F)

Zusätzlich sind noch zwei Funktionen für die Umwandlung in Groß- bzw.
Kleinbuchstaben definiert:

* `int tolower(int c)` wandelt Groß- in Kleinbuchstaben um
* `int toupper(int c)` wandelt Klein- in Großbuchstaben um

## Komplexe Datentypen

### Strukturen

Strukturen fassen mehrere primitive oder komplexe Variablen zu einer logischen
Einheit zusammen. Die Variablen dürfen dabei unterschiedliche Datentypen
besitzen. Die Variablen der Struktur werden als Komponenten (engl. members)
bezeichnet.

Eine logische Einheit kann zum Beispiel eine Adresse, Koordinate, Datums- oder
Zeitangabe sein. Ein Datum besteht beispielsweise aus den Komponenten Tag, Monat
und Jahr. Die Deklaration einer solchen Struktur sieht wie folgt aus:

``` c
struct datum
{
  int tag;
  char monat[10];
  int jahr;
};
```

Vergessen Sie bei der Deklaration bitte nicht das Semikolon am Ende!

Es gibt mehrere Möglichkeiten, Variablen von diesem Typ zu erzeugen;
beispielsweise im Zuge der Struktur-Deklaration:

``` c
struct datum
{
  int tag;
  char monat[10];
  int jahr;
} geburtstag, urlaub;
```

Die zweite Möglichkeit besteht darin, die Struktur zunächst wie oben zu
deklarieren und Variablen der Struktur später zu erzeugen:

``` c
struct datum geburtstag, urlaub;
```

Die Größe einer Variable vom Typ `struct datum` kann mit `sizeof(struct datum)`
ermittelt werden. Die Gesamtgröße eines `struct`-Typs kann mehr sein als die
Größe der einzelnen Komponenten, in unserem Fall also
`sizeof(int) + sizeof(char[10]) + sizeof(int)`. Der Compiler darf nämlich die
einzelnen Komponenten so im Speicher ausrichten, dass ein schneller Zugriff
möglich ist.

Beispiel:

``` c
 struct Test
 {
  char c;
  int i;
 };

 sizeof(struct Test); // Ergibt wahrscheinlich nicht 5
```

Der Compiler wird wahrscheinlich mehr Bytes als die Summe der Einzelkomponenten
reservieren:

[Online-Compiler ideone:](http://ideone.com/w03caY)

``` c
#include <stdio.h>
#include <stddef.h>

struct Test
{
  char c;
  int i;
};

int main(void)
{
	printf("Groesse : %lu\n", (unsigned long)sizeof(struct Test));
	printf("Offset c: %lu\n", (unsigned long)offsetof(struct Test,c));
	printf("Offset i: %lu\n", (unsigned long)offsetof(struct Test,i));
	return 0;
}
```
@run

```
Groesse : 8
Offset c: 0
Offset i: 4
```

Die Zuweisung kann komponentenweise erfolgen und eine Initialisierung erfolgt
immer mit geschweifter Klammer:

``` c
  struct datum geburtstag = {7, "Mai", 2005};
```

Beim Zugriff auf eine Strukturvariable muss immer der Bezeichner der Struktur
durch einen Punkt getrennt mit angegeben werden. Mit

``` c
 geburtstag.jahr = 1964;
```

wird der Komponente `jahr` der Struktur `geburtstag` der neue Wert 1964
zugewiesen.

Der gesamte Inhalt einer Struktur kann einer anderen Struktur zugewiesen werden.
Mit

``` c
  urlaub = geburtstag;
```

wird der gesamte Inhalt der Struktur `geburtstag` dem Inhalt der Struktur
`urlaub` zugewiesen.

Es gibt auch Zeiger auf Strukturen. Mit

``` c
 struct datum *urlaub;
```

wird `urlaub` als ein Zeiger auf eine Variable vom Typ `struct datum`
vereinbart. Der Zugriff auf das Element `tag` erfolgt über `(*urlaub).tag`.

Die Klammern sind nötig, da der Vorrang des Punktoperators höher ist als der des
Dereferenzierungsoperators `*`. Würde die Klammer fehlen, würde der
Dereferenzierungsoperator auf den gesamten Ausdruck angewendet, so dass man
stattdessen `*(urlaub.tag)` erhalten würde. Da die Komponente `tag` aber kein
Zeiger ist, würde man hier einen Fehler erhalten.

Da Zeiger auf Strukturen sehr häufig gebraucht werden, wurde in C der
`->`-Operator (auch Strukturoperator genannt)eingeführt. Er steht an der Stelle
des Punktoperators. So ist beispielsweise `(*urlaub).tag` äquivalent zu
`urlaub->tag`.

### Unions

Unions sind Strukturen sehr ähnlich. Der Hauptunterschied zwischen Strukturen
und Unions liegt allerdings darin, dass die Elemente denselben Speicherplatz
bezeichnen. Deshalb benötigt eine Variable vom Typ `union` nur genau soviel
Speicherplatz, wie ihr jeweils größtes Element.

Unions werden immer da verwendet, wo man komplexe Daten interpretieren will. Zum
Beispiel beim Lesen von Datendateien. Man hat sich ein bestimmtes Datenformat
ausgedacht, weiß aber erst beim Interpretieren, was man mit den Daten anfängt.
Dann kann man mit den Unions alle denkbaren Fälle deklarieren und je nach
Kontext auf die Daten zugreifen. Eine andere Anwendung ist die Konvertierung von
Daten. Man legt zwei Datentypen "übereinander" und kann auf die einzelnen Teile
zugreifen.

Im folgenden Beispiel wird ein `char`-Element mit einem `short`-Element
überlagert. Das `char`-Element belegt genau 1 Byte, während das `short`-Element
2 Byte belegt.

Beispiel:

``` c
 union zahl
 {
   char  c_zahl; //1 Byte
   short s_zahl; //1 Byte + 1 Byte
 }z;
```

Mit

``` c
 z.c_zahl = 5;
```

wird dem Element `c_zahl` der Variable `z` der Wert 5 zugwiesen. Da sich
`c_zahl` und das erste Byte von `s_zahl` auf derselben Speicheradresse befinden,
werden nur die 8 Bit des Elements `c_zahl` verändert. Die nächsten 8 Bit, welche
benötigt werden, wenn Daten vom Typ `short` in die Variable `z` geschrieben
werden, bleiben unverändert. Wird nun versucht auf ein Element zuzugreifen,
dessen Typ sich vom Typ des Elements unterscheidet, auf das zuletzt geschrieben
wurde, ist das Ergebnis nicht immer definiert.

Wie auch bei Strukturen kann der `->` Operator auf eine Variable vom Typ Union
angewendet werden.

Unions und Strukturen können beinahe beliebig ineinander verschachtelt werden.
Eine Union kann also innerhalb einer Struktur definiert werden und umgekehrt.

Beispiel:

``` c
 union vector3d {
  struct { float x, y, z; } vec1;
  struct { float alpha, beta, gamma; } vec2;
  float vec3[3];
 };
```

Um den in der Union aktuell verwendeten Datentyp zu erkennen bzw. zu speichern,
bietet es sich an, eine Struktur zu definieren, die die verwendete Union
zusammen mit einer weiteren Variable umschliesst. Diese weitere Variable kann
dann entsprechend kodiert werden, um den verwendeten Typ abzubilden:

``` c
 struct checkedUnion {
  int type;  // Variable zum Speichern des in der Union verwendeten Datentyps
  union intFloat {
   int i;
   float f;
  } intFloat1;
 };
```

Wenn man jetzt eine Variable vom Typ `struct checkedUnion` deklariert, kann man
bei jedem Lese- bzw. Speicherzugriff den gespeicherten Datentyp abprüfen bzw.
ändern. Um nicht direkt mit Zahlenwerten für die verschiedenen Typen zu
arbeiten, kann man sich Konstanten definieren, mit denen man dann bequem
arbeiten kann. So könnte der Code zum Abfragen und Speichern von Werten
aussehen:

``` c
#include <stdio.h>

#define UNDEF 0
#define INT 1
#define FLOAT 2

struct checkedUnion {
  int type;
  union intFloat {
   int i;
   float f;
  } intFloat1;
};

int main(void)
{
 struct checkedUnion test1;
 test1.type = UNDEF; // Initialisierung von type mit UNDEF=0, damit der undefinierte Fall zu erkennen ist
 int testInt = 10;
 float testFloat = 0.1;

 // Beispiel für einen Integer
 test1.type = INT; // setzen des Datentyps für die Union
 test1.intFloat1.i = testInt; // setzen des Wertes der Union

 // Beispiel für einen Float
 test1.type = FLOAT;
 test1.intFloat1.f = testFloat;

 // Beispiel für einen Lesezugriff
 if (test1.type == INT) {
  printf ("Der Integerwert der Union ist: %d\n", test1.intFloat1.i);
 } else if (test1.type == FLOAT) {
  printf ("Der Floatwert der Union ist: %lf\n", test1.intFloat1.f);
 } else {
  printf ("FEHLER!\n");
 }

 return 0;
}
```
@run

Folgendes wäre also nicht möglich, da die von der Union umschlossene Struktur
zwar definiert aber nicht deklariert wurde:

``` c
 union impossible {
  struct { int i, j; char l; }; // Deklaration fehlt, richtig wäre: struct { ... } structName;
  float b;
  void* buffer;
 };
```

Unions sind wann immer es möglich ist zu vermeiden. Type punning (engl.) – zu
deutsch etwa spielen mit den Datentypen – ist eine sehr fehlerträchtige
Angelegenheit und erschwert das Kompilieren auf anderen und die
Interoperabilität mit anderen Systemen mitunter ungemein.

### Aufzählungen

Die Definition eines Aufzählungsdatentyps (`enum`) hat die Form

``` c
 enum [Typname] {
     Bezeichner [= Wert] {, Bezeichner [= Wert]}
 };
```

Damit wird der Typ `Typname` definiert. Eine Variable diesen Typs kann einen der
mit Bezeichner definierten Werte annehmen. Beispiel:

``` c
 enum Farbe {
     Blau, Gelb, Orange, Braun, Schwarz
 };
```

Aufzählungstypen sind eigentlich nichts anderes als eine Definition von vielen
Konstanten. Durch die Zusammenfassung zu einem Aufzählungstyp wird ausgedrückt,
dass die Konstanten miteinander verwandt sind. Ansonsten verhalten sich diese
Konstanten ähnlich wie Integerzahlen, und die meisten Compiler stört es auch
nicht, wenn man sie bunt durcheinander mischt, also zum Beispiel einer
`int`-Variablen den Wert Schwarz zuweist.

Für Menschen ist es sehr hilfreich, Bezeichner statt Zahlen zu verwenden. So ist
bei der Anweisung `textfarbe(4)` nicht gleich klar, welche Farbe denn zur 4
gehört. Benutzt man jedoch `textfarbe(Schwarz)`, ist der Quelltext leichter
lesbar.

Bei der Definition eines Aufzählungstyps wird dem ersten Bezeichner der Wert 0
zugewiesen, falls kein Wert explizit angegeben wird. Jeder weitere Bezeichner
erhält den Wert seines Vorgängers, erhöht um 1. Beispiel:

``` c
 enum Primzahl {
     Zwei = 2, Drei, Fuenf = 5, Sieben = 7
 };
```

Die Drei hat keinen expliziten Wert bekommen. Der Vorgänger hat den Wert 2,
daher wird `Drei = 2 + 1 = 3`.

Meistens ist es nicht wichtig, welcher Wert zu welchem Bezeichner gehört,
Hauptsache sie sind alle unterschiedlich. Wenn man die Werte für die Bezeichner
nicht selbst festlegt (so wie im Farbenbeispiel oben), kümmert sich der Compiler
darum, dass jeder Bezeichner einen eindeutigen Wert bekommt. Aus diesem Grund
sollte man mit dem expliziten Festlegen auch sparsam umgehen.

### Variablen-Deklaration

Es ist zu beachten, dass z.B. Struktur-Variablen wie folgt deklariert werden
müssen:

``` c
struct StrukturName VariablenName;
```

Dies kann umgangen werden, indem man die Struktur wie folgt definiert:

``` c
typedef struct
{
  // Struktur-Elemente
} StrukturName;
```

Dann können die Struktur-Variablen einfach durch

``` c
StrukturName VariablenName;
```

deklariert werden. Dies gilt nicht nur für Strukturen, sondern auch für Unions
und Aufzählungen.

Folgendes ist auch möglich, da sowohl der Bezeichner `struct StrukturName`, wie
auch StrukturName, definiert wird:

``` c
typedef struct StrukturName
{
   // Struktur-Elemente
} StrukturName;

StrukturName VariablenName1;
struct StrukturName VariablenName2;
```

Mit `typedef` können Typen erzeugt werden, ähnlich wie "`int`" und "`char`"
welche sind. Dies ist hilfreich um seinen Code noch genauer zu strukturieren.

Beispiel:

``` c
typedef char name[200];
typedef char postleitzahl[5];

typedef struct {
	name strasse;
	unsigned int hausnummer;
	postleitzahl plz;
} adresse;

int main()
{
	name vorname, nachname;
	adresse meine_adresse;
}
```

## Typumwandlung

Der Typ eines Wertes kann sich aus verschiedenen Gründen ändern müssen.
Beispielsweise, weil man unter Berücksichtigung höherer Genauigkeit weiter
rechnen möchte, oder weil man den Nachkomma-Teil eines Wertes nicht mehr
benötigt. In solchen Fällen verwendet man Typumwandlung (auch als
Typkonvertierung bezeichnet).

Man unterscheidet dabei grundsätzlich zwischen **expliziter** und **impliziter**
Typumwandlung. Explizite Typumwandlung nennt man auch _Cast_.

Eine Typumwandlung kann _einschränkend_ oder _erweiternd_ sein.

### Implizite Typumwandlung

Bei der impliziten Typumwandlung wird die Umwandlung nicht im Code aufgeführt.
Sie wird vom Compiler automatisch anhand der Datentypen von Variablen bzw.
Ausdrücken erkannt und durchgeführt. Beispiel:

``` c
int i = 5;
float f = i; // implizite Typumwandlung
```

Offenbar gibt es hier kein Problem. Unsere Ganzzahl 5 wird in eine
Gleitkommazahl umgewandelt. Dabei könnten die ausgegebenen Variablen zum
Beispiel so aussehen:

```
5
5.000000
```

Die implizite Typumwandlung (allgemeiner Erweiternde Typumwandlung) erfolgt von
kleinen zu größeren Datentypen.

### Explizite Typumwandlung

Anders als bei der impliziten Typumwandlung wird die explizite Typumwandlung im
Code angegeben. Es gilt folgende Syntax:

``` c
(Zieltyp)Ausdruck
```

Wobei Zieltyp der Datentyp ist, zu dem Ausdruck konvertiert werden soll.
Beispiel:

``` c
float pi = 3.14159f;
int i = (int)pi; // explizite Typumwandlung
```

liefert `i=3`.

Die explizite Typumwandlung entspricht allgemein dem Konzept der Einschränkenden
Typumwandlung.

### Verhalten von Werten bei Typumwandlungen

Fassen wir zusammen. Wandeln wir `int` in `float` um, wird impliziert erweitert,
d. h. es geht keine Genauigkeit verloren.

Haben wir eine `float` nach `int` Umwandlung, schneidet der Compiler die
Nachkommastellen ab - Genauigkeit geht zwar verloren, aber das Programm ist in
seiner Funktion allgemein nicht beeinträchtigt.

Werden allgemein größere in kleinere Ganzzahltypen umgewandelt, werden die
oberen Bits abgeschnitten (es erfolgt somit keine Rundung!). Würde man versuchen
einen Gleitpunkttyp in einen beliebigen Typ mit kleineren Wertebereich
umzuwandeln, ist das Verhalten unbestimmt.


## Speicherverwaltung

Die Daten, mit denen ein Programm arbeitet, müssen während der Laufzeit an einem
bestimmten Ort der Computer-Hardware abgelegt und zugreifbar sein. Die
Speicherverwaltung bestimmt, wo bestimmte Daten abgelegt werden, und wer (welche
Programme, Programmteile) wie (nur lesen oder auch schreiben) darauf zugreifen
darf. Zudem unterscheidet man Speicher auch danach, wann die Zuordnung eines
Speicherortes überhaupt stattfindet. Die Speicherverwaltung wird in erster Linie
durch die Deklaration einer Variablen (oder Konstanten) beeinflusst, aber auch
durch Pragmas und durch Laufzeit-Allozierung, üblicherweise `malloc` oder
`calloc`.

### Ort und Art der Speicherreservierung (Speicherklasse)

Zum Teil bestimmt der Ort eines Speichers die Zugriffsmöglichkeiten und
-geschwindigkeiten, zum Teil wird der Zugriff aber auch von Compiler,
Betriebssystem und Hardware kontrolliert.

#### Speicherorte

Mögliche physikalische Speicherorte sind in erster Linie die Register der CPU
und der Arbeitsspeicher.

Um eine Variable explizit in einem Register abzulegen, deklariert man eine
Variable unter der Speicherklasse `register`, z.B.:

``` c
register int var;
```

Von dieser Möglichkeit sollte man allerdings, wenn überhaupt, nur äußerst selten
Gebrauch machen, da eine CPU nur wenige Register besitzt, und einige von diesen
stets für die Abarbeitung von Maschinenbefehlen benötigt werden. Die meisten
Compiler verfügen zudem über Optimierungs-Algorithmen, die Variablen in der
Regel dann in Registern ablegen, wenn es am sinnvollsten ist.

Die Ablage im Arbeitsspeicher kann grundsätzlich in zwei verschiedenen Bereichen
erfolgen.

Zum einen innerhalb einer Funktion, die Variable hat dann zur Ausführungszeit
der Funktion eine Position im Stack oder wird vom Optimierungs-Algorithmus in
einem Register platziert. Bei erneutem Aufruf der Funktion hat die Variable dann
nicht den gleichen Wert, wie zum Abschluss des letzten Aufrufs. Bei rekursivem
Aufruf erhält sie einen neuen, eigenen Speicherplatz, auch mit einem anderen
Wert. Deklariert man eine Variable innerhalb einer Funktion ohne weitere Angaben
zur Speicherklasse innerhalb eines Funktionskörpers, so gehört sie der Funktion
an, z.B:

``` c
int fun(int var) {
    int var;
}
```

Zum anderen im allgemeinen Bereich des Arbeitsspeichers, außerhalb des Stacks.
Dies erreicht man, indem man die Variable entweder außerhalb von
Funktionskörpern, oder innerhalb unter der Speicherklasse static deklariert:

``` c
int fun(int var) {
    static int var;
}
```

In Bezug auf Funktionen hat `static` eine andere Bedeutung, siehe ebenda.
Ebenfalls im allgemeinen Arbeitsspeicher landen Variablen, deren Speicherort zur
Laufzeit alloziert wird, s.u.

Insbesondere bei eingebetteten Systemen gibt es oft unterschiedliche Bereiche
des allgemeinen Adressbereichs des Arbeitsspeichers, hauptsächlich unterschieden
nach RAM und ROM. Ob eine Variable in direktem Zugriff nur gelesen oder auch
geschrieben werden kann, hängt dann also vom Speicherort ab. Der Speicherort
einer Variable wird hier durch zusätzliche Compiler-Direktiven, Pragmas,
deklariert, deren Syntax sich zwischen den jeweiligen Compilern stark
unterscheidet.

#### Zugriffsverwaltung

### Zeitpunkt der Speicherreservierung

#### Zum Zeitpunkt des Kompilierens

#### Zur Ladezeit

#### Während der Laufzeit

Wenn Speicher für Variablen benötigt wird, z.B. eine skalare Variable mit

``` c
int var;
```

oder eine Feld-Variable mit

``` c
int array[10];
```

deklariert werden, wird auch automatisch Speicher auf dem Stack reserviert.

Wenn jedoch die Größe des benötigten Speichers zum Zeitpunkt des Kompilierens
noch nicht feststeht, muss der Speicher dynamisch reserviert werden.

Dies geschieht meist mit Hilfe der Funktionen `malloc()` oder `calloc()` aus dem
Header `stdlib.h`, der man die Anzahl der benötigten Byte als Parameter
übergibt. Die Funktion gibt danach einen `void`-Zeiger auf den reservierten
Speicherbereich zurück, den man in den gewünschten Typ casten kann. Die Anzahl
der benötigten Bytes für einen Datentyp erhält man mit Hilfe des
`sizeof()`-Operators.

Beispiel:

``` c
int *zeiger;
zeiger = (int * ) malloc(sizeof(*zeiger) * 10);
// Reserviert Speicher für 10 Integer-Variablen
// und lässt 'zeiger' auf den Speicherbereich zeigen.
```

Nach dem `malloc()` sollte man testen, ob der Rückgabewert `NULL` ist. Im
Erfolgsfall wird `malloc()` einen Wert ungleich `NULL` zurückgeben. Sollte der
Wert aber `NULL` sein ist `malloc()` gescheitert und das System hat nicht
genügend Speicher allokieren können. Versucht man, auf diesen Bereich zu
schreiben, hat dies ein undefiniertes Verhalten des Systems zur Folge. Folgendes
Beispiel zeigt, wie man mit Hilfe einer Abfrage diese Falle umgehen kann:

``` c
#include <stdlib.h>
#include <stdio.h>
int *zeiger;

zeiger = (int * ) malloc(sizeof(*zeiger) * 10);           // Speicher anfordern
if (zeiger == NULL) {
    perror("Nicht genug Speicher vorhanden."); // Fehler ausgeben
    exit(EXIT_FAILURE);                        // Programm mit Fehlercode abbrechen
}
free(zeiger);                                  // Speicher wieder freigeben
```

Wenn der Speicher nicht mehr benötigt wird, muss er mit der Funktion `free()`
freigegeben werden, indem man als Parameter den Zeiger auf den Speicherbereich
übergibt.

``` c
free(zeiger); // Gibt den Speicher wieder frei
```

Wichtig: Nach dem `free` steht der Speicher nicht mehr zur Verfügung, und jeder
Zugriff auf diesen Speicher führt zu undefiniertem Verhalten. Dies gilt auch,
wenn man versucht, einen bereits freigegebenen Speicherbereich nochmal
freizugeben. Auch ein `free()` auf einen Speicher, der nicht dynamisch verwaltet
wird, führt zu einem Fehler. Einzig ein `free()` auf einen NULL-Zeiger ist
möglich, da hier der ISO-Standard ISO9899:1999 sagt, dass dieses keine
Auswirkungen haben darf. Siehe dazu folgendes Beispiel:

``` c
int *zeiger;
int *zeiger2;
int *zeiger3;
int array[10];

zeiger = (int * ) malloc(sizeof(*zeiger) * 10);  // Speicher anfordern
zeiger2 = zeiger;
zeiger3 = zeiger++;
free(zeiger);                           // geht noch gut
free(zeiger2);                          // FEHLER: DER BEREICH IST SCHON FREIGEGEBEN
free(zeiger3);                          /* undefiniertes Verhalten, wenn der Bereich
                                           nicht schon freigegeben worden wäre. So ist
                                           es ein FEHLER                             */
free(array);                            // FEHLER: KEIN DYNAMISCHER SPEICHER
free(NULL);                             // KEIN FEHLER, ist laut Standard erlaubt
```

## Verkettete Listen


Beim Programmieren in C kommt man immer wieder zu Punkten, an denen man
feststellt, dass man mit einem Array nicht auskommt. Diese treten zum Beispiel
dann ein, wenn man eine unbekannte Anzahl von Elementen verwalten muss. Mit den
Mitteln, die wir jetzt kennen, könnte man beispielsweise für eine Anzahl an
Elementen Speicher dynamisch anfordern und wenn dieser aufgebraucht ist, einen
neuen größeren Speicher anfordern, den alten Inhalt in den neuen Speicher
schreiben und dann den alten wieder löschen. Klingt beim ersten Hinsehen
ziemlich ineffizient, Speicher allokieren, füllen, neu allokieren, kopieren und
freigeben. Also lassen Sie uns überlegen, wie wir das Verfahren optimieren
können.

**1. Überlegung:**

Wir fordern vom System immer nur Platz für ein Element an. Vorteil: Jedes
Element hat einen eigenen Speicher und wir können jetzt für neue Elemente
einfach einen `malloc` ausführen. Weiterhin sparen wir uns das Kopieren, da
jedes Element von unserem Programm eigenständig behandelt wird. Nachteil: Wir
haben viele Zeiger, die jeweils auf ein Element zeigen und wir können immer noch
nicht beliebig viele Elemente verwalten.

**2. Überlegung:**

Jedes Element ist ein komplexer Datentyp, welcher einen Zeiger enthält, der auf
ein Element gleichen Typs zeigen kann. Vorteil: wir können jedes Element einzeln
allokieren und so die Vorteile der ersten Überlegung nutzen, weiterhin können
wir nun in jedem Element den Zeiger auf das nächste Element zeigen lassen, und
brauchen in unserem Programm nur einen Zeiger auf das erste Element. Somit ist
es möglich, beliebig viele Elemente zur Laufzeit zu verwalten. Nachteil: Wir
können nicht einfach ein Element aus der Kette löschen, da sonst kein Zeiger
mehr auf die nachfolgenden existiert.

### Die einfach verkettete Liste

Die Liste ist das Resultat der beiden Überlegungen, die wir angestellt haben.
Eine einfache Art, eine verkettete Liste zu erzeugen, sieht man im folgenden
Beispielquelltext:

[Online-Compiler ideone:](http://ideone.com/5SEiMi)

``` c
#include <stdio.h>
#include <stdlib.h>

struct element
{
    int value;             // der Wert des Elements
    struct element * next; // Zeiger auf das nächste Element
};

void printliste(const struct element *e)
{
    for( ; e != NULL ; e = e->next )
    {
        printf("%d\n", e->value);
    }
}

void append(struct element **lst, int value)
{
    struct element * neuesElement;

    // Zeiger auf die Einfügeposition ermitteln, d.h. bis zum Ende laufen

    while( *lst != NULL )
    {
        lst = &(* lst)->next;
    }

    neuesElement = malloc(sizeof(*neuesElement)); // erzeuge ein neues Element
    neuesElement->value = value;
    neuesElement->next = NULL; // Wichtig für das Erkennen des Listenendes

    * lst = neuesElement;
}

int main()
{
    struct element * Liste;

    Liste = NULL;      // init. die Liste mit NULL = leere Liste
    append(&Liste, 1); // füge neues Element in die Liste ein
    append(&Liste, 3); // füge neues Element in die Liste ein
    append(&Liste, 2); // füge neues Element in die Liste ein

    printliste(Liste); // zeige alle Elemente der Liste an

    return 0;
}
```
@run

## Fehlerbehandlung

Eine gute Methode, Fehler zu entdecken, ist es, mit dem Präprozessor eine
DEBUG-Konstante zu setzen und in den Code detaillierte Meldungen einzubauen.
Wenn dann alle Fehler beseitigt sind und das Programm zufriedenstellend läuft,
kann man diese Variable wieder entfernen.

Beispiel:

``` c
#define DEBUG

int main(void){
    #ifdef DEBUG
    // führe foo aus (z.B.
    printf("bin gerade hier\n");
    // )
    #endif
    //bar;
    return 0;
}
```
@run

Eine andere Methode besteht darin, `assert()` zu benutzen.

``` c
#include <assert.h>

int main (void)
{
 char * p = NULL;
 // tu was mit p
 ...
 // assert beendet das Programm, wenn die Bedingung FALSE ist
 assert (p != NULL);
 ...
 return 0;
}
```

Das Makro assert ist in der Headerdatei `assert.h` definiert. Dieses Makro dient
dazu, eine Annahme (englisch: assertion) zu überprüfen. Der Programmierer geht
beim Schreiben des Programms davon aus, dass gewisse Annahmen zutreffen (wahr
sind). Sein Programm wird nur dann korrekt funktionieren, wenn diese Annahmen
zur Laufzeit des Programms auch tatsächlich zutreffen. Liefert eine Überprüfung
mittels `assert` den Wert `TRUE`, läuft das Programm normal weiter. Ergibt die
Überprüfung hingegen ein `FALSE`, wird das Programm mit einer Fehlermeldung
angehalten. Die Fehlermeldung beinhaltet den Text "assertion failed" zusammen
mit dem Namen der Quelltextdatei und der Angabe der Zeilennummer.

## Präprozessor

Der Präprozessor ist ein mächtiges und gleichzeitig fehleranfälliges Werkzeug,
um bestimmte Funktionen auf den Code anzuwenden, bevor er vom Compiler
verarbeitet wird.

### Direktiven

Die Anweisungen an den Präprozessor werden als Direktiven bezeichnet. Diese
Direktiven stehen in der Form

``` c
#Direktive Parameter
```

im Code. Sie beginnen mit # und müssen nicht mit einem Semikolon abgeschlossen
werden. Eventuell vorkommende Sonderzeichen in den Parametern müssen nicht
escaped werden.

#### `#include`

Include-Direktiven sind in den Beispielprogrammen bereits vorgekommen. Sie
binden die angegebene Datei in die aktuelle Source-Datei ein. Es gibt zwei Arten
der `#include`-Direktive, nämlich

``` c
#include <Datei.h>
```

und

``` c
 #include "Datei.h"
```

Die erste Anweisung sucht die Datei im Standard-Includeverzeichnis des
Compilers, die zweite Anweisung sucht die Datei zuerst im Verzeichnis, in der
sich die aktuelle Sourcedatei befindet; sollte dort keine Datei mit diesem Namen
vorhanden sein, sucht sie ebenfalls im Standard-Includeverzeichnis.

#### `#define`

Für die #define-Direktive gibt es verschiedene Anweisungen.

Die erste Anwendung besteht im Definieren eines Symbols mit

``` c
#define SYMBOL
```

wobei SYMBOL jeder gültige Bezeichner in C sein kann. Mit den Direktiven
`#ifdef` bzw. `#ifndef` kann geprüft werden, ob diese Symbole definiert wurden.

Die zweite Anwendungsmöglichkeit ist das Definieren einer Konstante mit

``` c
#define KONSTANTE Wert
```

wobei KONSTANTE wieder jeder gültige Bezeichner sein darf und Wert ist der Wert
oder Ausdruck durch den KONSTANTE ersetzt wird. Insbesondere wenn arithmetische
Ausdrücke als Konstante definiert sind, ist die Verwendung einer Klammer sehr
ratsam, z.B.:

``` c
#define ERDBESCHLEUNIGUNG (9.80665)
```

Zwischen dem Namen der Konstante und einer evtl. öffnenden Klammer des Wertes
muss mindestens ein Leerzeichen stehen.

Die dritte Anwendung ist die Definition eines Makros mit

``` c
#define MAKRO(parameter...) Ausdruck
```

wobei MAKRO der Name des Makros ist und Ausdruck den Ersetzungstext für das
Makros darstellt. Die öffnende Klammer für die Parameter muss unmittelbar auf
den Makronamen folgen. Wird das Makro benutzt, werden die konstanten Textteile
des Ausdruckes unverändert übernommen, Vorkommen der Parameter werden durch die
Parameter-Werte des jeweiligen Makro-Aufrufes ersetzt.

Sowohl der Gesamtausdruck als auch alle Vorkommen der Parameter sollten in
Klammern stehen, da sich sonst je nach Umgebung des Makro-Aufrufes eine
unerwartete Rangfolge der Operatoren ergeben kann.

Wird beispielsweise ein Makro `MAX` mit den Parametern `a` und `b` definiert

``` c
#define MAX(a,b) ((a >= b) ? (a) : (b))
```

kann man dieses später verwenden, z.B. mit

``` c
maximum = MAX(5,eingabe);
```

In diesem Fall wird also 5 als aktueller Text für den Parameter `a` angegeben
und eingabe als Text für den Parameter b.

Die Ersetzung ergibt dann

``` c
maximum = ((5 >= eingabe) ? (5) : (eingabe));
```

#### `#undef`

Die Direktive `#undef` löscht ein mit define gesetztes Symbol. Syntax:

``` c
#undef SYMBOL
```

#### `#ifdef`


Mit der `#ifdef`-Direktive kann geprüft werden, ob ein Symbol definiert wurde.
Falls nicht, wird der Code nach der Direktive nicht an den Compiler
weitergegeben. Eine `#ifdef`-Direktive muss durch eine `#endif`-Direktive
abgeschlossen werden.

#### `#ifndef`

Die `#ifndef`-Direktive ist das Gegenstück zur `#ifdef`-Direktive. Sie prüft, ob
ein Symbol nicht definiert ist. Sollte es doch sein, wird der Code nach der
Direktive nicht an den Compiler weitergegeben. Eine `#ifndef`-Direktive muss
ebenfalls durch eine `#endif`-Direktive abgeschlossen werden.

#### `#endif`

Die #endif-Direktive schließt die vorhergehende `#ifdef`-, `#ifndef`-, `#if`- bzw
`#elif`-Direktive ab. Syntax:

``` c
#ifdef SYMBOL
// Code, der nicht an den Compiler weitergegeben wird
#endif

#define SYMBOL
#ifndef SYMBOL
// Wird ebenfalls nicht kompiliert
#endif
#ifdef SYMBOL
// Wird kompiliert
#endif
```

Solche Konstrukte werden häufig verwendet, um Debug-Anweisungen im fertigen
Programm von der Übersetzung auszuschließen oder um mehrere, von außen
gesteuerte, Übersetzungsvarianten zu ermöglichen.

#### `#error`

Die `#error`-Direktive wird verwendet, um den Kompilierungsvorgang mit einer
(optionalen) Fehlermeldung abzubrechen. Syntax:

``` c
#error Fehlermeldung
```

Die Fehlermeldung muss nicht in Anführungszeichen stehen.

Diese Fehlermeldung wird beim Compilieren des Programmes, sofern der Fehler
zutrift, im Fehlerausgabefenster ausgegeben.

#### `#if`

Mit `#if` kann ähnlich wie mit `#ifdef` eine bedingte Übersetzung eingeleitet
werden, jedoch können hier konstante Ausdrücke ausgewertet werden.

Beispiel:

``` c
#if (DEBUGLEVEL >= 1)
#  define print1 printf
#else
#  define print1(...) (0)
#endif

#if (DEBUGLEVEL >= 2)
#  define print2 printf
#else
#  define print2(...) (0)
#endif
```

Hier wird abhängig vom Wert der Präprozessorkonstante `DEBUGLEVEL` definiert,
was beim Aufruf von `print2()` oder `print1()` passiert.

Der Präprozessorausdruck innerhalb der Bedingung folgt den gleichen Regeln wie
Ausdrücke in C, jedoch muss das Ergebnis zum Übersetzungszeitpunkt bekannt sein.

#### `defined`

`defined` ist ein unärer Operator, der in den Ausdrücken der `#if` und `#elif`
Direktiven eingesetzt werden kann.

Beispiel:

``` c
#define FOO
#if defined FOO || defined BAR
#error "FOO oder BAR ist definiert"
#endif
```

Die genaue Syntax ist

``` c
defined SYMBOL
```

Ist das Symbol definiert, so liefert der Operator den Wert 1, anderenfalls den
Wert 0.

#### `#elif`

Ähnlich wie in einem `else`-`if` Konstrukt kann mit Hilfe von `#elif` etwas in
Abhängigkeit einer früheren Auswahl definiert werden. Der folgende Abschnitt
verdeutlicht das.

``` c
#define BAR
#ifdef FOO
#error "FOO ist definiert"
#elif defined BAR
#error "BAR ist definiert"
#else
#error "hier ist nichts definiert"
#endif
```

Der Compiler würde hier BAR ist definiert ausgeben.

#### `#else`

Beispiel:

``` c
#ifdef FOO
#error "FOO ist definiert"
#else
#error "FOO ist nicht definiert"
#endif
```

`#else` dient dazu, allen sonstigen nicht durch `#ifdef` oder `#ifndef`
abgefangenen Fälle einen Bereich zu bieten.

#### `#pragma`

Bei den `#pragma` Anweisungen handelt es sich um compilerspezifische
Erweiterungen der Sprache C. Diese Anweisungen steuern meist die
Codegenerierung. Sie sind aber zu sehr von den Möglichkeiten des jeweiligen
Compilers abhängig, als dass man hierzu eine allgemeine Aussage treffen kann.
Wenn Interesse an diesen Schaltern besteht, sollte man deshalb in die
Dokumentation des Compilers sehen oder sekundäre Literatur verwenden, die sich
speziell mit diesem Compiler beschäftigt.


## Dateien


In diesem Kapitel geht es um das Thema _Dateien_. Aufgrund der einfachen API
stellen wir zunächst die Funktionen rund um Streams vor, mit deren Hilfe Dateien
geschrieben und gelesen werden können. Anschließend folgt eine kurze
Beschreibung der Funktionen rund um Dateideskriptoren.

### Streams

Die Funktion `fopen` dient dazu, einen Datenstrom (Stream) zu öffnen.
Datenströme sind Verallgemeinerungen von Dateien. Die Syntax dieser Funktion
lautet:

``` c
 FILE *fopen (const char *Pfad, const char *Modus);
```

Der Pfad ist der Dateiname, der Modus darf wie folgt gesetzt werden:

* `r` -  Datei nur zum Lesen öffnen (READ)
* `w` -  Datei nur zum Schreiben öffnen (WRITE), löscht den Inhalt der Datei,
         wenn sie bereits existiert
* `a` -  Daten an das Ende der Datei anhängen (APPEND), die Datei wird
         nötigenfalls angelegt
* `r+` - Datei zum Lesen und Schreiben öffnen, die Datei muss bereits existieren
* `w+` - Datei zum Lesen und Schreiben öffnen, die Datei wird nötigenfalls angelegt
* `a+` - Datei zum Lesen und Schreiben öffnen, um Daten an das Ende der Datei
         anzuhängen, die Datei wird nötigenfalls angelegt

Es gibt noch einen weiteren Modus():

* `b` -  Binärmodus (anzuhängen an die obigen Modi, z.B. "`rb`" oder "`w+b`").

Ohne die Angabe von `b` werden die Daten im sog. Textmodus gelesen und
geschrieben, was dazu führt, dass unter bestimmten Systemen bestimmte Zeichen
bzw. Zeichenfolgen interpretiert werden. Unter Windows z.B. wird die
Zeichenfolge "`\r\n`" als Zeilenumbruch übersetzt. Um dieses zu verhindern, muss
die Datei im Binärmodus geöffnet werden. Unter Systemen, die keinen Unterschied
zwischen Text- und Binärmodus machen (wie zum Beispiel bei Unix, GNU/Linux), hat
das b keine Auswirkungen.

Die Funktion `fopen` gibt `NULL` zurück, wenn der Datenstrom nicht geöffnet
werden konnte, ansonsten einen Zeiger vom Typ `FILE` auf den Datenstrom.


Die Funktion `fclose` dient dazu, die mit der Funktion `fopen` geöffneten
Datenströme wieder zu schließen. Die Syntax dieser Funktion lautet:

``` c
int fclose (FILE *datei);
```

Alle nicht geschriebenen Daten des Stromes `*datei` werden gespeichert, alle
ungelesenen Eingabepuffer geleert, der automatisch zugewiesene Puffer wird
befreit und der Datenstrom `*datei` geschlossen. Der Rückgabewert der Funktion
ist `EOF`, falls Fehler aufgetreten sind, ansonsten ist er 0 (Null).

#### Dateien zum Schreiben öffnen

``` c
#include <stdio.h>
int main (void)
{
  FILE * datei;
  datei = fopen ("testdatei.txt", "w");
  if (datei == NULL)
  {
    printf("Fehler beim oeffnen der Datei.");
    return 1;
  }
  fprintf (datei, "Hallo, Welt\n");
  fclose (datei);
  return 0;
}
```

Der Inhalt der Datei `testdatei.txt` ist nun:

```
Hallo, Welt
```

Die Funktion `fprintf` funktioniert genauso, wie die schon bekannte Funktion
`printf`. Lediglich das erste Argument muss ein Zeiger auf den Dateistrom sein.


#### Dateien zum Lesen öffnen

Nachdem wir nun etwas in eine Datei hineingeschrieben haben, versuchen wir in
unserem zweiten Programm dieses einmal wieder herauszulesen:

``` c
#include <stdio.h>

int main()
{
  FILE * datei;
  char text[100+1];

  datei = fopen("testdatei.txt", "r");
  if (datei != NULL) {
    fscanf(datei, "%s", text);  // %c: einzelnes Zeichen %s: Zeichenkette
    // String muss mit Nullbyte abgeschlossen sein
    text[100] = '\0';
    printf("%s\n", text);
    fclose(datei);
  }
  return 0;
}
```

Die Ausgabe des Programmes ist wie erwartet

```
Hallo, Welt
```

`fscanf` ist das Pendant zu `scanf`.


#### Positionen innerhalb von Dateien

Stellen wir uns einmal eine Datei vor, die viele Datensätze eines bestimmten
Types beinhaltet, z.B. eine Adressdatei. Wollen wir nun die 4. Adresse ausgeben,
so ist es praktisch, an den Ort der 4. Adresse innerhalb der Datei zu springen
und diesen auszulesen. Um das folgende Beispiel nicht zu lang werden zu lassen,
beschränken wir uns auf Name und Postleitzahl.

``` c
#include <stdio.h>
#include <string.h>

/* Die Adressen-Datenstruktur */
typedef struct _adresse
{
  char name[100];
  int plz; // Postleitzahl
} adresse;

/* Erzeuge ein Adressen-Record */
void mache_adresse (adresse *a, const char *name, const int plz)
{
  sprintf(a->name, "%.99s", name);
  a->plz = plz;
}

int main (void)
{
  FILE * datei;
  adresse addr;

  // Datei erzeugen im Binärmodus, ansonsten kann es Probleme
  // unter Windows geben, siehe Anmerkungen bei '''fopen()'''
  datei = fopen ("testdatei.dat", "wb");

  if (datei != NULL)
    {
      mache_adresse (&addr, "Erika Mustermann", 12345);
      fwrite (&addr, sizeof (adresse), 1, datei);
      mache_adresse (&addr, "Hans Müller", 54321);
      fwrite (&addr, sizeof (adresse), 1, datei);
      mache_adresse (&addr, "Secret Services", 700);
      fwrite (&addr, sizeof (adresse), 1, datei);
      mache_adresse (&addr, "Peter Mustermann", 12345);
      fwrite (&addr, sizeof (adresse), 1, datei);
      mache_adresse (&addr, "Wikibook Nutzer", 99999);
      fwrite (&addr, sizeof (adresse), 1, datei);
      fclose (datei);
    }

  // Datei zum Lesen öffnen - Binärmodus
  datei = fopen ("testdatei.dat", "rb");
  if (datei != NULL)
    {
      // Hole den 4. Datensatz
      fseek(datei, 3 * sizeof (adresse), SEEK_SET);
      fread (&addr, sizeof (adresse), 1, datei);
      printf ("Name: %s (%d)\n", addr.name, addr.plz);
      fclose (datei);
    }
  return 0;
}
```

Um einen Datensatz zu speichern bzw. zu lesen, bedienen wir uns der Funktionen
`fwrite` und `fread`, welche die folgende Syntax haben:

``` c
size_t fread  (void *daten, size_t groesse, size_t anzahl, FILE *datei);
size_t fwrite (const void *daten, size_t groesse, size_t anzahl, FILE *datei);
```

Beide Funktionen geben die Anzahl der geschriebenen / gelesenen Zeichen zurück.
Die `groesse` ist jeweils die Größe eines einzelnen Datensatzes. Es können
`anzahl` Datensätze auf einmal geschrieben werden. Beachten Sie, dass sich der
Zeiger auf den Dateistrom bei beiden Funktionen am Ende der Argumentenliste
befindet.

Um nun an den 4. Datensatz zu gelangen, benutzen wir die Funktion `fseek`:

``` c
int fseek (FILE *datei, long offset, int von_wo);
```

Diese Funktion gibt 0 zurück, wenn es zu keinem Fehler kommt. Der Offset ist der
Ort, dessen Position angefahren werden soll. Diese Position kann mit dem
Parameter von_wo beeinflusst werden:

* `SEEK_SET` - Positioniere relativ zum Dateianfang,
* `SEEK_CUR` - Positioniere relativ zur aktuellen Dateiposition und
* `SEEK_END` - Positioniere relativ zum Dateiende.

Man sollte jedoch beachten: wenn man mit dieser Funktion eine Position in einem
Textstrom anfahren will, so muss man als Offset 0 oder einen Rückgabewert der
Funktion `ftell` angeben (in diesem Fall muss der Wert von von_wo `SEEK_SET`
sein).

#### Besondere Streams

Neben den Streams, die Sie selbst erzeugen können, gibt es schon vordefinierte:

* `stdin`  - Die Standardeingabe (typischerweise die Tastatur)
* `stdout` - Standardausgabe (typischerweise der Bildschirm)
* `stderr` - Standardfehlerkanal (typischerweise ebenfalls Bildschirm)

Diese Streams brauchen nicht geöffnet oder geschlossen zu werden. Sie sind
"einfach schon da".

``` c
...
fprintf (stderr, "Fehler: Etwas schlimmes ist passiert\n");
...
```

Wir hätten also auch unsere obigen Beispiele statt mit `printf` mit `fprintf`
schreiben können.

### Echte Dateien

Mit "echten Dateien" bezeichnen wir die API rund um Dateideskriptoren. Hier
passiert ein physischer Zugriff auf Geräte. Diese API eignet sich auch dazu,
Informationen über angeschlossene Netzwerke zu übermitteln.

#### Dateiausdruck

Das folgende Beispiel erzeugt eine Datei und gibt anschließend den Dateiinhalt
oktal, dezimal, hexadezimal und als Zeichen wieder aus. Es soll Ihnen einen
Überblick verschaffen über die typischen Dateioperationen: öffnen, lesen,
schreiben und schließen.

``` c
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

int main (void)
{
  int fd;
  char ret;
  const char * s = "Test-Text 0123\n";

  // Zum Schreiben öffnen
  fd = open ("testfile.txt", O_WRONLY|O_CREAT|O_TRUNC, S_IRUSR|S_IWUSR);
  if (fd == -1)
    exit (-1);
  write (fd, s, strlen (s));
  close (fd);

  // Zum Lesen öffnen
  fd = open ("testfile.txt", O_RDONLY);
  if (fd == -1)
     exit (-1);

  printf ("Oktal\tDezimal\tHexadezimal\tZeichen\n");
  while (read (fd, &ret, sizeof (char)) > 0)
    printf ("%o\t%u\t%x\t\t%c\n", ret, ret, ret, ret);
  close (fd);

 return 0;
}
```

Die Ausgabe des Programms ist wie folgt:

```
Oktal   Dezimal Hexadezimal     Zeichen
124     84      54                    T
145     101     65                    e
163     115     73                    s
164     116     74                    t
55      45      2d                    -
124     84      54                    T
145     101     65                    e
170     120     78                    x
164     116     74                    t
40      32      20
60      48      30                    0
61      49      31                    1
62      50      32                    2
63      51      33                    3
12      10      a
```

Mit `open` erzeugen (`O_CREAT`) wir zuerst eine Datei zum Schreiben
(`O_WRONLY`). Wenn diese Datei schon existiert, so soll sie geleert werden
(`O_TRUNC`). Derjenige Benutzer, der diese Datei anlegt, soll sie lesen
(`S_IRUSR`) und beschreiben (`S_IWUSR`) dürfen. Der Rückgabewert dieser Funktion
ist der Dateideskriptor, eine positive ganze Zahl, wenn das Öffnen erfolgreich
war. Sonst ist der Rückgabewert -1.

In diese so erzeugte Datei können wir schreiben:

``` c
ssize_t write (int dateideskriptor, const void *buffer, size_t groesse);
```

Diese Funktion gibt die Anzahl der geschriebenen Zeichen zurück. Sie erwartet
den Dateideskriptor, einen Zeiger auf einen zu schreibenden Speicherbereich und
die Anzahl der zu schreibenden Zeichen.

Der zweite Aufruf von `open` öffnet die Datei zum Lesen (`O_RDONLY`). Bitte
beachten Sie, dass der dritte Parameter der `open`-Funktion hier weggelassen
werden darf.

Die Funktion `read` erledigt für uns das Lesen:

``` c
ssize_t read (int dateideskriptor, void *buffer, size_t groesse);
```

Die Parameter sind dieselben wie bei der Funktion `write`. `read` gibt die
Anzahl der gelesenen Zeichen zurück.

### Streams und Dateien

In einigen Fällen kommt es vor, dass man - was im allgemeinen keine gute Idee
ist - die API der Dateideskriptoren mit der von Streams mischen muss. Hierzu
dient die Funktion:

``` c
FILE *fdopen (int dateideskriptor, const char * Modus);
```

`fdopen` öffnet eine Datei als Stream, sofern ihr Dateideskriptor vorliegt und
der Modus zu den bei `open` angegebenen Modi kompatibel ist.

## Rekursion

Eine Funktion, die sich selbst aufruft, wird als rekursive Funktion bezeichnet.
Den Aufruf selbst nennt man Rekursion. Als Beispiel dient die
Fakultäts-Funktion $n!$, die sich rekursiv als $n(n-1)!$ definieren lässt (wobei
$0! = 1$).

Hier ein Beispiel dazu in C:

``` c
#include <stdio.h>

int fakultaet (int a)
{
  if (a == 0)
    return 1;
  else
    return (a * fakultaet(a-1));
}

int main()
{
  int eingabe;

  printf("Ganze Zahl eingeben: ");
  scanf("%d",&eingabe);
  printf("Fakultaet der Zahl: %d\n",fakultaet(eingabe));

  return 0;
}
```
```bash stdin
12
```
@run_stdin

### Beseitigung der Rekursion

Rekursive Funktionen sind in der Regel leichter lesbar als ihre iterativen
Gegenstücke. Sie haben aber den Nachteil, dass für jeden Funktionsaufruf
verhältnismäßig hohe Kosten anfallen. Eine effiziente Programmierung in C
erfordert also die Beseitigung jeglicher Rekursion. Am oben gewählten Beispiel
der Fakultät könnte eine rekursionsfreie Variante wie folgt definiert werden:

``` c
int fak_iter(int n)
{
  int i, fak;
  for (i=1, fak=1; i<=n; i++)
    fak *= i;
  return fak;
}
```

Diese Funktion liefert genau die gleichen Ergebnisse wie die obige, allerdings
wurde die Rekursion durch eine Iteration ersetzt. Offensichtlich kommt es
innerhalb der Funktion zu keinem weiteren Aufruf, was die Laufzeit des
Algorithmus erheblich verkürzen sollte. Komplexere Algorithmen - etwa Quicksort -
können nicht so einfach iterativ implementiert werden. Das liegt an der Art der
Rekursion, die es bei Quicksort notwendig macht, einen Stack für die
Zwischenergebnisse zu verwenden. Eine so optimierte Variante kann allerdings zu
einer Laufzeitverbesserung von 25-30% führen.

### Weitere Beispiele für Rekursion

Die  Potenzfunktion "y = x hoch n" soll berechnet werden:

``` c
#include <stdio.h>

int potenz(int x, int n)
{
  if (n>0)
    return (x*potenz(x,--n));  // rekursiver Aufruf
  else
    return (1);
}

int main(void)
{
  int x;
  int n;
  int wert;

  printf("\nGib x ein: ");
  scanf("%d",&x);
  printf("\nGib n ein: \n");
  scanf("%d",&n);

  if(n<0)
  {
    printf("Exponent muss positiv sein!\n");
    return 1;
  }
  else
  {
    wert=potenz(x,n);
    printf("Funktionswert: %d\n",wert);
    return 0;
  }
}
```
``` bash stdin
3
4
```
@run_stdin

Multiplizieren von zwei Zahlen als Ausschnitt:

``` c
int multiply(int a, int b)
{
  if (b==0) return 0;
  return a + multiply(a,b-1);
}
```


## Programmierstil

Ein gewisser Programmierstil ist notwendig, um anderen Programmierern das Lesen
des Quelltextes nicht unnötig zu erschweren und um seinen eigenen Code auch nach
langer Zeit noch zu verstehen.

Außerdem zwingt man sich durch einen gewissen Stil selbst zum sauberen
Programmieren, was die Wartung des Codes vereinfacht.

### Kommentare

Grundsätzlich sollten alle Stellen im Code, die nicht selbsterklärend sind,
bestimmtes Vorwissen erfordern oder für andere Stellen im Quelltext kritisch
sind, kommentiert werden. Kommentare sollten sich jedoch nur darauf beschränken,
zu erklären, WAS eine Funktion macht, und NICHT WIE es gemacht wird.

Eine gute Regel lautet: Kann man die Funktionalität mit Hilfe des Quelltextes
klar formulieren so sollte man es auch tun, ansonsten muss es mit einem
Kommentar erklärt werden. Im Englischen lautet die Regel: If you can say it with
code, code it, else comment.

### Globale Variablen

Globale Variablen sollten vermieden werden, da sie ein Programm sehr anfällig
für Fehler machen und schnell zum unsauberen Programmieren verleiten.

Wird eine Variable von mehreren Funktionen innerhalb derselben Datei verwendet,
ist es hilfreich, diese Variable als `static` zu markieren, so dass sie nicht im
globalen Namensraum auftaucht.

### Namensgebung

Es gibt viele verschiedene Wege, die man bei der Namensgebung von Variablen,
Konstanten, Funktionen usw. beschreiten kann. Zu beachten ist jedenfalls, dass
man, egal welches System man verwendet (z.B. Variablen immer klein schreiben und
ihnen den Typ als Abkürzung voranstellen und Funktionen mit Großbuchstaben
beginnen und zwei Wörter mit Großbuchstaben trennen oder den Unterstrich
verwenden), konsequent dabei bleibt. Bei der Sprache, die man für die
Bezeichnungen wählt, sei aber etwas angemerkt. Wenn man Open-Source
programmieren will, so bietet es sich meist eher an, englische Bezeichnungen zu
wählen; ist man aber in einem Team von deutschsprachigen Entwicklern, so wäre
wohl die Muttersprache die bessere Wahl. Aber auch hier gilt: Egal was man
wählt, man sollte nach der Entscheidung konsequent bleiben.

Da sich alle globalen Funktionen und Variablen einen Namensraum teilen, macht es
Sinn, etwa durch Voranstellen des Modulnamens vor den Symbolnamen Eindeutigkeit
sicherzustellen. In vielen Fällen lassen sich globale Symbole auch vermeiden,
wenn man stattdessen statische Symbole verwendet.

Es sei jedoch angemerkt, dass es meistens nicht sinnvoll ist, Variablen mit nur
einem Buchstaben zu verwenden. Es sei denn, es hat sich dieser Buchstabe bereits
als Bezeichner in einem Bereich etabliert. Ein Beispiel dafür ist die Variable
`i` als Schleifenzähler oder `e`, wenn die Eulersche Zahl gebraucht wird. Code
ist sehr schlecht zu warten wenn man erstmal suchen muss, welchen Sinn z.B. a
hat.

Verbreitete Bezeichner sind:


| `h`, `i`, `j`, `k` | Laufvariablen in Schleifen (`i`: index)                |
| `w`, `x`, `y`, `z` | Zeilen, Spalten, usw. einer Matrix                     |
| `r`, `s`, `t`      | Zeiger auf Zeichenketten                               |
| `rv`               | Rückgabewert (return value)                            |
| `sp`               | Stack Pointer bei Array                                |
| `cnt`              | Zählervariable                                         |
| `tmp`              | Variable, die nur sehr kurz verwendet wird (temporary) |

### Gestaltung des Codes

Verschiedene Menschen gestalten ihren Code unterschiedlich. Die Einen bevorzugen
z.B. bei einer Funktion folgendes Aussehen:

``` c
int funk(int a){
    return 2 * a;
}
```

andere wiederum würden diese Funktion eher so

``` c
int funk (int a)
{
  return 2 * a;
}
```

schreiben. Es gibt vermutlich so viele unterschiedliche Schreibweisen von
Programmen, wie es programmierende Menschen gibt und sicher ist der Eine oder
Andere etwas religiös gegenüber der Platzierung einzelner Leerzeichen. Innerhalb
von Teams haben sich besondere Vorlieben herauskristallisiert, wie Code
auszusehen hat. Um zwischen verschiedenen Gestaltungen des Codes wechseln zu
können, gibt es Quelltextformatierer, wie z.B.: GNU indent, Artistic Style und
eine grafische Oberfläche UniversalIndentGUI, die sie bequem benutzen lässt.

### Standard-Funktionen und System-Erweiterungen

Sollte man beim Lösen eines Problem nicht allein mit dem auskommen, was durch
den C-Standard erreicht werden kann, ist es sinnvoll die systemspezifischen
Teile des Codes in eigene Funktionen und Header zu packen. Dieses macht es
leichter den Code auf einem anderen System zu reimplementieren, weil nur die
Funktionalität im systemspezifischen Code ausgetauscht werden muss.


## Sicherheit

Wenn man einmal die Grundlagen der C-Programmierung verstanden hat, sollte man
mal eine kleine Pause machen. Denn an diesen Punkt werden Sie sicher ihre ersten
Programme schreiben wollen, die nicht nur dem Erlernen der Sprache C dienen,
sondern Sie wollen für sich und vielleicht auch für andere Werkzeuge erstellen,
mit denen sich die Arbeit erleichtern lässt. Doch Vorsicht, bis jetzt wurden die
Programme von ihnen immer nur so genutzt, wie Sie es dachten.

Wenn Sie so genannten Produktivcode schreiben wollen, sollten Sie davon
ausgehen, dass dies nicht länger der Fall sein wird. Es wird immer mal einen
Benutzer geben, der nicht das eingibt, was Sie dachten oder der versucht, eine
längere Zeichenkette zu verarbeiten, als Sie es bei ihrer Überlegung angenommen
haben. Deshalb sollten Sie spätestens jetzt ihr Programm durch eine Reihe von
Verhaltensmustern schützen, so gut es geht.

### Der Compiler ist dein Freund

Viele ignorieren die Warnungen, die der Compiler ausgibt, oder haben sie gar
nicht angeschaltet. Frei nach dem Motto "solange es kein Fehler ist". Dies ist
mehr als kurzsichtig. Mit Warnungen will der Compiler uns mitteilen, dass wir
gerade auf dem Weg in die Katastrophe sind. Also gleich von Beginn an den
Warnungen nachgehen und dafür sorgen, dass diese nicht mehr erscheinen. Wenn
sich die Warnungen in einem ganz speziellen Fall nicht beseitigen lassen, ist es
selbstverständlich, dass man dem Projekt eine Erklärung beilegt, die ganz genau
erklärt, woher die Warnung kommt, warum man diese nicht umgehen kann und es ist
zu beweisen, dass die Warnung unter keinen Umständen zu einem Programmversagen
führen wird. Also im Klartext: "Ist halt so" ist keine Begründung.

Wenn Sie ihre Programme mit dem GNU C Compiler schreiben, sollten Sie dem
Compiler mindestens diese Argumente mitgeben, um viele sinnvolle Warnungen zu
sehen:

```
gcc -Wall -W -Wstrict-prototypes -O
```

Auch viele andere Compiler können sinnvolle Warnungen ausgeben, wenn Sie ihnen
die entsprechenden Argumente mitgeben.

### Zeiger und der Speicher

Zeiger sind in C ohne Zweifel eine mächtige Waffe, aber Achtung! Es gibt eine
Menge Programme, bei denen es zu sogenannten Pufferüberläufen (Buffer Overflows)
gekommen ist, weil der Programmierer sich nicht der Gefahr von Zeigern bewusst
war. Wenn Sie also mit Zeigern hantieren, nutzen Sie die Kontrollmöglichkeiten.
`malloc()` oder `fopen()` geben im Fehlerfall z.B. `NULL` zurück. Testen Sie
also, ob das Ergebis `NULL` ist und/oder nutzen Sie andere Kontrollen, um zu
überprüfen, ob Ihre Zeiger auf gültige Inhalte zeigen.

### Strings in C

Wie Sie vielleicht wissen, sind Strings in C nichts anderes als ein Array von
`char`. Das hat zur Konsequenz, dass es bei Stringoperationen besonders oft zu
Pufferüberläufen kommt, weil der Programmierer einfach nicht mit überlangen
Strings gerechnet hat. Vermeiden Sie dies, indem Sie nur die Funktionen
verwenden, welche die Länge des Zielstrings überwachen:

* `snprintf` statt `sprintf`
* bei `scanf/sscanf` den `width`-Spezifizierer benutzen

Lesen Sie sich unbedingt die Dokumentation durch, die zusammen mit diesen
Funktionen ausgeliefert wird. Überlegen Sie sich auch, was im Falle von zu
langen Strings passieren soll. Falls der String nämlich später benutzt wird, um
eine Datei zu löschen, könnte es leicht passieren, dass eine falsche Datei
gelöscht wird.


### Das Problem der Reellen Zahlen (Floating Points)

Auch wenn es im C-Standard die Typen "`float`" und "`double`" gibt, so sind
diese nur bedingt einsatzfähig. Durch die interne Darstellung einer
Floatingpointzahl auf eine fest definierte Anzahl von Bytes in
Exponentialschreibweise, kann es bei diesen Datentypen schnell zu
Rundungsfehlern kommen, insbesondere sind davon Gleichheitsoperationen
(`==`,`!=`,`<=`,`>=`)
betroffen, die Ergebnisse sind dabei oft überraschend. Deshalb sollten Sie in
ihren Projekten überlegen ob Sie nicht die Float-Berechnungen durch
Integerdatentypen ersetzen können, um eine bessere Genauigkeit zu erhalten. So
kann beispielsweise bei finanzmathematischen Programmen, welche cent- oder
zehntelcentgenau rechnen, oft der größtmögliche Integerdatentyp
(C89: `long int`/`unsigned long int`; C99 `intmax_t`/`uintmax_t`) benutzt
werden. Auch hierbei sind aber Überläufe/Unterläufe zu beachten und
auszuschließen.

### Die Eingabe von Werten

Falls Sie eine Eingabe erwarten, gehen Sie immer vom Schlimmsten aus. Vermeiden
Sie, einen Wert vom Benutzer ohne Überprüfung zu verwenden. Denn wenn Sie zum
Beispiel eine Zahl erwarten, und der Benutzer gibt einen Buchstaben ein, sind
meist Ihre daraus folgenden Berechnungen Blödsinn. Also besser erst als
Zeichenkette einlesen, dann auf Gültigkeit prüfen und erst dann in den benötigen
Typ umwandeln. Auch das Lesen von Strings sollten Sie überdenken: Zum Beispiel
prüft der folgende Aufruf die Länge **nicht**!

``` c
char str[10];
scanf("%s",str);
```

Wenn jetzt der Bereich `str` nicht lang genug für die Eingabe ist, haben Sie
einen Pufferüberlauf. Abhilfe schafft hier die Verwendung des
`width`-Spezifizierers:

``` c
char str[10];
scanf("%9s",str);
```

Hier werden maximal 9 Zeichen eingelesen, da am Ende noch das `Null`-Zeichen
angehängt werden muss.

### Magic Numbers sind böse

Wenn Sie ein Programm schreiben und dort Berechnungen anstellen oder Register
setzen, sollten Sie es vermeiden, dort direkt mit Zahlen zu arbeiten. Nutzen Sie
besser die Möglichkeiten von Defines oder Konstanten, die mit sinnvollen Namen
ausgestattet sind. Denn nach ein paar Monaten können selbst Sie nicht mehr
sagen, was die Zahl in Ihrer Formel sollte. Hierzu ein kleines Beispiel:

``` c
x=z*9.81;    // schlecht: man kann vielleicht ahnen was der Programmierer will
F=m*9.81;    /* besser: wir können jetzt an der Formel vielleicht schon
                        erkennen: es geht um Kraftberechnung */
#define GRAVITY 9.81
F=m*GRAVITY; // am besten: jeder kann jetzt sofort sagen worum es geht
```

Auch wenn Sie Register haben, die mit ihren Bits irgendwelche Hardware steuern,
sollten Sie statt den Magic Numbers einfach einen Header schreiben, welcher über
defines den einzelnen Bits eine Bedeutung gibt, und dann über das binäre ODER
eine Maske schaffen die ihre Ansteuerung enthält, hierzu ein Beispiel:

``` c
counters= 0x74;  // Schlecht
counters= COUNTER1 | BIN_COUNTER | COUNTDOWN | RATE_GEN ; // Besser
```

Beide Zeilen machen auf einem fiktiven Mikrocontroller das gleiche, aber für den
Code in Zeile 1 müsste ein Programmierer erstmal die Dokumentation des Projekts,
wahrscheinlich sogar die des Mikrocontroller lesen, um die Zählrichtung zu
ändern. In der Zeile 2 weiß jeder, dass das `COUNTDOWN` geändert werden muss,
und wenn der Entwickler des Headers gut gearbeitet hat, ist auch ein `COUNTUP`
bereits definiert.

### Die Zufallszahlen

„Gott würfelt nicht“ soll Einstein gesagt haben; vielleicht hatte er recht, aber
sicher ist, der Computer würfelt auch nicht. Ein Computer erzeugt Zufallszahlen,
indem ein Algorithmus Zahlen ausrechnet, die - mehr oder weniger - zufällig
verteilt (d.h. zufällig groß) sind. Diese nennt man Pseudozufallszahlen. Die
Funktion `rand()` aus der `stdlib.h` ist ein Beispiel dafür. Für einfache
Anwendungen mag `rand()` ausreichen, allerdings ist der verwendete Algorithmus
nicht besonders gut, so dass die hiermit erzeugten Zufallszahlen einige
schlechte statistische Eigenschaften aufweisen. Eine Anwendung ist etwa in
Kryptografie oder Monte-Carlo-Simulationen nicht vertretbar. Hier sollten
bessere Zufallszahlengeneratoren eingesetzt werden. Passende Algorithmen finden
sich in der GNU scientific library[^1] oder in Numerical Recipes[^2] (C Version
frei zugänglich[^3]).

[^1]: http://www.gnu.org/software/gsl
[^2]: http://nr.com
[^3]: http://www.nrbook.com/a/bookcpdf.php

### Undefiniertes Verhalten

Es gibt einige Funktionen, die in gewissen Situationen ein undefiniertes
Verhalten an den Tag legen. Das heißt, Sie wissen in der Praxis dann nicht, was
passieren wird: Es kann passieren, dass das Programm bis in alle Ewigkeit läuft –
oder auch nicht. Meiden Sie undefiniertes Verhalten! Sie begeben sich sonst in
die Hand des Compilers und was dieser daraus macht. Auch ein "bei mir läuft das
aber" ist keine Erlaubnis, mit diesen Schmutzeffekten zu arbeiten. Das
undefinierte Verhalten zu nutzen grenzt an Sabotage.

### `return`-Statement fehlt

Wenn für eine Funktion zwar ein Rückgabewert angegeben wurde, jedoch ohne
return-Statement endet, gibt der Compiler bei Standardeinstellung keinen Fehler
aus. Problematisch an diesem Zustand ist, dass eine solche Funktion in diesem
Fall eine zufällige, nicht festgelegte Zahl zurück gibt. Abhilfe schafft nur ein
höheres Warning-Level (siehe [Der Compiler ist dein Freund](#163)) bzw. explizit
diese Warnungen mit dem Parameter -Wreturn-type einzuschalten.

### Wartung des Codes

Ein Programm ist ein technisches Produkt, und wie alle anderen technischen
Produkte sollte es wartungsfreundlich sein. So dass Sie oder Ihr Nachfolger in
der Lage sind, sich schnell wieder in das Progamm einzuarbeiten. Um das zu
erreichen, sollten Sie sich einen einfach zu verstehenden
[Programmierstil](#156) für das Projekt suchen und sich selbst dann an den Stil
halten, wenn ein anderer ihn verbrochen hat. Beim Linux-Kernel werden auch gute
Patches abgelehnt, weil sie sich z.B. nicht an die Einrücktiefe gehalten haben.

### Wartung der Kommentare

Auch wenn es trivial erscheinen mag, wenn Sie ein Quellcode ändern, vergessen
Sie nicht den Kommentar. Man könnte argumentieren, dass der Kommentar ein Teil
Ihres Programms ist und so auch einer Wartung unterzogen werden sollte, wie der
Code selbst. Aber die Wahrheit ist eigentlich viel einfacher; ein Kommentar, der
von der Programmierung abweicht, sorgt bei dem Nächsten, der das Programm ändern
muss, erstmal für große Fragezeichen im Kopf. Denn wie wir im Kapitel
Programmierstil besprochen haben, soll der Kommentar helfen, die Inhalte des so
genannten Fachkonzeptes zu verstehen und dieser Prozess dauert dann viel länger,
als mit den richtigen Kommentaren.

### Weitere Informationen

Ausführlich werden die Fallstricke in C und die dadurch möglichen
Sicherheitsprobleme im _CERT C Secure Coding Standard_ dargestellt [^4]. Er
besteht aus einem Satz von Regeln und Empfehlungen, die bei der Programmierung
beachtet werden sollten.

[^4]: https://www.securecoding.cert.org/confluence/display/seccode/CERT+C+Secure+Coding+Standard

## Komplexe Zahlen

Seit der Verabschiedung des C99 Standards gibt es die Möglichkeit, direkt mit
komplexen Zahlen in C zu arbeiten. Zur Verfügung stehen einem die verschiedenen
Darstellungsformen und mathematische Operationen. In diesem Abschnitt werden die
verschiedenen Möglichkeiten gezeigt, mit denen komplexe Zahlen ein- und
ausgegeben werden können.

### Kartesische-Form

Im folgendem Beispiel wird eine komplexe Zahl definiert und ausgegeben.

``` c
#include <stdio.h>
#include <complex.h>

int main()
{
   double complex z = 3 + 4*I;
   printf("%f + %f*i\n", creal(z), cimag(z));

   return 1;
}
```
@run

```
3.000000 + 4.000000 * i
```

Um im Quelltext Real- von Imaginärteil zu unterscheiden, wird das Makro `I` mit
dem Imaginärteil multipliziert. Dieses verhält sich wie bei der mathematischen
Schreibweise, bei der ebenfalls ein `j` oder `i` mit dem Imaginärteil
multipliziert wird. Bei der Ausgabe in Zeile 7 werden zunächst der Real- und
Imaginärteil der komplexen Zahl bestimmt, um diese dann als normale
`double`-Werte auszugeben.

### Polarform

$$ z=5\cdot e^{\mathrm {i} \pi \over 2}=0+5\mathrm {i}$$


Online-Compiler ideone

``` c
#include <stdio.h>
#include <math.h>
#include <complex.h>

#ifndef M_PI_2
#define M_PI_2 (3.1415927/2)
#endif

int main()
{
   double complex z = 5 * cexp(M_PI_2 * I);
   printf("%f * e^(%f * i) = %f + %f * i\n", cabs(z), carg(z), creal(z), cimag(z));

   return 0;
}
```
@run

```
5.000000 * e^(1.570796 * i) = 0.000000 + 5.000000 * i
```

In diesem Beispiel wurde die komplexe Zahl in der Polarform angegeben. Dafür
wurde die Funktion `cexp()` benutzt, welche die natürliche Exponentialfunktion
für komplexe Zahlen darstellt. Das Makro `M_PI_2` ist eine mathematische
Konstante und entspricht $\pi / 2$, welches in unserem Beispiel einem Winkel
$\phi = 90 \degree$ entspricht. Bei der Ausgabe wird mit der Funktion `cabs()`
der Betrag und mit `carg()` die Phase unserer komplexen Zahl `z` bestimmt.


## Kompilierung

Um C-Programme ausführen zu können, müssen diese erst in die Maschinensprache
übersetzt werden. Diesen Vorgang nennt man kompilieren.

Anschließend wird der beim Kompilieren entstandene Objektcode mit einem Linker
gelinkt, so dass alle eingebundenen Bibliotheksfunktionen verfügbar sind. Das
gelinkte Produkt aus einer oder verschiedenen Objektcode-Dateien und den
Bibliotheken ist dann das ausführbare Programm.

### Compiler

Um die erstellten Code-Dateien zu kompilieren, benötigt man selbstverständlich
auch einen Compiler. Je nach Plattform hat man verschiedene Alternativen:

#### Microsoft Windows

Wer zu Anfang nicht all zu viel Aufwand betreiben will, kann mit relativ kleinen
Compilern (ca. 2-5 MByte) inkl. IDE/Editor anfangen:

* [Pelles C](http://www.smorgasbordet.com/pellesc), kostenlos.
  [Hier](http://www.pellesc.de/) befindet sich der deutsche Mirror.
* [lcc-win32](http://www.cs.virginia.edu/~lcc-win32/),
  kostenlos für private Zwecke.
* [cc386](http://www.members.tripod.com/~ladsoft/cc386.htm), Open Source.

Wer etwas mehr Aufwand (finanziell oder an Download) nicht scheut, kann zu
größeren Paketen inkl. IDE greifen:

* [Microsoft Visual Studio](http://www.microsoft.com/germany/VisualStudio/),
  kommerziell, enthält neben dem C-Compiler auch Compiler für C#, C++ und
  VisualBasic. [Visual C++ Express](http://www.microsoft.com/germany/express/)
  ist die kostenlose Version.
* [CodeGear C++ Builder](http://www.codegear.com/products/cppbuilder),
  kommerziell, ehemals Borland C++ Builder.
* [Open Watcom](http://www.openwatcom.org), Open Source.
* [wxDevCpp](http://wxdsgn.sourceforge.net/), komplette IDE basierend
  auf dem GNU C Compiler (Mingw32), Open Source.

Wer einen (kostenlosen) Kommandozeilen-Compiler bevorzugt, kann zusätzlich zu
obigen noch auf folgende Compiler zugreifen:

* [Mingw32](http://www.mingw.org/), der GNU-Compiler für Windows, Open Source.
* [Digital Mars Compiler](http://www.digitalmars.com/),
  kostenlos für private Zwecke.
* [Version 5.5 des Borland Compilers](http://cc.codegear.com/Free.aspx?id=24778),
  kostenlos für private Zwecke
  ([Konfiguration](http://dn.codegear.com/article/21205) und
  [Gebrauch](http://dn.codegear.com/article/20997)).

#### Unix und Linux

Für alle Unix Systeme existieren C-Compiler, die meist auch schon vorinstalliert
sind. Insbesondere, bzw. darüber hinaus, existieren folgende Compiler:

* [GNU C Compiler](http://gcc.gnu.org), Open Source. Ist Teil jeder
  Linux-Distribution, und für praktisch alle Unix-Systeme verfügbar.
* [clang](http://clang.llvm.org), Open Source.
* [Tiny C Compiler](http://www.tinycc.org), Open Source.
* [Portable C Compiler](http://pcc.ludd.ltu.se), Open Source.
* [Der Intel C/C++ Compiler](http://software.intel.com/en-us/articles/intel-compilers/),
  kostenlos für private Zwecke.

Alle gängigen Linux-Distributionen stellen außerdem zahlreiche
Entwicklungsumgebungen zur Verfügung, die vor allem auf den GNU C Compiler
zurückgreifen.

#### Macintosh

Apple stellt selbst einen Compiler mit Entwicklungsumgebung zur Verfügung:

* [Xcode](http://developer.apple.com/tools/xcode), eine komplette
  Entwicklungsumgebung für: C, C++, Java und andere, die Mac OS X beiliegt.
* [Apple's Programmer's Workshop](http://developer.apple.com/tools/mpw-tools)
  kostenlose Entwicklungsumgebung für MacOS 7 bis einschließlich 9.2.2.
* [Gnu Compiler Collection](http://gcc.gnu.org) Gcc, wird über das Terminal
  gesteuert. Ist nach der Installation von
  [Xcode](http://developer.apple.com/tools/xcode) dabei.

#### Amiga

* SAS/C, kommerziell
* vbcc, frei
* GCC

#### Atari

* [GNU C Compiler](http://vincent.riviere.free.fr/soft/m68k-atari-mint),
  existiert auch in gepflegter Fassung für das freie Posix Betriebssystem MiNT,
  auch als Crosscompiler.
* [AHCC](http://members.chello.nl/h.robbers), ein Pure-C kompatibler
  Compiler/Assembler, funktioniert auch unter Single-TOS und ist ebenfalls Open
  Source.

Neben diesen gibt es noch zahllose andere C-Compiler, von optimierten Intel-
oder AMD-Compilern bis hin zu Compilern für ganz exotische Plattformen (cc65 für
6502).

### GNU C Compiler

Der GNU C Compiler, Teil der GCC (GNU Compiler Collection), ist wohl der
populärste Open-Source-C-Compiler und ist für viele verschiedene Plattformen
verfügbar. Er ist in der GNU Compiler Collection enthalten und der
Standard-Compiler für GNU/Linux und die BSD-Varianten.

Compileraufruf: `gcc Quellcode.c -o Programm`

Der GCC kompiliert und linkt nun die "`Quellcode.c`" und gibt es als "Programm"
aus. Das Flag `-c` sorgt dafür, dass nicht gelinkt wird und bei `-S` wird auch
nicht assembliert. Der GCC enthält nämlich einen eigenen Assembler, den GNU
Assembler, der als Backend für die verschiedenen Compiler dient. Um
Informationen über weitere Parameter zu erhalten, verwenden Sie bitte
[`man gcc`](http://www.manpage.org/cgi-bin/man/man2html?gcc-4.0+1).

### Microsoft Visual Studio

Die Microsoft Entwicklungsumgebung enthält eine eigene Dokumentation und ruft
den Compiler nicht über die Kommandozeile auf, sondern ermöglicht die Bedienung
über ihre Oberfläche.

Bevor Sie allerdings mit der Programmierung beginnen können, müssen Sie ein
neues Projekt anlegen. Dazu wählen Sie in den Menüleiste den Eintrag "Datei" und
"Neu..." aus. Im folgenden Fenster wählen Sie im Register "Projekte" den Eintrag
"Win32-Konsolenanwendung" aus und geben einen Projektnamen ein. Verwechseln Sie
nicht den Projektnamen mit dem Dateinamen! Die Endung .c darf hier deshalb noch
nicht angegeben werden. Anschließen klicken Sie auf "OK" und "Fertigstellen" und
nochmals auf "OK".

Nachdem Sie das Projekt erstellt haben, müssen Sie diesem noch eine Datei
hinzufügen. Rufen Sie dazu nochmals den Menüeintrag "Datei" - "Neu..." auf und
wählen Sie in der Registerkarte "Dateien" den Eintrag "C++ Quellcodedateien"
aus. Dann geben Sie den Dateinamen ein, diesmal mit der Endung .c und bestätigen
mit "OK". Der Dateiname muss nicht gleich dem Projektname sein.

In Visual Studio 6 ist das Kompilieren im Menü "Erstellen" unter "Alles neu
erstellen" möglich. Das Programm können Sie anschließend in der
"Eingabeaufforderung" von Windows ausführen.

## Erlaubte Zeichen

Die folgenden Zeichen sind in C erlaubt:

* Großbuchstaben:

  `A B C D E F G H I J K L M N O P Q R S T U V W X Y Z`

* Kleinbuchstaben:

  `a b c d e f g h i j k l m n o p q r s t u v w x y z`

* Ziffern:

  `0 1 2 3 4 5 6 7 8 9`

* Sonderzeichen:

  `!` `"` `#` `%` `&` `'` `(` `)` `*` `+` `,` `-` `.` `/` `:` `;` `<` `=` `>`
  `?` `[` `\` `]` `^` `_` `{` `|` `}` `~` Leerzeichen

* Steuerzeichen:

  horizontaler Tabulator, vertikaler Tabulator, Form Feed

### Ersetzungen

Der ANSI-Standard enthält außerdem so genannte Drei-Zeichen-Folgen (trigraph
sequences), die der Präprozessor jeweils durch das im Folgenden angegebene
Zeichen ersetzt. Diese Ersetzung erfolgt vor jeder anderen Bearbeitung.

| Drei-Zeichen-Folge | = Ersetzung |
|--------------------|-------------|
| `??=`              | `#`         |
| `??'`              | `^`         |
| `??-`              | `~`         |
| `??!`              | `|`         |
| `??/`              | `\`         |
| `??(`              | `[`         |
| `??)`              | `]`         |
| `??<`              | `{`         |
| `??>`              | `}`         |


## Schlüsselwörter

ANSI C (C89)/ISO C (C90) Schlüsselwörter:

* `auto`
* [`break`](#57)
* `case`
* `char`
* `const`
* `continue`
* `default`
* `do`
* `double`
* `else`
* `enum`
* `extern`
* `float`
* `for`
* `goto`
* `if`
* `int`
* `long`
* `register`
* `return`
* `short`
* `signed`
* `sizeof`
* `static`
* `struct`
* `switch`
* `typedef`
* `union`
* `unsigned`
* `void`
* `volatile`
* `while`

ISO C (C99) Schlüsselwörter:

* `_Bool`
* `_Complex`
* `_Imaginary`
* `inline`
* `restrict`

ISO C (C11) Schlüsselwörter:

* `_Alignas`
* `_Alignof`
* `_Atomic`
* `_Generic`
* `_Noreturn`
* `_Static_assert`
* `_Thread_local`

## Ausdrücke und Operatoren

### Ausdrücke

Ein Ausdruck ist eine Kombination aus Variablen, Konstanten, Operatoren und
Rückgabewerten von Funktionen. Die Auswertung eines Ausdrucks ergibt einen Wert.

### Operatoren

Man unterscheidet zwischen unären, binären und ternären Operatoren. Unäre
Operatoren besitzen einen, binäre Operatoren besitzen zwei, ternäre drei
Operanden. Die Operatoren `*`, `&`, `+` und `–` kommen sowohl als unäre wie auch
als binäre Operatoren vor.

#### Vorzeichenoperatoren

**Negatives Vorzeichen `-`**

Liefert den negativen Wert eines Operanden. Der Operand muss ein arithmetischer
Typ sein. Beispiel:

``` c
printf("-3 minus -2 = %i", -3 - -2); // Ergebnis ist -1
```

**Positives Vorzeichen `+`**

Der unäre Vorzeichenoperator + wurde in die Sprachdefinition aufgenommen, damit
ein symmetrischer Operator zu `-` existiert. Er hat keine Einfluss auf den
Operanden. So ist beispielsweise +4.35 äquivalent zu 4.35. Der Operand muss ein
arithmetischer Typ sein. Beispiel:

``` c
printf("+3 plus +2= %i", +3 + +2); // Ergebnis ist 5
```

#### Arithmetik

Alle arithmetischen Operatoren, außer dem Modulo-Operator, können sowohl auf
Ganzzahlen als auch auf Gleitkommazahlen angewandt werden. Arithmetische
Operatoren sind immer binär.

Beim + und - Operator kann ein Operand auch ein Zeiger sein, der auf ein Objekt
(etwa ein Array) verweist und der zweite Operand ein Integer sein. Das Resultat
ist dann vom Typ des Zeigeroperanden. Wenn P auf das i-te Element eines Arrays
zeigt, dann zeigt `P + n` auf das i+n-te Element des Array und P - n zeigt auf
das i-n-te Element. Beispielsweise zeigt `P + 1` auf das nächste Element des
Arrays. Ist `P` bereits das letzte Element des Arrays, so verweist der Zeiger
auf das nächste Element nach dem Array. Ist das Ergebnis nicht mehr ein Element
des Arrays oder das erste Element nach dem Array, ist das Resultat undefiniert.

**Addition `+`**

Der Additionsoperator liefert die Summe der Operanden zurück. Beispiel:

``` c
int a = 3, b = 5;
int ergebnis;
ergebnis = a + b; // ergebnis hat den Wert 8
```

**Subtraktion `-`**

Der Subtraktionsoperator liefert die Differenz der Operanden zurück. Beispiel:

``` c
int a = 7, b = 2;
int ergebnis;
ergebnis = a - b; // ergebnis hat den Wert 5
```

Wenn zwei Zeiger subtrahiert werden, müssen beide Operanden Elemente desselben
Arrays sein. Das Ergebnis ist vom Typ `ptrdiff`. Der Typ ptrdiff ist ein
vorzeichenbehafteter Integer-Wert, der in der Header-Datei `<stddef.h>` definiert
ist.

**Multiplikation `*`**

Der Multiplikationsoperator liefert das Produkt der beiden Operanden zurück.
Beispiel:

``` c
int a = 5, b = 3;
int ergebnis;
ergebnis = a * b; // variable 'ergebnis' speichert den Wert 15
```

**Division `/`**

Der Divisionsoperator liefert den Quotienten aus der Division des ersten durch
den zweiten Operanden zurück. Beispiel:

``` c
int a = 8, b = 2;
int ergebnis;
ergebnis = a/b; // Ergebnis hat den Wert 4
```

Bei einer Division durch 0 ist das Verhalten undefiniert. Handelt es sich um
eine Ganzzahl-Operation, wird das Ergebnis stets abgerundet, d.h. 7/2 ist dann
3. Bei einer Fließkomma-Operation führt 7.0/2.0 zu 3.5.

Ebenso ist bei Architekturen mit 2er-Komplement (was heute praktisch überall so
ist) eine Division von 2 signed Integer, bei dem der 1. Operand den Minimalwert
hat (z.b. `INT_MIN`) und der 2. den Wert -1 das verhalten undefiniert. Der Grund
dafür ist, dass das Resultat zu gross ist. Beispiel:

``` c
int a = INT_MIN; //z.b. -2147483648 bei einem 32 bit int
int b = -1;
int ergebnis;
ergebnis = a/b; //würde mathematisch gesehen 2147483648 (2^31) ergeben,
                //jedoch kann ein 32 bit int maximal bis 2147483647 (2^31-1) speichern => undefiniertes Verhalten
```

**Rest `%`**

Der Rest-Operator liefert den Divisionsrest. Die Operanden des Rest-Operators
müssen vom ganzzahligen Typ sein. Beispiel:

``` c
int a = 5, b = 2;
int ergebnis;
ergebnis = a % b; // Ergebnis hat den Wert 1
```

Ist der zweite Operand eine 0, so ist das Verhalten undefiniert.

Die Restoperation ist nicht gleich einer Modulooperation. Ist mindestens ein
Operand negativ kann das Ergebnis negativ sein, während Modulooperationen nie
negative Werte liefern.

``` c
int a = -5, b = 2;
int ergebnis;
ergebnis = a % b; // Ergebnis kann den Wert 1 oder -1 haben
```

#### Zuweisung

Der linke Operand einer Zuweisung muss ein modifizierbarer L-Wert sein.

**Zuweisung `=`**

Bei der einfachen Zuweisung erhält der linke Operand den Wert des rechten.
Beispiel:

``` c
int a = 2, b = 3;
a = b; //a erhaelt Wert 3
```

**Kombinierte Zuweisungen**

Kombinierte Zuweisungen setzen sich aus einer Zuweisung und einer anderen
Operation zusammen. Der Operand

``` c
 a += b
```

wird zu

``` c
 a = a + b
```

erweitert. Es existieren folgende kombinierte Zuweisungen:

`+=` , `-=` , `*=` , `/=` ,  `%=` , `&=` , `|=` , `^=` , `<<=` , `>>=`

**Inkrement `++`**

Der Inkrement-Operator erhöht den Wert einer Variablen um 1. Wird er auf einen
Zeiger angewendet, erhöht er dessen Wert um die Größe des Objekts, auf das der
Zeiger verweist.

Man unterscheidet Postfix ( `a++` )- und Präfix ( `++a` )-Notation. Bei der
Postfix-Notation wird die Variable nach ihrer Verwendung inkrementiert, bei der
Präfix-Notation vorher.

Die Notationsarten unterscheiden sich durch ihre Priorität (siehe Liste der
Operatoren, geordnet nach ihrer Priorität). Der Operand muss ein L-Wert sein.

**Dekrement `--`**

Der Dekrement-Operator verringert den Wert einer Variablen um 1. Wird er auf
einen Zeiger angewendet, verringert er dessen Wert um die Größe des Objekts, auf
das der Zeiger verweist. Auch hier unterscheidet man Postfix- und
Präfix-Notation.

#### Vergleiche

Das Ergebnis eines Vergleichs ist 1, wenn der Vergleich zutrifft, andernfalls 0.
Als Rückgabewert liefert der Vergleich einen Integer-Wert. In C wird der
boolsche Wert true durch einen Wert ungleich 0 und false durch 0 repräsentiert.
Beispiel:

``` c
a = (4 == 3); // a erhaelt den Wert 0
a = (3 == 3); // a erhaelt den Wert 1
```

**Gleichheit `==`**

Der Gleichheits-Operator vergleicht die beiden Operanden auf Gleichheit. Er
besitzt einen geringeren Vorrang als `<`, `>`, `<=` und `>=`.

**Ungleichheit `!=`**

Der Ungleichheits-Operator vergleicht die beiden Operanden auf Ungleichheit. Er
besitzt einen geringeren Vorrang als `<`, `>`, `<=` und `>=`.

**Kleiner `<`**

Der kleiner-als-Operator liefert dann 1, wenn der Wert des linken Operanden
kleiner ist als der des rechten. Beispiel:

``` c
int a = 7, b = 2;
int ergebnis;
ergebnis = a < b; // Ergebnis hat den Wert 0
ergebnis = b < a; // Ergebnis hat den Wert 1
```

**Größer `>`**

Der größer-als-Operator liefert dann 1, wenn der Wert des linken Operanden
größer ist als der des rechten. Beispiel:

``` c
int a = 7, b = 2;
int ergebnis;
ergebnis = a > b; // Ergebnis hat den Wert 1
ergebnis = b > a; // Ergebnis hat den Wert 0
```

**Kleiner gleich `<=`**

Der kleiner-gleich-Operator liefert dann 1, wenn der Wert des linken Operanden
kleiner als der oder gleich dem Wert des rechten. Beispiel:

``` c
int a = 2, b = 7, c = 7;
int ergebnis;
ergebnis = a <= b; // Ergebnis hat den Wert 1
ergebnis = b <= c; // Ergebnis hat ebenfalls den Wert 1
```

**Größer gleich `>=`**

Der größer-gleich-Operator liefert dann 1, wenn der Wert des linken Operanden
größer als der oder gleich dem Wert des rechten. Beispiel:

``` c
int a = 2, b = 7, c = 7;
int ergebnis;
ergebnis = b >= a; // Ergebnis hat den Wert 1
ergebnis = b >= c; // Ergebnis hat ebenfalls den Wert 1
```

#### Aussagenlogik

**Logisches NICHT `!`**

Ist ein unärer Operator und invertiert den Wahrheitswert eines Operanden.
Beispiel:

``` c
printf("Das logische NICHT liefert den Wert %i, wenn die Bedingung (nicht) erfuellt ist.", !(2<1)); //Ergebnis hat den Wert 1
```

**Logisches UND `&&`**

Das Ergebnis des Ausdrucks ist 1, wenn beide Operanden ungleich 0 sind,
andernfalls 0. Der Ausdruck streng wird von links nach rechts ausgewertet. Wenn
der erste Operand bereits 0 ergibt, wird der zweite Operand nicht mehr
ausgewertet, und der Ausdruck liefert in jedem Fall den Wert 0. Nur wenn das
Ergebnis des ersten Operanten ungleich 0 ist, wird der zweite Operand
ausgewertet. Der `&&` Operator ist ein Sequenzpunkt: Alle Nebenwirkungen des
linken Operanden müssen bewertet worden sein, bevor die Nebenwirkungen des
rechten Operanden ausgewertet werden.

Das Resultat des Ausdrucks ist vom Typ `int`. Beispiel:

``` c
printf("Das logische UND liefert den Wert %i, wenn beide Bedingungen erfuellt sind.", 2 > 1 && 3 < 4); //Ergebnis hat den Wert 1
```

**Logisches ODER `||`**

Das Ergebnis ist 1, wenn einer der Operanden ungleich 0 ist, andernfalls ist es 0. Der Ausdruck wird streng von links nach rechts ausgewertet. Wenn der erste Operand einen von 0 verschiedenen Wert liefert, ist das Ergebnis des Ausdruck 1, und der zweite Operand wird nicht mehr ausgewertet. Auch dieser Operator ist ein Sequenzpunkt.

Das Resultat des Ausdrucks ist vom Typ `int`. Beispiel:

``` c
printf("Das logische ODER liefert den Wert %i, wenn mindestens eine der beiden Bedingungen erfuellt ist.", 2 > 3 || 3 < 4); // Ergebnis hat den Wert 1
```

#### Bitmanipulation

**Bitweises UND / AND `&`**

Mit dem UND-Operator werden zwei Operanden bitweise verknüpft.

Wahrheitstabelle der UND-Verknüpfung:

| `b`    | `a`    | `a & b` |
|--------|--------|---------|
| falsch | falsch | falsch  |
| falsch | wahr   | falsch  |
| wahr   | falsch | falsch  |
| wahr   | wahr   | wahr    |

Beispiel:

```c
 a = 45 & 35		// a == 33
```

**Bitweises ODER / OR `|`**

Mit dem ODER-Operator werden zwei Operanden bitweise verknüpft. Die Verknüpfung
darf nur für Integer-Operanden verwendet werden.

Wahrheitstabelle der ODER-Verknüpfung:

| `a`    | `b`    | `a | b` |
|--------|--------|---------|
| falsch | falsch | falsch  |
| falsch | wahr   | wahr    |
| wahr   | falsch | wahr    |
| wahr   | wahr   | wahr    |

Beispiel:

``` c
 a = 45 | 35		// a == 47
```

**Bitweises exklusives ODER (XOR) `^`**

Mit dem XOR-Operator werden zwei Operanden bitweise verknüpft. Die Verknüpfung
darf nur für Integer-Operanden verwendet werden.

Wahrheitstabelle der XOR-Verknüpfung:

| `a`    | `b`    | `a ^ b` |
|--------|--------|---------|
| falsch | falsch | falsch  |
| falsch | wahr   | wahr    |
| wahr   | falsch | wahr    |
| wahr   | wahr   | falsch  |

Beispiel:

``` c
 a = 45 ^ 35;		// a == 14
```

**Bitweises NICHT / NOT `~`**

Mit der NICHT-Operation wird der Wahrheitswert eines Operanden bitweise
umgekehrt.

Wahrheitstabelle der NOT-Verknüpfung:

| a      | `~a`   |
|:------:|:------:|
| 101110 | 010001 |
| 111111 | 000000 |

Beispiel:

``` c
  a = ~45;
```

**Linksshift `<<`**

Verschiebt den Inhalt einer Variable bitweise nach links. Bei einer ganzen nicht
negativen Zahl entspricht eine Verschiebung einer Multiplikation mit 2n, wobei n
die Anzahl der Verschiebungen ist, wenn das höchstwertige Bit nicht links
hinausgeschoben wird. Das Ergebnis ist undefiniert, wenn der zu verschiebende
Wert negativ ist.

Beispiel:

``` c
 y = x << 1;
```

| `x`      | `y`      |
|----------|----------|
| 01010111 | 10101110 |

**Rechtsshift `>>`**

Verschiebt den Inhalt einer Variable bitweise nach rechts. Bei einer ganzen,
nicht negativen Zahl entspricht eine Verschiebung einer Division durch 2n und
dem Abschneiden der Nachkommastellen (falls vorhanden), wobei n die Anzahl der
Verschiebungen ist. Das Ergebnis ist implementierungsabhängig, wenn der zu
verschiebende Wert negativ ist.

Beispiel:

``` c
 y = x >> 1;
```

| `x`      | `y`      |
|----------|----------|
| 01010111 | 00101011 |

#### Datenzugriff

**Dereferenzierung `*`**

Der Dereferenzierungs-Operator (auch Indirektions-Operator oder Inhalts-Operator
genannt) dient zum Zugriff auf ein Objekt durch einen Zeiger. Beispiel:

``` c
int a;
int * zeiger;
zeiger = &a;
* zeiger = 3; // Setzt den Wert von a auf 3
```

Der unäre Dereferenzierungs-Operator bezieht sich immer auf den rechts stehenden
Operanden.

Jeder Zeiger hat einen festgelegten Datentyp. Die Notation

``` c
 int *zeiger
```

mit Leerzeichen zwischen dem Datentyp und dem Inhalts-Operator soll dies zum
Ausdruck bringen. Eine Ausnahme bildet nur ein Zeiger vom Typ void. Ein so
definierter Zeiger kann einen Zeiger beliebigen Typs aufnehmen. Zum Schreiben
muss der Datentyp per Typumwandlung festgelegt werden.

**Elementzugriff `->`**

Dieser Operator stellt eine Vereinfachung dar, um über einen Zeiger auf ein
Element einer Struktur oder Union zuzugreifen.

``` c
 objZeiger->element
```

entspricht

``` c
 (* objZeiger).element
```

**Elementzugriff `.`**

Der Punkt-Operator dient dazu, auf Elemente einer Struktur oder Union
zuzugreifen.

#### Typumwandlung

**Typumwandlung `()`**

Mit dem Typumwandlungs-Operator kann der Typ des Wertes einer Variable für die
Weiterverarbeitung geändert werden, nicht jedoch der Typ einer Variable.
Beispiel:

```c
float f = 1.5;
int i = (int)f; // i erhaelt den Wert 1

float a = 5;
int b = 2;
float ergebnis;
ergebnis = a / (float)b; //ergebnis erhaelt den Wert 2.5
```

#### Speicherberechnung

**Adresse `&`**

Mit dem Adress-Operator erhält man die Adresse einer Variablen im Speicher. Das
wird vor allem verwendet, um Zeiger auf bestimmte Variablen verweisen zu lassen.
Beispiel:

``` c
int *zeiger;
int a;
zeiger = &a; // zeiger verweist auf die Variable a
```

Der Operand muss ein L-Wert sein.

**Speichergröße `sizeof`**

Mit dem `sizeof`-Operator kann die Größe eines Datentyps oder eines Datenobjekts
in Byte ermittelt werden. `sizeof` liefert einen ganzzahligen Wert ohne
Vorzeichen zurück, dessen Typ `size_t` in der Headerdatei `stddef.h` festgelegt
ist.

Beispiel:

``` c
int a;
int groesse = sizeof(a);
```

Alternativ kann man `sizeof` als Parameter auch den Namen eines Datentyps
übergeben. Dann würde die letzte Zeile wie folgt aussehen:

``` c
int groesse = sizeof(int);
```

Der Operator `sizeof` liefert die Größe in Bytes zurück. Die Größe eines `int`
beträgt mindestens 8 Bit, kann je nach Implementierung aber auch größer sein.
Die tatsächliche Größe kann über das Macro `CHAR_BIT`, das in der
Standardbibliothek `limits.h` definiert ist, ermittelt werden. Der Ausdruck
`sizeof(char)` liefert immer den Wert 1.

Wird `sizeof` auf ein Array angewendet, ist das Resultat die Größe des Arrays,
`sizeof` auf ein Element eines Arrays angewendet, liefert die Größe des
Elements. Beispiel:

``` c
char a[10];
sizeof(a);    // liefert 10
sizeof(a[3]); // liefert 1
```

Der `sizeof`-Operator darf nicht auf Funktionen oder Bitfelder angewendet
werden.

#### Sonstige

**Funktionsaufruf `()`**

Bei einem Funktionsaufruf stehen nach dem Namen der Funktion zwei runde
Klammern. Wenn Parameter übergeben werden, stehen diese zwischen diesen
Klammern. Beispiel:

``` c
funktion(); // Ruft funktion ohne Parameter auf
funktion2(4, a); // Ruft funktion2 mit 4 als ersten und a als zweiten Parameter auf
```

**Komma-Operator `,`**

Der Komma-Operator erlaubt es, zwei Ausdrücke auszuführen, wo nur einer erlaubt
wäre. Die Ergebnisse aller durch diesen Operator verknüpften Ausdrücke außer dem
letzten werden verworfen. Am häufigsten wird er in `for`-Schleifen verwendet,
wenn zwei Schleifen-Variablen vorhanden sind.

``` c
int x = (1,2,3); // entspricht  int x = 3;
for (i = 0, j = 1; i < 10; i++, j--)
{
   //...
}
```

**Bedingung `?:`**

Der Bedingungs-Operator, auch als ternärer Operator bezeichnet, hat drei
Operanden und folgende Syntax

``` c
Bedingung ? Ausdruck1 : Ausdruck2
```

Zuerst wird die Bedingung ausgewertet. Trifft diese zu, wird der erste Ausdruck
abgearbeitet, andernfalls der zweite. Beispiel:

``` c
int a, b, max;
a = 5;
b = 3;
max = (a > b) ? a : b; //max erhalt den Wert von a (also 5),
                       //weil diese die Variable mit dem größeren Wert ist
```

**Indizierung `[]`**

Der Index-Operator wird verwendet, um ein Element eines Arrays anzusprechen.
Beispiel:

``` c
 a[3] = 5;
```

**Klammerung `()`**

Geklammerte Ausdrücke werden vor den anderen ausgewertet. Dabei folgt C den
Regeln der Mathematik, dass innere Klammern zuerst ausgewertet werden. So
durchbricht

``` c
 ergebnis = (a + b) * c
```

die Punkt-vor-Strich-Regel, die sonst bei

``` c
 ergebnis = a + b * c
```

gälte.

## Liste der Operatoren nach Priorität

| Priorität | Symbol                       | Assoziativität | Bedeutung                   |
|:---------:|:-----------------------------|:--------------:|:----------------------------|
| 15        | (Postfix) `++`               | L - R          | Postfix-Inkrement           |
|           | (Postfix) `--`               |                | Postfix-Dekrement           |
|           | `()`                         |                | Funktionsaufruf             |
|           | `[]`                         |                | Indizierung                 |
|           | `->`                         |                | Elementzugriff              |
|           | `.`                          |                | Elementzugriff              |
|           |	(Typ){Initialisierungsliste} |                | compound literal (C99)      |
| 14        | `++` (Präfix)                | R - L          | Präfix-Inkrement            |
|           | `--` (Präfix)                |                | Präfix-Dekrement            |
|           | `+` (Vorzeichen)             |                | Vorzeichen                  |
|           | `-` (Vorzeichen)             |                | Vorzeichen                  |
|           | `!`                          |                | logisches NICHT             |
|           | `~`                          |                | bitweises NICHT             |
|           | `&`                          |                | Adresse                     |
|           | `*`                          |                | Zeigerdereferenzierung      |
|           | `(Typ)`                      |                | Typumwandlung               |
|           | `sizeof`                     |                | Speichergröße               |
|           | `_Alignof`                   |                | alignment requirement (C11) |
| 13        | `*`                          | L - R          | Multiplikation              |
|           | `/`                          |                | Division                    |
|           | `%`                          |                | Modulo                      |
| 12        | `+`                          | L - R          | Addition                    |
|           | `-`                          |                | Subtraktion                 |
| 11        | `<<`                         | L - R          | Links-Shift                 |
|           | `>>`                         |                | Rechtsshift                 |
| 10        | `<`                          | L - R          | kleiner                     |
|           | `<=`                         |                | kleiner gleich              |
|           | `>`                          |                | größer                      |
|           | `>=`                         |                | größer gleich               |
| 9         | `==`                         | L - R          | gleich                      |
|           | `!=`                         |                | ungleich                    |
| 8         | `&`                          | L - R          | bitweises UND               |
| 7         | `^`                          | L - R          | bitweises exklusives ODER   |
| 6         | `|`                          | L - R          | bitweises ODER              |
| 5         | `&&`                         | L - R          | logisches UND               |
| 4         | `||`                         | L - R          | logisches ODER              |
| 3         | `?:`                         | R - L          | Bedingung                   |
| 2         | `=`                          | R - L          | Zuweisung                   |
|           | `*=`, `/=`, `%=`, `+=`, `-=`, `&=`, `^=`, `|=`, `<<=`, `>>=` | | Zusammengesetzte Zuweisung |
| 1         | `,`                          | L - R          | Komma-Operator              |

## Datentypen

TODO: Image https://de.wikibooks.org/wiki/C-Programmierung:_Datentypen#/media/File:Datentypen_in_C.svg

### Grunddatentypen

| Typ                  | Grenz-Konstanten        | Mindest-Wertebereich lt. Standard | typischer Wertebereich |
|:---------------------|:-----------------------:|:---------------------------------:|:----------------------:|
| `signed char`        | `SCHAR_MIN - SCHAR_MAX` | -127 - 127                        | -128 - 127 |
| `signed short`       | `SHRT_MIN - SHRT_MAX`   | -32.767 - 32.767                  | -32.768 - 32.767 |
| `signed int`         | `INT_MIN - INT_MAX`     | -32.767 - 32.767                  | -2.147.483.648 - 2.147.483.647 |
| `signed long`        | `LONG_MIN - LONG_MAX`   | -2.147.483.647 - 2.147.483.647    | -2.147.483.648 - 2.147.483.647 |
| `signed long long`   | `LLONG_MIN - LLONG_MAX` | -9.223.372.036.854.775.807 - 9.223.372.036.854.775.807 | -9.223.372.036.854.775.808 - 9.223.372.036.854.775.807 |
| `unsigned char`      | `0 - UCHAR_MAX`         | 0 - 255                           | 0 - 255 |
| `unsigned short`     | `0 - USHRT_MAX`         | 0 - 65.535                        | 0 - 65.535 |
| `unsigned int`       | `0 - UINT_MAX`          | 0 - 65.535                        | 0 - 4.294.967.295 |
| `unsigned long`      | `0 - ULONG_MAX`         | 0 - 4.294.967.295                 | 0 - 4.294.967.295 |
| `unsigned long long` | `0 - ULLONG_MAX`        | 0 - 18.446.744.073.709.551.615    | 0 - 18.446.744.073.709.551.615 |
| `float`              | `FLT_MIN - FLT_MAX`     | $10^37 - 10^37$  | 1.175494351*10-38 - 3.402823466*1038 |
| `double`             | `DBL_MIN - DBL_MAX`     | 10-37 - 1037 | 2.2250738585072014*10-308 - 1.7976931348623158*10308 |
| `long double`        | `LDBL_MIN - LDBL_MAX`   | 10-37 - 1037 | 3.362103143112093506262677817321752602598*10-4932 - 1.189731495357231765021263853030970205169*104932 |

Durch den Standard werden ausschließlich Mindest-Wertebereiche vorgegeben, die
vom Compilerhersteller konkret vergeben werden. Die in der Implementierung
tatsächlich verwendeten Größen sind in der Headerdatei `<limits.h>` und
`<float.h>` definiert.

Auf Maschinen, auf denen negative Zahlen im Zweierkomplement dargestellt werden,
erhöht sich der negative Zahlenbereich um eins. Deshalb ist beispielsweise der
Wertebereich für den Typ `signed char` bei den meisten Implementierungen
zwischen -128 und +127.

Eine ganzzahlige Variable wird mit dem Schlüsselwort unsigned als vorzeichenlos
vereinbart, mit dem Schlüsselwort `signed` als vorzeichenbehaftet. Fehlt diese
Angabe, so ist die Variable vorzeichenbehaftet, beim Datentyp `char` ist dies
implementierungsabhängig.

Der Typ `int` besitzt laut Standard eine "natürliche Größe". Allerdings muss
`short` kleiner als oder gleich groß wie `int` und `int` muss kleiner als oder
gleich groß wie `long` sein.

Der Standard legt fest, dass `char` groß genug sein muss, um alle Zeichen aus
dem Standardzeichensatz aufnehmen zu können. Wird ein Zeichen gespeichert, so
garantiert der Standard, dass char vorzeichenlos ist.

Mit dem C99-Standard wurde der Typ `_Bool` eingeführt. Er kann die Werte 0
(`false`) und 1 (`true`) aufnehmen. Wie groß der Typ ist, schreibt der
ANSI-Standard nicht vor, ebenso nicht für alle anderen Datentypen außer
`sizeof(char) == 1`(Byte),allerdings muss `_Bool` groß genug sein, um 0 und 1 zu
speichern. Wird ein Wert per "cast" in den Datentyp `_Bool` umgewandelt, dann ist
das Ergebnis 0, wenn der umzuwandelnde Wert 0 ist, andernfalls ist das Ergebnis
1.

#### Größe eines Typs ermitteln

Der `sizeof`-Operator ermittelt die Größe eines Typs in Bytes. Der Rückgabetyp
von `sizeof` ist als `size_t` definiert. Für unvollständige Typen (incomplete
types), also `void` (nicht `void*` !) führt der sizeof Operator zu einer
constraint violation, ist also nicht verwendbar. Außerhalb des Standards
verwenden Compiler trotzdem `sizeof` mit `void`, beim gcc z.B.
`sizeof(void) == 1`.
