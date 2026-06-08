# demmo-agent-template

Ứng dụng Python CLI đơn giản:

```powershell
agent
agent update
agent --version
```

## Ghi chú quan trọng trên Windows

Không nên để `agent.ps1` gọi trực tiếp `.venv\Scripts\agent.exe`, vì khi chạy:

```powershell
agent update
```

Windows sẽ khóa chính file `agent.exe` đang chạy. Khi `uv pip install` cài lại package, nó cần xóa/ghi đè `agent.exe`, dẫn tới lỗi:

```text
failed to remove file ... Scripts/agent.exe: Access is denied. (os error 5)
```

Bản này sửa bằng cách để `agent.ps1` gọi:

```powershell
python.exe -m demmo_agent.cli
```

Như vậy `agent.exe` không bị process hiện tại khóa và update có thể ghi đè bình thường.

## Cài đặt

```powershell
.\install.ps1 -Owner "<owner>" -Repo "<repo>"
```

Sau khi cài, thêm thư mục này vào PATH:

```text
%LOCALAPPDATA%\demmo-agent\bin
```
