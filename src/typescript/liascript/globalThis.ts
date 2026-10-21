// `globalThis` is only available since Firefox 65, but several dependencies
// (drag-drop-touch, y-generic) use it unguarded. On KaiOS 2.x (Gecko 48) this
// broke the entire startup bundle, thus it has to be the very first import of
// the runtime, see `index.ts`.
if (typeof globalThis === 'undefined') {
  // @ts-ignore
  self.globalThis = self
}
