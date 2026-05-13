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
let g:cinch_last_push        = get(g:, 'cinch_last_push', {'at': 0, 'bytes': 0, 'status': '', 'error': ''})
let g:cinch_last_pull        = get(g:, 'cinch_last_pull', {'at': 0, 'bytes': 0, 'source': '', 'status': '', 'error': ''})
let g:cinch_in_opfunc        = get(g:, 'cinch_in_opfunc', 0)

" Commands
command! -range=% CinchPush call <SID>cinch_push_range(<range>, <line1>, <line2>)

function! s:cinch_push_range(has_range, l1, l2) abort
  if a:has_range && a:l1 != a:l2
    call cinch#push(join(getline(a:l1, a:l2), "\n"))
  else
    call cinch#push(getreg(g:cinch_push_register))
  endif
endfunction
command! CinchPull call cinch#pull()
command! -nargs=1 -complete=customlist,cinch#complete_devices
      \ CinchPullFrom call cinch#pull({'from': <q-args>})
command! CinchToggle let g:cinch_auto_push = !g:cinch_auto_push
      \ | echom '[cinch] auto-push ' . (g:cinch_auto_push ? 'enabled' : 'disabled')

" <Plug> mappings (always installed; default maps gated by g:cinch_default_mappings)
nnoremap <silent> <expr> <Plug>(cinch-push)      cinch#_set_opfunc()
nnoremap <silent>        <Plug>(cinch-push-line)  :call cinch#push(getline('.'))<CR>
nnoremap <silent>        <Plug>(cinch-push-eol)   :call cinch#push(strpart(getline('.'), col('.') - 1))<CR>
xnoremap <silent>        <Plug>(cinch-push)       :<C-u>call cinch#opfunc_visual()<CR>

nnoremap <silent> <Plug>(cinch-pull)        :call cinch#pull()<CR>
nnoremap <silent> <Plug>(cinch-pull-after)  :call cinch#pull_paste('after')<CR>
nnoremap <silent> <Plug>(cinch-pull-before) :call cinch#pull_paste('before')<CR>

if g:cinch_default_mappings
  silent! nmap <unique> yc  <Plug>(cinch-push)
  silent! nmap <unique> ycc <Plug>(cinch-push-line)
  silent! nmap <unique> yC  <Plug>(cinch-push-eol)
  silent! xmap <unique> yc  <Plug>(cinch-push)
endif

" Autocmd
augroup cinch
  autocmd!
  autocmd TextYankPost * call s:on_yank()
augroup END

function! s:on_yank() abort
  if !g:cinch_auto_push | return | endif
  if get(g:, 'cinch_in_opfunc', 0) | return | endif
  let l:reg = has('nvim') ? v:event.regname : v:register
  if l:reg !=# '' && l:reg !=# g:cinch_push_register | return | endif
  let l:op = has('nvim') ? v:event.operator : 'y'
  if l:op !=# 'y' | return | endif
  if has('nvim')
    let l:text = join(v:event.regcontents, "\n")
  else
    let l:text = substitute(getreg(g:cinch_push_register), "\n$", '', '')
  endif
  call cinch#push(l:text)
endfunction
