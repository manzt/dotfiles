set rtp +=~/.vim

nnoremap <SPACE> <Nop>
let mapleader="\<Space>"


" =============================================================================
" # PLUGINS
" =============================================================================

call plug#begin()

Plug 'editorconfig/editorconfig-vim'

" Color scheme
Plug 'chriskempson/base16-vim'

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Semantic language support
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'

Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'

" pretty icons for LSP
Plug 'onsails/lspkind-nvim'

Plug 'simrat39/rust-tools.nvim'
Plug 'evanleck/vim-svelte'

" Delete, change, add surrounding pairs
Plug 'tpope/vim-surround'

" Nice find highlighting
Plug 'romainl/vim-cool'
Plug 'cespare/vim-toml'
Plug 'snakemake/snakemake', {'rtp': 'misc/vim'}


" Disable copilot
" Plug 'github/copilot.vim'

call plug#end()

" =============================================================================
" # Autocommands
" =============================================================================

" Jump to last edit position on opening file
if has("autocmd")
  " https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
  au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" =============================================================================
" # Deal with colors ... 
" =============================================================================

if !has('gui_running')
  set t_Co=256
endif

if (match($TERM, "-256color") != -1) && (match($TERM, "screen-256color") == -1)
  " screen does not (yet) support truecolor
  set termguicolors
endif

set background=dark
let base16colorspace=256
colorscheme base16-gruvbox-dark-hard

highlight Normal guibg=NONE ctermbg=NONE

" call matchadd('ColorColumn', '\%81v', 90)
highlight ColorColumn ctermbg=8
set colorcolumn=90

" =============================================================================
" # Key mappings
" =============================================================================

" Ctrl+j as Esc
nnoremap <C-j> <Esc>
inoremap <C-j> <Esc>

" Open hotkeys
map <C-p> :Files<CR>
nmap <leader>; :Buffers<CR>

" Copy clipboard
map <leader>y "*y

" <leader>s for Rg search
noremap <leader>s :Rg<CR>

" Toggle through buffers
nnoremap <leader><leader> <c-^>

nmap <leader>x :!open %<cr><cr>

" =============================================================================
" # Editor settings
" =============================================================================

set nofoldenable

" Turn on syntax highlighting.
syntax on

" Default settings for spacing
set tabstop=4
set shiftwidth=4
" set expandtab

" Completion
" Better display for messages
set cmdheight=2

" Keep more context when scrolling off the end of a buffer
set scrolloff=3

" Enable file type detection, use default filetype settings
filetype plugin indent on
set autoindent

" If a file is changed outside of vim, automatically reload it without asking
set autoread

" Line numbers
set number
set relativenumber 
set numberwidth=2

set list
set listchars=tab:→\ ,trail:·
" set listchars=tab:▶\ ,trail:·


" Permanent undo
set undodir=~/.vimdid
set undofile

" TextEdit might fail if hidden is not set.
set hidden

" Having longer update time leads to noticeable delays 
" and poor user experience.
set updatetime=300

" Always show the status line at the bottom, even if you only have one window open.
set laststatus=2

set mouse=a " Enable mouse usage (all modes) in terminals

" Enable searching as you type, rather than waiting till you press enter.
set incsearch

" Ignore patterns for ctrlp
set wildignore+=*/tmp/*
set wildignore+=*/node_modules/*

" Sane splits
set splitright
set splitbelow

set showcmd " Show (partial) command in status line.

set ttyfast
" https://github.com/vim/vim/issues/1735#issuecomment-383353563
set lazyredraw
set synmaxcol=500
set laststatus=2

set hidden
set nowrap
set nojoinspaces

set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

" Proper search
set incsearch
set ignorecase
set smartcase
set gdefault

set encoding=utf-8
set ambiwidth=single


" =============================================================================
" # LSP client setup
" =============================================================================

lua << EOF
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

   -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local flags = { debounce_text_changes = 150 }

nvim_lsp.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  flags = flags
}

-- nvim_lsp.denols.setup {
--   root_dir = nvim_lsp.util.root_pattern("deno.json"),
--   on_attach = on_attach,
--   flags,
-- }

nvim_lsp.tsserver.setup {
  root_dir = nvim_lsp.util.root_pattern("package.json"),
  on_attach = on_attach,
  capabilities = capabilities,
  flags = flags,
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)

require('rust-tools').setup {
  tools = {
    autoSetHints = true,
    hover_with_actions = true,
    inlay_hints = {
      show_parameter_hints = false,
      parameter_hints_prefix = "",
      other_hints_prefix = "",
    },
  },
  server = {
    on_attach = on_attach,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy"
        },
      }
    }
  },
}
EOF

" =============================================================================
" # Auto complete setup
" =============================================================================

" Set completeopt to have a better completion experience
" :help completeopt
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect

lua <<EOF
local lspkind = require 'lspkind'
lspkind.init()

local cmp = require 'cmp'
cmp.setup {
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.close(),
    ["<c-y>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    ["<c-space>"] = cmp.mapping.complete(),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'luasnip' },
    { name = 'buffer', keyword_length = 3 },
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  formatting = {
    format = lspkind.cmp_format {
      with_text = true,
      menu = {
        buffer = "[buf]",
        nvim_lsp = "[LSP]",
        luasnip = "[snip]",
        path = "[path]",
      },
    },
  },
  experimental = {
    native_menu = false,
    ghost_text = true,
  },
}
EOF

au BufReadPost *.njk set syntax=html

" https://github.com/neovim/nvim-lspconfig/issues/195#issuecomment-753644842
lua <<EOF
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    -- disable virtual text
    virtual_text = false,
    -- show signs
    signs = true,
    -- delay update diagnostics
    update_in_insert = false,
    -- display_diagnostic_autocmds = { "InsertLeave" },
  }
)
EOF
