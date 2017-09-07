module.exports = {
    config: {
        optimize: true,
        paths: {
            watched: [
                "assets",
                "src",
                "examples",
                "scss",
            ],
        },
        files: {
            // vendor is for 3rb party lib, app is for custom lib
            javascripts: {
                joinTo: {
                    "js/vendor.js": /^(node_modules|lib)/,
                },
            },
            stylesheets: {
                joinTo: {
                    "css/app.css": /^(?!node_modules)/,
                    "css/vendor.css": /^node_modules/,
                },
            },
        },
        plugins: {
            elmBrunch: {
                mainModules: ["examples/Online.elm"],
                outputFolder: "public/js/",
                outputFile: 'app.js',
                makeParameters: ['--warn', '--debug'],
            },
            sass: {
                mode: "native",
            },
            copycat: {
                "fonts": [
                    "node_modules/katex/dist/fonts/",
                ],
                verbose: true,
                onlyChanged: true,
            },
        },
        npm: {
            styles: {
                "highlight.js": ["styles/default.css"],
                "animate.css": ["animate.css"],
                "katex": ["dist/katex.css"],
            },
            static: [
                "node_modules/katex/dist/katex.js",
                //"lib/responsivevoice.js",
            ],
        },
    }
};
