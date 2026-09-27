@echo off
rem Launches Bastion Line. Running from source needs Godot 4.7; without it, this falls back to the
rem prebuilt exe in build\ if there is one. To just play, download BastionLine.exe from the releases.
setlocal
set "GODOT="
if exist "%LOCALAPPDATA%\Microsoft\WinGet\Links\godot.exe" set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Links\godot.exe"
if not defined GODOT for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do (
    for %%F in ("%%D\Godot_v4*_win64.exe") do set "GODOT=%%F"
)
if not defined GODOT for /f "delims=" %%G in ('where godot 2^>nul') do if not defined GODOT set "GODOT=%%G"
if defined GODOT (
    start "" "%GODOT%" --path "%~dp0."
    exit /b 0
)
if exist "%~dp0build\BastionLine.exe" (
    start "" "%~dp0build\BastionLine.exe"
    exit /b 0
)
echo Bastion Line: Godot 4.7 isn't installed, so the game can't run from source here.
echo.
echo   To play:  download BastionLine.exe from
echo             https://github.com/Swooshiiroll/bastion-line/releases/latest
echo             and run it. Nothing else needs to be installed.
echo.
echo   To run from source:  winget install GodotEngine.GodotEngine  then run Play.cmd again.
echo.
pause
