local M = {}

M.setup = function()
  vim.lsp.config("learn_lsp", {
    cmd = { 'deno', 'run', '-A', '/Users/manzt/demos/learn-lsp/server/main.ts' },
    filetypes = { 'markdown' },
    single_file_support = true,
  });
  vim.lsp.enable("learn_lsp")
end

return M
