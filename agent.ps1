$ErrorActionPreference = "Stop"

$AGENT_HOME = Join-Path $env:LOCALAPPDATA "demmo-agent"
$AGENT_EXE = Join-Path $AGENT_HOME ".venv\Scripts\agent.exe"

if (-not (Test-Path $AGENT_EXE)) {
    throw "Không tìm thấy agent.exe tại $AGENT_EXE. Hãy chạy install.ps1 trước."
}

& $AGENT_EXE @args
exit $LASTEXITCODE
