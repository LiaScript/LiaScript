import httplib2
import json
from datetime import date
from bs4 import BeautifulSoup


def toHTTPS(url):
    url = url.replace("http:", "https:")
    return url


def cleanProtocol(url):
    url = toHTTPS(url)
    url = url.replace("https://", "")
    return url


def getSoup(url):
    problem = "unknown\n"

    try:
        response, content = httplib2.Http(disable_ssl_certificate_validation=True, timeout=30).request(url)

        if response["status"] == "200" or len(content) > 250:
            return (True, BeautifulSoup(content, "html5lib"))

        else:
            print("--->", response)
            print("\n--->", content)
            problem = str(response)+"\n\n"+str(content)+"\n"
    except:
        pass

    return (False, problem)


def metaDescription(soup):
    try:
        description = soup.find("meta", attrs={"name": "description"})
        if description != None and description["content"] != "":
            return description["content"]

        description = soup.find("meta", attrs={"name": "Description"})
        if description != None and description["content"] != "":
            return description["content"]

        description = soup.find("meta", {"property": "twitter:description"})
        if description != None and description["content"] != "":
            return description["content"]

        description = soup.find("meta", {"property": "og:description"})
        if description != None and description["content"] != "":
            return description["content"]

        description = soup.find("meta", {"property": "og:title"})
        if description != None and description["content"] != "":
            return description["content"]

        print("--- Description: problem parsing meta -----------------------")
        for meta in soup.find_all('meta'):
            print("  ", meta)
        print("-------------------------------------------------------------")

        # content of the first paragraph
        description = soup.find("p")
        if description != None and description.sting != "":
            return description.string

        description = soup.find("title")
        if description != None and description.sting != "":
            return description.string

    except:
        pass

    return ""


def metaImage(soup, url):
    try:
        description = soup.find("meta", {"property": "twitter:image"})
        if description != None:
            return description["content"]

        description = soup.find("meta", {"property": "og:image"})
        if description != None:
            return description["content"]

        print("--- Image: problem parsing meta -----------------------------")
        for meta in soup.find_all('meta'):
            print("  ", meta)
        print("-------------------------------------------------------------")

        for meta in soup.find_all('img'):
            if meta["src"].startswith("http"):
                return meta["src"]
            elif not meta["src"].startswith("data:"):
                return url + meta["src"]

    except:
        pass

    return ""


print("Start downloading ... ")
_, content = httplib2.Http().request("https://oembed.com/providers.json")
print("done")

collection = []
provider = []
brokenLinks = []

print("generating entdpoints.ts ...")

data = json.loads(content)

for d in data:
    provider.append({"name": d["provider_name"], "url": toHTTPS(d["provider_url"])})

print("done\nupdating README.md ... ")
with open('./README.md', 'w') as outfile:
    outfile.write("# oEmbed Service Providers\n\n")

    outfile.write("__date__: " + date.today().strftime("%d/%m/%Y") + "\n\n")

    brokenProviders = ""

    for (i, p) in enumerate(provider):
        print("################################################################################")
        print(i, p["name"], ":", p["url"])

        (ok, soup) = getSoup(p["url"])

        description = ""
        image = ""

        if ok:
            outfile.write("__" + p["name"] + ":__ " + p["url"] + "\n\n")

            description = metaDescription(soup)

            if description != None:
                description = description.strip().replace("\n", " ")
                description = (description[:300] + '..') if len(description) > 300 else description

            image = metaImage(soup, p["url"])

            if description:
                outfile.write(description + "\n\n")

            if image:
                outfile.write("![logo](" + image + ")\n\n")

            print("\n--> [", image, "]")
            print("\n   ", description, "\n")

            outfile.write("---\n\n")
        else:
            brokenLinks += [p["url"]]
            brokenProviders += "__" + p["name"] + ":__ " + p["url"] + "\n\n```\n" + soup + "```\n\n---\n\n"
            print("--> BROKEN")

    outfile.write("## Broken sites\n\n" + brokenProviders)


for d in data:
    if not (d["provider_url"] in brokenLinks):
        for e in d["endpoints"]:
            if "schemes" in e:
                schemes = []
                for scheme in e["schemes"]:
                    if not scheme.__contains__("\""):
                        schemes.append(cleanProtocol(scheme))

                collection += [[cleanProtocol(e["url"]), schemes]]
            else:
                collection += [[cleanProtocol(e["url"]), []]]

collection = json.dumps(collection).replace(" ", "")

print("writing down endpoints ... ")
with open('./endpoints.ts', 'w') as outfile:
    outfile.write("export const endpoints = JSON.parse(`" + collection + "`)\n")
    outfile.close()

print("done")
