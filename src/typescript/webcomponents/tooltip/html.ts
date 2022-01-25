import { allowedProtocol } from '../../helper'

const HREF = /href=[\"'](.*?)[\"']/gi
const SRC = /src=[\"'](.*?)[\"']/gi
const ALT = /alt=[\"'](.*?)[\"']/gi

const H1 = /<h1.*?>(.*?)<\/h1>/gi
const H2 = /<h2.*?>(.*?)<\/h2>/gi
const TITLE = /<title>(.*?)<\/title>/gi

export function parse(url: string, html: string) {
  const image = parseImage(html)

  const base = new URL(parseBase(html) || url)

  return {
    url: url,
    title: parseTitle(html),
    description: parseDescription(base, html),
    image: image.url,
    image_alt: image.alt,
  }
}

function parseBase(html: string) {
  return firstMatch(/<base.*?href\s*=\s*[\"'](.*?)[\"']>/gi, html)
}

function parseImage(html: string): {
  url?: string
  alt?: string
} {
  const ogImage = parseContent('og:image', html)
  if (ogImage) {
    return {
      url: ogImage,
      alt: parseContent('og:image:alt', html),
    }
  }

  const imgRelLink = firstMatch(/<link.*?rel=[\"']image_src[\"'].*?>/gi, html)
  if (imgRelLink) {
    return {
      url: firstMatch(HREF, imgRelLink),
    }
  }

  const twitterImage = parseContent('twitter:image', html)
  if (twitterImage) {
    return {
      url: twitterImage,
      alt: parseContent('twitter:image:alt', html),
    }
  }

  const image = firstMatch(/<img .*?>/gi, html)
  if (image) {
    return {
      url: firstMatch(SRC, image),
      alt: firstMatch(ALT, image),
    }
  }

  return {}
}

function parseTitle(html: string) {
  const ogTitle = parseContent('og:title', html)
  if (ogTitle && ogTitle.length > 0) {
    return ogTitle
  }

  const twitterTitle = parseContent('twitter:title', html)
  if (twitterTitle && twitterTitle.length > 0) {
    return twitterTitle
  }

  const docTitle = firstMatch(TITLE, html)
  if (docTitle && docTitle.length > 0) {
    return docTitle
  }

  const h1 = firstMatch(H1, html)
  if (h1 && h1.length > 0) {
    return h1
  }

  const h2 = firstMatch(H2, html)
  if (h2 && h2.length > 0) {
    return h2
  }
}

function parseDescription(url: URL, html: string) {
  const ogDescription = parseContent('og:description', html)
  if (ogDescription && ogDescription.length > 0) {
    return ogDescription
  }

  const twitterDescription = parseContent('twitter:description', html)
  if (twitterDescription && twitterDescription.length > 0) {
    return twitterDescription
  }

  const metaDescription = firstMatch(
    /<meta.*?name=[\"']description[\"'].*?>/gi,
    html
  )
  if (metaDescription) {
    const description = firstMatch(/content=[\"'](.*?)[\"']/gi, metaDescription)
    if (description && description.length > 0) {
      return description
    }
  }

  let p = firstMatch(/<p>([\s\S]+?)<\/p>/gi, html)
  if (p) {
    p = p.replace(/(href|src)\s*=\s*[\"'].*?[\"']/g, function (e: string) {
      return baseHREF(url, e)
    })
    return p
  }
}

/**
 * **private helper:** to run regular expression onto a single string, to speed
 * up the process, only the first match is returned
 *
 * @param str - to parse
 * @param pattern - to match
 * @returns the first match as a string or undefined
 */
function firstMatch(pattern: RegExp, str: string): string | undefined {
  const match = str.matchAll(pattern).next()

  return match.value ? match.value[match.value.length - 1] : undefined
}

function parseContent(property: string, html: string) {
  const meta = firstMatch(
    new RegExp(`<meta[^>]+?property=[\"']${property}[\"'][^>]*?>`, 'gi'),
    html
  )

  if (meta) {
    return firstMatch(/content=[\"'](.*?)[\"']/gi, meta)
  }
}

function baseHREF(url: URL, match: string) {
  const pos = match.search(/[\"']/)

  if (match.startsWith('href')) {
    match += ' target="blank_"'
  }

  const begin = match.slice(0, pos + 1)
  const end = match.slice(pos + 1)

  if (allowedProtocol(begin)) {
    return match
  } else if (end.startsWith('//')) {
    return match
  } else if (end.startsWith('/')) {
    return begin + url.origin + end
  } else if (end.startsWith('#')) {
    return begin + url.href + end
  }

  return begin + url.origin + '/' + end
}
