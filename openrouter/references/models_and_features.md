# OpenRouter Models and Features

## Getting the Models List

To get the full list of available models with pricing and capabilities:

```bash
curl https://openrouter.ai/api/v1/models -H "Authorization: Bearer $OPENROUTER_API_KEY"
```

The response includes:
- Model ID and name
- Pricing (prompt/completion tokens)
- Context length
- Supported parameters
- Architecture details

**Note**: This list can be very large (thousands of tokens). The models are sorted by creation date (newest first), which serves as a decent proxy for quality given AI's rapid pace.

**Tip**: Save the full JSON to a file and use grep/jq to filter by price, context length, or capabilities rather than loading everything into context.

## Model Selection Shortcuts

### Speed Optimization: `:nitro`
Append `:nitro` to any model ID to use the fastest available provider for that model.

Example: `anthropic/claude-3.5-sonnet:nitro`

### Web Search: `:online`
Append `:online` to any model ID to enable web search capabilities.

Example: `openai/gpt-4o:online`

### Combining Modifiers
You can combine modifiers:

Example: `anthropic/claude-3.5-sonnet:nitro:online`

## Common Model Format

OpenRouter uses the format `provider/model-name`:
- `anthropic/claude-3.5-sonnet`
- `openai/gpt-4o`
- `google/gemini-pro-1.5`
- `meta-llama/llama-3.1-405b-instruct`

## Cost and Usage Tracking

The API returns usage data in the response JSON under the `usage` field:
```json
{
  "usage": {
    "prompt_tokens": 14,
    "completion_tokens": 277,
    "total_tokens": 291
  }
}
```

Use the model's pricing information to calculate costs:
- Cost = (prompt_tokens × prompt_price) + (completion_tokens × completion_price)
