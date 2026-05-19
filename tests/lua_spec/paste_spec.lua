describe('cinch.paste', function()
  local paste

  before_each(function()
    package.loaded['cinch.paste'] = nil
    paste = require('cinch.paste')
    -- Fresh buffer per test so register state is observable in isolation.
    vim.cmd('enew!')
    vim.fn.setreg('"', '')
    vim.fn.setreg('+', '')
    vim.fn.setreg('a', '')
    vim.g.cinch_push_register = '"'
  end)

  it('pastes a text clip into the current buffer via the default register', function()
    paste.clip({ content_type = 'text', content = 'hello world' })
    assert.are.equal('hello world', table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'))
    assert.are.equal('hello world', vim.fn.getreg('"'))
  end)

  it('honours a custom g:cinch_push_register when pasting (regression: paste read wrong reg)', function()
    vim.g.cinch_push_register = 'a'
    paste.clip({ content_type = 'text', content = 'from register a' })
    assert.are.equal('from register a', table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'))
    assert.are.equal('from register a', vim.fn.getreg('a'))
  end)

  it('does not crash on an empty clip (regression: E353 Nothing in register)', function()
    -- The pre-fix code called `normal! p` on an empty register and threw E353.
    local ok = pcall(paste.clip, { content_type = 'text', content = '' })
    assert.is_true(ok)
    -- Buffer remains unchanged.
    assert.are.equal('', table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'))
  end)

  it('does not crash on an image clip', function()
    local ok = pcall(paste.clip, { content_type = 'image', content = '', byte_size = 1024 })
    assert.is_true(ok)
    assert.are.equal('', table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'))
  end)

  it('returns silently when given nil', function()
    local ok = pcall(paste.clip, nil)
    assert.is_true(ok)
  end)
end)
