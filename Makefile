all:
	elm-make examples/Editor.elm --output build/app.js
	./lib/KaTeX/node_modules/uglify-js/bin/uglifyjs --compress --mangle  --output build/app.min.js build/app.js

example_slides:
	elm-make examples/Slides.elm --output build/app.js
	./lib/KaTeX/node_modules/uglify-js/bin/uglifyjs --compress --mangle  --output build/app.min.js build/app.js

example_plain:
		elm-make examples/Plain.elm --output build/app.js
		./lib/KaTeX/node_modules/uglify-js/bin/uglifyjs --compress --mangle  --output build/app.min.js build/app.js


debug:
	elm-make --debug --warn examples/Editor.elm --output build/app.js
	./lib/KaTeX/node_modules/uglify-js/bin/uglifyjs --compress --mangle  --output build/app.min.js build/app.js

init:
	#git clone https://github.com/mathjax/MathJax lib/MathJax
	git clone https://github.com/Khan/KaTeX lib/KaTeX
	cd lib/KaTeX; make
	cp lib/KaTeX/build/katex.min.js lib/
	cp lib/KaTeX/build/katex.min.css lib/
	elm-make --yes
