export function getTitle(doc: Document | null): string | undefined {
  if (doc === null) return

  const ogTitle = <HTMLMetaElement>(
    doc.querySelector('meta[property="og:title"]')
  )
  if (ogTitle && ogTitle.content.length > 0) {
    return ogTitle.content
  }

  const twitterTitle = <HTMLMetaElement>(
    doc.querySelector('meta[name="twitter:title"]')
  )
  if (twitterTitle && twitterTitle.content.length > 0) {
    return twitterTitle.content
  }

  const docTitle = doc.title
  if (docTitle && docTitle.length > 0) {
    return docTitle
  }

  const h1 = <HTMLHeadElement>doc.querySelector('h1')
  if (h1 && h1.innerHTML) {
    return h1.innerHTML
  }
  const h2 = <HTMLHeadElement>doc.querySelector('h2')
  if (h2 && h2.innerHTML) {
    return h2.innerHTML
  }
}

export function getDescription(doc: Document | null): string | undefined {
  if (doc === null) return

  const ogDescription = <HTMLMetaElement>(
    doc.querySelector('meta[property="og:description"]')
  )
  if (ogDescription && ogDescription.content.length > 0) {
    return ogDescription.content
  }

  const twitterDescription = <HTMLMetaElement>(
    doc.querySelector('meta[name="twitter:description"]')
  )
  if (twitterDescription && twitterDescription.content.length > 0) {
    return twitterDescription.content
  }

  const metaDescription = <HTMLMetaElement>(
    doc.querySelector('meta[name="description"]')
  )
  if (metaDescription && metaDescription.content.length > 0) {
    return metaDescription.content
  }

  const paragraphs = doc.querySelectorAll('p')
  for (let i = 0; i < paragraphs.length; i++) {
    const par = paragraphs[i]
    if (
      // if object is visible in dom
      par.offsetParent !== null &&
      par.childElementCount !== 0 &&
      par.textContent
    ) {
      return par.textContent
    }
  }
}

export function getDomainName(doc: Document | null, uri: string) {
  let domainName = null

  if (doc) {
    const canonicalLink = <HTMLLinkElement>(
      doc.querySelector('link[rel=canonical]')
    )
    if (canonicalLink && canonicalLink.href.length > 0) {
      domainName = canonicalLink.href
    } else {
      const ogUrlMeta = <HTMLMetaElement>(
        doc.querySelector('meta[property="og:url"]')
      )
      if (ogUrlMeta && ogUrlMeta.content.length > 0) {
        domainName = ogUrlMeta.content
      }
    }
  }

  return domainName != null
    ? new URL(domainName).hostname.replace('www.', '')
    : new URL(uri).hostname.replace('www.', '')
}

export function getImage(doc: Document | null): {
  url?: string
  alt?: string
} {
  if (doc === null) return {}

  // according to OpenGraph <https://ogp.me>
  const ogImg = <HTMLMetaElement>doc.querySelector('meta[property="og:image"]')
  if (ogImg != null && ogImg.content.length > 0) {
    const alt = <HTMLMetaElement>(
      doc.querySelector('meta[property="og:image:alt"]')
    )

    return {
      url: ogImg.content,
      alt: alt != null && alt.content.length > 0 ? alt.content : undefined,
    }
  }

  const imgRelLink = <HTMLLinkElement>doc.querySelector('link[rel="image_src"]')
  if (imgRelLink != null && imgRelLink.href.length > 0) {
    return {
      url: imgRelLink.href,
    }
  }

  // Twitter cards: https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/summary
  const twitterImg = <HTMLMetaElement>(
    doc.querySelector('meta[name="twitter:image"]')
  )
  if (twitterImg != null && twitterImg.content.length > 0) {
    const alt = <HTMLMetaElement>(
      doc.querySelector('meta[property="twitter:image:alt"]')
    )

    return {
      url: twitterImg.content,
      alt: alt != null && alt.content.length > 0 ? alt.content : undefined,
    }
  }

  try {
    const img = Array.from(doc.getElementsByTagName('img'))[0]
    return { url: img.src, alt: img.alt }
  } catch (e) {}

  return {}
}
