@echo off
REM ============================================================
REM Build script for the SugarCube Linter Testbed (Windows .bat)
REM Compiles all .twee/.js/.css files under src\ into a single
REM HTML file using Tweego and the SugarCube-2 story format.
REM
REM Searches for tweego.exe in this order:
REM   1. %SCRIPT_DIR%\tweego\tweego.exe   (bundled subfolder)
REM   2. %SCRIPT_DIR%\tweego.exe          (alongside this script)
REM   3. PATH                              (system install)
REM
REM Usage:
REM   build.bat            one-shot build to dist\story.html
REM   build.bat clean      remove dist\ before building
REM ============================================================
setlocal enableextensions enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "SRC_DIR=%SCRIPT_DIR%\src"
set "DIST_DIR=%SCRIPT_DIR%\dist"
set "OUTPUT=%DIST_DIR%\story.html"

if /i "%~1"=="clean" (
    if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%"
)

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

REM ---- Locate tweego.exe ------------------------------------------------
set "TWEGO_EXE="

if exist "%SCRIPT_DIR%\tweego\tweego.exe" (
    set "TWEGO_EXE=%SCRIPT_DIR%\tweego\tweego.exe"
    goto :found_tweego
)

if exist "%SCRIPT_DIR%\tweego.exe" (
    set "TWEGO_EXE=%SCRIPT_DIR%\tweego.exe"
    goto :found_tweego
)

for /f "delims=" %%I in ('where tweego 2^>nul') do (
    set "TWEGO_EXE=%%I"
    goto :found_tweego
)

echo.
echo ERROR: tweego.exe not found.
echo.
echo Searched:
echo   - %SCRIPT_DIR%\tweego\tweego.exe
echo   - %SCRIPT_DIR%\tweego.exe
echo   - PATH
echo.
echo Download Tweego from https://www.motoslave.net/tweego/
echo and either unzip it into a 'tweego' subfolder of this project,
echo place tweego.exe alongside build.bat, or add its folder to PATH.
echo.
exit /b 1

:found_tweego
echo Using tweego: %TWEGO_EXE%

REM ---- Report SugarCube version (informational) -------------------------
for %%D in ("%TWEGO_EXE%") do set "TWEGO_DIR=%%~dpD"
if "%TWEGO_DIR:~-1%"=="\" set "TWEGO_DIR=%TWEGO_DIR:~0,-1%"

set "SC_FORMAT=%TWEGO_DIR%\storyformats\sugarcube-2\format.js"
if exist "%SC_FORMAT%" (
    for /f "tokens=2 delims=:," %%V in ('findstr /r /c:"\"version\"" "%SC_FORMAT%" 2^>nul') do (
        if not defined SC_VERSION_RAW set "SC_VERSION_RAW=%%V"
    )
    if defined SC_VERSION_RAW (
        set "SC_VERSION=!SC_VERSION_RAW:"=!"
        echo SugarCube version: !SC_VERSION!
        if /i not "!SC_VERSION!"=="2.37.0" (
            echo.
            echo WARNING: Project targets SugarCube 2.37.0, but found !SC_VERSION!.
            echo   ^<^<do^>^> ^/^<^<redo^>^> and other v2.37 features may not work.
            echo   Replace the sugarcube-2 folder with the 2.37.0 release from:
            echo   https://github.com/tmedwards/sugarcube-2/releases/tag/v2.37.0
            echo.
        )
    )
) else (
    echo WARNING: SugarCube-2 format not found at %SC_FORMAT%
    echo   Make sure the storyformats\sugarcube-2 folder exists next to tweego.exe.
    echo.
)

REM ---- Run tweego -------------------------------------------------------
REM -f sugarcube-2   story format
REM -t               test mode (Twine 2-style formats only)
REM -l               log passage/word counts
REM -o               output file
"%TWEGO_EXE%" -f sugarcube-2 -t -l -o "%OUTPUT%" "%SRC_DIR%"
set "EXITCODE=%ERRORLEVEL%"

if not "%EXITCODE%"=="0" (
    echo.
    echo Build FAILED. Exit code %EXITCODE%
    echo.
    exit /b %EXITCODE%
)

echo.
echo Built: %OUTPUT%
echo   Open it in a browser to play / inspect.
endlocal
