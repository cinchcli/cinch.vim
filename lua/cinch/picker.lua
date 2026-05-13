local M = {}

local ADAPTERS = { 'snacks', 'fzf_lua', 'telescope', 'builtin' }

local function load_safe(name)
  local ok, mod = pcall(require, 'cinch.picker.' .. name)
  return ok and mod or nil
end

function M.resolve(pref)
  pref = pref or 'auto'
  if pref ~= 'auto' then
    local mod = load_safe(pref:gsub('-', '_'))
    if mod then return mod end
    return load_safe('builtin')
  end
  for _, name in ipairs(ADAPTERS) do
    local mod = load_safe(name)
    if mod and mod.available() then return mod end
  end
  return load_safe('builtin')
end

return M
