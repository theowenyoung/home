# Digital Home

我的 dotfiles 仓库。这个 Repo 就是我的 `$HOME` 目录，用 `.gitignore` 白名单模式管理，只跟踪需要的配置文件。

## 原则

- 所有 GUI 应用和命令行工具通过 [Homebrew](https://brew.sh/) 安装，统一在 `~/Brewfile` 中管理，使用 `brew bundle` 安装、`brew bundle --cleanup` 清理不在列表中的软件
- 所有开发语言运行时通过 [mise](https://mise.jdx.dev/) 管理，配置在 `~/.config/mise/config.toml`
  - npm 全局包：`~/.default-npm-packages`（mise 安装 node 时自动安装）
  - gems 全局包：`~/.default-gems`（mise 安装 ruby 时自动安装）
- 敏感信息（token、密钥）使用 macOS Keychain 管理，通过 `sec` 函数操作（定义在 bashrc 中）
- `.gitignore` 采用白名单模式：默认忽略所有文件，显式取消忽略需要跟踪的配置

## 目录结构

```
~/
├── Brewfile                    # Homebrew 软件清单
├── .default-npm-packages       # mise 安装 node 时自动安装的 npm 全局包
├── .default-gems               # mise 安装 ruby 时自动安装的 gems
├── .config/
│   ├── bash/                   # bash 配置、补全脚本
│   ├── git/                    # git 配置和全局 ignore
│   ├── ghostty/                # Ghostty 终端配置
│   ├── tmux/                   # tmux 配置
│   ├── nvim/                   # Neovim 配置（NvChad）
│   ├── mise/                   # mise 运行时版本配置
│   ├── alfred-workflows/       # Alfred 自定义工作流
│   ├── surfingkeys/            # SurfingKeys 浏览器插件配置
│   ├── caddy/                  # Caddy 反向代理配置
│   ├── ss/ sslocal/            # 代理相关配置
│   ├── clash/                  # Clash 代理配置
│   ├── systemd/                # systemd 用户服务
│   └── ...
├── deploy/                     # 服务器部署（Ansible、K3s、Helm）
└── .gnupg/gpg-agent.conf       # GPG agent 配置
```

## macOS 初始化

### 0. 系统偏好设置

1. 输入法设置为双拼，caps 切换中英输入法
2. Settings -> Keyboard：按键速度和延迟都调到最快
4. Settings -> Trackpad：启用 Tap to click
3. Settings -> Accessibility -> Pointer Control -> Trackpad Options > enable Use trackpad for draffing -> Dragging style -> 三指拖动（Three Finger Drag）
5. Settings -> Dock：自动隐藏 Dock 栏
6. 删除 Dock 里不需要的应用。

### 1. 安装 Xcode Command Line Tools

```bash
xcode-select --install
sudo xcodebuild -license   # 仅在装了完整 Xcode 时需要；只装 Command Line Tools 可跳过
```

### 2. 安装 Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

安装完成后，`brew` 还不在 PATH 里，需要先把它加载进当前 shell（之后 step 7 加载 bashrc 后会自动处理，这里只是为了让后续步骤能用）：

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

或直接关闭并重开终端。验证：

```bash
brew --version
```

### 3. SSH 密钥

SSH 私钥以文本形式存储在 macOS Passwords app 中（作为密码条目的值），通过 iCloud 在设备间同步。

**备份密钥到 Passwords app：**

```bash
# 复制私钥内容到剪贴板，然后在 Passwords app 中新建条目粘贴保存
cat ~/.ssh/id_ed25519 | pbcopy
```

**在新机器上恢复密钥：**

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh

# 在 Passwords app 中找到 SSH 条目，复制内容，然后粘贴写入文件
pbpaste > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519

# 从私钥生成对应的公钥
ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
```

### 4. 将 home repo 初始化到 $HOME

```bash
cd "$HOME"
rm -rf .git
git init -b main
git remote add origin git@github.com:theowenyoung/home.git
git fetch origin main
git reset --hard origin/main
git branch --set-upstream-to origin/main main
```

### 5. 安装 Bash / Ghostty / Chrome

提前装好后续要用到的几个基础软件：

- `bash`：后续 bashrc 依赖较新版本（macOS 自带的是 3.x）
- `ghostty`：日常用的终端（之后切到 Ghostty 里继续操作更顺）
- `google-chrome`：日常浏览器（登录账号 / 同步扩展用）

```bash
brew install bash mise
brew install --cask ghostty google-chrome
mise install
```

### 6. 切换默认 Shell 为 Homebrew Bash

> 装完 Ghostty 后，建议在 Ghostty 里继续后面的步骤，体验更好。

```bash
# 添加 homebrew bash 到合法 shell 列表
echo '/opt/homebrew/bin/bash' | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/bash
```

### 7. 加载自定义 bashrc

`~/.bash_profile` 与 `~/.bashrc` 都被 `.gitignore` 屏蔽，新机器需要手动建立两条最小引导：

- `~/.bashrc`：source 仓库里的共享配置（PATH、aliases、`sec` 函数、API token 导出等都在 `~/.config/bash/.bashrc` 里集中管理）
- `~/.bash_profile`：登录 shell 入口，source `~/.bashrc`（macOS 登录 shell 默认不会自动读 `.bashrc`）

```bash
# 1) ~/.bashrc 接入共享配置
if ! grep -q "# green-bashrc-start" ~/.bashrc 2>/dev/null; then
cat >>~/.bashrc <<'EOF'
# green-bashrc-start

if [ -f ~/.config/bash/.bashrc ]; then
  source ~/.config/bash/.bashrc
fi

# green-bashrc-end

# use pp or nopp to toggle

# proxy_start
#export HTTP_PROXY=http://127.0.0.1:7890
#export HTTPS_PROXY=http://127.0.0.1:7890
#export ALL_PROXY=socks5://127.0.0.1:7890
#export http_proxy=http://127.0.0.1:7890
#export https_proxy=http://127.0.0.1:7890
#export all_proxy=socks5://127.0.0.1:7890
#export NO_PROXY="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.local"
#export no_proxy="$NO_PROXY"
# proxy_end

EOF
fi

# 2) ~/.bash_profile source ~/.bashrc
if ! grep -q "source ~/.bashrc\|\. ~/.bashrc" ~/.bash_profile 2>/dev/null; then
cat >>~/.bash_profile <<'EOF'
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi
EOF
fi
```

```bash
source ~/.bash_profile
```

> 说明：`~/.bash_profile` 中其它工具自动写入的片段（iTerm2 shell integration、Windsurf PATH、`~/.local/bin/env`、Kiro CLI 等）会在对应工具安装/首次运行时自动追加，无需手工维护。API token 等敏感信息通过 `sec add <KEY> "<value>"` 写入 macOS Keychain（见后文「密钥管理」），共享 bashrc 会在启动时自动读取。
>
> 如果是从旧 Mac 迁移：在旧机 `sec export` 写入剪贴板，本机（已登录同一 iCloud，Universal Clipboard 自动同步）执行 `sec import` 即可一次性灌入全部 token，无需逐个 `sec add`。

### 8. 安装所有软件

home repo 已在 `$HOME`，直接用 Brewfile 安装其余软件：

```bash
cd ~ && brew bundle
```

### 9. GPG 密钥（可选）

如果需要保持同一个 GPG 签名身份，GPG 私钥同样以文本形式存储在 Passwords app 中。

> 私钥已经包含公钥，导入后 `gpg --list-keys` 自动可见，无需单独导出公钥。

**备份密钥到 Passwords app：**

```bash
# 账户 1: theowenyoung@gmail.com
gpg --armor --export-secret-keys 6453791878A4BC69317FEF9DA5142BBAFFEF7028 | pbcopy

# 账户 2: owen@owenyoung.com (Main)
gpg --armor --export-secret-keys B12C44A2E9386B993A8FFC53F822CE4444B1D606 | pbcopy
```

每条命令执行后，去 Passwords app 新建对应条目粘贴保存。

**在新机器上恢复密钥：**

```bash
# 依次从 Passwords app 复制每个条目的内容，然后执行：
pbpaste | gpg --import                  # 导入私钥（两个账户各执行一次）

gpg --list-secret-keys                  # 验证
```

### 10. Alfred 配置


1. 快捷键改为 `Cmd+Space`，移除默认 Spotlight 快捷键
2. 剪贴板管理快捷键：`Cmd+Cmd`（双击 Cmd）
3. 主题改为 Alfred macOS
4. Advanced sync 选择 icloud drive Documents/alfred-settings
5. 参考 [alfred-workflows](https://github.com/theowenyoung/home/tree/main/.config/alfred-workflows), 安装自己写的 alfred workflow


### 11. Bartender 配置

菜单栏整理工具（已通过 Brewfile 安装），首次启动需要做几件事：

1. 授予 **Accessibility** 权限（System Settings → Privacy & Security → Accessibility）
2. 授予 **Screen Recording** 权限（用于读取菜单栏图标）
3. 设置开机自启（Bartender → Settings → General → Launch at login）
4. 配置 iCloud 同步（Bartender → Settings → Profiles → 启用 iCloud sync），新机器会自动拉到同样的隐藏/显示规则

### 12. Cleanshot 配置

1. 根据提示配置系统快捷键
2. 打开截图后，自动复制到剪贴板和 Downloads 文件夹


### 其他没有在 brew 管理的软件

1. [Clash](https://github.com/MetaCubeX/ClashX.Meta/releases)
2. [闪电说](https://shandianshuo.cn/)

自定义词典：

```
mise
jant
Mise
小象
tumblr
通义千问
变体
最佳实践
Obsidian
网址
app store
apple store
windows
iOS
macOS
PWA
Chrome
Blog
APP
Touch grass
gemini
markdown
AI
LLM
ChatGPT
rss
Owen
Claude
prompt
Claude 4.6
wrangler
repo
Jant
CLAUDE.md
commands
command
AGENTS.md
sql
sqlite
build
```

## 日常使用

### 升级所有软件

```bash
brew upgrade
```

### mise 管理开发环境

安装/更新全局 node（`--force` 会重新安装 `.default-npm-packages` 中的所有包）：

```bash
mise u -g node@lts --force
```

安装 mise 配置中的所有运行时：

```bash
mise install
```

当前通过 mise 管理的运行时（见 `.config/mise/config.toml`）：
node, deno, bun, python, ruby, rust, go, zig, uv, redis, zola, awscli, neovim, ansible(pipx)

### AI Agent skills 管理

通过 [`npx skills`](https://github.com/vercel-labs/skills) 管理 Claude Code / Codex 等 agent 的 skills，全局清单保存在 `~/.agents/.skill-lock.json`（类似 Brewfile 的角色，已纳入 git）。

新机器一键还原:

```bash
mise run skills-restore
```

该 task 会读取 lock 文件，逐个执行 `npx skills add ... -g`，自动重建 `~/.agents/skills/` 目录和各 agent 目录下的符号链接（如 `~/.claude/skills/`）。

### 密钥管理

API token 等敏感信息不应该写死在 bashrc 。这里用 macOS Keychain 来存储（本地 login keychain，不走 iCloud Keychain 同步），通过定义在 bashrc 中的 `sec` 函数操作：

```bash
sec add GITHUB_TOKEN "ghp_xxx"    # 添加
sec get GITHUB_TOKEN              # 获取
sec rm GITHUB_TOKEN               # 删除
sec ls                            # 列出所有

# 配合 export 使用
export GITHUB_TOKEN=$(sec get GITHUB_TOKEN 2>/dev/null)
```

跨机器迁移：通过剪贴板（配合 macOS Universal Clipboard，可在登录同一 iCloud 的 Mac 之间无缝传输）：

```bash
sec export    # 在源机：把所有 secret/* 编码（base64）后写入剪贴板
sec import    # 在目标机：从剪贴板读入并校验 magic header，逐个写入 keychain
```

剪贴板里短暂存在 base64 编码的明文 token，不在同一 iCloud 时可手动粘到加密笔记中转。


## 常见的脚本记录（防止丢失）


### 1. miniflux rss 自定义 javascript 


超链接改成 新窗口打开，点击 标记 已读，不需要确认弹窗

```
document.addEventListener("DOMContentLoaded", () => {
  const MINIFLUX_API_TOKEN = "xxx";

  const DEBUG = false;
  const BYPASS_CACHE = false;

  function debug(...args) {
    if (DEBUG) console.log("[Miniflux Summary]", ...args);
  }

  const FEEDS = {
    direct: [
      "awealthofcommonsense.com",
      "www.macworld.com",
      "https://www.datagubbe.se",
      "https://boz.com",
      "iankduncan.com",
      "www.nplusonemag.com",
      "nplusonemag.com",
      "blog.michalprzadka.com",
      // "https://news.ycombinator.com",
      // "https://www.reddit.com",
    ],
  };

  const SUMMARY = {
    enabled: true,
    maxChars: 500,
    maxParagraphs: 6,
    chunkTargetChars: 260,
    concurrency: 3,
    cachePrefix: "miniflux_entry_summary:",
    cacheVersion: "v15-br-rendered-preview",
    cacheMaxItems: 300,
    placeholderText: "Loading summary…",
  };

  function normalizeUrl(url) {
    return String(url || "")
      .trim()
      .toLowerCase()
      .replace(/^https?:\/\//, "")
      .replace(/^www\./, "")
      .replace(/\/$/, "");
  }

  function matchFeed(feedUrl, prefixes) {
    const normalizedFeedUrl = normalizeUrl(feedUrl);

    return prefixes.some((prefix) => {
      const normalizedPrefix = normalizeUrl(prefix);

      return (
        normalizedFeedUrl === normalizedPrefix ||
        normalizedFeedUrl.startsWith(`${normalizedPrefix}/`)
      );
    });
  }

  function getHostnameFromUrlLike(urlLike) {
    if (!urlLike) return "";

    try {
      const value = String(urlLike).trim();
      const withProtocol = /^https?:\/\//i.test(value)
        ? value
        : `https://${value}`;

      const parsed = new URL(withProtocol, window.location.origin);

      return parsed.hostname.toLowerCase().replace(/^www\./, "");
    } catch (_) {
      return "";
    }
  }

  function isDifferentExternalDomain(feedUrl, originalUrl) {
    const feedHost = getHostnameFromUrlLike(feedUrl);
    const originalHost = getHostnameFromUrlLike(originalUrl);

    if (!feedHost || !originalHost) return false;

    return feedHost !== originalHost;
  }

  function injectSummaryStyles() {
    if (document.getElementById("custom-entry-summary-style")) return;

    const style = document.createElement("style");
    style.id = "custom-entry-summary-style";
    style.textContent = `
      .custom-entry-summary {
        margin-top: 0.45rem;
        margin-bottom: 0.25rem;
        font-size: 0.92rem;
        line-height: 1.5;
        opacity: 0.82;
        overflow-wrap: anywhere;
      }

      .custom-entry-summary.is-loading {
        opacity: 0.45;
        font-style: italic;
      }

      .custom-entry-summary.is-empty {
        display: none;
      }

      .custom-entry-summary.is-error {
        display: none;
      }

      .custom-timestamp-link {
        color: inherit;
        text-decoration: none;
      }

      .custom-timestamp-link:hover {
        text-decoration: underline;
      }
    `;
    document.head.appendChild(style);
  }

  function getEntryIDFromUrl(url) {
    try {
      const parsed = new URL(url, window.location.origin);
      const match = parsed.pathname.match(/\/(?:entry|entries)\/(\d+)/);
      return match ? match[1] : "";
    } catch (_) {
      return "";
    }
  }

  function getCacheKey(entryID) {
    return `${SUMMARY.cachePrefix}${SUMMARY.cacheVersion}:${entryID}`;
  }

  const memoryCache = new Map();

  function getCachedSummary(entryID) {
    if (BYPASS_CACHE) return null;

    if (memoryCache.has(entryID)) {
      return memoryCache.get(entryID);
    }

    try {
      const value = sessionStorage.getItem(getCacheKey(entryID));
      if (value != null) {
        memoryCache.set(entryID, value);
        return value;
      }
    } catch (_) {}

    return null;
  }

  function setCachedSummary(entryID, summary) {
    if (BYPASS_CACHE) return;

    memoryCache.set(entryID, summary);

    try {
      sessionStorage.setItem(getCacheKey(entryID), summary);
      trimSummaryCache();
    } catch (_) {}
  }

  function trimSummaryCache() {
    try {
      const keys = [];

      for (let i = 0; i < sessionStorage.length; i++) {
        const key = sessionStorage.key(i);
        if (key?.startsWith(SUMMARY.cachePrefix)) {
          keys.push(key);
        }
      }

      if (keys.length <= SUMMARY.cacheMaxItems) return;

      keys
        .slice(0, keys.length - SUMMARY.cacheMaxItems)
        .forEach((key) => sessionStorage.removeItem(key));
    } catch (_) {}
  }

  function htmlToTextWithBoundaries(html) {
    if (!html) return "";

    let prepared = html;

    prepared = prepared
      .replace(/<script\b[^>]*>[\s\S]*?<\/script>/gi, "")
      .replace(/<style\b[^>]*>[\s\S]*?<\/style>/gi, "")
      .replace(/<noscript\b[^>]*>[\s\S]*?<\/noscript>/gi, "")
      .replace(/<audio\b[^>]*>[\s\S]*?<\/audio>/gi, "")
      .replace(/<video\b[^>]*>[\s\S]*?<\/video>/gi, "")
      .replace(/<iframe\b[^>]*>[\s\S]*?<\/iframe>/gi, "")
      .replace(/<svg\b[^>]*>[\s\S]*?<\/svg>/gi, "")
      .replace(/<canvas\b[^>]*>[\s\S]*?<\/canvas>/gi, "")
      .replace(/<figure\b[^>]*>[\s\S]*?<\/figure>/gi, "")
      .replace(/<form\b[^>]*>[\s\S]*?<\/form>/gi, "")
      .replace(/<button\b[^>]*>[\s\S]*?<\/button>/gi, "");

    prepared = prepared
      .replace(/<img\b[^>]*>/gi, "")
      .replace(/<picture\b[^>]*>[\s\S]*?<\/picture>/gi, "")
      .replace(/<source\b[^>]*>/gi, "");

    prepared = prepared
      .replace(/<br\s*\/?>/gi, "\n")
      .replace(/<\/p\s*>/gi, "\n\n")
      .replace(/<p\b[^>]*>/gi, "")
      .replace(/<\/div\s*>/gi, "\n\n")
      .replace(/<div\b[^>]*>/gi, "")
      .replace(/<\/section\s*>/gi, "\n\n")
      .replace(/<section\b[^>]*>/gi, "")
      .replace(/<\/article\s*>/gi, "\n\n")
      .replace(/<article\b[^>]*>/gi, "")
      .replace(/<\/blockquote\s*>/gi, "\n\n")
      .replace(/<blockquote\b[^>]*>/gi, "")
      .replace(/<\/pre\s*>/gi, "\n\n")
      .replace(/<pre\b[^>]*>/gi, "")
      .replace(/<\/h[1-6]\s*>/gi, "\n\n")
      .replace(/<h[1-6]\b[^>]*>/gi, "")
      .replace(/<\/li\s*>/gi, "\n")
      .replace(/<li\b[^>]*>/gi, "• ")
      .replace(/<\/ul\s*>/gi, "\n\n")
      .replace(/<ul\b[^>]*>/gi, "\n")
      .replace(/<\/ol\s*>/gi, "\n\n")
      .replace(/<ol\b[^>]*>/gi, "\n")
      .replace(/<\/tr\s*>/gi, "\n")
      .replace(/<tr\b[^>]*>/gi, "")
      .replace(/<\/t[dh]\s*>/gi, " ")
      .replace(/<t[dh]\b[^>]*>/gi, "");

    const doc = new DOMParser().parseFromString(prepared, "text/html");
    const text = doc.body.textContent || "";

    return cleanPreviewText(text);
  }

  function normalizeText(text) {
    return String(text || "")
      .replace(/\u00a0/g, " ")
      .replace(/\r/g, "\n")
      .replace(/[ \t\f\v]+/g, " ")
      .replace(/[ \t]*\n[ \t]*/g, "\n")
      .replace(/\n{4,}/g, "\n\n\n")
      .trim();
  }

  function cleanPreviewText(text) {
    return normalizeText(text)
      .replace(/\bSpeed:\s*\(?\d+(\.\d+)?x\)?\b/gi, "")
      .replace(/\bShare this:\b/gi, "")
      .replace(/\bShare\b\s+(Facebook|Twitter|X|LinkedIn|Reddit|Email)\b/gi, "")
      .replace(/\bFiled under:.*$/gim, "")
      .replace(/\bTags?:.*$/gim, "")
      .replace(/\bCategories?:.*$/gim, "")
      .replace(/\bRead more\b/gi, "")
      .replace(/\bContinue reading\b/gi, "")
      .replace(/\bClick here to unsubscribe\b/gi, "")
      .replace(/\bView this email in your browser\b/gi, "")
      .replace(/([.!?])([A-Z])/g, "$1 $2")
      .replace(/([\u4e00-\u9fff])([A-Za-z0-9])/g, "$1 $2")
      .replace(/([A-Za-z0-9])([\u4e00-\u9fff])/g, "$1 $2")
      .replace(/[ \t]{2,}/g, " ")
      .replace(/\n{4,}/g, "\n\n\n")
      .trim();
  }

  function isBadParagraph(paragraph) {
    const text = cleanPreviewText(paragraph);
    const lower = text.toLowerCase();

    if (!text) return true;
    if (text.length < 12) return true;

    return (
      lower === "attachments" ||
      lower === "comments" ||
      lower === "read more" ||
      lower === "continue reading" ||
      lower === "advertisement" ||
      lower === "sponsored content" ||
      lower === "related posts" ||
      lower === "you may also like" ||
      lower === "subscribe" ||
      lower === "share this" ||
      lower === "listen to this article" ||
      lower === "audio player" ||
      lower === "video player" ||
      /^speed\s*:/i.test(text) ||
      /^\d+(\.\d+)?x$/.test(text) ||
      lower.includes("click here to unsubscribe") ||
      lower.includes("view this email in your browser") ||
      (lower.startsWith("the post ") && lower.includes(" appeared first on "))
    );
  }

  function splitIntoRealParagraphs(text) {
    return normalizeText(text)
      .split(/\n{2,}/)
      .map((paragraph) => cleanPreviewText(paragraph.replace(/\n/g, " ")))
      .filter((paragraph) => !isBadParagraph(paragraph));
  }

  function splitIntoSentences(text) {
    const clean = cleanPreviewText(text);
    if (!clean) return [];

    const sentences = clean
      .split(/(?<=[。！？])|(?<=[.!?])\s+/)
      .map((sentence) => cleanPreviewText(sentence))
      .filter(Boolean);

    return sentences.length > 0 ? sentences : [clean];
  }

  function splitLongTextIntoPreviewChunks(text) {
    const sentences = splitIntoSentences(text);
    const chunks = [];
    let current = "";

    for (const sentence of sentences) {
      const next = current ? `${current} ${sentence}` : sentence;

      if (next.length <= SUMMARY.chunkTargetChars || !current) {
        current = next;
      } else {
        chunks.push(current);
        current = sentence;
      }
    }

    if (current) chunks.push(current);

    return chunks;
  }

  function dedupeParagraphs(paragraphs) {
    const seen = new Set();
    const result = [];

    for (const paragraph of paragraphs) {
      const clean = cleanPreviewText(paragraph);
      const key = clean.toLowerCase().replace(/\s+/g, " ");

      if (!clean || seen.has(key)) continue;

      seen.add(key);
      result.push(clean);
    }

    return result;
  }

  function getPreviewParagraphs(text) {
    const realParagraphs = dedupeParagraphs(splitIntoRealParagraphs(text));
    const flattened = cleanPreviewText(realParagraphs.join(" "));

    debug("paragraph debug", {
      realParagraphsCount: realParagraphs.length,
      realParagraphsPreview: realParagraphs.slice(0, 8).map((p) => p.slice(0, 120)),
      flattenedLength: flattened.length,
      newlineCount: (text.match(/\n/g) || []).length,
      doubleNewlineCount: (text.match(/\n\n/g) || []).length,
    });

    if (
      realParagraphs.length < 3 &&
      flattened.length > SUMMARY.chunkTargetChars * 1.5
    ) {
      return dedupeParagraphs(splitLongTextIntoPreviewChunks(flattened));
    }

    return dedupeParagraphs(
      realParagraphs.flatMap((paragraph) => {
        const clean = cleanPreviewText(paragraph);

        if (clean.length > SUMMARY.chunkTargetChars * 1.4) {
          return splitLongTextIntoPreviewChunks(clean);
        }

        return [clean];
      })
    );
  }

  function trimAtSentence(text, maxChars) {
    const clean = cleanPreviewText(text);
    if (clean.length <= maxChars) return clean;

    const slice = clean.slice(0, maxChars + 1);

    const boundary = Math.max(
      slice.lastIndexOf("。"),
      slice.lastIndexOf("！"),
      slice.lastIndexOf("？"),
      slice.lastIndexOf(". "),
      slice.lastIndexOf("! "),
      slice.lastIndexOf("? "),
      slice.lastIndexOf("；"),
      slice.lastIndexOf("; "),
      slice.lastIndexOf("："),
      slice.lastIndexOf(": "),
      slice.lastIndexOf("，"),
      slice.lastIndexOf(", ")
    );

    if (boundary > maxChars * 0.45) {
      return slice.slice(0, boundary + 1).trim();
    }

    const lastSpace = slice.lastIndexOf(" ");
    if (lastSpace > maxChars * 0.55) {
      return slice.slice(0, lastSpace).trim() + "…";
    }

    return clean.slice(0, maxChars).trim() + "…";
  }

  function makePreview(text, maxChars) {
    const paragraphs = getPreviewParagraphs(text);

    const selected = [];
    let total = 0;

    for (const paragraph of paragraphs) {
      if (selected.length >= SUMMARY.maxParagraphs) break;

      const clean = cleanPreviewText(paragraph);
      if (!clean) continue;

      const nextTotal = total + clean.length + (selected.length ? 2 : 0);

      if (selected.length === 0) {
        const first = trimAtSentence(
          clean,
          Math.min(maxChars, SUMMARY.chunkTargetChars)
        );
        selected.push(first);
        total = first.length;
        continue;
      }

      if (nextTotal <= maxChars) {
        selected.push(clean);
        total = nextTotal;
        continue;
      }

      break;
    }

    return selected.join("\n\n").trim();
  }

  function extractPreviewFromEntryContent(contentHtml) {
    const text = htmlToTextWithBoundaries(contentHtml);

    debug("text after boundary parse", {
      textLength: text.length,
      newlineCount: (text.match(/\n/g) || []).length,
      doubleNewlineCount: (text.match(/\n\n/g) || []).length,
      preview: text.slice(0, 500),
    });

    return makePreview(text, SUMMARY.maxChars);
  }

  async function fetchEntrySummary(entryID) {
    const cached = getCachedSummary(entryID);
    if (cached != null) return cached;

    if (!MINIFLUX_API_TOKEN || MINIFLUX_API_TOKEN === "PASTE_YOUR_TOKEN_HERE") {
      throw new Error("Missing Miniflux API token");
    }

    const response = await fetch(`/v1/entries/${entryID}`, {
      method: "GET",
      credentials: "same-origin",
      headers: {
        "X-Auth-Token": MINIFLUX_API_TOKEN,
        Accept: "application/json",
      },
    });

    if (!response.ok) {
      throw new Error(`Failed to fetch entry via API: ${response.status}`);
    }

    const entry = await response.json();
    const contentHtml = entry.content || entry.summary || entry.description || "";
    const summary = extractPreviewFromEntryContent(contentHtml);

    setCachedSummary(entryID, summary);
    return summary;
  }

  const queue = [];
  let activeCount = 0;

  function enqueue(task) {
    queue.push(task);
    runQueue();
  }

  function runQueue() {
    while (activeCount < SUMMARY.concurrency && queue.length > 0) {
      const task = queue.shift();
      activeCount++;

      Promise.resolve()
        .then(task)
        .catch(() => {})
        .finally(() => {
          activeCount--;
          runQueue();
        });
    }
  }

  function createSummaryElement(item) {
    let summaryEl = item.querySelector(".custom-entry-summary");
    if (summaryEl) return summaryEl;

    summaryEl = document.createElement("div");
    summaryEl.className = "custom-entry-summary entry-content is-loading";
    summaryEl.textContent = SUMMARY.placeholderText;

    const title = item.querySelector("h2.item-title");
    const meta =
      item.querySelector(".item-meta") ||
      item.querySelector(".entry-meta") ||
      item.querySelector("footer");

    if (title) {
      title.insertAdjacentElement("afterend", summaryEl);
    } else if (meta) {
      meta.insertAdjacentElement("beforebegin", summaryEl);
    } else {
      item.appendChild(summaryEl);
    }

    return summaryEl;
  }

  function renderTextWithBreaks(container, text) {
    container.textContent = "";

    const paragraphs = String(text || "").split(/\n{2,}/);

    paragraphs.forEach((paragraph, index) => {
      if (index > 0) {
        container.appendChild(document.createElement("br"));
      }

      container.appendChild(document.createTextNode(paragraph));
    });
  }

  function renderSummary(summaryEl, summary) {
    if (summary) {
      renderTextWithBreaks(summaryEl, summary);
      summaryEl.classList.remove("is-loading", "is-empty", "is-error");
    } else {
      summaryEl.textContent = "";
      summaryEl.classList.remove("is-loading", "is-error");
      summaryEl.classList.add("is-empty");
    }
  }

  function renderSummaryError(summaryEl) {
    summaryEl.textContent = "";
    summaryEl.classList.remove("is-loading");
    summaryEl.classList.add("is-error");
  }

  function enhanceEntrySummary(item) {
    if (!SUMMARY.enabled) return;
    if (item.dataset.summaryEnhanced === "true") return;

    const titleLink = item.querySelector("h2.item-title > a");
    if (!titleLink) return;

    const entryID =
      titleLink.dataset.entryId ||
      getEntryIDFromUrl(titleLink.dataset.readerUrl || titleLink.href);

    if (!entryID) return;

    titleLink.dataset.entryId = entryID;
    item.dataset.summaryEnhanced = "true";

    const summaryEl = createSummaryElement(item);

    const cached = getCachedSummary(entryID);
    if (cached != null) {
      renderSummary(summaryEl, cached);
      return;
    }

    enqueue(async () => {
      try {
        const summary = await fetchEntrySummary(entryID);

        if (!summaryEl.isConnected) return;

        renderSummary(summaryEl, summary);
      } catch (_) {
        if (!summaryEl.isConnected) return;
        renderSummaryError(summaryEl);
      }
    });
  }

  function setupSummaryLoading() {
    if (!SUMMARY.enabled) return;

    injectSummaryStyles();

    const items = [...document.querySelectorAll("article.entry-item")];
    if (items.length === 0) return;

    items.forEach(enhanceEntrySummary);
  }

  function getFinalEntryLinkUrl(item) {
    const titleLink = item.querySelector("h2.item-title > a");
    const feedLink = item.querySelector('a[data-feed-link="true"]');
    const originalLink = item.querySelector('a[data-original-link="true"]');

    if (!titleLink) return "";

    if (!titleLink.dataset.readerUrl) {
      titleLink.dataset.readerUrl = titleLink.href;
    }

    const readerUrl = titleLink.dataset.readerUrl;
    const feedUrl = (feedLink?.title || feedLink?.textContent || "").trim();
    const originalUrl = originalLink?.href || "";

    const shouldOpenOriginal =
      feedLink &&
      originalLink &&
      originalUrl &&
      (
        matchFeed(feedUrl, FEEDS.direct) ||
        isDifferentExternalDomain(feedUrl, originalUrl)
      );

    if (shouldOpenOriginal) {
      return originalUrl;
    }

    return readerUrl;
  }

  function setupEntryLinks() {
    document.querySelectorAll("article.entry-item").forEach((item) => {
      const titleLink = item.querySelector("h2.item-title > a");
      if (!titleLink) return;

      if (!titleLink.dataset.readerUrl) {
        titleLink.dataset.readerUrl = titleLink.href;
      }

      const entryID = getEntryIDFromUrl(titleLink.dataset.readerUrl);
      if (entryID) {
        titleLink.dataset.entryId = entryID;
      }

      const finalUrl = getFinalEntryLinkUrl(item);
      if (finalUrl) {
        titleLink.href = finalUrl;
      }

      titleLink.target = "_blank";
      titleLink.rel = "noopener noreferrer";
    });
  }

  function setupTimestampLinks() {
    document.querySelectorAll("article.entry-item").forEach((item) => {
      const timeEl = item.querySelector(".item-meta-info-timestamp time");
      if (!timeEl) return;

      const finalUrl = getFinalEntryLinkUrl(item);
      if (!finalUrl) return;

      let link = timeEl.closest("a.custom-timestamp-link");

      if (!link) {
        link = document.createElement("a");
        link.className = "custom-timestamp-link";

        timeEl.parentNode.insertBefore(link, timeEl);
        link.appendChild(timeEl);
      }

      link.href = finalUrl;
      link.target = "_blank";
      link.rel = "noopener noreferrer";
    });
  }

  setupEntryLinks();
  setupTimestampLinks();
  setupSummaryLoading();

  document.addEventListener(
    "click",
    (event) => {
      const button = event.target.closest('button[data-action="markPageAsRead"]');
      if (!button) return;

      setTimeout(() => {
        const yesButton = [...document.querySelectorAll("button")].find(
          (btn) => btn.textContent.trim().toLowerCase() === "yes"
        );

        yesButton?.click();
      }, 100);
    },
    true
  );
});
```

## Linux 服务器初始化

适用于需要复用 bash 和 mise 配置的 Linux 服务器环境。

### 1. 创建用户并配置 SSH 登录

以 root 登录服务器后执行：

```bash
# 创建用户（无密码）并赋予免密 sudo 权限
useradd -m -s /bin/bash green
usermod -aG sudo,docker green
echo "green ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/green

# 将本地公钥写入 authorized_keys
mkdir -p /home/green/.ssh
# 把本地 ~/.ssh/id_ed25519.pub 的内容粘贴进去
vi /home/green/.ssh/authorized_keys
chmod 700 /home/green/.ssh
chmod 600 /home/green/.ssh/authorized_keys
chown -R green:green /home/green/.ssh

# 为 green 用户生成 SSH 密钥（用于 GitHub clone）
su - green -c 'ssh-keygen -t ed25519 -C "green@$(hostname)" -N ""'
# 查看公钥，添加到 https://github.com/settings/ssh/new
cat /home/green/.ssh/id_ed25519.pub
```

之后即可从本地免密登录：`ssh green@<server-ip>`

### 2. 初始化 home repo

```bash
# 将 repo 初始化到 $HOME
cd "$HOME"
rm -rf .git
git init -b main
git remote add origin git@github.com:theowenyoung/home.git
git fetch origin main
git reset --hard origin/main
git branch --set-upstream-to origin/main main
```

### 3. 安装系统依赖和 mise

```bash
sudo apt install -y tmux
curl https://mise.run | sh
```

### 4. 加载自定义 bashrc

```bash
if ! grep -q "# green-bashrc-start" ~/.bashrc; then
cat >>~/.bashrc <<EOF
# green-bashrc-start

if [ -f ~/.config/bash/.bashrc ]; then
    source ~/.config/bash/.bashrc
fi

# green-bashrc-end
EOF
fi
```

```bash
source ~/.bashrc
```

### 5. 安装开发运行时

```bash
mise install
```

## 部署

服务器部署和基础设施即代码在单独的仓库管理：[theowenyoung/studio-example](https://github.com/theowenyoung/studio-example)


## 迁移

旧机器在弃用 / 抹除前要做的清单：

1. 最好保留旧的 Mac，这样可以同步复制粘贴（依赖 iCloud Universal Clipboard）。
2. 迁移 `~/.ssh/`：直接复制粘贴。
3. 迁移 keychain 中的 API token：在旧机执行 `sec export`（写入剪贴板），新机 `sec import` 一次性灌入。详见「密钥管理」。
4. 复制 Chrome 插件的本地设置（账号同步不会带过来的部分），常见的：
   - **Claude**：扩展里的快捷键设置（chrome://extensions/shortcuts）
   - 其他扩展中靠本地存储而非账号同步的偏好（如自定义快捷键、白名单域名等）
