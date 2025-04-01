local M = {}

M.setup = function()
  local lspconfig = require 'lspconfig'
  local configs = require 'lspconfig.configs'

  if not configs.red_knot then
    configs.red_knot = {
      default_config = {
        cmd = { '/Users/manzt/demos/ruff/target/release/red_knot', 'server' },
        root_dir = lspconfig.util.root_pattern('pyproject.toml', '.git'),
        filetypes = { 'python' },
      },
    }
  end

  lspconfig.red_knot.setup {}
end

return M


