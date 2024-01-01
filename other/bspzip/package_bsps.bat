@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

rem Assumes we're running as a loosely installed addon in the garrysmod/addons/jazztronauts directory!
set "BSPZIP=..\..\..\..\..\bin\bspzip.exe"
set "BSPFOLDER=..\..\maps"
set "ZIPFOLDER=..\..\bspzip"


call:pakBspList jazz_bar
call:pakBspList jazz_apartments

goto:eof



rem Package all the files in bspzip/<mapname> into <mapname>.bsp
:pakBspList

echo "Build tmp file list"
python list.py %~1.txt "%ZIPFOLDER%\%~1"

echo "Packing %~1.bsp"
"%BSPZIP%" -addorupdatelist "%BSPFOLDER%/%~1.bsp" %~1.txt "%BSPFOLDER%/%~1.bsp"
del %~1.txt

goto:eof

PAUSE
ENDLOCAL