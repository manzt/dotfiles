-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Setting options ]]
-- See `:help vim.opt`

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.numberwidth = 4

-- Enable mouse mode
vim.o.mouse = "a"

-- Don"t show the mode, since it"s already in status line
vim.opt.showmode = false

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.wo.list = true
vim.opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Keep more context when scrolling
vim.o.scrolloff = 10

-- Set :substitute flag to g, so that it replaces all occurrences in a line
vim.o.gdefault = true

-- set tabstop
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Disable line wrapping
vim.o.wrap = false

-- For deno formatting ts blocks correctly
vim.g.markdown_fenced_languages = {
  "ts=typescript"
}

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`

-- Toggle buffers
vim.keymap.set("n", "<leader><leader>", "<c-^>")

-- Copy clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", "\"*y")

-- Jump to last position in the file
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local row, col = unpack(vim.api.nvim_buf_get_mark(0, "\""))
    if { row, col } ~= { 0, 0 } then
      vim.api.nvim_win_set_cursor(0, { row, col })
    end
  end,
})

-- for vim-flog, show the git log
vim.keymap.set("n", "<leader>l", ":Flog<CR>")

-- Open oil.nvim
vim.keymap.set("n", "-", ":Oil<CR>")


-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "cappuccin" } },
  checker = { enabled = true },
})

-- Work around to get Deno virtual LSP locations working
-- https://github.com/neovim/neovim/issues/30908#issuecomment-2583300661
local function virtual_text_document(params)
  local bufnr = params.buf
  local actual_path = params.match:sub(1)

  local clients = vim.lsp.get_clients({ name = "denols" })
  if #clients == 0 then
    return
  end

  local client = clients[1]
  local method = "deno/virtualTextDocument"
  local req_params = { textDocument = { uri = actual_path } }
  local response = client:request_sync(method, req_params, 2000, 0)
  if not response or type(response.result) ~= "string" then
    return
  end

  local lines = vim.split(response.result, "\n")
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_set_option_value("readonly", true, { buf = bufnr })
  vim.api.nvim_set_option_value("modified", false, { buf = bufnr })
  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
  vim.api.nvim_buf_set_name(bufnr, actual_path)
  vim.lsp.buf_attach_client(bufnr, client.id)

  local filetype = "typescript"
  if actual_path:sub(-3) == ".md" then
    filetype = "markdown"
  end
  vim.api.nvim_set_option_value("filetype", filetype, { buf = bufnr })
end

-- DENO. To appropriately highlight codefences returned from denols
vim.g.markdown_fenced_languages = { "ts=typescript" }
vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
  pattern = { "deno:/*" },
  callback = virtual_text_document,
})

-- Custom language servers ...
require("learn-lsp").setup()
-- require("red-knot").setup()
