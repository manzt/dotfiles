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
vim.o.scrolloff = 3

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
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Toggle buffers
vim.keymap.set("n", "<leader><leader>", "<c-^>")

-- Copy clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", "\"*y")

-- Open current file with default app
vim.keymap.set("n", "<leader>x", ":!open %<CR>")

-- avante.nivm: views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3


-- Jump to last position in the file
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local row, col = unpack(vim.api.nvim_buf_get_mark(0, "\""))
    if { row, col } ~= { 0, 0 } then
      vim.api.nvim_win_set_cursor(0, { row, col })
    end
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- for vim-flog, show the git log
vim.keymap.set("n", "<leader>l", ":Flog<CR>")

require("lazy").setup({
  -- Delete, change, add surrounding pairs
  "tpope/vim-surround",
  -- Detect tabstop and shiftwidth automatically
  "tpope/vim-sleuth",

  { -- Fuzzy Finder (files, lsp, etc)
    "nvim-telescope/telescope.nvim",
    event = 'VimEnter',
    -- branch = '0.1.x',
    commit = "2eca9ba",
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
        local ok = pcall(builtin.git_files, opts)
        if not ok then builtin.find_files(opts) end
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
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
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

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end
      })

      --  Add any additional overrides configuration in the following tables. They will be
      --  merged with the `capabilities` and `on_attach` parameters.
      local servers = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = {
                command = "clippy",
              },
              files = {
                excludeDirs = { ".venv", "node_modules" }
              },
            }
          }
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              diagnostics = { disable = { "missing-fields" } },
            },
          },
        },
        -- Workaround so that deno and tsserver don't conflict. We prefer deno for single file mode.
        denols = {
          root_dir = require("lspconfig").util.root_pattern("mod.ts", "deno.json", "deno.jsonc"),
          single_file_support = true,
        },
        ts_ls = {
          single_file_support = false,
          root_dir = function(fname)
            local deno_root = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc")(fname)
            if deno_root then return nil end
            return require("lspconfig").util.root_pattern("package.json")(fname)
          end,
        },
        pyright = {
          settings = {
            python = {
              venvPath = ".venv",
              pythonPath = ".venv/bin/python",
            }
          },
        },
      }
      require("mason").setup()
      require("mason-lspconfig").setup({
        automatic_installation = false,
        ensure_installed = {},
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force",
              {},
              require("blink.cmp").get_lsp_capabilities(
                vim.lsp.protocol.make_client_capabilities()
              ),
              server.capabilities or {}
            )
            require("lspconfig")[server_name].setup(server)
          end
        }
      })
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
        cmdline = {}, -- disable autocomplete for cmdline
      },
    },
    opts_extend = { "sources.default" }
  },
  { -- Treesitter, syntax highlighting, text objects
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-context", opts = { max_lines = 1 } },
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      pcall(require("nvim-treesitter.install").update { with_sync = true })
      vim.keymap.set("n", "<leader>tc", ":TSContextToggle<CR>", { desc = "[T]oggle [C]ontext" })
      require("nvim-treesitter.configs").setup {
        -- Add languages to be installed here that you want installed for treesitter
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
    -- "olivercederborg/poimandres.nvim",
    -- "EdenEast/nightfox.nvim",
    -- "yorickpeterse/vim-paper",
    "catppuccin/nvim",
    -- "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme "poimandres"
      -- vim.cmd.colorscheme "dawnfox"
      -- vim.cmd.colorscheme "paper"
      vim.cmd.colorscheme "catppuccin"
      -- vim.cmd.colorscheme "tokyonight"
    end
  },
  { -- Open files on GitHub in browser
    "almo7aya/openingh.nvim",
    config = function()
      --  Open in lines on GitHub in browser
      vim.keymap.set("n", "<leader>gh", ":OpenInGHFile <CR>", { silent = true, noremap = true })
      vim.keymap.set("v", "<leader>gh", ":OpenInGHFileLines <CR>", { silent = true, noremap = true })
    end
  },
  { -- Update deps in Cargo.toml
    "saecki/crates.nvim",
    tag = "stable",
    config = function()
      require("crates").setup({})
    end,
  },
  {
    -- Fancy git log viewer
    "rbong/vim-flog",
    lazy = true,
    cmd = { "Flog", "Flogsplit", "Floggit" },
    dependencies = { "tpope/vim-fugitive" },
  },
  { -- nice icons
    "nvim-tree/nvim-web-devicons"
  },
  { -- edit files
    "stevearc/oil.nvim",
    opts = {},
  }
})

-- To appropriately highlight codefences returned from denols, you
-- will need to augment vim.g.markdown_fenced languages in your init.lua.
vim.g.markdown_fenced_languages = {
  "ts=typescript"
}
