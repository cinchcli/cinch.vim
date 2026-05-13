# cinch.vim manual smoke checklist

Run before tagging a release.

## Push

- [ ] `ycw` pushes word, register unchanged after
- [ ] `ycc` pushes line
- [ ] `yC` pushes to EOL
- [ ] Visual `yc` pushes selection
- [ ] `:'<,'>CinchPush` pushes range

## Pull

- [ ] `:CinchPull` writes latest clip to `"`
- [ ] `:CinchPullFrom desktop` (and tab-completion) works
- [ ] `g:cinch_default_source` is honoured
- [ ] `g:cinch_pull_exclude_self = 1` adds `--exclude-self`
- [ ] `<Plug>(cinch-pull-after)` pastes after cursor

## History picker

For each adapter (snacks, fzf-lua, telescope, builtin):

- [ ] `:CinchHistory` opens the picker
- [ ] `:CinchHistory!` shows 200 rows
- [ ] `<CR>` pastes the selected clip
- [ ] Image clips display metadata only

## Status / error

- [ ] `:CinchStatus` shows all fields
- [ ] Logging out → push shows "cinch auth login" message
- [ ] Renaming the binary → "binary not found" message
