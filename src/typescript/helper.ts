export function allowedProtocol(url: string) {
  return (
    url.startsWith('https://') ||
    url.startsWith('http://') ||
    url.startsWith('file://') ||
    url.startsWith('hyper://') ||
    url.startsWith('dat://') ||
    url.startsWith('ipfs://') ||
    url.startsWith('ipns://')
  )
}
