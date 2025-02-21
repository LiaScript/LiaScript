import { clientsClaim, cacheNames } from 'workbox-core'
import { registerRoute } from 'workbox-routing'
import { NetworkFirst, CacheFirst } from 'workbox-strategies'
import { precacheAndRoute } from 'workbox-precaching'

console.log('service-worker.js')

// (setConfig removed; in production builds, debug logging is disabled automatically)

// Updating SW lifecycle to update the app after a user-triggered refresh
self.skipWaiting()
clientsClaim()

// data-uris shall not be cached and also work offline
registerRoute(
  ({ url }) => url.search.startsWith('?data:text'),
  async ({ event }) => {
    const cache = await caches.open(cacheNames.precache)
    const response = await cache.match(event.request.url.split('?data:text')[0])
    return response || fetch(event.request)
  }
)

// workbox.googleAnalytics.initialize();
registerRoute(
  // Match all navigation requests, except those for URLs whose
  // path starts with '/LiveEditor/'
  ({ request, url }) =>
    request.mode === 'navigate' && !url.pathname.startsWith('/LiveEditor/'),
  new NetworkFirst()
)

registerRoute(/.*/, new NetworkFirst())

registerRoute(/https:\/\/code\.responsivevoice\.org/, new NetworkFirst())

registerRoute(
  'https://storage.googleapis.com/workbox-cdn/releases/7.0.0/workbox-sw.js',
  new CacheFirst()
)

precacheAndRoute(self.__WB_MANIFEST)
