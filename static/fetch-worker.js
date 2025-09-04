const CACHE_NAME = 'fetch-cache'
const MAX_CACHE_ITEMS = 500

async function trimCache(cacheName, maxItems) {
  const cache = await caches.open(cacheName)
  const keys = await cache.keys()
  if (keys.length > maxItems) {
    for (let i = 0; i < keys.length - maxItems; i++) {
      await cache.delete(keys[i])
    }
  }
}

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url)

  // Only cache non-same-origin GET requests
  if (url.origin !== self.location.origin && event.request.method === 'GET') {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          // Clone and store in cache
          const responseClone = response.clone()
          caches.open(CACHE_NAME).then(async (cache) => {
            await cache.put(event.request, responseClone)
            await trimCache(CACHE_NAME, MAX_CACHE_ITEMS)
          })
          return response
        })
        .catch(() =>
          // On failure, try cache
          caches
            .match(event.request)
            .then((cached) => cached || Promise.reject('no-match'))
        )
    )
  }
  // For same-origin or non-GET, default fetch
})
