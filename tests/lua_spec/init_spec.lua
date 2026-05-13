describe('cinch (public API)', function()
  local cinch

  before_each(function()
    package.loaded['cinch'] = nil
    cinch = require('cinch')
  end)

  it('case 13: push invokes CLI once with stdin', function()
    cinch.push({ text = 'payload' })
    -- push is async — wait for the autoload's on_exit to land
    local ok = vim.wait(2000, function()
      return vim.g.cinch_last_push and vim.g.cinch_last_push.status == 'ok'
    end, 50)
    assert.is_true(ok, 'push did not complete: ' .. vim.inspect(vim.g.cinch_last_push))
    local log = table.concat(vim.fn.readfile(os.getenv('CINCH_TEST_DIR') .. '/calls.log'), '\n')
    assert.is_true(log:find('push') ~= nil)
    assert.is_true(log:find('payload') ~= nil)
  end)

  it('case 14: pull from desktop returns fixture text', function()
    local text = cinch.pull({ from = 'desktop' })
    assert.is_truthy(text)
    assert.is_true(text:find('hello from the fake relay') ~= nil)
  end)

  it('case 15: status returns a table with the expected keys', function()
    local s = cinch.status()
    for _, k in ipairs({ 'authed', 'relay', 'default_source', 'last_push', 'last_pull', 'auto_push' }) do
      assert.is_not_nil(s[k], 'missing key: ' .. k)
    end
  end)

  it('builtin picker opens a floating window with one line per fixture clip', function()
    vim.g.cinch_picker = 'builtin'
    require('cinch').pick({})
    local wins = vim.api.nvim_list_wins()
    local found_float = false
    for _, w in ipairs(wins) do
      local cfg = vim.api.nvim_win_get_config(w)
      if cfg.relative ~= '' then
        found_float = true
        local buf = vim.api.nvim_win_get_buf(w)
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        assert.are.equal(2, #lines, 'expected 2 fixture rows, got ' .. #lines)
      end
    end
    assert.is_true(found_float, 'expected at least one floating picker window')
    vim.cmd('close!')
  end)
end)
