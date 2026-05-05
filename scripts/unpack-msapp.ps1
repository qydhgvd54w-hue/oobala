<#
.SYNOPSIS
    Unpacks a .msapp from archive\msapp-history into canvas-app\_staging_unpack for diffing.
.PARAMETER Msapp
    Filename (not full path) of the .msapp in archive\msapp-history.
.EXAMPLE
    .\scripts\unpack-msapp.ps1 -Msapp "dashboard_passG_2026-05-04.msapp"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Msapp
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot    = Split-Path -Parent $PSScriptRoot
$archiveDir  = Join-Path $repoRoot "archive\msapp-history"
$stagingDir  = Join-Path $repoRoot "canvas-app\_staging_unpack"
$msappPath   = Join-Path $archiveDir $Msapp

# Validate input
if (-not (Test-Path $msappPath)) {
    Write-Error "File not found in archive\msapp-history: $Msapp"
    Write-Host "Available builds:"
    Get-ChildItem $archiveDir -Filter "*.msapp" | Select-Object -ExpandProperty Name | ForEach-Object { Write-Host "  $_" }
    exit 1
}

# Validate pac CLI
if (-not (Get-Command pac -ErrorAction SilentlyContinue)) {
    Write-Error "pac CLI not found on PATH. Install: winget install Microsoft.PowerApps.CLI"
    exit 1
}

# Clear and recreate staging dir
if (Test-Path $stagingDir) {
    Write-Host "Clearing existing staging folder..."
    Remove-Item -Path $stagingDir -Recurse -Force
}
New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

# Unpack
Write-Host "Unpacking: $msappPath"
Write-Host "Into:      $stagingDir"
Write-Host ""
pac canvas unpack --msapp $msappPath --sources $stagingDir

if ($LASTEXITCODE -eq 0) {
    $fileCount = (Get-ChildItem $stagingDir -Recurse -File).Count
    Write-Host ""
    Write-Host "SUCCESS: $fileCount files unpacked to canvas-app\_staging_unpack\"
    Write-Host ""
    Write-Host "NOTE: _staging_unpack is gitignored — diff only, do not edit here."
    Write-Host "      Make changes in canvas-app\ADAMSCOSBY_CLEAN\ instead."
} else {
    Write-Error "FAILED: pac canvas unpack returned exit code $LASTEXITCODE"
    exit 1
}
