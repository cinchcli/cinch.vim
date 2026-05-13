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

@test "case 13: g:cinch_last_push is populated after a successful push" {
  cat > "$CINCH_TEST_DIR/scenario.vim" <<'EOF'
call setline(1, ['payload'])
let g:cinch_auto_push = 1
normal! yy
let s:start = reltime()
while g:cinch_last_push.status ==# 'pending' && reltimefloat(reltime(s:start)) < 2.0
  sleep 50m
endwhile
call writefile([json_encode(g:cinch_last_push)], g:cinch_test_state_path)
EOF
  run_vim "$CINCH_TEST_DIR/scenario.vim"
  run cat "$CINCH_TEST_DIR/state.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"status":"ok"'* ]]
  [[ "$output" == *'"bytes":7'* ]]
}

@test "case 3: auto-push off + yy fires zero invocations" {
  cat > "$CINCH_TEST_DIR/scenario.vim" <<'EOF'
call setline(1, ['payload'])
let g:cinch_auto_push = 0
normal! yy
sleep 200m
EOF
  run_vim "$CINCH_TEST_DIR/scenario.vim"
  run calls_count
  [ "$status" -eq 0 ]
  [ "$output" -eq 0 ]
}

@test "case 4: \"ayy with g:cinch_push_register='\"' does not push" {
  cat > "$CINCH_TEST_DIR/scenario.vim" <<'EOF'
call setline(1, ['payload'])
let g:cinch_auto_push = 1
let g:cinch_push_register = '"'
normal! "ayy
sleep 200m
EOF
  run_vim "$CINCH_TEST_DIR/scenario.vim"
  run calls_count
  [ "$status" -eq 0 ]
  [ "$output" -eq 0 ]
}
