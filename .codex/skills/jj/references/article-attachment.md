# Full-Text Attachment Rules

## Extraction scope

Create a faithful Markdown copy of the current page's complete primary content.

- For an article, essay, documentation page, or blog post, include the title once, byline and publication date when present, every substantive section, footnotes, blockquotes, tables, lists, code blocks, and meaningful captions.
- For a product, tool, or other non-article page, include the cleaned main-page content in reading order.
- Prefer the current rendered DOM over metadata such as the original `<html lang>` value. A translation extension may have changed or augmented the visible article.
- Include content already loaded below the fold. Exclude site navigation, cookie prompts, ads, unrelated sidebars, comments, related-content cards, subscription prompts, and repeated footer text.
- Do not follow pagination, open links, expand interactive controls, bypass access controls, or fetch a hidden source version.
- Preserve meaningful links as Markdown links with absolute URLs. Preserve informative image alt text and captions; omit decorative images. Do not upload or archive image binaries unless the user asks separately.

If the content is visibly incomplete, stop before creating the post and say why. Do not label a partial extraction as full text.

## Markdown conversion

Preserve the source hierarchy and reading order:

- Use headings at matching levels and avoid duplicating the title.
- Preserve paragraphs, emphasis, links, ordered and unordered lists, tables, blockquotes, footnotes, and fenced code blocks.
- Keep code, commands, identifiers, filenames, URLs, and mathematical expressions unchanged.
- Remove layout-only duplication and normalize excessive blank lines.
- Do not add commentary, a translator's note, a new conclusion, or claims absent from the page.

## Language decision

Judge the extracted primary content, not merely the page language metadata.

### Chinese or already translated Chinese

Keep the current rendered content unchanged when substantive prose is already Chinese. This includes a page whose original language metadata is English but whose visible article has been translated into Chinese. Do not translate it again.

### English

Translate every substantive English block into natural Simplified Chinese while preserving the Markdown structure. Preserve proper nouns, product names, code, URLs, numbers, units, citations, and factual precision. Translate headings, paragraphs, captions, blockquotes, table prose, and footnotes. Do not summarize, compress, combine, omit, or embellish sections.

### Already bilingual

Treat the page as bilingual only when substantial corresponding passages appear in both Chinese and another language, often in alternating blocks or parallel columns, or when the rendered page clearly labels original and translated passages. Incidental English terms, code, navigation, or quotations do not make a Chinese article bilingual.

For a true bilingual page, preserve the currently rendered bilingual content and its ordering exactly. Do not translate the non-Chinese half again and do not remove either language.

For a predominantly non-Chinese, non-English page, preserve the current rendered text unless the user explicitly asks for translation.

## Completeness check

Before POSTing:

1. Compare the source and output section sequence.
2. Confirm every substantive heading, paragraph, list, table, blockquote, code block, caption, and footnote appears exactly once.
3. Confirm no output section contains a placeholder such as `…`, `略`, `其余内容`, or “same as above.”
4. Confirm the attachment is non-empty Markdown and the selected attachment summary matches its language state.

For a long page, process ordered chunks at block boundaries and concatenate them without reordering. If tool output or context limits prevent a complete result, stop and report the limitation rather than posting a truncated attachment.
