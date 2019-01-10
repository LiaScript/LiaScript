<!--

author:   Noname

email:    nomail

version:  1.0.0

language: en

narrator: US English Female

comment:  Brython Template

script:   https://brython.info/src/brython.js



-->

# Brython Template

asdfsafd

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

``` python
hellos = input()

for i in range(hellos):
  print(i)
```
<script>
let output = "";
brython({debug: 1});
window.__BRYTHON__.stdout.write = function(e) { output += e; };


let x = window.__BRYTHON__.python_to_js(`@input`);

eval.call(window, x);

output;
</script>


``` js

```
<script>
@input
</script>



# brython_template
Python (brython) programming template for LiaScript
