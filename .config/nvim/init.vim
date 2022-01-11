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
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-telescope/telescope.nvim'

" Semantic language support
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'

" Snippets
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'

" Pretty icons for LSP
Plug 'onsails/lspkind-nvim'

" Language/format-specific tools
Plug 'simrat39/rust-tools.nvim'
Plug 'evanleck/vim-svelte'
Plug 'romainl/vim-cool'
Plug 'cespare/vim-toml'
Plug 'snakemake/snakemake', {'rtp': 'misc/vim'}

" Delete, change, add surrounding pairs
Plug 'tpope/vim-surround'

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

set background=dark
let base16colorspace=256
colorscheme base16-gruvbox-dark-hard

highlight Normal guibg=NONE ctermbg=NONE
highlight ColorColumn ctermbg=8
set colorcolumn=90

" =============================================================================
" # Key mappings
" =============================================================================

" Ctrl+j as Esc
nnoremap <C-j> <Esc>
inoremap <C-j> <Esc>

" Copy clipboard
map <leader>y "*y

" Toggle through buffers
nnoremap <leader><leader> <c-^>

" open current file with default app
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

" Sane splits
set splitright
set splitbelow

set showcmd " Show (partial) command in status line.

set ttyfast
" https://github.com/vim/vim/issues/1735#issuecomment-383353563
set lazyredraw
set synmaxcol=500
set laststatus=2

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
" # Telescope
" =============================================================================
"
noremap <leader>ft :Telescope git_files<CR>
noremap <leader>fd :Telescope find_files<CR>
noremap <leader>; :Telescope buffers<CR>
noremap <leader>s :Telescope grep_string<CR>
noremap <space>ca :Telescope lsp_code_actions<CR>
noremap <space>d :Telescope diagnostics bufnr=0<CR>
noremap <space>D :Telescope lsp_type_definitions<CR>
noremap gr :Telescope lsp_references<CR>

" edit dotfiles
noremap <leader>ed :Telescope git_files cwd=~/github/manzt/dotfiles<CR>


lua << EOF
require('telescope').load_extension('fzf')
EOF

" =============================================================================
" # LSP
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
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
end

-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').update_capabilities(
  vim.lsp.protocol.make_client_capabilities()
)
local flags = { debounce_text_changes = 150 }

local servers = { 'pyright', 'tsserver' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = flags,
  }
end

-- TODO(2022-10-01): Turn off for now. Issues with both denols/tsserver running for JS/TS.
-- nvim_lsp.denols.setup {
--   root_dir = nvim_lsp.util.root_pattern("deno.json"),
--   on_attach = on_attach,
--   flags,
-- }


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
