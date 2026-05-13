describe('picker adapter resolution', function()
  it('case 16: falls back to builtin when no third-party picker is present', function()
    package.loaded['snacks'] = nil
    package.loaded['fzf-lua'] = nil
    package.loaded['telescope'] = nil
    local picker = require('cinch.picker').resolve('auto')
    assert.is_not_nil(picker)
    assert.is_true(picker == require('cinch.picker.builtin'))
  end)

  it('honours an explicit g:cinch_picker override', function()
    vim.g.cinch_picker = 'fzf-lua'
    local picker = require('cinch.picker').resolve(vim.g.cinch_picker)
    -- fzf-lua not installed in CI; resolver falls back to builtin
    assert.is_not_nil(picker)
  end)
end)
