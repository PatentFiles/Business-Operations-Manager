# BOM Windows Host Readiness (read-only)
# This script checks the Windows host only. WSL2/Ubuntu has a separate Node/pnpm
# installation that must also meet the requirements in docs/bom/WINDOWS_BASELINE_TEST.md.
# No installer, network call, registry change, service start, secret read or file write.
[CmdletBinding()]
param(
    [string]$RepositoryPath = '.'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ToolVersion {
    param([string]$Name)
    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        return [pscustomobject]@{ Available = $false; Version = 'not found' }
    }

    try {
        $lines = @(& $command.Source --version 2>&1)
        $first = ($lines | Select-Object -First 1 | Out-String).Trim()
        if ([string]::IsNullOrWhiteSpace($first)) { $first = 'not reported' }
        return [pscustomobject]@{ Available = $true; Version = $first }
    }
    catch {
        return [pscustomobject]@{ Available = $true; Version = 'could not read version' }
    }
}

function Test-MinimumSemVer {
    param([string]$Actual, [int]$Major, [int]$Minor, [int]$Patch)
    if ($Actual -notmatch 'v?(\d+)\.(\d+)\.(\d+)') { return $false }
    $parts = @([int]$Matches[1], [int]$Matches[2], [int]$Matches[3])
    $minimum = @($Major, $Minor, $Patch)
    for ($i = 0; $i -lt 3; $i++) {
        if ($parts[$i] -gt $minimum[$i]) { return $true }
        if ($parts[$i] -lt $minimum[$i]) { return $false }
    }
    return $true
}

Write-Host ''
Write-Host 'BUSINESS OPERATIONS MANAGER | Windows host readiness (read-only)'
Write-Host '----------------------------------------------------------------'
$node = Get-ToolVersion -Name 'node'
$npm = Get-ToolVersion -Name 'npm'
$pnpm = Get-ToolVersion -Name 'pnpm'
$git = Get-ToolVersion -Name 'git'

Write-Host ('Node.js : ' + $node.Version)
Write-Host ('npm     : ' + $npm.Version)
Write-Host ('pnpm    : ' + $pnpm.Version)
Write-Host ('Git     : ' + $git.Version)

if (-not (Test-MinimumSemVer -Actual $node.Version -Major 24 -Minor 11 -Patch 0)) {
    Write-Warning 'This Windows Node version is below the BOM requirement (24.11.0+).'
}
if (-not $pnpm.Available -or $pnpm.Version -notmatch '(^|[^0-9])9\.15\.4([^0-9]|$)') {
    Write-Warning 'BOM repository pins pnpm 9.15.4. Check the actual version inside Ubuntu too.'
}
if (-not $git.Available) {
    Write-Warning 'Git was not found on the Windows PATH.'
}

$wsl = Get-Command 'wsl.exe' -ErrorAction SilentlyContinue
if ($null -eq $wsl) {
    Write-Warning 'WSL2 was not found. See Microsoft WSL installation instructions.'
}
else {
    Write-Host 'WSL     : wsl.exe found (Ubuntu distribution/version not verified)'
    Write-Host '          Run "wsl --list --verbose" to check the installed distributions.'
}

try {
    $root = (Resolve-Path -LiteralPath $RepositoryPath -ErrorAction Stop).Path
    if ((Test-Path -LiteralPath (Join-Path $root '.git')) -and $git.Available) {
        $head = (& git -C $root rev-parse --short HEAD 2>$null | Out-String).Trim()
        if ($LASTEXITCODE -eq 0 -and $head) {
            Write-Host ('Checkout: ' + $root)
            Write-Host ('Commit  : ' + $head)
        }
    }
}
catch {
    Write-Host 'Local checkout not detected; no repository was modified.'
}

Write-Host ''
Write-Host 'IMPORTANT: Use the Ubuntu/WSL2 terminal for the actual BOM Node/pnpm checks.'
Write-Host 'Setup guide: docs/bom/WINDOWS_BASELINE_TEST.md'
Write-Host 'No changes were made by this script.'
