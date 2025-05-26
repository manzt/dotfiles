local M = {}

M.setup = function()
  vim.lsp.config("ty", {
    cmd = { "uvx", "ty", "server" },
    filetypes = { "python" },
    single_file_support = true,
  });
  vim.lsp.enable("ty")
end

return M
