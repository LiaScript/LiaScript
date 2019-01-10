<!--
author:   André Dietrich

email:    andre.dietrich@ovgu.de

version:  0.0.1

language: de

narrator: US English Female

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

!?[eLab Version 1](https://youtu.be/bICfKRyKTwE)

## Zurzeit zwo Teile

````
                eLab
                 |
      ___________|___________
     |                       |
     |                       |
    LIA                   robulab
     |
     |
 liascript
````

### robulab

**Ursprüngliches Team:**
* Martin Koppehel
* Fin Christensen
* Leon Wehmeier

**Mit Firmenausgründung:** TODO

### LIA und liascript

!?[gource](https://youtu.be/BDMGNLqc64o)

#### Infrastruktur (LIA)

````
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
````

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
Wähle deine gewünschste Darstellung

{{1}} Unterpunkt

{{2}} Unterpunkt

{{3}} Unterpunkt

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


## CodeRunner & Editor



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


``` js

let code = `// Global variables
float radius = 50.0;
int X, Y;
int nX, nY;
int delay = 16;

// Setup the Processing Canvas
void setup(){
  size( 200, 200 );
  strokeWeight( 10 );
  frameRate( 15 );
  X = width / 2;
  Y = height / 2;
  nX = X;
  nY = Y;  
}

// Main draw loop
void draw(){

  radius = radius + sin( frameCount / 4 );

  // Track circle to new destination
  X+=(nX-X)/delay;
  Y+=(nY-Y)/delay;

  // Fill canvas grey
  background( 100 );

  // Set fill-color to blue
  fill( 0, 121, 184 );

  // Set stroke-color white
  stroke(255);

  // Draw circle
  ellipse( X, Y, radius, radius );                  
}


// Set circle's next destination
void mouseMoved(){
  nX = mouseX;
  nY = mouseY;  
}`

Processing.compile(code);
```
<script>
@input
</script>

<canvas id="sketch"></canvas>

#### Online Programmieren

``` javascript     main.c
let files = {"main.c": `#include <stdio.h>

int main (void){
	int i = 0;
	int max = 0;

	printf("How many hellos: ");
	scanf("%d",&max);

  for(i=0; i<max; i++)
  	printf ("Hello, world %d!\n", i);

	return 0;
}
`};


function service(event_id, data) {
    console.log("SSSSSSSS", event_id, data);
    if(!event_id)
        Promise.resolve({event_id: null});

		else
    return new Promise((resolve, reject)  => {
        send.service(event_id, data)
        .receive("ok",   e => {
						console.log("OK: ", e);
            send.lia("output", e.message );
            resolve(e);
        })
        .receive("error", e => {
						console.log("ERROR: ", e);
            send.lia("output", e.message );
						resolve({event_id: null});
        });
    });

};

service("ex1", {start: "CodeRunner", settings: null})
 .then((e) => { service(e.event_id, {files: files}) })
 .then((e) => { service(e.event_id, {compile: "gcc -Wall main.c -o a.out", order: ["main.c"]}) })
 .then((e) => { service(e.event_id, {execute: "./a.out"}) })
 .then((e) => { console.log("EEEEEEEEEEEEEE1", e); send.lia("eval", "LIA: terminal") })
.catch((e) => { console.log("EEEEEEEEEEEEEE2", e);send.lia("eval", "LIA: stop") } );

"LIA: wait";
```
<script>
@input
</script>


## c

``` cpp     main.c
#include <stdio.h>

int main (void) {
	int i = 0;
	int max = 0;

	printf("How many hellos: ");
	scanf("%d",&max);

  for(i=0; i<max; i++)
  	printf ("Hello, world %d!\n", i);

	return 0;
}
```
<script>
events.register("example1", e => {
console.log(e);

if (e.exit === undefined)
    send.lia("output", e.stdout);
else
    send.lia("eval",  "LIA: stop");
});

send.handle("input", (e) => {send.service("example1",  {input: e})});
send.handle("stop", (e) => {send.service("example1",  {stop: ""})});

send.service("example1", {start: "CodeRunner", settings: null})
.receive("ok", e => {
		send.lia("output", "connecting to CodeRunner ... done\nuploading files ... ")
		send.service("example1", {files: {"main.c": `@input`}})
		.receive("ok", e => {
				send.lia("output", "done\ncompiling ... ")
				send.service("example1",  {compile: "gcc -Wall main.c -o a.out", order: ["main.c"]})
				.receive("ok", e => {
						send.lia("output", "done\n---------------------\n"+e.message+"\n---------------------\nstarting execution ...", [], true);
						send.service("example1",  {execute: "./a.out"})
						.receive("ok", e=>{
							send.lia("output", "done\n", [], true);
						})
						.receive("error", e =>{ send.lia("output", "failed\n" + e.message );
														        send.lia("eval", "LIA: stop" ); })
				})
				.receive("error", e =>{ send.lia("output", "failed\n" + e.message );
														    send.lia("eval", "LIA: stop" ); })
		})
		.receive("error", e => { send.lia("output", "failed\n" + e.message );
														 send.lia("eval", "LIA: stop" ); })
})
.receive("error", e => { send.lia("eval", "connecting to CodeRunner ... failed\n" + e.message ) });

"LIA: terminal";
</script>


``` cpp     main.c
//hier
#include <stdio.h>

int main (void) {
	int i = 0;
	int max = 0;

	printf("How many hellos: ");
	scanf("%d",&max);

  for(i=0; i<max; i++)
  	printf ("Hello, world %d!\n", i);

	return 0;
}
```
<script>
let ID0 = "exx";


events.register(ID0, e => {
		if (!e.exit)
    		send.lia("output", e.stdout);
		else
    		send.lia("eval",  "LIA: stop");
});

send.handle("input", (e) => {send.service(ID0,  {input: e})});
send.handle("stop",  (e) => {send.service(ID0,  {stop: ""})});


send.service(ID0, {start: "CodeRunner", settings: null})
.receive("ok", e => {
		send.lia("output", e.message);

		send.service(ID0, {files: {"main.c": `@input`}})
		.receive("ok", e => {
				send.lia("output", e.message);

				send.service(ID0,  {compile: "gcc -Wall main.c -o a.out", order: ["main.c"]})
				.receive("ok", e => {
						send.lia("log", e.message, e.details, true);

						send.service(ID0,  {execute: "./a.out"})
						.receive("ok", e => {
								send.lia("output", e.message);
								send.lia("eval", "LIA: terminal");





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


## selector

Gib bitte dein RobuLab login ein:

<form action="javascript:void(0);" onsubmit="return alert("DDDDDDDDDDDDDDDD")">

	 <hr class="my-4">
	 <div class="form-group">
	 		<input type="email" class="form-control" id="exampleInputEmail1" aria-describedby="emailHelp" placeholder="Enter email">
	</div>
	<div class="form-group">
		<input type="password" class="form-control" id="exampleInputPassword1" placeholder="Password">
	</div>
	<button type="submit" class="btn btn-primary" onclick="alert("fuck")">Speichern</button>
	<hr class="my-4">
</form>

<script>



</script>


<div id="robot_list">
 <button>Apple</button>
 <button>Samsung</button>
 <button>Sony</button>
</div>

# sucker

``` javascript

events.register("dummy", e => {
		console.log("received: ", e);
		send.lia("eval", JSON.stringify(e));
});


send.service("dummy", {start: "MissionControl", settings: {user: "elab", pass: "elab"}})
.receive("ok", e => {
		console.log(e);
		send.service("dummy", {id: "sucker", action: "call", params: {procedure: "com.robulab.target.get-online", args: [] }})
		.receive("ok", e => {
		console.log(e);
	}).receive("error", e => {
		console.log(e);
});

})
.receive("error", e => {
		console.log(e);
});

"LIA: wait";

```
<script>@input</script>


## CodeRunner & Editor



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


## CodeRunner & Editor
