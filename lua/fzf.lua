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

  return { buffer_id = buffer_id, window_id = window_id }, nil
end

local function fzf(callback)
  local split, error = create_split()
  if split == nil then
    callback(nil, error)
    return
  end

  local function cleanup() 
    if vim.api.nvim_win_is_valid(split.window_id) then
      vim.api.nvim_win_close(split.window_id, true)
    end

    if vim.api.nvim_buf_is_valid(split.buffer_id) then
      vim.api.nvim_buf_delete(split.buffer_id, { force = true })
    end
  end

  local job_id = vim.fn.jobstart({ 'fzf' }, {
    term = true,
    on_exit = function(_job_id, exit_code, _event_type) 
      local SIGINT = 130
      if exit_code == SIGINT then
	      cleanup()
	      callback(nil, nil)
        return
      end

      if exit_code ~= 0 then
        cleanup()
        callback(nil, string.format('process exited with code %d', exit_code))
        return
      end

      local line = 0
      local strict = false
      local ok, lines = pcall(vim.api.nvim_buf_get_lines, split.buffer_id, line, line + 1, strict)
      
      if not ok or #lines == 0 then
        cleanup()
        callback(nil, 'failed to read lines')
        return
      end

      local result = lines[1]
      cleanup()
      callback(result, nil)
    end 
  })

  if job_id <= 0 then
    cleanup()
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
