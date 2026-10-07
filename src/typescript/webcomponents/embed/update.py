# type: ignore
import json
import re
import time
from concurrent.futures import ThreadPoolExecutor
from datetime import date
from typing import Tuple, Union
from urllib.parse import urljoin
import httplib2
from bs4 import BeautifulSoup

# optional: pip install curl_cffi
try:
    from curl_cffi import requests as curl_requests
except ImportError:
    curl_requests = None

# number of homepages that are downloaded in parallel
WORKERS = 16

# many sites block the default python user-agent with 403
HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0",
    "Accept": "text/html,application/xhtml+xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
}

# domains, that have expired and are now for sale (the provider is dead)
PARKED = re.compile(
    rb"hugedomains\.com|namebright|sedoparking|\bdan\.com/|afternic|bodis\.com"
    rb"|domain name is (available|for sale)|this domain (is|may be) for sale"
    rb"|domain (registration )?has\s+expired|suspendedpage\.cgi"
    rb"|location\.href\s*=\s*[\"']/lander",
    re.IGNORECASE,
)

# transparent placeholder images, that are not useful as a logo
SPACER = re.compile(r"(void|spacer|blank|pixel|transparent)\.(gif|png)", re.IGNORECASE)


def to_https(url: str) -> str:
    """
    Converts a url to https if it is not already https.
    """
    url = url.replace("http:", "https:")
    return url


def clean_protocol(url: str) -> str:
    """
    Remove all protocols from a url
    """
    url = to_https(url)
    url = url.replace("https://", "")
    return url


def fetch(url: str) -> Tuple[dict, bytes]:
    """
    Download a url and return the response headers (incl. "status") and body.
    If available curl_cffi is used, which mimics the TLS fingerprint of Chrome
    and thus passes more bot protections (e.g. Cloudflare) than httplib2.
    """
    if curl_requests is not None:
        resp = curl_requests.get(url, impersonate="chrome", timeout=30, verify=False)
        # content-location holds the final url after redirects (as in httplib2)
        return {**resp.headers, "status": str(resp.status_code), "content-location": resp.url}, resp.content

    return httplib2.Http(
        disable_ssl_certificate_validation=True, timeout=30
    ).request(url, headers=HEADERS)


def get_soup(url: str, retry: bool = True) -> Union[str, BeautifulSoup]:
    """
    Return a BeautifulSoup object from a url or in case of an error a string message.
    """

    problem = "unknown\n"

    try:
        resp, body = fetch(url)

        # server errors are often temporary, so try once more
        if retry and resp["status"].startswith("5"):
            time.sleep(5)
            return get_soup(url, retry=False)

        final_url = resp.get("content-location", url)

        if resp["status"] == "200" and (PARKED.search(body) or PARKED.search(final_url.encode())):
            return "parked domain: " + final_url + "\n"

        if resp["status"] == "200":
            soup = BeautifulSoup(body, "html.parser")
            # relative links have to be resolved against the url after redirects
            soup.final_url = final_url
            return soup

        problem = str(resp)+"\n\n"+str(body)+"\n"

    except Exception as err:  # pylint: disable=broad-except
        problem = str(err)

        # some sites have a broken https setup, but redirect correctly from http
        if url.startswith("https:"):
            return get_soup(url.replace("https:", "http:", 1))

    return problem


def meta_content(soup: BeautifulSoup, key: str) -> str:
    """
    Return the content of the first non-empty meta tag, whose name or property
    matches key (case-insensitive), otherwise an empty string.
    """
    key = key.lower()
    for meta in soup.find_all("meta"):
        if key in (meta.get("name", "").lower(), meta.get("property", "").lower()):
            content = meta.get("content", "").strip()
            if content:
                return content
    return ""


def dump_meta(soup: BeautifulSoup, topic: str) -> str:
    return (
        "--- " + topic + ": problem parsing meta -----------------------\n"
        + "".join("   " + str(meta) + "\n" for meta in soup.find_all("meta"))
        + "-------------------------------------------------------------\n"
    )


def meta_description(soup: BeautifulSoup) -> str:
    """
    Search for a content description in the meta tags of a html page.
    """

    for key in ["description", "twitter:description", "og:description", "og:title", "twitter:title", "og:site_name"]:
        content = meta_content(soup, key)
        if content:
            return content

    # the title or the content of the first paragraph
    for tag in ["title", "p"]:
        match = soup.find(tag)
        if match is not None:
            content = match.get_text(" ", strip=True)
            if content:
                return content

    return ""


def meta_image(soup: BeautifulSoup, url: str) -> str:
    """
    Search for an image url in the meta tags of a html page.
    """
    url = soup.final_url

    for key in ["twitter:image", "twitter:image:src", "og:image", "og:image:url"]:
        content = meta_content(soup, key)
        if content and not content.startswith("data:"):
            return urljoin(url, content)

    for rel in ["apple-touch-icon", "icon", "shortcut icon"]:
        for link in soup.find_all("link", href=True):
            if " ".join(link.get("rel", [])).lower() == rel and not link["href"].startswith("data:"):
                return urljoin(url, link["href"])

    icon = manifest_icon(soup, url)
    if icon:
        return icon

    for img in soup.find_all("img", src=True):
        src = img["src"].strip()
        if src and not src.startswith("data:") and not SPACER.search(src):
            return urljoin(url, src)

    # most sites still have a favicon, even if it is not linked
    try:
        resp, _ = fetch(urljoin(url, "/favicon.ico"))
        if resp["status"] == "200" and resp.get("content-type", "").startswith("image"):
            return resp.get("content-location", urljoin(url, "/favicon.ico"))
    except Exception:  # pylint: disable=broad-except
        pass

    return ""


def manifest_icon(soup: BeautifulSoup, url: str) -> str:
    """
    Return the largest icon of a linked web app manifest, pages that are
    rendered with JavaScript (e.g. TikTok) often only provide icons there.
    """
    link = soup.find("link", rel="manifest", href=True)
    if link is None:
        return ""

    try:
        manifest_url = urljoin(url, link["href"])
        resp, body = fetch(manifest_url)
        if resp["status"] != "200":
            return ""

        icons = json.loads(body).get("icons", [])
        size = lambda icon: max([int(s.split("x")[0]) for s in icon.get("sizes", "0x0").split() if "x" in s] or [0])
        icons = sorted((i for i in icons if i.get("src")), key=size, reverse=True)
        if icons:
            # icon urls are relative to the manifest, not to the page
            return urljoin(resp.get("content-location", manifest_url), icons[0]["src"])
    except Exception:  # pylint: disable=broad-except
        pass

    return ""


def analyse(provider: dict) -> Tuple[str, str, str]:
    """
    Download and analyse the homepage of a provider, this runs in parallel.
    Returns the log output, the README entry, and in case of an error the
    problem description (README entry is then empty).
    """
    response = get_soup(provider["url"])

    if isinstance(response, str):
        return "--> BROKEN: " + response.strip() + "\n", "", response

    log = ""

    description = meta_description(response).strip().replace("\n", " ")
    description = (description[:300] + '..') if len(description) > 300 else description
    if not description:
        log += dump_meta(response, "Description")

    image = meta_image(response, provider["url"])
    if not image:
        log += dump_meta(response, "Image")

    entry = "__" + provider["name"] + ":__ " + provider["url"] + "\n\n"

    if description:
        entry += description + "\n\n"

    if image:
        entry += "![logo](" + image + ")\n\n"

    log += "\n--> [ " + image + " ]\n\n    " + description + "\n"

    return log, entry + "---\n\n", ""


if __name__ == "__main__":

    if curl_requests is None:
        print("WARNING: curl_cffi is not installed, sites behind Cloudflare will be marked as broken")
        print("         install it via: pip install curl_cffi (Arch: pacman -S python-curl_cffi)\n")

    print("Start downloading ... ")
    _, content = httplib2.Http().request("https://oembed.com/providers.json")
    print("done")

    collection = []
    provider = []
    brokenLinks = []

    print("generating endpoints.ts ...")

    data = json.loads(content)

    for d in data:
        provider.append({"name": d["provider_name"], "url": to_https(d["provider_url"])})

    print("done\nupdating README.md ... ")
    with open('./README.md', 'w', encoding='utf-8') as outfile:
        outfile.write("# oEmbed Service Providers\n\n")

        outfile.write("__date__: " + date.today().strftime("%d/%m/%Y") + "\n\n")

        brokenProviders = ""

        # pool.map runs in parallel, but returns the results in the original order
        with ThreadPoolExecutor(max_workers=WORKERS) as pool:
            for (i, (p, (log, entry, problem))) in enumerate(zip(provider, pool.map(analyse, provider))):
                print("################################################################################")
                print(i, p["name"], ":", p["url"])
                print(log)

                if problem:
                    brokenLinks += [p["url"]]
                    brokenProviders += (
                        "__"
                        + p["name"]
                        + ":__ "
                        + p["url"]
                        + "\n\n```\n"
                        + problem
                        + "```\n\n---\n\n"
                    )
                else:
                    outfile.write(entry)

        outfile.write("## Broken sites\n\n" + brokenProviders)
    for d in data:
        if to_https(d["provider_url"]) not in brokenLinks:
            for e in d["endpoints"]:
                if "schemes" in e:
                    schemes = []
                    for scheme in e["schemes"]:
                        if not scheme.__contains__("\""):
                            schemes.append(clean_protocol(scheme))

                    collection += [[clean_protocol(e["url"]), schemes]]
                else:
                    collection += [[clean_protocol(e["url"]), []]]

    collection = json.dumps(collection).replace(" ", "")

    print("writing down endpoints ... ")
    with open('./endpoints.ts', 'w', encoding='utf-8') as outfile:
        outfile.write("export const endpoints = JSON.parse(`" + collection + "`)\n")
        outfile.close()

    print("done")
