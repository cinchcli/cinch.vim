#!/usr/bin/env bats

load ../helpers.bash

setup() { setup_cinch_env; }
teardown() { teardown_cinch_env; }

@test "fake cinch records argv and stdin" {
  echo "hello" | tests/bin/cinch push --extra arg
  run cat "$CINCH_TEST_DIR/calls.log"
  [ "$status" -eq 0 ]
  [[ "$output" == *"push --extra arg"* ]]
  [[ "$output" == *"hello"* ]]
}

@test "minimal.vim sources cinch plugin without error" {
  run "${VIM_BIN:-vim}" -Es -u tests/minimal.vim -c 'qa!' < /dev/null
  [ "$status" -eq 0 ]
}
