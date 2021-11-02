# Iconfont Process

If you want to add additional icons, then create a svg and put it into
the subFolder icons.

Build via:

``` bash
# initialize the sub-project and download the dependencies 
$ npm i

# translating the svgs via gulp
$ npm run build
```

## Folder Structure

## Iconfont Preview

After the Gulp task "template-iconfont" has been executed, there will be a
new preview in
[`/fonts/icon/dist/preview.html`](./fonts/icon/dist/preview.html).
All the icons in the icon font are listed in it.
There is also a little documentation attached.

## Specification


The icon graphic should just touch the edge of the SVG drawing area!

* **Format:** SVG

* **Width:** variable width (cannot be supplied by the graphic designer)

* **Height:** the height is fixed to 512 pixels

* **Colors:** Unless otherwise provided, do not define any colors in the
  SVG (cannot be implemented by the graphic designer)

* **Naming:** the file name of the icon should always be in English and
  have the following structure:
  
  `icon-NAME-OF-ICON.svg`


## Example

``` html
<svg height="512" width="512" xmlns="http://www.w3.org/2000/svg">
<path d="m477.73 107.53-221.71 228.27-221.7-228.25-34.32 33.33 256.02 263.59 255.98-263.59z"/>
</svg>
```

Ideally, the SVG does not contain any class names or IDs.


## SVG Creation


Make sure that the SVG symbols have a sufficiently high height.

512 is a minimum


### Figma

* Use the `Fill-Rule-Editor` to check:
  
  * all vectors support the "Non-zero rule"
  * it might be required change the path direction with this plugin
  * add the export-option "SVG" to all icon-frames (right sidebar within the design-tab at the bottom "Export")

### Inkscape

* remove all grouping (Ctrl-Shift-G)
* transform contours to paths
* combine all paths (Ctrl-+)
* store as simple SVG

### Illustrator

store as SVG with the following settings:

* SVG-Profile: SVG 1.1
* Font-Type: SVG
* Separation of fonts: none
* Options place: embed
* extended options:

  - CSS-properties: presentation-attribute
  - digits: 1
  - encoding: UTF-8
  - reduce `<tspan>` elements: check

leave everything else unchecked.

> Further information:
> 
> http://www.adobe.com/inspire/2013/09/exporting-svg-illustrator.html
