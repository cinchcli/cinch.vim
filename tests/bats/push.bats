#!/usr/bin/env bats

load ../helpers.bash

setup() { setup_cinch_env; }
teardown() { teardown_cinch_env; }

@test "case 2: auto-push + yy triggers exactly one CLI invocation" {
  cat > "$CINCH_TEST_DIR/scenario.vim" <<'EOF'
call setline(1, ['hello world'])
let g:cinch_auto_push = 1
normal! yy
sleep 200m
EOF
  run_vim "$CINCH_TEST_DIR/scenario.vim"
  run calls_count
  [ "$status" -eq 0 ]
  [ "$output" -eq 1 ]
}
