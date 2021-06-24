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
            collection += [[e["url"], e["schemes"]]]
        else:
            collection += [[ e["url"], [] ]]
    #print(d["endpoints"])

collection = json.dumps(collection).replace(" ", "")

with open('./endpoints.ts', 'w') as outfile:
    outfile.write("export const endpoints = JSON.parse('" + collection + "'\n")
    outfile.close()