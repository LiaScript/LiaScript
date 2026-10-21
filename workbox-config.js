module.exports = {
  globDirectory: './dist',
  // Keep the first visit small: GitHub Pages rate-limits per IP and a whole
  // lecture hall shares one NAT address. Ace modes/themes/snippets/workers and
  // legacy font formats are cached on first use by sw.js instead.
  globPatterns: ['**/*.{ico,jpg,png,html,js,svg,webmanifest,css,woff2}'],
  globIgnores: [
    '**/node_modules/**/*',
    // except the most used languages and the default theme
    'mode-!(markdown|javascript|python|c_cpp|csharp|html).js',
    'theme-!(dreamweaver).js',
    '{ext,keybinding,worker}-*.js',
    'snippets/**',
    // legacy svg fonts, ignored by browsers that run the service worker
    '**/*-latin-*.svg',
    // sync backends need the network anyway
    '{Ably,Edrys,Gun,Matrix,Nostr,P2PT,PeerJS,PubNub,SimplePeer,Trystero,WebSocket}.*.js',
    'trystero-*.js',
  ],
  swSrc: './src/typescript/sw.js',
  swDest: './dist/sw.js',
  maximumFileSizeToCacheInBytes: 5000000,
}
