param(
    [string]$AgentName = "demmo-agent"
)

$ErrorActionPreference = "Stop"

function Stage($Name) {
    Write-Host ""
    Write-Host "==> $Name" -ForegroundColor Cyan
}

$AGENT_HOME = Join-Path $env:LOCALAPPDATA $AgentName
$BIN_DIR = Join-Path $AGENT_HOME "bin"

Stage "1. Remove AGENT_HOME"
Set-Location $env:TEMP
if (Test-Path $AGENT_HOME) {
    Remove-Item -Recurse -Force $AGENT_HOME
    Write-Host "Removed $AGENT_HOME"
} else {
    Write-Host "$AGENT_HOME does not exist, skipping."
}

Stage "2. Remove BIN_DIR from PATH"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -like "*$BIN_DIR*") {
    $newPath = ($currentPath -split ";" | Where-Object { $_ -ne $BIN_DIR }) -join ";"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    $env:Path = ($env:Path -split ";" | Where-Object { $_ -ne $BIN_DIR }) -join ";"
    Write-Host "Removed $BIN_DIR from PATH."
} else {
    Write-Host "$BIN_DIR is not in PATH."
}

Write-Host ""
Write-Host "Uninstalled successfully." -ForegroundColor Green
