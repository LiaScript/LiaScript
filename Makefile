help:
	@echo "Simple Makefile to build LiaScript locally"
	@echo ""
	@echo "make install              - same as 'npm i' will install"
	@echo "make all                  - will build the entire app as a PWA"
	@echo "make editor               - will bild the editor in branch 'editor'"
	@echo "                            note that the target is different"
	@echo "                            no indexeddb support"
	@echo "make ... KEY='adfia2'     - if you want to host this app by your own,"
	@echo "                            you will have to get a responsivevoice-API key"
	@echo "                            your key can be passed via the KEY parameter"


all: app index manifest responsivevoice
	rm dist/README.md

editor: base index responsivevoice
	rm dist/README.md

base:
	npm run build:base

app:
	npm run build

index: preview
	sed -i "s/\"logo/\".\/logo/g" dist/index.html
	sed -i "s/href=\"main\./href=\".\/main./g" dist/index.html
	sed -i "s/href=\"manifest\./href=\".\/manifest./g" dist/index.html
	sed -i "s/href=\"material-icons\./href=\".\/material-icons./g" dist/index.html
	sed -i "s/href=\"roboto\./href=\".\/roboto./g" dist/index.html
	sed -i "s/src=\"ace\./src=\".\/ace./g" dist/index.html
	sed -i "s/src=\"app\./src=\".\/app./g" dist/index.html
	sed -i "s/src=\"base\./src=\".\/base./g" dist/index.html
	sed -i "s/src=\"echarts\./src=\".\/echarts./g" dist/index.html
	sed -i "s/src=\"katex\./src=\".\/katex./g" dist/index.html
	sed -i "s/src=\"oembed\./src=\".\/oembed./g" dist/index.html
	sed -i "s/src=\"preview\-lia\./src=\".\/preview-lia./g" dist/index.html

responsivevoice:
	sed -i "s/responsivevoice\.js\"/responsivevoice.js?key=$(KEY)\"/g" dist/index.html

manifest:
	sed -i "s/\"logo_/\".\/logo_/g" dist/manifest.webmanifest
	sed -i "s/\"index\.html/\".\/index.html/g" dist/manifest.webmanifest

preview:
	sed -i -r "s/preview-lia\.([^.])*/preview-lia/g" dist/index.html
	mv dist/preview-lia.*.js dist/preview-lia.js
	sed -i -r "s/preview-lia\.([^.])*/preview-lia/g" dist/sw.js

watch:
	npm run watch

install:
	npm run i
