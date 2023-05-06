import sys
import json
import time
import urllib.request
import re

HOST = "http://api.steampowered.com"
ENDPOINT = "IPublishedFileService/QueryFiles/v0001/"
APPID = 4000
NUMPERPAGE = 100
DELAY = 0.1 # How long to delay between requests
FILENAME = "addons.txt"

ignore_words = ["content", "server"]
ignore_reg = "(?<!_){0}(?!_)" # Allow ignore words to be a part of the map name (surrounding underscores)
def containsIgnoreWord(str, word):
    return re.search(ignore_reg.format(word), str) is not None

def containsIgnoreWords(str):
    for word in ignore_words:
        if containsIgnoreWord(str, word):
            return True
        
    return False

if __name__ == "__main__":

    if len(sys.argv) <= 1:
        print("A Steam WebAPI key is required.")
        sys.exit(1)

    if len(sys.argv) > 2:
        FILENAME = sys.argv[2]

    key = sys.argv[1]
    page = 0
    workshopids = []

    f = open(FILENAME, "w")

    while True:
        req = "{0}/{1}?key={2}&appid={3}&requiredtags[0]=map&numperpage={4}&page={5}&return_metadata=1&query_type=1".format(HOST, ENDPOINT, key, APPID, NUMPERPAGE, page)
        response = urllib.request.urlopen(req).read()
        resobj = json.loads(response.decode("utf-8", "ignore"))
        total = resobj["response"]["total"]

        for addon in resobj["response"]["publishedfiledetails"]:
            if "title" in addon and containsIgnoreWords(addon["title"]):
                ign_str = u"Ignoring: " + addon["title"]
                print(ign_str.encode('utf-8'))
                continue

            # Add if not already in (sometimes query will give us dupes?)
            wsid = addon["publishedfileid"]
            if not wsid in workshopids:
                workshopids.append(wsid)

        # Informative output
        finished = page * NUMPERPAGE + len(resobj["response"]["publishedfiledetails"])
        print("Finished {0} addons. ({1:.2f}% of {2})".format(finished, finished * 100.0 / total, total))

        # Move onto to the next page
        page += 1

        if page * NUMPERPAGE > resobj["response"]["total"]:
            break
        else:   
            # so valve doesn't get angry at us
            time.sleep(DELAY)
    
    # Results come back sorted, but reverse it so
    # newer entries are added at the end instead of shifting everything at the beginning
    workshopids.reverse()

    print("Dumping {0} addons to {1}".format(len(workshopids), FILENAME))
    for id in workshopids:
        f.write(id + "\n")

    print("Finished!!")
    f.close()

