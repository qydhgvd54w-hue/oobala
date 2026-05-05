<#
.SYNOPSIS
    Packs canvas-app\ADAMSCOSBY_CLEAN into archive\msapp-history\dashboard_{Label}_{date}.msapp
.PARAMETER Label
    Build label appended to the output filename. Defaults to "dev".
.EXAMPLE
    .\scripts\pack-msapp.ps1 -Label "passH"
#>
param(
    [string]$Label = "dev"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot    = Split-Path -Parent $PSScriptRoot
$sourceDir   = Join-Path $repoRoot "canvas-app\ADAMSCOSBY_CLEAN"
$archiveDir  = Join-Path $repoRoot "archive\msapp-history"
$dateStamp   = Get-Date -Format "yyyy-MM-dd"
$outputFile  = Join-Path $archiveDir "dashboard_${Label}_${dateStamp}.msapp"

# Validate source
if (-not (Test-Path $sourceDir)) {
    Write-Error "Source not found: $sourceDir"
    exit 1
}
if (-not (Test-Path (Join-Path $sourceDir "Src\App.fx.yaml"))) {
    Write-Error "Source integrity check failed: Src\App.fx.yaml missing from $sourceDir"
    exit 1
}

# Validate pac CLI
if (-not (Get-Command pac -ErrorAction SilentlyContinue)) {
    Write-Error "pac CLI not found on PATH. Install: winget install Microsoft.PowerApps.CLI"
    exit 1
}

# Ensure archive dir exists
New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null

# Pack
Write-Host "Packing: $sourceDir"
Write-Host "Output:  $outputFile"
pac canvas pack --msapp $outputFile --sources $sourceDir

if ($LASTEXITCODE -eq 0 -and (Test-Path $outputFile)) {
    $size = (Get-Item $outputFile).Length
    $sizeKB = [math]::Round($size / 1KB, 1)
    Write-Host ""
    Write-Host "SUCCESS: $outputFile ($sizeKB KB)"
} else {
    Write-Error "FAILED: pac canvas pack returned exit code $LASTEXITCODE"
    exit 1
}
