help:
	@echo "Simple Makefile to build LiaScript locally"
	@echo ""
	@echo "make install              - same as 'npm i' will install"
	@echo "make all                  - will build the entire app as a PWA"
	@echo "make all2                 - same as above, but with elm-optimize2"
	@echo "make editor               - will build the editor in branch 'editor'"
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
	rm dist/*.md

all2: optimize all deoptimize

editor: base index responsivevoice
	rm dist/README.md

editor2: optimize editor deoptimize

base:
	npm run build:base

app:
	npm run build

index:
	sed -i "s/href=\"logo\./href=\".\/logo./g" dist/index.html
	sed -i "s/href=\"index\./href=\".\/index./g" dist/index.html
	sed -i "s/href=\"manifest\./href=\".\/manifest./g" dist/index.html
	sed -i "s/href=\"up\_/href=\".\/up_/g" dist/index.html
	sed -i "s/src=\"index\./src=\".\/index./g" dist/index.html
	sed -i "s/content=\"up\_\/up\_/content=\".\/up_\/up_/g" dist/index.html
	sed -i "s/src:local(\"\")/src:local(\"\.\")/g" dist/index.*.css
	sed -i "s/url(\//url(/g" dist/index.*.css

responsivevoice:
	if [ -z "$(KEY)" ]; then \
        echo "NO responsivevoice key ... "; \
	else \
		sed -i "s/<\/head>/<script defer async src=\"https:\/\/code.responsivevoice.org\/responsivevoice.js?key=$(KEY)\"><\/script><\/head>/g" dist/index.html ; \
	fi

manifest:
	sed -i "s/\"logo_/\".\/logo_/g" dist/manifest.webmanifest
	sed -i "s/\"up_/\".\/up_/g" dist/manifest.webmanifest
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
