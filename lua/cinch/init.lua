local data = require('cinch.data')

local M = {}

local function default_register()
  return vim.g.cinch_push_register or '"'
end

function M.push(opts)
  opts = opts or {}
  local text = opts.text
  if text == nil then text = vim.fn.getreg(opts.register or default_register()) end
  vim.fn['cinch#push'](text)
end

function M.pull(opts)
  opts = opts or {}
  local args = {}
  if opts.from then args.from = opts.from end
  if opts.register then args.register = opts.register end
  if opts.exclude_self ~= nil then args.exclude_self = opts.exclude_self end
  return vim.fn['cinch#pull'](args)
end

function M.pick(opts)
  opts = opts or {}
  local picker_name = vim.g.cinch_picker or 'auto'
  local picker = require('cinch.picker').resolve(picker_name)
  if picker then picker.open(opts) end
end

function M.toggle()
  vim.cmd('CinchToggle')
end

function M.status()
  local r = data.run({ 'auth', 'status' })
  local authed = r.code == 0 and r.stdout:find('logged in') ~= nil
  local relay = r.stdout:match('relay:%s*(%S+)') or ''
  return {
    authed = authed,
    relay = relay,
    default_source = vim.g.cinch_default_source or '',
    last_push = vim.g.cinch_last_push or {},
    last_pull = vim.g.cinch_last_pull or {},
    auto_push = vim.g.cinch_auto_push == 1,
  }
end

return M
