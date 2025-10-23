#!/usr/bin/env bash
set -euo pipefail

# Script to package all skills in the repository
# Uses the Anthropic skill-creator packaging script

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKAGE_SCRIPT="/Users/raymondweitekamp/.claude/plugins/marketplaces/anthropic-agent-skills/skill-creator/scripts/package_skill.py"

# Check if package script exists
if [[ ! -f "$PACKAGE_SCRIPT" ]]; then
    echo "Error: Package script not found at $PACKAGE_SCRIPT" >&2
    echo "Make sure the skill-creator plugin is installed." >&2
    exit 1
fi

# Find all SKILL.md files (these indicate skill directories)
SKILLS_PACKAGED=0
SKILLS_FAILED=0

echo "🔍 Finding skills in $REPO_ROOT..."

# Look for SKILL.md files, excluding .claude-plugin directory
while IFS= read -r -d '' skill_file; do
    SKILL_DIR="$(dirname "$skill_file")"
    SKILL_NAME="$(basename "$SKILL_DIR")"

    echo ""
    echo "📦 Packaging skill: $SKILL_NAME"

    if python3 "$PACKAGE_SCRIPT" "$SKILL_DIR" "$REPO_ROOT"; then
        echo "✅ Successfully packaged: ${SKILL_NAME}.zip"
        ((SKILLS_PACKAGED++))

        # Stage the zip file for commit
        git add "${REPO_ROOT}/${SKILL_NAME}.zip" 2>/dev/null || true
    else
        echo "❌ Failed to package: $SKILL_NAME" >&2
        ((SKILLS_FAILED++))
    fi
done < <(find "$REPO_ROOT" -name "SKILL.md" -not -path "*/.claude-plugin/*" -print0)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: $SKILLS_PACKAGED skill(s) packaged, $SKILLS_FAILED failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ $SKILLS_FAILED -gt 0 ]]; then
    exit 1
fi

exit 0
