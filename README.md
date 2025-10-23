# Raygent Skills

Ray's Skills for AI Agents, starting with Claude Skills.

## Skills

### OpenRouter

Use OpenRouter's unified API to call different LLM models with cost and performance tracking.

**Features**:
- Call any model available on OpenRouter (Claude, GPT, Gemini, Llama, etc.)
- Track response time and cost per request
- Compare models for quality, speed, and cost
- Use modifiers like `:nitro` (fastest) and `:online` (web search)

**Installation**: See [Installation](#installation) below.

## Installation

### Via Claude Code Plugin System

1. Add this repository as a plugin marketplace (feature coming soon)
2. Install the `raygent-skills` plugin

### Manual Installation

1. Download `openrouter.zip`
2. Unzip to your Claude skills directory:
   ```bash
   unzip openrouter.zip -d ~/.claude/skills/
   ```

## Development

### Requirements

- Python 3
- [skill-creator](https://github.com/anthropics/skills) plugin installed
- `jq` (for bash scripts)

### Auto-Packaging

This repository uses a pre-commit hook to automatically package skills when committing. This ensures `.zip` files are always up-to-date with source changes.

**How it works**:
1. When you run `git commit`, the hook automatically runs
2. All skills (directories with `SKILL.md`) are packaged
3. Updated `.zip` files are staged and included in the commit
4. If packaging fails, the commit is aborted

**Manual packaging**:
```bash
# Package all skills
bash scripts/package_all_skills.sh

# Package a specific skill
python3 ~/.claude/plugins/marketplaces/anthropic-agent-skills/skill-creator/scripts/package_skill.py ./openrouter .
```

### Adding New Skills

1. Create a new skill directory with `SKILL.md`
2. Update `.claude-plugin/marketplace.json` to include the new skill
3. Commit your changes - the skill will be auto-packaged

### Security

**Important**: Never commit API keys or secrets!

- `.env` files are gitignored
- API keys should be set as environment variables
- Check `.gitignore` before committing sensitive files

## Contributing

Contributions welcome! Please ensure:
1. Skills follow the [Anthropic skill guidelines](https://github.com/anthropics/skills)
2. Skills pass validation (`package_skill.py` validates automatically)
3. Documentation is clear and includes examples

## License

MIT

## Author

Raymond Weitekamp ([@raygent](https://github.com/raygent))
