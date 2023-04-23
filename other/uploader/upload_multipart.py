import fnmatch
import sys
import os
import glob2
import parser
import tempfile
import shutil
import argparse
from subprocess import check_output, CalledProcessError

gmod_dir = "F:/Steam Games/steamapps/common/GarrysMod/bin"

gmad = os.path.join(gmod_dir, "gmad.exe")
gmpublish = os.path.join(gmod_dir, "gmpublish.exe")

def parseInt(s):
	try:
		return int(s)
	except:
		return None

def getFiles(path):
	return glob2.glob(path, recursive = True)

def stripComments(line):
	pos = line.find("#")
	pos = pos if pos != -1 else len(line)
	return line[:pos]

def getPackSize(pack, filemap):
	size = 0
	for f, p in iter(filemap.items()):
		if p != pack:
			continue

		size += os.path.getsize(f)

	return size

def getAddonName(pack):
	return os.path.splitext(pack)[0] + ".gma"

def copyFile(src, dest):
	path = os.path.dirname(dest)
	if not os.path.exists(path):
		os.makedirs(path)

	shutil.copy(src, dest)


# incredibly lazy, sue me 
# https://stackoverflow.com/questions/1094841/reusable-library-to-get-human-readable-version-of-file-size
def sizeof_fmt(num, suffix='B'):
    for unit in ['','Ki','Mi','Gi','Ti','Pi','Ei','Zi']:
        if abs(num) < 1024.0:
            return "%3.1f%s%s" % (num, unit, suffix)
        num /= 1024.0
    return "%.1f%s%s" % (num, 'Yi', suffix)

searchpath = ""
def buildGMA(pack, filemap, tempdir):
	print("Moving files...")

	# 1. Copy all the files over to the temp dir
	for f, p in iter(filemap.items()):
		if p != pack:
			continue
		relpath = os.path.join(tempdir, os.path.relpath(f, searchpath))
		# os.makedirs(relpath)

		copyFile(f, relpath)

	# 2. Copy corresponding addon.txt 
	print("Copying " + pack)
	copyFile(pack, os.path.join(tempdir, "addon.json"))

	# 3 Invoke gmad and generate a new gma
	gmaname = getAddonName(pack)
	print("Building gma...")
	try:
		print(os.path.join(os.getcwd(), gmaname))
		out = check_output([gmad, "create", "-folder", tempdir, "-out", os.path.join(os.getcwd(), gmaname) ], encoding='UTF-8')
		print(out)
	except CalledProcessError as e:
		print("gmad FAILURE!!")
		print(e.output)
		raise

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="Organize multi-part addon uploads")
	parser.add_argument("dir", type=str, help="Root directory of addon to split up")
	parser.add_argument("-c", "--changelog", dest="changelog", type=str, help="Text for what to put in the change log")
	parser.add_argument("-b", "--build", dest="build", action="store_true", help="Enable building gmas")
	parser.add_argument("-u", "--upload", dest="upload", action="store_true", help="Enable uploading of gmas to workshop")
	args = parser.parse_args()

	if args.dir != None:
		searchpath = args.dir

	# Load in the split definition file
	lines = None
	with open("split.txt") as f:
		lines = f.readlines()

	# Grab each definition and build a mapping for where each file will go
	filemap = {}
	curpack = None
	allpacks = []
	packids = {}
	print("#### Beginning file scan")
	for i, finfo in enumerate(lines):

		# Strip comments/whitespace
		finfo = stripComments(finfo).strip()

		#Ignore blank lines
		if len(finfo) == 0:
			continue

		#Lines with ":" are addon pack directives
		pack = finfo.split(":")
		if len(pack) >= 2:
			curpack = pack[0]
			packids[curpack] = parseInt(pack[1])

			# Keep track of all packs we've come across
			if curpack not in allpacks:
				allpacks.append(curpack)

			print("Changing to pack " + curpack)
			continue

		if curpack == None:
			print("Addon pack name must be specified before filenames!")
			break

		fpath = os.path.normpath(os.path.join(searchpath, finfo))

		# Resolve all files that match the specified rule
		print("Adding " + os.path.abspath(fpath) + " to pack " + curpack)
		files = getFiles(fpath)
		for f in files:
			#ignore directories
			if os.path.isdir(f):
				continue

			filemap[f] = curpack

	excluded = list(filter(lambda x : x == 'ignore', allpacks))
	for pack in excluded:
		print("\tExcluding pack \"" + pack + "\"")
		allpacks.remove(pack)
	
	for pack in allpacks:
		print("{0:<35}: {1}".format(pack, sizeof_fmt(getPackSize(pack, filemap))))

	# Start building gmas for each addon
	if args.build:
		print("\n#### Beginning gma build ")
		for pack in allpacks:
			temp = tempfile.mkdtemp()
			try:
				buildGMA(pack, filemap, temp)
			except Exception as err:
				print("oops errored: ", err)
				exit()
			finally:
				shutil.rmtree(temp)


	# Create or update the addon on workshop
	if args.upload:
		print("\n#### Beginning workshop upload ")
		for pack in allpacks:
			wsid = packids[pack]
			try:
				mode = "create" 
				extraparam = []

				if wsid != None:
					mode = "update"
					extraparam += ["-id", str(wsid)]

				if args.changelog != None:
					extraparam += ["-changes", args.changelog]

				params = [gmpublish, mode, "-addon", getAddonName(pack), "-icon", "addon.jpg"] + extraparam
				print("Uploading params:")
				print(params)

				out = check_output(params, encoding='UTF-8')
				print(out)
			except CalledProcessError as e:
				print("gmpublish FAILURE!!")
				print(e.output)
