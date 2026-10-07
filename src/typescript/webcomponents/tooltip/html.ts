/**
 * Extract title, description and image of a website. DOMParser creates an
 * inert document, scripts are not executed and images are not loaded.
 *
 * @param url - of the website, used to resolve relative image urls
 * @param html - the content of the website
 */
export function parse(url: string, html: string) {
  const doc = new DOMParser().parseFromString(html, 'text/html')

  const meta = (key: string) =>
    doc
      .querySelector(`meta[property="${key}"], meta[name="${key}"]`)
      ?.getAttribute('content')
      ?.trim() || undefined

  const text = (selector: string) =>
    doc.querySelector(selector)?.textContent?.trim() || undefined

  const img = doc.querySelector('img')

  // image and alt-text have to come from the same source
  let [image, image_alt] =
    [
      [meta('og:image'), meta('og:image:alt')],
      [doc.querySelector('link[rel="image_src"]')?.getAttribute('href')],
      [meta('twitter:image'), meta('twitter:image:alt')],
      [img?.getAttribute('src'), img?.getAttribute('alt')],
    ].find(([src]) => src) || []

  if (image) {
    try {
      const base = doc.querySelector('base')?.getAttribute('href')
      image = new URL(image, base ? new URL(base, url) : url).href
    } catch (_) {
      image = undefined
    }
  }

  return {
    title:
      meta('og:title') ||
      meta('twitter:title') ||
      doc.title.trim() ||
      text('h1') ||
      text('h2'),
    description:
      meta('og:description') ||
      meta('twitter:description') ||
      meta('description') ||
      text('p'),
    image: image || undefined,
    image_alt: image_alt || undefined,
  }
}
