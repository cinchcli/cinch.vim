" autoload/cinch.vim — core push/pull/status.

function! cinch#push(text, ...) abort
  if !executable(g:cinch_binary)
    call cinch#_set_last('push', {'status': 'error', 'error': 'binary not found: ' . g:cinch_binary})
    call cinch#_echo_error('binary not found: ' . g:cinch_binary)
    return
  endif
  let g:cinch_last_push = {'at': localtime(), 'bytes': strlen(a:text), 'status': 'pending', 'error': ''}
  let l:argv = [g:cinch_binary, 'push']
  if has('nvim')
    let l:jid = jobstart(l:argv, {
          \ 'stdin': 'pipe',
          \ 'on_stderr': function('cinch#_on_stderr_nvim', ['push']),
          \ 'on_exit': function('cinch#_on_exit_nvim', ['push']),
          \ })
    call chansend(l:jid, split(a:text, "\n", 1))
    call chanclose(l:jid, 'stdin')
  else
    let l:job = job_start(l:argv, {
          \ 'in_io': 'pipe',
          \ 'err_cb': function('cinch#_on_stderr_vim', ['push']),
          \ 'exit_cb': function('cinch#_on_exit_vim', ['push']),
          \ })
    let l:ch = job_getchannel(l:job)
    call ch_sendraw(l:ch, a:text)
    call ch_close_in(l:ch)
  endif
endfunction

function! cinch#pull(...) abort
  let l:opts = a:0 ? a:1 : {}
  if !executable(g:cinch_binary)
    call cinch#_set_last('pull', {'status': 'error', 'error': 'binary not found: ' . g:cinch_binary})
    call cinch#_echo_error('binary not found: ' . g:cinch_binary)
    return ''
  endif
  let l:argv = [g:cinch_binary, 'pull']
  if has_key(l:opts, 'from') && !empty(l:opts.from)
    call extend(l:argv, ['--from', l:opts.from])
  else
    if get(g:, 'cinch_default_source', '') !=# ''
      call extend(l:argv, ['--from', g:cinch_default_source])
      let l:opts.from = g:cinch_default_source
    elseif get(g:, 'cinch_pull_exclude_self', 0)
      call add(l:argv, '--exclude-self')
    endif
  endif
  let l:output = system(join(map(copy(l:argv), 'shellescape(v:val)'), ' '))
  let l:exit = v:shell_error
  if l:exit != 0
    let g:cinch_last_pull = {'at': localtime(), 'bytes': 0, 'source': get(l:opts, 'from', ''), 'status': 'error', 'error': cinch#_exit_message(l:exit, l:output)}
    call cinch#_echo_error(g:cinch_last_pull.error)
    return ''
  endif
  let l:register = get(l:opts, 'register', g:cinch_push_register)
  call setreg(l:register, l:output)
  let g:cinch_last_pull = {'at': localtime(), 'bytes': strlen(l:output), 'source': get(l:opts, 'from', ''), 'status': 'ok', 'error': ''}
  if get(g:, 'cinch_verbose', 0) >= 1
    echom '[cinch] pulled ' . strlen(l:output) . ' bytes to @' . l:register
  endif
  return l:output
endfunction

function! cinch#_set_last(kind, fields) abort
  call extend(a:kind ==# 'push' ? g:cinch_last_push : g:cinch_last_pull, a:fields)
endfunction

function! cinch#_echo_error(msg) abort
  echohl ErrorMsg | echom '[cinch] ' . a:msg | echohl None
endfunction

function! cinch#_exit_message(code, stderr) abort
  if a:code == 2 | return 'not authenticated. Run: cinch auth login' | endif
  if a:code == 4 | return 'relay unreachable. Check network or relay URL' | endif
  let l:first = split(a:stderr, "\n")
  return empty(l:first) ? ('cli exit ' . a:code) : l:first[0]
endfunction

function! cinch#_on_stderr_nvim(kind, job, data, event) abort
  let l:lines = filter(copy(a:data), 'v:val !=# ""')
  if !empty(l:lines)
    call cinch#_set_last(a:kind, {'error': join(l:lines, ' ')})
  endif
endfunction

function! cinch#_on_stderr_vim(kind, channel, msg) abort
  call cinch#_set_last(a:kind, {'error': a:msg})
endfunction

function! cinch#_on_exit_nvim(kind, job, code, event) abort
  call cinch#_finish(a:kind, a:code)
endfunction

function! cinch#_on_exit_vim(kind, job, code) abort
  call cinch#_finish(a:kind, a:code)
endfunction

function! cinch#_finish(kind, code) abort
  let l:target = a:kind ==# 'push' ? g:cinch_last_push : g:cinch_last_pull
  let l:target.status = a:code == 0 ? 'ok' : 'error'
  if a:code != 0
    let l:target.error = cinch#_exit_message(a:code, get(l:target, 'error', ''))
    call cinch#_echo_error(l:target.error)
  endif
  call cinch#_set_last(a:kind, l:target)
endfunction

" Operator function: called by Vim after the user provides a motion to yc{motion}.
" Yanks the motion region into @", calls cinch#push, then restores @" so the
" operator does not clobber the user's unnamed register.
" g:cinch_in_opfunc is set while the yank happens so that the TextYankPost
" autocmd (s:on_yank) skips the push — preventing a double-push when
" g:cinch_auto_push = 1.
function! cinch#opfunc(type) abort
  let l:save_reg  = getreg('"')
  let l:save_type = getregtype('"')
  let g:cinch_in_opfunc = 1
  try
    if a:type ==# 'char'
      silent normal! `[v`]y
    elseif a:type ==# 'line'
      silent normal! '[V']y
    elseif a:type ==# 'block'
      silent execute "normal! `[\<C-v>`]y"
    endif
    call cinch#push(getreg('"'))
  finally
    let g:cinch_in_opfunc = 0
    call setreg('"', l:save_reg, l:save_type)
  endtry
endfunction

" Visual operator: re-selects the last visual region, yanks it, calls
" cinch#push, then restores @".
" g:cinch_in_opfunc guards against double-push (same reason as cinch#opfunc).
function! cinch#opfunc_visual() abort
  let l:save_reg  = getreg('"')
  let l:save_type = getregtype('"')
  let g:cinch_in_opfunc = 1
  try
    silent normal! gvy
    call cinch#push(getreg('"'))
  finally
    let g:cinch_in_opfunc = 0
    call setreg('"', l:save_reg, l:save_type)
  endtry
endfunction

" Returns 'g@' (the operator-pending prefix) after setting operatorfunc.
" Used as <expr> in the <Plug>(cinch-push) normal-mode mapping so that
" yc{motion} works: Vim evaluates the expression, gets 'g@', then waits
" for the user's motion and calls cinch#opfunc with the motion type.
function! cinch#_set_opfunc() abort
  set operatorfunc=cinch#opfunc
  return 'g@'
endfunction

let s:device_cache = []
let s:device_cache_at = 0

function! cinch#complete_devices(arg, line, pos) abort
  if localtime() - s:device_cache_at > 30
    let l:out = system(g:cinch_binary . ' devices --names')
    if v:shell_error == 0
      let s:device_cache = filter(split(l:out, "\n"), 'v:val !=# ""')
      let s:device_cache_at = localtime()
    endif
  endif
  return filter(copy(s:device_cache), 'v:val =~? "^" . a:arg')
endfunction
