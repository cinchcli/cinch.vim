#!/usr/bin/env bats

load ../helpers.bash

setup() { setup_cinch_env; }
teardown() { teardown_cinch_env; }

@test "case 9: exit code 2 message points to cinch auth login" {
  cat > "$CINCH_TEST_DIR/scenario.vim" <<'EOF'
let $CINCH_FAKE_EXIT = 2
let g:cinch_auto_push = 0
silent! CinchPull
call writefile([g:cinch_last_pull.error], g:cinch_test_state_path)
EOF
  run_vim "$CINCH_TEST_DIR/scenario.vim"
  run cat "$CINCH_TEST_DIR/state.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"cinch auth login"* ]]
}

@test "case 12: missing binary triggers 'binary not found'" {
  cat > "$CINCH_TEST_DIR/scenario.vim" <<'EOF'
let g:cinch_binary = '/nonexistent/cinch-binary-xyz'
let g:cinch_auto_push = 1
call setline(1, ['payload'])
normal! yy
sleep 200m
call writefile([g:cinch_last_push.error], g:cinch_test_state_path)
EOF
  run_vim "$CINCH_TEST_DIR/scenario.vim"
  run cat "$CINCH_TEST_DIR/state.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"binary not found"* ]]
}

@test "case 10: :CinchStatus output contains auth, last_push, last_pull lines" {
  cat > "$CINCH_TEST_DIR/scenario.vim" <<'EOF'
let g:cinch_auto_push = 0
silent CinchPull
silent! redir => g:status_out
silent CinchStatus
silent! redir END
call writefile(split(g:status_out, "\n"), g:cinch_test_state_path)
EOF
  run_vim "$CINCH_TEST_DIR/scenario.vim"
  run cat "$CINCH_TEST_DIR/state.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"auth"* ]]
  [[ "$output" == *"last push"* ]]
  [[ "$output" == *"last pull"* ]]
}
