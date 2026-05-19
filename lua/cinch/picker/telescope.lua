local data = require('cinch.data')
local paste = require('cinch.paste')

local M = {}

function M.available()
  return pcall(require, 'telescope')
end

function M.open(opts)
  opts = opts or {}
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local clips = data.list({ limit = opts.limit or 50, source = opts.source }) or {}
  pickers.new({}, {
    prompt_title = 'cinch history',
    finder = finders.new_table({
      results = clips,
      entry_maker = function(c)
        local first = (c.content_type == 'image')
          and ('[image · ' .. (c.byte_size or 0) .. ' B]')
          or ((c.content or ''):match('([^\n]*)') or '')
        return {
          value = c,
          ordinal = first .. ' ' .. (c.source or ''),
          display = string.format('[%s] %s', c.source or '?', first),
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if entry and entry.value then
          paste.clip(entry.value)
        end
      end)
      return true
    end,
  }):find()
end

return M
