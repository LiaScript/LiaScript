# Ardunio-Template

``` javascript    sketch.ino
let code = `/*
  AnalogReadSerial

  Reads an analog input on pin 0, prints the result to the Serial Monitor.
  Graphical representation is available using Serial Plotter (Tools > Serial Plotter menu).
  Attach the center pin of a potentiometer to pin A0, and the outside pins to +5V and ground.

  This example code is in the public domain.

  http://www.arduino.cc/en/Tutorial/AnalogReadSerial
*/

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  int sensorValue = analogRead(A0);
  // print out the value you read:
  Serial.println(sensorValue);
  delay(1);        // delay in between reads for stability
}
`;

let compile = `arduino-builder -compile -logger=machine -hardware /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/hardware -hardware /home/andre/.arduino15/packages -tools /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/tools-builder -tools /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/hardware/tools/avr -tools /home/andre/.arduino15/packages -built-in-libraries /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/libraries -libraries /home/andre/Arduino/libraries -fqbn="Robubot Micro:avr:microbot" -ide-version=10807 -build-path $PWD/build -warnings=none -prefs=build.warn_data_percentage=100 -prefs=runtime.tools.avr-gcc.path=/home/andre/.arduino15/packages/arduino/tools/avr-gcc/4.8.1-arduino5 -prefs=runtime.tools.avr-gcc-4.8.1-arduino5.path=/home/andre/.arduino15/packages/arduino/tools/avr-gcc/4.8.1-arduino5 sketch/sketch.ino`;

events.register("cod", e => {
		console.log(e);
});

send.service("chain", {serialize: [{event_id: "cod", message: {start: "CodeRunner", settings: null}},
																	 {event_id: "cod", message: {files: {"sketch/sketch.ino": code, "build/": ""}}},
																	 {event_id: "cod", message: {compile: compile, order: ["sketch.ino"]}},
]})
```
<script>@input</script>


# fff

``` javascript       sketch.ino
let code = `/*
  AnalogReadSerial

  Reads an analog input on pin 0, prints the result to the Serial Monitor.
  Graphical representation is available using Serial Plotter (Tools > Serial Plotter menu).
  Attach the center pin of a potentiometer to pin A0, and the outside pins to +5V and ground.

  This example code is in the public domain.

  http://www.arduino.cc/en/Tutorial/AnalogReadSerial
*/

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  int sensorValue = analogRead(A0);
  // print out the value you read:
  Serial.println(sensorValue);
  delay(1);        // delay in between reads for stability
}
`;

let compile = `arduino-builder -compile -logger=machine -hardware /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/hardware -hardware /home/andre/.arduino15/packages -tools /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/tools-builder -tools /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/hardware/tools/avr -tools /home/andre/.arduino15/packages -built-in-libraries /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/libraries -libraries /home/andre/Arduino/libraries -fqbn="Robubot Micro:avr:microbot" -ide-version=10807 -build-path $PWD/build -warnings=none -prefs=build.warn_data_percentage=100 -prefs=runtime.tools.avr-gcc.path=/home/andre/.arduino15/packages/arduino/tools/avr-gcc/4.8.1-arduino5 -prefs=runtime.tools.avr-gcc-4.8.1-arduino5.path=/home/andre/.arduino15/packages/arduino/tools/avr-gcc/4.8.1-arduino5 sketch/sketch.ino`;

send.service("arduino", {start: "CodeRunner", settings: null})
.receive("ok", e => {
		send.lia("output", e.message);

		send.service("arduino", {files: {"sketch/sketch.ino": code, "build/": ""}})
		.receive("ok", e => {
				send.lia("output", e.message);

				send.service("arduino",  {compile: compile, order: ["sketch.ino"]})
				.receive("ok", e => {
						send.lia("log", e.message, e.details, true);

            send.service("user",  {start: "MissionControl", settings: {user: "elab", pass: "elab"}})
            .receive("ok", e => {
						        send.lia("log", e.message, true);

                    send.service("user",  {start: "MissionControl", settings: {user: "elab", pass: "elab"}})

                    send.lia("eval", "LIA: stop");
                     })
            .receive("error", e => { send.lia("log", e.message, e.details, false); console.log("DDDD", e); send.lia("eval", "LIA: stop"); });

				})
				.receive("error", e => { send.lia("log", e.message, e.details, false); console.log("DDDD", e); send.lia("eval", "LIA: stop"); });
		})
		.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });
})
.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });

"LIA: wait";
```
<script>@input</script>

arduino-builder -compile -logger=machine -hardware /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/hardware -hardware /home/andre/.arduino15/packages -tools /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/tools-builder -tools /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/hardware/tools/avr -tools /home/andre/.arduino15/packages -built-in-libraries /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/libraries -libraries /home/andre/Arduino/libraries -fqbn="Robubot Micro:avr:microbot" -ide-version=10807 -build-path $PWD/build -warnings=none -prefs=build.warn_data_percentage=100 -prefs=runtime.tools.avr-gcc.path=/home/andre/.arduino15/packages/arduino/tools/avr-gcc/4.8.1-arduino5/avr -prefs=runtime.tools.avr-gcc-4.8.1-arduino5.path=/home/andre/.arduino15/packages/arduino/tools/avr-gcc/4.8.1-arduino5 sketch/sketch.ino

arduino-builder -compile -logger=machine -hardware /usr/local/share/arduino/hardware -tools /usr/local/share/arduino/tools-builder -tools /usr/local/share/arduino/hardware/tools/avr -built-in-libraries /usr/local/share/arduino/libraries -libraries /usr/local/share/arduino/libraries -fqbn="Robubot Micro:avr:microbot" -ide-version=10807 -build-path $PWD/build -warnings=none -prefs=build.warn_data_percentage=100 -prefs=runtime.tools.avr-gcc.path=/usr/local/share/arduino/packages/arduino/tools/avr-gcc/4.8.1-arduino5/avr -prefs=runtime.tools.avr-gcc-4.8.1-arduino5.path=/usr/local/share/arduino/packages/arduino/tools/avr-gcc/4.8.1-arduino5/avr sketch/sketch.ino


## Bulgarian

--{{0 Russian Male}}--
Васил Атанасов Ивановски, известен още с псевдонимите си Бистришки, Бистрицки,
Динко Динков и Наско, е български комунистически деец, публицист, македонист,
„теоретик“ на „македонската нация“ в рамките на ВМРО (обединена)“, деен участник
в македонизацията на Пиринска Македония след Втората световна война. Според
историографията на Република Македония Ивановски е неин основоположник и виден
„борец за афирмација на македонскиот национален идентитет“, а според българската
историография е известен „със своите лутания по македонския въпрос“.


## Ardunio-Template

``` javascript title
let code = `/*
  AnalogReadSerial

  Reads an analog input on pin 0, prints the result to the Serial Monitor.
  Graphical representation is available using Serial Plotter (Tools > Serial Plotter menu).
  Attach the center pin of a potentiometer to pin A0, and the outside pins to +5V and ground.

  This example code is in the public domain.

  http://www.arduino.cc/en/Tutorial/AnalogReadSerial
*/

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  int sensorValue = analogRead(A0);
  // print out the value you read:
  Serial.println(sensorValue);
  delay(1);        // delay in between reads for stability
}
`;

let compile = `arduino-builder -compile -logger=machine -hardware /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/hardware -hardware /home/andre/.arduino15/packages -tools /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/tools-builder -tools /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/hardware/tools/avr -tools /home/andre/.arduino15/packages -built-in-libraries /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/libraries -libraries /home/andre/Arduino/libraries -fqbn="Robubot Micro:avr:microbot" -ide-version=10807 -build-path $PWD/build -warnings=none -prefs=build.warn_data_percentage=100 -prefs=runtime.tools.avr-gcc.path=/home/andre/.arduino15/packages/arduino/tools/avr-gcc/4.8.1-arduino5 -prefs=runtime.tools.avr-gcc-4.8.1-arduino5.path=/home/andre/.arduino15/packages/arduino/tools/avr-gcc/4.8.1-arduino5 sketch/sketch.ino`;

send.service("arduino", {start: "CodeRunner", settings: null})
.receive("ok", e => {
		send.lia("output", e.message);

		send.service("arduino", {files: {"sketch/sketch.ino": code, "build/": ""}})
		.receive("ok", e => {
				send.lia("output", e.message);

				send.service("arduino",  {compile: compile, order: ["sketch.ino"]})
				.receive("ok", e => {
						send.lia("log", e.message, e.details, true);
            send.lia("eval", "LIA: stop");
				})
				.receive("error", e => { send.lia("log", e.message, e.details, false); console.log("DDDD", e); send.lia("eval", "LIA: stop"); });
		})
		.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });
})
.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });

"LIA: wait";
```


## FormXXXX

``` cpp sketch.ino
#include <FrameStream.h>
#include <Frameiterator.h>

#define OUTPUT__BAUD_RATE 9600
FrameStream frm(Serial1);

// We do not have any interaction in this example, but a default
// callback definition is need for frm.run().
// GUI initialisation request
beginrunnerlist();
callrunner(!!,InitGUI);
endrunnerlist();

void InitGUI(){
	Serial.print("init_Gui ... ");
  frm.print("!h<h1>ArduinoView</h1> <h2>Demo 0 - Hello World </h2>");
  frm.print("<p>Congratulation you transmitted the first HTML Code from your Arduino!!!</p>");
  frm.print("<img src=\"https://upload.wikimedia.org/wikipedia/commons/8/87/Arduino_Logo.svg\" height=\"200\" width=\"200\" >");
  frm.end();
  Serial.println("done");
}

void setup() {
  Serial1.begin(OUTPUT__BAUD_RATE);
  Serial.begin(9600);

  //request reset of gui
  frm.print("!!");
  frm.end();

  delay(500);
}

int i = 0;

void loop() {
  frm.run();

}
```
@sketch(fromxxx)







## FormX

``` cpp sketch.ino
#include <FrameStream.h>
#include <Frameiterator.h>

#define OUTPUT__BAUD_RATE 9600
FrameStream frm(Serial1);

// We do not have any interaction in this example, but a default
// callback definition is need for frm.run().
// GUI initialisation request
beginrunnerlist();
callrunner(!!,InitGUI);
endrunnerlist();

void InitGUI(){
	Serial.print("init_Gui ... ");
  frm.print("!h<h1>ArduinoView</h1> <h2>Demo 0 - Hello World </h2>");
  frm.print("<p>Congratulation you transmitted the first HTML Code from your Arduino!!!</p>");
  frm.print("<img src=\"https://upload.wikimedia.org/wikipedia/commons/8/87/Arduino_Logo.svg\" height=\"200\" width=\"200\" >");
  frm.end();
  Serial.println("done");
}

void setup() {
  Serial1.begin(OUTPUT__BAUD_RATE);
  Serial.begin(9600);

  //request reset of gui
  frm.print("!!");
  frm.end();

  delay(500);
}

int i = 0;

void loop() {
  frm.run();

}
```
<script>
events.register("mc_stdout", e => { send.lia("output", e); });
events.register("mc_start", e => { send.lia("eval", "LIA: terminal"); });


let compile = `arduino-builder -compile -logger=machine -hardware /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/hardware -hardware /home/andre/.arduino15/packages -tools /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/tools-builder -tools /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/hardware/tools/avr -tools /home/andre/.arduino15/packages -built-in-libraries /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/libraries -libraries /home/andre/Arduino/libraries -fqbn="Robubot Micro:avr:microbot" -ide-version=10807 -build-path $PWD/build -warnings=default -prefs=build.warn_data_percentage=75 -prefs=runtime.tools.avr-gcc.path=/home/andre/.arduino15/packages/arduino/tools/avr-gcc/4.8.1-arduino5 -prefs=runtime.tools.avr-gcc-4.8.1-arduino5.path=/home/andre/.arduino15/packages/arduino/tools/avr-gcc/4.8.1-arduino5 -verbose sketch/sketch.ino`;


send.service("arduino", {start: "CodeRunner", settings: null})
.receive("ok", e => {

		send.lia("output", e.message);
		send.service("arduino", {files: {"sketch/sketch.ino": `@input`, "build/": ""}})
		.receive("ok", e => {

				send.lia("output", e.message);
				send.service("arduino",  {compile: compile, order: ["sketch.ino"]})
				.receive("ok", e => {

						send.lia("log", e.message, e.details, true);
            if(!window["bot_selected"]) { send.lia("eval", "LIA: stop"); }
            else {
              send.service("c",
                { connect: [["arduino", {"get_path": "build/sketch.ino.hex"}], ["mc", {"upload": null, "target": window["bot_selected"]}]]
                }
              );

              send.handle("input", (e) => {
                send.service("mc",  {id: "bot_stdin",
                           action: "call",
                           params: {procedure: "com.robulab.target."+window["bot_selected"]+".send_input", args: [0,  String.fromCharCode(0)+btoa(e) ] }})});

              send.handle("stop",  (e) => {
                send.service("mc", {id: "stdio0",
                                   action: "unsubscribe",
                                   params: {id: window["stdio0"], args: [] }});

                send.service("mc", {id: "stdio1",
                                   action: "unsubscribe",
                                   params: {id: window["stdio1"], args: [] }});

                send.service("mc",  {id: "bot_disconnect."+window["bot_selected"],
                           action: "call",
                           params: {procedure: "com.robulab.target.disconnect", args: [window["bot_selected"]] }})});
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
    if(!window["mc_subscribed"]) {
        events.register("mc", e => {

           if(typeof(e) === "undefined")
              return;

           if(!!e.subscription) {
             if (e.subscription == "com.robulab.target.changed") {
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
                 String.fromCharCode.apply(this, e.parameters.args[0].data)

                 );
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
             let [cmd, target, id] = e.id.split(" ");

             send.service("mc", {id: "bot_stdio.0.target",
                                 action: "subscribe",
                                 params: {topic: "com.robulab.target."+target+".0.raw_out", args: [] }});

             send.service("mc", {id: "bot_stdio.1.target",
                                 action: "subscribe",
                                 params: {topic: "com.robulab.target."+target+".1.raw_out", args: [] }});

             events.dispatch("mc_start", "");

             aduinoview_init();
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
              update();
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
              update();
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
   }
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
        form.hidden = false;
        cmdi.hidden = true;
        console.log("user-connected:", e);
        alert("Fail: Please check your login!");
    });
};



  if (!window.mc_logged_in) {
    login();
  }

</script>


<div id="mcInterface" hidden="true">
  <span id="bot_list" ></span>

  <span id="canvas" ></span>

  <iframe id="arduinoviewer" style="width: 100%; max-height: 260px;" src="http://localhost:4000/arduinoview"></iframe>
</div>



## Form

``` cpp sketch.ino
#include <FrameStream.h>
#include <Frameiterator.h>

#define OUTPUT__BAUD_RATE 9600
FrameStream frm(Serial1);

// We do not have any interaction in this example, but a default
// callback definition is need for frm.run().
// GUI initialisation request
beginrunnerlist();
callrunner(!!,InitGUI);
endrunnerlist();

void InitGUI(){
	Serial.print("init_Gui ... ");
  frm.print("!h<h1>ArduinoView</h1> <h2>Demo 0 - Hello World </h2>");
  frm.print("<p>Congratulation you transmitted the first HTML Code from your Arduino!!!</p>");
  frm.print("<img src=\"https://upload.wikimedia.org/wikipedia/commons/8/87/Arduino_Logo.svg\" height=\"200\" width=\"200\" >");
  frm.end();
  Serial.println("done");
}

void setup() {
  Serial1.begin(OUTPUT__BAUD_RATE);
  Serial.begin(9600);

  //request reset of gui
  frm.print("!!");
  frm.end();

  delay(500);
}

int i = 0;

void loop() {
  frm.run();

}
```
<script>
events.register("mc_stdout", e => { send.lia("output", e); });
events.register("mc_start", e => { send.lia("eval", "LIA: terminal"); });


let compile = `arduino-builder -compile -logger=machine -hardware /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/hardware -hardware /home/andre/.arduino15/packages -tools /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/tools-builder -tools /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/hardware/tools/avr -tools /home/andre/.arduino15/packages -built-in-libraries /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/libraries -libraries /home/andre/Arduino/libraries -fqbn="Robubot Micro:avr:microbot" -ide-version=10807 -build-path $PWD/build -warnings=default -prefs=build.warn_data_percentage=75 -prefs=runtime.tools.avr-gcc.path=/home/andre/.arduino15/packages/arduino/tools/avr-gcc/4.8.1-arduino5 -prefs=runtime.tools.avr-gcc-4.8.1-arduino5.path=/home/andre/.arduino15/packages/arduino/tools/avr-gcc/4.8.1-arduino5 -verbose sketch/sketch.ino`;


send.service("arduino", {start: "CodeRunner", settings: null})
.receive("ok", e => {
		send.lia("output", e.message);

		send.service("arduino", {files: {"sketch/sketch.ino": `@input`, "build/": ""}})
		.receive("ok", e => {
				send.lia("output", e.message);

				send.service("arduino",  {compile: compile, order: ["sketch.ino"]})
				.receive("ok", e => {
						send.lia("log", e.message, e.details, true);

            if(!window["bot_selected"]) {
              send.lia("eval", "LIA: stop");
            }
            else {

              send.service(
                "c",
                { connect: [["arduino", {"get_path": "build/sketch.ino.hex"}], ["mc", {"upload": null, "target": window["bot_selected"]}]]
                }
              );


              send.handle("input", (e) => {

                console.log("FFFFFFFFFFFFFFFFFF",
                  {id: "bot_stdin",
                             action: "call",
                             params: {procedure: "com.robulab.target."+window["bot_selected"]+".send_input", args: [0,  String.fromCharCode(0)+btoa(e) ] }}
                  );

                send.service("mc",  {id: "bot_stdin",
                           action: "call",
                           params: {procedure: "com.robulab.target."+window["bot_selected"]+".send_input", args: [0,  String.fromCharCode(0)+btoa(e) ] }})});



              send.handle("stop",  (e) => {
                send.service("mc", {id: "stdio0",
                                   action: "unsubscribe",
                                   params: {id: window["stdio0"], args: [] }});

                send.service("mc", {id: "stdio1",
                                   action: "unsubscribe",
                                   params: {id: window["stdio1"], args: [] }});

                send.service("mc",  {id: "bot_disconnect."+window["bot_selected"],
                           action: "call",
                           params: {procedure: "com.robulab.target.disconnect", args: [window["bot_selected"]] }})});
            }
				})
				.receive("error", e => { send.lia("log", e.message, e.details, false); console.log("DDDD", e); send.lia("eval", "LIA: stop"); });

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
    alert("fuckkkk alert");

    arduino_view_frame.contentWindow.ArduinoView.init = function () {
      alert("fuckkkk alert");

      arduino_view_frame.contentWindow.ArduinoView.sendMessage = function(e) {

        console.log("send_message", e);

        send.service("mc",  {id: "bot_stdin2",
                   action: "call",
                   params: {procedure: "com.robulab.target."+window["bot_selected"]+".send_input", args: [1,  String.fromCharCode(0)+btoa(e) ] }});
      };

      arduino_view_frame.contentWindow.ArduinoView.onInputPermissionChanged(true);
    };
  };

  arduino_view_frame.contentWindow.ArduinoView.sendMessage = function(e) {

    console.log("send_message", e);
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
    if(!window["mc_subscribed"]) {
        events.register("mc", e => {
           console.log("fuck", e);

           if(typeof(e) === "undefined")
              return;

           if(!!e.subscription) {
             if (e.subscription == "com.robulab.target.changed") {
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
               console.log("received: ", e)
               window["arduino_view_frame"].contentWindow.ArduinoView.onArduinoViewMessage(
                 String.fromCharCode.apply(this, e.parameters.args[0].data)

                 );
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
             let [cmd, target, id] = e.id.split(" ");

             send.service("mc", {id: "bot_stdio.0.target",
                                 action: "subscribe",
                                 params: {topic: "com.robulab.target."+target+".0.raw_out", args: [] }});

             send.service("mc", {id: "bot_stdio.1.target",
                                 action: "subscribe",
                                 params: {topic: "com.robulab.target."+target+".1.raw_out", args: [] }});

             events.dispatch("mc_start", "");

             aduinoview_init();
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
              update();
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
              update();
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
   }
};

function login(user, silent=true) {
    let form = document.getElementById("mcForm");
    let cmdi = document.getElementById("mcInterface");

    send.service("mc", {start: "MissionControl", settings: user})
    .receive("ok", (e) => {
        console.log("user-connected:", e);
        liaStorage.setItems({"MissionControl_user": user});
        if(!silent)
            alert("Success: You are now logged in!");
        form.hidden = true;
        cmdi.hidden = false;
        window["mc_logged_in"] = true;

        subscriptions();
    })
    .receive("error", (e) => {
        form.hidden = false;
        cmdi.hidden = true;
        console.log("user-connected:", e);
        alert("Fail: Please check your login!");
    });
};



  if(!localStorage.getItem("MissionControl_user")) {
    let form = document.getElementById("mcForm");
    form.hidden = false;

    if (!window.mc) {
      window["mc"] = () => {

        let user = {
          user: form.getElementsByTagName("input")[0].value,
          pass: form.getElementsByTagName("input")[1].value,
        };

        login(user, false);
      };
    }
  }
  else if (!window.mc_logged_in) {
    let user = JSON.parse( localStorage.getItem("MissionControl_user") );
    login(user);
  }

</script>

<form id="mcForm" onSubmit="window.mc(); return false;" hidden="true">
    <b>Please enter your Robybot login</b>
        <br><br>
    Email: <br>
        <input type="text" name="email"><br>
    Password: <br>
        <input type="password" name="password"><br>
        <br>
    <input type="submit" value="Submit">
</form>


<div id="mcInterface" hidden="true">
  <span id="bot_list" ></span>

  <span id="canvas" ></span>

  <iframe id="arduinoviewer" style="width: 100%; max-height: 260px;" src="http://localhost:4000/arduinoview"></iframe>
</div>


## Form

``` cpp sketch.ino
// -----------------------------------------------------------------
// Examples of the ArduinoView Library
// 0. Hello World
// -----------------------------------------------------------------
// This example demonstates the integration of html content within
// the arduino code

#include <FrameStream.h>
#include <Frameiterator.h>

#define OUTPUT__BAUD_RATE 57600
FrameStream frm(Serial1);

// We do not have any interaction in this example, but a default
// callback definition is need for frm.run().
// GUI initialisation request
beginrunnerlist();
callrunner(!!,InitGUI);
endrunnerlist();

void InitGUI(){
	Serial.print("init_Gui ... ");
  frm.print("!!");
  frm.print("!h<h1>ArduinoView</h1> <h2>Demo 0 - Hello World </h2>");
  frm.print("<p>Congratulation you transmitted the first HTML Code from your Arduino!!!</p>");
  frm.print("<img src=\"https://upload.wikimedia.org/wikipedia/commons/8/87/Arduino_Logo.svg\" height=\"200\" width=\"200\" >");
  frm.end();
  Serial.println("done");
}

void setup() {
  Serial1.begin(OUTPUT__BAUD_RATE);
  Serial.begin(9600);

  InitGUI()

  //request reset of gui
  //frm.print("!!");
  //frm.end();



  delay(500);
}

int i = 0;

void loop() {
  Serial.print(++i);
  Serial.println(" ... xxx");
  frm.run();
  delay(2000);
}
```
<script>
events.register("mc_stdout", e => { send.lia("output", e); });
events.register("mc_start", e => { send.lia("eval", "LIA: terminal"); });





let compile = `arduino-builder -compile -logger=machine -hardware /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/hardware -hardware /home/andre/.arduino15/packages -tools /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/tools-builder -tools /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/hardware/tools/avr -tools /home/andre/.arduino15/packages -built-in-libraries /home/andre/Downloads/arduino-1.8.7-linux64/arduino-1.8.7/libraries -libraries /home/andre/Arduino/libraries -fqbn="Robubot Micro:avr:microbot" -ide-version=10807 -build-path $PWD/build -warnings=default -prefs=build.warn_data_percentage=75 -prefs=runtime.tools.avr-gcc.path=/home/andre/.arduino15/packages/arduino/tools/avr-gcc/4.8.1-arduino5 -prefs=runtime.tools.avr-gcc-4.8.1-arduino5.path=/home/andre/.arduino15/packages/arduino/tools/avr-gcc/4.8.1-arduino5 -verbose sketch/sketch.ino`;


send.service("arduino", {start: "CodeRunner", settings: null})
.receive("ok", e => {
		send.lia("output", e.message);

		send.service("arduino", {files: {"sketch/sketch.ino": `@input`, "build/": ""}})
		.receive("ok", e => {
				send.lia("output", e.message);

				send.service("arduino",  {compile: compile, order: ["sketch.ino"]})
				.receive("ok", e => {
						send.lia("log", e.message, e.details, true);

            if(!window["bot_selected"]) {
              send.lia("eval", "LIA: stop");
            }
            else {

              send.service(
                "c",
                { connect: [["arduino", {"get_path": "build/sketch.ino.hex"}], ["mc", {"upload": null, "target": window["bot_selected"]}]]
                }
              );


              send.handle("input", (e) => {

                console.log("FFFFFFFFFFFFFFFFFF",
                  {id: "bot_stdin",
                             action: "call",
                             params: {procedure: "com.robulab.target."+window["bot_selected"]+".send_input", args: [0,  String.fromCharCode(0)+btoa(e) ] }}
                  );

                send.service("mc",  {id: "bot_stdin",
                           action: "call",
                           params: {procedure: "com.robulab.target."+window["bot_selected"]+".send_input", args: [0,  String.fromCharCode(0)+btoa(e) ] }})});



              send.handle("stop",  (e) => {
                send.service("mc",  {id: "bot_disconnect."+window["bot_selected"],
                           action: "call",
                           params: {procedure: "com.robulab.target.disconnect", args: [window["bot_selected"]] }})});




            }
				})
				.receive("error", e => { send.lia("log", e.message, e.details, false); console.log("DDDD", e); send.lia("eval", "LIA: stop"); });

		})
		.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });
})
.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });

"LIA: wait";

</script>










<script>
function aduinoview_init() {

  let arduino_view_frame = document.getElementById("arduinoviewer").contentWindow.ArduinoView;

  window["arduino_view_frame"] = arduino_view_frame;

  arduino_view_frame.set_init(console.log);

  arduino_view_frame.onInputPermissionChanged(true);

  arduino_view_frame.sendMessage = function(e){
      console.log("sendMessage", e);

//      send.service("mc",  {id: "bot_stdin2",
  //               action: "call",
    //             params: {procedure: "com.robulab.target."+window["bot_selected"]+".send_input", args: [1,  String.fromCharCode(0)+btoa(e) ] }})});
  };




}

function update() {
  if(!window["bot_selected"]) {
    for(let i=0; i<window.bot_list.length; i++) {
      let btn = document.getElementById("button_"+window.bot_list[i].target);

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
    if(!window["mc_subscribed"]) {
        events.register("mc", e => {
           console.log(e);

           if(!!e.subscription) {
             if (e.subscription == "com.robulab.target.changed") {
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
               console.log("received: ", e)
               window["arduino_view_frame"].onArduinoViewMessage(
                 String.fromCharCode.apply(this, e.parameters.args[0].data)
                 );
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
             let [cmd, target, id] = e.id.split(" ");



             send.service("mc", {id: "stdio0",
                                 action: "subscribe",
                                 params: {topic: "com.robulab.target."+target+".0.raw_out", args: [] }});

             send.service("mc", {id: "stdio1",
                                 action: "subscribe",
                                 params: {topic: "com.robulab.target."+target+".1.raw_out", args: [] }});


             events.dispatch("mc_start", "");

             aduinoview_init();
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

                 send.service("mc", {id: "stdio0",
                                    action: "unsubscribe",
                                    params: {topic: "com.robulab.target."+target+".0.raw_out", args: [] }});

                 send.service("mc", {id: "stdio1",
                                    action: "unsubscribe",
                                    params: {topic: "com.robulab.target."+target+".1.raw_out", args: [] }});

              };
              update();
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

              update();
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
   }
};

function login(user, silent=true) {
    let form = document.getElementById("mcForm");
    let cmdi = document.getElementById("mcInterface");

    send.service("mc", {start: "MissionControl", settings: user})
    .receive("ok", (e) => {
        console.log("user-connected:", e);
        liaStorage.setItems({"MissionControl_user": user});
        if(!silent)
            alert("Success: You are now logged in!");
        form.hidden = true;
        cmdi.hidden = false;
        window["mc_logged_in"] = true;

        subscriptions();
    })
    .receive("error", (e) => {
        form.hidden = false;
        cmdi.hidden = true;
        console.log("user-connected:", e);
        alert("Fail: Please check your login!");
    });
};



  if(!localStorage.getItem("MissionControl_user")) {
    let form = document.getElementById("mcForm");
    form.hidden = false;

    if (!window.mc) {
      window["mc"] = () => {

        let user = {
          user: form.getElementsByTagName("input")[0].value,
          pass: form.getElementsByTagName("input")[1].value,
        };

        login(user, false);
      };
    }
  }
  else if (!window.mc_logged_in) {
    let user = JSON.parse( localStorage.getItem("MissionControl_user") );
    login(user);
  }

</script>

<form id="mcForm" onSubmit="window.mc(); return false;" hidden="true">
    <b>Please enter your Robybot login</b>
        <br><br>
    Email: <br>
        <input type="text" name="email"><br>
    Password: <br>
        <input type="password" name="password"><br>
        <br>
    <input type="submit" value="Submit">
</form>


<div id="mcInterface" hidden="true">
  <span id="bot_list" ></span>

  <span id="canvas" ></span>

  <!--iframe id="arduinoviewer" style="width: 100%; height: 360px;" src="http://localhost:4000/sandbox"></iframe-->
</div>
