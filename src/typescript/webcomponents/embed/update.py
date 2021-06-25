import httplib2
import json

print("Start downloading ... ")
_, content = httplib2.Http().request("https://oembed.com/providers.json")
print("done")

data = json.loads(content)

collection = []

for d in data:
    for e in d["endpoints"]:
        if "schemes" in e:
            schemes = []
            for scheme in e["schemes"]:
                if not scheme.__contains__("\""):
                    schemes.append(scheme)

            collection += [[e["url"], schemes]]
        else:
            collection += [[ e["url"], [] ]]

collection = json.dumps(collection).replace(" ", "")


with open('./endpoints.ts', 'w') as outfile:
    outfile.write("export const endpoints = JSON.parse(`" + collection + "`)\n")
    outfile.close()