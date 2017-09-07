module.exports = {
    config: {
        paths: {
            watched: ["examples", "src", "scss", "assets"]
        },
        files: {
            javascripts: {
                joinTo: "js/app.js"
            },
            stylesheets: {
                joinTo: "css/app.css"
            }
        },
        plugins: {
            elmBrunch: {
                mainModules: ["examples/Slides.elm"],
                outputFolder: "public/js/",
                outputFile: 'elm.js',
                makeParameters: ['--warn', '--debug']
            },
            sass: {
                mode: "native"
            }
        }
    }
};
