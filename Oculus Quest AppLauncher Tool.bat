@echo off

cd /D "%~dp0"

mkdir temp

set "java=.\res\jre\bin\java.exe"
set "adb=.\res\platform-tools\adb.exe"

rem Get package names

echo -----------------------------------------------
echo First select the package you'd like to replace
echo -----------------------------------------------
echo The icon and name from this app with be used in the apps screen
echo (It will be uninstalled and data will be lost)
echo.

Call :selectpackage
set outpkg=%return%
echo Using %outpkg% as replaced package
clear

echo -----------------------------------------------
echo Now select the package you'd like to launch
echo -----------------------------------------------
echo This is the app that will be open instead of the replaced package
echo (It will be reinstalled and data might be lost)
echo.

Call :selectpackage
set inpkg=%return%
echo Using %inpkg% as launched package
clear

echo.
echo "REDIRECT %outpkg% -> %inpkg%"
echo.
echo When you try to open %outpkg% from the main menu, 
echo %inpkg% will be opened instead.
echo.
echo When you first launch the app, you'll be notified that it is modified. Make sure NOT to restore.
echo You can revert this by uninstalling %outpkg%, then resinstalling both if desired.
echo.
echo Close the window to cancel, or
pause

@REM Extract APK
for /f %%i in ('%adb% shell pm path %inpkg%') do set apkpath=%%i
set apkpath=%apkpath:~8%
echo Found %apkpath%
%adb% pull %apkpath% ./temp/base.apk 


@REM Modify apk

echo.
echo  -- Decompiling APK [1/6] -- 

%java% -jar ./res/apktool.jar d -f -o ./temp/decompiled ./temp/base.apk 

setlocal enableextensions disabledelayedexpansion
set "search=renameManifestPackage: null"
set "replace=renameManifestPackage: %outpkg%"

echo.
echo  -- Renaming Package [2/6] -- 
set textFile=.\temp\decompiled\apktool.yml
for /f "delims=" %%i in ('type "%textFile%" ^& break ^> "%textFile%" ') do (
	set "line=%%i"
	setlocal enabledelayedexpansion
	>>"%textFile%" echo(!line:%search%=%replace%!
	endlocal
)
set "line="
set "i="

echo.
echo  -- Recompiling APK [3/6] -- 
%java% -jar ./res/apktool.jar b ./temp/decompiled -o ./temp/modified.apk

echo.
echo  -- Signing APK [4/6] -- 
%java% -jar ".\res\uber-apk-signer-1.2.1.jar" -a ".\temp\modified.apk"

@REM Uninstall/reinstall

echo.
echo  -- Uninstalling Old Packages [5/6] --
%adb% uninstall %inpkg%
%adb% uninstall %outpkg%

echo.
echo  -- Installing APK [6/6] --
.\res\platform-tools\adb.exe install ./temp/modified-aligned-debugSigned.apk
echo Done. Restart your headset if you have issues. (Hold Power Button then Restart)
pause
rmdir temp
goto end


@REM SELECT PACKAGE FUNCTION
:selectpackage
set filter=
set /P filter="Enter package name or search term (Leave empty to list all):"
if not defined filter set "filter=:"

:relist

set /a index=0
set "line="
set "i="

%adb% shell pm list packages | findstr %filter% >> pkglist
for /f "delims=" %%i in ('type "pkglist" ^& break ^> "pkglist" ') do (
	set "line=%%i"
	setlocal enabledelayedexpansion
	echo !index! - !line:~8!
	endlocal
	set /a index+=1
)
set "line="
set "i="
del pkglist

:reinput
set ofilter=%filter%
if %index% EQU 0 set /P filter="No packages found. Try a shorter search term or press enter to list all:"
if %index% NEQ 0 set /P filter="Enter the number of the package you want, or a new search term:"
set "ntest=%filter%"
set /a ntest=ntest

if "%ntest%" NEQ "%filter%" goto :relist

if %ntest% LEQ %index% (
	if %ntest% GEQ 0 (
		@REM valid
	) else (
		echo Invalid input
		goto reinput
	)
) else (
	echo Invalid input
	goto reinput
)
%adb% shell pm list packages | findstr %ofilter% >> pkglist2

if %ntest% EQU 0 (
	for /f "delims=" %%i in ('type "pkglist2" ^& break ^> "pkglist2" ') do (
		set "line=%%i"
		goto nextline
	)
) else (
for /f "skip=%ntest% delims=" %%i in ('type "pkglist2" ^& break ^> "pkglist2" ') do (
		set "line=%%i"
		goto nextline
	)
)
:nextline
set return=%line:~8%
del pkglist2
EXIT /B 0
:end