param(
    [string]$Owner = "k4han",
    [string]$Repo = "demmo-agent-template",
    [string]$Branch = "main",
    [string]$AgentName = "demmo-agent"
)

$ErrorActionPreference = "Stop"

function Stage($Name) {
    Write-Host ""
    Write-Host "==> $Name" -ForegroundColor Cyan
}

if ($Owner -eq "<owner>" -or $Repo -eq "<repo>") {
    throw "Vui lòng truyền Owner/Repo thật. Ví dụ: .\install.ps1 -Owner k4han -Repo demmo-agent-template"
}

$AGENT_HOME = Join-Path $env:LOCALAPPDATA $AgentName
$BIN_DIR = Join-Path $AGENT_HOME "bin"
$DOWNLOAD_DIR = Join-Path $AGENT_HOME "download"
$SOURCE_DIR = Join-Path $AGENT_HOME "source"
$VENV_DIR = Join-Path $AGENT_HOME ".venv"

$UV_EXE = Join-Path $BIN_DIR "uv.exe"
$SOURCE_ZIP = Join-Path $DOWNLOAD_DIR "source.zip"
$EXTRACT_DIR = Join-Path $DOWNLOAD_DIR "extract"
$AGENT_PS1 = Join-Path $BIN_DIR "agent.ps1"

Stage "1. Tạo AGENT_HOME"
New-Item -ItemType Directory -Force -Path $AGENT_HOME, $BIN_DIR, $DOWNLOAD_DIR | Out-Null
Write-Host "AGENT_HOME=$AGENT_HOME"

Stage "2. Cài uv riêng vào AGENT_HOME/bin"
if (-not (Test-Path $UV_EXE)) {
    $uvZip = Join-Path $DOWNLOAD_DIR "uv.zip"
    $uvExtract = Join-Path $DOWNLOAD_DIR "uv"

    if (Test-Path $uvExtract) {
        Remove-Item -Recurse -Force $uvExtract
    }

    $uvUrl = "https://github.com/astral-sh/uv/releases/latest/download/uv-x86_64-pc-windows-msvc.zip"
    Invoke-WebRequest -Uri $uvUrl -OutFile $uvZip

    New-Item -ItemType Directory -Force -Path $uvExtract | Out-Null
    Expand-Archive -Path $uvZip -DestinationPath $uvExtract -Force

    $foundUv = Get-ChildItem -Path $uvExtract -Filter "uv.exe" -Recurse | Select-Object -First 1
    if (-not $foundUv) {
        throw "Không tìm thấy uv.exe sau khi giải nén."
    }

    Copy-Item $foundUv.FullName $UV_EXE -Force
}
& $UV_EXE --version

Stage "3. Tải source main.zip"
$sourceUrl = "https://github.com/$Owner/$Repo/archive/refs/heads/$Branch.zip"
Write-Host "Downloading $sourceUrl"
Invoke-WebRequest -Uri $sourceUrl -OutFile $SOURCE_ZIP

Stage "4. Giải nén source vào AGENT_HOME/source"
if (Test-Path $EXTRACT_DIR) {
    Remove-Item -Recurse -Force $EXTRACT_DIR
}
New-Item -ItemType Directory -Force -Path $EXTRACT_DIR | Out-Null
Expand-Archive -Path $SOURCE_ZIP -DestinationPath $EXTRACT_DIR -Force

$root = Get-ChildItem -Path $EXTRACT_DIR -Directory | Select-Object -First 1
if (-not $root) {
    throw "Không tìm thấy thư mục source sau khi giải nén."
}

if (Test-Path $SOURCE_DIR) {
    Remove-Item -Recurse -Force $SOURCE_DIR
}
Copy-Item -Recurse -Force $root.FullName $SOURCE_DIR

Stage "5. Tạo venv và uv pip install source"
if (-not (Test-Path $VENV_DIR)) {
    & $UV_EXE venv $VENV_DIR
}

$PYTHON_EXE = Join-Path $VENV_DIR "Scripts\python.exe"
& $UV_EXE pip install --python $PYTHON_EXE --reinstall $SOURCE_DIR

Stage "6. Tạo agent.ps1"
@"
`$ErrorActionPreference = "Stop"

`$AGENT_HOME = Join-Path `$env:LOCALAPPDATA "$AgentName"
`$PYTHON_EXE = Join-Path `$AGENT_HOME ".venv\Scripts\python.exe"

if (-not (Test-Path `$PYTHON_EXE)) {
    throw "Không tìm thấy python.exe tại `$PYTHON_EXE. Hãy chạy lại install.ps1."
}

& `$PYTHON_EXE -m demmo_agent.cli @args
exit `$LASTEXITCODE
"@ | Set-Content -Path $AGENT_PS1 -Encoding UTF8

Stage "7. Thêm BIN_DIR vào PATH (user scope)"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$BIN_DIR*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$BIN_DIR", "User")
    $env:Path = "$env:Path;$BIN_DIR"
    Write-Host "Đã thêm $BIN_DIR vào PATH (user scope)."
} else {
    Write-Host "$BIN_DIR đã có trong PATH."
}

Write-Host ""
Write-Host "Installed successfully." -ForegroundColor Green
Write-Host "Mở terminal mới rồi chạy:"
Write-Host "  agent"
Write-Host "  agent update --owner $Owner --repo $Repo"
Write-Host "  agent --version"
