" Minimal init for headless vim/nvim test runs.
set nocompatible
set runtimepath^=.
set runtimepath+=after
filetype plugin on
syntax off
let g:cinch_default_mappings = get(g:, 'cinch_default_mappings', 1)
runtime plugin/cinch.vim
