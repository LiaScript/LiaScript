console.log("service-worker.js")

// advanced config for injectManifest approach
importScripts('https://storage.googleapis.com/workbox-cdn/releases/4.3.1/workbox-sw.js')

// Detailed logging is very useful during development
workbox.setConfig({
  debug: false
})

// Updating SW lifecycle to update the app after user triggered refresh
workbox.core.skipWaiting()
workbox.core.clientsClaim()

// workbox.googleAnalytics.initialize();

workbox.routing.registerRoute(/\/$/, new workbox.strategies.NetworkFirst())
workbox.routing.registerRoute(/\/*/, new workbox.strategies.NetworkFirst())
workbox.routing.registerRoute(/.+\/*/, new workbox.strategies.NetworkFirst())

workbox.routing.registerRoute(
  /https:\/\/code\.responsivevoice\.org/,
  new workbox.strategies.StaleWhileRevalidate()
)

workbox.precaching.precacheAndRoute(self.__WB_MANIFEST)
