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
                mainModules: ["examples/Editor.elm"],
                outputFolder: "public/js/",
                outputFile: 'elm.js',
                makeParameters: ['--warn']
            },
            sass: {
                mode: "native"
            }
        }
    }
};
