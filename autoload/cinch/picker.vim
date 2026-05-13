scriptencoding utf-8
" autoload/cinch/picker.vim — Vim 8 popup/scratch fallback picker.
" Used by cinch#history() on classic Vim (non-Neovim).
" Neovim delegates to lua/cinch/init.lua instead.

" cinch#picker#open({limit} [, {force_scratch}])
"
"   limit        — maximum number of clips to fetch
"   force_scratch — when non-zero, always use the scratch-buffer path even if
"                   popup_create() is available (used by the test suite and as
"                   the Vim 8.0-8.1 fallback)
"
function! cinch#picker#open(limit, ...) abort
  let l:force_scratch = a:0 ? a:1 : 0

  let l:json = system(g:cinch_binary . ' list --json --limit ' . a:limit)
  if v:shell_error != 0
    call cinch#_echo_error('list failed')
    return
  endif

  let l:clips = json_decode(l:json)
  if empty(l:clips)
    echo '[cinch] no clips'
    return
  endif

  let l:lines = []
  for l:c in l:clips
    let l:first = l:c.content_type ==# 'image'
          \ ? printf('[image · %d B]', l:c.byte_size)
          \ : split(l:c.content, "\n")[0]
    call add(l:lines, printf('[%s] %s', l:c.source, l:first))
  endfor

  if !l:force_scratch && exists('*popup_create')
    let s:cinch_picker_clips = l:clips
    call popup_create(l:lines, {
          \ 'title':      ' cinch history ',
          \ 'border':     [],
          \ 'mapping':    0,
          \ 'cursorline': 1,
          \ 'filter':     function('s:popup_filter'),
          \ 'callback':   function('s:popup_callback'),
          \ })
  else
    call s:scratch_buffer(l:lines, l:clips)
  endif
endfunction

" Keyboard handler for the popup window.
" <CR> accepts the current line; q / <Esc> dismiss.
function! s:popup_filter(id, key) abort
  if a:key ==# "\<CR>"
    let l:idx = line('.', a:id)
    call popup_close(a:id, l:idx)
    return 1
  elseif a:key ==# 'q' || a:key ==# "\<Esc>"
    call popup_close(a:id, -1)
    return 1
  endif
  return 0
endfunction

" Popup close callback: paste the selected clip content.
" result == -1 means dismissed without selection.
function! s:popup_callback(id, result) abort
  if a:result <= 0 | return | endif
  let l:c = s:cinch_picker_clips[a:result - 1]
  call setreg(g:cinch_push_register, l:c.content)
  silent normal! p
endfunction

" Open a scratch buffer and populate it with one display line per clip.
" <CR> pastes the clip under the cursor; q closes without pasting.
function! s:scratch_buffer(lines, clips) abort
  new
  setlocal buftype=nofile bufhidden=wipe noswapfile
  call setline(1, a:lines)
  let b:cinch_clips = a:clips
  nnoremap <buffer> q         :bwipeout!<CR>
  nnoremap <buffer> <CR>      :call <SID>scratch_choose()<CR>
endfunction

function! s:scratch_choose() abort
  let l:c = b:cinch_clips[line('.') - 1]
  call setreg(g:cinch_push_register, l:c.content)
  bwipeout!
  silent normal! p
endfunction
