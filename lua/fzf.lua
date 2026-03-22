local M = {}

local function create_split()
  local listed = false
  local scratch = true
  local ok, buffer_id = pcall(vim.api.nvim_create_buf, listed, scratch)
  if not ok or buffer_id == 0 then
    return nil, 'failed to create scratch buffer'
  end
  
  local enter = true
  local ok, window_id = pcall(vim.api.nvim_open_win, buffer_id, enter, { split = 'below' })
  if not ok or window_id == 0 then
	  vim.api.nvim_buf_delete(buffer_id, { force = true })
    return nil, 'failed to create split window'
  end

  local function cleanup() 
    if vim.api.nvim_win_is_valid(window_id) then
      vim.api.nvim_win_close(window_id, true)
    end

    if vim.api.nvim_buf_is_valid(buffer_id) then
      vim.api.nvim_buf_delete(buffer_id, { force = true })
    end
  end

  return { buffer_id = buffer_id, window_id = window_id, cleanup = cleanup }, nil
end

local function process_stdout(buffer_id, exit_code)
  local SIGINT = 130
  if exit_code == SIGINT then
    return nil, nil
  end

  if exit_code ~= 0 then
    return nil, string.format('process exited with code %d', exit_code)
  end

  local line = 0
  local strict = false
  local ok, lines = pcall(vim.api.nvim_buf_get_lines, buffer_id, line, line + 1, strict)

  if not ok or #lines == 0 then
    return nil, 'failed to read lines'
  end

  local result = lines[1]
  return result, nil
end

local function fzf(callback)
  local split, error = create_split()
  if split == nil then
    callback(nil, error)
    return
  end

  local job_id = vim.fn.jobstart({ 'fzf' }, {
    term = true,
    on_exit = function(_job_id, exit_code, _event_type) 
      local result, error = process_stdout(split.buffer_id, exit_code)
      split.cleanup()
      callback(result, error)
    end 
  })

  if job_id <= 0 then
    split.cleanup()
    callback(nil, 'failed to start job')
    return
  end

  vim.cmd.startinsert()
end

local function find()
  fzf(function(result, error)
    if error ~= nil then
      vim.notify(error, vim.log.levels.ERROR)
      return
    end

    if result == "" or result == nil then 
      return
    end

    local name = vim.fn.fnameescape(result)
    vim.cmd.edit(name)
  end)
end

M.find = find

return M
