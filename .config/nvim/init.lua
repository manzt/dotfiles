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

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Toggle buffers
vim.keymap.set("n", "<leader><leader>", "<c-^>")

-- Copy clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", "\"*y")

vim.keymap.set('n', '<leader>cfp', function()
  vim.fn.setreg('+', vim.fn.expand('%:p'))
end, { desc = 'Copy current file path to clipboard' })

-- Jump to last position in the file
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local row, col = unpack(vim.api.nvim_buf_get_mark(0, "\""))
    if { row, col } ~= { 0, 0 } then
      vim.api.nvim_win_set_cursor(0, { row, col })
    end
  end,
})

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
  -- Delete, change, add surrounding pairs
  "tpope/vim-surround",
  -- Detect tabstop and shiftwidth automatically
  "tpope/vim-sleuth",
  { -- Fuzzy Finder (files, lsp, etc)
    "nvim-telescope/telescope.nvim",
    event = 'VimEnter',
    -- branch = '0.1.x',
    commit = "b4da76b",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable "make" == 1
        end,
      },
      {
        "nvim-tree/nvim-web-devicons",
        enabled = vim.g.have_nerd_font
      },
    },
    config = function()
      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      -- See `:help telescope.builtin`
      local builtin = require "telescope.builtin"
      vim.keymap.set("n", "<C-p>", function()
        local opts = {} -- define here if you want to define something

        -- Check if we are in a Git directory, but not if the `.git` directory is $HOME
        local is_home_git = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "") == vim.env.HOME

        if not is_home_git then
          local ok = pcall(builtin.git_files, opts)
          if not ok then
            builtin.find_files(opts)
          end
        else
          builtin.find_files(opts)
        end
      end)

      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[S]earch Recent Files (\".\" for repeat)" })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set("n", "<leader>/", function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = "[/] Fuzzily search in current buffer" })

      -- It"s also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set("n", "<leader>s/", function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        }
      end, { desc = "[S]earch [/] in Open Files" })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set("n", "<leader>sn", function()
        builtin.find_files { cwd = vim.fn.stdpath "config" }
      end, { desc = "[S]earch [N]eovim files" })

      -- Shortcut to edit dotfiles
      vim.keymap.set("n", "<leader>ed", function()
        builtin.git_files { cwd = "~" }
      end, { desc = "[E]dit [D]otfiles" })
    end,
  },
  -- LSP Stuff
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { "williamboman/mason.nvim", opts = {} },
      "williamboman/mason-lspconfig.nvim",
      -- Useful status updates for LSP
      { "j-hui/fidget.nvim",       opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Navigation
          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
          map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
          map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
          map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
          map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

          -- LSP actions
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

          -- Lesser used LSP functionality
          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- Format the current buffer
          map("<leader>f", vim.lsp.buf.format, "[F]ormat");

          -- Hover diagnostic
          map("<leader>ee", vim.diagnostic.open_float, "Hover [E]rrors")

          -- Document hover
          map("K", function()
            vim.lsp.buf.hover({ border = "rounded", max_height = 25, max_width = 120 })
          end, "Document hover")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = "if_many",
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }
      require("mason").setup()
      require("mason-lspconfig").setup()

      local function capabilities(server)
        local base = require("blink.cmp").get_lsp_capabilities(
          vim.lsp.protocol.make_client_capabilities()
        )
        if server == nil then
          return base
        end
        return vim.tbl_deep_extend(
          "force",
          vim.lsp.config[server] and vim.lsp.config[server].capabilities or {},
          base
        )
      end

      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities("rust_analyzer"),
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = { command = "clippy" },
            files = { excludeDirs = { ".venv", "node_modules" } },
          }
        }
      })
      vim.lsp.config("lua_ls", {
        capabilities = capabilities("lua_ls"),
      })
      vim.lsp.config("denols", {
        capabilities = capabilities("denols"),
        single_file_support = false,
        workspace_required = true,
        root_markers = { "deno.json", "deno.jsonc", "deno.lock" }
      })
      vim.lsp.config("ts_ls", {
        capabilities = capabilities("ts_ls"),
        single_file_support = false,
        workspace_required = true,
        root_markers = {
          "pnpm-lock.yaml",
          "yarn.lock",
          "package-lock.json",
          "bun.lock",
          "tsconfig.json",
          "jsconfig.json",
          "package.json",
        }
      })
      vim.lsp.config("basedpyright", {
        capabilities = capabilities("basedpyright"),
        settings = {
          basedpyright = {
            typeCheckingMode = "standard",
          },
          python = {
            venvPath = ".venv",
            pythonPath = ".venv/bin/python",
            -- analysis = { diagnosticMode = "off", typeCheckingMode = "off" },
          }
        },
      })
      vim.lsp.config("tombi", {
        cmd = { "uvx", "tombi", "lsp" },
        filetypes = { "toml" },
        single_file_support = true,
      });
      vim.lsp.enable("tombi")
    end
  },
  {
    "saghen/blink.cmp",
    dependencies = "rafamadriz/friendly-snippets",
    version = "*",
    opts = {
      keymap = { preset = "default" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          -- Fixes really annoying behavior where "buffer" sources are ignored
          -- when LSP is attached enabled.
          lsp = { fallbacks = {} }
        }
      },
    },
    opts_extend = { "sources.default" }
  },
  { -- Treesitter, syntax highlighting, text objects
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-context", opts = { max_lines = 1 } },
    },
    config = function()
      pcall(require("nvim-treesitter.install").update { with_sync = true })
      require("nvim-treesitter.configs").setup {
        ensure_installed = { 'typescript', 'python', 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
        highlight = {
          enable = true,
          -- disable slow treesitter highlight for large files
          disable = function(_, buf)
            local max_filesize = 300 * 1024 -- 300 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },
        indent = { enable = true },
      }
    end,
  },
  { -- Highlight todo, notes, etc in comments
    "folke/todo-comments.nvim",
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false }
  },
  { -- Nice status line
    "stevearc/dressing.nvim",
    opts = {},
  },
  { -- Theme
    "catppuccin/nvim",
    lazy = false,
    config = function()
      vim.cmd.colorscheme "catppuccin"
    end
  },
  { -- Open files on GitHub in browser
    "almo7aya/openingh.nvim",
    keys = {
      { "<leader>gh", ":OpenInGHFile <CR>",      mode = "n" },
      { "<leader>gh", ":OpenInGHFileLines <CR>", mode = "v" }
    }
  },
  { -- Update deps in Cargo.toml
    "saecki/crates.nvim",
    tag = "stable",
    opts = {},
  },
  {
    -- Fancy git log viewer
    "rbong/vim-flog",
    lazy = true,
    cmd = { "Flog", "Flogsplit", "Floggit" },
    dependencies = { "tpope/vim-fugitive" },
    keys = { { "<leader>l", ":Flog<CR>" } }
  },
  { -- nice icons
    "nvim-tree/nvim-web-devicons"
  },
  { -- edit files
    "stevearc/oil.nvim",
    event = { "VimEnter */*,.*", "BufNew */*,.*" },
    opts = {
      default_file_explorer = true,
    },
    keys = { { "-", ":Oil<CR>" } }
  },
  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup()
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },
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
  local response = client:request_sync("deno/virtualTextDocument",
    { textDocument = { uri = actual_path } },
    2000,
    0
  )
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
-- require("learn-lsp").setup()
