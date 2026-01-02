# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains custom Alfred workflows for macOS. The main workflow is "all-in-one" which provides translation, time conversion, and text utilities.

## Development Commands

### Run tests
```bash
node --test ~/.config/alfred-workflows/all-in-one/translate.test.mjs
node --test ~/.config/alfred-workflows/all-in-one/time.test.mjs
```

### Install workflow
```bash
cd ~/.config/alfred-workflows/all-in-one
./install.sh
```

The install script creates a symlink from this source directory to Alfred's workflow directory (`~/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows/`).

## Architecture

### Workflow Structure

The "all-in-one" workflow consists of several Node.js scripts that output Alfred Script Filter JSON:

- **translate.mjs** - Translation with streaming OpenAI API and word lookup via iCIBA dictionary. Auto-detects language direction based on ASCII ratio. For single English words, fetches dictionary definitions and plays pronunciation audio.
- **time.mjs** - Timestamp/date conversion showing Beijing time, local time, UTC, and Unix timestamp
- **length.mjs** - Character count utility
- **json2string.mjs** / **string2json.mjs** - JSON escape/unescape utilities
- **play.mjs** - Audio playback helper (downloads MP3 and plays via `afplay`)

### Key Patterns

1. **Alfred Script Filter Output**: All scripts output JSON in Alfred's Script Filter format with `items` array or Text View format with `response` field
2. **Streaming Translation**: Uses `rerun` feature with state files in `alfred_workflow_cache` directory for OpenAI streaming responses
3. **Node.js Path Detection**: Scripts detect Node.js from common paths (`~/.nix-profile/bin/node`, `/usr/local/bin/node`, etc.)

### Environment Variables

Used by translate.mjs:
- `OPENAI_API_KEY` - OpenAI API key
- `OPENAI_API_ENDPOINT` - Custom API endpoint (default: immersivetranslate proxy)
- `OPENAI_MODEL` - Model to use (default: gpt-4o-mini)
- `DEEPL_AUTH_KEY` - DeepL API key (currently disabled)
- `alfred_workflow_cache` - Alfred-provided cache directory
