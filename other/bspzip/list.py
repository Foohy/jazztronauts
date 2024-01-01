import sys
import pathlib

if __name__ == "__main__":
    if (len(sys.argv) < 1):
        print("Not enough arguments")
        exit(1)

    output_file = sys.argv[1]
    zip_folder = sys.argv[2]

    f = open(output_file, "w")

    ZipDirectory = pathlib.Path(zip_folder)
    paths = ZipDirectory.rglob("*")

    for path in list(paths):
        if path.is_file():
            f.write(str(path.relative_to(zip_folder)).replace("\\", "/"))
            f.write("\n")
            f.write(str(path.resolve()))
    
    print("all done")
    f.close()