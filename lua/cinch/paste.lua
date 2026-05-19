local M = {}

-- Paste a clip selected from a history picker into the current buffer.
-- Handles image clips (which have no text payload) and empty content so the
-- caller never invokes `normal! p` on an empty register (E353).
function M.clip(clip)
  if not clip then return end
  if clip.content_type == 'image' then
    vim.notify('[cinch] image clips cannot be pasted into a text buffer',
      vim.log.levels.WARN)
    return
  end
  local content = clip.content or ''
  if content == '' then
    vim.notify('[cinch] clip is empty — nothing to paste',
      vim.log.levels.WARN)
    return
  end
  local reg = vim.g.cinch_push_register or '"'
  vim.fn.setreg(reg, content)
  if reg == '"' then
    vim.cmd('normal! p')
  else
    vim.cmd('normal! "' .. reg .. 'p')
  end
end

return M
