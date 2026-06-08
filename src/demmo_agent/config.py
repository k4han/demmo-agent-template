from __future__ import annotations

import os
from pathlib import Path


APP_NAME = "demmo-agent"
DEFAULT_OWNER = "<owner>"
DEFAULT_REPO = "<repo>"
DEFAULT_BRANCH = "main"


def get_agent_home() -> Path:
    local_app_data = os.getenv("LOCALAPPDATA")
    if local_app_data:
        return Path(local_app_data) / APP_NAME
    return Path.home() / f".{APP_NAME}"


def get_uv_path() -> Path:
    exe_name = "uv.exe" if os.name == "nt" else "uv"
    return get_agent_home() / "bin" / exe_name
