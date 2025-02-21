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

// workbox.googleAnalytics.initialize();
workbox.routing.registerRoute(
  // Match all navigation requests, except those for URLs whose
  // path starts with '/admin/'
  ({ request, url }) =>
    request.mode === 'navigate' && !url.pathname.startsWith('/LiveEditor/'),
  new workbox.strategies.NetworkFirst()
)

//workbox.routing.registerRoute(/\/*/, new workbox.strategies.NetworkFirst())
workbox.routing.registerRoute(/.*/, new workbox.strategies.NetworkFirst())

workbox.routing.registerRoute(
  /https:\/\/code\.responsivevoice\.org/,
  new workbox.strategies.NetworkFirst()
)

workbox.routing.registerRoute(
  'https://storage.googleapis.com/workbox-cdn/releases/7.0.0/workbox-sw.js',
  new workbox.strategies.CacheFirst()
)

workbox.precaching.precacheAndRoute(self.__WB_MANIFEST)
