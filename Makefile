help:
	@echo "Simple Makefile to build LiaScript locally"
	@echo ""
	@echo "make install              - same as 'npm i' will install"
	@echo "make all                  - will build the entire app as a PWA"
	@echo "make all2                 - same as above, but with elm-optimize2"
	@echo "make editor               - will bild the editor in branch 'editor'"
	@echo "                            note that the target is different"
	@echo "                            no indexeddb support"
	@echo "make editor2              - same as above, but with elm-optimize2"
	@echo "make clean                - delete dist folder"
	@echo "make ... KEY='adfia2'     - if you want to host this app by your own,"
	@echo "                            you will have to get a responsivevoice-API key"
	@echo "                            your key can be passed via the KEY parameter"


clean:
	rm -rf dist

all: clean app index manifest responsivevoice preview
	rm dist/README.md

all2: optimize all deoptimize

editor: base index responsivevoice
	rm dist/README.md

editor2: optimize editor deoptimize

base:
	npm run build:base

app:
	npm run build

index:
	sed -i "s/\"\/logo/\".\/logo/g" dist/index.html
	sed -i "s/href=\"\/main\./href=\".\/main./g" dist/index.html
	sed -i "s/href=\"\/manifest\./href=\".\/manifest./g" dist/index.html
	sed -i "s/=\"\/formula\./=\".\/formula./g" dist/index.html
	sed -i "s/src=\"\/editor\./src=\".\/editor./g" dist/index.html
	sed -i "s/src=\"\/app\./src=\".\/app./g" dist/index.html
	sed -i "s/src=\"\/base\./src=\".\/base./g" dist/index.html
	sed -i "s/src=\"\/chart\./src=\".\/chart./g" dist/index.html
	sed -i "s/src=\"\/oembed\./src=\".\/oembed./g" dist/index.html
	sed -i "s/src=\"\/format\./src=\".\/format./g" dist/index.html
	sed -i "s/src=\"\/preview\-lia\./src=\".\/preview-lia./g" dist/index.html
	sed -i "s/src=\"\/preview\-link\./src=\".\/preview-link./g" dist/index.html
	sed -i "s/src:local(\"\")/src:local(\"\.\")/g" dist/index.*.css
	sed -i "s/url(\//url(/g" dist/index.*.css

responsivevoice:
	sed -i "s/responsivevoice\.js\"/responsivevoice.js?key=$(KEY)\"/g" dist/index.html

manifest:
	sed -i "s/\"logo_/\".\/logo_/g" dist/manifest.webmanifest
	sed -i "s/\"index\.html/\".\/index.html/g" dist/manifest.webmanifest

preview:
	npm run build:preview

watch:
	npm run watch

install:
	npm run i

optimize:
	sed -i "s/elm\/Main.elm/..\/elm.js/g" src/typescript/liascript/index.ts
	elm-optimize-level-2 -O3 src/elm/Main.elm

deoptimize:
	sed -i "s/\.\.\/elm.js/elm\/Main\.elm/g" src/typescript/liascript/index.ts
	rm elm.js