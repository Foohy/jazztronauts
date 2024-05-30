#!/usr/bin/env python

import sys
import json
import time
import urllib.request
import urllib.parse
import re

HOST = "http://api.steampowered.com"
ENDPOINT = "IPublishedFileService/QueryFiles/v0001/"
APPID = 4000
NUMPERPAGE = 100
DELAY = 0.1 # How long to delay between requests
FILENAME = "addons.txt"

# This regex nightmare is an attempt to avoid false positives
# Words with letters or underscore before will be kept (like gm_navigation)
# Words with letters after will be kept (like Navy), unless |(suffix) matches
# Anything after a suffix will also be caught (like navmeshed)
ignore_reg = "(?<![A-Z_]){0}(?=$|[^A-Z]|s{1})"
ignore_words = [
	"content|(pack)|(map)",
	"server|(content)",
	"nav|(mesh)|(igat)",
	"node|(d)|(graph)",
	"icon",
]

# Now forget allat, if these appear ANYWHERE except next to an underscore they go
strict_reg = "(?<!_){0}(?!_)"
ignore_strict = [
	"content",
	"server",
	"mapicon",
]

def containsIgnoreWord(str, word):
	word = word.split('|', 1)
	suffixes = ""
	if len(word) == 2:
		suffixes = "|" + word[1]

	return re.search(ignore_reg.format(word[0], suffixes), str, flags=re.IGNORECASE) is not None

def containsIgnoreStrict(str, word):
	return re.search(strict_reg.format(word), str, flags=re.IGNORECASE) is not None

def containsIgnoreWords(str):
	for word in ignore_strict:
		if containsIgnoreStrict(str, word):
			return word

	for word in ignore_words:
		if containsIgnoreWord(str, word):
			return word

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

	cursor = "*"
	last_cursor = None
	while cursor != None and cursor != last_cursor:
		req = "{0}/{1}?key={2}&appid={3}&requiredtags[0]=map&numperpage={4}&cursor={5}&return_metadata=1&query_type=1".format(HOST, ENDPOINT, key, APPID, NUMPERPAGE, urllib.parse.quote_plus(cursor))
		response_data = urllib.request.urlopen(req).read()
		response = json.loads(response_data.decode("utf-8", "ignore"))["response"]
		total = response["total"]
		last_cursor = cursor
		cursor = response["next_cursor"]

		for addon in response["publishedfiledetails"]:
			if not "publishedfileid" in addon or not "title" in addon:
				continue
			wsid = addon["publishedfileid"]
			title = addon["title"]

			hasignoreword = containsIgnoreWords(title)
			sexyfuntimes = "maybe_inappropriate_sex" in addon and addon["maybe_inappropriate_sex"] == True
			if hasignoreword or sexyfuntimes:
				ign_str = u"Ignoring: " + title + " (ID " + wsid + ")"
				if hasignoreword:
					ign_str = ign_str + ' (has "' + hasignoreword.split('|', 1)[0] + '")'
				if sexyfuntimes:
					ign_str = ign_str + " (has sex)"
				print(ign_str.encode('utf-8'))
				continue

			# Add if not already in (sometimes query will give us dupes?)
			if not wsid in workshopids:
				workshopids.append(wsid)

		# Informative output
		finished = page * NUMPERPAGE + len(response["publishedfiledetails"])
		print("Finished {0} addons. ({1:.2f}% of {2})".format(finished, finished * 100.0 / total, total))

		# Move onto to the next page
		page += 1

		if page * NUMPERPAGE > response["total"]:
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
