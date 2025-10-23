#!/usr/bin/env bash
set -euo pipefail

# Check for required API key
: "${OPENROUTER_API_KEY:?Set OPENROUTER_API_KEY in your environment}"

# Parse command-line arguments
MODEL=""
PROMPT=""
SYSTEM_MSG=""
MAX_TOKENS=""
TEMPERATURE=""
JSON_OUTPUT=false

show_usage() {
    cat <<EOF
Usage: $0 --model MODEL --prompt PROMPT [OPTIONS]

Required:
  --model MODEL          Model ID (e.g., "anthropic/claude-3.5-sonnet")
  --prompt PROMPT        User prompt/question

Optional:
  --system SYSTEM        System message
  --max-tokens N         Maximum tokens to generate
  --temperature N        Temperature (0.0-2.0)
  --json                 Output as JSON
  --help                 Show this help message

Environment Variables:
  OPENROUTER_API_KEY     Your OpenRouter API key (required)
  OPENROUTER_REFERER     HTTP referer for tracking (default: https://raw.works)
  OPENROUTER_TITLE       Title for tracking (default: RAW.works)

Examples:
  $0 --model "openai/gpt-4o-mini" --prompt "What is 2+2?" --json
  $0 --model "anthropic/claude-3.5-sonnet:nitro" --prompt "Explain quantum computing" --max-tokens 500
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --model)
            MODEL="$2"
            shift 2
            ;;
        --prompt)
            PROMPT="$2"
            shift 2
            ;;
        --system)
            SYSTEM_MSG="$2"
            shift 2
            ;;
        --max-tokens)
            MAX_TOKENS="$2"
            shift 2
            ;;
        --temperature)
            TEMPERATURE="$2"
            shift 2
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            show_usage >&2
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$MODEL" ]]; then
    echo "Error: --model is required" >&2
    show_usage >&2
    exit 1
fi

if [[ -z "$PROMPT" ]]; then
    echo "Error: --prompt is required" >&2
    show_usage >&2
    exit 1
fi

# Set defaults
REFERER="${OPENROUTER_REFERER:-https://raw.works}"
TITLE="${OPENROUTER_TITLE:-RAW.works}"

# Build messages array
MESSAGES="["
if [[ -n "$SYSTEM_MSG" ]]; then
    MESSAGES="${MESSAGES}{\"role\": \"system\", \"content\": $(printf '%s' "$SYSTEM_MSG" | jq -Rs .)},"
fi
MESSAGES="${MESSAGES}{\"role\": \"user\", \"content\": $(printf '%s' "$PROMPT" | jq -Rs .)}"
MESSAGES="${MESSAGES}]"

# Build request body
REQUEST_BODY=$(cat <<EOF
{
  "model": "$MODEL",
  "messages": $MESSAGES,
  "extra_body": {
    "usage": { "include": true }
  }
EOF
)

# Add optional parameters
if [[ -n "$MAX_TOKENS" ]]; then
    REQUEST_BODY="${REQUEST_BODY},\"max_tokens\": $MAX_TOKENS"
fi

if [[ -n "$TEMPERATURE" ]]; then
    REQUEST_BODY="${REQUEST_BODY},\"temperature\": $TEMPERATURE"
fi

REQUEST_BODY="${REQUEST_BODY}}"

# Make the API call
SECONDS=0
TMP_RESPONSE=$(mktemp)
HTTP_STATUS=$(
  curl --silent --show-error \
       --header "Authorization: Bearer ${OPENROUTER_API_KEY}" \
       --header "Content-Type: application/json" \
       --header "HTTP-Referer: ${REFERER}" \
       --header "X-Title: ${TITLE}" \
       --data "${REQUEST_BODY}" \
       --output "${TMP_RESPONSE}" \
       --write-out '%{http_code}' \
       https://openrouter.ai/api/v1/chat/completions
)
ELAPSED_SECONDS=$SECONDS

# Check for errors
if [[ "${HTTP_STATUS}" -ne 200 ]]; then
    echo "Error: Request failed (HTTP ${HTTP_STATUS}) after ${ELAPSED_SECONDS}s" >&2
    cat "${TMP_RESPONSE}" >&2
    rm -f "${TMP_RESPONSE}"
    exit 1
fi

# Parse response
RESPONSE=$(cat "${TMP_RESPONSE}")
rm -f "${TMP_RESPONSE}"

# Extract data from response
CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty')
PROMPT_TOKENS=$(echo "$RESPONSE" | jq -r '.usage.prompt_tokens // null')
COMPLETION_TOKENS=$(echo "$RESPONSE" | jq -r '.usage.completion_tokens // null')
TOTAL_TOKENS=$(echo "$RESPONSE" | jq -r '.usage.total_tokens // null')
COST=$(echo "$RESPONSE" | jq -r '.usage.cost // null')

# Output results
if [[ "$JSON_OUTPUT" == true ]]; then
    # JSON output
    cat <<EOF
{
  "model": "$MODEL",
  "success": true,
  "response_time": $ELAPSED_SECONDS,
  "cost": $COST,
  "error": null,
  "content": $(echo "$CONTENT" | jq -Rs .),
  "usage": {
    "prompt_tokens": $PROMPT_TOKENS,
    "completion_tokens": $COMPLETION_TOKENS,
    "total_tokens": $TOTAL_TOKENS
  }
}
EOF
else
    # Human-readable output
    echo "Model: $MODEL"
    echo "Response time: ${ELAPSED_SECONDS}s"
    echo ""
    echo "--- Response ---"
    echo "$CONTENT"
    echo ""
    echo "--- Usage ---"
    echo "Prompt tokens: $PROMPT_TOKENS"
    echo "Completion tokens: $COMPLETION_TOKENS"
    echo "Total tokens: $TOTAL_TOKENS"
    if [[ "$COST" != "null" ]]; then
        echo "Cost: \$$COST"
    fi
fi
