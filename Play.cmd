@echo off
rem Launches Bastion Line with the winget-installed Godot.
set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Links\godot.exe"
if not exist "%GODOT%" set "GODOT=godot"
start "" "%GODOT%" --path "%~dp0."
