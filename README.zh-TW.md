# Open WebUI 繁體中文說明（臺灣）

> **這是翻譯。** 本文把上游儲存庫 [open-webui/open-webui](https://github.com/open-webui/open-webui) 的英文說明 [README.md](https://github.com/open-webui/open-webui/blob/main/README.md) 譯成繁體中文（臺灣，zh-TW），說明這個專案是什麼、功能放在哪裡看，以及如何安裝與使用。程式碼區塊、指令與連結維持原文。若譯文與原文不一致，以上游 [README.md](https://github.com/open-webui/open-webui/blob/main/README.md) 為準。
>
> 本檔是這個 fork 另外新增的，沒有改上游檔案。上游專案自己的繁體中文版是 [README.zht.md](https://github.com/open-webui/open-webui/blob/main/README.zht.md)。

<h2>Open WebUI</h2>

<p>Open WebUI 是 <a href="https://docs.openwebui.com/"><strong>AI 的家</strong></a>：一套可擴充、好上手、可以完全離線運作的自架平台。透過 Ollama 連接本機模型，或使用相容 OpenAI 的 API 連接本機與雲端模型。</p>

[English](README.md) |
[简体中文](README.zh.md) |
[繁體中文](README.zht.md) |
[한국어](README.ko.md) |
[Deutsch](README.de.md) |
[Español](README.es.md) |
[Français](README.fr.md) |
[Italiano](README.it.md) |
[Dansk](README.da.md) |
[日本語](README.ja.md) |
[Polski](README.pl.md) |
[Русский](README.ru.md) |
[Bosanski](README.bs.md) |
[العربية](README.ar.md) |
[Norsk](README.no.md) |
[Português (Brasil)](README.br.md) |
[ไทย](README.th.md) |
[Türkçe](README.tr.md) |
[Українська](README.uk.md) |
[বাংলা](README.bn.md) |
[Ελληνικά](README.gr.md) |
[Tiếng Việt](README.vi.md)

[![Open WebUI 示範](https://cdn.openwebui.com/open-webui-demo.gif)](https://docs.openwebui.com/)

![GitHub stars](https://img.shields.io/github/stars/open-webui/open-webui?style=social)
![GitHub forks](https://img.shields.io/github/forks/open-webui/open-webui?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/open-webui/open-webui?style=social)
![GitHub repo size](https://img.shields.io/github/repo-size/open-webui/open-webui)
![GitHub language count](https://img.shields.io/github/languages/count/open-webui/open-webui)
![GitHub top language](https://img.shields.io/github/languages/top/open-webui/open-webui)
![GitHub last commit](https://img.shields.io/github/last-commit/open-webui/open-webui?color=red)
[![Discord](https://img.shields.io/badge/Discord-Open_WebUI-blue?logo=discord&logoColor=white)](https://discord.gg/5rJgQTnV4s)
[![](https://img.shields.io/static/v1?label=Sponsor&message=Support&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/open-webui)

[進一步了解 Open WebUI →](https://docs.openwebui.com/)

### 安裝

#### Python

需要 Python 3.12。

```bash
pip install open-webui
open-webui serve
```

接著開啟 [http://localhost:8080](http://localhost:8080)。

#### Docker

```bash
docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
```

接著開啟 [http://localhost:3000](http://localhost:3000)。

| 映像檔標籤 | 內容 |
| --- | --- |
| `:main` | 標準映像檔，含本機 AI 的依賴套件 |
| `:slim` | 輕量映像檔；嵌入（embedding）、文件擷取與語音改由外部服務處理 |
| `:cuda` | 支援 CUDA 加速的 Open WebUI |
| `:ollama` | 內含 Ollama 的 Open WebUI |
| `:dev` | 最新開發版 |

視需要，在 `docker run` 的映像檔名稱前面加上這些選項：

| 選項 | 用途 |
| --- | --- |
| `-e OLLAMA_BASE_URL=http://your-ollama-server:11434` | 連到另一台伺服器上的 Ollama |
| `-e OPENAI_API_KEY=your_secret_key` | 設定 OpenAI API 金鑰 |
| `-e HF_HUB_OFFLINE=1` | 不要從 Hugging Face 下載模型，供離線使用 |
| `--gpus all` | 讓 `:cuda` 或 `:ollama` 使用 Nvidia GPU；須安裝 Nvidia Container Toolkit |

安裝步驟與設定項目請見 [Docker 安裝指南](https://docs.openwebui.com/getting-started/quick-start/)。

#### 桌面程式

[下載原生桌面程式](https://github.com/open-webui/desktop)，支援 macOS、Windows 與 Linux。

[閱讀說明文件 →](https://docs.openwebui.com/getting-started/)

### 生態系

- [Open Terminal](https://github.com/open-webui/open-terminal)／[Terminals（企業版）](https://github.com/open-webui/terminals)：動作層，把 Open WebUI 變成完整的代理執行環境（agent harness）；企業版負責編排，讓每位使用者有各自的工作區。
- [Knowledge Base Sync（oikb）](https://github.com/open-webui/oikb)：以增量同步，把資料夾、儲存庫、儲存桶與 wiki 鏡像進 Open WebUI 知識庫。
- [Open WebUI Computer](https://github.com/open-webui/computer)：在任何瀏覽器裡使用你的電腦：檔案、編輯器、終端機、Git，以及可選的 AI 代理，實際執行在你自己的機器上。

詳情請見[生態系說明](https://docs.openwebui.com/ecosystem/)。

### 疑難排解與更新

連線有問題時，請見[疑難排解指南](https://docs.openwebui.com/troubleshooting/)。要更新已安裝的版本，請見[更新指南](https://docs.openwebui.com/getting-started/updating)。

### 說明文件

設定與用法請見[說明文件](https://docs.openwebui.com/)，預定要做的項目請見[路線圖](https://docs.openwebui.com/roadmap/)。

Docker Compose、Kubernetes 與其他安裝方式，請見[安裝說明](https://docs.openwebui.com/getting-started/)。

### 支援

[開 issue](https://github.com/open-webui/open-webui/issues)，或到[討論區](https://github.com/open-webui/open-webui/discussions)發文。

也可以在 [Reddit](https://www.reddit.com/r/OpenWebUI/)、[X](https://x.com/OpenWebUI) 與 [Discord](https://discord.gg/5rJgQTnV4s) 找到我們。

### 安全性

請透過 [GitHub 安全性公告](https://github.com/open-webui/open-webui/security)私下回報漏洞。安全性回報只接受 GitHub 這一條管道。

### Star 數歷程

<a href="https://star-history.com/#open-webui/open-webui&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=open-webui/open-webui&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=open-webui/open-webui&type=Date" />
    <img alt="Star 數歷程圖" src="https://api.star-history.com/svg?repos=open-webui/open-webui&type=Date" />
  </picture>
</a>

#### 授權

包含以 Open WebUI License 授權的程式碼，該授權要求保留 Open WebUI 品牌；先前的貢獻則適用各自原本的授權。條款與沿革請見 [LICENSE](./LICENSE) 與 [LICENSE_HISTORY](./LICENSE_HISTORY)。

[企業方案](https://docs.openwebui.com/enterprise) · [徵才](https://careers.openwebui.com/) · [贊助](https://github.com/sponsors/open-webui)

由 [Timothy Jaeryang Baek](https://github.com/tjbck) 建立。
