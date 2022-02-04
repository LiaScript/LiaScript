/**
 * LiaScript
 *
 * @file Configuration of gulp.js Tasks
 * @copyright 2021 - 599media GmbH
 *
 */

let fs = require("fs");
let path = require("path");
let glob = require("glob");
let async = require("async");

let gulp = require("gulp");
let rename = require("gulp-rename");
let iconfont = require("gulp-iconfont");
let consolidate = require("gulp-consolidate");

let runTimestamp = Math.round(Date.now() / 1000);

/**
 * Paths
 */

const paths = {
  iconSvgInputFolder: "./icons",
  iconFontOutputFolder: "./fonts",
  iconFontCssFile: "./../scss/00_settings/_settings.iconfont.scss",
  iconTemplatePath: "./../templates/icon-preview",
};

//
// Helper
//

const mapGlyphs = (glyph) => {
  return {
    name: glyph.name,
    codepoint: glyph.unicode[0].charCodeAt(0),
  };
};

//
// Gulp Tasks
//

/**
 * template-iconfont
 */
gulp.task("iconfont", (done) => {
  let inputPath = paths.iconSvgInputFolder;
  let outputPath = paths.iconFontOutputFolder;
  let fontName = "icon";

  let iconStream = gulp.src(inputPath + "/**/*.svg").pipe(
    iconfont({
      fontName: fontName,
      prependUnicode: false,
      timestamp: runTimestamp,
      formats: ["ttf", "eot", "svg", "woff", "woff2"],
      centerHorizontally: true,
      normalize: true,
      fontHeight: 512,
      log: () => {}, // suppress unnecessary logging
    })
  );

  async.parallel([
    // generate font files
    (generateFontFiles = (cb) => {
      let targetPath = outputPath + "/" + fontName + "/fonts/";
      iconStream.pipe(gulp.dest(targetPath)).on("finish", cb);
    }),

    // generate example html and css
    (generateExample = (cb) => {
      let targetPath = outputPath + "/" + fontName;
      iconStream
        .on("glyphs", (glyphs, options) => {
          gulp
            .src(paths.iconTemplatePath + "/icons.css")
            .pipe(
              consolidate("lodash", {
                fontPath: "./../fonts/",
                fontName: fontName,
                className: "icon",
                glyphs: glyphs,
              })
            )
            .pipe(rename("icons.css"))
            .pipe(gulp.dest(targetPath + "/dist"));
          gulp
            .src(paths.iconTemplatePath + "/preview/icons.html")
            .pipe(
              consolidate("lodash", {
                fontName: fontName,
                className: "icon",
                glyphs: glyphs.map(mapGlyphs),
              })
            )
            .pipe(rename("preview.html"))
            .pipe(gulp.dest(targetPath + "/dist"));
        })
        .on("finish", cb);
    }),

    // generate scss file
    (generateScssFile = (cb) => {
      let targetPath = outputPath + "/" + fontName;
      iconStream
        .on("glyphs", (glyphs, options) => {
          gulp
            .src(paths.iconTemplatePath + "/icons.scss")
            .pipe(
              consolidate("lodash", {
                fontPath: "../.." + ("/src/assets" + targetPath + "/fonts/").replace("./", "/"),
                fontName: fontName,
                className: "icon",
                glyphs: glyphs,
              })
            )
            .pipe(rename("_icons.scss"))
            .pipe(gulp.dest(targetPath));
        })
        .on("finish", cb);
    }),

    // generate css file
    (generateCssFile = (cb) => {
      let targetPath = outputPath + "/" + fontName;
      iconStream
        .on("glyphs", (glyphs, options) => {
          gulp
            .src(paths.iconTemplatePath + "/icons.css")
            .pipe(
              consolidate("lodash", {
                fontPath: "../.." + ("/src/assets" + targetPath + "/fonts/").replace("./", "/"),
                fontName: fontName,
                className: "icon",
                glyphs: glyphs,
              })
            )
            .pipe(rename("icons.css"))
            .pipe(gulp.dest(targetPath));
        })
        .on("finish", cb);
    }),
  ]);

  let scssContent =
    '@import "' + '../../assets/fonts' + /* outputPath + */ "/" + fontName + '/_icons.scss";';
  fs.writeFile(paths.iconFontCssFile, scssContent, (error) => {
    if (error) {
      console.error(error);
    }
  });

  done();
});
