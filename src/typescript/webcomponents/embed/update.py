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


def meta(url):

    try:
        _, content = httplib2.Http(timeout=30).request(url)
        soup = BeautifulSoup(content)
    except:
        return ""

    try:
        description = soup.find("meta", {"name": "description"})
        if description != None:
            return description["content"]

        description = soup.find("meta", {"name": "Description"})
        if description != None:
            return description["content"]

        description = soup.find("meta", {"property": "twitter:description"})
        if description != None:
            return description["content"]

        description = soup.find("meta", {"property": "og:description"})
        if description != None:
            return description["content"]

        description = soup.find("meta", {"property": "og:title"})
        if description != None:
            return description["content"]

    except:
        pass

    return ""


print("Start downloading ... ")
_, content = httplib2.Http().request("https://oembed.com/providers.json")
print("done")

collection = []
provider = []

print("generating entdpoints.ts ...")

data = json.loads(content)

for d in data:

    provider.append({"name": d["provider_name"], "url": toHTTPS(d["provider_url"])})

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

with open('./endpoints.ts', 'w') as outfile:
    outfile.write("export const endpoints = JSON.parse(`" + collection + "`)\n")
    outfile.close()

print("done\nupdating README.md ... ")
with open('./README.md', 'w') as outfile:
    outfile.write("# oEmbed Service Providers\n\n")

    outfile.write("__date__: " + date.today().strftime("%d/%m/%Y") + "\n\n")

    for (i, p) in enumerate(provider):
        description = meta(p["url"])

        outfile.write("__" + p["name"] + ":__ " + p["url"] + "\n\n" + description + "\n\n---\n\n")

        print(i, p["name"], ":", p["url"], "-->", description)

print("done")
