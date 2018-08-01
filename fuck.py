import fnmatch
import os

def getFiles(root, match):
	matches = []
	for root, dirnames, filenames in os.walk(root):
		for filename in fnmatch.filter(filenames, match):
			matches.append(os.path.join(root, filename))

	return matches

# Source material names that have uppercases
materialfiles = getFiles("gamemodes/jazztronauts/content/materials", "*.*")

# Binary replace
replaceFiles = getFiles("gamemodes/jazztronauts/content/materials", "*.vmt")
replaceFiles += getFiles("gamemodes/jazztronauts/content/models", "*.mdl")

def replaceContents(filename, find, replace):
	f = open(filename, 'rb')
	contents = f.read().replace(find, replace)
	f.close()

	# Write result
	f = open(filename, 'wb')
	f.write(contents)
	f.close()


for mat in materialfiles:
	# Skip all-lowercase files
	if mat.islower():
		continue

	basename = os.path.splitext(os.path.basename(mat))[0]
	basenamelow = basename.lower()

	if basename.islower():
		# print("!!!! ", mat)
		# continue

	print(basename, mat)

	for binfile in replaceFiles:
		replaceContents(binfile, basename, basenamelow)

	# convert to lower case
	os.rename(mat, mat.lower())

	# fuck you git
	gitlower = "git mv --force " + mat + " " + mat.lower()
	os.system(gitlower)