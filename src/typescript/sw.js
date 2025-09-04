console.log('service-worker.js')

// advanced config for injectManifest approach
importScripts(
  'https://storage.googleapis.com/workbox-cdn/releases/7.1.0/workbox-sw.js'
)

// Detailed logging is very useful during development
workbox.setConfig({
  debug: false,
})

// Updating SW lifecycle to update the app after user triggered refresh
self.skipWaiting()
workbox.core.clientsClaim()

// data-uris shall not be cached and also work offline
workbox.routing.registerRoute(
  ({ url }) => url.search.startsWith('?data:text'),

  async ({ event }) => {
    const cache = await caches.open(workbox.core.cacheNames.precache)
    const response = await cache.match(event.request.url.split('?data:text')[0])

    return response || fetch(event.request)
  }
)

// Helper to check if request is cross-origin
function isCrossOrigin(request) {
  try {
    const url = new URL(request.url)
    return url.origin !== self.location.origin
  } catch {
    return false
  }
}

// Cache images with CacheFirst strategy
workbox.routing.registerRoute(
  ({ request }) => request.destination === 'image' && isCrossOrigin(request),
  new workbox.strategies.CacheFirst({
    cacheName: 'assets-images',
    plugins: [
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 500,
        maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
      }),
    ],
  })
)

// Cache CSS with StaleWhileRevalidate strategy
workbox.routing.registerRoute(
  ({ request }) => request.destination === 'style' && isCrossOrigin(request),
  new workbox.strategies.StaleWhileRevalidate({
    cacheName: 'assets-css',
    plugins: [
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 100,
        maxAgeSeconds: 30 * 24 * 60 * 60,
      }),
    ],
  })
)

// Cache JS with StaleWhileRevalidate strategy
workbox.routing.registerRoute(
  ({ request }) => request.destination === 'script' && isCrossOrigin(request),
  new workbox.strategies.StaleWhileRevalidate({
    cacheName: 'assets-js',
    plugins: [
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 100,
        maxAgeSeconds: 30 * 24 * 60 * 60,
      }),
    ],
  })
)

// Cache audio files from other origins
workbox.routing.registerRoute(
  ({ request }) => request.destination === 'audio' && isCrossOrigin(request),
  new workbox.strategies.CacheFirst({
    cacheName: 'assets-audio',
    plugins: [
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 100,
        maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
      }),
    ],
  })
)

// Cache video files from other origins
workbox.routing.registerRoute(
  ({ request }) => request.destination === 'video' && isCrossOrigin(request),
  new workbox.strategies.CacheFirst({
    cacheName: 'assets-video',
    plugins: [
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 50,
        maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
      }),
    ],
  })
)

// Cache SVG files from other origins
workbox.routing.registerRoute(
  ({ request }) =>
    request.destination === '' &&
    request.url.endsWith('.svg') &&
    isCrossOrigin(request),
  new workbox.strategies.CacheFirst({
    cacheName: 'assets-svg',
    plugins: [
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 100,
        maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
      }),
    ],
  })
)

// Cache fonts from other origins
workbox.routing.registerRoute(
  ({ request }) => request.destination === 'font' && isCrossOrigin(request),
  new workbox.strategies.CacheFirst({
    cacheName: 'assets-fonts',
    plugins: [
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 50,
        maxAgeSeconds: 60 * 24 * 60 * 60, // 60 days
      }),
    ],
  })
)

workbox.routing.registerRoute(
  // Match all navigation requests, except those for URLs whose
  // path starts with '/admin/'
  ({ request, url }) =>
    request.mode === 'navigate' && !url.pathname.startsWith('/LiveEditor/'),
  new workbox.strategies.NetworkFirst()
)

//workbox.routing.registerRoute(/\/*/, new workbox.strategies.NetworkFirst())

workbox.routing.registerRoute(
  /https:\/\/code\.responsivevoice\.org/,
  new workbox.strategies.NetworkFirst()
)

workbox.routing.registerRoute(
  'https://storage.googleapis.com/workbox-cdn/releases/7.0.0/workbox-sw.js',
  new workbox.strategies.CacheFirst()
)

// Add error handling for fetch operations
workbox.routing.setCatchHandler(({ event }) => {
  console.error(`Failed to handle fetch: ${event.request.url}`)
  return Response.error()
})

workbox.precaching.precacheAndRoute(self.__WB_MANIFEST)
