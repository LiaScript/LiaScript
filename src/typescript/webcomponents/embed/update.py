# type: ignore
import json
from datetime import date
from typing import Union
import httplib2
from bs4 import BeautifulSoup


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


def get_soup(url: str) -> Union[str, BeautifulSoup]:
    """
    Return a BeautifulSoup object from a url or in case of an error a string message.
    """

    problem = "unknown\n"

    try:
        resp, body = httplib2.Http(
            disable_ssl_certificate_validation=True, timeout=30
        ).request(url)

        if resp["status"] == "200" or len(body) > 250:
            return BeautifulSoup(body, "html5lib")

        print("--->", resp)
        print("\n--->", body)
        problem = str(resp)+"\n\n"+str(body)+"\n"

    except Exception as err:  # pylint: disable=broad-except
        problem = str(err)

    return problem


def meta_description(soup: BeautifulSoup) -> str:
    """
    Search for a content description in the meta tags of a html page.
    """

    try:
        match = soup.find("meta", attrs={"name": "description"})
        if match is not None and match["content"] != "":
            return match["content"]

        match = soup.find("meta", attrs={"name": "Description"})
        if match is not None and match["content"] != "":
            return match["content"]

        match = soup.find("meta", {"property": "twitter:description"})
        if match is not None and match["content"] != "":
            return match["content"]

        match = soup.find("meta", {"property": "og:description"})
        if match is not None and match["content"] != "":
            return match["content"]

        match = soup.find("meta", {"property": "og:title"})
        if match is not None and match["content"] != "":
            return match["content"]

        print("--- Description: problem parsing meta -----------------------")
        for meta in soup.find_all('meta'):
            print("  ", meta)
        print("-------------------------------------------------------------")

        # content of the first paragraph
        match = soup.find("p")
        if match is not None and match.sting != "":
            return match.string

        match = soup.find("title")
        if match is not None and match.sting != "":
            return match.string

    except Exception as err:  # pylint: disable=broad-except
        print(str(err))

    return ""


def meta_image(soup: BeautifulSoup, url: str) -> str:
    """
    Search for an image url in the meta tags of a html page.
    """
    try:
        match = soup.find("meta", {"property": "twitter:image"})
        if match is not None:
            return match["content"]

        match = soup.find("meta", {"property": "og:image"})
        if match is not None:
            return match["content"]

        print("--- Image: problem parsing meta -----------------------------")
        for meta in soup.find_all('meta'):
            print("  ", meta)
        print("-------------------------------------------------------------")

        for meta in soup.find_all('img'):
            if meta["src"].startswith("http"):
                return meta["src"]

            if not meta["src"].startswith("data:"):
                return url + meta["src"]

    except Exception as err:  # pylint: disable=broad-except
        print(str(err))

    return ""


if __name__ == "__main__":

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

        for (i, p) in enumerate(provider):
            print("################################################################################")
            print(i, p["name"], ":", p["url"])

            response = get_soup(p["url"])

            description = ""
            image = ""

            if isinstance(response, str):

                brokenLinks += [p["url"]]
                brokenProviders += (
                    "__"
                    + p["name"]
                    + ":__ "
                    + p["url"]
                    + "\n\n```\n"
                    + response
                    + "```\n\n---\n\n"
                )
                print("--> BROKEN")

            else:
                outfile.write("__" + p["name"] + ":__ " + p["url"] + "\n\n")

                description = meta_description(response)

                if description is not None:
                    description = description.strip().replace("\n", " ")
                    description = (description[:300] + '..') if len(description) > 300 else description

                image = meta_image(response, p["url"])

                if description:
                    outfile.write(description + "\n\n")

                if image:
                    outfile.write("![logo](" + image + ")\n\n")

                print("\n--> [", image, "]")
                print("\n   ", description, "\n")

                outfile.write("---\n\n")

        outfile.write("## Broken sites\n\n" + brokenProviders)

    for d in data:
        if d["provider_url"] not in brokenLinks:
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
