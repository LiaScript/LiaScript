all:
	elm-make examples/Editor.elm --output build/app.js

init:
	git clone https://github.com/mathjax/MathJax lib/MathJax
	elm-make --yes
