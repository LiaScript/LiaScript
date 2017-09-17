all:
	elm-make examples/Online.elm --output build/app.js
	closure-compiler --compilation_level ADVANCED_OPTIMIZATIONS  --language_in ECMASCRIPT5 --js build/app.js --js_output_file build/lia.js

github:
	elm-make examples/Online.elm --output build/app.js
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
	git clone https://github.com/Khan/KaTeX lib/KaTeX
	cd lib/KaTeX; make
	cp lib/KaTeX/build/katex.min.js lib/
	cp lib/KaTeX/build/katex.min.css lib/
	elm-make --yes
	git clone https://github.com/andre-dietrich/elm-responsive-voice elm-stuff/packages/andre-dietrich/elm-responsive-voice/1.0.0/
