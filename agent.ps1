$ErrorActionPreference = "Stop"

$AGENT_HOME = Join-Path $env:LOCALAPPDATA "demmo-agent"
$PYTHON_EXE = Join-Path $AGENT_HOME ".venv\Scripts\python.exe"

if (-not (Test-Path $PYTHON_EXE)) {
    throw "Không tìm thấy python.exe tại $PYTHON_EXE. Hãy chạy install.ps1 trước."
}

# Không gọi .venv\Scripts\agent.exe ở đây.
# Nếu gọi agent.exe rồi chạy `agent update`, Windows sẽ khóa agent.exe và uv không thể ghi đè nó.
& $PYTHON_EXE -m demmo_agent.cli @args
exit $LASTEXITCODE
