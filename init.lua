local bin_path = vim.fn.expand("~/.config/nvim/bin/node_modules/.bin")
vim.env.PATH = bin_path .. ":" .. vim.env.PATH

-- The 'termguicolors' option is false in init.lua; it is updated asynchronously after truecolor detection.
-- Enable it here so colorschemes use truecolor from the start.
vim.opt.termguicolors = true

-- gutter
vim.opt.number = true
vim.opt.signcolumn = 'yes'

vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'noinsert', 'popup' }

vim.lsp.config.typescript = {
  init_options = { hostInfo = 'neovim' },
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  root_markers = {
     { 'package-lock.json', 'yarn.lock' },
     { '.git' },
  },
  on_attach = function (client, bufnr)
    vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = false })
  end,
}

vim.lsp.enable('typescript')

local function fzf(callback)
  local listed = false
  local scratch = true
  local buffer_id = vim.api.nvim_create_buf(listed, scratch)
  if buffer_id == 0 then
    callback(nil, 'failed to create scratch buffer')
    return
  end
  
  local enter = true
  local window_id = vim.api.nvim_open_win(buffer_id, enter, { split = 'below' })
  if window_id == 0 then
    callback(nil, 'failed to create split window')
    return
  end

  local job_id = vim.fn.jobstart({ 'fzf' }, {
    term = true,
    on_exit = function() 
      local line = 0
      local strict = false
      local lines = vim.api.nvim_buf_get_lines(buffer_id, line, line + 1, strict)

      vim.api.nvim_buf_delete(buffer_id, { force = true })

      if #lines == 0 then
        callback(nil, 'failed to read lines')
        return
      end

      local result = lines[1]
      callback(result, nil)
    end 
  })

  if job_id <= 0 then
    callback(nil, 'failed to start job')
    return
  end

  vim.cmd.startinsert()
end

local function find()
  fzf(function(result, error)
    if error ~= nil then
      return
    end

    if result == "" then 
      return
    end

    local name = vim.fn.fnameescape(result)
    vim.cmd.edit(name)
  end)
end

vim.api.nvim_create_user_command("Find", find, {})
vim.keymap.set('n', '<Leader>f', '<Cmd>Find<CR>')
