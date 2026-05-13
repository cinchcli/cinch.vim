local data = require('cinch.data')

local M = {}

function M.available()
  local ok, snacks = pcall(require, 'snacks')
  return ok and snacks and snacks.picker ~= nil
end

local function row(c)
  local source = c.source or 'unknown'
  if c.content_type == 'image' then
    return ('[image · %s B]  [%s]'):format(c.byte_size or 0, source)
  end
  return ((c.content or ''):match('([^\n]*)') or '') .. '  [' .. source .. ']'
end

function M.open(opts)
  opts = opts or {}
  local snacks = require('snacks')
  local clips = data.list({ limit = opts.limit or 50, source = opts.source }) or {}
  local items = {}
  for _, c in ipairs(clips) do
    table.insert(items, { text = row(c), clip = c })
  end
  snacks.picker.pick({
    items = items,
    format = function(item) return item.text end,
    confirm = function(picker, item)
      picker:close()
      if item and item.clip then
        vim.fn.setreg(vim.g.cinch_push_register or '"', item.clip.content or '')
        vim.cmd('normal! p')
      end
    end,
  })
end

return M
