#!/usr/bin/env bash
set -euo pipefail

# Setup script to install git hooks for this repository
# Run this once after cloning: bash scripts/setup_hooks.sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"

echo "🔧 Setting up git hooks for raygent-skills..."

# Check if we're in a git repository
if [[ ! -d "$REPO_ROOT/.git" ]]; then
    echo "Error: Not in a git repository" >&2
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Install pre-commit hook
cat > "$HOOKS_DIR/pre-commit" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Pre-commit hook to automatically package all skills
# This ensures that .zip files are always up-to-date with the skill source

echo "🔄 Running pre-commit hook: Packaging skills..."

REPO_ROOT="$(git rev-parse --show-toplevel)"
PACKAGE_SCRIPT="$REPO_ROOT/scripts/package_all_skills.sh"

if [[ ! -f "$PACKAGE_SCRIPT" ]]; then
    echo "Warning: Package script not found at $PACKAGE_SCRIPT" >&2
    echo "Skipping skill packaging." >&2
    exit 0
fi

# Run the packaging script
if "$PACKAGE_SCRIPT"; then
    echo "✅ All skills packaged successfully"
else
    echo "❌ Skill packaging failed" >&2
    echo "" >&2
    echo "Your commit was aborted to prevent committing out-of-date skill packages." >&2
    echo "Please fix the errors above and try again." >&2
    exit 1
fi

exit 0
EOF

chmod +x "$HOOKS_DIR/pre-commit"

echo "✅ Pre-commit hook installed"
echo ""
echo "The hook will automatically package skills before each commit."
echo "To test: make a change and run 'git commit'"
