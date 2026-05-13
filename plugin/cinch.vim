" cinch.vim - Vim/Neovim plugin for Cinch remote clipboard
" https://github.com/cinchcli/cinch.vim

if exists('g:loaded_cinch') | finish | endif
let g:loaded_cinch = 1

" Configuration defaults
let g:cinch_auto_push        = get(g:, 'cinch_auto_push', 1)
let g:cinch_push_register    = get(g:, 'cinch_push_register', '"')
let g:cinch_binary           = get(g:, 'cinch_binary', 'cinch')
let g:cinch_default_source   = get(g:, 'cinch_default_source', '')
let g:cinch_pull_exclude_self = get(g:, 'cinch_pull_exclude_self', 0)
let g:cinch_default_mappings = get(g:, 'cinch_default_mappings', 1)
let g:cinch_verbose          = get(g:, 'cinch_verbose', 0)

" Commands
command! CinchPush call cinch#push(getreg(g:cinch_push_register))
command! CinchPull call cinch#pull()
command! CinchToggle let g:cinch_auto_push = !g:cinch_auto_push
      \ | echom '[cinch] auto-push ' . (g:cinch_auto_push ? 'enabled' : 'disabled')

" Autocmd
augroup cinch
  autocmd!
  autocmd TextYankPost * call s:on_yank()
augroup END

function! s:on_yank() abort
  if !g:cinch_auto_push | return | endif
  let l:reg = has('nvim') ? v:event.regname : v:register
  if l:reg !=# '' && l:reg !=# g:cinch_push_register | return | endif
  let l:op = has('nvim') ? v:event.operator : 'y'
  if l:op !=# 'y' | return | endif
  let l:text = has('nvim') ? join(v:event.regcontents, "\n") : getreg(g:cinch_push_register)
  call cinch#push(l:text)
endfunction
