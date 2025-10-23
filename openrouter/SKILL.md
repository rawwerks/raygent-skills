---
name: openrouter
description: Use this skill when the user wants to call different LLM models through OpenRouter's unified API, compare model responses, track costs and response times, or find the best model for a task. Triggers include requests to test models, benchmark performance, use specific providers (OpenAI, Anthropic, Google, etc.), or optimize for speed/cost.
---

# OpenRouter

## Overview

OpenRouter provides a unified API to access hundreds of LLM models from different providers (OpenAI, Anthropic, Google, Meta, and more) with automatic routing, cost tracking, and performance monitoring. Use this skill to make API calls to any OpenRouter model, compare responses across models, track costs and latency, and optimize model selection.

## Quick Start

To call an OpenRouter model:

1. Set `OPENROUTER_API_KEY` in your environment
2. Use the `scripts/call_openrouter.sh` script with `--model` and `--prompt` flags
3. Add `--json` flag for structured output

The script returns:
- **Response time** in seconds (wall-clock time)
- **Cost** in dollars (OpenRouter pricing)
- **Full response content**
- **Token counts** (prompt, completion, total)

## Making API Calls

### Basic Usage

The `scripts/call_openrouter.sh` script provides a flexible CLI interface:

```bash
# Basic call
bash scripts/call_openrouter.sh \
  --model "anthropic/claude-3.5-sonnet" \
  --prompt "Explain quantum computing" \
  --json

# With optional parameters
bash scripts/call_openrouter.sh \
  --model "openai/gpt-4o:nitro" \
  --prompt "Write a haiku" \
  --max-tokens 100 \
  --temperature 0.7 \
  --json
```

### Command-Line Arguments

- `--model` (required): Model ID (e.g., "anthropic/claude-3.5-sonnet")
- `--prompt` (required): User prompt/question
- `--system`: Optional system message
- `--max-tokens`: Maximum tokens to generate
- `--temperature`: Temperature (0.0-2.0)
- `--json`: Output as JSON (default: human-readable)

### Environment Variables

- `OPENROUTER_API_KEY` (required): Your API key
- `OPENROUTER_REFERER` (optional): HTTP referer for tracking (default: http://localhost)
- `OPENROUTER_TITLE` (optional): Title for tracking (default: Local Test)
- `MODEL` (optional): Override the default model

### Reading the Output

The script outputs:
1. Response time in seconds (measured client-side)
2. Complete JSON response with:
   - `choices[0].message.content`: The model's response
   - `usage.prompt_tokens`: Input token count
   - `usage.completion_tokens`: Output token count
   - `usage.total_tokens`: Total tokens used

### Cost Calculation

To calculate costs:
1. Get the model's pricing from the models list (see references)
2. Calculate: `(prompt_tokens × prompt_price) + (completion_tokens × completion_price)`

Example: If a model costs $0.0000025/token for prompts and $0.000002/token for completions, and uses 14 prompt + 277 completion tokens:
- Cost = (14 × 0.0000025) + (277 × 0.000002) = $0.000035 + $0.000554 = $0.000589

## Model Selection

### Finding Models

Retrieve the full models list with pricing and capabilities:

```bash
curl https://openrouter.ai/api/v1/models -H "Authorization: Bearer $OPENROUTER_API_KEY" > models.json
```

The list is sorted by creation date (newest first), serving as a proxy for quality.

**Important**: The models list can be very large. Consider saving to a file and using grep/jq to filter by:
- Price range
- Context length
- Specific providers
- Capabilities (vision, function calling, etc.)

### Model Naming Format

OpenRouter uses `provider/model-name`:
- `anthropic/claude-3.5-sonnet`
- `openai/gpt-4o`
- `google/gemini-pro-1.5`
- `meta-llama/llama-3.1-405b-instruct`

### Speed and Feature Modifiers

**`:nitro`** - Use the fastest available provider for a model
```
anthropic/claude-3.5-sonnet:nitro
```

**`:online`** - Enable web search capabilities
```
openai/gpt-4o:online
```

**Combine modifiers:**
```
anthropic/claude-3.5-sonnet:nitro:online
```

## Common Use Cases

### Testing a Specific Model

Edit the script's `PAYLOAD` to use the desired model and messages:

```bash
{
  "model": "anthropic/claude-3.5-sonnet",
  "messages": [
    {"role": "user", "content": "Explain quantum computing in simple terms"}
  ]
}
```

### Comparing Models

Run the script multiple times with different models and compare:
- Response quality
- Response time
- Token usage and cost

### Finding the Cheapest/Fastest Model

1. Fetch the models list and save to file
2. Use jq or grep to filter by criteria
3. Test top candidates with the script
4. Compare performance vs. cost trade-offs

For speed: Try models with `:nitro` suffix
For cost: Filter models.json by lowest pricing values

## Resources

### scripts/call_openrouter.sh

Bash script that makes an API call to OpenRouter and returns timing, cost, and full response. Uses curl and jq for simple, dependency-free execution.

**Requirements**: `jq` (for JSON parsing)

**Usage**:
```bash
bash call_openrouter.sh --model "anthropic/claude-3.5-sonnet" --prompt "Your question" --json
```

### references/models_and_features.md

Detailed reference on:
- How to fetch and filter the models list
- Model naming conventions
- Speed (`:nitro`) and web search (`:online`) modifiers
- Cost calculation from usage data
