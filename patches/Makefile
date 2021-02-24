all: patch-url

patch-url:
	cd elm-patch && make all

patch-break-dom:
	rm -f ~/.elm/0.19.1/packages/elm/virtual-dom/1.0.2/artifacts.dat
	rm -f ~/.elm/0.19.1/packages/elm/virtual-dom/1.0.2/docs.json
	patch -u ~/.elm/0.19.1/packages/elm/virtual-dom/1.0.2/src/Elm/Kernel/VirtualDom.js elm-break-dom/patch/VirtualDom.patch
