# Raygent Skills Marketplace

A plugin marketplace (index) for Claude Code, pointing to Ray's AI agent skills.

## Available Plugins

| Plugin | Description | Repo |
|--------|-------------|------|
| **openrouter** | OpenRouter unified API for LLM models | [this repo](./openrouter) |
| **ralph-eats-beads** | Autonomous AI coding loop with bd | [rawwerks/ralph-eats-beads](https://github.com/rawwerks/ralph-eats-beads) |

## Installation

### Add the marketplace

```
/plugin marketplace add rawwerks/raygent-skills
```

### Install plugins

```
/plugin install openrouter@raygent-skills
/plugin install ralph-eats-beads@raygent-skills
```

## Architecture

This repo is a **marketplace index** — it catalogs plugins but doesn't necessarily contain them all:

```
raygent-skills (marketplace)
├── .claude-plugin/marketplace.json  ← index pointing to plugins
├── openrouter/                      ← plugin hosted here
└── README.md

ralph-eats-beads (separate repo)     ← plugin hosted externally
├── SKILL.md
└── scripts/
```

## Adding Plugins

To add a plugin to this marketplace, update `.claude-plugin/marketplace.json`:

```json
{
  "name": "my-plugin",
  "description": "What it does",
  "repo": "https://github.com/owner/repo",
  "version": "1.0.0"
}
```

## License

MIT

## Author

Raymond Weitekamp ([@rawwerks](https://github.com/rawwerks))
