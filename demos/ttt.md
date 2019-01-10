<!--
author:   André Dietrich

email:    andre.dietrich@ovgu.de

version:  0.0.1

language: de

narrator: Deutsch Female

comment:  Eine kleine Einführung in die Grundlagen der Regelungstechnik.

link:     https://cdn.jsdelivr.net/chartist.js/latest/chartist.min.css

script:   https://cdn.jsdelivr.net/chartist.js/latest/chartist.min.js

script:   https://canvasjs.com/assets/script/canvasjs.min.js


@eval
<script>
function frmt(x, n) {
    return Number.parseFloat(x).toFixed(n);
}



function reportError(error) {
   let line = getLineNumber(error);
   let details = [];
   let msg = "An error occured";

  if (line) {
    details = [[{ row : line-1,
               column : 0,
                 text : error.message,
                 type : "error" }]];

    msg += " on line " + line;
  }
  send.lia("eval", msg + "\n" + error.message, details, false);
};

async function eeval(code) {
  function update(t, w, ist) {
      dps_ist.push({x: t, y: ist});
      dps_soll.push({x: t, y: w});
      chart.render();
  }

  let dps_ist  = [];  // dataPoints
  let dps_soll = []; // dps2

  document.getElementById("container@0").hidden = false;

  let chart = new CanvasJS.Chart("container@0", {
      title :{ text: "@0"   },
      axisY: { includeZero: false },
      data: [{ name: "Ist-Wert",
               showInLegend: true,
               type: "line",
               dataPoints: dps_ist },
             { name: "Soll-Wert",
               showInLegend: true,
               type: "line",
               dataPoints: dps_soll }]
  });

  function print(e) {
      send.lia("log", e + "\n");
  }

  const sleep = (milliseconds) => {
      return new Promise(resolve => setTimeout(resolve, milliseconds))
  }

  try {
    code = code.replace("wait", "await sleep");
    const evalString = '(async function runner() { try { ' + code + '} catch (e) { reportError(e) } })()';

    await eval(evalString).catch(function(e) {
      reportError(e);
    });
    send.lia("eval", "LIA: stop");
  }
  catch(e) {
    reportError(e);
  }
};
setTimeout(function(e){ eeval(`@input`+"\n") }, 100);

"LIA: wait";
</script>

<div hidden="true" id="container@0" class="persitent" style="height: 370px; width:100%;"></div>

@end



-->

# Regelungstechnik eine Einführung

Auch wenn es sich vielleicht technisch anhört und sehr oft kompliziert
beschrieben wird, so ist eine Regelung ein sehr altes Konzept, das schon weit
vor dem Menschen von Mutter-Natur genutzt wurde, damit ihre Organismen sich auf
Änderungen der Umgebung anpassen können.

Damit ist hier jedoch nicht die Evolution gemeint, sondern die vielen kleinen
Abläufe, die im inneren eines jeden Organismus stattfinden, wie die
Konstanthaltung der Körpertemperatur oder des Blutzuckerspiegels, die Anpassung
der Pupille and Helligkeitsänderungen, das Halten den Gleichgewichts, bei
einfachen Organismen können sogar deren Verhaltensweisen leicht mit
regelungstechnischen Mechanismen erklärt werden.

Die ersten Menschen, die dieses Prinzip nachweislich, erkannten und nutzten
waren, nicht wie so oft erwähnt, die Ingenieure des 17. und 18. Jahrhunderts wie
zum Beispiel James Watt[^1] mit seinem Fliehkraftregler, sondern Mechaniker der
griechischen Antike, wie Ktesibios, Philon und Heron, die Schwimmerregelungen
erdachten, wobei die ursprüngliche Anwendung im Bau von Wasseruhren lag.

[^1]: James Watt wird oft auch fälschlicherweise die Erfindung der Dampfmaschine
      angedichtet, dieser erkannte jedoch nur deren wirtschaftliches und
      industrielles Potential und verbesserte die von Thomas Newcomen 1712
      konstruierte Dampfmaschine.

## 1. Gundlagen

**Also was ist nun eine Regelung?**

Die Abbildung zeigt den typischen Aufbau eines einschleifigen Regelkreises,
hierbei wird im Gegensatz zu einer Steuerung (die hier nicht behandelt werden
soll) mit dem Prinzip der Rückkopplung (Feedback) gearbeitet. Dabie wird die zu
regelnde Größe (Ist-Wert) fortwährend überwacht und mit einer anderen Größe, der
Führungsgröße (Soll-Wert), verglichen. Die Regelgröße kann durch verschiedene
externe Kräfte (Regelstrecke) gestört werden und damit von der Führungsgröße
abweichen.

Ein Vorteil gegenüber der Steuerung ist, dass diese störenden Kräfte nicht im
Einzelnen erfasst werden müssen (eventuell ist dies gar nicht möglich), vielmehr
wird nur der Unterschied zwischen Regel- und Führungsgröße (Ist- und Soll-Wert)
als Gesamtfehler (oder Regelabweichung) betrachtet. In Abhängigkeit dieses
Gesamtfehlers wird versucht, eine dritte Größe (Stellgröße) in geeigneter Weise
zu beeinflussen, um die Regelabweichung zu minimieren.

Was hier noch nicht erläutert wurde, das ist die Regeleinrichtung. Dabei handelt
es sich um den eigentlichen Regler, also P, I, D und die die Kombinationen
daraus, sowie weiter Arten. In den folgenden Abschnitten werden wir die
verschieden Reglerarten noch näher erläutern.

````
                                                        Störgröße -+
                                                           d(t)    |
 Führungsgröße     Regelabweichung           Stellgröße            v
          w(t)     e(t)   +------------------+  u(t)  +--------------+
     ---------> o ------> | Regeleinrichtung |------->| Regelstrecke |----- o ----->
                          +------------------+        +--------------+      |
                ^                                                           |
                |___________________________________________________________|
                                (Rückführung der Messgröße)
````

Betrachten wir das Beispiel nochmal kurz aus den Blickwinkel eines Autofahrers
auf der Autobahn (ohne Abstandsautomatik, CruiseControl, etc.). Der Fahrer muss
die Geschwindigkeit seines PKWs ständig an die verschiedenen
Richtgeschwindigkeiten und die aktuelle Verkehrssituation anpassen. Die
Führungsgröße steht hier für die vorgegebene Richtgeschwindigkeit, die
Regelgröße steht für die Geschwindigkeit des Fahrzeugs. Über das Tachometer kann
der Autofahrer ständig vergleichen, wie sich seine aktuelle Geschwindigkeit von
der Richtgeschwindigkeit unterscheidet (Rückkopplung). Ausgehend von diesem
Geschwindigkeitsunterschied beschleunigt oder bremst der Autofahrer, die
Stellgröße, mit der er auf die Geschwindigkeit einwirkt, ist sein Fuß auf dem
Gaspedal. Störkräfte könnten in diesem Beispiel die verschiedenen Anstiege oder
Kurven der Fahrstrecke, aber auch andere Autofahrer sein. Aufgrund der Störungen
oder der Änderung der Richtgeschwindigkeit ist der Fahrer immer wieder
gezwungen, seine Geschwindigkeit anzupassen (Regeln).

Wie jeder Fahrer auf das Gaspedal tritt, eher langsam und zaghaft oder schnell
und ruppig, wird durch seine Art und Regelparameter bestimmt.

## 2. Arten von Regelungen

Je nach Regelungsaufgabe gibt es eine Vielzahl verschiedener Typen von
Regelungen, die ihrerseits spezifische Vor- und Nachteile besitzen. Durch die
Kombination verschiedener Regler lassen sich wiederum andere Regler finden mit
wieder anderen Eigenschaften (in diesem Zusammenhang spricht man auch Reglern,
bestehend aus Regelgliedern). Welcher der ideale Regler für eine gegebene
Regelungsaufgabe ist, lässt sich meist nur schwer ermitteln. Man benötigt zum
Teil genaue Kenntnis der Regelstrecke, erschwerend können noch
Güteforderungen[^1] hinzukommen und wurde schließlich ein Regler gefunden, so
müssen noch dessen Parameter angepasst werden.

Die wichtigsten klassischen Regler sollen im Folgenden kurz vorgestellt werden.
Dazu zählen Proportional-, Integral- und Differenzialregler.

[^1]: Güteforderungen können u. a.die Stabilität, die Störkompensation und
      Sollwertfolge, sowie die Robustheit der Regler betreffen.

### 2.1 Proportionalregler

In ihrer einfachsten Form spricht man von einem verzögerungsfreien P-Regler,
dabei verändert sich der Wert der Stellgröße $u(t)$ proportional zur
Regelabweichung $e(t)$:

$$ u_{R} (t) = K_{P} * e_{R} (t)$$

Der statische Faktor $K_{P}$ gibt die Stärke an, mit der der P-Regler auf die
Regelabweichung reagiert. Bei dem hier vorgestellten Regler handelt es sich des
Weiteren um einen Regler mit Proportionalglied 0ter Ordnung (PT0). Die Ordnung
eines Gliedes gibt dessen Verzögerung an. Wie man ebenfalls in Abbildung 3.3(a)
erkennt, kann dieser Regler nur sehr begrenzt eingesetzt werden, anders sieht
das jedoch bei P-Reglern höherer Ordnung aus.

Ein P-Regler erster Ordnung (mit PT1-Glied) folgt der Differenzialgleichung:

$$T * \dot{u} (t) + u(t) = K_P * e(t) , u(0) = u_0$$


Analog dazu die Differenzialgleichung eines PT2-Gliedes:

$$T^2 * \ddot{u}(t) + 2 * D * T * \dot{u}(t) + u(t) = K_P * e(t)$$

Bei $T$ handelt es sich wieder um eine Zeitkonstante und bei $D$ um einen
Dämpfungsfaktor. Je nach Wahl dieser Faktoren können die Regler mit stark
unterschiedlichem Schwingverhalten reagieren.

Der Vorteil des P-Reglers liegt in der schnellen Reaktion auf Änderungen der
Regelgröße, die jedoch mit steigender Ordnung abschwächt, was zu einem erhöhten
Zeitverbrauch beim Erreichen eines statischen Endwerts führen kann. Jedoch
können P-Regler höherer Ordnung durch die Dämpfung ihrer Reaktion besser mit
Schwingungen bezüglich der Regelgröße umgehen. Des Weiteren neigen P-Regler bei
einem zu hohen Wert für $K_P$ zu Schwingungen, was mitunter zu einer bleibenden
Regeldifferenz führen kann. Eine bleibende Regeldifferenz tritt zum Teil auch
bei einem zu klein gewählten $K_P$ auf, der Regler findet zwar einen statischen
Endwert, dieser liegt dann jedoch weit unter dem Optimum.

### 2.2 Integralregler

Beim integralwirkenden Regler (I-Regler) wird die Stellgröße $u(t)$ durch
Integration der Regeldifferenz $e(t)$ gebildet. Die Stellgröße strebt dabei
nur einem konstanten Wert zu, wenn die Regeldifferenz mit fortschreitender Zeit
$t$ gegen null geht. Das verzögerungsfreie I-Glied wird durch die
Differenzialgleichung

$$T_I \dot{u}(t) = e(t), u(0) = u_0$$

mit $T_I$ als Integrationskonstanten, beschrieben. Nach dem Hauptsatz der
Differenzial- und Integralgleichung erhält man für den Anfangswert
$u(0) = u_0$ die eindeutige Lösung:

$$ u(t) = \frac{1}{T_I} * \int_{0}^{t} e(t) dt + u_0 $$

Es lassen sich auch I-Regler mit Verzögerungsgliedern beschreiben, diese sollen
hier jedoch nicht näher erläutert werden.

Integralwirkende Regel sind im Vergleich zu anderen Reglern zwar langsamer,
haben jedoch den Vorteil, dass sie eine Abweichung von Soll- zu Regelgröße
vollständig eliminieren können.

### 2.3 Differenzialregler

Bei differenzialwirkenden Regelungsgliedern (D-Regler) bestimmt die Änderung der
Regelabweichung die der Stellgröße. Ein verzögerungsfreies D-Glied ist wie folgt
definiert:

$$ u(t) = T_D \frac{de(t)}{dt} $$

Reale physikalische Systeme lassen sich praktisch nicht mit Reglern, bestehend
aus einem verzögerungsfreien D-Glied, regeln, da die Stellgröße hier nur mit
einem Diracimpuls antwortet. Das heißt, die Stellgröße steigt zu Beginn
unverhältnismäßig stark und geht dann bei konstanter Regeldifferenz gegen null.
Aus diesem Grund müssen D-Glieder auch mit anderen Regelgliedern kombiniert
werden, vorzugsweise mit P-Reglern, sie werden aber auch zur Stabilisierung von
I-Reglern höherer Ordnung eingesetzt. Ein Nachteil aller Regler mit D-Anteil ist
die Unruhe bei verrauschtem Eingangssignal. Das Rauschen wird verstärkt und über
die Stellgröße wieder in den Regelkreis, was unter anderem auch zu starken
Schwingungen der Stellgröße führen kann.

## 3. Digital-/Software-Regeler und deren Kombination

TODO:

In den folgenden Abschnitten soll kurz erläutert werden, wie Da die späteren
Simulationen auf einem zeitdiskreten Modell basieren, soll in nun die
Diskretisierung der bereits vorgestellten Regler erläutert werden. Des Weiteren
werden PI-, PD- und PID-Regler durch Kombination der Standardregler gebildet.

### 3.1 P-Software-Regler


                                 --{{0}}--
Das folgende Programm zeigt die Simulation einer PT0-Reglers samt Regelstrecke.
Ziemlich trivial oder? Die Forschleife simuliert die diskreten Zeitschritte und
die Funktion `Regelstrecke` ist durch einfache "Konstanten"-Funktion definiert,
auf die $u$ unterschiedlich einwirkt.

$$ u(t) = K_P * e(t) $$


                                 --{{1}}--
Wenn ihr ein wenig mit den Wert für `Kp` experimentiert, dann werdet ihr schnell
merken, dass dieser Regler allein sehr unbrauchbar ist und für große Werte
schnell Überschwingt und bei allen kleineren Werten sein Soll niemals erreicht.
Er ist deshalb nur in einigen  Spezialfällen nützlich. Ein viel besseres
Ergebnis liefert die Kombination mit einem Integral-Regler, der im nächsten Abschnitt vorgestellt wird.


```javascript
let w  = 1;   // Führungsgröße (Sollwert)
let e  = 0;   // Regelabweichung (Gesamtfehler)
let u  = 0;   // Stellgröße (Druck auf das Gaspedal)
let Kp = 0.6; // proportional Faktor (stärke der Reaktion)
// Speicher für den ist-Wert als Ergebnis der Regelstrecke
let ist = 0;

// eine einfache (konstante) Regelstrecke für den Anfang
function Regelstrecke(t, u) {
    if (t < 50)
      return 0 + u;
    else
      return 2 + u
}

for(let t = 0; t < 100; t++) {
    ist = Regelstrecke(t, u);

    e = w - ist; // Feedback ... Berechnung des Gesamtfehlers
    u = Kp * e;  // Bestimmung der neuen direkten Stellgröße

    print("t: "+t+" soll:"+frmt(w,12)+" ist:"+frmt(ist,12)+" e:"+frmt(e,12));

    update(t, w, ist);  // plotten der Ergebnisse im Diagram
    wait(50);           // verzögert den Schleifendurchlauf um 50ms
}
```
@eval(PT0-Regler)


#### 3.1.2 PT1-Simulation

                                 --{{0}}--
Kleine Änderung und große Wirkung, indem wir einfach die alte Stellgröße
$u(t-1)$ mitschleifen und zur neuen Stellgröße addieren funktioniert der Regler
auf einmal prächtig. Ihr könnt mit verschiedenen Einstellungen experimentieren,
für welchen `Kp` Faktor beginnt das System zu schwingen, beziehungsweise wann
kippt es um.

$$ u(t) = K_P * e(t) + u(t - 1) $$


```javascript
let w  = 10;  // Führungsgröße (Sollwert)
let e  = 0;   // Regelabweichung (Gesamtfehler)
let u  = 0;   // Stellgröße (Druck auf das Gaspedal)
let Kp = 1.5; // proportional Faktor (stärke der Reaktion)
// Speicher für den ist-Wert als Ergebnis der Regelstrecke
let ist = 0;

// eine einfache (konstante) Regelstrecke für den Anfang
function Regelstrecke(t, u) {
    return 1 + u;
}

for(let t = 0; t < 100; t++) {
    ist = Regelstrecke(t, u);

    e = w - ist;    // Feedback ... Berechnung des Gesamtfehlers
    u = Kp * e + u; // Bestimmung der neuen verzögerten Stellgröße

    print("t: "+t+" soll:"+frmt(w,12)+" ist:"+frmt(ist,12)+" e:"+frmt(e,12));

    update(t, w, ist);  // plotten der Ergebnisse im Diagram
    wait(50);           // verzögert den Schleifendurchlauf um 50ms
}
```
@eval(PT1-Regler)


                                 --{{1}}--
Wenn ihr ein wenig mit unterschiedlichen Regelstrecken experimentiert, dann
werdet ihr schnell herausfinden, dass dieser Regler sehr viel robuster und
adaptiver ist, als ein einfacher PT0-Regler, aber auch dieser Regler neigt zu
Schwingungen und hat Probleme den Gesamtfehler exakt zu minimieren. Ihr könnt
versuchen dies durch einen PTn-Regler zu kompensieren, versucht es für euch
allein. Oder man könnte die Schwingungen auch durch einen zusätzlichen I-Anteil
abgeschwächen...

    {{1}}
``` javascript
function Regelstrecke(t, u) {
  if(t < 33)
    return 0 - u;
  else if(t < 66)
    return t - u;
  else
    return t * 0.1 - u;
}
```

### 3.2 I-Software-Regler

Aus der Gleichung für den I-Regler:

$$ u(t) = \frac{1}{T_I} * \int_{0}^{t} e(t) dt + u_0 $$

erhält man durch Diskretisieren die folgende Gleichung:


$$
   u(t) = K_I * \sum^{t}_{t = 0} e(t) + u(0) ,

   \mathrm{mit}\; K_I = \frac{1}{T_I}
$$

```javascript
let w  = 1; // Führungsgröße (Sollwert)
let e  = 0;   // Regelabweichung (Gesamtfehler)
let u  = 0;   // Stellgröße (Druck auf das Gaspedal)
let Ki = 0.2; // integral Faktor (stärke der Reaktion)
// Speicher für den ist-Wert als Ergebnis der Regelstrecke
let ist = 0;

// eine einfache (konstante) Regelstrecke für den Anfang
function Regelstrecke(t, u) {
    if (t < 50)
      return 0 + u;
    else
      return 2 + u
}

for(let t = 0; t < 100; t++) {
    ist = Regelstrecke(t, u);

    e = e + (w - ist); // Integration des Gesamtfehlers
    u = Ki * e;        // Bestimmung der neuen verzögerten Stellgröße

    print("t: "+t+" soll:"+frmt(w,12)+" ist:"+frmt(ist,12)+" e:"+frmt(e,12));

    update(t, w, ist); // plotten der Ergebnisse im Diagramm
    wait(50);          // verzögert den Schleifendurchlauf um 50ms
}
```
@eval(I-Regler)


### 3.3 PD-Software-Regler

Analog zur Bestimmung des P-Software-Reglers kann hier aus der Gleichung des
D-Reglers:

$$ u(t) = K_D \frac{de(t)}{dt} $$

durch Diskretisieren die folgende Gleichung gewonnen werden:

$$ u(t) = K_D \frac{e(t) - e(t-1)}{T} $$

$T$ steht in dieser Gleichung für die Abtastzeit. Wie man erkennt, verändert
sich bei konstanter Regelabweichung die Stellgröße nicht, weshalb dieser Regler
auch mit P- und/oder I-Reglern kombiniert werden muss. Diese Kombination der
Regelglieder geschieht durch einfache Addition. Vereinfachend für $T = 1$
ergibt sich dann die folgende Gleichung für den PD-Regler:

$$ u(t) = \underbrace{K_P * e(t)}_{\text{Proportionalteil}}
        + \overbrace{K_D * (e(t) - e(t-1))}^{\text{Differenzialteil}} $$


```javascript
let w  = 1; // Führungsgröße (Sollwert)
let e_old  = 0;   // Regelabweichung (Gesamtfehler)
let e_new  = 0;
let u  = 0;    // Stellgröße (Druck auf das Gaspedal)
let Kp = 0.6;  // integral Faktor (stärke der Reaktion)
let Kd = 0.15; // integral Faktor (stärke der Reaktion)
// Speicher für den ist-Wert als Ergebnis der Regelstrecke
let ist = 0;

// eine einfache (konstante) Regelstrecke für den Anfang
function Regelstrecke(t, u) {
    if (t < 50)
      return 0 + u;
    else
      return 2 + u
}

for(let t = 0; t < 100; t++) {
    ist = Regelstrecke(t, u);

    e_old = e_new;
    e_new = (w - ist); // Integration des Gesamtfehlers
    u = Kp * e_new + Kd * (e_new - e_old);        // Bestimmung der neuen verzögerten Stellgröße

    print("t: "+t+" soll:"+frmt(w,12)+" ist:"+frmt(ist,12)+" e:"+frmt(e_new,12));

    update(t, w, ist); // plotten der Ergebnisse im Diagramm
    wait(50);          // verzögert den Schleifendurchlauf um 50ms
}
```
@eval(PD-Regler)

Ein besserer Regler ergibt sich durch Kombination von D- und PT1-Glied:

$$ u(t) = \underbrace{K_P * e(t) + u(t-1)}_{\text{Proportionalteil}}
        + \overbrace{K_D * (e(t) - e(t-1))}^{\text{Differenzialteil}} $$


``` javascript
let w  = 10; // Führungsgröße (Sollwert)
let e  = 0;   // Regelabweichung (Gesamtfehler)
let e_1 = 0;
let u  = 0;   // Stellgröße (Druck auf das Gaspedal)
let Kd = 0.5; // integral Faktor (stärke der Reaktion)
let Kp = 0.4;
// Speicher für den ist-Wert als Ergebnis der Regelstrecke
let ist = 0;

// eine einfache (konstante) Regelstrecke für den Anfang
function Regelstrecke(t, u) {
    return 0 + u;
}

for(let t = 0; t < 100; t++) {
    ist = Regelstrecke(t, u);

    e_1 = e;

    e = (w - ist); // Integration des Gesamtfehlers

    u = Kp*e +u + Kd * (e - e_1);        // Bestimmung der neuen verzögerten Stellgröße

    print("t: "+t+" soll:"+frmt(w,12)+" ist:"+frmt(ist,12)+" e:"+frmt(e,12));

    update(t, w, ist); // plotten der Ergebnisse im Diagramm
    wait(100);          // verzögert den Schleifendurchlauf um 50ms
}
```
@eval(PT1D-Regler)

Der D-Anteil bewertet die Änderung der Regelabweichung und bestimmt so deren
Änderungsgeschwindigkeit. Diese wird mit dem Faktor $K_D$ multipliziert und zum
P-Anteil hinzuaddiert. Der PD-Regler reagiert damit schon auf Ankündigungen von
Veränderungen und damit ist ein PD-Regler meist schneller als ein P- oder
PI-Regler.

### 3.4 PI-Software-Regler

Wie beim PD-Regler, so kann auch der PI-Regler einfach durch Addition von P- und
I-Glied gebildet werden:

$$ u(t) = \underbrace{K_P * e(t)}_{\text{Proportionalteil}}
        + \overbrace{K_I * \sum^{t}_{t = 0} e(t) + u(0)}^{\text{Integralteil}} $$



```javascript
let w  = 1; // Führungsgröße (Sollwert)
let e  = 0;
let e_sum = 0;   // Regelabweichung (Gesamtfehler)
let u  = 0;    // Stellgröße (Druck auf das Gaspedal)
let Kp = 0.6;  // integral Faktor (stärke der Reaktion)
let Ki = 0.15; // integral Faktor (stärke der Reaktion)
// Speicher für den ist-Wert als Ergebnis der Regelstrecke
let ist = 0;

// eine einfache (konstante) Regelstrecke für den Anfang
function Regelstrecke(t, u) {
    if (t < 50)
      return 0 + u;
    else
      return 2 + u
}

for(let t = 0; t < 100; t++) {
    ist = Regelstrecke(t, u);

    e = (w - ist); // Integration des Gesamtfehlers
    e_sum += e;
    u = Kp * e + Ki * e_sum;        // Bestimmung der neuen verzögerten Stellgröße

    print("t: "+t+" soll:"+frmt(w,12)+" ist:"+frmt(ist,12)+" e:"+frmt(e,12));

    update(t, w, ist); // plotten der Ergebnisse im Diagramm
    wait(50);          // verzögert den Schleifendurchlauf um 50ms
}
```
@eval(PI-Regler)


### 3.5 PID-Software-Regler

$$ u(t) = \underbrace{K_P * e(t)}_{\text{Proportionalteil}}
        + \overbrace{K_I * \sum^{t}_{t = 0} e(t) + u(0)}^{\text{Integralteil}}
        + \underbrace{K_D * (e(t) - e(t-1))}_{\text{Differenzialteil}}
$$


```javascript
let w  = 1; // Führungsgröße (Sollwert)
let e  = 0;
let e_dif = 0;
let e_sum = 0;   // Regelabweichung (Gesamtfehler)
let u  = 0;    // Stellgröße (Druck auf das Gaspedal)
let Kp = 0.6;  // integral Faktor (stärke der Reaktion)
let Ki = 0.2;  // integral Faktor (stärke der Reaktion)
let Kd = 0.1;
// Speicher für den ist-Wert als Ergebnis der Regelstrecke
let ist = 0;

// eine einfache (konstante) Regelstrecke für den Anfang
function Regelstrecke(t, u) {
    if (t < 50)
      return 0 + u;
    else
      return 2 + u
}

for(let t = 0; t < 100; t++) {
    ist = Regelstrecke(t, u);


    e = (w - ist); // Integration des Gesamtfehlers
    e_dif = e_dif - e;

    e_sum += e;
    u = Kp * e + Ki * e_sum + Kd * e_dif;        // Bestimmung der neuen verzögerten Stellgröße

    print("t: "+t+" soll:"+frmt(w,12)+" ist:"+frmt(ist,12)+" e:"+frmt(e,12));

    update(t, w, ist); // plotten der Ergebnisse im Diagramm
    wait(50);          // verzögert den Schleifendurchlauf um 50ms
}
```
@eval(PID-Regler)


## Code

```javascript
let i = 0;
let soll = 20;
let p = 0.5;
let fehler = 0;

function strecke(x) {
    return 1;
}

for(i = 0; i < 100; i++) {
    let ist = strecke(i);

    fehler = soll - ist;

    print("ist:"+ ist+ " soll:" + soll + " fehler:" + fehler);
}
```
<script>
function print(e) {
    send.lia("log", e + "\n");
}

setTimeout(function(e) {
    eval(`@input`);
    send.lia("eval", "LIA: stop")
}, 300);

"LIA: wait"
</script>

<div class="ct-chart ct-golden-section" id="chart1"></div>
<div class="ct-chart ct-golden-section" id="chart2"></div>


### Projects

You can make your code executable and define projects:

``` js     -EvalScript.js
let who = data.first_name + " " + data.last_name;

if(data.online) {
  who + " is online"; }
else {
  who + " is NOT online"; }
```
``` json    +Data.json
{
  "first_name" :  "Sammy",
  "last_name"  :  "Shark",
  "online"     :  true
}
```
<script>
  // insert the JSON dataset into the local variable data
  let data = @input(1);

  // eval the script that uses this dataset
  eval(`@input(0)`);
</script>

## More

Find out what you can even do more with quizzes:

https://liascript.github.io/course/?https://raw.githubusercontent.com/liaScript/docs/master/README.md
