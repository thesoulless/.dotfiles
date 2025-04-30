--[[ Helper functions ]]
local function get_breakpoints_path()
  local bp_path = os.getenv("HOME") .. '/.cache/dap/breakpoints.json'
  return bp_path
end


local function open_file(fpath, mode)
  local fp = io.open(fpath, mode)
  assert(fp, "Couldn't open file " .. fpath)
  return fp
end


local function get_buffer_number(fpath)
  local bufnr = vim.fn.bufnr(fpath, true)
  -- Load the file if it wasn't loaded by the session
  if vim.fn.bufloaded(bufnr) == 0 then
    vim.api.nvim_buf_call(bufnr, vim.cmd.edit)
  end
  return bufnr
end


--[[ Module functions ]]
local M = {}

function M.save_session_breakpoints()
  local savepath = get_breakpoints_path()
  local Breakpoints = require('dap.breakpoints')
  local breakpoints_by_buf = Breakpoints.get()

  if vim.tbl_isempty(breakpoints_by_buf)  then
    -- If there's no breakpoints but the breakpoint file exists,
    -- erase the file
    if vim.fn.filereadable(savepath) > 0 then
      vim.fn.delete(savepath)
    end
    return nil
  end

  -- Map breakpoints to corresponding file
  local breakpoints_by_file = {}
  for buf, buf_bps in pairs(breakpoints_by_buf) do
    local fname = vim.api.nvim_buf_get_name(buf)
    breakpoints_by_file[fname] = buf_bps
  end

  -- Save breakpoints
  local fp = open_file(savepath, 'w')
  fp:write(vim.fn.json_encode(breakpoints_by_file))
  fp:close()
  vim.notify("Saved breakpoints: " .. savepath)
end


function M.restore_session_breakpoints()
  local bp_path = get_breakpoints_path()
  -- If no breakpoints file, there's nothing to do
  if vim.fn.filereadable(bp_path) == 0 then
    return nil
  end
  local fp = open_file(bp_path, 'r')
  local content = fp:read('*a')
  local breakpoints_by_file = vim.fn.json_decode(content)
  fp:close()

  local Breakpoints = require('dap.breakpoints')
  for fname, breakpoints in pairs(breakpoints_by_file) do
    local bufnr = get_buffer_number(fname)
    for _, bp in pairs(breakpoints) do
      local line = bp.line
      local opts = {
        condition = bp.condition,
        log_message = bp.logMessage,
        hit_condition = bp.hitCondition
      }
      Breakpoints.set(opts, bufnr, line)
    end
  end
end


function M.delete_session_breakpoints()
  local bp_path = get_breakpoints_path()
  vim.fn.delete(bp_path)
end


return M
