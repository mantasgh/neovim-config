local bin_path = vim.fn.expand("~/.config/nvim/bin/node_modules/.bin")
vim.env.PATH = bin_path .. ":" .. vim.env.PATH

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
