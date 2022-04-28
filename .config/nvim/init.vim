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
Plug 'snakemake/snakemake', {'rtp': 'misc/vim'}

" Delete, change, add surrounding pairs
Plug 'tpope/vim-surround'

" make hlsearch nicer
Plug 'romainl/vim-cool'

" Github Copilot
" Plug 'github/copilot.vim'
" imap <silent><script><expr> <C-m> copilot#Accept("\<CR>")
" let g:copilot_no_tab_map = v:true

call plug#end()


" =============================================================================
" # Autocommands
" =============================================================================

" Jump to last cursor position unless it's invalid or in an event handler
autocmd BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\   exe "normal g`\"" |
\ endif

" =============================================================================
" # Colors
" =============================================================================

set background=dark
let base16colorspace=256
colorscheme base16-gruvbox-dark-hard

" =============================================================================
" # Key mappings
" =============================================================================

" Ctrl+j as Esc
" nnoremap <C-j> <Esc>
" inoremap <C-j> <Esc>

" Copy clipboard
map <leader>y "*y

" Toggle through buffers
nnoremap <leader><leader> <c-^>

" Insert a hash rocket with <c-l>
imap <c-l> <space>=><space>

" open current file with default app
nmap <leader>x :!open %<cr><cr>

" =============================================================================
" # Editor settings
" =============================================================================

" Turn folding off
set nofoldenable

" Turn on syntax highlighting.
syntax on

" Default settings for spacing
set tabstop=4
set shiftwidth=4
" set expandtab

" Completion
" Better display for messages
set cmdheight=1

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

" Permanent undo
set undodir=~/.vimdid
set undofile

" Having longer update time leads to noticeable delays 
" and poor user experience.
set updatetime=300

" Always show the status line at the bottom, even if you only have one window open.
set laststatus=2

set mouse=a " Enable mouse usage (all modes) in terminals

" Sane splits
set splitright
set splitbelow

" https://github.com/vim/vim/issues/1735#issuecomment-383353563
set lazyredraw
set synmaxcol=500
set laststatus=2

set nowrap
" Insert only one space when joining lines that contain sentence-terminating punctuation like `.`.
set nojoinspaces

set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

" Proper search
set incsearch
set ignorecase smartcase
set gdefault

set encoding=utf-8
set ambiwidth=single

" =============================================================================
" # Telescope
" =============================================================================
"
noremap <C-p> :Telescope git_files<CR>
noremap <leader>ff :Telescope find_files<CR>
noremap <leader>; :Telescope buffers<CR>
noremap <leader>s :Telescope live_grep<CR>
noremap <space>ca :Telescope lsp_code_actions<CR>
noremap <space>d :Telescope diagnostics<CR>
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
local on_attach = function()
   -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = 0 })
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = 0 })
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = 0 })
  vim.keymap.set('n', 'gT', vim.lsp.buf.type_definition, { buffer = 0 })
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = 0 })
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = 0 })
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, { buffer = 0 })
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { buffer = 0 })
  vim.keymap.set('n', '<space>dn', vim.diagnostic.goto_next, { buffer = 0 })
  vim.keymap.set('n', '<space>dp', vim.diagnostic.goto_prev, { buffer = 0 })
end

-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').update_capabilities(
  vim.lsp.protocol.make_client_capabilities()
)

nvim_lsp.pyright.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

nvim_lsp.tsserver.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

require('rust-tools').setup {
  server = {
    capabilities = capabilities,
    on_attach = on_attach,
    standalone = false,
    cmd = { "rustup", "run", "nightly", "rust-analyzer" },
  }
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
    { name = 'buffer' },
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  formatting = {
    format = require('lspkind').cmp_format {
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
