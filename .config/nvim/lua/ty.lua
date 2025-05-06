local M = {}

M.setup = function()
  vim.lsp.config("ty", {
    cmd = { "/Users/manzt/github/astral-sh/ruff/target/release/ty", "server" },
    filetypes = { 'python' },
    single_file_support = true,
  });
  vim.lsp.enable("ty")
end

return M
