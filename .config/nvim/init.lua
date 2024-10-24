-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Setting options ]]
-- See `:help vim.opt`

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.numberwidth = 4

-- Enable mouse mode
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

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
vim.opt.listchars = { tab = '→ ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Keep more context when scrolling
vim.o.scrolloff = 3

-- Set :substitute flag to g, so that it replaces all occurrences in a line
vim.o.gdefault = true

-- set tabstop
vim.o.tabstop = 4

-- Disable line wrapping
vim.o.wrap = false

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Toggle buffers
vim.keymap.set('n', '<leader><leader>', '<c-^>')

-- Copy clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"*y')

-- Open current file with default app
vim.keymap.set('n', '<leader>x', ':!open %<CR>')

-- avante.nivm: views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3

-- Jump to last position in the file
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local row, col = unpack(vim.api.nvim_buf_get_mark(0, "\""))
    if { row, col } ~= { 0, 0 } then
      vim.api.nvim_win_set_cursor(0, { row, col })
    end
  end,
})

-- Diagnostic keymaps
vim.diagnostic.config {
  virtual_text = { source = true },
  float = { source = true },
}
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
vim.keymap.set('n', '<leader>ih', function(bufnr)
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = 'Toggle [I]nlay [H]int' })

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Delete, change, add surrounding pairs
  'tpope/vim-surround',
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    config = function()
      -- Two important keymaps to use while in telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- telescope picker.

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
      local builtin = require 'telescope.builtin'

      -- Enable telescope extensions, if they are installed
      -- pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      vim.keymap.set('n', '<C-p>', function()
        local opts = {} -- define here if you want to define something
        local ok = pcall(builtin.git_files, opts)
        if not ok then builtin.find_files(opts) end
      end)
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[F]ind [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })

      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut to edit dotfiles
      vim.keymap.set('n', '<leader>ed', function()
        builtin.git_files { cwd = '~' }
      end, { desc = '[E]dit [D]otfiles' })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      -- Useful status updates for LSP
      { "j-hui/fidget.nvim", opts = {} },
      -- Useful status updates for LSP
      { "folke/neodev.nvim", opts = {} }
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local nmap = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          -- Navigation
          nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- LSP actions
          nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
          nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

          -- Lesser used LSP functionality
          nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Format the current buffer
          nmap('<leader>f', vim.lsp.buf.format, '[F]ormat');
        end
      })

      -- Make nvim-cmp aware of LSP capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

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
              runtime = { version = 'LuaJIT' },
              diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim', 'require' },
              },
              workspace = {
                checkThirdParty = false,
                library = {
                  '${3rd}/luv/library',
                  unpack(vim.api.nvim_get_runtime_file('', true)),
                },
                -- If lua_ls is really slow on your computer, you can try this instead:
                -- library = { vim.env.VIMRUNTIME },
              },
              telemetry = {
                enable = false,
              },
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
          root_dir = function(fname)
            -- Copied from default, but we don't want to set the workspace to the root
            local root = require('lspconfig').util.root_pattern('.luarc.json', '.luarc.jsonc', '.luacheckrc',
              '.stylua.toml',
              'stylua.toml', 'selene.toml', 'selene.yml', '.git')(fname) -- prevent workspace from being set to root
            if root == vim.loop.os_homedir() then return nil end
            return root or fname
          end,
        },
        -- Workaround so that deno and tsserver don't conflict. We prefer deno for single file mode.
        denols = {
          root_dir = require('lspconfig').util.root_pattern('mod.ts', 'deno.json', 'deno.jsonc'),
        },
        tsserver = {
          root_dir = function(fname)
            local deno_root = require('lspconfig').util.root_pattern('deno.json', 'deno.jsonc')(fname)
            if deno_root then return nil end
            return require('lspconfig').util.root_pattern('package.json')(fname)
          end,
          single_file_support = false,
          commands = {
            OrganizeImports = {
              function()
                local params = {
                  command = '_typescript.organizeImports',
                  arguments = { vim.api.nvim_buf_get_name(0) },
                  title = ''
                }
                vim.lsp.buf.execute_command(params)
              end,
              description = 'Organize Imports',
            }
          }
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                -- FIX: I don't think this is doing anything
                -- ref: https://github.com/microsoft/pyright/issues/4878#issuecomment-1553156526
                stubPath = vim.fn.stdpath("data") .. "/lazy/python-type-stubs",
                useLibraryCodeForTypes = false,
              }
            }
          }
        }
      }
      -- Setup mason so it can manage external tooling
      require('mason').setup()

      -- Ensure the servers above are installed
      local mason_lspconfig = require('mason-lspconfig')
      mason_lspconfig.setup {
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end
        }
      }
    end
  },
  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = "InsertEnter",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
      -- Pretty icons for LSP
      'onsails/lspkind-nvim',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'nvim_lsp', group_index = 2 },
          { name = 'path',     group_index = 2 },
          { name = 'luasnip',  group_index = 2 },
          { name = 'buffer',   group_index = 2 },
        },
        formatting = {
          format = require('lspkind').cmp_format {
            with_text = true,
            menu = {
              buffer = "[buf]",
              nvim_lsp = "[lsp]",
              luasnip = "[snip]",
              path = "[path]",
            },
          },
        }
      }
    end
  },
  { -- Treesitter, syntax highlighting, text objects
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-context', opts = {} },
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/playground',
    },
    config = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
      vim.filetype.add({ extension = { wgsl = "wgsl", mdx = "mdx" } })
      vim.treesitter.language.register('markdown', 'mdx')
      vim.keymap.set('n', '<leader>tc', ":TSContextToggle<CR>", { desc = '[T]oggle [C]ontext' })
      require('nvim-treesitter.configs').setup {
        -- Add languages to be installed here that you want installed for treesitter
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>A'] = '@parameter.inner',
            },
          },
        },
      }
    end,
  },
  { -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false }
  },
  { -- Nice status line
    'stevearc/dressing.nvim',
    opts = {},
  },
  { -- Theme
    -- "olivercederborg/poimandres.nvim",
    "catppuccin/nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.termguicolors = true
      -- vim.cmd.colorscheme "poimandres"
      vim.cmd.colorscheme "catppuccin-mocha"
    end
  },
  { -- justfile syntax
    "NoahTheDuke/vim-just",
    ft = { "just" },
  },
  { -- Open files on GitHub in browser
    "almo7aya/openingh.nvim",
    config = function()
      --  Open in lines on GitHub in browser
      vim.keymap.set('n', '<leader>gh', ':OpenInGHFile <CR>', { silent = true, noremap = true })
      vim.keymap.set('v', '<leader>gh', ':OpenInGHFileLines <CR>', { silent = true, noremap = true })
    end
  },
  {
    'saecki/crates.nvim',
    tag = 'stable',
    config = function()
      require('crates').setup()
    end,
  },
  'github/copilot.vim',
  {
    'f-person/git-blame.nvim',
    opts = {
      enabled = false
    }
  },
  { -- https://github.com/microsoft/pyright/issues/4878#issuecomment-1553156526
    "microsoft/python-type-stubs",
    cond = false
  },
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {
      enabled = false
    }
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,
    opts = {},
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons",
      -- { 'MeanderingProgrammer/render-markdown.nvim', opts = { file_types = { "markdown", "Avante" } }, ft = { "markdown", "Avante" }, },
    },
  }
})
