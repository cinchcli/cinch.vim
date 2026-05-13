#!/usr/bin/env bats

load ../helpers.bash

setup() { setup_cinch_env; }
teardown() { teardown_cinch_env; }

@test "case 7: :CinchPull writes fixture content to the register" {
  cat > "$CINCH_TEST_DIR/scenario.vim" <<'EOF'
let g:cinch_auto_push = 0
silent CinchPull
call writefile([getreg('"')], g:cinch_test_state_path)
EOF
  run_vim "$CINCH_TEST_DIR/scenario.vim"
  run cat "$CINCH_TEST_DIR/state.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"hello from the fake relay"* ]]
}

@test "case 8: :CinchPullFrom desktop passes --from desktop in argv" {
  cat > "$CINCH_TEST_DIR/scenario.vim" <<'EOF'
let g:cinch_auto_push = 0
silent CinchPullFrom desktop
EOF
  run_vim "$CINCH_TEST_DIR/scenario.vim"
  run cat "$CINCH_TEST_DIR/calls.log"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pull --from desktop"* ]]
}

@test "case 11: g:cinch_default_source applies to :CinchPull" {
  cat > "$CINCH_TEST_DIR/scenario.vim" <<'EOF'
let g:cinch_auto_push = 0
let g:cinch_default_source = 'mac'
silent CinchPull
EOF
  run_vim "$CINCH_TEST_DIR/scenario.vim"
  run cat "$CINCH_TEST_DIR/calls.log"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pull --from mac"* ]]
}

@test "exclude-self: pull --exclude-self when g:cinch_pull_exclude_self=1" {
  cat > "$CINCH_TEST_DIR/scenario.vim" <<'EOF'
let g:cinch_auto_push = 0
let g:cinch_pull_exclude_self = 1
silent CinchPull
EOF
  run_vim "$CINCH_TEST_DIR/scenario.vim"
  run cat "$CINCH_TEST_DIR/calls.log"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pull --exclude-self"* ]]
}

@test "exclude-self is suppressed when --from is set" {
  cat > "$CINCH_TEST_DIR/scenario.vim" <<'EOF'
let g:cinch_auto_push = 0
let g:cinch_pull_exclude_self = 1
silent CinchPullFrom desktop
EOF
  run_vim "$CINCH_TEST_DIR/scenario.vim"
  run cat "$CINCH_TEST_DIR/calls.log"
  [ "$status" -eq 0 ]
  [[ "$output" != *"--exclude-self"* ]]
}

@test "<Plug>(cinch-pull) invokes cinch pull and writes to register" {
  cat > "$CINCH_TEST_DIR/scenario.vim" <<'EOF'
let g:cinch_auto_push = 0
nmap gp <Plug>(cinch-pull)
normal gp
call writefile([getreg('"')], g:cinch_test_state_path)
EOF
  run_vim "$CINCH_TEST_DIR/scenario.vim"
  run cat "$CINCH_TEST_DIR/state.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"hello from the fake relay"* ]]
}

@test "<Plug>(cinch-pull-after) pastes after cursor" {
  cat > "$CINCH_TEST_DIR/scenario.vim" <<'EOF'
call setline(1, ['head'])
let g:cinch_auto_push = 0
nmap gp <Plug>(cinch-pull-after)
normal gp
call writefile(getline(1, '$'), g:cinch_test_state_path)
EOF
  run_vim "$CINCH_TEST_DIR/scenario.vim"
  run cat "$CINCH_TEST_DIR/state.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"head"* ]]
  [[ "$output" == *"hello from the fake relay"* ]]
}
