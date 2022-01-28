import httplib2
import json
from datetime import date

def toHTTPS(url):
    url = url.replace("http:", "https:")
    return url

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
                    schemes.append(toHTTPS(scheme))

            collection += [[ toHTTPS(e["url"]), schemes]]
        else:
            collection += [[ toHTTPS(e["url"]), [] ]]

collection = json.dumps(collection).replace(" ", "")

with open('./endpoints.ts', 'w') as outfile:
    outfile.write("export const endpoints = JSON.parse(`" + collection + "`)\n")
    outfile.close()

print("done\nupdating README.md ... ")
with open('./README.md', 'w') as outfile:
    outfile.write("# oEmbed Service Providers\n\n")

    outfile.write("__date__: " + date.today().strftime("%d/%m/%Y") + "\n\n")

    outfile.write("| # | Provider Name | URL |\n")
    outfile.write("|--:|---------------|-----|\n")

    for (i, p) in enumerate(provider):
        outfile.write("| " + str(i) + " | " + p["name"] + " | " + p["url"] + " |\n")

print("done")