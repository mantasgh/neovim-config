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

vim.api.nvim_create_user_command("Find", require('fzf').find, {})
vim.keymap.set('n', '<Leader>f', '<Cmd>Find<CR>')
