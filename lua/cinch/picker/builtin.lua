local data = require('cinch.data')

local M = {}

function M.available() return true end

local function format_row(c)
  local source = c.source or 'unknown'
  local first_line = (c.content_type == 'image')
    and string.format('[image · %s bytes]', c.byte_size or 0)
    or ((c.content or ''):match('([^\n]*)') or '')
  return string.format('%-12s [%s]  %s', '?', source, first_line)
end

function M.open(opts)
  opts = opts or {}
  local clips = data.list({ limit = opts.limit or 50, source = opts.source }) or {}
  local lines = {}
  for _, c in ipairs(clips) do table.insert(lines, format_row(c)) end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local width = math.min(120, vim.o.columns - 6)
  local height = math.min(20, math.max(3, #lines + 1))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor', row = 2, col = 2,
    width = width, height = height, style = 'minimal', border = 'rounded',
  })
  vim.bo[buf].bufhidden = 'wipe'
  vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<CR>', function()
    local idx = vim.api.nvim_win_get_cursor(win)[1]
    local clip = clips[idx]
    if clip then
      vim.fn.setreg(vim.g.cinch_push_register or '"', clip.content or '')
      vim.cmd('close')
      vim.cmd('normal! p')
    end
  end, { buffer = buf, silent = true })
end

return M
