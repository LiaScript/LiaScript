all: patch-elm patch-dexie

patch-elm:
	cd elm-patch && make all

patch-dexie:
	patch -u ../node_modules/dexie/dist/dexie.es.js Dexie.patch