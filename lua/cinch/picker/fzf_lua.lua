local data = require('cinch.data')
local paste = require('cinch.paste')

local M = {}

function M.available()
  return pcall(require, 'fzf-lua')
end

local function row(c)
  local id = c.clip_id or '?'
  local source = c.source or 'unknown'
  local first = (c.content_type == 'image')
    and ('[image · ' .. (c.byte_size or 0) .. ' B]')
    or ((c.content or ''):match('([^\n]*)') or '')
  return id .. '\t' .. ('[' .. source .. '] ' .. first)
end

function M.open(opts)
  opts = opts or {}
  local fzf = require('fzf-lua')
  local clips = data.list({ limit = opts.limit or 50, source = opts.source }) or {}
  local by_id = {}
  local entries = {}
  for _, c in ipairs(clips) do
    by_id[c.clip_id or '?'] = c
    table.insert(entries, row(c))
  end
  fzf.fzf_exec(entries, {
    prompt = 'cinch> ',
    actions = {
      ['default'] = function(selected)
        local id = (selected and selected[1] or ''):match('^(%S+)')
        local c = by_id[id]
        if c then
          paste.clip(c)
        end
      end,
    },
  })
end

return M
