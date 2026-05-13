# Shared bats helpers for cinch.vim. Source via `load ../helpers.bash`.

setup_cinch_env() {
  export CINCH_TEST_DIR="$(mktemp -d)"
  export CINCH_FIXTURES_DIR="$BATS_TEST_DIRNAME/../fixtures"
  export PATH="$BATS_TEST_DIRNAME/../bin:$PATH"
  : > "$CINCH_TEST_DIR/calls.log"
  : > "$CINCH_TEST_DIR/state.json"
}

teardown_cinch_env() {
  rm -rf "$CINCH_TEST_DIR"
}

run_vim() {
  local script="$1"
  shift
  local out_state="$CINCH_TEST_DIR/state.json"
  "${VIM_BIN:-vim}" -Es -u tests/minimal.vim \
    -c "let g:cinch_test_state_path = '$out_state'" \
    -c "source $script" \
    -c "qa!" "$@" < /dev/null
}

read_calls() {
  cat "$CINCH_TEST_DIR/calls.log"
}

calls_count() {
  grep -c . "$CINCH_TEST_DIR/calls.log" || true
}
