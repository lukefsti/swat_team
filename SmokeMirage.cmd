@echo off
SETLOCAL EnableDelayedExpansion

:: Paths based on running directory
set NIRCMD_PATH=%~dp0src\tools\nircmd.exe
set WALLPAPER_PATH=%~dp0src\assets\wallpaper.jpg

:: Get Screen Resolution
for /f "tokens=2 delims==" %%a in ('wmic desktopmonitor get screenwidth /value') do set width=%%a
for /f "tokens=2 delims==" %%a in ('wmic desktopmonitor get screenheight /value') do set height=%%a

:: Volume Control
set /a volumeLevel=%random% %% 101
%NIRCMD_PATH% setsysvolume (65535 * %volumeLevel% / 100)
echo Volume has been set to %volumeLevel%%

:: Randomly Move the Cursor (using screen resolution)
set /a x=%random% %% !width!
set /a y=%random% %% !height!
%NIRCMD_PATH% setcursor %x% %y%
echo Cursor moved to %x%, %y%

:: Minimize All Windows
%NIRCMD_PATH% win min all
echo All windows minimized

:: Clear Clipboard
%NIRCMD_PATH% clipboard clear
echo Clipboard cleared

:: Set Wallpaper
%NIRCMD_PATH% setwallpaper %WALLPAPER_PATH%
echo Wallpaper set from %WALLPAPER_PATH%

:: Turn off Screen
%NIRCMD_PATH% monitor off
echo monitor offline

ENDLOCAL
