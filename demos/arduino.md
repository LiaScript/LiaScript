<!--

author:   Konstantin Kirchheim

email:    konstantin.kirchheim@ovgu.de

version:  2.0.0

language: de

narrator: Deutsch Female


@run_main
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

		send.service("@0", {files: {"main.c": `@input`}})
		.receive("ok", e => {
				send.lia("output", e.message);

				send.service("@0",  {compile: "gcc main.c -o a.out", order: ["main.c"]})
				.receive("ok", e => {
						send.lia("log", e.message, e.details, true);

						send.service("@0",  {execute: "./a.out"})
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







@sketch
<script>
events.register("mc_stdout", e => { send.lia("output", e); });
events.register("mc_start", e => { send.lia("eval", "LIA: terminal"); });


let compile = `arduino-builder -compile -logger=machine -hardware /usr/local/share/arduino/hardware -tools /usr/local/share/arduino/tools-builder -tools /usr/local/share/arduino/hardware/tools/avr -built-in-libraries /usr/local/share/arduino/libraries -libraries /usr/local/share/arduino/libraries -fqbn="Robubot Micro:avr:microbot" -ide-version=10807 -build-path $PWD/build -warnings=none -prefs=build.warn_data_percentage=100 -prefs=runtime.tools.avr-gcc.path=/usr/local/share/arduino/packages/arduino/tools/avr-gcc/4.8.1-arduino5/avr -prefs=runtime.tools.avr-gcc-4.8.1-arduino5.path=/usr/local/share/arduino/packages/arduino/tools/avr-gcc/4.8.1-arduino5/avr sketch/sketch.ino`;


send.service("@0arduino", {start: "CodeRunner", settings: null})
.receive("ok", e => {

		send.lia("output", e.message);
		send.service("@0arduino", {files: {"sketch/sketch.ino": `@input`, "build/": ""}})
		.receive("ok", e => {

				send.lia("output", e.message);
				send.service("@0arduino",  {compile: compile, order: ["sketch.ino"]})
				.receive("ok", e => {

						send.lia("log", e.message, e.details, true);
            if(!window["bot_selected"]) { send.lia("eval", "LIA: stop"); }
            else {

              document.getElementById("button_"+window.bot_selected).disabled = true;
              send.service("c",
                { connect: [["@0arduino", {"get_path": "build/sketch.ino.hex"}], ["mc", {"upload": null, "target": window["bot_selected"]}]]
                }
              );

              send.handle("input", (e) => {
                send.service("mc",  {id: "bot_stdin",
                           action: "call",
                           params: {procedure: "com.robulab.target."+window["bot_selected"]+".send_input", args: [0,  String.fromCharCode(0)+btoa(e) ] }})});

              send.handle("stop",  (e) => {
                document.getElementById("button_"+window.bot_selected).disabled = false;

                send.service("mc", {id: "stdio0",
                                   action: "unsubscribe",
                                   params: {id: window["stdio0"], args: [] }});

                send.service("mc", {id: "stdio1",
                                   action: "unsubscribe",
                                   params: {id: window["stdio1"], args: [] }});

                send.service("mc",  {id: "bot_disconnect."+window["bot_selected"],
                           action: "call",
                           params: {procedure: "com.robulab.target.disconnect", args: [window["bot_selected"]] }})});


                delete window.stdio0;
                delete window.stdio1;
            }
				})
				.receive("error", e => { send.lia("log", e.message, e.details, false); send.lia("eval", "LIA: stop"); });
		})
		.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });
})
.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });

"LIA: wait";
</script>

<script>
function aduinoview_init() {

  let arduino_view_frame = document.getElementById("arduinoviewer");

  window["arduino_view_frame"] = arduino_view_frame;

  arduino_view_frame.onload = function () {

    arduino_view_frame.contentWindow.ArduinoView.init = function () {

      arduino_view_frame.contentWindow.ArduinoView.sendMessage = function(e) {

        send.service("mc",  {id: "bot_stdin2",
                   action: "call",
                   params: {procedure: "com.robulab.target."+window["bot_selected"]+".send_input", args: [1,  String.fromCharCode(0)+btoa(e) ] }});
      };

      arduino_view_frame.contentWindow.ArduinoView.onInputPermissionChanged(true);
    };
  };

  arduino_view_frame.contentWindow.ArduinoView.sendMessage = function(e) {

    send.service("mc",  {id: "bot_stdin2",
               action: "call",
               params: {procedure: "com.robulab.target."+window["bot_selected"]+".send_input", args: [1,  String.fromCharCode(0)+btoa(e) ] }});
  };

  arduino_view_frame.contentWindow.ArduinoView.onInputPermissionChanged(true);

}

function update() {
  if(!window["bot_selected"]) {
    for(let i=0; i<window.bot_list.length; i++) {
      let btn = document.getElementById("button_"+window.bot_list[i].target);

      if(btn === null) {
        let cmdi = document.getElementById("bot_list");

        btn = document.createElement("BUTTON");
        btn.id = "button_" + window.bot_list[i].target;
        btn.innerHTML = window.bot_list[i].name;
        btn.onclick = function() {
           let id = window.bot_list[i].target;

           send.service("mc", {id: "bot_connect."+id,
                      action: "call",
                      params: {procedure: "com.robulab.target.connect", args: [id] }});
         };

         cmdi.appendChild(btn);
         cmdi.appendChild(document.createTextNode(" "));
      }

      btn.style.backgroundColor = "";

      if(window.bot_list[i].owner == ""){
        btn.className = "lia-btn";
        btn.disabled = false;
      }
      else {
        btn.className = "lia-btn";
        btn.disabled = true;
      }
    }
  }
  else {
    for(let i=0; i<window.bot_list.length; i++) {
      let btn = document.getElementById("button_"+window.bot_list[i].target);
      if(window.bot_list[i].target == window["bot_selected"]){
        btn.className = "lia-btn";
        btn.disabled = false;
        btn.style.backgroundColor = "#ADFF2F";
      }
      else {
        btn.className = "lia-btn";
        btn.disabled = true;
      }
    }
  }
}


function subscriptions() {
    events.register("mc", e => {
       if(typeof(e) === "undefined")
          return;

       if(!!e.subscription) {
         if (e.subscription.startsWith("com.robulab.livestream")) {
            console.log("vid", e.parameters.args[0].data);
            window.cam.PutData(new Uint8Array(e.parameters.args[0].data));
         }
         else if (e.subscription == "com.robulab.target.changed") {
           let args = e.parameters.args;
           for(let i=0; i<args.length; i++) {
             for(let j=0; j<window.bot_list.length; j++) {
               if(args[i].target == window.bot_list[j].target) {
                 window.bot_list[j] = Object.assign(window.bot_list[j], args[i])
               }
             }
           }
           update();
         } else if (e.subscription.endsWith(".0.raw_out")) {
           events.dispatch("mc_stdout", String.fromCharCode.apply(this, e.parameters.args[0].data));
         } else if (e.subscription.endsWith(".1.raw_out")) {
           window["arduino_view_frame"].contentWindow.ArduinoView.onArduinoViewMessage(
             String.fromCharCode.apply(this, e.parameters.args[0].data) );
         }
         else {
          //console.log("problem", e);
         }
       }
       else if(e.id == "bot_list") {
         window["bot_list"] = e.ok;
         let cmdi = document.getElementById("bot_list");

         for (let i = 0; i< window.bot_list.length; i++) {
            let btn = document.createElement("BUTTON");
            btn.id = "button_" + window.bot_list[i].target;
            btn.innerHTML = window.bot_list[i].target;
            btn.onclick = function() {
              let id = window.bot_list[i].target;

              send.service("mc", {id: "bot_connect."+id,
                           action: "call",
                          params: {procedure: "com.robulab.target.connect", args: [id] }});
              };

              cmdi.appendChild(btn);
              cmdi.appendChild(document.createTextNode(" "));

              send.service("mc", {id: "bot_name."+i,
                           action: "call",
                           params: {procedure: "com.robulab.target."+ window.bot_list[i].target +".get_name", args: [] }});
             }
           update();
         }
         else if( e.id.startsWith("bot_flash1") ) {
           let [cmd, target, file] = e.id.split(" ");
           send.service("mc", {upload: file, target: target, id: e.ok});
         }
         else if( e.id.startsWith("bot_flash2") ) {
           let [cmd, target, id] = e.id.split(" ");
           send.service("mc", {finish: parseInt(id), target: target});
         }
         else if ( e.id.startsWith("bot_flash3") && !e.ok ) {
           aduinoview_init();
           let [cmd, target, id] = e.id.split(" ");

           send.service("mc", {id: "bot_stdio.0.target",
                               action: "subscribe",
                               params: {topic: "com.robulab.target."+target+".0.raw_out", args: [] }});

           send.service("mc", {id: "bot_stdio.1.target",
                               action: "subscribe",
                               params: {topic: "com.robulab.target."+target+".1.raw_out", args: [] }});

           events.dispatch("mc_start", "");


        }

        else if (e.id.startsWith("bot_stdio")) {
          let [cmd, stdio, target] = e.id.split(".");
          window["stdio"+stdio] = e.ok.id;
        }

        else if( e.id.startsWith("bot_name") ) {
          let [cmd, id] = e.id.split(".")
          window.bot_list[id]["name"] = e.ok;
          document.getElementById("button_"+window.bot_list[id].target).innerHTML = e.ok;
        }

        else if( e.id.startsWith("bot_connect") ) {
          let [cmd, target] = e.id.split(".");
          window["bot_selected"] = target;
          let btn = document.getElementById("button_"+target);
          btn.onclick = function() {
              send.service("mc", {id: "bot_disconnect."+target,
                         action: "call",
                         params: {procedure: "com.robulab.target.disconnect", args: [target] }});
          };

          send.service("mc", {id: "bot_stream."+target,
                     action: "call",
                     params: {procedure: "com.robulab.target."+target+".get_stream", args: [target] }});

          update();

          window["cam"] = window.decoder(document.getElementById("bot_show"), ([w, h]) => {
              let canvas = document.getElementById("bot_show");

              canvas.height = h;
              canvas.width = w;
          });
        }
        else if( e.id.startsWith("bot_disconnect") ) {
          let [cmd, target] = e.id.split(".");
          delete window["bot_selected"];

          let btn = document.getElementById("button_"+target)
          btn.onclick = function() {
              send.service("mc", {id: "bot_connect."+target,
                         action: "call",
                         params: {procedure: "com.robulab.target.connect", args: [target] }});
          };

          send.service("mc", {id: "cam_disconnect",
                             action: "unsubscribe",
                             params: {id: window["streaming_id"], args: [] }});

          update();
        }
        else if ( e.id.startsWith("bot_stream") ) {
          let [cmd, target] = e.id.split(".");
          send.service("mc",
                       {id: "streaming",
                        action: "subscribe",
                        params: {topic: e.ok.url, args: [] }});
        }
        else if (e.id == "streaming") {
          window["streaming_id"] = e.ok.id;
        }

        else if ( e.id == "cam_disconnect") {
          delete window.cam;
        }

        else {
          console.log("not handled", e);
      }
      });

      send.service("mc", {id: "bot_list",
                            action: "call",
                            params: {procedure: "com.robulab.target.get-online", args: [] }});

      send.service("mc", {id: "bot_changes",
                            action: "subscribe",
                            params: {topic: "com.robulab.target.changed", args: [] }})

      send.service("mc", {id: "bot_changes",
                            action: "subscribe",
                            params: {topic: "com.robulab.target.reregister", args: [] }})


      window["mc_subscribed"] = true;

};

function login(silent=true) {
    let cmdi = document.getElementById("mcInterface");

    send.service("mc", {start: "MissionControl", settings: null})
      .receive("ok", (e) => {
          console.log("user-connected:", e);
          cmdi.hidden = false;
          window["mc_logged_in"] = true;
          subscriptions();
      })
      .receive("error", (e) => {
          cmdi.hidden = true;
          console.log("Error user-connected:", e);
          alert("Fail: Please check your login!");
      });
};

if (!window.mc_logged_in) {
  setTimeout((e) => { login() }, 300);
}
else {
  document.getElementById("mcInterface").hidden = false;
  update();
}

window.addEventListener("beforeunload", function (event) {

    if ( window.stdio1 ) {
          send.service("mc", {id: "stdio1",
                       action: "unsubscribe",
                       params: {id: window["stdio1"], args: [] }});
    }

    if ( window.stdio0 ) {
          send.service("mc", {id: "stdio0",
                       action: "unsubscribe",
                       params: {id: window["stdio0"], args: [] }});
    }

    if(window.bot_selected) {
        send.service("mc", {id: "cam_disconnect",
                           action: "unsubscribe",
                           params: {id: window["streaming_id"], args: [] }});

        send.service("mc",  {id: "bot_disconnect."+window["bot_selected"],
                   action: "call",
                   params: {procedure: "com.robulab.target.disconnect", args: [window["bot_selected"]] }});
    }

});

</script>


<div id="mcInterface" hidden="true">
  <span style="border-style: solid; width: 49.5%; float: left; min-width: 480px;">
    <span id="bot_list" ></span>
    <br>
    <iframe id="arduinoviewer" style="margin-left: 3px; width: 99%; max-height: 432px;" src="https://elab.ovgu.robulab.com/arduinoview"></iframe>
  </span>
  <span style="border-style: solid; width: 49.5%; height: 480px; float: right; min-width: 480px; overflow: auto">
    <canvas id="bot_show" style="width: calc(16 * 10vw); height: calc(9 * 10vw);"></canvas>
  </span>
</div>
@end


@init_clear
<script>
  let cmdi = document.getElementById("mcInterface");
  if(cmdi)
    cmdi.hidden = true;

  let viewer = document.getElementById("arduinoviewer");
  if(viewer)
    try {
    //  viewer.contentWindow.document.body.innerHTML = ""
    } catch(e) {}

  if ( window.stdio1 ) {
          send.service("mc", {id: "stdio1",
                       action: "unsubscribe",
                       params: {id: window["stdio1"], args: [] }});
  }

  if ( window.stdio0 ) {
          send.service("mc", {id: "stdio0",
                       action: "unsubscribe",
                       params: {id: window["stdio0"], args: [] }});
  }

  if(window.bot_selected) {
        send.service("mc", {id: "cam_disconnect",
                           action: "unsubscribe",
                           params: {id: window["streaming_id"], args: [] }});

        send.service("mc",  {id: "bot_disconnect."+window["bot_selected"],
                   action: "call",
                   params: {procedure: "com.robulab.target.disconnect", args: [window["bot_selected"]] }});
  }
</script>


@end


-->

# PKeS1: Treiber

@init_clear

Willkommen zurück im eLearning-System *eLab*.


    --{{1}}--
Da ihr euch während der letzten Aufgabe sowohl mit dem System, als auch mit dem
Arbeitsablauf vertraut machen konntet, wird es in dieser Aufgabe darum gehen,
tiefer in die Programmierung eingebetteter Systeme einzudringen.

    --{{2}}--
Ein wesentliches Merkmal eingebetteter Systeme ist, dass sie durch periphere
Hardware mit ihrer Umgebung interagieren können. Dafür müssen diese
Hardwarekomponenten jedoch in Software repräsentiert und angesprochen werden
können. Wie auch bei einem Desktop-Computer, geschieht das durch Treiber.

    --{{3}}--
Zur Einführung in die Treiberentwicklung eingebetteter Systeme, wird es in
dieser Aufgabe darum gehen, drei 8-Segment-Anzeigen anzusteuern und sie durch
ein
[Application Programming Interface(API)](https://en.wikipedia.org/wiki/Application_programming_interface)
nach außen als ein Display darzustellen.

![Display](pics/display.png)<!-- width="300px" -->


## Themen und Ziele

@init_clear

    --{{1}}--
Die Themen, die durch die Treiberentwicklung am Beispiel des 8-Segment-Displays
adressiert werden sollen, umfassen zunächst die Ansteuern von periphären
Geräten, im speziellen aber Shift-Register.

    --{{2}}--
Darüber hinaus soll durch die Treiberentwicklung ein Verständnis für die
abstrahierenden Funktionen von Treibern und ihren Beitrag zur Strukturierung von
Programmen dargestellt werden.

    --{{3}}--
Letztlich bietet ein Treiber eine Schnittstelle, die durch weiter Programme
genutzt werden kann. Daher wird auch die Thematik einer API angeschnitten
werden.

**Themen:**

* Einführung in die Treiberentwicklung für eingebettete Systeme
* Arbeitsweise von Shift-Registern und 8-Segment-Anzeigen


**Ziel(e):**

* {{1}} Ansteuerung von Shift-Registern
* {{2}} Kapselung gerätespezifischer Informationen in abstrahierenden Funktionen
        (Treiberentwicklung)
* {{3}} Implementierung entsprechend einer gegebenen API

## Weitere Informationen

@init_clear

    --{{0}}--
Wie immer möchten wir euch weitere Hintergrundinformationen um das Thema Treiber
und Treiberentwicklung geben.

**Treiber und Treiberentwicklung:**

* [Treiber](https://en.wikipedia.org/wiki/Device_driver)
* [Buch zur Treiberentwicklung unter Linux](http://free-electrons.com/doc/books/ldd3.pdf)
* [Application Programming Interface (API)](https://en.wikipedia.org/wiki/Application_programming_interface)


    --{{1}}--
Da es, je nach Hardware und benötigter Performanz, auch nötig sein kann
Assembler zu programmieren, haben wir zusätzlich Links zur Thematik der
Assemblerprogrammierung hinzugefügt.

    {{1}}
*******************************************************************************
**Assembler**

* [Einführung in Assembler](https://www.tutorialspoint.com/assembly_programming/assembly_introduction.htm)
* [YouTube-Tutorial zur Assemblerprogrammierung](https://www.youtube.com/watch?v=ViNnfoE56V8)
* [AVR GCC Inline Assembler Cookbook](http://www.nongnu.org/avr-libc/user-manual/inline_asm.html)
*******************************************************************************

    --{{2}}--
Und natürlich noch ein paar nützliche Links zur Bearbeitung dieses
Aufgabenkomplexes. Im Anhang zu diesem Kurs findet ihr noch eine kurze
Erläuterung zum Shift-Operator.

    {{2}}
*******************************************************************************
**PKeS**

* [Der Shift-Operator](#18)
* [Schaltbelegungsplan](https://github.com/liaScript/PKeS0/blob/master/materials/robubot_stud.pdf?raw=true)
* 8-Segmente Anzeige
  * [Wikipedia](https://en.wikipedia.org/wiki/Seven-segment_display)
  * [Datenblatt](http://www.kingbrightusa.com/images/catalog/SPEC/SA52-11SRWA.pdf)


* [Shift-Register](https://www.sparkfun.com/datasheets/IC/SN74HC595.pdf)
* [Arduinoview](https://github.com/fesselk/Arduinoview/blob/master/doc/Documetation.md)
* [Datenblatt des AVR ATmega32U4](http://www.atmel.com/Images/Atmel-7766-8-bit-AVR-ATmega16U4-32U4_Datasheet.pdf)
********************************************************************************

# Aufgabe

@init_clear

    --{{0}}--
In der *ersten* praktischen Aufgabe sollt ihr einen Treiber für das Display
unserer Roboterplattform implementieren. Dazu haben wir euch dieses mal
lediglich die `Display.h`-Datei vorgegeben, in der einige Funktionen deklariert
sind. Es gilt in dieser Aufgabe diese
[Application Programming Interface (API)](https://en.wikipedia.org/wiki/Application_programming_interface)
zu implementieren.
Es sollte hilfreich sein, wenn ihr bei der Bearbeitung der Aufgabe entsprechend
den Teilschritten vorgeht.

    --{{1}}--
In der ersten Teilaufgabe werdet ihr zunächst die Kommunikation zwischen dem
Mikrocontroller und dem Display implementieren.

    --{{2}}--
In der zweiten Teilaufgabe werdet ihr die Funktionalität des Treibers
vervollständigen, sodass ihr sowohl Gleitkommazahlen, als auch Ganzzahlen auf
dem Display darstellen könnt.

    --{{3}}--
Zuletzt werdet ihr den implementierten Treiber nutzen, um vorgegebene
Zahlenwerte darzustellen.

**Teilaufgaben:**

* {{1}} Implementiert die Grundfunktionalität zum Ansteuern des 8-Segment-Displays.
* {{2}} Implementiert die verbliebenen Funktionen der vorgegebenen API zur einfachen
  Darstellung von Ganzzahlen und Gleitkommazahlen.
* {{3}} Implementiert die Anbindung zum Arduinoview-Interface.

> **Hinweis:**
>
> Verwendet bei der Bearbeitung der Aufgabe keine Funktionen aus der
> Arduino-Bibliothek. Lediglich die Funktionen der `Serial*`-Klassen können zur
> Ansteuerung der seriellen Schnittstelle genutzt werden.

## Teilaufgabe 1

@init_clear

    --{{0}}--
In dieser Teilaufgabe sollt ihr zunächst den Fluss der Daten vom Mikrocontroller
zu den einzelnen 8-Segment-Anzeigen verstehen, bevor ihr die Grundfunktionalität
der Ansteuerung implementiert. Wie bereits erwähnt, besteht das Display aus drei
eigenständigen 8-Segment-Anzeigen. Um deren korrekte Ansteuerung zu verstehen,
solltet ihr den Datenfluss zwischen dem Mikrocontroller und den
8-Segement-Anzeigen verstehen.

    --{{1}}--
Eine zentrale Rolle im Datenfluss nehmen die
[Shift-Register](https://www.sparkfun.com/datasheets/IC/SN74HC595.pdf) ein.
Daher solltet ihr diese eingehend studieren. Wie funktionieren Shift-Register?
Wie sind unsere verschaltet und was muss daher bei der Kommunikation mit ihnen
(auch zeitlich) beachtet werden?

    --{{2}}--
Nachdem nun die theoretischen Fragen zu den von dieser Aufgabe betroffenen
Bauteilen geklärt sein sollten, können wir mit der Implementierung beginnen. Wie
schon angedeutet, soll die in `Display.h` deklarierte API in der dazugehörigen
`Display.cpp` implementiert werden. Beginnt daher mit der Funktion
`initDisplay`. Darin müssen die entsprechenden PINs, an denen die
8-Segment-Anzeigen angeschlossen sind, als Ausgänge konfiguriert werden.
Außerdem soll das Display mit einem *default*-Wert gefüllt werden um mögliche,
zufällige Ausgaben zu löschen.

    --{{3}}--
Zuletzt soll eine grundlegende Funktionalität `writeToDisplay(uint8_t data[3])`
zum Ausgeben von drei Byte implementiert werden. Nehmt dabei an, dass die bits
der drei Werte des Arrays `data` bereits die richtige Bitreihenfolge beachten.


**Ziel:**

Das Ziel in dieser Aufgabe ist es, den Datenfluss, der zur Ansteuerung des
Displays notwendig ist, zu verstehen und den Mikrocontroller entsprechend zu
konfigurieren. Am Ende der Teilaufgabe sollte es euch dadurch möglich sein,
einen von euch gewählten *default*-Wert auf dem Display auszugeben.

Dazu solltet ihr den
[Schaltbelegungsplan](https://github.com/liaScript/PKeS0/blob/master/materials/robubot_stud.pdf?raw=true)
eingehend studieren. Hilfreich ist es, die jeweiligen Ein- und Ausgänge der
Komponenten *gedanklich* miteinander zu verbinden. Ihr könnt dazu bei den
Ausgängen des Mikrocontrollers beginnen und euch bis zum Anschluss jedes
einzelnen 8-Segment-Displays vorarbeiten, oder den Weg umgekehrt gehen.

Beantwortet für euch die Frage: Durch welche Leiter muss ein einzelnes Bit
geleitet werden, um schließlich ein einzelnes Segment eines bestimmten Displays
ein- oder auszuschalten?


**Teilschritte:**

   {{1}}
*******************************************************************************

Verständnis des Datenflusses.

* Wie wird ein einzelnes Segment angesteuert?
* Zusätzlich solltet ihr das
  [Datenblatt des Displays](http://www.kingbrightusa.com/images/catalog/SPEC/SA52-11SRWA.pdf)
  studieren um zu verstehen, wie die Eingänge des Displays den einzelnen LEDs
  zugeordnet sind.

*******************************************************************************

    {{2}}
*******************************************************************************

Implementierung der Funktion `initDisplay()`

* Welche PINs müssen als Ausgänge definiert werden?
* Wie können wir einen *default*-Wert, z.B.: '===', in die Shift-Register
  übertragen?
* Wodurch können wir die Anzeige der Werte auf dem Display veranlassen?

*******************************************************************************


   {{3}}
*******************************************************************************

Implementierung der Funktion `writeToDisplay(uint8_t data[3])`

* Übertragt die drei Byte des Arrays in die Shift-Register und zeigt die Werte
  auf dem Display an.
* Wie können wir die Funktionen, die wir für `initDispaly()` bereits
  implementiert haben, am effizientesten wiederverwenden?

Um eure Funktion zu testen, könnt ihr ein Array mit dem Inhalt {`0b01000010`,
`0b01000010`, `0b01000010`} oder {`0b00011000`, `0b00011000`, `0b00011000`}
übergeben, um eine 1 auszugeben.

*******************************************************************************

## Teilaufgabe 2

@init_clear

    --{{0}}--
In der letzten Teilaufgabe haben wir eine grundlegende Funktionalität zur
Ausgabe von drei Bytes auf dem Display implementiert. In dieser Teilaufgabe soll
diese Funktion genutzt werden, um Variablen der Standarddatentypen `int` und
`float` auszugeben.

    --{{1}}--
Dazu soll die Funktion `writeValueToDisplay`, sowie ihre Überladung mit dem
`float`-Datentypen, implementiert werden. Bei beiden Funktionen muss jedoch der
darstellbare Wertebereich beachtet werden! Versucht so viel Stellen wie möglich
auf dem Display anzuzeigen. Was passiert/sollte passieren, wenn wir den
Funktionen einen nicht-darstellbaren Wert übergeben?

    --{{2}}--
Darüber hinaus muss eine Transformation von der mikrocontroller-internen
Wertedarstellung zur Bitrepresentation auf dem Display implementiert werden.
Dafür kann es hilfreich sein, eine (mehr oder weniger) standardisierten
[Darstellung von Zeichen für 7-Segment-Anzeigen](https://en.wikipedia.org/wiki/Seven-segment_display)
als Zwischenrepräsentation zu implementieren. Ausgehend von dieser kann eine
gerätespezifische Konvertierung geschehen. Welche Vorteil hätte dies für
zukünftige Projekte?


**Ziel:**

Vervollständigt die Implementierung der API in dem ihr die Funktionen `writeValueToDisplay(int value)` und `writeValueToDisplay(float value)` zum Anzeigen von Ganz- und Gleitkommazahlen implementiert.

**Teilschritte:**

    {{1}}
*******************************************************************************

Implementiert eine Konvertierung von `int` zur Bitrepräsentation der Ganzzahl
entsprechend der Ansteuerung des Displays

* (optional) Konvertiert die Zahl zunächst in eine Standardrepräsentation
  wie sie zum Beispiel
  [hier](https://en.wikipedia.org/wiki/Seven-segment_display)
  vorgestellt wird.
* Generiert eine Bitdarstellung in `uint8_t` zur Übergabe an die Funktion
  `writeToDisplay`.

*******************************************************************************

    {{2}}
*******************************************************************************

Implementiert eine Konvertierung von `float` zur Bitrepräsentation der
Gleitkommazahl entsprechend der Ansteuerung des Displays.

* Achtet auf den Dezimal-Punkt!
* Könnt ihr die Implementierung für die Ganzzahlen möglicherweise
  wiederverwenden?

*******************************************************************************

## Teilaufgabe 3

@init_clear


    --{{0}}--
Durch die Teilaufgabe 1.2 sollte die Implementierung des Treibers für unser
Display abgeschlossen sein. Nun können wir ihn zur Darstellung von Zahlen
testen. Daher soll in dieser Aufgabe das Arudinoview-Interface genutzt werden,
um Zahlen zu generieren, die ihr dann über euren Treiber auf dem Display
darstellt. Wir haben euch bereits einen Slider vorgegeben, durch den ihr Werte
in dem Bereich von -200 bis 1000 generieren könnt. Diese werden in der
Callback-Funktion `CallbackSL` als
[null-terminierter String](https://www.tutorialspoint.com/cprogramming/c_strings.htm)
übergeben.

    --{{1}}--
Da wir allerdings auch unsere Ganzzahl-Implementierung der API testen möchten,
solltet ihr in einem ersten Schritt dem Arduinoview-Interface noch eine CheckBox
hinzufügen. Durch die soll es möglich sein, zwischen der `int` und der
`float`-Darstellung dynamisch zu wechseln.
Tipp: ihr könnt zunächst einen Button, wie in der Aufgabe zuvor, verwenden um
zwischen der `int` und `float`-Darstellung zu wechseln, bevor ihr den Button
durch eine CheckBox ersetzt.

    --{{2}}--
In dem finalen, zweiten Schritt könnt ihr die durch die Funktion `CallbackSL`
übermittelten Werte in `int` bzw. `float`-Datentypen konvertieren und sie
mittels der überladenen Funktionen `writeValueToDisplay` darstellen.

    --{{3}}--
Zusätzlich kann es hilfreich sein dem Interface noch ein Text-Input zu direkten
Übergabe von Werten hinzuzufügen. Alternativ könnt ihr natürlich auch Werte von
der seriellen Schnittstelle einlesen.

**Ziel:**

Erweitert das vorgegebene Arduinoview-Interface um eine CheckBox um die durch
den Slider vorgegebenen Werte dynamisch als `int` oder als `float` auf dem
Display auszugeben.

**Teilschritte:**

{{1}} Fügt eine CheckBox zum Wechseln zwischen `float` und `int`-Darstellung.

{{2}} Zeigt die Ganz- und Gleitkommazahlen, die durch den Slider vorgegeben
werden, auf dem Display an.

# **Pogrammierung**

``` cpp sketch.ino
// -----------------------------------------------------------------
// Exercise 1
// -----------------------------------------------------------------

#include <FrameStream.h>
#include <Frameiterator.h>
#include <avr/io.h>
#include "Display.h"


#define OUTPUT__BAUD_RATE 57600
FrameStream frm(Serial1);

// Forward declarations
void InitGUI();

// hierarchical runnerlist, that connects the gui elements with
// callback methods
declarerunnerlist(GUI);

// First level will be called by frm.run (if a frame is recived)
beginrunnerlist();
fwdrunner(!g, GUIrunnerlist); //forward !g to the second level (GUI)
callrunner(!!, InitGUI);
endrunnerlist();

// second level
// SL the slider and Ft the checkbox are registerd here
beginrunnerlist(GUI);
fwdrunner(SL, CallbackSL);
endrunnerlist();


/*
 * this is the callback of the Slider SL
 * slider callback str will contain
 * a number ranging from -200 to 1000 in a string
 */
void CallbackSL(char* str, size_t length)
{
    // TODO interprete string str as integer
    // TODO map integer to
    // show current number string in Arduinoview
    frm.print("!jdocument.getElementById(\"info_val\").innerText=");
    frm.print(str);
    frm.end();
}


/*
 * @brief initialises the GUI of ArduinoView
 *
 * In this function, the GUI, is configured. For this, Arduinoview shorthand,
 * HTML as well as embedded JavaScript can be used.
 */
void InitGUI()
{
    frm.print(F("!h<h1>PKeS Exercise 1</h1>"));
    frm.end();

    // Generating the Slider SL
    frm.print("!SsSL");
    frm.end();

    // modify the Slider using JavaScript
    frm.print("!jvar x=document.getElementById(\"_SD_SL\");");
    frm.print("x.max= 1000;");
    frm.print("x.min=-200;");
    frm.print("x.step=.01;");
    frm.print("x.style.width=\"100%\";");
    frm.end();

    // generate some Space to display Information
    frm.print(F("!H<div>Slider value: <span id=info_val></span></div>"));
    frm.end();
}

/*
 * @brief Initialisation
 *
 * Implement basic initialisation of the program.
 */
void setup()
{
    // give the Web-Interface a bit time to connect
    // to all outputs.
    delay(1000);

    //prepare Serial interfaces
    Serial.begin(OUTPUT__BAUD_RATE);
    Serial1.begin(OUTPUT__BAUD_RATE);

    Serial.println(F("Willkommen zur PKeS Übung"));

    //request reset of GUI
    frm.print("!!");
    frm.end();

    //TODO initialise Display through initDisplay() here
    delay(500);
}

/*
 *  @brief Main loop
 *
 *  This function will be called repeatedly and shall therefore implement the
 *  main behavior of the program.
 */
void loop()
{
    // read & run ArduinoView Frames
    while(frm.run());
}
```
``` cpp Display.h
#ifndef DISPLAY_H
#define DISPLAY_H

#include <inttypes.h>


//TODO: make Display.cpp implement this interface

// you may create as much helper functions inside
// your Display.cpp as you like
// ADVICE: all values are displayed as decimal (Base 10)
// if you like you may ADD functions that display values
// as hexadecimal (Base 16)

//initialises Display
//Setup Data Direction
//write some default pattern or empty to Display

void initDisplay();

// writes 3 data-bytes to Display
// these bytes/bits should represent the 7 Segments and Dot
// may be used to implement the pattern or clearing of initDisplay()
// and the writeValue Functions
// prepare to discuss your bitorder
void writeToDisplay(uint8_t data[3]);

//writes an integer value to display
void writeValueToDisplay(int value);

//writes float value to display
//display as many significant digits as possible
//eg. 5.87 ; 14.5; 124.; -12.4
void writeValueToDisplay(float value);

#endif
```
``` cpp Display.cpp
#include "Display.h"

// TODO: Write a Driver for the LED-Display
```
@sketch


# Prüfe dein Wissen

@init_clear


    --{{0}}--
Wie auch in der letzten Aufgabe, haben wir noch ein paar kurze Fragen an euch,
die ihr in Vorbereitung der Abgabe der Aufgabe bei den Tutoren klären solltet.

## C/C++

@init_clear

Welche der folgenden Funktionen könnten in einem hypothetischen C Programm
parallel zu der Funktion `void fun1(int a)` definiert sein?

    [[ ]] `int fun1(int a)`
    [[ ]] `void fun1(float a)`
    [[X]] `void fun2(float a)`
    [[ ]] `void fun1(void)`

---

Welche der folgenden Funktionen könnten in einem hypothetischen C++ Programm
parallel zu der Funktion `void fun1(int a)` definiert sein?

    [[ ]] `int fun1(int a)`
    [[X]] `void fun1(float a)`
    [[X]] `void fun2(float a)`
    [[X]] `void fun1(void)`
*******************************************************************************

Im Gegensatz zu C, können in C++ Funktionen
[überladen](https://www.tutorialspoint.com/cplusplus/cpp_overloading.htm)
werden. Somit können Funktionen mit verschiedenen Argumenten definiert werden.
Der Datentyp des Rückgabewertes kann jedoch nicht überladen werden!

*******************************************************************************

---

Gegeben sei folgende C-Code Zeile:

``` c
A = A & ~(1<<n);
```

wobei `A` ein Controller-Register und `n` eine integer Zahl zwischen 0 und 7
sei. Welcher Wert steht am Ende in `A` ...

    [( )] eine 1 am n-ten Bit, alle anderen Werte sind 0
    [( )] überall 0
    [( )] eine 0 am n-ten Bit, alle anderen Werte sind 1
    [(X)] eine 0 am n-ten Bit, alle anderen Werte sind unverändert

## Shift-Register und 8-Segment-Display

@init_clear

Welche Aussage zu RS- bzw- D-Flip-Flops ist korrekt?

    [(X)] Die Ausgänge können in einen unbestimmten Zustand gelangen.
    [( )] RS-Flip-Flops können nur aus NAND-Gattern hergestellt werden.
    [( )] D-Flip-Flops sind immer taktgesteuert.

---

Warum wird neben dem *Clock*-Eingang noch ein *Latch*-Eingang für das
Shift-Register benötigt?

    [(X)] Durch den *Latch*-Eingang können die Daten an die Ausgänge des Shift-Registers angelegt werden.
    [( )] Durch den *Latch*-Eingang kann der Inhalt aller Flip-Flops durch ein Steuerungskommando zurückgesetzt werden.
    [( )] Der *Latch*-Eingang ist eine alternative zum *Clock*-Eingang.

### Timing Diagramm 1

@init_clear

Welche Ausgänge des
[Shift-Register](https://www.sparkfun.com/datasheets/IC/SN74HC595.pdf) sind nach
dem folgenden Timing-Diagramm aktiv? Nehmt an, dass zuvor alle Ausgänge
inaktiv(0) waren. (1: aktiv, 0: inaktiv. Reihenfolge: QA, QB, QC, QD, QE, QF,
QG, QH)


<!-- style="max-width: 600px" -->
````
           ___     ___     ___     ___     ___
 SRCLK ___|   |___|   |___|   |___|   |___|   |___
               _______
   SER _______|       |___________________________
                       ___     ___     ___     ___
  RCLK _______________|   |___|   |___|   |___|
 _____ ___________________________________________
 SRCLR
    __
    OE ___________________________________________
````

    [( )] (00100001)
    [( )] (10010000)
    [(X)] (00010000)


### Timing Diagramm 2

@init_clear

Welche Ausgänge des
[Shift-Register](https://www.sparkfun.com/datasheets/IC/SN74HC595.pdf) sind nach
dem folgenden Timing-Diagramm aktiv? Nehmt an, dass zuvor alle Ausgänge
inaktiv(0) waren. (1: aktiv, 0: inaktiv. Reihenfolge: QA, QB, QC, QD, QE, QF,
QG, QH)

<!-- style="max-width: 600px" -->
````
           ___     ___     ___     ___     ___
 SRCLK ___|   |___|   |___|   |___|   |___|   |___
               _______         _______
   SER _______|       |_______|       |___________
                       ___     ___     ___     ___
  RCLK _______________|   |___|   |___|   |___|
 _____ ___________________________________________
 SRCLR
    __
    OE ___________________________________________
````

    [( )] (00000000)
    [( )] (10100001)
    [(X)] (01010000)

### Timing Diagramm 3

@init_clear

Welche Ausgänge des
[Shift-Register](https://www.sparkfun.com/datasheets/IC/SN74HC595.pdf) sind nach
dem folgenden Timing-Diagramm aktiv? Nehmt an, dass zuvor alle Ausgänge
inaktiv(0) waren. (1: aktiv, 0: inaktiv. Reihenfolge: QA, QB, QC, QD, QE, QF,
QG, QH)

<!-- style="max-width: 600px" -->
````
           ___     ___     ___     ___     ___
 SRCLK ___|   |___|   |___|   |___|   |___|   |___
               _______________________
   SER _______|                       |___________

  RCLK ___________________________________________
 _____ ___________________________________________
 SRCLR
    __
    OE ___________________________________________
````

    [( )] (00100000)
    [(X)] (00000000)
    [( )] (00010000)

### Muster

@init_clear

Welches Muster wird auf dem Display dargestellt, wenn die drei Shift-Register
die Werte `0b01001011`, `0b01001011` und `0b01001011` beinhalten?

    [(X)] 444
    [( )] 555
    [( )] 666

### Datenblatt

@init_clear

Das Datenblatt des verwendeten Shift-Registers SN54HC595 (RICHTIG?) spezifiziert
eine maximale Clock-Frequenz für den Betrieb unter 25 Grad Celsius. Welche
Aussage gilt für die Konfiguration des Bauteils, wie sie in den Übungen
verwendet wird?

    [( )] < 36 MHz
    [( )] < 31 MHz
    [(X)] <  6 MHz

---

Laut Datenblatt sollte zwischen dem Schreiben auf der Datenleitung SER und dem
steigenden Flankenwechsel auf der SRCLK im ungünstigsten Fall eine Zeit von 150
ns vergehen. Wie viele NOP Befehle müssen ausgeführt werden, um diese
Verzögerung zu generieren.

    [( )] 1 bei einer Taktrate von 8 MHz
    [(X)] 2
    [( )] 4
    [( )] 6

---

Welche der folgenden Aussagen gilt NICHT als Merkmal von RISC Controller im
Vergleich mit CISC-Systemen:

    [( )] kleinere Befehlssatz
    [(X)] komplexere Befehle
    [( )] meist Load/Store Architekturen
    [( )] extrem schnell auszuführenden Befehle

# Umfrage

@init_clear

Todo

# Der Schift-Operator

@init_clear

Auszug aus dem Wikibuch _C-Programmierung_ ...

Die Operatoren `<<` und `>>` dienen dazu, den Inhalt einer Variablen bitweise um
1 nach links bzw. um 1 nach rechts zu verschieben (siehe Abbildung).

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
@run_main(shift)

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
wäre?

    [[!]]
*******************************************************************************

**Die Antwort lautet:** Bei den meisten Prozessoren wird die Verschiebung der
Bits wesentlich schneller ausgeführt als eine Multiplikation. Deshalb kann es
bei laufzeitkritischen Anwendungen vorteilhaft sein, den Shift-Operator anstelle
der Multiplikation zu verwenden. Eine weitere praktische Einsatzmöglichkeit des
Shift Operators findet sich zudem in der Programmierung von Mikroprozessoren.
Durch einen Leftshift können digitale Eingänge einfacher und schneller
geschaltet werden. Man erspart sich hierbei mehrere Taktzyklen des Prozessors.

*******************************************************************************

> **Anmerkung:** Heutige Compiler optimieren dies schon selbst. Der Lesbarkeit
> halber sollte man also besser `x * 2` schreiben, wenn eine Multiplikation
> durchgeführt werden soll. Will man ein Byte als Bitmaske verwenden, d.h. wenn
> die einzelnen gesetzten Bits interessieren, dann sollte man mit Shift
> arbeiten, um seine Absicht im Code besser auszudrücken.

## Linksshift `<<`

@init_clear


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

## Rechtsshift `>>`

@init_clear


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
