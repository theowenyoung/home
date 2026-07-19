# Content Generation Rules

## Title

Clean every title:

- Remove site suffixes such as `- Medium`, `| GitHub`, `— Substack`, and `- YouTube`.
- Remove marketing modifiers and hype.

Then handle the content type:

- Product, tool, service, or library: keep the product name and add one very short Chinese differentiator after an ASCII colon. Examples: `Kosmi: 在线一起看视频`, `Linear: 键盘驱动的项目管理`, `tRPC: 全栈 TypeScript 零 API 定义`, `Valibot: 模块化的 schema 验证`.
- English descriptive article, opinion, or tutorial title: translate naturally and concisely into Chinese. Example: `How React Server Components Work` becomes `React Server Components 的工作原理`.
- Chinese title: preserve the original wording after cleanup.
- Mixed title with proper nouns: translate the sentence structure but preserve proper nouns. Example: `Why SQLite Does Not Use Git` becomes `为什么 SQLite 不用 Git`.

Do not creatively rename an article. Translation is a faithful restatement. For product pages, the phrase after the colon is a compact extraction of the clearest differentiator, not a feature list.

## Slug

- For an English source title, lowercase it, replace spaces with hyphens, remove punctuation, and drop filler words such as `a`, `an`, `the`, and `of` unless needed for clarity.
- For a Chinese source title, translate its core idea into short English keywords and convert those to a slug.
- Preserve recognizable product and technology names.
- Keep the slug short and readable. Use only lowercase ASCII letters, digits, and hyphens; collapse repeated hyphens and trim leading or trailing hyphens.

Examples:

- `How React Server Components Work` → `how-react-server-components-work`
- `深入理解 Git Rebase` → `git-rebase-in-depth`
- `Linear: 键盘驱动的项目管理` → `linear`

## Description

Write only the one or two facts that make this page or product memorable among close alternatives. Use concise Markdown outline bullets, one fact per line. Add an indented sub-bullet only when a concrete detail is needed. Usually use 1–3 top-level bullets.

Prefer:

- A concrete architectural choice or unusual constraint
- A number, limit, or measurable comparison stated by the page
- A counterintuitive tradeoff
- The specific mechanism behind a claimed advantage

Exclude:

- Category definitions already conveyed by the title or collection
- Generic pain-point setup
- Significance summaries such as “这意味着”
- Recommendations, hype, or words such as “神器”, “宝藏”, or “颠覆”
- Empty phrases such as “文章探讨了” or “研究表明”
- Broad feature lists that bury the differentiator
- Unsupported comparisons or inferences

Self-check every bullet:

1. Could this sentence describe most competing products or similar articles? If yes, remove or sharpen it.
2. Will this sentence make the item recognizable six months later? If no, prefer a more specific fact.

Good examples:

```markdown
- 整个 UI 围绕键盘快捷键设计，操作手感接近代码编辑器
- 固定 workflow，不提供自定义字段和流程配置
```

```markdown
- 核心发现：模型参数量和训练 token 数应该等比扩大，之前的大模型普遍训练数据不足
  - Chinchilla 用 GPT-3 四成的参数（700 亿 vs 1750 亿），靠 4.7 倍的数据量反超
```

```markdown
- 和 Zod 同样的 schema 验证 API，但模块化设计，按函数引入
- bundle size 随用量线性增长，而不是一次性引入整个库
```

```markdown
- SQLite 用自己写的版本控制 Fossil，核心原因是需要可复现的 build——同一份源码在任何时间构建出 bit-identical 的二进制
- Git 做不到这一点，因为 checkout 时间戳不确定，而 SQLite 的构建产物会进入其他项目的版本控制
```
