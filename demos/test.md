<!--
author:   Your Name

email:    your@mail.org

version:  0.0.1

language: en

narrator: US English Female

comment:  Try to write a short comment about
          your course, multiline is also okay.


@HTML: @__HTML(@uid)

@__HTML
<script>
    document.getElementById("container_@0").innerHTML = `@input`;
    "LIA: stop";
</script>

<div id="container_@0" class="persistent"></div>
@end

@JavaScript
<script>
let log = console.log;

console.log = function(e){ send.lia("log", e+"\n") };

eval(`@input`)

console.log = log;

"LIA: stop";
</script>
@end

@HTML_JavaScript
<script>
document.getElementById("@0").innerHTML = `@input`;

let log = console.log;

console.log = function(e){ send.lia("log", e+"\n") };

eval(`@input(1)`);

console.log = log;

"LIA: stop";
</script>

<div id="@0"></div>
@end

-->

# WebDev Template

[[solution]]
<script>
  // @input will be replace by the user input
  let input_string = "@input";
  console.log("dddddddddd", input_string.trim().toLowerCase());
  false;
</script>

## HTML

``` html table.html
<h1>This is an example of a table</h1>

<table>
    <tr>
      <th style="text-align:left"> Header 1 </th>
      <th style="text-align:left"> Header 2 </th>
    </tr>
    <tr>
      <td style="text-align:left"> row 1.1 </td>
      <td style="text-align:left"> row 1.2 </td>
    </tr>
    <tr>
      <td style="text-align:left"> row 2.1 </td>
      <td style="text-align:left"> row 2.2 </td>
    </tr>
</table>
```
@HTML


``` html table.html
<h1>This is an example of a table</h1>

<table>
    <tr>
      <th style="text-align:left"> Header 1 </th>
      <th style="text-align:left"> Header 2 </th>
    </tr>
    <tr>
      <td style="text-align:left"> row 1.1 </td>
      <td style="text-align:left"> row 1.2 </td>
    </tr>
    <tr>
      <td style="text-align:left"> row 2.1 </td>
      <td style="text-align:left"> row 2.2 </td>
    </tr>
</table>
```
@HTML


``` html table.html
<h1>This is an example of a table</h1>

<table>
    <tr>
      <th style="text-align:left"> Header 1 </th>
      <th style="text-align:left"> Header 2 </th>
    </tr>
    <tr>
      <td style="text-align:left"> row 1.1 </td>
      <td style="text-align:left"> row 1.2 </td>
    </tr>
    <tr>
      <td style="text-align:left"> row 2.1 </td>
      <td style="text-align:left"> row 2.2 </td>
    </tr>
</table>
```
@HTML

## JavaScript

``` javascript for-loop.js
let fak = 1;

for(let i=1; i<10; i++) {
  fak = fak * i;
  console.log("i: " + i + "  fak:"+ fak);
}

console.log("fin")
```
@JavaScript


## HTML & JavaScript

```html index.html
<h1 id="hallo_id"> Hallo </h1>
```
```javascript  test.js
document.getElementById("hallo_id").innerHTML = "TEST";
```
@HTML_JavaScript(example2)



## Charts


                                Multiline
1.9 |
    |    DOTs         ***
  y |               *     *
  - | r r r r r r r*r r r r*r r r r r r r
  a |             *         *
  x |            *           *
  i | B B B B B * B B B B B B * B B B B B
  s |         *                 *
    | *  * *                       * *  *
 -1 +------------------------------------
    0              x-axis               1


               Title - dots
6 | A a B b C c
  | D d E e F f G g H h I i
  | J j K k L l M m N n o O
  | P p Q q R r S s T t U u
  | V v W w X x Y y Z Z   *
1 +------------------------
  0                      24
