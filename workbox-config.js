module.exports = {
  globDirectory: './dist',
  globPatterns: [
    '**/*.{ico,jpg,png,html,js,svg,webmanifest,css,woff2,woff,eot,ttf}',
  ],
  swSrc: './src/typescript/sw.js',
  swDest: './dist/sw.js',
  maximumFileSizeToCacheInBytes: 5000000,
}
