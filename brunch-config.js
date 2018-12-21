module.exports = {
    config: {
        optimize: true,
        paths: {
            watched: [
                "assets",
                "src",
                "lib",
                "examples",
                "scss",
                "webcomponents"
            ],
        },
        files: {
            // vendor is for 3rb party lib, app is for custom lib
            javascripts: {
                joinTo: {
                    "js/vendor.js": /^(node_modules|src\/index.js)/,
                }
            },
            stylesheets: {
                joinTo: {
                    "css/app.css": /^(?!node_modules)/,
                    "css/vendor.css": /^node_modules/,
                },
                order: {
                    before: [
                        "node_modules/normalize.css/normalize.css",
                    ],
                    after: [
                    ],
                },
            },
        },
        plugins: {
            elmBrunch: {
                mainModules: ["examples/Online.elm"],
                outputFolder: "public/js/",
                outputFile: 'app.js',
                makeParameters: []//'--debug'],
            },
            sass: {
                mode: "native",
                options: {
                    includePaths: [
                        "node_modules/sass-material-colors/sass",
                    ],
                },
            },
            copycat: {
                "css/fonts": [
                    //"node_modules/katex/dist/fonts/",
                    "vendor/material_icons/flUhRq6tzZclQEJ-Vdg-IuiaDsNc.woff2",
                    "vendor/roboto/fonts"
                ],
                "css": [
                    "vendor/material_icons/material.css",
                    "vendor/roboto/roboto.css"
                ],
                "js": [
                    "lib/liascript.js",
                    "vendor/responsivevoice.js"
                ],
                "js/ace": [
                    "vendor/ace"
                ],
                "webcomponents" : [
                    "webcomponents"
                ],
                verbose: false,
                onlyChanged: true,
            },
            uglify: {
                mangle: false,
                compress: {
                    global_defs: {
                        DEBUG: false
                    }
                }
            },
        },
        npm: {
            styles: {
                "normalize.css": ["normalize.css"],
                "animate.css": ["animate.css"],
                //"katex": ["dist/katex.css"]
            },
            static: [
                //"node_modules/katex/dist/katex.js"
            ],
        },
    }
};
