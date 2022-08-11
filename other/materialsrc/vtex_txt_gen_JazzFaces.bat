:: vtex_txt_gen.bat - Sierra Foxtrot
:: Not responsible if your hard-drive gets filled with vtex .txt files!
:: 
:: Makes a copy of our VTEX parameters for each Jazztronauts Cat texture
:: Find And Replace Text v1.99b by Lionelle Lunesu

SETLOCAL EnableDelayedExpansion
for /d %%G in ("..\materialsrc\models\andy\*") do (
	for /r %%F in ("..\materialsrc\models\andy\%%~nxG\*_*.tga") do (
	
		for /F "tokens=1 delims=." %%a in ("%%~nxF") do (
			copy "..\materialsrc\VTEXBASE_JazzFaces.txt"	"..\materialsrc\models\andy\%%~nxG\%%a.txt"
		)
	)
)
pause