import sys
import json
import time
import urllib2

HOST = "http://api.steampowered.com"
ENDPOINT = "IPublishedFileService/QueryFiles/v0001/"
APPID = 4000
NUMPERPAGE = 100
DELAY = 0.0 # How long to delay between requests
FILENAME = "addons.txt"

if __name__ == "__main__":

    if len(sys.argv) <= 1:
        print("A Steam WebAPI key is required.")
        sys.exit(1)

    f = open(FILENAME, "w")

    key = sys.argv[1]
    page = 0

    while True:
        req = "{0}/{1}?key={2}&appid={3}&requiredtags[0]=map&numperpage={4}&page={5}".format(HOST, ENDPOINT, key, APPID, NUMPERPAGE, page)
        response = urllib2.urlopen(req).read()
        resobj = json.loads(response)
        total = resobj["response"]["total"]
        # print(len(resobj["response"]["publishedfiledetails"]))
        for addon in resobj["response"]["publishedfiledetails"]:
            f.write(addon["publishedfileid"] + "\n")

        # Informative output
        finished = page * NUMPERPAGE + len(resobj["response"]["publishedfiledetails"])
        print("Finished {0} addons. ({1:.2f}% of {2})".format(finished, finished * 100.0 / total, total))

        # so valve doesn't get angry at us
        time.sleep(0.1)

        # Move onto to the next page
        page += 1

        if page * NUMPERPAGE > resobj["response"]["total"]:
            break
    
    print("Finished!!")
    f.close()

