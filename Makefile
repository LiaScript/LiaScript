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
	sed -i "s/responsivevoice\.js\"/responsivevoice.js?key=blVZszUw\"/g" dist/index.html

manifest:
	sed -i "s/\"logo_/\".\/logo_/g" dist/manifest.webmanifest
	sed -i "s/\"index\.html/\".\/index.html/g" dist/manifest.webmanifest

preview:
	sed -i -r "s/preview-lia\.([^.])*/preview-lia/g" dist/index.html
	mv dist/preview-lia.*.js dist/preview-lia.js
