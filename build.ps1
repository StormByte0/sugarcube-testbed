# ============================================================
# Build script for the SugarCube Linter Testbed (PowerShell)
# Compiles all .twee/.js/.css files under src/ into a single
# HTML file using Tweego and the SugarCube-2 story format.
#
# Searches for tweego.exe in this order:
#   1. <ScriptDir>\tweego\tweego.exe   (bundled subfolder)
#   2. <ScriptDir>\tweego.exe          (alongside this script)
#   3. PATH                             (system install)
#
# Usage:
#   .\build.ps1                # one-shot build to dist\story.html
#   .\build.ps1 -Clean         # remove dist\ before building
#   .\build.ps1 -Watch         # rebuild on file change
#   .\build.ps1 -Output out.html
#   .\build.ps1 -Help
# ============================================================
[CmdletBinding()]
param(
    [string]$Output = "",
    [switch]$Watch,
    [switch]$Clean,
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\build.ps1 [-Clean] [-Watch] [-Output path.html] [-Help]"
    Write-Host ""
    Write-Host "  -Clean    Remove dist\ before building"
    Write-Host "  -Watch    Watch src\ for changes and rebuild automatically"
    Write-Host "  -Output   Path to the output HTML file (default: dist\story.html)"
    Write-Host "  -Help     Show this help message"
    exit 0
}

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SrcDir    = Join-Path $ScriptDir "src"
$DistDir   = Join-Path $ScriptDir "dist"
if (-not $Output) { $Output = Join-Path $DistDir "story.html" }

if ($Clean -and (Test-Path $DistDir)) {
    Write-Host "Cleaning $DistDir..."
    Remove-Item -Recurse -Force $DistDir
}

if (-not (Test-Path $DistDir)) {
    New-Item -ItemType Directory -Path $DistDir | Out-Null
}

# ---- Locate tweego.exe ------------------------------------------------
$TweegoExe = $null
$candidates = @(
    (Join-Path $ScriptDir "tweego\tweego.exe"),  # bundled subfolder
    (Join-Path $ScriptDir "tweego.exe")          # alongside script
)

foreach ($c in $candidates) {
    if (Test-Path $c) {
        $TweegoExe = $c
        break
    }
}

if (-not $TweegoExe) {
    $cmd = Get-Command tweego -ErrorAction SilentlyContinue
    if ($cmd) {
        $TweegoExe = $cmd.Source
    }
}

if (-not $TweegoExe) {
    Write-Error @"
tweego.exe not found. Searched:
  - $(Join-Path $ScriptDir 'tweego\tweego.exe')
  - $(Join-Path $ScriptDir 'tweego.exe')
  - PATH

Download Tweego from https://www.motoslave.net/tweego/ and either:
  - Unzip it into a 'tweego' subfolder of this project, or
  - Place tweego.exe alongside build.ps1, or
  - Add its folder to your PATH.
Make sure the SugarCube-2 story format is in tweego's storyformats\ folder.
"@
    exit 1
}

Write-Host "Using tweego: $TweegoExe" -ForegroundColor Cyan

# ---- Report SugarCube version (warn if not 2.37.0) -------------------
$TweegoDir = Split-Path -Parent $TweegoExe
$ScFormatJs = Join-Path $TweegoDir "storyformats\sugarcube-2\format.js"

if (Test-Path $ScFormatJs) {
    $formatContent = Get-Content $ScFormatJs -Raw
    if ($formatContent -match '"version"\s*:\s*"([^"]+)"') {
        $ScVersion = $Matches[1]
        Write-Host "SugarCube version: $ScVersion" -ForegroundColor Cyan
        if ($ScVersion -ne "2.37.0") {
            Write-Warning @"
Project targets SugarCube 2.37.0, but found $ScVersion.
  <<do>>/<<redo>> and other v2.37 features may not work at runtime.
  Replace $ScFormatJs with the 2.37.0 release from:
  https://github.com/tmedwards/sugarcube-2/releases/tag/v2.37.0
"@
        }
    }
} else {
    Write-Warning "Could not find SugarCube-2 format at: $ScFormatJs"
}

# ---- Build argument list ----------------------------------------------
$buildArgs = @(
    "-f", "sugarcube-2",
    "-t",
    "-l",
    "-o", $Output
)
if ($Watch) {
    $buildArgs += "-w"
    Write-Host "Watching src\ for changes (Ctrl+C to stop)..." -ForegroundColor Yellow
}
$buildArgs += $SrcDir

# ---- Run tweego -------------------------------------------------------
& $TweegoExe @buildArgs

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed (exit code $LASTEXITCODE)."
    exit $LASTEXITCODE
}

if (-not $Watch) {
    Write-Host ""
    Write-Host "Built: $Output" -ForegroundColor Green
    Write-Host "  Open it in a browser to play / inspect."
}
