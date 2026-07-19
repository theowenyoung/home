---
name: jj
description: Save the currently active browser page to the link collection at saved.owenyoung.com. Use when explicitly invoked as $jj, or when the user asks to bookmark or collect the current page there. Read the page without navigating, generate a concise Chinese title, SEO slug, and distinctive Markdown description, attach the complete article or main-page text in Markdown with Chinese translation when needed, match collections, create one authenticated link record, and return its clickable URL.
---

# Save the Current Page

Create exactly one link record for the page that is active when the user invokes `$jj`.

## Guardrails

- Treat an explicit `$jj` invocation as authorization to create one record for the current page. Do not ask for an additional confirmation.
- Read and follow the installed Browser skill before interacting with the browser. Connect to the existing/default browser and use its current active tab.
- Do not navigate, reload, refresh, submit forms on, or otherwise change the current page. Do not open API endpoints in a tab.
- Use JavaScript `fetch()` for every API request. Prefer Node-side `fetch()` in the same persistent JavaScript session used for browser control so cross-origin restrictions cannot affect the request.
- Never expose, print, return, save, or interpolate the API token into tool-call source. Refer to it only through an in-memory variable.
- Do not create a record if the current URL is not an absolute `http:`, `https:`, or `mailto:` URL. If its query or fragment appears to contain a credential, token, session ID, or password, stop and ask whether to save a sanitized URL.
- Do not automatically retry a POST whose result is ambiguous; it may already have created the record.

## Configuration

Use this non-secret base URL:

```text
https://saved.owenyoung.com
```

Load the token without displaying it, in this order:

1. Read `JJ_API_TOKEN` from the JavaScript runtime's process environment.
2. On macOS, if the environment variable is absent, read the Generic Password whose Keychain service name is `codex-jj-api-token` by calling `/usr/bin/security find-generic-password -s codex-jj-api-token -w` from the JavaScript runtime. Capture stdout directly into an in-memory variable and make the tool expression return only a boolean or a fixed success label.
3. If neither source exists, stop before any API call. Ask the user to configure the environment variable or add the token to macOS Keychain; do not ask them to paste the token into chat.

Keep the loaded token in a JavaScript variable such as `globalThis.jjApiToken`. Build the `Authorization` header from that variable. Never inspect browser cookies, browser storage, passwords, or session stores to find the token.

## Workflow

### 1. Read the current page

Use the selected browser's documented APIs to bind to the active existing tab. Record the full URL, document title, meta description, and the complete meaningful article or main-page content already present in the current DOM. Read content below the fold without navigating or refreshing. Ignore menus, cookie notices, repeated navigation, ads, comments, recommendations, and boilerplate.

Do not follow links or bypass a paywall, sign-in wall, or other access control. If the active tab cannot be read, the article is visibly truncated, or complete content cannot be recovered without navigation, report that and stop without creating a record. Do not silently attach a partial article as the full text.

### 2. Generate the fields

Read [content-rules.md](references/content-rules.md) completely. Generate:

- `title`: cleaned or translated according to the page type; at most 300 characters.
- `slug`: short, lowercase, SEO-friendly ASCII words separated by hyphens.
- `bodyMarkdown`: normally 1–3 Markdown list items containing only the page's most distinctive facts.

Base claims only on the current page. Do not invent capabilities, numbers, limitations, or comparisons.

### 3. Build the full-text attachment

Read [article-attachment.md](references/article-attachment.md) completely. Convert the complete article or cleaned main-page content to faithful Markdown, then apply its language rules:

- Keep Chinese content as displayed.
- Translate a predominantly English article completely into Simplified Chinese.
- Preserve an already translated Chinese view or a true bilingual view exactly as currently rendered; do not translate it again.

For long pages, extract and translate in ordered chunks at heading or block boundaries, then concatenate them. Verify that every substantive source block appears once in the final Markdown. Never replace a long section with a summary, placeholder, or ellipsis.

Create one text attachment:

```json
{
  "type": "text",
  "contentFormat": "markdown",
  "content": "<complete Markdown article or main-page text>",
  "summary": "网页全文（中文翻译）"
}
```

Set `summary` to one of `网页全文（中文翻译）`, `网页全文（中文原文）`, `网页全文（双语）`, or `网页主要内容`, matching the actual content. The API allows up to 20 attachments, requires non-empty text content, and limits an attachment summary to 300 characters. It documents no `content` length cap. Keep this as one attachment; if the API rejects its size, report the validation error instead of truncating or splitting it silently.

### 4. Fetch and match collections

Call:

```text
GET https://saved.owenyoung.com/api/collections
Authorization: Bearer <in-memory token>
```

Require a successful response before continuing. Read the response's `collections` array and semantically match the page using each collection's `title`, `description`, and `slug`. Select zero or more IDs, with a maximum of 20. Omit `collectionIds` when no collection is a good fit; never force a match.

Typical matches:

- Blog posts, essays, commentary, or analysis: `Articles`
- Interesting products or services: `Products`
- Inspiring portfolios or side projects: `Inspired Links`
- Inspiring personal blogs: `Sources`
- RSS, Bluesky, Mastodon, indie web, or related topics: `Open Web`

A page can belong to multiple collections, such as `Articles` and `Open Web`.

### 5. Create the link record

Construct the request body with no token. Include only the generated link fields, the concise description, collection matches, and the intentional full-text attachment:

```json
{
  "format": "link",
  "title": "生成的标题",
  "url": "当前页面的完整 URL",
  "slug": "generated-slug",
  "bodyMarkdown": "- 独特点一\n- 独特点二",
  "collectionIds": ["col_example"],
  "attachments": [
    {
      "type": "text",
      "contentFormat": "markdown",
      "content": "# 示例标题\n\n替换为完整的 Markdown 正文。",
      "summary": "网页全文（中文翻译）"
    }
  ]
}
```

Omit `collectionIds` if empty. Do not include both `bodyMarkdown` and `body`. Keep the concise description in `bodyMarkdown`; do not move it into the attachment. Rely on the service defaults of `status: "published"` and `visibility: "public"` unless the user explicitly requests different values.

When the elevated Node fallback is required, pass the non-secret JSON payload to the fixed Node process through stdin rather than shell interpolation or command-line arguments. Let that process read the token directly from Keychain and call `fetch()`. Do not write the token to stdin or to the payload.

Send exactly one request:

```text
POST https://saved.owenyoung.com/api/posts
Authorization: Bearer <in-memory token>
Content-Type: application/json
```

Treat only `201 Created` as success. Parse the returned post object and use its returned `slug`, not merely the requested slug.

If the server explicitly rejects the slug as already used before creating anything, generate one short disambiguated slug and retry once. Do not retry timeouts, connection drops, or other ambiguous POST failures.

### 6. Return the result

On success, return only the useful confirmation in this form:

```markdown
✅ 已收藏：[生成的标题](https://saved.owenyoung.com/returned-slug)
```

On failure, report the HTTP status and a concise sanitized error. Never include request headers, credentials, or an unsanitized response that might echo them.
