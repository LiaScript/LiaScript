console.log('service-worker.js')

// advanced config for injectManifest approach
importScripts(
  'https://storage.googleapis.com/workbox-cdn/releases/6.5.4/workbox-sw.js',
)

// Detailed logging is very useful during development
workbox.setConfig({
  debug: false,
})

// Updating SW lifecycle to update the app after user triggered refresh
workbox.core.skipWaiting()
workbox.core.clientsClaim()

// workbox.googleAnalytics.initialize();
workbox.routing.registerRoute(
  // Match all navigation requests, except those for URLs whose
  // path starts with '/admin/'
  ({request, url}) => request.mode === 'navigate' &&
                      !url.pathname.startsWith('/LiveEditor/'),
  new workbox.strategies.StaleWhileRevalidate()
);

workbox.routing.registerRoute(/\/$/, new workbox.strategies.NetworkFirst())
workbox.routing.registerRoute(/\/*/, new workbox.strategies.NetworkFirst())
workbox.routing.registerRoute(/.+\/*/, new workbox.strategies.NetworkFirst())

workbox.routing.registerRoute(
  /https:\/\/code\.responsivevoice\.org/,
  new workbox.strategies.StaleWhileRevalidate(),
)

workbox.precaching.precacheAndRoute(self.__WB_MANIFEST)
