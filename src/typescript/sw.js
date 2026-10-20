// advanced config for injectManifest approach
importScripts(
  'https://storage.googleapis.com/workbox-cdn/releases/7.4.0/workbox-sw.js'
)
// Detailed logging is very useful during development
workbox.setConfig({
  debug: false,
})
// Updating SW lifecycle to update the app after user triggered refresh
self.skipWaiting()
workbox.core.clientsClaim()

// NetworkFirst with expiration, offline a failing fetch falls back to the cache
// immediately, the timeout covers slow networks
function networkFirst(
  cacheName,
  maxEntries,
  maxAgeDays,
  networkTimeoutSeconds
) {
  return new workbox.strategies.NetworkFirst({
    cacheName,
    networkTimeoutSeconds,
    plugins: [
      new workbox.cacheableResponse.CacheableResponsePlugin({
        statuses: [0, 200], // opaque (0) and successful responses
      }),
      new workbox.expiration.ExpirationPlugin({
        maxEntries,
        maxAgeSeconds: maxAgeDays * 24 * 60 * 60,
        purgeOnQuotaError: true,
      }),
    ],
  })
}

// data-uris shall not be cached and also work offline, they only need the app
workbox.routing.registerRoute(
  ({ url }) => url.search.startsWith('?data:text'),
  async ({ request }) =>
    (await workbox.precaching.matchPrecache('index.html')) || fetch(request)
)

workbox.routing.registerRoute(
  // Match all navigation requests, except those for URLs whose
  // path starts with '/LiveEditor/'
  ({ request, url }) =>
    request.mode === 'navigate' && !url.pathname.startsWith('/LiveEditor/'),
  networkFirst('navigation', 50, 7, 3)
)

// External resources, video and audio are left out, since media elements
// request byte ranges and partial (206) responses cannot be cached. CSS and
// scripts loaded via fetch as blobs (Resource.ts) have no destination, these
// are matched by their extension.
for (const [destination, cacheName, maxEntries, maxAgeDays, timeout, ext] of [
  ['image', 'external-images', 500, 30, 5],
  ['style', 'external-css', 100, 7, 3, '.css'],
  ['script', 'external-scripts', 100, 7, 3, '.js'],
  ['font', 'external-fonts', 50, 365, 3],
]) {
  workbox.routing.registerRoute(
    ({ request, url }) =>
      url.origin !== self.location.origin &&
      (request.destination === destination ||
        (!!ext && url.pathname.endsWith(ext))),
    networkFirst(cacheName, maxEntries, maxAgeDays, timeout)
  )
}

// README.md files and other documents from external sources
workbox.routing.registerRoute(
  ({ url }) =>
    url.origin !== self.location.origin &&
    (url.pathname.endsWith('.md') ||
      url.pathname.includes('README') ||
      url.pathname.endsWith('.markdown')),
  networkFirst('external-documents', 200, 7, 5)
)

workbox.precaching.precacheAndRoute(self.__WB_MANIFEST)

// Own assets left out of the precache (see workbox-config.js) are cached on
// first use. Must come after precacheAndRoute, routes match in order.
workbox.routing.registerRoute(
  ({ request, url }) =>
    url.origin === self.location.origin &&
    !url.search && // cache-busted urls would pile up
    ['script', 'worker', 'style', 'font'].includes(request.destination),
  new workbox.strategies.StaleWhileRevalidate({ cacheName: 'assets' })
)
