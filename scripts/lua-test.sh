#!/usr/bin/env bash
set -euo pipefail
export CINCH_TEST_DIR="$(mktemp -d)"
export CINCH_FIXTURES_DIR="$PWD/tests/fixtures"
export PATH="$PWD/tests/bin:$PATH"
: > "$CINCH_TEST_DIR/calls.log"

# Ensure plenary is available
PLENARY_DIR="${PLENARY_DIR:-$HOME/.cache/cinch.vim/plenary.nvim}"
if [ ! -d "$PLENARY_DIR" ]; then
  mkdir -p "$(dirname "$PLENARY_DIR")"
  git clone --depth 1 https://github.com/nvim-lua/plenary.nvim "$PLENARY_DIR"
fi

nvim --headless \
  --cmd "set rtp+=." \
  --cmd "set rtp+=$PLENARY_DIR" \
  -c "PlenaryBustedDirectory tests/lua_spec/ {minimal_init = 'tests/minimal.vim'}" \
  -c 'qa!'

# Clean up the test dir
rm -rf "$CINCH_TEST_DIR"
