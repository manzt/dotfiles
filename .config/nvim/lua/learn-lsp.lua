local M = {}

M.setup = function()
  local lspconfig = require 'lspconfig'
  local configs = require 'lspconfig.configs'

  if not configs.marimo then
    configs.marimo = {
      default_config = {
        cmd = { 'deno', 'run', '-A', '/Users/manzt/demos/learn-lsp/server.ts' },
        root_dir = lspconfig.util.root_pattern('.git'),
        filetypes = { 'markdown' },
      },
    }
  end

  lspconfig.marimo.setup {}
end

return M
