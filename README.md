# demmo-agent

Ứng dụng Python CLI đơn giản:

```powershell
agent
agent update
agent --version
```

- `agent`: chạy FastAPI app bằng uvicorn.
- `agent update`: tải source mới nhất từ GitHub main branch và cài lại bằng uv riêng trong `AGENT_HOME`.
- `agent --version`: xem phiên bản package.

## Cấu trúc cài đặt Windows

Mặc định:

```text
%LOCALAPPDATA%\demmo-agent
├── bin
│   ├── uv.exe
│   └── agent.ps1
├── download
│   └── source.zip
├── source
│   └── ...
└── .venv
    └── Scripts
        └── agent.exe
```

## Cài đặt

Sửa `Owner` và `Repo` hoặc truyền tham số:

```powershell
.\install.ps1 -Owner "<owner>" -Repo "<repo>"
```

Thêm thư mục sau vào PATH để gọi trực tiếp `agent` từ terminal mới:

```text
%LOCALAPPDATA%\demmo-agent\bin
```
