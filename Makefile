all:
	elm-make examples/Editor.elm --output build/app.js

init:
	#git clone https://github.com/mathjax/MathJax lib/MathJax
	git clone https://github.com/Khan/KaTeX lib/KaTeX
	cd lib/KaTeX; make
	cp lib/KaTeX/build/katex.min.js lib/
	cp lib/KaTeX/build/katex.min.css lib/
	elm-make --yes
