local M = {}
local uv = vim.loop

local function read_pipe(pipe, into)
  pipe:read_start(function(_, chunk)
    if chunk then table.insert(into, chunk) end
  end)
end

function M.run(args, stdin)
  local bin = vim.g.cinch_binary or 'cinch'
  local stdout, stderr = {}, {}
  local stdout_pipe = uv.new_pipe(false)
  local stderr_pipe = uv.new_pipe(false)
  local stdin_pipe = stdin and uv.new_pipe(false) or nil

  local code = -1
  local done = false
  local handle
  handle = uv.spawn(bin, {
    args = args,
    stdio = { stdin_pipe, stdout_pipe, stderr_pipe },
  }, function(c) code = c; done = true; if handle then handle:close() end end)

  if not handle then
    if stdin_pipe then stdin_pipe:close() end
    stdout_pipe:close(); stderr_pipe:close()
    return { code = -1, stdout = '', stderr = bin .. ': spawn failed' }
  end

  read_pipe(stdout_pipe, stdout)
  read_pipe(stderr_pipe, stderr)
  if stdin_pipe then
    stdin_pipe:write(stdin, function()
      stdin_pipe:shutdown(function() stdin_pipe:close() end)
    end)
  end

  vim.wait(5000, function() return done end, 20)
  return { code = code, stdout = table.concat(stdout), stderr = table.concat(stderr) }
end

function M.parse_list(json_text)
  local ok, value = pcall(vim.json.decode, json_text)
  if not ok or type(value) ~= 'table' then return {} end
  return value
end

function M.list(opts)
  opts = opts or {}
  local args = { 'list', '--json', '--limit', tostring(opts.limit or 50) }
  if opts.source then
    table.insert(args, '--from')
    table.insert(args, opts.source)
  end
  local r = M.run(args)
  if r.code ~= 0 then return nil, r.stderr end
  return M.parse_list(r.stdout)
end

function M.pull_by_id(id)
  local r = M.run({ 'pull', '--id', id, '--raw' })
  if r.code ~= 0 then return nil, r.stderr end
  return r.stdout
end

return M
