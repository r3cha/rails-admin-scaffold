#!/bin/bash

# Rails Admin Scaffold - Claude Code Skill Installer
# Usage:
#   Global:  curl -sSL https://raw.githubusercontent.com/r3cha/rails-admin-scaffold/main/install.sh | bash
#   Local:   curl -sSL https://raw.githubusercontent.com/r3cha/rails-admin-scaffold/main/install.sh | bash -s -- --local

set -e

REPO_URL="https://github.com/r3cha/rails-admin-scaffold.git"
SKILL_NAME="rails-admin-scaffold"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() { echo -e "${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

# Parse arguments
LOCAL_INSTALL=false
for arg in "$@"; do
  case $arg in
    --local|-l)
      LOCAL_INSTALL=true
      shift
      ;;
  esac
done

# Check for git
if ! command -v git &> /dev/null; then
  print_error "Git is required but not installed."
  exit 1
fi

if [ "$LOCAL_INSTALL" = true ]; then
  # Local installation (per-project)
  INSTALL_DIR=".claude/skills/$SKILL_NAME"
  SETTINGS_FILE=".claude/settings.json"
  SKILL_PATH=".claude/skills/$SKILL_NAME/SKILL.md"

  print_step "Installing $SKILL_NAME locally in current project..."

  # Check if we're in a reasonable directory
  if [ ! -f "Gemfile" ] && [ ! -f "package.json" ]; then
    print_warning "No Gemfile or package.json found. Are you in a project directory?"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
else
  # Global installation
  INSTALL_DIR="$HOME/.claude/skills/$SKILL_NAME"
  SETTINGS_FILE="$HOME/.claude/settings.json"
  SKILL_PATH="~/.claude/skills/$SKILL_NAME/SKILL.md"

  print_step "Installing $SKILL_NAME globally..."
fi

# Create directory and clone
if [ -d "$INSTALL_DIR" ]; then
  print_step "Updating existing installation..."
  cd "$INSTALL_DIR" && git pull --quiet
  cd - > /dev/null
  print_success "Updated $SKILL_NAME"
else
  print_step "Cloning repository..."
  mkdir -p "$(dirname "$INSTALL_DIR")"
  git clone --quiet "$REPO_URL" "$INSTALL_DIR"
  print_success "Cloned $SKILL_NAME"
fi

# Configure settings.json
SETTINGS_DIR="$(dirname "$SETTINGS_FILE")"
mkdir -p "$SETTINGS_DIR"

if [ -f "$SETTINGS_FILE" ]; then
  # Check if skill already configured
  if grep -q "$SKILL_NAME/SKILL.md" "$SETTINGS_FILE" 2>/dev/null; then
    print_success "Skill already configured in settings.json"
  else
    # Add to existing settings
    print_step "Adding skill to existing settings.json..."

    if command -v jq &> /dev/null; then
      # Use jq if available
      tmp=$(mktemp)
      jq --arg path "$SKILL_PATH" '.skills = (.skills // []) + [$path]' "$SETTINGS_FILE" > "$tmp" && mv "$tmp" "$SETTINGS_FILE"
      print_success "Added skill to settings.json"
    else
      print_warning "jq not found. Please manually add to $SETTINGS_FILE:"
      echo ""
      echo "  \"skills\": [\"$SKILL_PATH\"]"
      echo ""
    fi
  fi
else
  # Create new settings file
  print_step "Creating settings.json..."
  echo "{\"skills\":[\"$SKILL_PATH\"]}" > "$SETTINGS_FILE"
  print_success "Created $SETTINGS_FILE"
fi

# Add to .gitignore for local install
if [ "$LOCAL_INSTALL" = true ] && [ -f ".gitignore" ]; then
  if ! grep -q ".claude/skills/" ".gitignore" 2>/dev/null; then
    echo ".claude/skills/" >> .gitignore
    print_success "Added .claude/skills/ to .gitignore"
  fi
fi

echo ""
print_success "Installation complete!"
echo ""
echo "Usage: In Claude Code, run:"
echo ""
echo "  /rails-admin-scaffold"
echo ""
if [ "$LOCAL_INSTALL" = false ]; then
  echo "The skill is now available in all your projects."
else
  echo "The skill is now available in this project."
fi
echo ""
