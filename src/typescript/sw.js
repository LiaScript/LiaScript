console.log('service-worker.js')
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
// data-uris shall not be cached and also work offline
workbox.routing.registerRoute(
  ({ url }) => url.search.startsWith('?data:text'),
  async ({ event }) => {
    const cache = await caches.open(workbox.core.cacheNames.precache)
    const response = await cache.match(event.request.url.split('?data:text')[0])
    return response || fetch(event.request)
  }
)
// workbox.googleAnalytics.initialize();
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

// Cache external images with StaleWhileRevalidate strategy
workbox.routing.registerRoute(
  ({ request, url }) =>
    request.destination === 'image' && url.origin !== self.location.origin,
  new workbox.strategies.StaleWhileRevalidate({
    cacheName: 'external-images',
    plugins: [
      new workbox.cacheableResponse.CacheableResponsePlugin({
        statuses: [0, 200], // Cache opaque responses (0) and successful responses (200)
      }),
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 500,
        maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
        purgeOnQuotaError: true,
      }),
    ],
  })
)

// Cache external videos with CacheFirst strategy
workbox.routing.registerRoute(
  ({ request, url }) =>
    request.destination === 'video' && url.origin !== self.location.origin,
  new workbox.strategies.CacheFirst({
    cacheName: 'external-videos',
    plugins: [
      new workbox.cacheableResponse.CacheableResponsePlugin({
        statuses: [0, 200],
      }),
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 50,
        maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
        purgeOnQuotaError: true,
      }),
      new workbox.rangeRequests.RangeRequestsPlugin(),
    ],
  })
)

// Cache external audio with CacheFirst strategy
workbox.routing.registerRoute(
  ({ request, url }) =>
    request.destination === 'audio' && url.origin !== self.location.origin,
  new workbox.strategies.CacheFirst({
    cacheName: 'external-audio',
    plugins: [
      new workbox.cacheableResponse.CacheableResponsePlugin({
        statuses: [0, 200],
      }),
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 100,
        maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
        purgeOnQuotaError: true,
      }),
      new workbox.rangeRequests.RangeRequestsPlugin(),
    ],
  })
)

// Cache external CSS with StaleWhileRevalidate
workbox.routing.registerRoute(
  ({ request, url }) =>
    request.destination === 'style' && url.origin !== self.location.origin,
  new workbox.strategies.StaleWhileRevalidate({
    cacheName: 'external-css',
    plugins: [
      new workbox.cacheableResponse.CacheableResponsePlugin({
        statuses: [0, 200],
      }),
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 100,
        maxAgeSeconds: 7 * 24 * 60 * 60, // 7 days
        purgeOnQuotaError: true,
      }),
    ],
  })
)

// Cache external JavaScript with StaleWhileRevalidate
workbox.routing.registerRoute(
  ({ request, url }) =>
    request.destination === 'script' && url.origin !== self.location.origin,
  new workbox.strategies.StaleWhileRevalidate({
    cacheName: 'external-scripts',
    plugins: [
      new workbox.cacheableResponse.CacheableResponsePlugin({
        statuses: [0, 200],
      }),
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 100,
        maxAgeSeconds: 7 * 24 * 60 * 60, // 7 days
        purgeOnQuotaError: true,
      }),
    ],
  })
)

// Cache external fonts with CacheFirst strategy
workbox.routing.registerRoute(
  ({ request, url }) =>
    request.destination === 'font' && url.origin !== self.location.origin,
  new workbox.strategies.CacheFirst({
    cacheName: 'external-fonts',
    plugins: [
      new workbox.cacheableResponse.CacheableResponsePlugin({
        statuses: [0, 200],
      }),
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 50,
        maxAgeSeconds: 365 * 24 * 60 * 60, // 1 year
        purgeOnQuotaError: true,
      }),
    ],
  })
)

// Cache README.md files and other documents from external sources
// Using NetworkFirst to always try to get the latest version
workbox.routing.registerRoute(
  ({ request, url }) =>
    url.origin !== self.location.origin &&
    (url.pathname.endsWith('.md') ||
      url.pathname.includes('README') ||
      url.pathname.endsWith('.markdown')),
  new workbox.strategies.NetworkFirst({
    cacheName: 'external-documents',
    plugins: [
      new workbox.cacheableResponse.CacheableResponsePlugin({
        statuses: [0, 200],
      }),
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 200,
        maxAgeSeconds: 7 * 24 * 60 * 60, // 7 days
        purgeOnQuotaError: true,
      }),
    ],
    networkTimeoutSeconds: 5, // Fallback to cache if network is slow
  })
)

// Add error handling for fetch operations
workbox.routing.setCatchHandler(async ({ event, url }) => {
  console.error(`Failed to handle fetch: ${url}`)

  // Return a cached response if available
  const cache = await caches.open('external-images')
  const cachedResponse = await cache.match(event.request)
  if (cachedResponse) {
    return cachedResponse
  }

  // Otherwise return error
  return Response.error()
})

workbox.precaching.precacheAndRoute(self.__WB_MANIFEST)
