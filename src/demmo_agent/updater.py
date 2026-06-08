from __future__ import annotations

import os
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path
from urllib.request import urlretrieve

from demmo_agent.config import DEFAULT_BRANCH, DEFAULT_OWNER, DEFAULT_REPO, get_agent_home, get_uv_path


def _run(args: list[str]) -> None:
    subprocess.run(args, check=True)


def update_app(
    owner: str = DEFAULT_OWNER,
    repo: str = DEFAULT_REPO,
    branch: str = DEFAULT_BRANCH,
) -> None:
    if owner.startswith("<") or repo.startswith("<"):
        raise RuntimeError(
            "Bạn cần cấu hình owner/repo thật trong demmo_agent/config.py "
            "hoặc truyền biến môi trường DEMMO_AGENT_OWNER và DEMMO_AGENT_REPO."
        )

    agent_home = get_agent_home()
    download_dir = agent_home / "download"
    source_dir = agent_home / "source"
    venv_dir = agent_home / ".venv"
    uv_path = get_uv_path()

    download_dir.mkdir(parents=True, exist_ok=True)
    source_dir.mkdir(parents=True, exist_ok=True)

    zip_path = download_dir / "source.zip"
    url = f"https://github.com/{owner}/{repo}/archive/refs/heads/{branch}.zip"

    print(f"Downloading source: {url}")
    urlretrieve(url, zip_path)

    temp_extract_dir = download_dir / "extract"
    if temp_extract_dir.exists():
        shutil.rmtree(temp_extract_dir)
    temp_extract_dir.mkdir(parents=True)

    with zipfile.ZipFile(zip_path, "r") as zip_file:
        zip_file.extractall(temp_extract_dir)

    extracted_roots = [p for p in temp_extract_dir.iterdir() if p.is_dir()]
    if not extracted_roots:
        raise RuntimeError("Không tìm thấy thư mục source sau khi giải nén.")

    if source_dir.exists():
        shutil.rmtree(source_dir)
    shutil.copytree(extracted_roots[0], source_dir)

    if not uv_path.exists():
        raise RuntimeError(f"Không tìm thấy uv riêng tại: {uv_path}")

    if not venv_dir.exists():
        print("Creating virtual environment...")
        _run([str(uv_path), "venv", str(venv_dir)])

    python_exe = venv_dir / ("Scripts/python.exe" if os.name == "nt" else "bin/python")
    print("Installing app with uv pip...")
    _run([str(uv_path), "pip", "install", "--python", str(python_exe), str(source_dir)])

    print("Update completed.")
