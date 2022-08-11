for /d %%G in ("..\materialsrc\models\andy\*") do (
	call "..\..\bin\vtex" -mkdir -nopause -outdir "..\materials\models\andy\%%~nxG" "..\materialsrc\models\andy\%%~nxG\*.tga" )
pause