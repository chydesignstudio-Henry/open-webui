# Open WebUI（繁體中文說明｜Fork）

> 本儲存庫 fork 自上游 **[open-webui/open-webui](https://github.com/open-webui/open-webui)**。原英文說明保留在 [README.en.md](README.en.md)。

## 這是什麼
Open WebUI 是可以自架的 AI 聊天介面，支援 Ollama 和 OpenAI 相容 API，並提供 **Knowledge（文件 RAG）**、工具、記憶、多使用者等功能。

## 與個人 multi-AI 知識庫（ai-kb）的關係
Open WebUI 是 ai-kb 的**日常使用介面**。ai-kb 的 `export_md.py` 把整理過的條目輸出成 Markdown，再由 `load_kb.py` 透過 API 建立 Knowledge collections：

| Knowledge | 條目數 |
|---|---|
| AI-KB grok | 45 |
| AI-KB claude | 46 |
| AI-KB notebooklm | 21 |
| AI-KB gemini | 53 |

在對話中輸入 `#` 就能引用 collection。原始對話串的封存與語意瀏覽交給 [ThreadShelf fork](https://github.com/chydesignstudio-Henry/ThreadShelf)。

## 本機執行（不使用 Docker，pip 或 uv）
```bash
uv venv .venv --python 3.11 && uv pip install --python .venv open-webui
export DATA_DIR=$PWD/data WEBUI_AUTH=False ENABLE_OLLAMA_API=False \
  RAG_EMBEDDING_MODEL=sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2
.venv/bin/open-webui serve --host 127.0.0.1 --port 8080
```
開啟 http://127.0.0.1:8080。`WEBUI_AUTH=False` 是單人免登入模式，請只在本機使用。

- 第一次啟動會下載 embedding 模型。下載完成後可以設 `HF_HUB_OFFLINE=1`，加快啟動並避免卡在下載。
- 健康檢查：`curl http://127.0.0.1:8080/health`
- 接模型：到「設定 → 連線」填入 OpenAI 相容 API 的 URL 和 Key。

使用 Docker：
```bash
docker run -d -p 3000:8080 -v open-webui:/app/backend/data --name open-webui ghcr.io/open-webui/open-webui:main
```

## 授權
依上游 [LICENSE](LICENSE)。
