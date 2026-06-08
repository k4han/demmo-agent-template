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

Stage "1. Xóa AGENT_HOME"
if (Test-Path $AGENT_HOME) {
    Remove-Item -Recurse -Force $AGENT_HOME
    Write-Host "Đã xóa $AGENT_HOME"
} else {
    Write-Host "$AGENT_HOME không tồn tại, bỏ qua."
}

Stage "2. Xóa BIN_DIR khỏi PATH"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -like "*$BIN_DIR*") {
    $newPath = ($currentPath -split ";" | Where-Object { $_ -ne $BIN_DIR }) -join ";"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    $env:Path = ($env:Path -split ";" | Where-Object { $_ -ne $BIN_DIR }) -join ";"
    Write-Host "Đã xóa $BIN_DIR khỏi PATH."
} else {
    Write-Host "$BIN_DIR không có trong PATH."
}

Write-Host ""
Write-Host "Uninstalled successfully." -ForegroundColor Green
