<!--

author:   Sebastian Zug & André Dietrich
email:    zug@ovgu.de   & andre.dietrich@ovgu.de
version:  0.0.1
language: de
narrator: Deutsch Female

comment:  This is a very simple comment.
          Multiline is also okay.

translation: English   translation/english.md

script:   https://felixhao28.github.io/JSCPP/dist/JSCPP.es5.min.js

@JSCPP
<script>
  console.log("fasdfasfa\nafdasdöfjasölfd\nasdklfjsaölfd\nasdfajsöfld\nasfda");
  try {
    var output = "";
    JSCPP.run(`@0`, `@1`, {stdio: {write: s => { output += s.replace(/\n/g, "<br>");}}});
    output;
  } catch (msg) {
    console.log(msg);
    /*var error = new LiaError(msg, 1);
    var log = msg.match(/(.*)\nline (\d+) \(column (\d+)\):.*\n.*\n(.*)/);
    var info = log[1] + " " + log[4];

    if (info.length > 80)
      info = info.substring(0,76) + "..."

    error.add_detail(0, info, "error", log[2]-1, log[3]);

    throw error;*/
  }
</script>
@end


-->

# C-Kurs

![C logo](img/logo.png)

See the interactive version at
[https://LiaScript.github.io](https://LiaScript.github.io/course/?https://raw.githubusercontent.com/liaScript/CCourse/master/README.md)


\[




## Beispiel

<script>
alert("fuck");
console.log("sssss\nasdasdfasd\nassssss");
</script>

Ausführbarer C++ Code sieht wie folgt aus, der Titel kann weggelassen werden.

```cpp                     Sample.cpp
#include <iostream>
using namespace std;

int main() {
    int a = 120;
    int rslt = 0;
    for(int i=1; i<a; ++i) {
        rslt += i;
        cout << "rslt: " << rslt << "asdfasf\n";
    }
    cout << "final result = " << rslt << "asdfsafd\n";
    return 0;
}
```
@JSCPP(@input, )


```cpp                     Sample.cpp
#include <iostream>
using namespace std;

int main() {
    int a;
    int b;
    cin >> a;
    cin >> b;
    int rslt = b;
    for(int i=1; i<a; ++i) {
        rslt += i;
        cout << "rslt: " << rslt << endl;
    }
    cout << "final result = " << rslt << endl;
    return 0;
}
```
``` text                  stdin
5
12
```
@JSCPP(@input,`@input(1)`)

## Vorlesungsinhalte

### Einführung
Frage an die Veranstaltung: Was passiert überhaupt bei der Abarbeitung eines Programmes und auf welchem Wege kann ich es erzeugen.

+ Hello World Beispiel (C99, C11)
+ Entwicklungumgebungen (Linux, MinGW, cygwin)
+ Compiler, Fehlermeldungen,
+ Rechnerarchitektur, Assembler
+ Vor/ Nachteile, Abstraktionsgedanke bei Programmiersprachen
+ Geschichtlicher Abriss (von C)
+ Eigenschaften von C (imperativ, Zahl der Schlüsselwörter, ...)
+ Abgrenzung zu anderen Sprachen und Konzepten (Entwicklung der "Popularität")
+ heutige Verwendung

### Variablen und Datentypen

+ Idee der Variablen, Bezug auf Architektur
+ /Exkurs/ Zahlendarstellung
+ Definition, Deklaration (fehlende Initialisierung unter c)
+ Kompilieren eines Programms mit unterschiedlichen Variablentypen --> Einfluss auf Programmgröße
+ Kennzeichen einer Variablen: Name (Adresse), Datentyp, Wert, Wertebereich, Sichtbarkeit
+ Typconvertierung, implizite Konvertierung, Beispiel
+ ...

### Operatoren und Ausdrücke
### Kontrollstrukturen
### Funktionen

+ Procedurale Programmierung
+ Definition, Deklaration, Aufruf

### Arrays

+ Beispiel: Argumentenübergabe mittels argv

### Zeiger
### Structs, Unions, Bitfelder
### Speicher, Speicherverwaltung
### Präprozessor
### Standardbibliothek
### Modulare Programmierung
### Algorithmen und Datenstrukturen

## Variable Inhalte
### Debuggingtechniken, häufige Fehler
###
