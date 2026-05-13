" cinch.vim - Vim/Neovim plugin for Cinch remote clipboard
" https://github.com/cinchcli/cinch.vim

if exists('g:loaded_cinch') | finish | endif
let g:loaded_cinch = 1

" Configuration
let g:cinch_auto_push     = get(g:, 'cinch_auto_push', 1)
let g:cinch_push_register = get(g:, 'cinch_push_register', '"')
let g:cinch_binary        = get(g:, 'cinch_binary', 'cinch')

" ── Core functions ────────────────────────────────────────────────────────────

function! cinch#push(text) abort
  if !executable(g:cinch_binary)
    echohl WarningMsg | echom '[cinch] binary not found: ' . g:cinch_binary | echohl None
    return
  endif
  if has('nvim')
    call jobstart([g:cinch_binary, 'push'], {
          \ 'stdin': split(a:text, "\n", 1),
          \ 'on_stderr': function('s:on_error'),
          \ })
  else
    let l:job = job_start([g:cinch_binary, 'push'], {
          \ 'in_io': 'pipe',
          \ 'err_cb': function('s:on_error_vim'),
          \ 'exit_cb': function('s:noop'),
          \ })
    let l:ch = job_getchannel(l:job)
    call ch_sendraw(l:ch, a:text)
    call ch_close_in(l:ch)
  endif
endfunction

function! cinch#pull() abort
  if !executable(g:cinch_binary)
    echohl WarningMsg | echom '[cinch] binary not found: ' . g:cinch_binary | echohl None
    return
  endif
  let output = system(g:cinch_binary . ' pull')
  if v:shell_error
    echohl ErrorMsg | echom '[cinch] pull failed' | echohl None
    return
  endif
  call setreg(g:cinch_push_register, output)
  echom '[cinch] pulled to register @' . g:cinch_push_register
endfunction

function! s:on_yank() abort
  if !g:cinch_auto_push | return | endif
  let event_reg = has('nvim') ? v:event.regname : v:register
  if event_reg !=# '' && event_reg !=# g:cinch_push_register | return | endif
  let operator = has('nvim') ? v:event.operator : 'y'
  if operator !=# 'y' | return | endif
  let text = has('nvim')
        \ ? join(v:event.regcontents, "\n")
        \ : getreg(g:cinch_push_register)
  call cinch#push(text)
endfunction

" ── Error callbacks ───────────────────────────────────────────────────────────

function! s:on_error(job, data, event) abort
  if !empty(filter(copy(a:data), 'v:val !=# ""'))
    echohl ErrorMsg | echom '[cinch] ' . join(a:data) | echohl None
  endif
endfunction

function! s:on_error_vim(channel, msg) abort
  echohl ErrorMsg | echom '[cinch] ' . a:msg | echohl None
endfunction

function! s:noop(...) abort
endfunction

" ── Commands ──────────────────────────────────────────────────────────────────

command! CinchPush call cinch#push(getreg(g:cinch_push_register))
command! CinchPull call cinch#pull()
command! CinchToggle let g:cinch_auto_push = !g:cinch_auto_push
      \ | echom '[cinch] auto-push ' . (g:cinch_auto_push ? 'enabled' : 'disabled')

" ── Autocmd ───────────────────────────────────────────────────────────────────

augroup cinch
  autocmd!
  autocmd TextYankPost * call s:on_yank()
augroup END
